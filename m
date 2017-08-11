From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] nfp: send control message when MAC representors are created
Date: Fri, 11 Aug 2017 10:25:44 +0200
Message-ID: <1502439944-18910-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:34255 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbdHKIZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 04:25:56 -0400
Received: by mail-qt0-f170.google.com with SMTP id s6so17547856qtc.1
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 01:25:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware expects a MAC_REPR control message when a MAC representor
is created. The driver should expect a PORTMOD message to follow which
will provide the link states of the physical port associated with the MAC
representor.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c | 33 ++++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h | 21 +++++++++++++++
 drivers/net/ethernet/netronome/nfp/flower/main.c | 29 ++++++++++++++++++---
 3 files changed, 80 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index dd7fa9cf225f..a69d68ba3d0c 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -75,6 +75,39 @@ nfp_flower_cmsg_alloc(struct nfp_app *app, unsigned int size,
 	return skb;
 }
 
+struct sk_buff *
+nfp_flower_cmsg_mac_repr_start(struct nfp_app *app, unsigned int num_ports)
+{
+	struct nfp_flower_cmsg_mac_repr *msg;
+	struct sk_buff *skb;
+	unsigned int size;
+
+	size = sizeof(*msg) + num_ports * sizeof(msg->ports[0]);
+	skb = nfp_flower_cmsg_alloc(app, size, NFP_FLOWER_CMSG_TYPE_MAC_REPR);
+	if (!skb)
+		return NULL;
+
+	msg = nfp_flower_cmsg_get_data(skb);
+	memset(msg->reserved, 0, sizeof(msg->reserved));
+	msg->num_ports = num_ports;
+
+	return skb;
+}
+
+void
+nfp_flower_cmsg_mac_repr_add(struct sk_buff *skb, unsigned int idx,
+			     unsigned int nbi, unsigned int nbi_port,
+			     unsigned int phys_port)
+{
+	struct nfp_flower_cmsg_mac_repr *msg;
+
+	msg = nfp_flower_cmsg_get_data(skb);
+	msg->ports[idx].idx = idx;
+	msg->ports[idx].info = nbi & NFP_FLOWER_CMSG_MAC_REPR_NBI;
+	msg->ports[idx].nbi_port = nbi_port;
+	msg->ports[idx].phys_port = phys_port;
+}
+
 int nfp_flower_cmsg_portmod(struct nfp_repr *repr, bool carrier_ok)
 {
 	struct nfp_flower_cmsg_portmod *msg;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index cf738de170ab..aa92a8711a02 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -247,12 +247,27 @@ struct nfp_flower_cmsg_hdr {
 enum nfp_flower_cmsg_type_port {
 	NFP_FLOWER_CMSG_TYPE_FLOW_ADD =		0,
 	NFP_FLOWER_CMSG_TYPE_FLOW_DEL =		2,
+	NFP_FLOWER_CMSG_TYPE_MAC_REPR =		7,
 	NFP_FLOWER_CMSG_TYPE_PORT_MOD =		8,
 	NFP_FLOWER_CMSG_TYPE_FLOW_STATS =	15,
 	NFP_FLOWER_CMSG_TYPE_PORT_ECHO =	16,
 	NFP_FLOWER_CMSG_TYPE_MAX =		32,
 };
 
+/* NFP_FLOWER_CMSG_TYPE_MAC_REPR */
+struct nfp_flower_cmsg_mac_repr {
+	u8 reserved[3];
+	u8 num_ports;
+	struct {
+		u8 idx;
+		u8 info;
+		u8 nbi_port;
+		u8 phys_port;
+	} ports[0];
+};
+
+#define NFP_FLOWER_CMSG_MAC_REPR_NBI		GENMASK(1, 0)
+
 /* NFP_FLOWER_CMSG_TYPE_PORT_MOD */
 struct nfp_flower_cmsg_portmod {
 	__be32 portnum;
@@ -308,6 +323,12 @@ static inline void *nfp_flower_cmsg_get_data(struct sk_buff *skb)
 	return (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;
 }
 
+struct sk_buff *
+nfp_flower_cmsg_mac_repr_start(struct nfp_app *app, unsigned int num_ports);
+void
+nfp_flower_cmsg_mac_repr_add(struct sk_buff *skb, unsigned int idx,
+			     unsigned int nbi, unsigned int nbi_port,
+			     unsigned int phys_port);
 int nfp_flower_cmsg_portmod(struct nfp_repr *repr, bool carrier_ok);
 void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb);
 struct sk_buff *
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 6a65c8b33807..b905454b30ca 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -214,15 +214,22 @@ nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 {
 	struct nfp_eth_table *eth_tbl = app->pf->eth_tbl;
 	struct nfp_reprs *reprs, *old_reprs;
+	struct sk_buff *ctrl_skb;
 	unsigned int i;
 	int err;
 
-	reprs = nfp_reprs_alloc(eth_tbl->max_index + 1);
-	if (!reprs)
+	ctrl_skb = nfp_flower_cmsg_mac_repr_start(app, eth_tbl->count);
+	if (!ctrl_skb)
 		return -ENOMEM;
 
+	reprs = nfp_reprs_alloc(eth_tbl->max_index + 1);
+	if (!reprs) {
+		err = -ENOMEM;
+		goto err_free_ctrl_skb;
+	}
+
 	for (i = 0; i < eth_tbl->count; i++) {
-		int phys_port = eth_tbl->ports[i].index;
+		unsigned int phys_port = eth_tbl->ports[i].index;
 		struct nfp_port *port;
 		u32 cmsg_port_id;
 
@@ -255,6 +262,11 @@ nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 			goto err_reprs_clean;
 		}
 
+		nfp_flower_cmsg_mac_repr_add(ctrl_skb, i,
+					     eth_tbl->ports[i].nbi,
+					     eth_tbl->ports[i].base,
+					     phys_port);
+
 		nfp_info(app->cpp, "Phys Port %d Representor(%s) created\n",
 			 phys_port, reprs->reprs[phys_port]->name);
 	}
@@ -265,9 +277,20 @@ nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 		goto err_reprs_clean;
 	}
 
+	/* The MAC_REPR control message should be sent after the MAC
+	 * representors are registered using nfp_app_reprs_set().  This is
+	 * because the firmware may respond with control messages for the
+	 * MAC representors, f.e. to provide the driver with information
+	 * about their state, and without registration the driver will drop
+	 * any such messages.
+	 */
+	nfp_ctrl_tx(app->ctrl, ctrl_skb);
+
 	return 0;
 err_reprs_clean:
 	nfp_reprs_clean_and_free(reprs);
+err_free_ctrl_skb:
+	kfree_skb(ctrl_skb);
 	return err;
 }
 
-- 
2.1.4
