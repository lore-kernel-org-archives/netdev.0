From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: [PATCH] small loopback.c cleanups
Date: Sat, 16 Aug 2003 17:57:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817005706.GE80721@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Few trivial cleanups/improvements to drivers/net/loopback.c  Seems to work
fine for me, although I don't know how to stress all of the code paths.

Patch is versus 2.6.0-test3 (should apply to current BK fine)

-Mitch

--- linux-2.6.0-test3-VIRGIN/drivers/net/loopback.c	2003-07-13 20:30:48.000000000 -0700
+++ linux-2.6.0-test3mnb1/drivers/net/loopback.c	2003-08-16 08:37:29.000000000 -0700
@@ -128,17 +128,13 @@
 	 *	instead are lobbed from tx queue to rx queue 
 	 */
 
-	if(atomic_read(&skb->users) != 1)
-	{
+	if (skb_shared(skb)) {
 	  	struct sk_buff *skb2=skb;
 	  	skb=skb_clone(skb, GFP_ATOMIC);		/* Clone the buffer */
-	  	if(skb==NULL) {
-			kfree_skb(skb2);
+		kfree_skb(skb2);
+	  	if (unlikely(skb==NULL))
 			return 0;
-		}
-	  	kfree_skb(skb2);
-	}
-	else
+	} else
 		skb_orphan(skb);
 
 	skb->protocol=eth_type_trans(skb,dev);
@@ -148,12 +144,8 @@
 #endif
 
 	if (skb_shinfo(skb)->tso_size) {
-		struct iphdr *iph = skb->nh.iph;
-
-		if (skb->protocol != htons(ETH_P_IP))
-			BUG();
-		if (iph->protocol != IPPROTO_TCP)
-			BUG();
+		BUG_ON(skb->protocol != htons(ETH_P_IP));
+		BUG_ON(skb->nh.iph->protocol != IPPROTO_TCP);
 
 		emulate_large_send_offload(skb);
 		return 0;
