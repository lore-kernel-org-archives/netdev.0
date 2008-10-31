From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IP-less bridge as a martian source
Date: Fri, 31 Oct 2008 08:41:24 +0000
Message-ID: <20081031084124.GA4364@ff.dom.local>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu> <48FF614C.7020507@gmail.com> <48FF7AA3.50408@gmail.com> <87y707mjbi.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:22978 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbYJaIlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 04:41:31 -0400
Received: by ug-out-1314.google.com with SMTP id 39so1168704ugf.37
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 01:41:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87y707mjbi.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 05:56:17PM +0100, Ferenc Wagner wrote:
> Jarek Poplawski <jarkao2@gmail.com> writes:
> 
> > Jarek Poplawski wrote, On 10/22/2008 07:22 PM:
> >
> >> Ferenc Wagner wrote, On 10/22/2008 05:00 PM:
> >> 
> >>> Ferenc Wagner <wferi@niif.hu> writes:
> >>>
> >>>> I expected an IP-less bridge interface to pick up no IP packets, but
> >>>> apparently this isn't the case: broadcast packets with destination
> >>>> address 255.255.255.255 are reported as martians by the 2.6.18
> >>>> kernel, which I find counterintuitive (I know 2.6.18 is rather old,
> >>>> but that's the one supported by Xen).
> >>>>
> >>>>   1. Is this the expected behaviour?
> >> 
> >> I think so, and this thread pertains to something similar:
> >> http://marc.info/?l=linux-netdev&m=122456602708727&w=2
> >
> > Sorry! I didn't check this before writing. This:
> >
> > 1941 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> > 1942                                u8 tos, struct net_device *dev)
> > 1943 {
> > ...
> > 1963         /* IP on this device is disabled. */
> > 1964
> > 1965         if (!in_dev)
> > 1966                 goto out;
> > 1967
> > 1968         /* Check for the most weird martians, which can be not detected
> > 1969            by fib_lookup.
> > 1970          */
> >
> > means something else, so with IP disabled you shouldn't have any martians!
> > (And this is old code.)
> 
> Hi Jarek,
> 
> Thanks for your comments.  To tell the truth, I'm quite confused about
> the host-based addressing model.  If the addresses belong to the host,
> then why do we add them to interfaces?

Hi Ferenc,

This model is disputable, but it seems to me "your" martians could be
more complex matter yet...

> 
> In my case, the bridge itself (?) has no IP addresses assigned, but
> an other interface (which isn't a bridge port) does have.  In other
> words, the only network interface of the host is a bond interface
> aggregating the two physical Ethernet interfaces; the two IP addresses
> of the host are assigned to this bond0.
> 
> bond0 is also the raw interface of several .1q VLAN interfaces, which
> are ports of bridges (there is one bridge for each VLAN but the native
> above).  The other ports of the bridges are the virtual interfaces of
> the Xen guests running on this host.  If I run ping -b 255.255.255.255
> on one such guest, that gives a "martian source 255.255.255.255"
> warning on the given bridge.  Even though 255.255.255.255 is the
> destination address of that ping packet...
> 
> And this happens on 2.6.26.6, too.  Can't it come from
> ip_mkroute_input instead of ip_route_input_slow?

I doubt it.

1941 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
1942                                u8 tos, struct net_device *dev)
1943 {
...
1963         /* IP on this device is disabled. */
1964
1965         if (!in_dev)
1966                 goto out;
1967
1968         /* Check for the most weird martians, which can be not detected
1969            by fib_lookup.
1970          */
1971
1972         if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
1973             ipv4_is_loopback(saddr))
1974                 goto martian_source;
1975
1976         if (daddr == htonl(0xFFFFFFFF) || (saddr == 0 && daddr == 0))
1977                 goto brd_input;

This means that even with IP enabled device ip_mkroute_input() should
be skipped. So it seems it's not about 255.255.255.255 generally, but
just about source address. You didn't give any examples of these
warnings, but I guess it's not a 0 address which is most popular with
255.255.255.255.

And, if there is some network address we have a problem: AFAIK this
255.255.255.255 broadcast is special, and it shouldn't be routed to
other networks. Your host doesn't seem to recognize this network, so
it shouldn't happen on this interface. So it seems, you expect the
bridge behavior where it's 2 in 1 (bridge + IP host).

I'm not sure there is "right" solution for this with any model, but
I can miss something - then more details are needed. Otherwise,
maybe you should simply consider turning off log_martians on these
devices.

Regards,
Jarek P.
