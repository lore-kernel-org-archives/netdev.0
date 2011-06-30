From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Thu, 30 Jun 2011 11:06:23 +0200
Message-ID: <20110630090623.GA13201@secunet.com>
References: <20110608053020.GA6489@secunet.com>
 <20110609.144704.1705676110990397845.davem@davemloft.net>
 <20110622110219.GF6489@secunet.com>
 <20110627.203938.1899202479649578621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57165 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab1F3JFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 05:05:46 -0400
Content-Disposition: inline
In-Reply-To: <20110627.203938.1899202479649578621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2011 at 08:39:38PM -0700, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 22 Jun 2011 13:02:19 +0200
> 
> > While reading through the code of __ip_append_data() I noticed that we
> > might use ip_ufo_append_data() for packets that will be IPsec transformed
> > later, is this ok? I don't know how ufo handling works, but I would guess
> > that it expects an udp header and not an IPsec header as the packets
> > transport header.
> 
> Indeed, it could be a real problem.

Ok, so I'll send a patch to fix it up.

> 
> > The IPsec mtu is 1438 here, so the first packet is too big.
> > xfrm4_tunnel_check_size() notices this and sends a ICMP_FRAG_NEEDED
> > packet that announces a mtu of 1438 to the original sender of the ping
> > packet. Unfortunately the sender is a local address, it's the IPsec
> > tunnel entry point. So we update the mtu for this connection to 1438.
> > Now, with the next packet xfrm_bundle_ok() notices that the path mtu has
> > changed, so it subtracts the IPsec overhead from the mtu a second time
> > and we end up with a mtu of 1374. This game goes until we reach a minimal
> > mtu of 494.
> > 
> > Unfortunately I don't know how to fix this. Any ideas?
> 
> If the generic PMTU handling in net/ipv4/route.c is adjusting the MTU
> for the IPSEC path's route, that would be the problem.
> 

Yes, this is exactly what happens. We use icmp_send() to notify about
message size errors even for locally generated packets, this leads to
an incorrect pmtu update. Changing this to use ip_local_error() if we
have socket context fixes the problem. I'll send a patch for this too.

