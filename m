From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 8/9] nfp: add a stats handler for flower offloads
Date: Wed, 28 Jun 2017 01:21:48 +0200
Message-ID: <1498605709-22574-9-git-send-email-simon.horman@netronome.com>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36595 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754044AbdF0XW3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:22:29 -0400
Received: by mail-qk0-f180.google.com with SMTP id p21so38318192qke.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:22:28 -0700 (PDT)
In-Reply-To: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
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
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  26 ++++
 .../net/ethernet/netronome/nfp/flower/metadata.c   | 143 ++++++++++++++++++++-
 .../net/ethernet/netronome/nfp/flower/offload.c    |  14 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   1 +
 4 files changed, 181 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index cc184618306c..8490ef1129ea 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -38,6 +38,7 @@
 #include <linux/types.h>
 
 #include "cmsg.h"
+#include "../nfp_net.h"
 
 #define NFP_FLOWER_ALLOWED_VER 0x0001000000010000UL
 
@@ -46,9 +47,13 @@ struct tc_to_netdev;
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
@@ -66,10 +71,17 @@ struct nfp_fl_mask_id {
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
@@ -77,6 +89,7 @@ struct nfp_fl_mask_id {
 struct nfp_flower_priv {
 	struct nfp_net *nn;
 	u64 flower_version;
+	struct nfp_fl_stats_id stats_ids;
 	struct nfp_fl_mask_id mask_ids;
 	DECLARE_HASHTABLE(mask_table, NFP_FLOWER_MASK_HASH_BITS);
 	DECLARE_HASHTABLE(flow_table, NFP_FLOWER_HASH_BITS);
@@ -101,11 +114,20 @@ struct nfp_fl_rule_metadata {
 
 struct nfp_fl_payload {
 	struct nfp_fl_rule_metadata meta;
+	spinlock_t lock_nfp_flow_stats; /* serialize flow stats access. */
+	struct nfp_stat_pair stats;
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
 
@@ -132,4 +154,8 @@ nfp_flower_find_in_fl_table(struct nfp_app *app,
 int nfp_flower_remove_fl_table(struct nfp_app *app,
 			       unsigned long tc_flower_cookie);
 
+void nfp_flower_rx_flow_stats(struct nfp_app *app, struct sk_buff *skb);
+void nfp_flower_populate_stats(struct nfp_fl_payload *nfp_flow);
+void nfp_flower_stats_clear(struct nfp_fl_payload *nfp_flow);
+
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/flower/metadata.c b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
index acbf4c757988..75a98da049f7 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/metadata.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
@@ -39,6 +39,7 @@
 #include <net/pkt_cls.h>
 
 #include "main.h"
+#include "cmsg.h"
 
 struct nfp_mask_id_table {
 	struct hlist_node link;
@@ -53,6 +54,115 @@ struct nfp_flower_table {
 	struct hlist_node link;
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
+void nfp_flower_populate_stats(struct nfp_fl_payload *nfp_flow)
+{
+	spin_lock(&nfp_flow->lock_nfp_flow_stats);
+	nfp_flow->stats.pkts = 0;
+	nfp_flow->stats.bytes = 0;
+	nfp_flow->stats.used = jiffies;
+	spin_unlock(&nfp_flow->lock_nfp_flow_stats);
+}
+
+void nfp_flower_stats_clear(struct nfp_fl_payload *nfp_flow)
+{
+	spin_lock(&nfp_flow->lock_nfp_flow_stats);
+	nfp_flow->stats.pkts = 0;
+	nfp_flow->stats.bytes = 0;
+	spin_unlock(&nfp_flow->lock_nfp_flow_stats);
+}
+
+static void
+nfp_flower_update_stats(struct nfp_app *app, struct nfp_fl_stats_frame *stats)
+{
+	struct nfp_fl_payload *nfp_flow;
+	unsigned long flower_cookie;
+
+	flower_cookie = be64_to_cpu(stats->stats_cookie);
+
+	nfp_flow = nfp_flower_find_in_fl_table(app, flower_cookie);
+	if (!nfp_flow)
+		return;
+
+	if (nfp_flow->meta.host_ctx_id != stats->stats_con_id)
+		return;
+
+	spin_lock(&nfp_flow->lock_nfp_flow_stats);
+	nfp_flow->stats.pkts += be32_to_cpu(stats->pkt_count);
+	nfp_flow->stats.bytes += be64_to_cpu(stats->byte_count);
+	nfp_flow->stats.used = jiffies;
+	spin_unlock(&nfp_flow->lock_nfp_flow_stats);
+}
+
+void nfp_flower_rx_flow_stats(struct nfp_app *app, struct sk_buff *skb)
+{
+	unsigned int msg_len = skb->len - NFP_FLOWER_CMSG_HLEN;
+	struct nfp_fl_stats_frame *stats_frame;
+	unsigned char *msg;
+	int msg_offset = 0;
+
+	msg = (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;
+
+	while (msg_len >= sizeof(struct nfp_fl_stats_frame)) {
+		stats_frame = (struct nfp_fl_stats_frame *)msg + msg_offset;
+		if (!stats_frame)
+			break;
+
+		nfp_flower_update_stats(app, stats_frame);
+
+		msg_offset += sizeof(struct nfp_fl_stats_frame);
+		msg_len -= sizeof(struct nfp_fl_stats_frame);
+	}
+}
+
 static struct nfp_flower_table *
 nfp_flower_search_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie)
 {
@@ -289,13 +399,24 @@ int nfp_compile_flow_metadata(struct nfp_app *app,
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
 	err = nfp_check_mask_add(app, nfp_flow->mask_data,
 				 nfp_flow->meta.mask_len, &new_mask_id);
-	if (err < 0)
+	if (err < 0) {
+		if (nfp_release_stats_entry(app, stats_cxt))
+			return -EINVAL;
 		return err;
+	}
 
 	nfp_flow->meta.flags |= err;
 
@@ -307,6 +428,9 @@ int nfp_compile_flow_metadata(struct nfp_app *app,
 
 	err = nfp_flower_add_fl_table(app, flow->cookie, nfp_flow);
 	if (err < 0) {
+		if (nfp_release_stats_entry(app, stats_cxt))
+			return -EINVAL;
+
 		if (nfp_check_mask_remove(app, nfp_flow->mask_data,
 					  nfp_flow->meta.mask_len,
 					  &new_mask_id))
@@ -315,6 +439,8 @@ int nfp_compile_flow_metadata(struct nfp_app *app,
 		return err;
 	}
 
+	nfp_flower_populate_stats(nfp_flow);
+
 	return 0;
 }
 
@@ -323,6 +449,7 @@ int nfp_modify_flow_metadata(struct nfp_app *app,
 {
 	struct nfp_flower_priv *priv = app->priv;
 	u8 new_mask_id = 0;
+	u32 temp_ctx_id;
 
 	nfp_flow->meta.flags |= nfp_check_mask_remove(app, nfp_flow->mask_data,
 						      nfp_flow->meta.mask_len,
@@ -334,7 +461,10 @@ int nfp_modify_flow_metadata(struct nfp_app *app,
 	/* Update flow payload with mask ids. */
 	nfp_flow->unmasked_data[NFP_FL_MASK_ID_LOCATION] = new_mask_id;
 
-	return 0;
+	/* Release the stats ctx id. */
+	temp_ctx_id = be32_to_cpu(nfp_flow->meta.host_ctx_id);
+
+	return nfp_release_stats_entry(app, temp_ctx_id);
 }
 
 int nfp_flower_metadata_init(struct nfp_app *app)
@@ -362,6 +492,14 @@ int nfp_flower_metadata_init(struct nfp_app *app)
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
 	priv->flower_version = 0;
 
 	return 0;
@@ -376,4 +514,5 @@ void nfp_flower_metadata_cleanup(struct nfp_app *app)
 
 	kfree(priv->mask_ids.mask_id_free_list.buf);
 	kfree(priv->mask_ids.last_used);
+	vfree(priv->stats_ids.free_list.buf);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index a7f688bbc761..b39c96623657 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -171,6 +171,7 @@ nfp_flower_allocate_new(struct nfp_fl_key_ls *key_layer)
 		goto err_free_mask;
 
 	flow_pay->meta.flags = 0;
+	spin_lock_init(&flow_pay->lock_nfp_flow_stats);
 
 	return flow_pay;
 
@@ -294,7 +295,18 @@ nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
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
+	tcf_exts_stats_update(flow->exts, nfp_flow->stats.bytes,
+			      nfp_flow->stats.pkts, nfp_flow->stats.used);
+
+	nfp_flower_stats_clear(nfp_flow);
+
+	return 0;
 }
 
 static int
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index b1fa77bd708b..cfd74ce36797 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -466,6 +466,7 @@ static inline bool nfp_net_fw_ver_eq(struct nfp_net_fw_version *fw_ver,
 struct nfp_stat_pair {
 	u64 pkts;
 	u64 bytes;
+	u64 used;
 };
 
 /**
-- 
2.1.4
