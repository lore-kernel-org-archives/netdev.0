From: Michal Tesar <mtesar@redhat.com>
Subject: [PATCH] igmp: Make igmp group member RFC 3376 compliant
Date: Thu, 3 Nov 2016 10:38:34 +0100
Message-ID: <20161103093834.GA31875@sparky-lenivo.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35601 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752567AbcKCJih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 05:38:37 -0400
Received: by mail-wm0-f50.google.com with SMTP id a197so192346556wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 02:38:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

5.2. Action on Reception of a Query

 When a system receives a Query, it does not respond immediately.
 Instead, it delays its response by a random amount of time, bounded
 by the Max Resp Time value derived from the Max Resp Code in the
 received Query message.  A system may receive a variety of Queries on
 different interfaces and of different kinds (e.g., General Queries,
 Group-Specific Queries, and Group-and-Source-Specific Queries), each
 of which may require its own delayed response.

 Before scheduling a response to a Query, the system must first
 consider previously scheduled pending responses and in many cases
 schedule a combined response.  Therefore, the system must be able to
 maintain the following state:

 o A timer per interface for scheduling responses to General Queries.

 o A per-group and interface timer for scheduling responses to Group-
   Specific and Group-and-Source-Specific Queries.

 o A per-group and interface list of sources to be reported in the
   response to a Group-and-Source-Specific Query.

 When a new Query with the Router-Alert option arrives on an
 interface, provided the system has state to report, a delay for a
 response is randomly selected in the range (0, [Max Resp Time]) where
 Max Resp Time is derived from Max Resp Code in the received Query
 message.  The following rules are then used to determine if a Report
 needs to be scheduled and the type of Report to schedule.  The rules
 are considered in order and only the first matching rule is applied.

 1. If there is a pending response to a previous General Query
    scheduled sooner than the selected delay, no additional response
    needs to be scheduled.

 2. If the received Query is a General Query, the interface timer is
    used to schedule a response to the General Query after the
    selected delay.  Any previously pending response to a General
    Query is canceled.
--8<--

Currently the timer is rearmed with new random expiration time for
every incoming query regardless of possibly already pending report.
Which is not aligned with the above RFE.
It also might happen that higher rate of incoming queries can
postpone the report after the expiration time of the first query
causing group membership loss.

Now the per interface general query timer is rearmed only
when there is no pending report already scheduled on that interface or
the newly selected expiration time is before the already pending
scheduled report.

Signed-off-by: Michal Tesar <mtesar@redhat.com>
---
 net/ipv4/igmp.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 606cc3e..5fc3fd4 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -219,9 +219,14 @@ static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
 static void igmp_gq_start_timer(struct in_device *in_dev)
 {
 	int tv = prandom_u32() % in_dev->mr_maxdelay;
+	unsigned long exp = jiffies + tv + 2;
+
+	if (in_dev->mr_gq_running &&
+	    time_after_eq(exp, (in_dev->mr_gq_timer).expires))
+		return;
 
 	in_dev->mr_gq_running = 1;
-	if (!mod_timer(&in_dev->mr_gq_timer, jiffies+tv+2))
+	if (!mod_timer(&in_dev->mr_gq_timer, exp))
 		in_dev_hold(in_dev);
 }
 
-- 
2.5.5
