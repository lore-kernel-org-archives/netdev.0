From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [10/12] pasemi_mac: Remove SKB copy/recycle logic
Date: Wed, 28 Nov 2007 20:57:56 -0600
Message-ID: <20071129025756.GK17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36924 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758980AbXK2Cyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:54:45 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: Remove SKB copy/recycle logic

It doesn't really buy us much, since copying is about as expensive
as the allocation in the first place. Just remove it for now.


Signed-off-by: Olof Johansson <olof@lixom.net>


---
 drivers/net/pasemi_mac.c |   25 +++----------------------
 1 file changed, 3 insertions(+), 22 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -503,13 +503,8 @@ static void pasemi_mac_replenish_rx_ring
 		/* Entry in use? */
 		WARN_ON(*buff);
 
-		/* skb might still be in there for recycle on short receives */
-		if (info->skb)
-			skb = info->skb;
-		else {
-			skb = dev_alloc_skb(BUF_SIZE);
-			skb_reserve(skb, LOCAL_SKB_ALIGN);
-		}
+		skb = dev_alloc_skb(BUF_SIZE);
+		skb_reserve(skb, LOCAL_SKB_ALIGN);
 
 		if (unlikely(!skb))
 			break;
@@ -666,21 +661,7 @@ static int pasemi_mac_clean_rx(struct pa
 			goto next;
 		}
 
-		if (len < 256) {
-			struct sk_buff *new_skb;
-
-			new_skb = netdev_alloc_skb(mac->netdev,
-						   len + LOCAL_SKB_ALIGN);
-			if (new_skb) {
-				skb_reserve(new_skb, LOCAL_SKB_ALIGN);
-				memcpy(new_skb->data, skb->data, len);
-				/* save the skb in buffer_info as good */
-				skb = new_skb;
-			}
-			/* else just continue with the old one */
-		} else
-			info->skb = NULL;
-
+		info->skb = NULL;
 		info->dma = 0;
 
 		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
