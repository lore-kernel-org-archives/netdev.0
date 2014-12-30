From: Beniamino Galvani <b.galvani@gmail.com>
Subject: Re: [PATCH net-next] net: stmmac: add BQL support
Date: Tue, 30 Dec 2014 22:27:31 +0100
Message-ID: <20141230212731.GA11453@gmail.com>
References: <1419778631-23067-1-git-send-email-b.galvani@gmail.com>
 <CAGVrzca_i9Wdpa9ecJYPZDgw+TqgMq1SH6ZmRnE4MoQ2dvnAAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGVrzca_i9Wdpa9ecJYPZDgw+TqgMq1SH6ZmRnE4MoQ2dvnAAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 28, 2014 at 11:48:14PM -0800, Florian Fainelli wrote:
> 2014-12-28 6:57 GMT-08:00 Beniamino Galvani <b.galvani@gmail.com>:
> > Add support for Byte Queue Limits to the STMicro MAC driver.
> >
> > Tested on a Amlogic S805 Cortex-A5 board, where the use of BQL
> > slightly decreases the ping latency from ~10ms to ~3ms when the
> > 100Mbps link is saturated by TCP streams. No difference is
> > observed at 1Gbps.
> >
> > Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
> > ---
> 
> [snip]
> 
> >         priv->dev->stats.tx_errors++;
> > @@ -2049,6 +2057,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
> >                 skb_tx_timestamp(skb);
> >
> >         priv->hw->dma->enable_dma_transmission(priv->ioaddr);
> > +       netdev_sent_queue(dev, skb->len);
> 
> You are introducing a potential use after free here in case tx_lock is
> eliminated one day and your TX reclaim logic kicks in and frees the
> freshly transmitted SKB, it would be safer to just cache skb->len in a
> local variable, and use it here.

Ok, I will change this part; probably a simpler solution is to call
netdev_sent_queue() before enabling the DMA like in other drivers.

BTW, I'm not sure this lock is really needed, since it should be
possible to safely access the ring without locks from both the
transmit and the reclaim functions if the pointers are updated
carefully. So maybe it will be really removed one day.

Beniamino

> 
> >
> >         spin_unlock(&priv->tx_lock);
> >         return NETDEV_TX_OK;
