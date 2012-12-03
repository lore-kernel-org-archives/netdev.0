From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH V3 2/5] cxgb4: Add LE hash collision bug fix path in LLD driver
Date: Mon,  3 Dec 2012 16:52:58 +0530
Message-ID: <1354533781-31575-3-git-send-email-vipul@chelsio.com>
References: <1354533781-31575-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	abhishek@chelsio.com, Vipul Pandya <vipul@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5892 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab2LCL1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 06:27:48 -0500
In-Reply-To: <1354533781-31575-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It supports establishing passive open connection through firmware filter work
request. Passive open connection will go through this path as now instead of
listening server we create a server filter which will redirect the incoming SYN
packet to the offload queue.

It divides filter region into regular filters and server filter portion. It
introduces new server filter region which will be exclusively used for creating
server filters. This region will not overlap with regular filter region.

It provides new API cxgb4_alloc_sftid in LLD for getting stid in case of LE
hash collision path. This new stid will be used to open server filter in the
filter region.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
V2: Changed commenting style from kernel-doc format('/**') to normal
V3: Resending the whole patch series again with the missing patches in V2

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  150 +++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   15 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   33 +++++
 4 files changed, 193 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b6403d1..868acde 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -35,6 +35,8 @@
 #ifndef __CXGB4_H__
 #define __CXGB4_H__
 
+#include "t4_hw.h"
+
 #include <linux/bitops.h>
 #include <linux/cache.h>
 #include <linux/interrupt.h>
@@ -212,6 +214,8 @@ struct tp_err_stats {
 struct tp_params {
 	unsigned int ntxchan;        /* # of Tx channels */
 	unsigned int tre;            /* log2 of core clocks per TP tick */
+	unsigned short tx_modq_map;  /* TX modulation scheduler queue to */
+				     /* channel map */
 
 	uint32_t dack_re;            /* DACK timer resolution */
 	unsigned short tx_modq[NCHAN];	/* channel to modulation queue map */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a678287..f55386b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2489,7 +2489,34 @@ int cxgb4_alloc_stid(struct tid_info *t, int family, void *data)
 EXPORT_SYMBOL(cxgb4_alloc_stid);
 
 /*
- * Release a server TID.
+ * Allocate a server filter TID and set it to the supplied value.
+ */
+int cxgb4_alloc_sftid(struct tid_info *t, int family, void *data)
+{
+	int stid;
+
+	spin_lock_bh(&t->stid_lock);
+	if (family == PF_INET) {
+		stid = find_next_zero_bit(t->stid_bmap,
+				t->nstids + t->nsftids, t->nstids);
+		if (stid < (t->nstids + t->nsftids))
+			__set_bit(stid, t->stid_bmap);
+		else
+			stid = -1;
+	} else {
+		stid = -1;
+	}
+	if (stid >= 0) {
+		t->stid_tab[stid].data = data;
+		stid += t->stid_base;
+		t->stids_in_use++;
+	}
+	spin_unlock_bh(&t->stid_lock);
+	return stid;
+}
+EXPORT_SYMBOL(cxgb4_alloc_sftid);
+
+/* Release a server TID.
  */
 void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family)
 {
@@ -2604,12 +2631,14 @@ static int tid_init(struct tid_info *t)
 	unsigned int stid_bmap_size;
 	unsigned int natids = t->natids;
 
-	stid_bmap_size = BITS_TO_LONGS(t->nstids);
+	stid_bmap_size = BITS_TO_LONGS(t->nstids + t->nsftids);
 	size = t->ntids * sizeof(*t->tid_tab) +
 	       natids * sizeof(*t->atid_tab) +
 	       t->nstids * sizeof(*t->stid_tab) +
+	       t->nsftids * sizeof(*t->stid_tab) +
 	       stid_bmap_size * sizeof(long) +
-	       t->nftids * sizeof(*t->ftid_tab);
+	       t->nftids * sizeof(*t->ftid_tab) +
+	       t->nsftids * sizeof(*t->ftid_tab);
 
 	t->tid_tab = t4_alloc_mem(size);
 	if (!t->tid_tab)
@@ -2617,7 +2646,7 @@ static int tid_init(struct tid_info *t)
 
 	t->atid_tab = (union aopen_entry *)&t->tid_tab[t->ntids];
 	t->stid_tab = (struct serv_entry *)&t->atid_tab[natids];
-	t->stid_bmap = (unsigned long *)&t->stid_tab[t->nstids];
+	t->stid_bmap = (unsigned long *)&t->stid_tab[t->nstids + t->nsftids];
 	t->ftid_tab = (struct filter_entry *)&t->stid_bmap[stid_bmap_size];
 	spin_lock_init(&t->stid_lock);
 	spin_lock_init(&t->atid_lock);
@@ -2633,7 +2662,7 @@ static int tid_init(struct tid_info *t)
 			t->atid_tab[natids - 1].next = &t->atid_tab[natids];
 		t->afree = t->atid_tab;
 	}
-	bitmap_zero(t->stid_bmap, t->nstids);
+	bitmap_zero(t->stid_bmap, t->nstids + t->nsftids);
 	return 0;
 }
 
