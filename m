From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge-netfilter: don't overwrite memory outside of skb
Date: Tue, 22 Aug 2006 17:19:28 -0700
Message-ID: <20060822171928.7ed34b86@localhost.localdomain>
References: <20060821135110.1114298d@localhost.localdomain>
	<20060821.150238.88482205.davem@davemloft.net>
	<20060822161628.2d69cf76@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47070 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751131AbWHWAT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 20:19:58 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060822161628.2d69cf76@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bridge netfilter code needs to check for space at the
front of the skb before overwriting; otherwise if skb from
device doesn't have headroom, then it will cause random
memory corruption.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.17.9.orig/include/linux/netfilter_bridge.h	2006-08-21 11:39:58.000000000 -0700
+++ linux-2.6.17.9/include/linux/netfilter_bridge.h	2006-08-21 11:40:26.000000000 -0700
@@ -47,18 +47,26 @@
 #define BRNF_BRIDGED			0x08
 #define BRNF_NF_BRIDGE_PREROUTING	0x10
 
-
 /* Only used in br_forward.c */
-static inline
-void nf_bridge_maybe_copy_header(struct sk_buff *skb)
+static inline int nf_bridge_maybe_copy_header(struct sk_buff *skb)
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
--- linux-2.6.17.9.orig/net/bridge/br_forward.c	2006-08-18 09:26:24.000000000 -0700
+++ linux-2.6.17.9/net/bridge/br_forward.c	2006-08-21 11:40:26.000000000 -0700
@@ -43,11 +43,15 @@
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
