From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.6+, gre+ipsec+forwarding = IP fragmentation broken
Date: Fri, 15 Mar 2013 11:25:16 +0200
Message-ID: <20130315112516.4b1651ca@vostro>
References: <20130313171453.0297f179@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:64556 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab3COJYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 05:24:38 -0400
Received: by mail-ea0-f175.google.com with SMTP id o10so1400630eaj.20
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 02:24:36 -0700 (PDT)
In-Reply-To: <20130313171453.0297f179@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Mar 2013 17:14:53 +0200
Timo Teras <timo.teras@iki.fi> wrote:

> In the typical DMVPN setup with IPv4-ESP-GRE-IPv4 stack, it seems that
> IPv4 fragmentation got broke around 3.6 for forwarded packets.
> 
> It would seem that fragmentation works for locally generated packets.
> Also PMTU (DF set) seems to work for both forwarded and locally
> generated packets. But forwarded packets to gre device that gets IPsec
> encrypted do not get fragmented properly.
> 
> 3.4.x kernels work, 3.6 and 3.8 series tested and fail similarly.

Actually 3.4.x vanilla does not work. It works only with 38d523e "ipv4:
Remove output route check in ipv4_mtu" applied which I've been
cherry-picking to my builds.

> I was going through the changelog and it seems that MTU is now handled
> in nexthop exceptions and one needs to produce the full flow info to
> update it. I'm wonding if this does not hold true in my code path as
> ip_gre rewraps the forwarded packet and creates new IP header - when
> it next goes to the xfrm code (which sends the ICMP error) the inner
> iphdr is no longer accessible. Would this cause the breakage that I'm
> seeing? Or the forward flow's mtu still updated somehow?

I have now a theory on what goes wrong.

My gre tunnel is configured with 'ttl 64' so the tunnel IP header
always gets DF bit set to do proper path-mtu. The kind of locally
generated ICMP messages I get, imply that re-fragmentation happens only
on the tunnel's IPv4 header level - but it'll be too late then: the
large packet is queued, IPsec'ed and it is the IPsec'ed packet that
gets is tried to be fragmented (but it has DF set so it fails and
packet is dropped).

I believe ip_gre should explicitly fragment the inner IPv4 and IPv6
packets if the tunnel's ttl is not inherited (resulting in DF bit set
in the tunnel's IPv4 header).

So basically ip_gre worked wrong all along - things just happened to
work due to GRO/GSO not implemented in ip_gre, and the way (the now
deleted) routing cache exposed pmtu.

Does this make sense?

- Timo
