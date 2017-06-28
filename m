From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 8/9] nfp: add a stats handler for flower offloads
Date: Wed, 28 Jun 2017 22:30:01 +0200
Message-ID: <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:32891 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdF1Ub7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 16:31:59 -0400
Received: by mail-qt0-f180.google.com with SMTP id r30so59385780qtc.0
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 13:31:59 -0700 (PDT)
In-Reply-To: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously there was no way of updating flow rule stats after they
have been offloaded to hardware. This is solved by keeping track of
stats received from hardware and providing this to the TC handler
on request.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |   5 -
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |   5 +
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  29 +++++
 .../net/ethernet/netronome/nfp/flower/metadata.c   | 124 ++++++++++++++++++++-
 .../net/ethernet/netronome/nfp/flower/offload.c    |  20 +++-
 5 files changed, 175 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index 916a6196d2ba..0f5410aa66d6 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -52,11 +52,6 @@ nfp_flower_cmsg_get_hdr(struct sk_buff *skb)
 	return (struct nfp_flower_cmsg_hdr *)skb->data;
 }
 
-static void *nfp_flower_cmsg_get_data(struct sk_buff *skb)
-{
-	return (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;
-}
-
 static struct sk_buff *
 nfp_flower_cmsg_alloc(struct nfp_app *app, unsigned int size,
 		      enum nfp_flower_cmsg_type_port type)
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index 4c72e537af32..736c4848f073 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -300,6 +300,11 @@ nfp_flower_cmsg_pcie_port(u8 nfp_pcie, enum nfp_flower_cmsg_port_vnic_type type,
 			   NFP_FLOWER_CMSG_PORT_TYPE_PCIE_PORT);
 }
 
+static inline void *nfp_flower_cmsg_get_data(struct sk_buff *skb)
+{
+	return (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;
+}
+
 int nfp_flower_cmsg_portmod(struct nfp_repr *repr, bool carrier_ok);
 void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb);
 
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index ae54b8052043..cfa54540aff0 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -43,9 +43,13 @@ struct tc_to_netdev;
 struct net_device;
 struct nfp_app;
 
+#define NFP_FL_REPEATED_HASH_MAX	BIT(17)
 #define NFP_FLOWER_HASH_BITS		10
 #define NFP_FLOWER_HASH_SEED		129004
 
+#define NFP_FL_STATS_ENTRY_RS		BIT(20)
+#define NFP_FL_STATS_ELEM_RS		4
+
 #define NFP_FLOWER_MASK_ENTRY_RS	256
 #define NFP_FLOWER_MASK_ELEMENT_RS	1
 #define NFP_FLOWER_MASK_HASH_BITS	10
@@ -63,10 +67,17 @@ struct nfp_fl_mask_id {
 	u8 init_unallocated;
 };
 
+struct nfp_fl_stats_id {
+	struct circ_buf free_list;
+	u32 init_unalloc;
+	u8 repeated_em_count;
+};
+
 /**
  * struct nfp_flower_priv - Flower APP per-vNIC priv data
  * @nn:			Pointer to vNIC
  * @flower_version:	HW version of flower
+ * @stats_ids:		List of free stats ids
  * @mask_ids:		List of free mask ids
  * @mask_table:		Hash table used to store masks
  * @flow_table:		Hash table used to store flower rules
@@ -74,6 +85,7 @@ struct nfp_fl_mask_id {
 struct nfp_flower_priv {
 	struct nfp_net *nn;
 	u64 flower_version;
+	struct nfp_fl_stats_id stats_ids;
 	struct nfp_fl_mask_id mask_ids;
 	DECLARE_HASHTABLE(mask_table, NFP_FLOWER_MASK_HASH_BITS);
 	DECLARE_HASHTABLE(flow_table, NFP_FLOWER_HASH_BITS);
@@ -96,13 +108,28 @@ struct nfp_fl_rule_metadata {
 	__be32 shortcut;
 };
 
+struct nfp_fl_stats {
+	u64 pkts;
+	u64 bytes;
+	u64 used;
+};
+
 struct nfp_fl_payload {
 	struct nfp_fl_rule_metadata meta;
+	spinlock_t lock; /* lock stats */
+	struct nfp_fl_stats stats;
 	char *unmasked_data;
 	char *mask_data;
 	char *action_data;
 };
 
+struct nfp_fl_stats_frame {
+	__be32 stats_con_id;
+	__be32 pkt_count;
+	__be64 byte_count;
+	__be64 stats_cookie;
+};
+
 int nfp_flower_metadata_init(struct nfp_app *app);
 void nfp_flower_metadata_cleanup(struct nfp_app *app);
 
@@ -127,4 +154,6 @@ nfp_flower_find_in_fl_table(struct nfp_app *app,
 struct nfp_fl_payload *
 nfp_flower_remove_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie);
 
