From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: IP-less bridge as a martian source
Date: Sun, 02 Nov 2008 00:55:56 +0100
Message-ID: <877i7novar.fsf@szonett.ki.iif.hu>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu>
	<48FF614C.7020507@gmail.com> <48FF7AA3.50408@gmail.com>
	<87y707mjbi.fsf@tac.ki.iif.hu> <20081031084124.GA4364@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lipton.aai.niif.hu ([193.225.14.195]:47621 "EHLO
	lipton.aai.niif.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbYKBAcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 20:32:41 -0400
In-Reply-To: <20081031084124.GA4364@ff.dom.local> (Jarek Poplawski's message
	of "Fri, 31 Oct 2008 08:41:24 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> On Wed, Oct 29, 2008 at 05:56:17PM +0100, Ferenc Wagner wrote:
>
>> Jarek Poplawski <jarkao2@gmail.com> writes:
>> 
>>>>> Ferenc Wagner <wferi@niif.hu> writes:
>>>>>
>>>>>> I expected an IP-less bridge interface to pick up no IP
>>>>>> packets, but apparently this isn't the case: broadcast packets
>>>>>> with destination address 255.255.255.255 are reported as
>>>>>> martians by the 2.6.18 kernel, which I find counterintuitive (I
>>>>>> know 2.6.18 is rather old, but that's the one supported by Xen).
>>>>>>
>>>>>>   1. Is this the expected behaviour?
>>>
>>> with IP disabled you shouldn't have any martians!
>> 
>> In my case, the bridge itself (?) has no IP addresses assigned, but
>> an other interface (which isn't a bridge port) does have.  In other
>> words, the only network interface of the host is a bond interface
>> aggregating the two physical Ethernet interfaces; the two IP
>> addresses of the host are assigned to this bond0.
>> 
>> bond0 is also the raw interface of several .1q VLAN interfaces,
>> which are ports of bridges (there is one bridge for each VLAN but
>> the native above).  The other ports of the bridges are the virtual
>> interfaces of the Xen guests running on this host.  If I run ping
>> -b 255.255.255.255 on one such guest, that gives a "martian source
>> 255.255.255.255" warning on the given bridge.  Even though
>> 255.255.255.255 is the destination address of that ping packet...
>> 
>> And this happens on 2.6.26.6, too.  Can't it come from
>> ip_mkroute_input instead of ip_route_input_slow?
>
> I doubt it.
>
> 1941 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> 1942                                u8 tos, struct net_device *dev)
> 1943 {
> ...
> 1963         /* IP on this device is disabled. */
> 1964
> 1965         if (!in_dev)
> 1966                 goto out;
> 1967
> 1968         /* Check for the most weird martians, which can be not detected
> 1969            by fib_lookup.
> 1970          */
> 1971
> 1972         if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
> 1973             ipv4_is_loopback(saddr))
> 1974                 goto martian_source;
> 1975
> 1976         if (daddr == htonl(0xFFFFFFFF) || (saddr == 0 && daddr == 0))
> 1977                 goto brd_input;
>
> This means that even with IP enabled device ip_mkroute_input() should
> be skipped. So it seems it's not about 255.255.255.255 generally, but
> just about source address. You didn't give any examples of these
> warnings, but I guess it's not a 0 address which is most popular with
> 255.255.255.255.

Indeed not, sorry.  If I ping -b 255.255.255.255 on a virtual machine
with IP 193.225.14.155, whose virtual interface is a port of br891:

martian source 255.255.255.255 from 193.225.14.155, on dev br891

> And, if there is some network address we have a problem: AFAIK this
> 255.255.255.255 broadcast is special, and it shouldn't be routed to
> other networks. Your host doesn't seem to recognize this network, so
> it shouldn't happen on this interface. So it seems, you expect the
> bridge behavior where it's 2 in 1 (bridge + IP host).

Yes, this machine is an IP host (SSH access is needed) in a private
subnet (10.253.2/24) and also bridges traffic belonging to other
subnets (like for example the above).  It is not a router, though, so
it knows nothing about the bridged subnets.  Actually, it should be
totally separated from those, that's why I was alarmed by the martian
warnings: these "limited broadcast" (255.255.255.255, not routed, as
you note) addressed packets could reach the bridge!

> I'm not sure there is "right" solution for this with any model, but
> I can miss something - then more details are needed. Otherwise,
> maybe you should simply consider turning off log_martians on these
> devices.

I could, but I'm more than a little worried that I don't understand
this stuff I'm expected to manage.  That's why I brought up the issue
here.  rp_filter is already enabled on all interfaces.  Do you think
it already ensures the separation I'm after, and all that's left is to
disable log_martians?
-- 
Thanks,
Feri.

Ps: If so, then I'd suggest placing the martian warning after
rp_filter, so that it doesn't warn about packets which get dropped
anyway, if possible.  Also, flipping the addresses in the martian
warning text would reduce confusion.  As it is, it suggests (English
is a foreign language for me, mind you) that 255.255.255.255 is the
problematic "martian source", while it's just a random destination
address in fact.
