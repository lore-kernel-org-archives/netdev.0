From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Mon, 27 Jun 2011 20:39:38 -0700 (PDT)
Message-ID: <20110627.203938.1899202479649578621.davem@davemloft.net>
References: <20110608053020.GA6489@secunet.com>
	<20110609.144704.1705676110990397845.davem@davemloft.net>
	<20110622110219.GF6489@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756408Ab1F1Dj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 23:39:58 -0400
In-Reply-To: <20110622110219.GF6489@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 22 Jun 2011 13:02:19 +0200

> In between I found the problem. In ip_setup_cork() we take the mtu on the
> base of dst_mtu(rt->dst.path) and assign it to cork->fragsize which is
> used as the mtu in __ip_append_data(). The path dst_entry is a routing
> dst_entry that does not take the IPsec header and trailer overhead into
> account. So if we build an IPsec packet based on this mtu it might be to
> big after the IPsec transformations are applied. If we take the actual
> IPsec mtu from dst_mtu(&rt->dst) and adapt the exthdr handling to this,
> it works as expected. So I'll send two patches, one that reverts Eric's
> patch and one that fixes the slowpath issue.

Thanks for doing this work Steffen.

> While reading through the code of __ip_append_data() I noticed that we
> might use ip_ufo_append_data() for packets that will be IPsec transformed
> later, is this ok? I don't know how ufo handling works, but I would guess
> that it expects an udp header and not an IPsec header as the packets
> transport header.

Indeed, it could be a real problem.

> The IPsec mtu is 1438 here, so the first packet is too big.
> xfrm4_tunnel_check_size() notices this and sends a ICMP_FRAG_NEEDED
> packet that announces a mtu of 1438 to the original sender of the ping
> packet. Unfortunately the sender is a local address, it's the IPsec
> tunnel entry point. So we update the mtu for this connection to 1438.
> Now, with the next packet xfrm_bundle_ok() notices that the path mtu has
> changed, so it subtracts the IPsec overhead from the mtu a second time
> and we end up with a mtu of 1374. This game goes until we reach a minimal
> mtu of 494.
> 
> Unfortunately I don't know how to fix this. Any ideas?

If the generic PMTU handling in net/ipv4/route.c is adjusting the MTU
for the IPSEC path's route, that would be the problem.

In the case of IPSEC encapsulation, tunnels, and similar, only the
tunnel or the XFRM layer should be processing the PMTU notification.
