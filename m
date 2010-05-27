From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Thu, 27 May 2010 17:14:44 +0200
Message-ID: <8739xdqsuz.fsf@small.ssi.corp>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>
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
Received: from copper.chdir.org ([88.191.97.87]:46918 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750904Ab0E0PPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 11:15:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks for your reply Brian and sorry for the length of this response. If
Hideaki and David can comment on the IPv6/XFRM and SO_BINDTODEVICE
aspects discussed below that would be helpful, IMHO.

Brian Haley <brian.haley@hp.com> writes:

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

When it's not 0, fl->oif is a sane value: it is set to the index of the
interface on which the current *Care-of Address* is configured. All the
traffic is expected to leave the host via this interface. 

> The other thought is that it's the tunnel code calling it, as it's going
> to set 'oif' (actually it caches a whole flowi) from the tunnel parms ifindex/link
> value.  It could have been setting it forever, but ip6_route_output() just
> never enforced it until now.

I added some printk in the code of ip6_route_output(), rt6_score_route()
and find_rr_leaf(). Below are respectivevly what I get for a 2.6.34 with
and without f4f914b58019f0e50d521bbbadfaee260d766f95. I removed the
beginning as it is the same and only started when it starts diverging.:

...
ip6_route_output() called from ip6_dst_lookup_tail() 1
ip6_route_output: fl->oif is wlan0
2001:XXXX:XXXX:0002:020d:93ff:fe55:f897 (HoA) => 2001:XXXX:XXXX:f002:021e:0bff:fe4e:04b5 (HA@) proto 135
rt6_score_route: oif is wlan0. rt->rt6i_dev->ifindex: lo. Leaving due to strict.
rt6_score_route: oif is wlan0. rt->rt6i_dev->ifindex: lo. Leaving due to strict.
rt6_score_route: oif is wlan0. rt->rt6i_dev->ifindex: ip6tnl1. Leaving due to strict.
rt6_score_route: oif is wlan0. rt->rt6i_dev->ifindex: ip6tnl1. Leaving due to strict.
...

On a working kernel:

...
ip6_route_output() called from ip6_dst_lookup_tail() 1
ip6_route_output: fl->oif is wlan0
2001:XXXX:XXXX:0002:020d:93ff:fe55:f897 (HoA) => 2001:XXXX:XXXX:f002:021e:0bff:fe4e:04b5 (HA@) proto 135
find_rr_leaf: match is 1. oif is wlan0
find_rr_leaf: match is 1. oif is wlan0
find_rr_leaf: match is 8. oif is wlan0
ip6_route_output() called from ip6_dst_lookup_tail() 1
ip6_route_output: fl->oif is 0
...

Above, a Binding Update message (a Mobility Header (proto 135) type 5)
has to be sent to the Home Agent. It is expected to leave the system via
the wlan0 interface, which is the interface on which the Care-of Address
of the packet is configured. The *wire* format of the packet is the
following:   

 IPv6(src=CoA, dst=HA@)/DestOpt(HoA)/ESP()/MH(type=5)

The addition of Destination Option header (containing a Home Address
Option) and ESP extension header is performed via XFRM. Initially, the
packet created by userland looks like this:

 IPv6(src=HoA, dst=HA@)/MH(type=5)

In previous debug outputs, the content of the fl->oif is ok, i.e. it is
set to the interface on which the CoA is configured, i.e. the output
interface. But the commit results in flags |= RT6_LOOKUP_F_IFACE.
Later, in rt6_score_route(), the call to rt6_check_dev() returns 0
(dev->ifindex is ip6tnl1 but oif is wlan0). Because of the change to flags 
flags, we quickly return -1 in rt6_score_route():

static int rt6_score_route(struct rt6_info *rt, int oif,
			   int strict)
{
	int m, n;

	m = rt6_check_dev(rt, oif);
	if (!m && (strict & RT6_LOOKUP_F_IFACE))
                return -1;
        ...

Now, I wonder if the following is correct. Don't hesitate to correct me
if I am wrong:

Initially (before f4f914b58019f0), the purpose of the test using
rt6_need_strict() in ip6_route_output() (introduced by c71099ac) was to
allow the multiple routing table logic to be applied to all global
addresses but to preserve the addresses for which it would not make
sense (link-local, multicast, ). The change introduced by f4f914b58019f0
basically reduces the ability to route traffic as you want and forces
the traffic to leave the device by the interface on which it is
configured (if fl->oif is set). 

>From my (very limited and possibly wrong) understanding, the change
introduced by f4f914b58019f0 looks like a workaround for the 
SO_BINDTODEVICE issue. Looking at the code, there is something I don't
understand: if SO_BINDTODEVICE has been used on a socket, the socket
should have its sk_bound_dev_if attribute set to the correct ifindex
value. Hence the following (naive) question: why is that information not
used to inflect the selection of the route cached for the socket? And
why would the fix be at the adress level instead of being at the
interface level (ifindex)?

Cheers,

a+
