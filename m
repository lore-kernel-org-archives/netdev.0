From: Annie Li <Annie.li@oracle.com>
Subject: [PATCH net] Xen-netback: Fix issue caused by using gso_type wrongly
Date: Mon, 10 Mar 2014 15:44:14 +0800
Message-ID: <1394437454-2402-1-git-send-email-Annie.li@oracle.com>
Cc: konrad.wilk@oracle.com, Ian.Campbell@citrix.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com, annie.li@oracle.com
To: xen-devel@lists.xen.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36913 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbaCJHmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 03:42:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <annie.li@oracle.com>

Current netback uses gso_type to check whether the skb contains
gso offload, and this is wrong. Gso_size is the right one to
check gso existence, and gso_type is only used to check gso type.

Some skbs contains nonzero gso_type and zero gso_size, current
netback would treat these skbs as gso and create wrong response
for this. This also causes ssh failure to domu from other server.

Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/net/xen-netback/netback.c |   35 +++++++++++++++++------------------
 1 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index e5284bc..57a7d5d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -240,7 +240,7 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 	struct gnttab_copy *copy_gop;
 	struct xenvif_rx_meta *meta;
 	unsigned long bytes;
-	int gso_type;
+	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
 
 	/* Data must not cross a page boundary. */
 	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
@@ -299,12 +299,12 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		}
 
 		/* Leave a gap for the GSO descriptor. */
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
-		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
-		else
-			gso_type = XEN_NETIF_GSO_TYPE_NONE;
+		if (skb_shinfo(skb)->gso_size) {
+			if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+				gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
+			else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+				gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
+		}
 
 		if (*head && ((1 << gso_type) & vif->gso_mask))
 			vif->rx.req_cons++;
@@ -342,15 +342,13 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 
 	old_meta_prod = npo->meta_prod;
 
-	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
-		gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
-		gso_size = skb_shinfo(skb)->gso_size;
-	} else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
-		gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
-		gso_size = skb_shinfo(skb)->gso_size;
-	} else {
-		gso_type = XEN_NETIF_GSO_TYPE_NONE;
-		gso_size = 0;
+	gso_type = XEN_NETIF_GSO_TYPE_NONE;
+	gso_size = skb_shinfo(skb)->gso_size;
+	if (gso_size) {
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
 	}
 
 	/* Set up a GSO prefix descriptor, if necessary */
@@ -500,8 +498,9 @@ static void xenvif_rx_action(struct xenvif *vif)
 			size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
 			max_slots_needed += DIV_ROUND_UP(size, PAGE_SIZE);
 		}
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
-		    skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		if (skb_shinfo(skb)->gso_size &&
+		   (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
+		    skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6))
 			max_slots_needed++;
 
 		/* If the skb may not fit then bail out now */
-- 
1.7.3.4
