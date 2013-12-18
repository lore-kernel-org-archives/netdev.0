From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Thu, 19 Dec 2013 00:54:15 +0100
Message-ID: <20131218235415.GE3505@order.stressinduktion.org>
References: <20131215022336.GA27866@order.stressinduktion.org> <20131218.173442.336109133942416102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37888 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab3LRXyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 18:54:17 -0500
Content-Disposition: inline
In-Reply-To: <20131218.173442.336109133942416102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 05:34:42PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sun, 15 Dec 2013 03:23:36 +0100
> 
> > While forwarding we should not use the protocol path mtu to calculate
> > the mtu for a forwarded packet but instead use the interface mtu.
> > 
> > We mark forwarded skbs in ip_forward with IPSKB_FORWARDED which was
> > introduced for multicast forwarding. But as it does not conflict with
> > our usage in unicast code path it is perfect for reuse.
> > 
> > I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
> > along with the new ip_dst_mtu_secure to net/ip.h to fix circular
> > dependencies because of IPSKB_FORWARDED.
> > 
> > Because someone might have written a software which does probe
> > destinations manually and expects the kernel to honour those path mtus
> > I introduced a new per-namespace "forwarding_uses_pmtu" knob so someone
> > can disable this new behaviour. We also use mtus which are locked on a
> > route for forwarding.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: David Miller <davem@davemloft.net>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Sockets aren't the only entity that create cached PMTU information
> we might like to use during forwarding, tunnels do too.

I had tunnels in mind and they specifically clear IPCB bits when
reinserting the skb into the output functions. So they would get the
non-secure dst_mtu and honour the pmtu data.

Another patch I am currently preparing deals with xt_MSS, which I have
still to test.

> I'm afraid what the side effects of this change will be in that
> situation, because the dst_mtu() is exactly what will allow us
> to relay the ICMP back to the pre-decapsulation source address
> properly.
> 
> In any event, this code was made to explicitly behave this way
> back in 2007 by John Heffner, maybe he has some opinions too.

I doubt that it is the right thing to do, as currently one can easily
bring a router to fragment all packets along one path. E.g. icmp_err
handler lets one easily insert pmtu information for arbitary destinations
(as long as they pass uRPF check).

Thanks for looking after the original change and add the Cc. I thought
it was the original behaviour since the code was implemented.

Btw. this is my ongoing work to try to reduce possible sources of
fragmentation as one can expect that the 16 bit fragmentation id is not
secure enough.

Thanks,

  Hannes
