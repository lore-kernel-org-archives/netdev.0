From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Fri, 28 May 2010 02:39:40 +0900
Message-ID: <4BFEAE5C.2080703@linux-ipv6.org>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Scott Otto <scott.otto@alcatel-lucent.com>,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46178 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753843Ab0E0Rjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 13:39:42 -0400
In-Reply-To: <4BFDC14F.6050407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Brian Haley wrote:
> On 05/26/2010 01:01 PM, Arnaud Ebalard wrote:
>> Hi,
>>
>> I just updated my laptop's kernel to 2.6.34 (previously running .33 and
>> configured to act as an IPsec/IKE-protected MIPv6 Mobile Node using
>> racoon and umip): after rebooting on the new kernel, the transport mode
>> SA protecting MIPv6 signaling traffic are missing.
>>
>> I bisected the issue down to f4f914b58019f0e50d521bbbadfaee260d766f95
>> (net: ipv6 bind to device issue) which was added after 2.6.34-rc5: 
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index c2438e8..05ebd78 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>>  {
>>         int flags = 0;
>>  
>> -       if (rt6_need_strict(&fl->fl6_dst))
>> +       if (fl->oif || rt6_need_strict(&fl->fl6_dst))
>>                 flags |= RT6_LOOKUP_F_IFACE;
> 
> Can you see if fl->oif is at least a sane value here?  Maybe there's some
> partially un-initialized flowi getting passed-in, a quick source code check
> didn't find anything obvious.
> 
> The other thought is that it's the tunnel code calling it, as it's going
> to set 'oif' (actually it caches a whole flowi) from the tunnel parms ifindex/link
> value.  It could have been setting it forever, but ip6_route_output() just
> never enforced it until now.

Well, I'd like to rethink the original bug report / fix.
There are several factors:

1) CONFIG_IPV6_ROUTER_PREF?
2) Is it host, or router?
3) next-hop reachability

If CONFIG_IPV6_ROUTER_PREF is enabled and the node is host,
and one nexthop has better reachability, the route is always
preferred even if upper layer specified specific interface.
If we do not like this behavior, we should change
rt6_score_route() not to return -1 something like this:

         n = rt6_check_neigh(rt);
         if (!n && (strict & RT6_LOOKUP_F_REACHABLE) && !oif)
                 return -1;

instead of ip6_route_output().

--yoshfuji
