From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: [PATCH] net: Don't drop route cache entry in ipv4_negative_advice unless PTMU expired
Date: Fri, 19 Mar 2010 07:41:13 -0700
Message-ID: <1269009673-25497-1-git-send-email-guenter.roeck@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Denis V. Lunev" <den@openvz.org>,
	Guenter Roeck <guenter.roeck@ericsson.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr2.ericy.com ([198.24.6.3]:34750 "EHLO imr2.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705Ab0CSOlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 10:41:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP sessions over IPv4 can get stuck if routers between endpoints
do not fragment packets but implement PMTU instead.

Setup is as follows

       MTU1    MTU2   MTU1
    A--------B------C------D

with MTU1 > MTU2. A and D are endpoints, B and C are routers. B and C
implement PMTU and drop packets larger than MTU2 (for example because
DF is set on all packets). TCP sessions are initiated between A and D.
There is packet loss between A and D, causing frequent TCP retransmits.

After the number of retransmits on a TCP session reaches tcp_retries1,
tcp calls dst_negative_advice() prior to each retransmit. This results
in route cache entries for the peer to be deleted in ipv4_negative_advice()
if the Path MTU is set.

If the outstanding data on an affected TCP session is larger than MTU2, packets
sent from the endpoints will be dropped by B or C, and ICMP NEEDFRAG will be
returned. A and D receive NEEDFRAG messages and update PMTU.

Before the next retransmit, tcp will again call dst_negative_advice(), causing
the route cache entry (with correct PMTU) to be deleted. The retransmitted
packet will be larger than MTU2, causing it to be dropped again.

This sequence repeats until the TCP session aborts or is terminated.

Problem is fixed by removing route cache entries in ipv4_negative_advice()
only if the PMTU is expired.

Signed-off-by: Guenter Roeck <guenter.roeck@ericsson.com>
---
 net/ipv4/route.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d9b4024..7e1c9e4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1512,7 +1512,8 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			ip_rt_put(rt);
 			ret = NULL;
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
-			   rt->u.dst.expires) {
+			   (rt->u.dst.expires &&
+			    time_after_eq(jiffies, rt->u.dst.expires))) {
 			unsigned hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
 						rt->fl.oif,
 						rt_genid(dev_net(dst->dev)));
-- 
1.6.0.4

