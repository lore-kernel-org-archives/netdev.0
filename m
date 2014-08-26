From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v6 2/4] net: moxa: replace build_skb() with netdev_alloc_skb_ip_align() / memcpy()
Date: Tue, 26 Aug 2014 11:04:30 +0200
Message-ID: <4449672.aCJ5J5rv4r@wuerfel>
References: <1408544342-32058-1-git-send-email-jonas.jensen@gmail.com> <1408976542-15624-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jonas Jensen <jonas.jensen@gmail.com>, netdev@vger.kernel.org,
	f.fainelli@gmail.com, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, mirqus@gmail.com, davem@davemloft.net
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408976542-15624-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 25 August 2014 16:22:22 Jonas Jensen wrote:
> @@ -226,13 +226,15 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
>                 if (len > RX_BUF_SIZE)
>                         len = RX_BUF_SIZE;
>  
> -               skb = build_skb(priv->rx_buf[rx_head], priv->rx_buf_size);
> +               skb = netdev_alloc_skb_ip_align(ndev, len);
> +
>                 if (unlikely(!skb)) {
> -                       net_dbg_ratelimited("build_skb failed\n");
> +                       net_dbg_ratelimited("netdev_alloc_skb_ip_align failed\n");
>                         priv->stats.rx_dropped++;
>                         priv->stats.rx_errors++;
>                 }
>  
> +               memcpy(skb->data, priv->rx_buf[rx_head], len);
>                 skb_put(skb, len);
>                 skb->protocol = eth_type_trans(skb, ndev);
>                 napi_gro_receive(&priv->napi, skb);

While this seems correct, I wonder why you don't do the normal approach of
dequeuing the skb from the chain and adding a newly allocated skb to it to
save the memcpy.

	Arnd
