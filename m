From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT] remove skb_linearize from igmp.c
Date: Mon, 23 Jun 2003 12:41:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030623124118.620f8339.shemminger@osdl.org>
References: <20030623120342.470cf504.shemminger@osdl.org>
	<20030623.120229.59679308.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030623.120229.59679308.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Try again... this time add pullup logic to the query processing, and
use skb_checksum to handle non-linear buffers.

--- linux-2.5.73/net/ipv4/igmp.c	2003-06-23 11:39:50.000000000 -0700
+++ linux-2.5-sysfs/net/ipv4/igmp.c	2003-06-23 12:37:57.000000000 -0700
@@ -757,17 +757,16 @@ static void igmp_heard_report(struct in_
 	read_unlock(&in_dev->lock);
 }
 
-static void igmp_heard_query(struct in_device *in_dev, struct igmphdr *ih,
-	int len)
+static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb)
 {
+	struct igmphdr 		*ih = skb->h.igmph;
 	struct igmpv3_query *ih3 = (struct igmpv3_query *)ih;
 	struct ip_mc_list	*im;
 	u32			group = ih->group;
 	int			max_delay;
 	int			mark = 0;
 
-
-	if (len == 8) {
+	if (skb->len == 8) {
 		if (ih->code == 0) {
 			/* Alas, old v1 router presents here. */
 	
@@ -787,9 +786,14 @@ static void igmp_heard_query(struct in_d
 			__in_dev_put(in_dev);
 		/* clear deleted report items */
 		igmpv3_clear_delrec(in_dev);
-	} else if (len < 12) {
+	} else if (skb->len < 12) {
 		return;	/* ignore bogus packet; freed by caller */
 	} else { /* v3 */
+		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
+			return;
+		
+		ih3 = (struct igmpv3_query *)(ih = skb->h.igmph);
+
 		max_delay = IGMPV3_MRC(ih3->code)*(HZ/IGMP_TIMER_SCALE);
 		if (!max_delay)
 			max_delay = 1;	/* can't mod w/ 0 */
@@ -803,7 +807,13 @@ static void igmp_heard_query(struct in_d
 			return;
 		}
 		/* mark sources to include, if group & source-specific */
-		mark = ih3->nsrcs != 0;
+		if ((mark = (ih3->nsrcs != 0))) {
+			if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)
+					   + ntohs(ih3->nsrcs) * sizeof(ih3->srcs[0])))
+				return;
+			
+			ih3 = (struct igmpv3_query *)(ih = skb->h.igmph);
+		}
 	}
 
 	/*
@@ -838,32 +848,23 @@ static void igmp_heard_query(struct in_d
 int igmp_rcv(struct sk_buff *skb)
 {
 	/* This basically follows the spec line by line -- see RFC1112 */
-	struct igmphdr *ih = skb->h.igmph;
+	struct igmphdr *ih;
 	struct in_device *in_dev = in_dev_get(skb->dev);
-	int len = skb->len;
 
-	if (in_dev==NULL) {
-		kfree_skb(skb);
-		return 0;
-	}
+	if (in_dev==NULL) 
+		goto out;
 
-	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_ATOMIC) != 0) {
-			kfree_skb(skb);
-			return -ENOMEM;
-		}
-		ih = skb->h.igmph;
-	}
+	if ((u16)csum_fold(skb_checksum(skb, 0, skb->len, 0)))
+		goto drop;
 
-	if (len < sizeof(struct igmphdr) || ip_compute_csum((void *)ih, len)) {
-		in_dev_put(in_dev);
-		kfree_skb(skb);
-		return 0;
-	}
+	if (!pskb_may_pull(skb, sizeof(struct igmphdr)))
+		goto drop;
+	
+	ih = skb->h.igmph;
 
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		igmp_heard_query(in_dev, ih, len);
+		igmp_heard_query(in_dev, skb);
 		break;
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
@@ -887,7 +888,9 @@ int igmp_rcv(struct sk_buff *skb)
 	default:
 		NETDEBUG(printk(KERN_DEBUG "New IGMP type=%d, why we do not know about it?\n", ih->type));
 	}
+ drop:
 	in_dev_put(in_dev);
+ out:
 	kfree_skb(skb);
 	return 0;
 }
