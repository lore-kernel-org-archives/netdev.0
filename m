From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: Don't use entire L2T table, use only its slice
Date: Tue,  7 Jul 2015 21:49:18 +0530
Message-ID: <1436285961-8674-2-git-send-email-hariprasad@chelsio.com>
References: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5385 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756740AbbGGLFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 07:05:31 -0400
In-Reply-To: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was retrieving the parameters for the bounds of its
slice of the L2T from the firmware and then throwing those away and
using the entire table. This corrects that problem.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        | 94 ++++++++++++++-----------
 drivers/net/ethernet/chelsio/cxgb4/l2t.h        | 18 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      |  1 -
 4 files changed, 71 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c64b5a9..324244a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4760,7 +4760,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	cfg_queues(adapter);
 
-	adapter->l2t = t4_init_l2t();
+	adapter->l2t = t4_init_l2t(adapter->l2t_start, adapter->l2t_end);
 	if (!adapter->l2t) {
 		/* We tolerate a lack of L2T, giving up some functionality */
 		dev_warn(&pdev->dev, "could not allocate L2T, continuing\n");
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 252efc2..ac27898 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -51,24 +51,17 @@
 #define VLAN_NONE 0xfff
 
 /* identifies sync vs async L2T_WRITE_REQs */
-#define F_SYNC_WR    (1 << 12)
-
-enum {
-	L2T_STATE_VALID,      /* entry is up to date */
-	L2T_STATE_STALE,      /* entry may be used but needs revalidation */
-	L2T_STATE_RESOLVING,  /* entry needs address resolution */
-	L2T_STATE_SYNC_WRITE, /* synchronous write of entry underway */
-
-	/* when state is one of the below the entry is not hashed */
-	L2T_STATE_SWITCHING,  /* entry is being used by a switching filter */
-	L2T_STATE_UNUSED      /* entry not in use */
-};
+#define SYNC_WR_S    12
+#define SYNC_WR_V(x) ((x) << SYNC_WR_S)
+#define SYNC_WR_F    SYNC_WR_V(1)
 
 struct l2t_data {
+	unsigned int l2t_start;     /* start index of our piece of the L2T */
+	unsigned int l2t_size;      /* number of entries in l2tab */
 	rwlock_t lock;
 	atomic_t nfree;             /* number of free entries */
 	struct l2t_entry *rover;    /* starting point for next allocation */
-	struct l2t_entry l2tab[L2T_SIZE];
+	struct l2t_entry l2tab[0];  /* MUST BE LAST */
 };
 
 static inline unsigned int vlan_prio(const struct l2t_entry *e)
@@ -85,29 +78,36 @@ static inline void l2t_hold(struct l2t_data *d, struct l2t_entry *e)
 /*
  * To avoid having to check address families we do not allow v4 and v6
  * neighbors to be on the same hash chain.  We keep v4 entries in the first
- * half of available hash buckets and v6 in the second.
+ * half of available hash buckets and v6 in the second.  We need at least two
+ * entries in our L2T for this scheme to work.
  */
 enum {
-	L2T_SZ_HALF = L2T_SIZE / 2,
-	L2T_HASH_MASK = L2T_SZ_HALF - 1
+	L2T_MIN_HASH_BUCKETS = 2,
 };
 
-static inline unsigned int arp_hash(const u32 *key, int ifindex)
+static inline unsigned int arp_hash(struct l2t_data *d, const u32 *key,
+				    int ifindex)
 {
-	return jhash_2words(*key, ifindex, 0) & L2T_HASH_MASK;
+	unsigned int l2t_size_half = d->l2t_size / 2;
+
+	return jhash_2words(*key, ifindex, 0) % l2t_size_half;
 }
 
-static inline unsigned int ipv6_hash(const u32 *key, int ifindex)
+static inline unsigned int ipv6_hash(struct l2t_data *d, const u32 *key,
+				     int ifindex)
 {
+	unsigned int l2t_size_half = d->l2t_size / 2;
 	u32 xor = key[0] ^ key[1] ^ key[2] ^ key[3];
 
-	return L2T_SZ_HALF + (jhash_2words(xor, ifindex, 0) & L2T_HASH_MASK);
+	return (l2t_size_half +
+		(jhash_2words(xor, ifindex, 0) % l2t_size_half));
 }
 
-static unsigned int addr_hash(const u32 *addr, int addr_len, int ifindex)
+static unsigned int addr_hash(struct l2t_data *d, const u32 *addr,
+			      int addr_len, int ifindex)
 {
-	return addr_len == 4 ? arp_hash(addr, ifindex) :
-			       ipv6_hash(addr, ifindex);
+	return addr_len == 4 ? arp_hash(d, addr, ifindex) :
+			       ipv6_hash(d, addr, ifindex);
 }
 
 /*
@@ -139,6 +139,8 @@ static void neigh_replace(struct l2t_entry *e, struct neighbour *n)
  */
 static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 {
+	struct l2t_data *d = adap->l2t;
+	unsigned int l2t_idx = e->idx + d->l2t_start;
 	struct sk_buff *skb;
 	struct cpl_l2t_write_req *req;
 
@@ -150,10 +152,10 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 	INIT_TP_WR(req, 0);
 
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ,
-					e->idx | (sync ? F_SYNC_WR : 0) |
+					l2t_idx | (sync ? SYNC_WR_F : 0) |
 					TID_QID_V(adap->sge.fw_evtq.abs_id)));
 	req->params = htons(L2T_W_PORT_V(e->lport) | L2T_W_NOREPLY_V(!sync));
