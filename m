From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] remove skb_linearize from igmp.c
Date: Mon, 23 Jun 2003 12:03:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030623120342.470cf504.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch gets rid of the deprecated skb_linearize call in IGMP by
using pskb_may_pull like ip_input does.

Could someone who actually receives IGMP packets test this?

diff -Nru a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c	Mon Jun 23 11:59:56 2003
+++ b/net/ipv4/igmp.c	Mon Jun 23 11:59:56 2003
@@ -838,28 +838,19 @@
 int igmp_rcv(struct sk_buff *skb)
 {
 	/* This basically follows the spec line by line -- see RFC1112 */
-	struct igmphdr *ih = skb->h.igmph;
+	struct igmphdr *ih;
 	struct in_device *in_dev = in_dev_get(skb->dev);
 	int len = skb->len;
 
-	if (in_dev==NULL) {
-		kfree_skb(skb);
-		return 0;
-	}
-
-	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_ATOMIC) != 0) {
-			kfree_skb(skb);
-			return -ENOMEM;
-		}
-		ih = skb->h.igmph;
-	}
+	if (in_dev==NULL) 
+		goto out;
 
-	if (len < sizeof(struct igmphdr) || ip_compute_csum((void *)ih, len)) {
-		in_dev_put(in_dev);
-		kfree_skb(skb);
-		return 0;
-	}
+	if (!pskb_may_pull(skb, sizeof(struct igmphdr)))
+		goto drop;
+	
+	ih = skb->h.igmph;
+	if (ip_compute_csum((void *)ih, len)) 
+		goto drop;
 
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_QUERY:
@@ -887,7 +878,9 @@
 	default:
 		NETDEBUG(printk(KERN_DEBUG "New IGMP type=%d, why we do not know about it?\n", ih->type));
 	}
+ drop:
 	in_dev_put(in_dev);
+ out:
 	kfree_skb(skb);
 	return 0;
 }
