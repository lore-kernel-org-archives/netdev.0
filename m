From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: ipv6: mldv1/v2: fix switchback timeout to rfc3810, 9.12.
Date: Thu, 29 Aug 2013 18:09:38 +0200
Message-ID: <1377792578-32642-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753874Ab3H2QOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 12:14:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i) RFC3810, 9.2. Query Interval [QI] says:

   The Query Interval variable denotes the interval between General
   Queries sent by the Querier. Default value: 125 seconds. [...]

ii) RFC3810, 9.3. Query Response Interval [QRI] says:

  The Maximum Response Delay used to calculate the Maximum Response
  Code inserted into the periodic General Queries. Default value:
  10000 (10 seconds) [...] The number of seconds represented by the
  [Query Response Interval] must be less than the [Query Interval].

iii) RFC3810, 9.12. Older Version Querier Present Timeout [OVQPT] says:

  The Older Version Querier Present Timeout is the time-out for
  transitioning a host back to MLDv2 Host Compatibility Mode. When an
  MLDv1 query is received, MLDv2 hosts set their Older Version Querier
  Present Timer to [Older Version Querier Present Timeout].

  This value MUST be ([Robustness Variable] times (the [Query Interval]
  in the last Query received)) plus ([Query Response Interval]).

Hence, on default the timeout results in:

  [RV] = 2, [QI] = 125sec, [QRI] = 10sec
  [OVQPT] = [RV] * [QI] + [QRI] = 260sec

Having that said, we currently calculate [OVQPT] (here given as 'switchback'
variable) as ...

  switchback = (idev->mc_qrv + 1) * max_delay

Looking at bridging multicast code for MLDv1, we can see that [QRI] resp.
Maximum Response Delay is encoded into mld->mld_maxdelay, so getting [QRI]
in MLDv1 the way we do is correct, but [QI] does not appear in our current
switch back variant. Side note: briding code will set its timers as follows:

  ...
  br->multicast_query_response_interval = 10 * HZ;
  br->multicast_startup_query_interval = 125 * HZ / 4;
  br->multicast_query_interval = 125 * HZ;
  ...

Concluding, the current behaviour in IPv6's multicast code is not conform
to the RFC as switch back is calculated wrongly. That is, it has a too small
value, so MLDv2 hosts switch back again to MLDv2 way too early.

On the other hand, RFC3810, 9.12. says "the [Query Interval] in the last Query
received". In section "9.14. Configuring timers", it is said:

  This section is meant to provide advice to network administrators on
  how to tune these settings to their network. Ambitious router
  implementations might tune these settings dynamically based upon
  changing characteristics of the network. [...]

iv) RFC38010, 9.14.2. Query Interval:

  The overall level of periodic MLD traffic is inversely proportional
  to the Query Interval. A longer Query Interval results in a lower
  overall level of MLD traffic. The value of the Query Interval MUST
  be equal to or greater than the Maximum Response Delay used to
  calculate the Maximum Response Code inserted in General Query
  messages.

I assume that is why switchback is calculated as is (3 * max_delay), although
this setting seems to be meant for routers only to configure their [QI]
interval for non-default intervals.

Also again, looking at the 'opposite site' in bridging code, the following
is happening: If a bridge sends out a query itself via br_multicast_send_query(),
multicast_query_timer is reset with br->multicast_query_interval (if we're not
in startup), that is on default 125 * HZ.

Therefore, when an MLDv1 query is received fix it up to use the default
timeout of 125 * HZ (as we also have in bridging code for intervals
queries are sent).

Next to that, a follow-up patch after the fix could make MLD_QI_DEFAULT tunable
per idev.

Introduced in 06da92283 ("[IPV6]: Add MLDv2 support.").

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: David Stevens <dlstevens@us.ibm.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 - I chose net-next as this is not something critical such as fixing a panic.
 - Note, commit 06da92283 is in linux-history tree.
 - David Stevens, it would be great if you could comment on this. :)

 net/ipv6/mcast.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 98ead2b..4b0aa5a 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -108,6 +108,8 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 			    struct inet6_dev *idev);
 
 #define MLD_QRV_DEFAULT		2
+/* RFC3810, 9.2. Query Interval */
+#define MLD_QI_DEFAULT		(125 * HZ)
 
 /* RFC3810, 8.1 Query Version Distinctions */
 #define MLD_V1_QUERY_LEN	24
@@ -1150,11 +1152,24 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	if (len == MLD_V1_QUERY_LEN) {
+		int mc_qi = MLD_QI_DEFAULT;
 		int switchback;
 		/* MLDv1 router present */
 
+		/* RFC3810, 9.12. Older Version Querier Present Timeout:
+		 *
+		 * The Older Version Querier Present Timeout is the time-out
+		 * for transitioning a host back to MLDv2 Host Compatibility
+		 * Mode. When an MLDv1 query is received, MLDv2 hosts set
+		 * their Older Version Querier Present Timer to [Older Version
+		 * Querier Present Timeout].
+		 *
+		 * This value MUST be ([Robustness Variable] times (the
+		 * [Query Interval] in the last Query received)) plus
+		 * ([Query Response Interval]).
+		 */
 		max_delay = msecs_to_jiffies(ntohs(mld->mld_maxdelay));
-		switchback = (idev->mc_qrv + 1) * max_delay;
+		switchback = idev->mc_qrv * mc_qi + max_delay;
 		idev->mc_v1_seen = jiffies + switchback;
 
 		/* cancel the interface change timer */
-- 
1.7.11.7