-	req->l2t_idx = htons(e->idx);
+	req->l2t_idx = htons(l2t_idx);
 	req->vlan = htons(e->vlan);
 	if (e->neigh && !(e->neigh->dev->flags & IFF_LOOPBACK))
 		memcpy(e->dmac, e->neigh->ha, sizeof(e->dmac));
@@ -190,18 +192,19 @@ static void send_pending(struct adapter *adap, struct l2t_entry *e)
  */
 void do_l2t_write_rpl(struct adapter *adap, const struct cpl_l2t_write_rpl *rpl)
 {
+	struct l2t_data *d = adap->l2t;
 	unsigned int tid = GET_TID(rpl);
-	unsigned int idx = tid & (L2T_SIZE - 1);
+	unsigned int l2t_idx = tid % L2T_SIZE;
 
 	if (unlikely(rpl->status != CPL_ERR_NONE)) {
 		dev_err(adap->pdev_dev,
 			"Unexpected L2T_WRITE_RPL status %u for entry %u\n",
-			rpl->status, idx);
+			rpl->status, l2t_idx);
 		return;
 	}
 
-	if (tid & F_SYNC_WR) {
-		struct l2t_entry *e = &adap->l2t->l2tab[idx];
+	if (tid & SYNC_WR_F) {
+		struct l2t_entry *e = &d->l2tab[l2t_idx - d->l2t_start];
 
 		spin_lock(&e->lock);
 		if (e->state != L2T_STATE_SWITCHING) {
@@ -276,7 +279,7 @@ static struct l2t_entry *alloc_l2e(struct l2t_data *d)
 		return NULL;
 
 	/* there's definitely a free entry */
-	for (e = d->rover, end = &d->l2tab[L2T_SIZE]; e != end; ++e)
+	for (e = d->rover, end = &d->l2tab[d->l2t_size]; e != end; ++e)
 		if (atomic_read(&e->refcnt) == 0)
 			goto found;
 
@@ -368,7 +371,7 @@ struct l2t_entry *cxgb4_l2t_get(struct l2t_data *d, struct neighbour *neigh,
 	int addr_len = neigh->tbl->key_len;
 	u32 *addr = (u32 *)neigh->primary_key;
 	int ifidx = neigh->dev->ifindex;
-	int hash = addr_hash(addr, addr_len, ifidx);
+	int hash = addr_hash(d, addr, addr_len, ifidx);
 
 	if (neigh->dev->flags & IFF_LOOPBACK)
 		lport = netdev2pinfo(physdev)->tx_chan + 4;
@@ -481,7 +484,7 @@ void t4_l2t_update(struct adapter *adap, struct neighbour *neigh)
 	int addr_len = neigh->tbl->key_len;
 	u32 *addr = (u32 *) neigh->primary_key;
 	int ifidx = neigh->dev->ifindex;
-	int hash = addr_hash(addr, addr_len, ifidx);
+	int hash = addr_hash(d, addr, addr_len, ifidx);
 
 	read_lock_bh(&d->lock);
 	for (e = d->l2tab[hash].first; e; e = e->next)
@@ -554,20 +557,30 @@ int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
 	return write_l2e(adap, e, 0);
 }
 
-struct l2t_data *t4_init_l2t(void)
+struct l2t_data *t4_init_l2t(unsigned int l2t_start, unsigned int l2t_end)
 {
+	unsigned int l2t_size;
 	int i;
 	struct l2t_data *d;
 
-	d = t4_alloc_mem(sizeof(*d));
+	if (l2t_start >= l2t_end || l2t_end >= L2T_SIZE)
+		return NULL;
+	l2t_size = l2t_end - l2t_start + 1;
+	if (l2t_size < L2T_MIN_HASH_BUCKETS)
+		return NULL;
+
+	d = t4_alloc_mem(sizeof(*d) + l2t_size * sizeof(struct l2t_entry));
 	if (!d)
 		return NULL;
 
+	d->l2t_start = l2t_start;
+	d->l2t_size = l2t_size;
+
 	d->rover = d->l2tab;
-	atomic_set(&d->nfree, L2T_SIZE);
+	atomic_set(&d->nfree, l2t_size);
 	rwlock_init(&d->lock);
 
-	for (i = 0; i < L2T_SIZE; ++i) {
+	for (i = 0; i < d->l2t_size; ++i) {
 		d->l2tab[i].idx = i;
 		d->l2tab[i].state = L2T_STATE_UNUSED;
 		spin_lock_init(&d->l2tab[i].lock);
@@ -578,9 +591,9 @@ struct l2t_data *t4_init_l2t(void)
 
 static inline void *l2t_get_idx(struct seq_file *seq, loff_t pos)
 {
-	struct l2t_entry *l2tab = seq->private;
+	struct l2t_data *d = seq->private;
 
-	return pos >= L2T_SIZE ? NULL : &l2tab[pos];
+	return pos >= d->l2t_size ? NULL : &d->l2tab[pos];
 }
 
 static void *l2t_seq_start(struct seq_file *seq, loff_t *pos)
@@ -620,6 +633,7 @@ static int l2t_seq_show(struct seq_file *seq, void *v)
 			 "Ethernet address  VLAN/P LP State Users Port\n");
 	else {
 		char ip[60];
+		struct l2t_data *d = seq->private;
 		struct l2t_entry *e = v;
 
 		spin_lock_bh(&e->lock);
@@ -628,7 +642,7 @@ static int l2t_seq_show(struct seq_file *seq, void *v)
 		else
 			sprintf(ip, e->v6 ? "%pI6c" : "%pI4", e->addr);
 		seq_printf(seq, "%4u %-25s %17pM %4d %u %2u   %c   %5u %s\n",
-			   e->idx, ip, e->dmac,
+			   e->idx + d->l2t_start, ip, e->dmac,
 			   e->vlan & VLAN_VID_MASK, vlan_prio(e), e->lport,
 			   l2e_state(e), atomic_read(&e->refcnt),
 			   e->neigh ? e->neigh->dev->name : "");
@@ -652,7 +666,7 @@ static int l2t_seq_open(struct inode *inode, struct file *file)
 		struct adapter *adap = inode->i_private;
 		struct seq_file *seq = file->private_data;
 
-		seq->private = adap->l2t->l2tab;
+		seq->private = adap->l2t;
 	}
 	return rc;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.h b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
index a30126c..b38dc52 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
@@ -39,6 +39,20 @@
 #include <linux/if_ether.h>
 #include <linux/atomic.h>
 
+enum { L2T_SIZE = 4096 };     /* # of L2T entries */
+
+enum {
+	L2T_STATE_VALID,      /* entry is up to date */
+	L2T_STATE_STALE,      /* entry may be used but needs revalidation */
+	L2T_STATE_RESOLVING,  /* entry needs address resolution */
+	L2T_STATE_SYNC_WRITE, /* synchronous write of entry underway */
+	L2T_STATE_NOARP,      /* Netdev down or removed*/
+
+	/* when state is one of the below the entry is not hashed */
+	L2T_STATE_SWITCHING,  /* entry is being used by a switching filter */
+	L2T_STATE_UNUSED      /* entry not in use */
+};
+
 struct adapter;
 struct l2t_data;
 struct neighbour;
@@ -56,7 +70,7 @@ struct cpl_l2t_write_rpl;
  */
 struct l2t_entry {
 	u16 state;                  /* entry state */
-	u16 idx;                    /* entry index */
+	u16 idx;                    /* entry index within in-memory table */
 	u32 addr[4];                /* next hop IP or IPv6 address */
 	int ifindex;                /* neighbor's net_device's ifindex */
 	struct neighbour *neigh;    /* associated neighbour */
@@ -104,7 +118,7 @@ void t4_l2t_update(struct adapter *adap, struct neighbour *neigh);
 struct l2t_entry *t4_l2t_alloc_switching(struct l2t_data *d);
 int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
 			 u8 port, u8 *eth_addr);
-struct l2t_data *t4_init_l2t(void);
+struct l2t_data *t4_init_l2t(unsigned int l2t_start, unsigned int l2t_end);
 void do_l2t_write_rpl(struct adapter *p, const struct cpl_l2t_write_rpl *rpl);
 
 extern const struct file_operations t4_l2t_fops;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index c8488f4..640369d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -47,7 +47,6 @@ enum {
 	TCB_SIZE       = 128,   /* TCB size */
 	NMTUS          = 16,    /* size of MTU table */
 	NCCTRL_WIN     = 32,    /* # of congestion control windows */
-	L2T_SIZE       = 4096,  /* # of L2T entries */
 	PM_NSTATS      = 5,     /* # of PM stats */
 	MBOX_LEN       = 64,    /* mailbox size in bytes */
 	TRACE_LEN      = 112,   /* length of trace data and mask */
-- 
2.3.4
