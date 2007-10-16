From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/12] [IPSEC]: Remove xfrmX_tunnel_check_size
Date: Tue, 16 Oct 2007 16:38:04 +0200
Message-ID: <4714CCCC.2040504@trash.net>
References: <20071016141843.GA11956@gondor.apana.org.au> <E1IhnHJ-0003A4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42967 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925AbXJPOiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:38:24 -0400
In-Reply-To: <E1IhnHJ-0003A4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> [IPSEC]: Remove xfrmX_tunnel_check_size
> 
> These functions have always been causing trouble by sending ICMP errors
> back to the local host which was totally confused about how to deal with
> it and most often ended up causing a downward spiral which only finishes
> when the MTU is so small that you can't send packets out anymore.
> 
> They're also wrong now that we have inter-family transforms.  They'll
> end up trying to shove an IPv4 packet into the IPv6 ICMP stack and vice
> versa.
> 
> In fact, I've just realised that they are totally unnecessary.  The reason
> is that whoever calls us should have already checked the MTU.  In particular,
> there are two cases:
> 
> 1) The packet is forwarded in which case the forwarding function would've
> performed the check.
> 
> 2) The packet is local in which case whoever generated it should've checked.
> If they didn't check then us sending back an ICMP error wouldn't do any good
> anyway since the next time they transmit they'll still get it wrong.
> 
> So the only time this function has an effect is when the MTU happens to
> change between the caller checking it and us checking it.  This is useless
> because if we did catch such a change there's nothing stopping a further
> MTU change between us checking it and the packet actually getting to the
> device.


Thats true, but for the first case we actually have something in the
stack doing that, which is NAT and routing by fwmark. Maybe netfilter
should just send an ICMP error back, that would also solve the problem
of silently dropped packets when rerouting to an unreachable
destination.
