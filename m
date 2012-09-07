From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igmp: avoid drop_monitor false positives
Date: Fri, 07 Sep 2012 08:37:06 +0200
Message-ID: <1346999826.2484.252.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37529 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab2IGGhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 02:37:11 -0400
Received: by bkwj10 with SMTP id j10so1177588bkw.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 23:37:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

igmp should call consume_skb() for all correctly processed packets,
to avoid false dropwatch/drop_monitor false positives.

Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/igmp.c |   30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 0b5580c..3479b98 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -815,14 +815,15 @@ static int igmp_marksources(struct ip_mc_list *pmc, int nsrcs, __be32 *srcs)
 	return 1;
 }
 
-static void igmp_heard_report(struct in_device *in_dev, __be32 group)
+/* return true if packet was dropped */
+static bool igmp_heard_report(struct in_device *in_dev, __be32 group)
 {
 	struct ip_mc_list *im;
 
 	/* Timers are only set for non-local groups */
 
 	if (group == IGMP_ALL_HOSTS)
-		return;
+		return false;
 
 	rcu_read_lock();
 	for_each_pmc_rcu(in_dev, im) {
@@ -832,9 +833,11 @@ static void igmp_heard_report(struct in_device *in_dev, __be32 group)
 		}
 	}
 	rcu_read_unlock();
+	return false;
 }
 
-static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
+/* return true if packet was dropped */
+static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 	int len)
 {
 	struct igmphdr 		*ih = igmp_hdr(skb);
@@ -866,7 +869,7 @@ static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 		/* clear deleted report items */
 		igmpv3_clear_delrec(in_dev);
 	} else if (len < 12) {
-		return;	/* ignore bogus packet; freed by caller */
+		return true;	/* ignore bogus packet; freed by caller */
 	} else if (IGMP_V1_SEEN(in_dev)) {
 		/* This is a v3 query with v1 queriers present */
 		max_delay = IGMP_Query_Response_Interval;
@@ -883,13 +886,13 @@ static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 			max_delay = 1;	/* can't mod w/ 0 */
 	} else { /* v3 */
 		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
-			return;
+			return true;
 
 		ih3 = igmpv3_query_hdr(skb);
 		if (ih3->nsrcs) {
 			if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)
 					   + ntohs(ih3->nsrcs)*sizeof(__be32)))
-				return;
+				return true;
 			ih3 = igmpv3_query_hdr(skb);
 		}
 
@@ -901,9 +904,9 @@ static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 			in_dev->mr_qrv = ih3->qrv;
 		if (!group) { /* general query */
 			if (ih3->nsrcs)
-				return;	/* no sources allowed */
+				return false;	/* no sources allowed */
 			igmp_gq_start_timer(in_dev);
-			return;
+			return false;
 		}
 		/* mark sources to include, if group & source-specific */
 		mark = ih3->nsrcs != 0;
@@ -939,6 +942,7 @@ static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 			igmp_mod_timer(im, max_delay);
 	}
 	rcu_read_unlock();
+	return false;
 }
 
 /* called in rcu_read_lock() section */
@@ -948,6 +952,7 @@ int igmp_rcv(struct sk_buff *skb)
 	struct igmphdr *ih;
 	struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
 	int len = skb->len;
+	bool dropped = true;
 
 	if (in_dev == NULL)
 		goto drop;
@@ -969,7 +974,7 @@ int igmp_rcv(struct sk_buff *skb)
 	ih = igmp_hdr(skb);
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		igmp_heard_query(in_dev, skb, len);
+		dropped = igmp_heard_query(in_dev, skb, len);
 		break;
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
@@ -979,7 +984,7 @@ int igmp_rcv(struct sk_buff *skb)
 		/* don't rely on MC router hearing unicast reports */
 		if (skb->pkt_type == PACKET_MULTICAST ||
 		    skb->pkt_type == PACKET_BROADCAST)
-			igmp_heard_report(in_dev, ih->group);
+			dropped = igmp_heard_report(in_dev, ih->group);
 		break;
 	case IGMP_PIM:
 #ifdef CONFIG_IP_PIMSM_V1
@@ -997,7 +1002,10 @@ int igmp_rcv(struct sk_buff *skb)
 	}
 
 drop:
-	kfree_skb(skb);
+	if (dropped)
+		kfree_skb(skb);
+	else
+		consume_skb(skb);
 	return 0;
 }
 