@@ -2995,6 +3024,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 {
 	void *handle;
 	struct cxgb4_lld_info lli;
+	unsigned short i;
 
 	lli.pdev = adap->pdev;
 	lli.l2t = adap->l2t;
@@ -3021,10 +3051,16 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.ucq_density = 1 << QUEUESPERPAGEPF0_GET(
 			t4_read_reg(adap, SGE_INGRESS_QUEUES_PER_PAGE_PF) >>
 			(adap->fn * 4));
+	lli.filt_mode = tp_vlan_pri_map;
+	/* MODQ_REQ_MAP sets queues 0-3 to chan 0-3 */
+	for (i = 0; i < NCHAN; i++)
+		lli.tx_modq[i] = i;
 	lli.gts_reg = adap->regs + MYPF_REG(SGE_PF_GTS);
 	lli.db_reg = adap->regs + MYPF_REG(SGE_PF_KDOORBELL);
 	lli.fw_vers = adap->params.fw_vers;
 	lli.dbfifo_int_thresh = dbfifo_int_thresh;
+	lli.sge_pktshift = adap->sge.pktshift;
+	lli.enable_fw_ofld_conn = adap->flags & FW_OFLD_CONN;
 
 	handle = ulds[uld].add(&lli);
 	if (IS_ERR(handle)) {
@@ -3266,7 +3302,7 @@ static int delete_filter(struct adapter *adapter, unsigned int fidx)
 	struct filter_entry *f;
 	int ret;
 
-	if (fidx >= adapter->tids.nftids)
+	if (fidx >= adapter->tids.nftids + adapter->tids.nsftids)
 		return -EINVAL;
 
 	f = &adapter->tids.ftid_tab[fidx];
@@ -3279,6 +3315,77 @@ static int delete_filter(struct adapter *adapter, unsigned int fidx)
 	return 0;
 }
 
+int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
+		__be32 sip, __be16 sport, unsigned int queue)
+{
+	int ret;
+	struct filter_entry *f;
+	struct adapter *adap;
+	int i;
+	u8 *val;
+
+	adap = netdev2adap(dev);
+
+	/* Check to make sure the filter requested is writable ...
+	 */
+	f = &adap->tids.ftid_tab[stid];
+	ret = writable_filter(f);
+	if (ret)
+		return ret;
+
+	/* Clear out any old resources being used by the filter before
+	 * we start constructing the new filter.
+	 */
+	if (f->valid)
+		clear_filter(adap, f);
+
+	/* Clear out filter specifications */
+	memset(&f->fs, 0, sizeof(struct ch_filter_specification));
+	f->fs.val.lport = cpu_to_be16(sport);
+	f->fs.mask.lport  = ~0;
+	val = (u8 *)&sip;
+	if ((val[0] | val[1] | val[2] | val[3]) != 0)
+		for (i = 0; i < 4; i++) {
+			f->fs.val.lip[i] = val[i];
+			f->fs.mask.lip[i] = ~0;
+		}
+
+	f->fs.dirsteer = 1;
+	f->fs.iq = queue;
+	/* Mark filter as locked */
+	f->locked = 1;
+	f->fs.rpttid = 1;
+
+	ret = set_filter_wr(adap, stid);
+	if (ret) {
+		clear_filter(adap, f);
+		return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(cxgb4_create_server_filter);
+
+int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
+		unsigned int queue, bool ipv6)
+{
+	int ret;
+	struct filter_entry *f;
+	struct adapter *adap;
+
+	adap = netdev2adap(dev);
+	f = &adap->tids.ftid_tab[stid];
+	/* Unlock the filter */
+	f->locked = 0;
+
+	ret = delete_filter(adap, stid);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+EXPORT_SYMBOL(cxgb4_remove_server_filter);
+
 static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
 						struct rtnl_link_stats64 *ns)
 {
@@ -3525,6 +3632,34 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	v = t4_read_reg(adap, TP_PIO_DATA);
 	t4_write_reg(adap, TP_PIO_DATA, v & ~CSUM_HAS_PSEUDO_HDR);
 
+	/* first 4 Tx modulation queues point to consecutive Tx channels */
+	adap->params.tp.tx_modq_map = 0xE4;
+	t4_write_reg(adap, A_TP_TX_MOD_QUEUE_REQ_MAP,
+		     V_TX_MOD_QUEUE_REQ_MAP(adap->params.tp.tx_modq_map));
+
+	/* associate each Tx modulation queue with consecutive Tx channels */
+	v = 0x84218421;
+	t4_write_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+			  &v, 1, A_TP_TX_SCHED_HDR);
+	t4_write_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+			  &v, 1, A_TP_TX_SCHED_FIFO);
+	t4_write_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+			  &v, 1, A_TP_TX_SCHED_PCMD);
+
+#define T4_TX_MODQ_10G_WEIGHT_DEFAULT 16 /* in KB units */
+	if (is_offload(adap)) {
+		t4_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT0,
+			     V_TX_MODQ_WEIGHT0(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     V_TX_MODQ_WEIGHT1(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     V_TX_MODQ_WEIGHT2(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     V_TX_MODQ_WEIGHT3(T4_TX_MODQ_10G_WEIGHT_DEFAULT));
+		t4_write_reg(adap, A_TP_TX_MOD_CHANNEL_WEIGHT,
+			     V_TX_MODQ_WEIGHT0(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     V_TX_MODQ_WEIGHT1(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     V_TX_MODQ_WEIGHT2(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     V_TX_MODQ_WEIGHT3(T4_TX_MODQ_10G_WEIGHT_DEFAULT));
+	}
+
 	/* get basic stuff going */
 	return t4_early_init(adap, adap->fn);
 }
@@ -4948,7 +5083,8 @@ static void __devexit remove_one(struct pci_dev *pdev)
 		 */
 		if (adapter->tids.ftid_tab) {
 			struct filter_entry *f = &adapter->tids.ftid_tab[0];
-			for (i = 0; i < adapter->tids.nftids; i++, f++)
+			for (i = 0; i < (adapter->tids.nftids +
+					adapter->tids.nsftids); i++, f++)
 				if (f->valid)
 					clear_filter(adapter, f);
 		}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 59a6133..065bbd5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -131,7 +131,7 @@ static inline void *lookup_atid(const struct tid_info *t, unsigned int atid)
 static inline void *lookup_stid(const struct tid_info *t, unsigned int stid)
 {
 	stid -= t->stid_base;
-	return stid < t->nstids ? t->stid_tab[stid].data : NULL;
+	return stid < (t->nstids + t->nsftids) ? t->stid_tab[stid].data : NULL;
 }
 
 static inline void cxgb4_insert_tid(struct tid_info *t, void *data,
@@ -143,6 +143,7 @@ static inline void cxgb4_insert_tid(struct tid_info *t, void *data,
 
 int cxgb4_alloc_atid(struct tid_info *t, void *data);
 int cxgb4_alloc_stid(struct tid_info *t, int family, void *data);
+int cxgb4_alloc_sftid(struct tid_info *t, int family, void *data);
 void cxgb4_free_atid(struct tid_info *t, unsigned int atid);
 void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family);
 void cxgb4_remove_tid(struct tid_info *t, unsigned int qid, unsigned int tid);
@@ -151,7 +152,10 @@ struct in6_addr;
 
 int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 			__be32 sip, __be16 sport, unsigned int queue);
-
+int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
+			       __be32 sip, __be16 sport, unsigned int queue);
+int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
+			       unsigned int queue, bool ipv6);
 static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 {
 	skb_set_queue_mapping(skb, (queue << 1) | prio);
@@ -223,9 +227,16 @@ struct cxgb4_lld_info {
 	unsigned int iscsi_iolen;            /* iSCSI max I/O length */
 	unsigned short udb_density;          /* # of user DB/page */
 	unsigned short ucq_density;          /* # of user CQs/page */
+	unsigned short filt_mode;            /* filter optional components */
+	unsigned short tx_modq[NCHAN];       /* maps each tx channel to a */
+					     /* scheduler queue */
 	void __iomem *gts_reg;               /* address of GTS register */
 	void __iomem *db_reg;                /* address of kernel doorbell */
 	int dbfifo_int_thresh;		     /* doorbell fifo int threshold */
+	unsigned int sge_pktshift;           /* Padding between CPL and */
+					     /*	packet data */
+	bool enable_fw_ofld_conn;            /* Enable connection through fw */
+					     /* WR */
 };
 
 struct cxgb4_uld_info {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index a1a8b57..66ab614 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1032,4 +1032,37 @@
 #define  ADDRESS(x)     ((x) << ADDRESS_SHIFT)
 
 #define XGMAC_PORT_INT_CAUSE 0x10dc
+
+#define A_TP_TX_MOD_QUEUE_REQ_MAP 0x7e28
+
+#define A_TP_TX_MOD_CHANNEL_WEIGHT 0x7e34
+
+#define S_TX_MOD_QUEUE_REQ_MAP    0
+#define M_TX_MOD_QUEUE_REQ_MAP    0xffffU
+#define V_TX_MOD_QUEUE_REQ_MAP(x) ((x) << S_TX_MOD_QUEUE_REQ_MAP)
+
+#define A_TP_TX_MOD_QUEUE_WEIGHT0 0x7e30
+
+#define S_TX_MODQ_WEIGHT3    24
+#define M_TX_MODQ_WEIGHT3    0xffU
+#define V_TX_MODQ_WEIGHT3(x) ((x) << S_TX_MODQ_WEIGHT3)
+
+#define S_TX_MODQ_WEIGHT2    16
+#define M_TX_MODQ_WEIGHT2    0xffU
+#define V_TX_MODQ_WEIGHT2(x) ((x) << S_TX_MODQ_WEIGHT2)
+
+#define S_TX_MODQ_WEIGHT1    8
+#define M_TX_MODQ_WEIGHT1    0xffU
+#define V_TX_MODQ_WEIGHT1(x) ((x) << S_TX_MODQ_WEIGHT1)
+
+#define S_TX_MODQ_WEIGHT0    0
+#define M_TX_MODQ_WEIGHT0    0xffU
+#define V_TX_MODQ_WEIGHT0(x) ((x) << S_TX_MODQ_WEIGHT0)
+
+#define A_TP_TX_SCHED_HDR 0x23
+
+#define A_TP_TX_SCHED_FIFO 0x24
+
+#define A_TP_TX_SCHED_PCMD 0x25
+
 #endif /* __T4_REGS_H */
-- 
1.7.1
