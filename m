From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 4/4] xen-netback: use hash value from the frontend
Date: Wed, 11 May 2016 16:16:30 +0100
Message-ID: <1462979790-2824-5-git-send-email-paul.durrant@citrix.com>
References: <1462979790-2824-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:62460 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbcEKPae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 11:30:34 -0400
In-Reply-To: <1462979790-2824-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My recent patch to include/xen/interface/io/netif.h defines a new extra
info type that can be used to pass hash values between backend and guest
frontend.

This patch adds code to xen-netback to use the value in a hash extra
info fragment passed from the guest frontend in a transmit-side
(i.e. netback receive side) packet to set the skb hash accordingly.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7c72510..a5b5aad 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1509,6 +1509,33 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			}
 		}
 
+		if (extras[XEN_NETIF_EXTRA_TYPE_HASH - 1].type) {
+			struct xen_netif_extra_info *extra;
+			enum pkt_hash_types type = PKT_HASH_TYPE_NONE;
+
+			extra = &extras[XEN_NETIF_EXTRA_TYPE_HASH - 1];
+
+			switch (extra->u.hash.type) {
+			case _XEN_NETIF_CTRL_HASH_TYPE_IPV4:
+			case _XEN_NETIF_CTRL_HASH_TYPE_IPV6:
+				type = PKT_HASH_TYPE_L3;
+				break;
+
+			case _XEN_NETIF_CTRL_HASH_TYPE_IPV4_TCP:
+			case _XEN_NETIF_CTRL_HASH_TYPE_IPV6_TCP:
+				type = PKT_HASH_TYPE_L4;
+				break;
+
+			default:
+				break;
+			}
+
+			if (type != PKT_HASH_TYPE_NONE)
+				skb_set_hash(skb,
+					     *(u32 *)extra->u.hash.value,
+					     type);
+		}
+
 		XENVIF_TX_CB(skb)->pending_idx = pending_idx;
 
 		__skb_put(skb, data_len);
-- 
2.1.4
