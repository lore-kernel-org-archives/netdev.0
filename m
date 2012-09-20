From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 07:37:55 +0200
Message-ID: <1348119475.31352.60.camel@edumazet-glaptop>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	 <1347901326.26523.149.camel@edumazet-glaptop>
	 <1347901493.26523.151.camel@edumazet-glaptop>
	 <20120917.130732.1894375657044880827.davem@davemloft.net>
	 <1348067659.26523.949.camel@edumazet-glaptop>
	 <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:40399 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab2ITFiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 01:38:04 -0400
Received: by wibhi8 with SMTP id hi8so181041wib.1
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 22:38:02 -0700 (PDT)
In-Reply-To: <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 15:20 -0700, Vijay Subramanian wrote:
> > I did some tests and got no problem so far, even using splice() [ this
> > one was tricky because it only deals with order-0 pages at this moment ]
> >
> > NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4
> 
> 
> I applied this patch to net-next and tested with e1000e driver.
> With iperf I got around 8 % improvement on loopback.
> 
> Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> 
> 
> Vijay

If you keep the producer and consumer on separate cpus, and use large
enough send() (64KB or 128KB), gain is more like 15 or 20%

iperf uses 8KB writes, while netperf uses a 16KB default.

TCP stack has a problem because /proc/sys/net/ipv4/tcp_reordering
default value (3) is too small for loopback, since a packet contains 4
MSS

A single reorder and some packets are retransmitted.

Following setting is better

echo 16 >/proc/sys/net/ipv4/tcp_reordering

loopback is lossless, so its always surprising we can have TCP
retransmits on this medium ;)

Thanks
