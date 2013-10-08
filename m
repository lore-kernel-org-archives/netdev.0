From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 4/5] xen-netback: handle IPv6 TCP GSO packets from the guest
Date: Tue, 8 Oct 2013 11:44:40 +0100
Message-ID: <1381229081-17814-5-git-send-email-paul.durrant@citrix.com>
References: <1381229081-17814-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liuw2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:2023 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756953Ab3JHKov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 06:44:51 -0400
In-Reply-To: <1381229081-17814-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch a xenstore flag, festure-gso-tcpv6, to adevrtise netback can
handle IPv6 TCP GSO packets and creates SKB_GSO_TCPV6 skbs if the frontend
passes an extra segment with the new type XEN_NETIF_GSO_TYPE_TCPV6 added to
netif.h.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liuw2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/netback.c |   11 ++++++++---
 drivers/net/xen-netback/xenbus.c  |    7 +++++++
 include/xen/interface/io/netif.h  |    3 ++-
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 35b1fa6..ac42f73 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1096,15 +1096,20 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
 		return -EINVAL;
 	}
 
-	/* Currently only TCPv4 S.O. is supported. */
-	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
+	switch (gso->u.gso.type) {
+	case XEN_NETIF_GSO_TYPE_TCPV4:
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+		break;
+	case XEN_NETIF_GSO_TYPE_TCPV6:
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+		break;
+	default:
 		netdev_err(vif->dev, "Bad GSO type %d.\n", gso->u.gso.type);
 		xenvif_fatal_tx_err(vif);
 		return -EINVAL;
 	}
 
 	skb_shinfo(skb)->gso_size = gso->u.gso.size;
-	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 
 	/* Header must be checked, and gso_segs computed. */
 	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index dff423b..389fa72 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -101,6 +101,13 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		err = xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv6",
+				    "%d", sg);
+		if (err) {
+			message = "writing feature-gso-tcpv6";
+			goto abort_transaction;
+		}
+
 		/* We support partial checksum setup for IPv6 packets */
 		err = xenbus_printf(xbt, dev->nodename,
 				    "feature-ipv6-csum-offload",
diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index eb262e3..c19cc06 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -95,8 +95,9 @@ struct xen_netif_tx_request {
 #define _XEN_NETIF_EXTRA_FLAG_MORE	(0)
 #define  XEN_NETIF_EXTRA_FLAG_MORE	(1U<<_XEN_NETIF_EXTRA_FLAG_MORE)
 
-/* GSO types - only TCPv4 currently supported. */
+/* GSO types */
 #define XEN_NETIF_GSO_TYPE_TCPV4	(1)
+#define XEN_NETIF_GSO_TYPE_TCPV6	(2)
 
 /*
  * This structure needs to fit within both netif_tx_request and
-- 
1.7.10.4
