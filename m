From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: avoid flushing statistics when doing a MTU
 change
Date: Mon, 30 Nov 2009 02:43:16 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218065B9851@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <4B139ED2.2060500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1200 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154AbZK3KnV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 05:43:21 -0500
In-Reply-To: <4B139ED2.2060500@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> leitao@linux.vnet.ibm.com a =E9crit :
> > Actually when bnx2 changes the interface's MTU size, it resets
> > the chip and consequently flushes the interface statistics.
> > This patch saves the statistics in a temporary space in order to
> > maintain the statistics correct after the chip reset.
> >
> > Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
>
>
>
> >     return net_stats;
> >  }
> > @@ -6989,6 +7004,11 @@ bnx2_change_ring_size(struct bnx2
> *bp, u32 rx, u32 tx)
> >  {
> >     if (netif_running(bp->dev)) {
> >             bnx2_netif_stop(bp);
>
> I wonder if you need to renew this stats before copying them ?
>  (eg calling bnx2_get_stats())

Calling bnx2_get_stats() won't refresh the stats counters because
they are DMA'ed once a second.  There's an I/O to immediately DMA
the counters:

REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
                                BNX2_HC_COMMAND_STATS_NOW);
REG_RD(bp, BNX2_HC_COMMAND);

We then need to add some delay to wait for the DMA to complete.

>
>
> > +
> > +           /* Save statistics that is going to be reseted */
> > +           memcpy(bp->stats_extra, &bp->dev->stats,
> > +                   sizeof(struct net_device_stats));
> > +
> >             bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
> >             bnx2_free_skbs(bp);
> >             bnx2_free_mem(bp);

