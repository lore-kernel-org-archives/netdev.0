From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 19:23:44 +0200
Message-ID: <1345569824.5158.540.camel@edumazet-glaptop>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>
	 <1345555336.5158.493.camel@edumazet-glaptop>
	 <1345560131.5158.500.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1208211815550.2149@ja.ssi.bg>
	 <1345567633.5158.534.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1208211954380.2149@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55189 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758022Ab2HURXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 13:23:49 -0400
Received: by eaac11 with SMTP id c11so18737eaa.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 10:23:48 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1208211954380.2149@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 20:18 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Tue, 21 Aug 2012, Eric Dumazet wrote:

> > My first patch was :
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index e4ba974..9858714 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -956,6 +956,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
> >  		dst->obsolete = DST_OBSOLETE_KILL;
> >  	} else {
> >  		rt->rt_pmtu = mtu;
> > +		rt->dst.expires = 0;
> >  		dst_set_expires(&rt->dst, ip_rt_mtu_expires);
> 
> 	This is better, does not break ipv4_link_failure.
> There is a little race some ipv4_mtu() user to see
> rt_pmtu != 0 and dst.expires = 0 and to fail in time_after_eq
> test. May be that is why dst.expires is never set to 0.
> But I still don't understand what both changes fix.

In fact we re-enter ip_rt_update_pmtu() if we receive a second ICMP,
and rt->rt_pmtu is already set, but dst is expired.

Thats why Sylvain said it was not happening in the 10 minutes following
boot.

So calling again dst_set_expires(&rt->dst, ip_rt_mtu_expires) does
nothing : rt_pmtu is ignored because dst.expires is too old.

Maybe we should just do :

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4ba974..d0181e2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -952,7 +952,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	ip_rt_build_flow_key(&fl4, sk, skb);
 	mtu = __ip_rt_update_pmtu(rt, &fl4, mtu);
 
-	if (!rt->rt_pmtu) {
+	if (!rt->rt_pmtu || time_after_eq(jiffies, rt->dst.expires)) {
 		dst->obsolete = DST_OBSOLETE_KILL;
 	} else {
 		rt->rt_pmtu = mtu;
