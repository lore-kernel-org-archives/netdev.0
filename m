From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 4/8] xen-netback: accept an L4 or L3 skb hash value from the frontend
Date: Wed, 21 Oct 2015 11:36:21 +0100
Message-ID: <1445423785-4654-5-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:45975 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbbJUKhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 06:37:00 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an indication that netback is capable of handling hash
values passed from the frontend (see netif.h for details), and the code
necessary to process the additional xen_netif_extra_info segment and
set a hash on the skb.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c | 25 +++++++++++++++++++++++++
 drivers/net/xen-netback/xenbus.c  |  8 ++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 9f0c9f5..3799b5a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1383,6 +1383,28 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			}
 		}
 
+		if (extras[XEN_NETIF_EXTRA_TYPE_HASH - 1].type) {
+			struct xen_netif_extra_info *extra;
+			u32 hash = *(u32 *)extra->u.hash.value;
+
+			extra = &extras[XEN_NETIF_EXTRA_TYPE_HASH - 1];
+
+			switch (extra->u.hash.type) {
+			case XEN_NETIF_HASH_TYPE_TCPV4:
+			case XEN_NETIF_HASH_TYPE_TCPV6:
+				skb_set_hash(skb, hash, PKT_HASH_TYPE_L4);
+				break;
+
+			case XEN_NETIF_HASH_TYPE_IPV4:
+			case XEN_NETIF_HASH_TYPE_IPV6:
+				skb_set_hash(skb, hash, PKT_HASH_TYPE_L3);
+				break;
+
+			default:
+				break;
+			}
+		}
+
 		XENVIF_TX_CB(skb)->pending_idx = pending_idx;
 
 		__skb_put(skb, data_len);
@@ -1416,6 +1438,9 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type)
 			queue->pending_tx_info[pending_idx].extra_count++;
 
+		if (extras[XEN_NETIF_EXTRA_TYPE_HASH - 1].type)
+			queue->pending_tx_info[pending_idx].extra_count++;
+
 		queue->pending_cons++;
 
 		gop = xenvif_get_requests(queue, skb, txfrags, gop,
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 929a6e7..2fa8a16 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -335,6 +335,14 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		/* We support hash values. */
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-hash", "%d", 1);
+		if (err) {
+			message = "writing feature-hash";
+			goto abort_transaction;
+		}
+
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
 
-- 
2.1.4
