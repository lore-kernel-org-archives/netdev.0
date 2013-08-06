From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux IPV6_SUBTREES not functioning
Date: Tue, 6 Aug 2013 13:43:27 +0200
Message-ID: <20130806114327.GA11767@order.stressinduktion.org>
References: <8CBF8819-E1D9-445E-9E7C-793422934733@inf-net.nl> <20130806083005.GC2941@order.stressinduktion.org> <013B2D02-AE77-4213-A929-3E35F9C9BF0F@inf-net.nl> <20130806085307.GD2941@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Teco Boot <teco@inf-net.nl>, netdev@vger.kernel.org,
	boutier@pps.univ-paris-diderot.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:34258 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099Ab3HFLn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 07:43:28 -0400
Content-Disposition: inline
In-Reply-To: <20130806085307.GD2941@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 10:53:07AM +0200, Hannes Frederic Sowa wrote:
> On Tue, Aug 06, 2013 at 10:46:43AM +0200, Teco Boot wrote:
> > Hi Hannes,
> > 
> > Yes problems with real traffic, with CORE (open source mobile ad hoc network emulator currently maintained by NRL and Boeing).
> > Mattieu had same problems and therefore stepped to the ip rule. Most, if not all, take this ip rule hack. But then, for each and every source prefix a complete routing table is needed. This is a bad thing and shall be avoided.
> > 
> > Do you think it should work? Have it working? If so, I want to reproduce.
> 
> Definitely, that should work. I can reproduce the same output with your
> script on net-next and am looking how to fix this. This could take a
> bit because I have another patch in my pipeline for testing. But maybe
> it is just a nit. ;)

Could you test if this patch fixes your problems? It does fix the output of
your script at least. ;)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ed828d6..2eaf4a8 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -993,8 +993,12 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
 
 			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen)) {
 #ifdef CONFIG_IPV6_SUBTREES
-				if (fn->subtree)
-					fn = fib6_lookup_1(fn->subtree, args + 1);
+				if (fn->subtree) {
+					struct fib6_node *sfn;
+					sfn = fib6_lookup_1(fn->subtree,
+							    args + 1);
+					fn = sfn ? : fn;
+				}
 #endif
 				if (!fn || fn->fn_flags & RTN_RTINFO)
 					return fn;