+void nfp_flower_rx_flow_stats(struct nfp_app *app, struct sk_buff *skb);
+
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/flower/metadata.c b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
index 51de9ab85951..f03e45ab15af 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/metadata.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
@@ -55,6 +55,55 @@ struct nfp_flower_table {
 	struct rcu_head rcu;
 };
 
+static int nfp_release_stats_entry(struct nfp_app *app, u32 stats_context_id)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	struct circ_buf *ring;
+
+	ring = &priv->stats_ids.free_list;
+	/* Check if buffer is full. */
+	if (!CIRC_SPACE(ring->head, ring->tail, NFP_FL_STATS_ENTRY_RS *
+			NFP_FL_STATS_ELEM_RS -
+			NFP_FL_STATS_ELEM_RS + 1))
+		return -ENOBUFS;
+
+	memcpy(&ring->buf[ring->head], &stats_context_id, NFP_FL_STATS_ELEM_RS);
+	ring->head = (ring->head + NFP_FL_STATS_ELEM_RS) %
+		     (NFP_FL_STATS_ENTRY_RS * NFP_FL_STATS_ELEM_RS);
+
+	return 0;
+}
+
+static int nfp_get_stats_entry(struct nfp_app *app, u32 *stats_context_id)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	u32 freed_stats_id, temp_stats_id;
+	struct circ_buf *ring;
+
+	ring = &priv->stats_ids.free_list;
+	freed_stats_id = NFP_FL_STATS_ENTRY_RS;
+	/* Check for unallocated entries first. */
+	if (priv->stats_ids.init_unalloc > 0) {
+		*stats_context_id = priv->stats_ids.init_unalloc - 1;
+		priv->stats_ids.init_unalloc--;
+		return 0;
+	}
+
+	/* Check if buffer is empty. */
+	if (ring->head == ring->tail) {
+		*stats_context_id = freed_stats_id;
+		return -ENOENT;
+	}
+
+	memcpy(&temp_stats_id, &ring->buf[ring->tail], NFP_FL_STATS_ELEM_RS);
+	*stats_context_id = temp_stats_id;
+	memcpy(&ring->buf[ring->tail], &freed_stats_id, NFP_FL_STATS_ELEM_RS);
+	ring->tail = (ring->tail + NFP_FL_STATS_ELEM_RS) %
+		     (NFP_FL_STATS_ENTRY_RS * NFP_FL_STATS_ELEM_RS);
+
+	return 0;
+}
+
 static struct nfp_flower_table *
 nfp_flower_search_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie)
 {
@@ -69,6 +118,46 @@ nfp_flower_search_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie)
 	return NULL;
 }
 
+static void
+nfp_flower_update_stats(struct nfp_app *app, struct nfp_fl_stats_frame *stats)
+{
+	struct nfp_fl_payload *nfp_flow;
+	unsigned long flower_cookie;
+
+	flower_cookie = be64_to_cpu(stats->stats_cookie);
+
+	rcu_read_lock();
+	nfp_flow = nfp_flower_find_in_fl_table(app, flower_cookie);
+	if (!nfp_flow)
+		goto exit_rcu_unlock;
+
+	if (nfp_flow->meta.host_ctx_id != stats->stats_con_id)
+		goto exit_rcu_unlock;
+
+	spin_lock(&nfp_flow->lock);
+	nfp_flow->stats.pkts += be32_to_cpu(stats->pkt_count);
+	nfp_flow->stats.bytes += be64_to_cpu(stats->byte_count);
+	nfp_flow->stats.used = jiffies;
+	spin_unlock(&nfp_flow->lock);
+
+exit_rcu_unlock:
+	rcu_read_unlock();
+}
+
+void nfp_flower_rx_flow_stats(struct nfp_app *app, struct sk_buff *skb)
+{
+	unsigned int msg_len = skb->len - NFP_FLOWER_CMSG_HLEN;
+	struct nfp_fl_stats_frame *stats_frame;
+	unsigned char *msg;
+	int i;
+
+	msg = nfp_flower_cmsg_get_data(skb);
+
+	stats_frame = (struct nfp_fl_stats_frame *)msg;
+	for (i = 0; i < msg_len / sizeof(*stats_frame); i++)
+		nfp_flower_update_stats(app, stats_frame + i);
+}
+
 static int
 nfp_flower_add_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie,
 			struct nfp_fl_payload *nfp_flow)
