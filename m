From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.6+, gre+ipsec+forwarding = IP fragmentation broken
Date: Fri, 15 Mar 2013 13:38:20 +0200
Message-ID: <20130315133820.006a42f6@vostro>
References: <20130313171453.0297f179@vostro>
	<20130315112516.4b1651ca@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:59058 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab3COLhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 07:37:41 -0400
Received: by mail-ee0-f53.google.com with SMTP id e53so1495305eek.26
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 04:37:40 -0700 (PDT)
In-Reply-To: <20130315112516.4b1651ca@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Mar 2013 11:25:16 +0200
Timo Teras <timo.teras@iki.fi> wrote:

> On Wed, 13 Mar 2013 17:14:53 +0200
> Timo Teras <timo.teras@iki.fi> wrote:
> 
> > In the typical DMVPN setup with IPv4-ESP-GRE-IPv4 stack, it seems
> > that IPv4 fragmentation got broke around 3.6 for forwarded packets.
> > 
> > It would seem that fragmentation works for locally generated
> > packets. Also PMTU (DF set) seems to work for both forwarded and
> > locally generated packets. But forwarded packets to gre device that
> > gets IPsec encrypted do not get fragmented properly.
> > 
> > 3.4.x kernels work, 3.6 and 3.8 series tested and fail similarly.
> 
> Actually 3.4.x vanilla does not work. It works only with 38d523e
> "ipv4: Remove output route check in ipv4_mtu" applied which I've been
> cherry-picking to my builds.
> 
> > I was going through the changelog and it seems that MTU is now
> > handled in nexthop exceptions and one needs to produce the full
> > flow info to update it. I'm wonding if this does not hold true in
> > my code path as ip_gre rewraps the forwarded packet and creates new
> > IP header - when it next goes to the xfrm code (which sends the
> > ICMP error) the inner iphdr is no longer accessible. Would this
> > cause the breakage that I'm seeing? Or the forward flow's mtu still
> > updated somehow?
> 
> I have now a theory on what goes wrong.
> 
> My gre tunnel is configured with 'ttl 64' so the tunnel IP header
> always gets DF bit set to do proper path-mtu. The kind of locally
> generated ICMP messages I get, imply that re-fragmentation happens
> only on the tunnel's IPv4 header level - but it'll be too late then:
> the large packet is queued, IPsec'ed and it is the IPsec'ed packet
> that gets is tried to be fragmented (but it has DF set so it fails and
> packet is dropped).
> 
> I believe ip_gre should explicitly fragment the inner IPv4 and IPv6
> packets if the tunnel's ttl is not inherited (resulting in DF bit set
> in the tunnel's IPv4 header).
> 
> So basically ip_gre worked wrong all along - things just happened to
> work due to GRO/GSO not implemented in ip_gre, and the way (the now
> deleted) routing cache exposed pmtu.
> 
> Does this make sense?

Not really. Seems the fragmentation should happen already on the
earlier dst level. Though, this implies that GSO cannot be used in
ip_gre if ttl != inherit.

I added some ip_gre debugging and the following seems to happen:

- the mtu is calculated correctly on xmit path:
  dst_mtu(&rt->dst) = 1458 (the tunnel's XFRMed IPv4 path)

- skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
  is called with mtu=1430, which seems correct

- dst_mtu(skb_dst(skb)) seems to still return after above call the
  value 1472 which is wrong. so update_pmtu is not working.

- skb->dev->ifindex implies skb->dev points to gre device when
  update_pmtu is being called (and not the ethX from which the packet
  was received), so ip_rt_update_pmtu() which eventually calls
  build_skb_flow_key() is likely using wrong ifindex for the flow


- Timo
