From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: reduce cycles spend on ICMP replies
 that gets rate limited
Date: Sun, 4 Jun 2017 16:38:12 +0200
Message-ID: <20170604163812.602cc089@redhat.com>
References: <20170109150246.30215.63371.stgit@firesoul>
        <20170109150409.30215.34612.stgit@firesoul>
        <7d432179-5e3a-febe-ced7-39ea33ba4906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        xiyou.wangcong@gmail.com, brouer@redhat.com
To: Florian Weimer <fweimer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751159AbdFDOiS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 10:38:18 -0400
In-Reply-To: <7d432179-5e3a-febe-ced7-39ea33ba4906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 Jun 2017 09:11:53 +0200
Florian Weimer <fweimer@redhat.com> wrote:

> On 01/09/2017 04:04 PM, Jesper Dangaard Brouer wrote:
>
> > This patch split the global and per (inet)peer ICMP-reply limiter
> > code, and moves the global limit check to earlier in the packet
> > processing path.  Thus, avoid spending cycles on ICMP replies that
> > gets limited/suppressed anyhow.
> > 
> > The global ICMP rate limiter icmp_global_allow() is a good solution,
> > it just happens too late in the process.  The kernel goes through the
> > full route lookup (return path) for the ICMP message, before taking
> > the rate limit decision of not sending the ICMP reply.
> > 
> > Details: The kernels global rate limiter for ICMP messages got added
> > in commit 4cdf507d5452 ("icmp: add a global rate limitation").  It is
> > a token bucket limiter with a global lock.  It brilliantly avoids
> > locking congestion by only updating when 20ms (HZ/50) were elapsed. It
> > can then avoids taking lock when credit is exhausted (when under
> > pressure) and time constraint for refill is not yet meet.  
> 
> This patch removed the rate limit bypass for localhost.  As a result, it
> is impossible to write deterministic UDP client tests tests which
> exercise failover behavior in response to unreachable servers.

You cannot rely on ICMP responses delivery, too many systems (and
middleboxes) limit or drop ICMP. Before this patch, loopback dev was
explicitly excluded from being ICMP rate limited.  Thus, your localhost
test passed.

Is there a real use-case behind "failover behavior in response to
unreachable servers" (which would need to run on localhost)?


Adding back outgoing-dev loopback test will require a full
route-lookup, which is what the hole optimization gain[1] comes from.
[1] https://git.kernel.org/torvalds/c/9f2f27a9a518

I've tried to come-up with an alternative solution, see inlined patch
below...

 
> H.J. Lu noted that a glibc test started failing on kernel 4.11 and
> identified the regression:
> 
>   https://sourceware.org/ml/libc-alpha/2017-06/msg00167.html
> 
> (I have more tests which are afflicted by this, but are not yet in glibc
> upstream.)
> 
> This is particularly annoying because we already run such tests in a
> network namespace for isolation, but the rate limit counter is global,
> so that doesn't help here.
> 
> I'm attaching a self-contained test case.  It fails for me with:
> 
> localhost-icmp: iteration 50: no ICMP message (poll timeout)
> 
> On kernel 4.10, it passes and runs within just a few milliseconds.
> 
> Would you please fix this in some way?  Thanks.

I did a quick patch that fixes the problem... at least for your
reproducer test-vase.


[PATCH] net: don't global ICMP rate limit packets originating from loopback

From: Jesper Dangaard Brouer <brouer@redhat.com>

Florian Weimer seems to have a use-case that requires, that loopback
interfaces does not get ICMP ratelimited.  This was broken by commit
c0303efeab73 ("net: reduce cycles spend on ICMP replies that gets rate limited").

An ICMP response will usually be routed back-out the same incomming
interface.  Thus, take advantage of this and skip global ICMP ratelimit
when the incomming device is loopback.

This seems to fix the reproducer given by Florian.

Fixes: c0303efeab73 ("net: reduce cycles spend on ICMP replies that gets rate limited")
Reported-by: Florian Weimer <fweimer@redhat.com>
Reported-by: "H.J. Lu" <hjl.tools@gmail.com>
---
 net/ipv4/icmp.c |    9 +++++++--
 net/ipv6/icmp.c |    2 +-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 43318b5f5647..6d781e470678 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -419,6 +419,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	local_bh_disable();
 
 	/* global icmp_msgs_per_sec */
+	// XXX This is not the problem case getting hit ... see icmp_send
 	if (!icmpv4_global_allow(net, type, code))
 		goto out_bh_enable;
 
@@ -657,8 +658,12 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	/* Needed by both icmp_global_allow and icmp_xmit_lock */
 	local_bh_disable();
 
-	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
-	if (!icmpv4_global_allow(net, type, code))
+	/* Check global sysctl_icmp_msgs_per_sec ratelimit, but only
+	 * when incomming dev is not loopback.  If outgoing dev is not
+	 * loopback then it will be peer ratelimited (icmpv4_xrlim_allow)
+	 */
+	if (!(rt->dst.dev && (rt->dst.dev->flags&IFF_LOOPBACK)) &&
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
