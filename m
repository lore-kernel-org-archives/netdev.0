From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] Igmp w/o linearize.
Date: Wed, 25 Jun 2003 09:32:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625093216.57d0f586.shemminger@osdl.org>
References: <OF1697B5D8.36C009C2-ON88256D4F.00829A05@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <OF1697B5D8.36C009C2-ON88256D4F.00829A05@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the updated igmp patch, thanks to dlstevens for testing this.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1386  -> 1.1387 
#	     net/ipv4/igmp.c	1.26    -> 1.27   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/25	shemminger@osdl.org	1.1387
# IGMP no linearize
# --------------------------------------------
#
diff -Nru a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c	Wed Jun 25 09:27:47 2003
+++ b/net/ipv4/igmp.c	Wed Jun 25 09:27:47 2003
@@ -757,9 +757,10 @@
 	read_unlock(&in_dev->lock);
 }
 
-static void igmp_heard_query(struct in_device *in_dev, struct igmphdr *ih,
+static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 	int len)
 {
+	struct igmphdr 		*ih = skb->h.igmph;
 	struct igmpv3_query *ih3 = (struct igmpv3_query *)ih;
 	struct ip_mc_list	*im;
 	u32			group = ih->group;
@@ -790,6 +791,17 @@
 	} else if (len < 12) {
 		return;	/* ignore bogus packet; freed by caller */
 	} else { /* v3 */
+		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
+			return;
+		
+		ih3 = (struct igmpv3_query *) skb->h.raw;
+		if (ih3->nsrcs) {
+			if (!pskb_may_pull(skb, sizeof(struct igmpv3_query) 
+					   + ntohs(ih3->nsrcs)*sizeof(__u32)))
+				return;
+			ih3 = (struct igmpv3_query *) skb->h.raw;
+		}
+
 		max_delay = IGMPV3_MRC(ih3->code)*(HZ/IGMP_TIMER_SCALE);
 		if (!max_delay)
 			max_delay = 1;	/* can't mod w/ 0 */
@@ -838,7 +850,7 @@
 int igmp_rcv(struct sk_buff *skb)
 {
 	/* This basically follows the spec line by line -- see RFC1112 */
-	struct igmphdr *ih = skb->h.igmph;
+	struct igmphdr *ih;
 	struct in_device *in_dev = in_dev_get(skb->dev);
 	int len = skb->len;
 
@@ -847,23 +859,17 @@
 		return 0;
 	}
 
-	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_ATOMIC) != 0) {
-			kfree_skb(skb);
-			return -ENOMEM;
-		}
-		ih = skb->h.igmph;
-	}
-
-	if (len < sizeof(struct igmphdr) || ip_compute_csum((void *)ih, len)) {
+	if (!pskb_may_pull(skb, sizeof(struct igmphdr)) || 
+	    (u16)csum_fold(skb_checksum(skb, 0, len, 0))) {
 		in_dev_put(in_dev);
 		kfree_skb(skb);
 		return 0;
 	}
 
+	ih = skb->h.igmph;
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		igmp_heard_query(in_dev, ih, len);
+		igmp_heard_query(in_dev, skb, len);
 		break;
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
