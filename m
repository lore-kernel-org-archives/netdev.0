From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] dst: take into account policy update on check()
Date: Fri, 07 Sep 2012 17:21:52 +0200
Message-ID: <1347031312.2484.794.camel@edumazet-glaptop>
References: <5049FAE3.2050403@6wind.com>
	 <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1347033467-3757-2-git-send-email-nicolas.dichtel@6wind.com>
	 <1347028510.2484.736.camel@edumazet-glaptop>  <504A08EA.3080506@6wind.com>
	 <1347030598.2484.777.camel@edumazet-glaptop>  <504A0F1F.5060504@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vyasevich@gmail.com, davem@davemloft.net, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48365 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab2IGPV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 11:21:58 -0400
In-Reply-To: <504A0F1F.5060504@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-07 at 17:13 +0200, Nicolas Dichtel wrote:
> Le 07/09/2012 17:09, Eric Dumazet a =C3=A9crit :
> > On Fri, 2012-09-07 at 16:47 +0200, Nicolas Dichtel wrote:
> >> Le 07/09/2012 16:35, Eric Dumazet a =C3=A9crit :
> >>>
> >>> Hmm... cant we reuse rt_genid ?
> >>>
> >>> (When changing flow_cache_genid, change &net->ipv4.rt_genid)
> >>
> >> And so adding a new field in net->ipv6?
> >
> > or move net->ipv4.rt_genid to net->rt_genid
> >
> > Having separate field for IPv4/IPv6 is of little interest IMHO
> >
> Ok, I will wait feedback from other people and repost a patch after.

By the way, the get_random_bytes() calls in rt_cache_invalidate() and i=
n
rt_genid_init() are no longer needed, since we dont use jhash anymore
(no more route cache)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dc9549b..d6b2b1c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -448,26 +448,12 @@ static inline bool rt_is_expired(const struct rta=
ble *rth)
 }
=20
 /*
- * Perturbation of rt_genid by a small quantity [1..256]
- * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
- * many times (2^24) without giving recent rt_genid.
- * Jenkins hash is strong enough that litle changes of rt_genid are OK=
=2E
- */
-static void rt_cache_invalidate(struct net *net)
-{
-	unsigned char shuffle;
-
-	get_random_bytes(&shuffle, sizeof(shuffle));
-	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
-}
-
-/*
  * delay < 0  : invalidate cache (fast : entries will be deleted later=
)
  * delay >=3D 0 : invalidate & flush cache (can be long)
  */
 void rt_cache_flush(struct net *net, int delay)
 {
-	rt_cache_invalidate(net);
+	atomic_inc(&net->ipv4.rt_genid);
 }
=20
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst=
,
@@ -2533,8 +2519,7 @@ static __net_initdata struct pernet_operations sy=
sctl_route_ops =3D {
=20
 static __net_init int rt_genid_init(struct net *net)
 {
-	get_random_bytes(&net->ipv4.rt_genid,
-			 sizeof(net->ipv4.rt_genid));
+	atomic_set(&net->ipv4.rt_genid, 0);
 	get_random_bytes(&net->ipv4.dev_addr_genid,
 			 sizeof(net->ipv4.dev_addr_genid));
 	return 0;
