From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Fri, 28 May 2010 10:51:18 +0200
Message-ID: <87hblss92x.fsf@small.ssi.corp>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>
	<8739xdqsuz.fsf@small.ssi.corp> <4BFECA65.7030102@hp.com>
	<4BFEE49C.8060301@lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	=?utf-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org
To: Scott C Otto <otts@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:50738 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288Ab0E1Ivf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 04:51:35 -0400
In-Reply-To: <4BFEE49C.8060301@lucent.com> (Scott C. Otto's message of "Thu,
	27 May 2010 16:31:08 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Scott C Otto <otts@alcatel-lucent.com> writes:

> All,
> Thanks for looking into this.
>
> The behavior of SO_BINDTODEVICE, certainly with IPV4, is to identify a specific
> interface to use for sending/receiving AF_INET packets upon.   And that's how it
> has behaved with IPV4.   Tools like ping, traceroute (and ping6, traceroute6)
> make use of it with the -i (interface) options.
>
> We ran into this issue when updating an IPV4 application to IPV6.   The report
> provided one example of the issue.
>
> The original change was based on the semantics of flowi.oif used in IPV4.  There
> flowi.oif (as it is with IPV6 as well) is also set to sk->sk_bound_dev_if when
> using ip_route_connect() and routing simply took a non-zero oif to enforce an
> interface.  Looking at IPV4 tunneling, flowi.oif is set the same way from
> tunnel's parms.link as with IPV6 so would follow those semantics as well.
>
> Obviously, with IPV6, the semantics of flowi.oif are different and perhaps even
> vary with the users of IPV6.
>
> If that variability is desired, the proposed change from Brian (using
> sk->sk_bound_dev_if) would be an equivalent means of supporting SO_BINDTODEVICE
> while limiting the impact.

ok. Thanks for the feedback. Can you comment on what is below?

>> The below might actually be what was actually intended, triggering
>> on what the user forced, rather than assuming all callers require
>> strict behavior.
>> 
>> -Brian
>> 
>> 
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 294cbe8..252d761 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -814,7 +814,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>>  {
>>  	int flags = 0;
>>  
>> -	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
>> +	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl->fl6_dst))
>>  		flags |= RT6_LOOKUP_F_IFACE;
>>  
>>  	if (!ipv6_addr_any(&fl->fl6_src))

Brian, I tested the patch on my Mobile Node: it fixes the regression. I
also updated the kernel on my Home Agent to a 2.6.34 with that fix and
everything works as expected. *For that aspect* and fwiw, you get my

Tested-by: Arnaud Ebalard <arno@natisbad.org>

For the SO_BINDTODEVICE aspect, I don't have code at hand to test if the
fix works as expected. We should also double check that this will not
break other paths which use the sk->sk_bound_dev_if with a different
semantic:

$ grep -R sk_bound_dev_if net/ | wc -l
125
$ grep -R 'sk_bound_dev_if = ' net/
net/ieee802154/raw.c:   sk->sk_bound_dev_if = dev->ifindex;
net/core/sock.c:        sk->sk_bound_dev_if = index;
net/ipv6/datagram.c:    sk->sk_bound_dev_if = usin->sin6_scope_id;
net/ipv6/datagram.c:    sk->sk_bound_dev_if = np->mcast_oif;
net/ipv6/af_inet6.c:    sk->sk_bound_dev_if = addr->sin6_scope_id;
net/ipv6/tcp_ipv6.c:    sk->sk_bound_dev_if = usin->sin6_scope_id;
net/ipv6/tcp_ipv6.c:    newsk->sk_bound_dev_if = treq->iif;
net/ipv6/raw.c:         sk->sk_bound_dev_if = addr->sin6_scope_id;
net/sctp/socket.c:      newsk->sk_bound_dev_if = sk->sk_bound_dev_if;
net/ipv4/ip_output.c:   sk->sk_bound_dev_if = arg->bound_dev_if;
net/ipv4/udp.c:         sk->sk_bound_dev_if = 0;
net/dccp/ipv6.c:        newsk->sk_bound_dev_if = ireq6->iif;
net/dccp/ipv6.c:        sk->sk_bound_dev_if = usin->sin6_scope_id;

Cheers,

a+
