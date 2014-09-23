From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving an mldv2 query
Date: Tue, 23 Sep 2014 09:03:47 +0200
Message-ID: <1411455828-5196-3-git-send-email-dborkman@redhat.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080AbaIWHD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 03:03:57 -0400
In-Reply-To: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While reviewing the code, I found it confusing why we update the URI when
receiving an MLDv2 query. The RFC does not mention any of this, and I also
double-checked with other implementations.

It is true that we start the general query timer with the received max_delay,
as mentioned in the older RFC2710, section 5.:

  [...] "start timer" for the address on the interface, using a delay
  value chosen uniformly from the interval [0, Maximum Response Delay],
  where Maximum Response Delay is specified in the Query. If this is
  an unsolicited Report, the timer is set to a delay value chosen
  uniformly from the interval [0, [Unsolicited Report Interval] ].

It however does not say anywhere that we are supposed to overwrite that
value. The purpose of the report is quite different and described as:

  When a node starts listening to a multicast address on an interface,
  it should immediately transmit an unsolicited Report for that address
  on that interface, in case it is the first listener on the link.
  To cover the possibility of the initial Report being lost or damaged,
  it is recommended that it be repeated once or twice after short delays
  [Unsolicited Report Interval]. (A simple way to accomplish this is to
  send the initial Report and then act as if a Multicast-Address-Specific
  Query was received for that address, and set a timer appropriately).

RFC3810, section 9.11. only changed that default interval into 1 second (in
contrast to the older RFC2710). Therefore, do not update the URI sysctl
provided interval value when receiving an MLDv2 query, only pass that max
delay as mentioned in section 5. along to mld_gq_start_timer(). This
behaviour seems to be the case since the initial implementation of MLDv2.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 [ Sending to net-next to let this linger a bit here first, seems to be
   the case like this since initial MLDv2. ]

 net/ipv6/mcast.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 3d0e8fc..2a4d2b1 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -994,9 +994,9 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 	return rv;
 }
 
-static void mld_gq_start_timer(struct inet6_dev *idev)
+static void mld_gq_start_timer(struct inet6_dev *idev, unsigned long delay)
 {
-	unsigned long tv = prandom_u32() % idev->mc_uri;
+	unsigned long tv = prandom_u32() % delay;
 
 	idev->mc_gq_running = 1;
 	if (!mod_timer(&idev->mc_gq_timer, jiffies+tv+2))
@@ -1274,8 +1274,6 @@ static int mld_process_v2(struct inet6_dev *idev, struct mld2_query *mld,
 	mld_update_qi(idev, mld);
 	mld_update_qri(idev, mld);
 
-	idev->mc_uri = *max_delay;
-
 	return 0;
 }
 
@@ -1345,7 +1343,7 @@ int igmp6_event_query(struct sk_buff *skb)
 			if (mlh2->mld2q_nsrcs)
 				return -EINVAL; /* no sources allowed */
 
-			mld_gq_start_timer(idev);
+			mld_gq_start_timer(idev, max_delay);
 			return 0;
 		}
 		/* mark sources to include, if group & source-specific */
-- 
1.7.11.7
