From: shemminger@osdl.org
Subject: [PATCH 2/4] bridge-netfilter: code rearrangement for clarity
Date: Tue, 22 Aug 2006 17:10:52 -0700
Message-ID: <20060823001230.935359000@localhost.localdomain>
References: <20060823001050.363374000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:38878 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751072AbWHWATX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 20:19:23 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=br-nf-reorg.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup and rearrangement for better style and clarity:
	Split the function nf_bridge_maybe_copy_header into two pieces
	Move copy portion out of line.
	Use Ethernet header size macros.
	Use header file to handle CONFIG_NETFILTER_BRIDGE differences

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- br-nf.orig/include/linux/netfilter_bridge.h	2006-08-22 16:45:05.000000000 -0700
+++ br-nf/include/linux/netfilter_bridge.h	2006-08-22 16:46:47.000000000 -0700
@@ -47,26 +47,12 @@
 
 
 /* Only used in br_forward.c */
-static inline
-int nf_bridge_maybe_copy_header(struct sk_buff *skb)
+extern int nf_bridge_copy_header(struct sk_buff *skb);
+static inline int nf_bridge_maybe_copy_header(struct sk_buff *skb)
 {
-	int err;
-
-	if (skb->nf_bridge) {
-		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
-			err = skb_cow(skb, 18);
-			if (err)
-				return err;
-			memcpy(skb->data - 18, skb->nf_bridge->data, 18);
-			skb_push(skb, 4);
-		} else {
-			err = skb_cow(skb, 16);
-			if (err)
-				return err;
-			memcpy(skb->data - 16, skb->nf_bridge->data, 16);
-		}
-	}
-	return 0;
+	if (skb->nf_bridge)
+		return nf_bridge_copy_header(skb);
+  	return 0;
 }
 
 /* This is called by the IP fragmenting code and it ensures there is
@@ -90,6 +76,8 @@
 };
 
 extern int brnf_deferred_hooks;
+#else
+#define nf_bridge_maybe_copy_header(skb)	(0)
 #endif /* CONFIG_BRIDGE_NETFILTER */
 
 #endif /* __KERNEL__ */
--- br-nf.orig/net/bridge/br_forward.c	2006-08-22 16:44:04.000000000 -0700
+++ br-nf/net/bridge/br_forward.c	2006-08-22 16:48:12.000000000 -0700
@@ -38,13 +38,10 @@
 	if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
 		kfree_skb(skb);
 	else {
-#ifdef CONFIG_BRIDGE_NETFILTER
 		/* ip_refrag calls ip_fragment, doesn't copy the MAC header. */
 		if (nf_bridge_maybe_copy_header(skb))
 			kfree_skb(skb);
-		else
-#endif
-		{
+		else {
 			skb_push(skb, ETH_HLEN);
 
 			dev_queue_xmit(skb);
--- br-nf.orig/net/bridge/br_netfilter.c	2006-08-22 16:44:04.000000000 -0700
+++ br-nf/net/bridge/br_netfilter.c	2006-08-22 16:48:56.000000000 -0700
@@ -127,14 +127,37 @@
 
 static inline void nf_bridge_save_header(struct sk_buff *skb)
 {
-        int header_size = 16;
+        int header_size = ETH_HLEN;
 
 	if (skb->protocol == htons(ETH_P_8021Q))
-		header_size = 18;
+		header_size += VLAN_HLEN;
 
 	memcpy(skb->nf_bridge->data, skb->data - header_size, header_size);
 }
 
+/*
+ * When forwarding bridge frames, we save a copy of the original
+ * header before processing.
+ */
+int nf_bridge_copy_header(struct sk_buff *skb)
+{
+	int err;
+        int header_size = ETH_HLEN;
+
+	if (skb->protocol == htons(ETH_P_8021Q))
+		header_size += VLAN_HLEN;
+
+	err = skb_cow(skb, header_size);
+	if (err)
+		return err;
+
+	memcpy(skb->data - header_size, skb->nf_bridge->data, header_size);
+
+	if (skb->protocol == htons(ETH_P_8021Q))
+		__skb_push(skb, VLAN_HLEN);
+	return 0;
+}
+
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
  * bridge PRE_ROUTING hook. */

--


