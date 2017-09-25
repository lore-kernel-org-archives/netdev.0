From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 7/7] nfp: flower vxlan neighbour keep-alive
Date: Mon, 25 Sep 2017 12:23:41 +0200
Message-ID: <1506335021-32024-8-git-send-email-simon.horman@netronome.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        John Hurley <john.hurley@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:46066 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934439AbdIYKYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 06:24:09 -0400
Received: by mail-wm0-f50.google.com with SMTP id q124so17903644wmb.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 03:24:09 -0700 (PDT)
In-Reply-To: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Hurley <john.hurley@netronome.com>

Periodically receive messages containing the destination IPs of tunnels
that have recently forwarded traffic. Update the neighbour entries 'used'
value for these IPs next hop.

This prevents the neighbour entry from expiring on timeout but rather
signals an ARP to verify the connection. From an NFP perspective, packets
will not fall back mid-flow unless the link is verified to be down.

Signed-off-by: John Hurley <john.hurley@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |  3 +
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |  1 +
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  1 +
 .../ethernet/netronome/nfp/flower/tunnel_conf.c    | 64 ++++++++++++++++++++++
 4 files changed, 69 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index 862787daaa68..6b71c719deba 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -184,6 +184,9 @@ nfp_flower_cmsg_process_one_rx(struct nfp_app *app, struct sk_buff *skb)
 	case NFP_FLOWER_CMSG_TYPE_NO_NEIGH:
 		nfp_tunnel_request_route(app, skb);
 		break;
+	case NFP_FLOWER_CMSG_TYPE_ACTIVE_TUNS:
+		nfp_tunnel_keep_alive(app, skb);
+		break;
 	case NFP_FLOWER_CMSG_TYPE_TUN_NEIGH:
 		/* Acks from the NFP that the route is added - ignore. */
 		break;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index 1dc72a1ed577..504ddaa21701 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -319,6 +319,7 @@ enum nfp_flower_cmsg_type_port {
 	NFP_FLOWER_CMSG_TYPE_PORT_MOD =		8,
 	NFP_FLOWER_CMSG_TYPE_NO_NEIGH =		10,
 	NFP_FLOWER_CMSG_TYPE_TUN_MAC =		11,
+	NFP_FLOWER_CMSG_TYPE_ACTIVE_TUNS =	12,
 	NFP_FLOWER_CMSG_TYPE_TUN_NEIGH =	13,
 	NFP_FLOWER_CMSG_TYPE_TUN_IPS =		14,
 	NFP_FLOWER_CMSG_TYPE_FLOW_STATS =	15,
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index 93ad969c3653..12c319a219d8 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -196,5 +196,6 @@ void nfp_tunnel_write_macs(struct nfp_app *app);
 void nfp_tunnel_del_ipv4_off(struct nfp_app *app, __be32 ipv4);
 void nfp_tunnel_add_ipv4_off(struct nfp_app *app, __be32 ipv4);
 void nfp_tunnel_request_route(struct nfp_app *app, struct sk_buff *skb);
+void nfp_tunnel_keep_alive(struct nfp_app *app, struct sk_buff *skb);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/flower/tunnel_conf.c b/drivers/net/ethernet/netronome/nfp/flower/tunnel_conf.c
index 8c6b88a1306b..c495f8f38506 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/tunnel_conf.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/tunnel_conf.c
@@ -36,12 +36,36 @@
 #include <net/netevent.h>
 #include <linux/idr.h>
 #include <net/dst_metadata.h>
+#include <net/arp.h>
 
 #include "cmsg.h"
 #include "main.h"
 #include "../nfp_net_repr.h"
 #include "../nfp_net.h"
 
+#define NFP_FL_MAX_ROUTES               32
+
+/**
+ * struct nfp_tun_active_tuns - periodic message of active tunnels
+ * @seq:		sequence number of the message
+ * @count:		number of tunnels report in message
+ * @flags:		options part of the request
+ * @ipv4:		dest IPv4 address of active route
+ * @egress_port:	port the encapsulated packet egressed
+ * @extra:		reserved for future use
+ * @tun_info:		tunnels that have sent traffic in reported period
+ */
+struct nfp_tun_active_tuns {
+	__be32 seq;
+	__be32 count;
+	__be32 flags;
+	struct route_ip_info {
+		__be32 ipv4;
+		__be32 egress_port;
+		__be32 extra[2];
+	} tun_info[];
+};
+
 /**
  * struct nfp_tun_neigh - neighbour/route entry on the NFP
  * @dst_ipv4:	destination IPv4 address
@@ -147,6 +171,46 @@ struct nfp_tun_mac_non_nfp_idx {
 	struct list_head list;
 };
 
+void nfp_tunnel_keep_alive(struct nfp_app *app, struct sk_buff *skb)
+{
+	struct nfp_tun_active_tuns *payload;
+	struct net_device *netdev;
+	int count, i, pay_len;
+	struct neighbour *n;
+	__be32 ipv4_addr;
+	u32 port;
+
+	payload = nfp_flower_cmsg_get_data(skb);
+	count = be32_to_cpu(payload->count);
+	if (count > NFP_FL_MAX_ROUTES) {
+		nfp_flower_cmsg_warn(app, "Tunnel keep-alive request exceeds max routes.\n");
+		return;
+	}
+
+	pay_len = nfp_flower_cmsg_get_data_len(skb);
+	if (pay_len != sizeof(struct nfp_tun_active_tuns) +
+	    sizeof(struct route_ip_info) * count) {
+		nfp_flower_cmsg_warn(app, "Corruption in tunnel keep-alive message.\n");
+		return;
+	}
+
+	for (i = 0; i < count; i++) {
+		ipv4_addr = payload->tun_info[i].ipv4;
+		port = be32_to_cpu(payload->tun_info[i].egress_port);
+		netdev = nfp_app_repr_get(app, port);
+		if (!netdev)
+			continue;
+
+		n = neigh_lookup(&arp_tbl, &ipv4_addr, netdev);
+		if (!n)
+			continue;
+
+		/* Update the used timestamp of neighbour */
+		neigh_event_send(n, NULL);
+		neigh_release(n);
+	}
+}
+
 static bool nfp_tun_is_netdev_to_offload(struct net_device *netdev)
 {
 	if (!netdev->rtnl_link_ops)
-- 
2.1.4
