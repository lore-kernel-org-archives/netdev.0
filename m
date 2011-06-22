From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Wed, 22 Jun 2011 13:02:19 +0200
Message-ID: <20110622110219.GF6489@secunet.com>
References: <20110606085247.GE31505@secunet.com>
 <1307423217.2642.59.camel@edumazet-laptop>
 <20110608053020.GA6489@secunet.com>
 <20110609.144704.1705676110990397845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48270 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab1FVLCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 07:02:15 -0400
Content-Disposition: inline
In-Reply-To: <20110609.144704.1705676110990397845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 02:47:04PM -0700, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 8 Jun 2011 07:30:20 +0200
> 
> > In between I can confirm that we get the slowpath problem back with my
> > patch, so we still have a bug somewhere. Reverting your commit would
> > be just a band aid. I think it is better to find the bug and do a real
> > fix instead. Unfortunatly I fear I'm not able to track it down before
> > my vacation that starts tomorrow. I'll continue to work at it once I'm
> > back...
> 
> Thanks Steffen, looking forward to this.

In between I found the problem. In ip_setup_cork() we take the mtu on the
base of dst_mtu(rt->dst.path) and assign it to cork->fragsize which is
used as the mtu in __ip_append_data(). The path dst_entry is a routing
dst_entry that does not take the IPsec header and trailer overhead into
account. So if we build an IPsec packet based on this mtu it might be to
big after the IPsec transformations are applied. If we take the actual
IPsec mtu from dst_mtu(&rt->dst) and adapt the exthdr handling to this,
it works as expected. So I'll send two patches, one that reverts Eric's
patch and one that fixes the slowpath issue.

While reading through the code of __ip_append_data() I noticed that we
might use ip_ufo_append_data() for packets that will be IPsec transformed
later, is this ok? I don't know how ufo handling works, but I would guess
that it expects an udp header and not an IPsec header as the packets
transport header.

I found another funny thing when I tested my patches:

I use an IPsec tunnel with tunnel endpoints 192.168.1.1 and 192.168.1.2

Then I do at 192.168.1.2

ping -c20 -M do -s 1500 192.168.1.1

PING 192.168.1.1 (192.168.1.1) 1500(1528) bytes of data.
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1438)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1438)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1374)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1310)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1246)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1182)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1118)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 1054)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 990)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 926)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 862)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 798)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 734)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 670)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 606)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 552)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 494)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 494)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 494)
>From 192.168.1.1 icmp_seq=1 Frag needed and DF set (mtu = 494)

--- 192.168.1.1 ping statistics ---
0 packets transmitted, 0 received, +20 errors

These packets are locally generated and not from 192.168.1.1 as they
claim to be. I think the problem is the following:

The IPsec mtu is 1438 here, so the first packet is too big.
xfrm4_tunnel_check_size() notices this and sends a ICMP_FRAG_NEEDED
packet that announces a mtu of 1438 to the original sender of the ping
packet. Unfortunately the sender is a local address, it's the IPsec
tunnel entry point. So we update the mtu for this connection to 1438.
Now, with the next packet xfrm_bundle_ok() notices that the path mtu has
changed, so it subtracts the IPsec overhead from the mtu a second time
and we end up with a mtu of 1374. This game goes until we reach a minimal
mtu of 494.

Unfortunately I don't know how to fix this. Any ideas?

