From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Fri, 25 Nov 2016 08:16:30 -0800
Message-ID: <1480090590.8455.549.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0228849@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36011 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754878AbcKYQQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 11:16:32 -0500
Received: by mail-pf0-f196.google.com with SMTP id c4so3197690pfb.3
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 08:16:32 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0228849@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-25 at 16:03 +0000, David Laight wrote:
> From: Of Eric Dumazet
> > Sent: 25 November 2016 15:46
> > mlx4 stats are chaotic because a deferred work queue is responsible
> > to update them every 250 ms.
> > 
> > Even sampling stats every one second with "sar -n DEV 1" gives
> > variations like the following :
> ...
> > This patch allows rx/tx bytes/packets counters being folded at the
> > time we need stats.
> > 
> > We now can fetch stats every 1 ms if we want to check NIC behavior
> > on a small time window. It is also easier to detect anomalies.
> ...
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Tariq Toukan <tariqt@mellanox.com>
> ...
> >  	for (i = 0; i < priv->rx_ring_num; i++) {
> > -		stats->rx_packets += priv->rx_ring[i]->packets;
> > -		stats->rx_bytes += priv->rx_ring[i]->bytes;
> > -		sw_rx_dropped += priv->rx_ring[i]->dropped;
> > -		priv->port_stats.rx_chksum_good += priv->rx_ring[i]->csum_ok;
> > -		priv->port_stats.rx_chksum_none += priv->rx_ring[i]->csum_none;
> > -		priv->port_stats.rx_chksum_complete += priv->rx_ring[i]->csum_complete;
> > -		priv->xdp_stats.rx_xdp_drop    += priv->rx_ring[i]->xdp_drop;
> > -		priv->xdp_stats.rx_xdp_tx      += priv->rx_ring[i]->xdp_tx;
> > -		priv->xdp_stats.rx_xdp_tx_full += priv->rx_ring[i]->xdp_tx_full;
> > +		const struct mlx4_en_rx_ring *ring = priv->rx_ring[i];
> > +
> > +		sw_rx_dropped			+= READ_ONCE(ring->dropped);
> > +		priv->port_stats.rx_chksum_good += READ_ONCE(ring->csum_ok);
> > +		priv->port_stats.rx_chksum_none += READ_ONCE(ring->csum_none);
> > +		priv->port_stats.rx_chksum_complete += READ_ONCE(ring->csum_complete);
> > +		priv->xdp_stats.rx_xdp_drop	+= READ_ONCE(ring->xdp_drop);
> > +		priv->xdp_stats.rx_xdp_tx	+= READ_ONCE(ring->xdp_tx);
> > +		priv->xdp_stats.rx_xdp_tx_full	+= READ_ONCE(ring->xdp_tx_full);
> 
> This chunk (and the one after) seem to be adding READ_ONCE() and don't
> seem to be related to the commit message.

The READ_ONCE() are documenting the fact that no lock is taken to fetch
the stats, while another cpus might being changing them.

I had no answer yet from https://patchwork.ozlabs.org/patch/698449/

So I thought it was not needed to explain this in the changelog, given
that it apparently is one of the few things that can block someone to
understand one of my changes :/

Apparently nobody really understands READ_ONCE() purpose, it is really a
pity we have to explain this over and over.
