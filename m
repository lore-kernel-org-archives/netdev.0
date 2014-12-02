From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 2 Dec 2014 13:39:51 +0100
Message-ID: <20141202123951.GA16347@1wt.eu>
References: <20141202071304.GA22512@1wt.eu> <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:29118 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932313AbaLBMjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 07:39:54 -0500
Content-Disposition: inline
In-Reply-To: <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, Dec 02, 2014 at 04:18:08AM -0800, Eric Dumazet wrote:
> > diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> > index 4762994..35bfba7 100644
> > --- a/drivers/net/ethernet/marvell/mvneta.c
> > +++ b/drivers/net/ethernet/marvell/mvneta.c
> > @@ -214,7 +214,7 @@
> >  /* Various constants */
> >  
> >  /* Coalescing */
> > -#define MVNETA_TXDONE_COAL_PKTS		16
> > +#define MVNETA_TXDONE_COAL_PKTS		1
> >  #define MVNETA_RX_COAL_PKTS		32
> >  #define MVNETA_RX_COAL_USEC		100
> >  
> 
> 
> I am surprised TCP even worked correctly with this problem.

There are multiple explanations to this :
  - we used to flush Tx queues upon Rx interrupt, which used to hide
    the problem.

  - we tend to have large socket buffers, which cover the issue. I've
    never had any issue at high data rates. After all only 23kB send
    buffer is needed to get it to work.

  - most often you have multiple parallel streams which hide the issue
    even more.

> I highly suggest BQL for this driver, now this issue is fixed.

How does that work ?

> I wonder if this high setting was not because of race conditions in the
> driver :
>
> mvneta_tx() seems to access skb->len too late, TX completion might have
> already freed skb :
> 
>                 u64_stats_update_begin(&stats->syncp);
>                 stats->tx_packets++;
>                 stats->tx_bytes  += skb->len;         // potential use after free
>                 u64_stats_update_end(&stats->syncp);

Good catch! But no, this is unrelated since it does not fix the race either.
Initially this driver used to implement a timer to flush the Tx queue after
10ms, resulting in abysmal Tx-only performance as you can easily imagine. In
my opinion there's a design flaw in the chip, and they did everything they
could to workaround it (let's not say "hide it"), but that was not enough.
When I "fixed" the performance issue by enabling the Tx interrupt, I kept
the value 16 which gave pretty good results to me, without realizing that
there was this corner case :-/

> Thanks Willy !

Thanks for your review :-)

Willy
