From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/7) Get rid of skb_linearize in ipmr.c
Date: Wed, 25 Jun 2003 11:41:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114141.76c11186.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use explicit may_pull's instead of forcing skb to be linearized.

diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Wed Jun 25 11:30:41 2003
+++ b/net/ipv4/ipmr.c	Wed Jun 25 11:30:41 2003
@@ -1400,15 +1400,14 @@
 
 int pim_rcv_v1(struct sk_buff * skb)
 {
-	struct igmphdr *pim = (struct igmphdr*)skb->h.raw;
+	struct igmphdr *pim;
 	struct iphdr   *encap;
 	struct net_device  *reg_dev = NULL;
 
-	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_ATOMIC) != 0) 
-			goto drop;
-		pim = (struct igmphdr*)skb->h.raw;
-	}
+	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap))) 
+		goto drop;
+
+	pim = (struct igmphdr*)skb->h.raw;
 
         if (!mroute_do_pim ||
 	    skb->len < sizeof(*pim) + sizeof(*encap) ||
@@ -1465,21 +1464,18 @@
 #ifdef CONFIG_IP_PIMSM_V2
 static int pim_rcv(struct sk_buff * skb)
 {
-	struct pimreghdr *pim = (struct pimreghdr*)skb->h.raw;
+	struct pimreghdr *pim;
 	struct iphdr   *encap;
 	struct net_device  *reg_dev = NULL;
 
-	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_ATOMIC) != 0) 
-			goto drop;
-		pim = (struct pimreghdr*)skb->h.raw;
-	}
+	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap))) 
+		goto drop;
 
-        if (skb->len < sizeof(*pim) + sizeof(*encap) ||
-	    pim->type != ((PIM_VERSION<<4)|(PIM_REGISTER)) ||
+	pim = (struct pimreghdr*)skb->h.raw;
+        if (pim->type != ((PIM_VERSION<<4)|(PIM_REGISTER)) ||
 	    (pim->flags&PIM_NULL_REGISTER) ||
-	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 &&
-	     ip_compute_csum((void *)pim, skb->len))) 
+	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 && 
+	     (u16)csum_fold(skb_checksum(skb, 0, skb->len, 0)))) 
 		goto drop;
 
 	/* check if the inner packet is destined to mcast group */
