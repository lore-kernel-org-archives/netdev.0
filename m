From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net] net: don't global ICMP rate limit packets originating
 from loopback
Date: Wed, 14 Jun 2017 13:27:37 +0200
Message-ID: <149743965710.19877.13901728209731997446.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: fweimer@redhat.com, hjl.tools@gmail.com,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52454 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751771AbdFNL1p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:27:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Weimer seems to have a glibc test-case which requires that
loopback interfaces does not get ICMP ratelimited.  This was broken by
commit c0303efeab73 ("net: reduce cycles spend on ICMP replies that
gets rate limited").

An ICMP response will usually be routed back-out the same incoming
interface.  Thus, take advantage of this and skip global ICMP
ratelimit when the incoming device is loopback.  In the unlikely event
that the outgoing it not loopback, due to strange routing policy
rules, ICMP rate limiting still works via peer ratelimiting via
icmpv4_xrlim_allow().  Thus, we should still comply with RFC1812
(section 4.3.2.8 "Rate Limiting").

This seems to fix the reproducer given by Florian.  While still
avoiding to perform expensive and unneeded outgoing route lookup for
rate limited packets (in the non-loopback case).

Fixes: c0303efeab73 ("net: reduce cycles spend on ICMP replies that gets rate limited")
Reported-by: Florian Weimer <fweimer@redhat.com>
Reported-by: "H.J. Lu" <hjl.tools@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/ipv4/icmp.c |    8 ++++++--
 net/ipv6/icmp.c |    2 +-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 43318b5f5647..9144fa7df2ad 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -657,8 +657,12 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	/* Needed by both icmp_global_allow and icmp_xmit_lock */
 	local_bh_disable();
 
-	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
-	if (!icmpv4_global_allow(net, type, code))
+	/* Check global sysctl_icmp_msgs_per_sec ratelimit, unless
+	 * incoming dev is loopback.  If outgoing dev change to not be
+	 * loopback, then peer ratelimit still work (in icmpv4_xrlim_allow)
+	 */
+	if (!(skb_in->dev && (skb_in->dev->flags&IFF_LOOPBACK)) &&
+	      !icmpv4_global_allow(net, type, code))
 		goto out_bh_enable;
 
 	sk = icmp_xmit_lock(net);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 230b5aac9f03..8d7b113958b1 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -491,7 +491,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	local_bh_disable();
 
 	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
-	if (!icmpv6_global_allow(type))
+	if (!(skb->dev->flags&IFF_LOOPBACK) && !icmpv6_global_allow(type))
 		goto out_bh_enable;
 
 	mip6_addr_swap(skb);
