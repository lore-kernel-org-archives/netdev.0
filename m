From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 9/9] nfp: add control message passing capabilities to flower offloads
Date: Wed, 28 Jun 2017 01:21:49 +0200
Message-ID: <1498605709-22574-10-git-send-email-simon.horman@netronome.com>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33586 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754051AbdF0XWk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:22:40 -0400
Received: by mail-qk0-f170.google.com with SMTP id r62so38344223qkf.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:22:40 -0700 (PDT)
In-Reply-To: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously the flower offloads never sends messages to the hardware,
and never registers a handler for receiving messages from hardware.
This patch enables the flower offloads to send control messages to
hardware when adding and removing flow rules. Additionally it
registers a control message rx handler for receiving stats updates
from hardware for each offloaded flow.

Additionally this patch adds 4 control message types; Add, modify and
delete flow, as well as flow stats. It also allows
nfp_flower_cmsg_get_data() to be used outside of cmsg.c.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   | 11 ++---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   | 12 +++++
 .../net/ethernet/netronome/nfp/flower/offload.c    | 57 ++++++++++++++++++++++
 3 files changed, 74 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index 916a6196d2ba..dd7fa9cf225f 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -36,6 +36,7 @@
 #include <linux/skbuff.h>
 #include <net/dst_metadata.h>
 
+#include "main.h"
 #include "../nfpcore/nfp_cpp.h"
 #include "../nfp_net_repr.h"
 #include "./cmsg.h"
@@ -52,12 +53,7 @@ nfp_flower_cmsg_get_hdr(struct sk_buff *skb)
 	return (struct nfp_flower_cmsg_hdr *)skb->data;
 }
 
-static void *nfp_flower_cmsg_get_data(struct sk_buff *skb)
-{
-	return (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;
-}
-
-static struct sk_buff *
+struct sk_buff *
 nfp_flower_cmsg_alloc(struct nfp_app *app, unsigned int size,
 		      enum nfp_flower_cmsg_type_port type)
 {
@@ -148,6 +144,9 @@ void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb)
 	case NFP_FLOWER_CMSG_TYPE_PORT_MOD:
 		nfp_flower_cmsg_portmod_rx(app, skb);
 		break;
+	case NFP_FLOWER_CMSG_TYPE_FLOW_STATS:
+		nfp_flower_rx_flow_stats(app, skb);
+		break;
 	default:
 		nfp_flower_cmsg_warn(app, "Cannot handle invalid repr control type %u\n",
 				     type);
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index 4c72e537af32..5a997feb6f80 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -245,7 +245,11 @@ struct nfp_flower_cmsg_hdr {
 
 /* Types defined for port related control messages  */
 enum nfp_flower_cmsg_type_port {
+	NFP_FLOWER_CMSG_TYPE_FLOW_ADD =		0,
+	NFP_FLOWER_CMSG_TYPE_FLOW_MOD =		1,
+	NFP_FLOWER_CMSG_TYPE_FLOW_DEL =		2,
 	NFP_FLOWER_CMSG_TYPE_PORT_MOD =		8,
+	NFP_FLOWER_CMSG_TYPE_FLOW_STATS =	15,
 	NFP_FLOWER_CMSG_TYPE_PORT_ECHO =	16,
 	NFP_FLOWER_CMSG_TYPE_MAX =		32,
 };
@@ -300,7 +304,15 @@ nfp_flower_cmsg_pcie_port(u8 nfp_pcie, enum nfp_flower_cmsg_port_vnic_type type,
 			   NFP_FLOWER_CMSG_PORT_TYPE_PCIE_PORT);
 }
 
+static inline void *nfp_flower_cmsg_get_data(struct sk_buff *skb)
+{
+	return (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;
+}
+
 int nfp_flower_cmsg_portmod(struct nfp_repr *repr, bool carrier_ok);
 void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb);
+struct sk_buff *
+nfp_flower_cmsg_alloc(struct nfp_app *app, unsigned int size,
+		      enum nfp_flower_cmsg_type_port type);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index b39c96623657..4dcd50675926 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -45,6 +45,52 @@
 #include "../nfp_net.h"
 #include "../nfp_port.h"
 
+static int
+nfp_flower_xmit_flow(struct net_device *netdev,
+		     struct nfp_fl_payload *nfp_flow, u8 mtype)
+{
+	u32 meta_len, key_len, mask_len, act_len, tot_len;
+	struct nfp_repr *priv = netdev_priv(netdev);
+	struct sk_buff *skb;
+	unsigned char *msg;
+
+	meta_len =  sizeof(struct nfp_fl_rule_metadata);
+	key_len = nfp_flow->meta.key_len;
+	mask_len = nfp_flow->meta.mask_len;
+	act_len = nfp_flow->meta.act_len;
+
+	tot_len = meta_len + key_len + mask_len + act_len;
+
+	/* Convert to long words as firmware expects
+	 * lengths in units of NFP_FL_LW_SIZ.
+	 */
+	nfp_flow->meta.key_len /= NFP_FL_LW_SIZ;
+	nfp_flow->meta.mask_len /= NFP_FL_LW_SIZ;
+	nfp_flow->meta.act_len /= NFP_FL_LW_SIZ;
+
+	skb = nfp_flower_cmsg_alloc(priv->app, tot_len, mtype);
+	if (!skb)
+		return -ENOMEM;
+
+	msg = nfp_flower_cmsg_get_data(skb);
+	memcpy(msg, &nfp_flow->meta, meta_len);
+	memcpy(&msg[meta_len], nfp_flow->unmasked_data, key_len);
+	memcpy(&msg[meta_len + key_len], nfp_flow->mask_data, mask_len);
+	memcpy(&msg[meta_len + key_len + mask_len],
+	       nfp_flow->action_data, act_len);
+
+	/* Convert back to bytes as software expects
+	 * lengths in units of bytes.
+	 */
+	nfp_flow->meta.key_len *= NFP_FL_LW_SIZ;
+	nfp_flow->meta.mask_len *= NFP_FL_LW_SIZ;
+	nfp_flow->meta.act_len *= NFP_FL_LW_SIZ;
+
+	nfp_ctrl_tx(priv->app->ctrl, skb);
+
+	return 0;
+}
+
 static bool nfp_flower_check_lower_than_mac(struct tc_cls_flower_offload *f)
 {
 	return dissector_uses_key(f->dissector,
@@ -236,6 +282,11 @@ nfp_flower_add_offload(struct nfp_app *app, struct net_device *netdev,
 	if (err)
 		goto err_destroy_flow;
 
+	err = nfp_flower_xmit_flow(netdev, flow_pay,
+				   NFP_FLOWER_CMSG_TYPE_FLOW_ADD);
+	if (err)
+		goto err_destroy_flow;
+
 	/* Deallocate flow payload when flower rule has been destroyed. */
 	kfree(key_layer);
 
@@ -275,6 +326,12 @@ nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
 	if (err)
 		goto err_free_flow;
 
+	nfp_modify_flow_metadata(app, nfp_flow);
+	err = nfp_flower_xmit_flow(netdev, nfp_flow,
+				   NFP_FLOWER_CMSG_TYPE_FLOW_DEL);
+	if (err)
+		goto err_free_flow;
+
 	err = nfp_flower_remove_fl_table(app, flow->cookie);
 
 err_free_flow:
-- 
2.1.4
