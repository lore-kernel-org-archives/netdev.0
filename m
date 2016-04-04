From: Guus Sliepen <guus@tinc-vpn.org>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Mon, 4 Apr 2016 16:31:58 +0200
Message-ID: <20160404143158.GM3771@sliepen.org>
References: <57026C8F.8050406@valdikss.org.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org
To: ValdikSS <iam@valdikss.org.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arianus.sliepen.org ([92.243.30.131]:39139 "EHLO
	arianus.sliepen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914AbcDDOcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 10:32:01 -0400
Content-Disposition: inline
In-Reply-To: <57026C8F.8050406@valdikss.org.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 04:30:55PM +0300, ValdikSS wrote:

> I'm trying to increase OpenVPN throughput by optimizing tun manipulations, too.
> Right now I have more questions than answers.
> 
> I get about 800 Mbit/s speeds via OpenVPN with authentication and encryption disabled on a local machine with OpenVPN server and client running in a different
> network namespaces, which use veth for networking, with 1500 MTU on a TUN interface. This is rather limiting. Low-end devices like SOHO routers could only
> achieve 15-20 Mbit/s via OpenVPN with encryption with a 560 MHz CPU.
> Increasing MTU reduces overhead. You can get > 5GBit/s if you set 16000 MTU on a TUN interface.
> That's not only OpenVPN related. All the tunneling software I tried can't achieve gigabit speeds without encryption on my machine with MTU 1500. Didn't test
> tinc though.

It's exactly the same issue for tinc. But tinc does path MTU discovery,
and actively limits the size of packets inside the tunnel so that the
outer packets are not bigger than the PMTU. Of course this can be
disabled, but experience has shown that transmitting large UDP packets
over the Internet is not ideal, since they will be fragmented, and the
loss of one fragment means the whole packet is dropped. In the case of
OpenVPN, I think many users use -mssfix, so they too are in effect
limiting the size of packets inside the tunnel.

Of course, tinc could fragment packets internally (it actually does so
in some circumstances), but I'd rather avoid that.

Also, GSO and GRO only deal with optimizations within one UDP packet or
one TCP stream. If you have many concurrent programs sending data, or
one program sending lots of small UDP packets, those will never be
optimized.

So I think GSO/GRO is not the way to go, but there really should be a
way to receive and send many individual packets in one system call.

-- 
Met vriendelijke groet / with kind regards,
     Guus Sliepen <guus@tinc-vpn.org>
