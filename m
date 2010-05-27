From: Scott C Otto <otts@alcatel-lucent.com>
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Thu, 27 May 2010 16:31:08 -0500
Message-ID: <4BFEE49C.8060301@lucent.com>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com> <8739xdqsuz.fsf@small.ssi.corp> <4BFECA65.7030102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail4.lucent.com ([135.245.0.39]:57394 "EHLO
	ihemail4.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757893Ab0E0VjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 17:39:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,
Thanks for looking into this.

The behavior of SO_BINDTODEVICE, certainly with IPV4, is to identify a specific
interface to use for sending/receiving AF_INET packets upon.   And that's how it
has behaved with IPV4.   Tools like ping, traceroute (and ping6, traceroute6)
make use of it with the -i (interface) options.

We ran into this issue when updating an IPV4 application to IPV6.   The report
provided one example of the issue.

The original change was based on the semantics of flowi.oif used in IPV4.  There
flowi.oif (as it is with IPV6 as well) is also set to sk->sk_bound_dev_if when
using ip_route_connect() and routing simply took a non-zero oif to enforce an
interface.  Looking at IPV4 tunneling, flowi.oif is set the same way from
tunnel's parms.link as with IPV6 so would follow those semantics as well.

Obviously, with IPV6, the semantics of flowi.oif are different and perhaps even
vary with the users of IPV6.

If that variability is desired, the proposed change from Brian (using
sk->sk_bound_dev_if) would be an equivalent means of supporting SO_BINDTODEVICE
while limiting the impact.

Scott

On 5/27/2010 2:39 PM, Brian Haley wrote:
> Hi Arnoud,
> 
> On 05/27/2010 11:14 AM, Arnaud Ebalard wrote:
> 
>>Hi,
>>
>>Thanks for your reply Brian and sorry for the length of this response. If
>>Hideaki and David can comment on the IPv6/XFRM and SO_BINDTODEVICE
>>aspects discussed below that would be helpful, IMHO.
> 
> 
> Thanks for all the analysis, comments below.
> 
> 
>>>On 05/26/2010 01:01 PM, Arnaud Ebalard wrote:
>>>
>>>>Hi,
>>>>
>>>>I just updated my laptop's kernel to 2.6.34 (previously running .33 and
>>>>configured to act as an IPsec/IKE-protected MIPv6 Mobile Node using
>>>>racoon and umip): after rebooting on the new kernel, the transport mode
>>>>SA protecting MIPv6 signaling traffic are missing.
>>>>
>>>>I bisected the issue down to f4f914b58019f0e50d521bbbadfaee260d766f95
>>>>(net: ipv6 bind to device issue) which was added after 2.6.34-rc5: 
>>>>
>>>>diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>>>index c2438e8..05ebd78 100644
>>>>--- a/net/ipv6/route.c
>>>>+++ b/net/ipv6/route.c
>>>>@@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>>>> {
>>>>        int flags = 0;
>>>> 
>>>>-       if (rt6_need_strict(&fl->fl6_dst))
>>>>+       if (fl->oif || rt6_need_strict(&fl->fl6_dst))
>>>>                flags |= RT6_LOOKUP_F_IFACE;
>>>
>>>Can you see if fl->oif is at least a sane value here?  Maybe there's some
>>>partially un-initialized flowi getting passed-in, a quick source code check
>>>didn't find anything obvious.
>>
>>When it's not 0, fl->oif is a sane value: it is set to the index of the
>>interface on which the current *Care-of Address* is configured. All the
>>traffic is expected to leave the host via this interface. 
> 
> 
> Ok, so it's not un-initialized data causing this.
> 
> 
>>In previous debug outputs, the content of the fl->oif is ok, i.e. it is
>>set to the interface on which the CoA is configured, i.e. the output
>>interface. But the commit results in flags |= RT6_LOOKUP_F_IFACE.
>>Later, in rt6_score_route(), the call to rt6_check_dev() returns 0
>>(dev->ifindex is ip6tnl1 but oif is wlan0). Because of the change to flags 
>>flags, we quickly return -1 in rt6_score_route():
> 
> 
> Ok, so the call to ip6_route_output() was from the tunnel code, which is
> using it's cached flowi, which has oif set to the tunnel.  The XFRM code
> swaps the addresses, which should invalidate the oif, but it doesn't.
> 
> 
>>static int rt6_score_route(struct rt6_info *rt, int oif,
>>			   int strict)
>>{
>>	int m, n;
>>
>>	m = rt6_check_dev(rt, oif);
>>	if (!m && (strict & RT6_LOOKUP_F_IFACE))
>>                return -1;
>>        ...
>>
>>Now, I wonder if the following is correct. Don't hesitate to correct me
>>if I am wrong:
>>
>>Initially (before f4f914b58019f0), the purpose of the test using
>>rt6_need_strict() in ip6_route_output() (introduced by c71099ac) was to
>>allow the multiple routing table logic to be applied to all global
>>addresses but to preserve the addresses for which it would not make
>>sense (link-local, multicast, ). The change introduced by f4f914b58019f0
>>basically reduces the ability to route traffic as you want and forces
>>the traffic to leave the device by the interface on which it is
>>configured (if fl->oif is set).
> 
> 
> The problem is we assumed the caller's would only set fl->oif if they
> wanted it enforced (multicast, link-local, SO_BINDTODEVICE), but it
> didn't take into account the tunnel code.  I guess the easy answer
> would be to revert this until we can fix it correctly.
> 
> 
>>From my (very limited and possibly wrong) understanding, the change
>>introduced by f4f914b58019f0 looks like a workaround for the 
>>SO_BINDTODEVICE issue. Looking at the code, there is something I don't
>>understand: if SO_BINDTODEVICE has been used on a socket, the socket
>>should have its sk_bound_dev_if attribute set to the correct ifindex
>>value. Hence the following (naive) question: why is that information not
>>used to inflect the selection of the route cached for the socket? And
>>why would the fix be at the adress level instead of being at the
>>interface level (ifindex)?
> 
> 
> I guess I always believed setting SO_BINDTODEVICE should always force
> traffic out that interface, but from Yoshifuji's email it seems that
> maybe wasn't the intention, at least for things that don't meet
> the rt_need_strict() criteria like globals.  I don't know the history
> behind the setsockopt.
> 
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


