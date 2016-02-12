From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v1 8/8] xen-netback: use toeplitz hash value from the frontend
Date: Fri, 12 Feb 2016 10:13:25 +0000
Message-ID: <1455272005-17144-9-git-send-email-paul.durrant@citrix.com>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23531 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbcBLKVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 05:21:42 -0500
In-Reply-To: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to xen-netback to use the value in a toeplitz hash
extra info fragment passed from the VM frontend in a transmit-side packet
to set the skb hash accordingly.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 57c91fe..f550b8a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1341,6 +1341,28 @@ void xenvif_mcast_addr_list_free(struct xenvif *vif)
 	}
 }
 
+static void xenvif_set_skb_hash(struct xenvif *vif,
+				struct sk_buff *skb,
+				struct xen_netif_extra_info *extra)
+{
+	u32 hash = *(u32 *)extra->u.toeplitz.value;
+	enum pkt_hash_types type = PKT_HASH_TYPE_NONE;
+
+	switch (extra->u.toeplitz.type) {
+	case _XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4:
+	case _XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6:
+		type = PKT_HASH_TYPE_L3;
+		break;
+
+	case _XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4_TCP:
+	case _XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6_TCP:
+		type = PKT_HASH_TYPE_L4;
+		break;
+	}
+
+	skb_set_hash(skb, hash, type);
+}
+
 static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 				     int budget,
 				     unsigned *copy_ops,
@@ -1502,6 +1524,13 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			}
 		}
 
+		if (extras[XEN_NETIF_EXTRA_TYPE_TOEPLITZ - 1].type) {
+			struct xen_netif_extra_info *extra;
+
+			extra = &extras[XEN_NETIF_EXTRA_TYPE_TOEPLITZ - 1];
+			xenvif_set_skb_hash(queue->vif, skb, extra);
+		}
+
 		XENVIF_TX_CB(skb)->pending_idx = pending_idx;
 
 		__skb_put(skb, data_len);
-- 
2.1.4
