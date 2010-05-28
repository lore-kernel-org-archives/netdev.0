From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Sat, 29 May 2010 03:40:55 +0900
Message-ID: <4C000E37.7080306@linux-ipv6.org>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>	<8739xdqsuz.fsf@small.ssi.corp> <4BFECA65.7030102@hp.com> <87sk5d2h4u.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Scott Otto <scott.otto@alcatel-lucent.com>,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48614 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752137Ab0E1Slg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 14:41:36 -0400
In-Reply-To: <87sk5d2h4u.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2010/05/28 6:01), Arnaud Ebalard wrote:
> Hi,
>
> Brian Haley<brian.haley@hp.com>  writes:
>
>>> In previous debug outputs, the content of the fl->oif is ok, i.e. it is
>>> set to the interface on which the CoA is configured, i.e. the output
>>> interface. But the commit results in flags |= RT6_LOOKUP_F_IFACE.
>>> Later, in rt6_score_route(), the call to rt6_check_dev() returns 0
>>> (dev->ifindex is ip6tnl1 but oif is wlan0). Because of the change to flags
>>> flags, we quickly return -1 in rt6_score_route():
>>
>> Ok, so the call to ip6_route_output() was from the tunnel code, which is
>> using it's cached flowi, which has oif set to the tunnel.  The XFRM code
>> swaps the addresses, which should invalidate the oif, but it doesn't.
>>
>>> static int rt6_score_route(struct rt6_info *rt, int oif,
>>> 			   int strict)
>>> {
>>> 	int m, n;
>>>
>>> 	m = rt6_check_dev(rt, oif);
>>> 	if (!m&&  (strict&  RT6_LOOKUP_F_IFACE))
>>>                  return -1;
>>>          ...
>>>
>>> Now, I wonder if the following is correct. Don't hesitate to correct me
>>> if I am wrong:
>>>
>>> Initially (before f4f914b58019f0), the purpose of the test using
>>> rt6_need_strict() in ip6_route_output() (introduced by c71099ac) was to
>>> allow the multiple routing table logic to be applied to all global
>>> addresses but to preserve the addresses for which it would not make
>>> sense (link-local, multicast, ). The change introduced by f4f914b58019f0
>>> basically reduces the ability to route traffic as you want and forces
>>> the traffic to leave the device by the interface on which it is
>>> configured (if fl->oif is set).
>>
>> The problem is we assumed the caller's would only set fl->oif if they
>> wanted it enforced (multicast, link-local, SO_BINDTODEVICE), but it
>> didn't take into account the tunnel code.  I guess the easy answer
>> would be to revert this until we can fix it correctly.
>
> Nothing against it but maybe Jiri or David have other ideas.
>
>
>>>  From my (very limited and possibly wrong) understanding, the change
>>> introduced by f4f914b58019f0 looks like a workaround for the
>>> SO_BINDTODEVICE issue. Looking at the code, there is something I don't
>>> understand: if SO_BINDTODEVICE has been used on a socket, the socket
>>> should have its sk_bound_dev_if attribute set to the correct ifindex
>>> value. Hence the following (naive) question: why is that information not
>>> used to inflect the selection of the route cached for the socket? And
>>> why would the fix be at the adress level instead of being at the
>>> interface level (ifindex)?
>>
>> I guess I always believed setting SO_BINDTODEVICE should always force
>> traffic out that interface, but from Yoshifuji's email it seems that
>> maybe wasn't the intention, at least for things that don't meet
>> the rt_need_strict() criteria like globals.  I don't know the history
>> behind the setsockopt.
>
> The behavior I would expect from a combination of RFC 4191 and
> SO_BINDTODEVICE sockopt would be the use of the interface as outgoing
> interface and then the use of the best router (using router preference
> info, reachability, ...) available on the subnet. IIRC, the router
> preference info is per default router list in the RFC, i.e. per
> interface.

Good point.

Whatever our original intention/thought was,
current RFC says that we should honor outgoing interface
specified by user (by IPV6_PKTINFO etc.), as we do for
SO_BINDTODEVICE in IPv4 as well.

In this sense, checking sk->sk_bound_dev_if in
ip6_route_output() is not enough because we need to
take outgoing interface specified in ancillary data
into account, which is set to fl->oif.

How about adding additional "flags" parameter
for ip6_route_output()?

Thoughts?

--yoshfuji