@@ -291,22 +380,39 @@ int nfp_compile_flow_metadata(struct nfp_app *app,
 {
 	struct nfp_flower_priv *priv = app->priv;
 	u8 new_mask_id;
+	u32 stats_cxt;
 	int err;
 
+	err = nfp_get_stats_entry(app, &stats_cxt);
+	if (err < 0)
+		return err;
+
+	nfp_flow->meta.host_ctx_id = cpu_to_be32(stats_cxt);
+	nfp_flow->meta.host_cookie = cpu_to_be64(flow->cookie);
+
 	new_mask_id = 0;
 	if (!nfp_check_mask_add(app, nfp_flow->mask_data,
 				nfp_flow->meta.mask_len,
-				&nfp_flow->meta.flags, &new_mask_id))
+				&nfp_flow->meta.flags, &new_mask_id)) {
+		if (nfp_release_stats_entry(app, stats_cxt))
+			return -EINVAL;
 		return -ENOENT;
+	}
 
 	nfp_flow->meta.flow_version = cpu_to_be64(priv->flower_version);
 	priv->flower_version++;
 
 	/* Update flow payload with mask ids. */
 	nfp_flow->unmasked_data[NFP_FL_MASK_ID_LOCATION] = new_mask_id;
+	nfp_flow->stats.pkts = 0;
+	nfp_flow->stats.bytes = 0;
+	nfp_flow->stats.used = jiffies;
 
 	err = nfp_flower_add_fl_table(app, flow->cookie, nfp_flow);
 	if (err < 0) {
+		if (nfp_release_stats_entry(app, stats_cxt))
+			return -EINVAL;
+
 		if (!nfp_check_mask_remove(app, nfp_flow->mask_data,
 					   nfp_flow->meta.mask_len,
 					   NULL, &new_mask_id))
@@ -323,6 +429,7 @@ int nfp_modify_flow_metadata(struct nfp_app *app,
 {
 	struct nfp_flower_priv *priv = app->priv;
 	u8 new_mask_id = 0;
+	u32 temp_ctx_id;
 
 	nfp_check_mask_remove(app, nfp_flow->mask_data,
 			      nfp_flow->meta.mask_len, &nfp_flow->meta.flags,
@@ -334,7 +441,10 @@ int nfp_modify_flow_metadata(struct nfp_app *app,
 	/* Update flow payload with mask ids. */
 	nfp_flow->unmasked_data[NFP_FL_MASK_ID_LOCATION] = new_mask_id;
 
-	return 0;
+	/* Release the stats ctx id. */
+	temp_ctx_id = be32_to_cpu(nfp_flow->meta.host_ctx_id);
+
+	return nfp_release_stats_entry(app, temp_ctx_id);
 }
 
 int nfp_flower_metadata_init(struct nfp_app *app)
@@ -362,6 +472,15 @@ int nfp_flower_metadata_init(struct nfp_app *app)
 		return -ENOMEM;
 	}
 
+	/* Init ring buffer and unallocated stats_ids. */
+	priv->stats_ids.free_list.buf =
+		vmalloc(NFP_FL_STATS_ENTRY_RS * NFP_FL_STATS_ELEM_RS);
+	if (!priv->stats_ids.free_list.buf) {
+		vfree(priv->mask_ids.mask_id_free_list.buf);
+		return -ENOMEM;
+	}
+	priv->stats_ids.init_unalloc = NFP_FL_REPEATED_HASH_MAX;
+
 	return 0;
 }
 
@@ -374,4 +493,5 @@ void nfp_flower_metadata_cleanup(struct nfp_app *app)
 
 	kfree(priv->mask_ids.mask_id_free_list.buf);
 	kfree(priv->mask_ids.last_used);
+	vfree(priv->stats_ids.free_list.buf);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index d0c0350efef1..79df9d74f89e 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -170,6 +170,7 @@ nfp_flower_allocate_new(struct nfp_fl_key_ls *key_layer)
 		goto err_free_mask;
 
 	flow_pay->meta.flags = 0;
+	spin_lock_init(&flow_pay->lock);
 
 	return flow_pay;
 
@@ -270,7 +271,10 @@ nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
 		return -ENOENT;
 
 	err = nfp_modify_flow_metadata(app, nfp_flow);
+	if (err)
+		goto err_free_flow;
 
+err_free_flow:
 	nfp_flower_deallocate_nfp(nfp_flow);
 	return err;
 }
@@ -288,7 +292,21 @@ nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
 static int
 nfp_flower_get_stats(struct nfp_app *app, struct tc_cls_flower_offload *flow)
 {
-	return -EOPNOTSUPP;
+	struct nfp_fl_payload *nfp_flow;
+
+	nfp_flow = nfp_flower_find_in_fl_table(app, flow->cookie);
+	if (!nfp_flow)
+		return -EINVAL;
+
+	spin_lock(&nfp_flow->lock);
+	tcf_exts_stats_update(flow->exts, nfp_flow->stats.bytes,
+			      nfp_flow->stats.pkts, nfp_flow->stats.used);
+
+	nfp_flow->stats.pkts = 0;
+	nfp_flow->stats.bytes = 0;
+	spin_unlock(&nfp_flow->lock);
+
+	return 0;
 }
 
 static int
-- 
2.1.4
