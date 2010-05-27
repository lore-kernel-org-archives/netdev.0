From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Thu, 27 May 2010 23:01:53 +0200
Message-ID: <87sk5d2h4u.fsf@small.ssi.corp>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>
	<8739xdqsuz.fsf@small.ssi.corp> <4BFECA65.7030102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	=?utf-8?B?WU9TSElGVUpJIEhpZGVh?=
	 =?utf-8?B?a2kgLyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Scott Otto <scott.otto@alcatel-lucent.com>,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:56378 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756683Ab0E0VCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 17:02:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Brian Haley <brian.haley@hp.com> writes:

>> In previous debug outputs, the content of the fl->oif is ok, i.e. it is
>> set to the interface on which the CoA is configured, i.e. the output
>> interface. But the commit results in flags |= RT6_LOOKUP_F_IFACE.
>> Later, in rt6_score_route(), the call to rt6_check_dev() returns 0
>> (dev->ifindex is ip6tnl1 but oif is wlan0). Because of the change to flags 
>> flags, we quickly return -1 in rt6_score_route():
>
> Ok, so the call to ip6_route_output() was from the tunnel code, which is
> using it's cached flowi, which has oif set to the tunnel.  The XFRM code
> swaps the addresses, which should invalidate the oif, but it doesn't.
>
>> static int rt6_score_route(struct rt6_info *rt, int oif,
>> 			   int strict)
>> {
>> 	int m, n;
>> 
>> 	m = rt6_check_dev(rt, oif);
>> 	if (!m && (strict & RT6_LOOKUP_F_IFACE))
>>                 return -1;
>>         ...
>> 
>> Now, I wonder if the following is correct. Don't hesitate to correct me
>> if I am wrong:
>> 
>> Initially (before f4f914b58019f0), the purpose of the test using
>> rt6_need_strict() in ip6_route_output() (introduced by c71099ac) was to
>> allow the multiple routing table logic to be applied to all global
>> addresses but to preserve the addresses for which it would not make
>> sense (link-local, multicast, ). The change introduced by f4f914b58019f0
>> basically reduces the ability to route traffic as you want and forces
>> the traffic to leave the device by the interface on which it is
>> configured (if fl->oif is set).
>
> The problem is we assumed the caller's would only set fl->oif if they
> wanted it enforced (multicast, link-local, SO_BINDTODEVICE), but it
> didn't take into account the tunnel code.  I guess the easy answer
> would be to revert this until we can fix it correctly.

Nothing against it but maybe Jiri or David have other ideas.


>> From my (very limited and possibly wrong) understanding, the change
>> introduced by f4f914b58019f0 looks like a workaround for the 
>> SO_BINDTODEVICE issue. Looking at the code, there is something I don't
>> understand: if SO_BINDTODEVICE has been used on a socket, the socket
>> should have its sk_bound_dev_if attribute set to the correct ifindex
>> value. Hence the following (naive) question: why is that information not
>> used to inflect the selection of the route cached for the socket? And
>> why would the fix be at the adress level instead of being at the
>> interface level (ifindex)?
>
> I guess I always believed setting SO_BINDTODEVICE should always force
> traffic out that interface, but from Yoshifuji's email it seems that
> maybe wasn't the intention, at least for things that don't meet
> the rt_need_strict() criteria like globals.  I don't know the history
> behind the setsockopt.

The behavior I would expect from a combination of RFC 4191 and
SO_BINDTODEVICE sockopt would be the use of the interface as outgoing
interface and then the use of the best router (using router preference
info, reachability, ...) available on the subnet. IIRC, the router
preference info is per default router list in the RFC, i.e. per
interface. 


> The below might actually be what was actually intended, triggering
> on what the user forced, rather than assuming all callers require
> strict behavior.
>
> -Brian
>
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 294cbe8..252d761 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -814,7 +814,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>  {
>  	int flags = 0;
>  
> -	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
> +	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl->fl6_dst))
>  		flags |= RT6_LOOKUP_F_IFACE;
>  
>  	if (!ipv6_addr_any(&fl->fl6_src))

Just for fun, I'll test it tomorrow. I think this would be a better
alternative to a simple revert.

Cheers,

a+
