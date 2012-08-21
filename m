From: Julian Anastasov <ja@ssi.bg>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 23:00:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208212102540.2149@ja.ssi.bg>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>  <1345555336.5158.493.camel@edumazet-glaptop>  <1345560131.5158.500.camel@edumazet-glaptop>  <alpine.LFD.2.00.1208211815550.2149@ja.ssi.bg>  <1345567633.5158.534.camel@edumazet-glaptop>
  <alpine.LFD.2.00.1208211954380.2149@ja.ssi.bg> <1345569824.5158.540.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57629 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361Ab2HUT7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 15:59:05 -0400
In-Reply-To: <1345569824.5158.540.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 21 Aug 2012, Eric Dumazet wrote:

> In fact we re-enter ip_rt_update_pmtu() if we receive a second ICMP,
> and rt->rt_pmtu is already set, but dst is expired.
> 
> Thats why Sylvain said it was not happening in the 10 minutes following
> boot.
> 
> So calling again dst_set_expires(&rt->dst, ip_rt_mtu_expires) does
> nothing : rt_pmtu is ignored because dst.expires is too old.

	Oh, well. I thought dst_set_expires was used
before for IPv4, it was not. I didn't expected function
that was old to cause problem. So, you are right that
MTU is not updated second time. But we must check if
such change will harm IPv6, dst_set_expires was/is
used there.

> Maybe we should just do :
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e4ba974..d0181e2 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -952,7 +952,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
>  	ip_rt_build_flow_key(&fl4, sk, skb);
>  	mtu = __ip_rt_update_pmtu(rt, &fl4, mtu);
>  
> -	if (!rt->rt_pmtu) {
> +	if (!rt->rt_pmtu || time_after_eq(jiffies, rt->dst.expires)) {

	At first look it should not be needed to cause route
relookup here. tcp_v4_mtu_reduced is prepared to use the new
dst_mtu for mss after calling inet_csk_update_pmtu. It seems the
new code expects that every socket that performs PMTU Discovery
will get ICMP error, so tcp_v4_mtu_reduced should be called
for every socket with every new ICMP. If there are 100 sockets
we will get 100 ICMPs. If we set DST_OBSOLETE_KILL as you
propose, all sockets will notice the need to relookup
route and will learn the new PMTU from fnhe exception with less
chances for other ICMP events. At first look, this variant looks
better to me in case if we want single PMTU to be propagated
to all sockets immediately. Can it cause other problems?
Now the rt life with PMTU will be limited to 600 secs.

	OTOH, tcp_current_mss() is called often, it will
notice the new dst_mtu, so may be there is no need for
route relookup by setting DST_OBSOLETE_KILL?

	Not sure if we still have to support this second
option, to change dst_set_expires to check for timeout=0:

	if (dst->expires == 0 || time_after(expires, dst->expires) ||
	    !timeout)

	In IPv4, ip_rt_update_pmtu was the only place that
can extend dst->expires, for the rt_bind_exception case
I assume expires is still 0 before the checks. Not sure if
IPv6 needs to use time_after, may be it prefers the
time_before variant? IPv6 updates MTU in rt6_update_expires
and we call dst_set_expires where the timer will not be
extended. But may be the intention is that MTU only
can reduce the expiration, not to extend it after timer
was set when route was added.

	So, another option is to create new function
dst_update_expires and to use it just for IPv4, it will
use time_after because IPv4 uses the timer just for
PMTU while IPv6 uses it in ip6_route_add() to limit
route lifetime due to lft values.

	dst_update_expires will be like dst_set_expires
but with this difference (time_after):

	if (dst->expires == 0 || time_after(expires, dst->expires) ||
	    !timeout)

	while dst_set_expires will be as before, used by IPv6.

>  		dst->obsolete = DST_OBSOLETE_KILL;
>  	} else {
>  		rt->rt_pmtu = mtu;

Regards

--
Julian Anastasov <ja@ssi.bg>
