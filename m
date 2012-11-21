From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 3.6 routing cache regression, multicast loopback broken
Date: Wed, 21 Nov 2012 02:35:34 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1211210055040.1751@ja.ssi.bg>
References: <1352133471.12029.43.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:37370 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818Ab2KUAeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2012 19:34:16 -0500
In-Reply-To: <1352133471.12029.43.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 5 Nov 2012, Maxime Bizon wrote:

> 
> Hi David & all,
> 
> 
> kernel 3.6 to 3.6.5 (3.5 is working fine)
> 
> I have a "sender" sample app that does:
> 
>   - socket(dgram)
>   - setsockopt mcast ttl 8
>   - setsockopt mcast loopback

	Do you also have CONFIG_IP_MROUTE enabled? I see the
problem with caching both "RTCF_MULTICAST | RTCF_LOCAL" and
"RTCF_MULTICAST" flags to same place but I'm not sure in the
sequence of route lookups for your setup. ip_mc_output does
not care about RTCF_LOCAL when CONFIG_IP_MROUTE is disabled,
so in this case it should loop the packet even on wrong
caching (without RTCF_LOCAL flag).

>   - sendto() to 239.0.0.x
> 
> and a "receiver" sample app:
> 
>   - socket(dgram)
>   - bind(239.0.0.x)
>   - add membership (239.0.0.x)
>   - loop on recv()
> 
> 
> My setup: no default route, "ip route add 239.0.0.0/8 dev eth0", sender
> & receiver running on same host.
> 
> If I first start one sender app (on 239.0.0.1), and after a receiver app
> on 239.0.0.1 => no problem
> 
> If I first start two or more sender apps (239.0.0.1/239.0.0.2/...), then
> assuming I don't start as many matching receivers, receivers sometimes
> get all data or nothing at all.
> 
> 
> After digging in __mkroute_output(), I found that unless I'm using a
> default route (fi != NULL), rtable is cached and shared by all senders
> (even those with different mcast addresses)
> 
> Since ip_check_mc_rcu() returns different results depending on whether
> fl->daddr is present in device mc_list or not, I don't think we can
> cache this.
> 
> The random working/not working effect I get is because add_membership
> flushes the rt_cache, so depending on which sender does sendto() first
> after flush, the cached entry will either use ip_mc_output() or
> ip_output().

	Can you try the following patch. If it does not
solve the problem we have to add some debugs in __mkroute_output.
And I'm not sure if this is fatal only when CONFIG_IP_MROUTE
is enabled, I have to spend more time to check the code.
As an optimization, the patch avoids lookup for fnhe
when multicast is not cached because multicasts are
not redirected and they do not learn PMTU.

	The patch is not tested. I'll update the commit
message after your tests.

> -- 
> Maxime

[PATCH net-next] ipv4: do not cache looped multicasts

	We have two cases for outgoing multicasts
depending on the membership: with or without RTCF_LOCAL.
Currently, we use caching only if route to 224/4 is used.
As we can not cache for both cases, optimize the caching
for senders only, do not cache routes with RTCF_LOCAL
flag set.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/route.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5b58788..0d73f86 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1785,6 +1785,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
+	do_cache = true;
 	if (type == RTN_BROADCAST) {
 		flags |= RTCF_BROADCAST | RTCF_LOCAL;
 		fi = NULL;
@@ -1793,6 +1794,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		if (!ip_check_mc_rcu(in_dev, fl4->daddr, fl4->saddr,
 				     fl4->flowi4_proto))
 			flags &= ~RTCF_LOCAL;
+		else
+			do_cache = false;
 		/* If multicast route do not exist use
 		 * default one, but do not gateway in this case.
 		 * Yes, it is hack.
@@ -1802,8 +1805,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 	fnhe = NULL;
-	do_cache = fi != NULL;
-	if (fi) {
+	do_cache &= fi != NULL;
+	if (do_cache) {
 		struct rtable __rcu **prth;
 		struct fib_nh *nh = &FIB_RES_NH(*res);
 
-- 
1.7.3.4
