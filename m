From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v6 2/4] net: moxa: replace build_skb() with
 netdev_alloc_skb_ip_align() / memcpy()
Date: Tue, 26 Aug 2014 09:10:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1748126F@AcuExch.aculab.com>
References: <1408544342-32058-1-git-send-email-jonas.jensen@gmail.com>
 <1408976542-15624-1-git-send-email-jonas.jensen@gmail.com>
 <4449672.aCJ5J5rv4r@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jonas Jensen <jonas.jensen@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mirqus@gmail.com" <mirqus@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Arnd Bergmann' <arnd@arndb.de>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4449672.aCJ5J5rv4r@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> On Monday 25 August 2014 16:22:22 Jonas Jensen wrote:
> > @@ -226,13 +226,15 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
> >                 if (len > RX_BUF_SIZE)
> >                         len = RX_BUF_SIZE;
> >
> > -               skb = build_skb(priv->rx_buf[rx_head], priv->rx_buf_size);
> > +               skb = netdev_alloc_skb_ip_align(ndev, len);
> > +
> >                 if (unlikely(!skb)) {
> > -                       net_dbg_ratelimited("build_skb failed\n");
> > +                       net_dbg_ratelimited("netdev_alloc_skb_ip_align failed\n");
> >                         priv->stats.rx_dropped++;
> >                         priv->stats.rx_errors++;
> >                 }
> >
> > +               memcpy(skb->data, priv->rx_buf[rx_head], len);

Is this memcpy() aligned?
If the hardware can receive to a 4n+2 offset it is probably better to
copy the two bytes before the frame data and to round the length of to
a whole number of words.

> >                 skb_put(skb, len);
> >                 skb->protocol = eth_type_trans(skb, ndev);
> >                 napi_gro_receive(&priv->napi, skb);
> 
> While this seems correct, I wonder why you don't do the normal approach of
> dequeuing the skb from the chain and adding a newly allocated skb to it to
> save the memcpy.

Because the receive buffer area isn't made of skbs.
Post-allocating the skb also reduces the 'true size' of the skb.

	David
