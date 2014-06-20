From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] ipv6: fix multipath route cleanup path for duplicate nexthops error case
Date: Fri, 20 Jun 2014 09:05:46 -0700
Message-ID: <1403280346-21204-1-git-send-email-roopa@cumulusnetworks.com>
Cc: roque@di.fc.ul.pt, yoshfuji@usagi.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:46677 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631AbaFTQFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 12:05:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Problem:
(route output trimmed to show example):
# ip -6 route add 2001:10:1:3::/64 nexthop via 2001:10:1:2::99

# ip -6 route show
2001:10:1:3::/64 via 2001:10:1:2::99 dev swp26  metric 1024

# ip -6 route add 2001:10:1:3::/64 nexthop via 2001:10:1:2::99
RTNETLINK answers: File exists

# ip route show
#
/* Previously added route vanished */

When the route nexthop add fails with -EXISTS, cleanup path tries
to delete all nexthops added so far. The cleanup logic has a bug.
It tries to delete all the nexthops given by user. In the above case though
the route was added by the user in his previous attempts, just because it
matches with the nexthop in the new request, the previously added route is
deleted. This patch fixes the cleanup path to only delete nexthops that
were successfully added during this request.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv6/route.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f23fbd2..51e9b25 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2438,10 +2438,13 @@ static int ip6_route_multipath(struct fib6_config *cfg, int add)
 	int remaining;
 	int attrlen;
 	int err = 0, last_err = 0;
+	int nh_processed_cnt, nh_processed_cnt_last = 0;
+	int rollback = 0;
 
 beginning:
 	rtnh = (struct rtnexthop *)cfg->fc_mp;
 	remaining = cfg->fc_mp_len;
+	nh_processed_cnt = 0;
 
 	/* Parse a Multipath Entry */
 	while (rtnh_ok(rtnh, remaining)) {
@@ -2471,6 +2474,10 @@ beginning:
 				 * next hops that have been already added.
 				 */
 				add = 0;
+				rollback = 1;
+				if (!nh_processed_cnt)
+					break;
+				nh_processed_cnt_last = nh_processed_cnt;
 				goto beginning;
 			}
 		}
@@ -2480,6 +2487,9 @@ beginning:
 		 * fib6_add_rt2node() has reject it).
 		 */
 		cfg->fc_nlinfo.nlh->nlmsg_flags &= ~NLM_F_EXCL;
+		if (rollback && nh_processed_cnt == nh_processed_cnt_last)
+			break;
+		nh_processed_cnt++;
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
-- 
1.7.10.4
