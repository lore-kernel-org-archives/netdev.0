From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] correct IGMP behavior on v3 query during v2-compatibility
 mode
Date: Thu, 30 Sep 2010 17:29:40 -0700
Message-ID: <1285892980.21804.7.camel@w-dls.beaverton.ibm.com>
Reply-To: dlstevens@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:50060 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab0JAA3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 20:29:42 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o910Ku7P011112
	for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 18:20:56 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o910TfVu102730
	for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 18:29:42 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o910TfUV027180
	for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 18:29:41 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent patch to allow IGMPv2 responses to IGMPv3 queries
bypasses length checks for valid query lengths, incorrectly
resets the v2_seen timer, and does not support IGMPv1.

The following patch responds with a v2 report as required
by IGMPv2 while correcting the other problems introduced
by the patch.

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

--- linux-2.6.36-rc5/net/ipv4/igmp.c	2010-09-20 16:56:53.000000000 -0700
+++ linux-2.6.36-rc5-dls/net/ipv4/igmp.c	2010-09-28 12:09:03.000000000 -0700
@@ -834,7 +834,7 @@ static void igmp_heard_query(struct in_d
 	int			mark = 0;
 
 
-	if (len == 8 || IGMP_V2_SEEN(in_dev)) {
+	if (len == 8) {
 		if (ih->code == 0) {
 			/* Alas, old v1 router presents here. */
 
@@ -856,6 +856,18 @@ static void igmp_heard_query(struct in_d
 		igmpv3_clear_delrec(in_dev);
 	} else if (len < 12) {
 		return;	/* ignore bogus packet; freed by caller */
+	} else if (IGMP_V1_SEEN(in_dev)) {
+		/* This is a v3 query with v1 queriers present */
+		max_delay = IGMP_Query_Response_Interval;
+		group = 0;
+	} else if (IGMP_V2_SEEN(in_dev)) {
+		/* this is a v3 query with v2 queriers present;
+		 * Interpretation of the max_delay code is problematic here.
+		 * A real v2 host would use ih_code directly, while v3 has a
+		 * different encoding. We use the v3 encoding as more likely
+		 * to be intended in a v3 query.
+		 */
+		max_delay = IGMPV3_MRC(ih3->code)*(HZ/IGMP_TIMER_SCALE);
 	} else { /* v3 */
 		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
 			return;


