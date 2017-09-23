From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/2] neigh: make strucrt neigh_table::entry_size unsigned int
Date: Sat, 23 Sep 2017 23:03:04 +0300
Message-ID: <20170923200304.GB24928@avx2>
References: <20170923200106.GA24928@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ganeshgr@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:45491 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdIWUDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 16:03:08 -0400
Received: by mail-wm0-f49.google.com with SMTP id q124so10839879wmb.0
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 13:03:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170923200106.GA24928@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Key length can't be negative.

Leave comparisons against nla_len() signed just in case truncated attribute
can sneak in there.

Space savings:

	add/remove: 0/0 grow/shrink: 0/7 up/down: 0/-7 (-7)
	function                                     old     new   delta
	pneigh_delete                                273     272      -1
	mlx5e_rep_netevent_event                    1415    1414      -1
	mlx5e_create_encap_header_ipv6              1194    1193      -1
	mlx5e_create_encap_header_ipv4              1071    1070      -1
	cxgb4_l2t_get                               1104    1103      -1
	__pneigh_lookup                               69      68      -1
	__neigh_create                              2452    2451      -1

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/ethernet/chelsio/cxgb4/l2t.c |    4 ++--
 include/net/neighbour.h                  |    2 +-
 net/core/neighbour.c                     |   18 +++++++++---------
 3 files changed, 12 insertions(+), 12 deletions(-)

--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -422,7 +422,7 @@ struct l2t_entry *cxgb4_l2t_get(struct l2t_data *d, struct neighbour *neigh,
 	u8 lport;
 	u16 vlan;
 	struct l2t_entry *e;
-	int addr_len = neigh->tbl->key_len;
+	unsigned int addr_len = neigh->tbl->key_len;
 	u32 *addr = (u32 *)neigh->primary_key;
 	int ifidx = neigh->dev->ifindex;
 	int hash = addr_hash(d, addr, addr_len, ifidx);
@@ -536,7 +536,7 @@ void t4_l2t_update(struct adapter *adap, struct neighbour *neigh)
 	struct l2t_entry *e;
 	struct sk_buff_head *arpq = NULL;
 	struct l2t_data *d = adap->l2t;
-	int addr_len = neigh->tbl->key_len;
+	unsigned int addr_len = neigh->tbl->key_len;
 	u32 *addr = (u32 *) neigh->primary_key;
 	int ifidx = neigh->dev->ifindex;
 	int hash = addr_hash(d, addr, addr_len, ifidx);
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -191,7 +191,7 @@ struct neigh_hash_table {
 struct neigh_table {
 	int			family;
 	unsigned int		entry_size;
-	int			key_len;
+	unsigned int		key_len;
 	__be16			protocol;
 	__u32			(*hash)(const void *pkey,
 					const struct net_device *dev,
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -457,7 +457,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 				     const void *pkey)
 {
 	struct neighbour *n;
-	int key_len = tbl->key_len;
+	unsigned int key_len = tbl->key_len;
 	u32 hash_val;
 	struct neigh_hash_table *nht;
 
@@ -488,7 +488,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 				 struct net_device *dev, bool want_ref)
 {
 	u32 hash_val;
-	int key_len = tbl->key_len;
+	unsigned int key_len = tbl->key_len;
 	int error;
 	struct neighbour *n1, *rc, *n = neigh_alloc(tbl, dev);
 	struct neigh_hash_table *nht;
@@ -572,7 +572,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 }
 EXPORT_SYMBOL(__neigh_create);
 
-static u32 pneigh_hash(const void *pkey, int key_len)
+static u32 pneigh_hash(const void *pkey, unsigned int key_len)
 {
 	u32 hash_val = *(u32 *)(pkey + key_len - 4);
 	hash_val ^= (hash_val >> 16);
@@ -585,7 +585,7 @@ static u32 pneigh_hash(const void *pkey, int key_len)
 static struct pneigh_entry *__pneigh_lookup_1(struct pneigh_entry *n,
 					      struct net *net,
 					      const void *pkey,
-					      int key_len,
+					      unsigned int key_len,
 					      struct net_device *dev)
 {
 	while (n) {
@@ -601,7 +601,7 @@ static struct pneigh_entry *__pneigh_lookup_1(struct pneigh_entry *n,
 struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
 		struct net *net, const void *pkey, struct net_device *dev)
 {
-	int key_len = tbl->key_len;
+	unsigned int key_len = tbl->key_len;
 	u32 hash_val = pneigh_hash(pkey, key_len);
 
 	return __pneigh_lookup_1(tbl->phash_buckets[hash_val],
@@ -614,7 +614,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 				    struct net_device *dev, int creat)
 {
 	struct pneigh_entry *n;
-	int key_len = tbl->key_len;
+	unsigned int key_len = tbl->key_len;
 	u32 hash_val = pneigh_hash(pkey, key_len);
 
 	read_lock_bh(&tbl->lock);
@@ -659,7 +659,7 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
 		  struct net_device *dev)
 {
 	struct pneigh_entry *n, **np;
-	int key_len = tbl->key_len;
+	unsigned int key_len = tbl->key_len;
 	u32 hash_val = pneigh_hash(pkey, key_len);
 
 	write_lock_bh(&tbl->lock);
@@ -1662,7 +1662,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (tbl == NULL)
 		return -EAFNOSUPPORT;
 
-	if (nla_len(dst_attr) < tbl->key_len)
+	if (nla_len(dst_attr) < (int)tbl->key_len)
 		goto out;
 
 	if (ndm->ndm_flags & NTF_PROXY) {
@@ -1730,7 +1730,7 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (tbl == NULL)
 		return -EAFNOSUPPORT;
 
-	if (nla_len(tb[NDA_DST]) < tbl->key_len)
+	if (nla_len(tb[NDA_DST]) < (int)tbl->key_len)
 		goto out;
 	dst = nla_data(tb[NDA_DST]);
 	lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
