From: Brian Haley <brian.haley@hp.com>
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Fri, 28 May 2010 13:59:25 -0400
Message-ID: <4C00047D.3010404@hp.com>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>	<8739xdqsuz.fsf@small.ssi.corp> <4BFECA65.7030102@hp.com>	<4BFEE49C.8060301@lucent.com> <87hblss92x.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Scott C Otto <otts@alcatel-lucent.com>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:41297 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab0E1R7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 13:59:30 -0400
In-Reply-To: <87hblss92x.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2010 04:51 AM, Arnaud Ebalard wrote:
>>> The below might actually be what was actually intended, triggering
>>> on what the user forced, rather than assuming all callers require
>>> strict behavior.
>>>
>>> -Brian
>>>
>>>
>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>> index 294cbe8..252d761 100644
>>> --- a/net/ipv6/route.c
>>> +++ b/net/ipv6/route.c
>>> @@ -814,7 +814,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>>>  {
>>>  	int flags = 0;
>>>  
>>> -	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
>>> +	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl->fl6_dst))
>>>  		flags |= RT6_LOOKUP_F_IFACE;
>>>  
>>>  	if (!ipv6_addr_any(&fl->fl6_src))
> 
> Brian, I tested the patch on my Mobile Node: it fixes the regression. I
> also updated the kernel on my Home Agent to a 2.6.34 with that fix and
> everything works as expected. *For that aspect* and fwiw, you get my
> 
> Tested-by: Arnaud Ebalard <arno@natisbad.org>

Ok, thanks for testing, I'll send out an updated patch, with the caveat
there still might be a DCCP regression, see below.

> For the SO_BINDTODEVICE aspect, I don't have code at hand to test if the
> fix works as expected. We should also double check that this will not
> break other paths which use the sk->sk_bound_dev_if with a different
> semantic:

> net/ieee802154/raw.c:   sk->sk_bound_dev_if = dev->ifindex;

Isn't AF_INET6, OK.

> net/core/sock.c:        sk->sk_bound_dev_if = index;

The actual setsockopt() call, OK.

> net/ipv6/datagram.c:    sk->sk_bound_dev_if = usin->sin6_scope_id;
> net/ipv6/datagram.c:    sk->sk_bound_dev_if = np->mcast_oif;
> net/ipv6/af_inet6.c:    sk->sk_bound_dev_if = addr->sin6_scope_id;
> net/ipv6/tcp_ipv6.c:    sk->sk_bound_dev_if = usin->sin6_scope_id;
> net/ipv6/tcp_ipv6.c:    newsk->sk_bound_dev_if = treq->iif;
> net/ipv6/raw.c:         sk->sk_bound_dev_if = addr->sin6_scope_id;

This are all in link-local or multicast code, caller passing-in scopeid,
would trigger rt6_need_strict() regardless, so are OK.

> net/sctp/socket.c:      newsk->sk_bound_dev_if = sk->sk_bound_dev_if;

SCTP peeling-off a socket, cloning parent, OK.

> net/ipv4/ip_output.c:   sk->sk_bound_dev_if = arg->bound_dev_if;
> net/ipv4/udp.c:         sk->sk_bound_dev_if = 0;

IPv4, shouldn't be affected by an IPv6 route change, OK.

> net/dccp/ipv6.c:        newsk->sk_bound_dev_if = ireq6->iif;

This is the only mystery in this list.  Looks like the DCCP accept()
codepath, and it's getting bound to the interface the request was
received on.  I'm not sure if the intention here was to force this
strict behavior or not.

> net/dccp/ipv6.c:        sk->sk_bound_dev_if = usin->sin6_scope_id;

In link-local code, caller passing-in scopeid, would trigger
rt6_need_strict() regardless, so OK.

-Brian
