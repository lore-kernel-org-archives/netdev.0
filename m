From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/7) ipmr.c fix dst underflow on dropped packets
Date: Wed, 25 Jun 2003 11:41:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114137.4c4c2377.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If ipmr rejected a packet, then it would cause a socket buffer to be reprocessed
after freed leading to "dst underflow" and slow death.  The IP handler expects a negative
return value to be the protocol to resubmit to, not an error code.

diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Wed Jun 25 11:30:29 2003
+++ b/net/ipv4/ipmr.c	Wed Jun 25 11:30:29 2003
@@ -1405,19 +1405,15 @@
 	struct net_device  *reg_dev = NULL;
 
 	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_ATOMIC) != 0) {
-			kfree_skb(skb);
-			return -ENOMEM;
-		}
+		if (skb_linearize(skb, GFP_ATOMIC) != 0) 
+			goto drop;
 		pim = (struct igmphdr*)skb->h.raw;
 	}
 
         if (!mroute_do_pim ||
 	    skb->len < sizeof(*pim) + sizeof(*encap) ||
-	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER) {
-		kfree_skb(skb);
-                return -EINVAL;
-        }
+	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER) 
+		goto drop;
 
 	encap = (struct iphdr*)(skb->h.raw + sizeof(struct igmphdr));
 	/*
@@ -1427,11 +1423,9 @@
 	   c. packet is not truncated
 	 */
 	if (!MULTICAST(encap->daddr) ||
-	    ntohs(encap->tot_len) == 0 ||
-	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
+	    encap->tot_len == 0 ||
+	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len) 
+		goto drop;
 
 	read_lock(&mrt_lock);
 	if (reg_vif_num >= 0)
@@ -1440,10 +1434,8 @@
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
 
-	if (reg_dev == NULL) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
+	if (reg_dev == NULL) 
+		goto drop;
 
 	skb->mac.raw = skb->nh.raw;
 	skb_pull(skb, (u8*)encap - skb->data);
@@ -1464,6 +1456,9 @@
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
+ drop:
+	kfree_skb(skb);
+	return 0;
 }
 #endif
 
@@ -1475,10 +1470,8 @@
 	struct net_device  *reg_dev = NULL;
 
 	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_ATOMIC) != 0) {
-			kfree_skb(skb);
-			return -ENOMEM;
-		}
+		if (skb_linearize(skb, GFP_ATOMIC) != 0) 
+			goto drop;
 		pim = (struct pimreghdr*)skb->h.raw;
 	}
 
@@ -1486,19 +1479,15 @@
 	    pim->type != ((PIM_VERSION<<4)|(PIM_REGISTER)) ||
 	    (pim->flags&PIM_NULL_REGISTER) ||
 	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 &&
-	     ip_compute_csum((void *)pim, skb->len))) {
-		kfree_skb(skb);
-                return -EINVAL;
-        }
+	     ip_compute_csum((void *)pim, skb->len))) 
+		goto drop;
 
 	/* check if the inner packet is destined to mcast group */
 	encap = (struct iphdr*)(skb->h.raw + sizeof(struct pimreghdr));
 	if (!MULTICAST(encap->daddr) ||
-	    ntohs(encap->tot_len) == 0 ||
-	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
+	    encap->tot_len == 0 ||
+	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len) 
+		goto drop;
 
 	read_lock(&mrt_lock);
 	if (reg_vif_num >= 0)
@@ -1507,10 +1496,8 @@
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
 
-	if (reg_dev == NULL) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
+	if (reg_dev == NULL) 
+		goto drop;
 
 	skb->mac.raw = skb->nh.raw;
 	skb_pull(skb, (u8*)encap - skb->data);
@@ -1530,6 +1517,9 @@
 #endif
 	netif_rx(skb);
 	dev_put(reg_dev);
+	return 0;
+ drop:
+	kfree_skb(skb);
 	return 0;
 }
 #endif
