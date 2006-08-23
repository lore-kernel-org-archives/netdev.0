From: shemminger@osdl.org
Subject: [PATCH 1/4] bridge-netfilter: memory corruption fix
Date: Tue, 22 Aug 2006 17:10:51 -0700
Message-ID: <20060823001230.727305000@localhost.localdomain>
References: <20060823001050.363374000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35550 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750770AbWHWATK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 20:19:10 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=br-nf-over.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bridge-netfilter code will overwrite memory if there is not headroom
in the skb to save the header.  This first showed up when using Xen with
sky2 driver that doesn't allocate the extra space.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br-nf.orig/include/linux/netfilter_bridge.h	2006-08-22 16:43:41.000000000 -0700
+++ br-nf/include/linux/netfilter_bridge.h	2006-08-22 16:45:05.000000000 -0700
@@ -48,15 +48,25 @@
 
 /* Only used in br_forward.c */
 static inline
-void nf_bridge_maybe_copy_header(struct sk_buff *skb)
+int nf_bridge_maybe_copy_header(struct sk_buff *skb)
 {
+	int err;
+
 	if (skb->nf_bridge) {
 		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			err = skb_cow(skb, 18);
+			if (err)
+				return err;
 			memcpy(skb->data - 18, skb->nf_bridge->data, 18);
 			skb_push(skb, 4);
-		} else
+		} else {
+			err = skb_cow(skb, 16);
+			if (err)
+				return err;
 			memcpy(skb->data - 16, skb->nf_bridge->data, 16);
+		}
 	}
+	return 0;
 }
 
 /* This is called by the IP fragmenting code and it ensures there is
--- br-nf.orig/net/bridge/br_forward.c	2006-08-22 16:43:41.000000000 -0700
+++ br-nf/net/bridge/br_forward.c	2006-08-22 16:44:04.000000000 -0700
@@ -40,11 +40,15 @@
 	else {
 #ifdef CONFIG_BRIDGE_NETFILTER
 		/* ip_refrag calls ip_fragment, doesn't copy the MAC header. */
-		nf_bridge_maybe_copy_header(skb);
+		if (nf_bridge_maybe_copy_header(skb))
+			kfree_skb(skb);
+		else
 #endif
-		skb_push(skb, ETH_HLEN);
+		{
+			skb_push(skb, ETH_HLEN);
 
-		dev_queue_xmit(skb);
+			dev_queue_xmit(skb);
+		}
 	}
 
 	return 0;

--


