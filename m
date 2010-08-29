From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sun, 29 Aug 2010 11:59:51 +0200
Message-ID: <20100829095951.GA3153@del.dom.local>
References: <20100828143132.GA3211@del.dom.local>
 <1283006909.2277.22.camel@edumazet-laptop>
 <20100828101424.69c4c782@s6510>
 <20100828.144130.189711704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43735 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063Ab0H2J75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Aug 2010 05:59:57 -0400
Received: by fxm13 with SMTP id 13so2763568fxm.19
        for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 02:59:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100828.144130.189711704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 28, 2010 at 02:41:30PM -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Sat, 28 Aug 2010 10:14:24 -0700
> 
> > The Marvell Yukon2 hardware supports two interfaces sharing a common interrupt.
> > Therfore the sky2 driver has up to two net devices and a single NAPI per board.
> > It is possible in a single invocation of the poll loop to process frames
> > for both ports.  GRO works by combining received packets from identical
> > flows over one NAPI interval. It is possible on sky2 that one packet
> > could be processed for the first port, and the next packet processed was for
> > second port and the two packets were related so that GRO would combine them.
> > The check for the same dev is required to prevent this. Yes it is an unlikely
> > corner case, but the purpose of GRO is to do aggregation but preserve the
> > flow characteristics of the incoming traffic.
> 
> If that is true then GRO is going to refuse to merge every single
> frame that arrives on the second port of a SKY2 device. :-)
> 
> This is because for the two ports, you allocate and register one NAPI
> instance which uses only the first port's netdev pointer.
> 
> Therefore, when GRO compares napi->dev to skb->dev it will always not

Actually, when GRO compares napi->dev to skb->dev?

Jarek P.

> match for packets coming from the second port since the netdev pointer
> in skb->dev will be different.
> 
> Since netpoll does similar things, this means both NAPI and netpoll
> cannot function properly with SKY2's second port.  It will only work
> right on the first port.
> 
> 
