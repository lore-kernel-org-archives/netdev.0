From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 19 Sep 2012 19:55:08 +0200
Message-ID: <1348077308.26523.1158.camel@edumazet-glaptop>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	 <1347901326.26523.149.camel@edumazet-glaptop>
	 <1347901493.26523.151.camel@edumazet-glaptop>
	 <20120917.130732.1894375657044880827.davem@davemloft.net>
	 <1348067659.26523.949.camel@edumazet-glaptop>  <505A00C8.5050302@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56676 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932807Ab2ISRzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 13:55:13 -0400
Received: by bkwj10 with SMTP id j10so691803bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 10:55:12 -0700 (PDT)
In-Reply-To: <505A00C8.5050302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 10:28 -0700, Rick Jones wrote:
> On 09/19/2012 08:14 AM, Eric Dumazet wrote:
> > I did some tests and got no problem so far, even using splice() [ this
> > one was tricky because it only deals with order-0 pages at this moment ]
> >
> > NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4
> >
> > On loopback, performance of netperf goes from 31900 Mb/s to 38500 Mb/s,
> > thats a 20 % increase.
> 
> I guess Brutus will need a new baseline for his TCP Friends patch then :)
> 
> BTW, what is the change, if any for TCP_RR?
> 
> happy benchmarking,
> 
> rick jones
> 

No difference, because I already optimized this case last year ;)


commit f07d960df33c5aef8f513efce0fd201f962f94a1
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Nov 28 22:41:47 2011 +0000

    tcp: avoid frag allocation for small frames
    
    tcp_sendmsg() uses select_size() helper to choose skb head size when a
    new skb must be allocated.
    
    If GSO is enabled for the socket, current strategy is to force all
    payload data to be outside of headroom, in PAGE fragments.
    
    This strategy is not welcome for small packets, wasting memory.
    
    Experiments show that best results are obtained when using 2048 bytes
    for skb head (This includes the skb overhead and various headers)
    
    This patch provides better len/truesize ratios for packets sent to
    loopback device, and reduce memory needs for in-flight loopback packets,
    particularly on arches with big pages.
    
    If a sender sends many 1-byte packets to an unresponsive application,
    receiver rmem_alloc will grow faster and will stop queuing these packets
    sooner, or will collapse its receive queue to free excess memory.
    
    netperf -t TCP_RR results are improved by ~4 %, and many workloads are
    improved as well (tbench, mysql...)
