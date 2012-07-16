From: Timo Teras <timo.teras@iki.fi>
Subject: Re: iptables CLAMP MSS to PMTU not working?
Date: Mon, 16 Jul 2012 09:20:58 +0300
Message-ID: <20120716092058.270f6008@vostro>
References: <20120712120021.3dc5cd68@vostro>
	<20120712132419.50b4acaf@vostro>
	<20120716084946.67b91a69@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44469 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab2GPGVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 02:21:18 -0400
Received: by eaak11 with SMTP id k11so1521417eaa.19
        for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 23:21:16 -0700 (PDT)
In-Reply-To: <20120716084946.67b91a69@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jul 2012 08:49:46 +0300 Timo Teras <timo.teras@iki.fi> wrote:

> On Thu, 12 Jul 2012 13:24:19 +0300 Timo Teras <timo.teras@iki.fi>
> wrote:
> 
> > On Thu, 12 Jul 2012 12:00:21 +0300 Timo Teras <timo.teras@iki.fi>
> > wrote:
> > 
> > > We recently noticed that CLAMPMSS to path MTU does not seem to be
> > > working properly. Most recently tested version is linux-3.3.6
> > > which does not work. linux-2.6.35 works for sure, but I suspect
> > > it to have broken somewhere around 3.0'ish with the inetpeer
> > > changes.
> > > 
> > > In my case, the destination is on gre tunnel (that gets routed to
> > > Internet over IPsec transport mode).
> > > 
> > > 'ip route' command verifies that in both boxes the path-MTU is
> > > detected properly. That, is on both cases the static route MTU is
> > > higher. And after large packets sent, ICMP frag-needed is received
> > > and the cache route is updated properly.
> > > 
> > > On the new kernel, I get info like:
> > > # ip route get 10.x.x.x
> > > 10.x.x.x via 172.16.y.y dev gre1  src 172.16.z.z 
> > >     cache  expires 68sec ipid 0x3153 mtu 1422
> > 
> > CLAMP MSS sets MSS to 1432. Which implies MTU 1472. This matches the
> > gre1 interface MTU:
> > 
> > 14: gre1: <UP,LOWER_UP> mtu 1472 qdisc noqueue state UNKNOWN 
> > 
> > So apparently CLAMPMSS is honoring the static route for gre1,
> > instead of the cached pmtu route.
> > 
> > > And the older kernel:
> > > # ip route get 10.x.x.x
> > > 10.x.x.x via 172.16.y.y dev gre1  src 172.16.z.z 
> > >     cache  expires 595sec ipid 0xd241 mtu 1422 advmss 1432
> > > hoplimit 64
> > > 
> > > For some reason, iptables CLAMPMSS seems to set incorrect MSS for
> > > this route (or maybe it's using the static route instead?).
> > 
> > And in this case MSS is set to 1382. That is, it's properly
> > calculated from the path MTU (1422-40=1382). I would expect the
> > advmss of the cached route to get updated on the TCP connects on
> > the older kernels (the above paste is after pinging with large
> > packets and no TCP connection done for the cached entry).
> 
> Looking at the changelog, this would likely be side effect of:
> 
> commit 261663b0ee2ee8e3947f4c11c1a08be18cd2cea1
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Wed Nov 23 02:14:50 2011 +0000
> 
>     ipv4: Don't use the cached pmtu informations for input routes
> 
> At least from performance side, it would be better if CLAMPMSS to PMTU
> would clamp to the learned, cached mtu.

Actually, this is worse. Since XFRM is ignored - it breaks
fragmentation for IPsec targets.

Could this be reverted?
