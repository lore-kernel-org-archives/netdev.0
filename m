From: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 15 May 2016 20:38:29 +0800
Message-ID: <20160515123829.GA2831@debian-dorm>
References: <20160514161602.GA3347@debian-dorm>
 <20160514200356.GA14105@electric-eye.fr.zoreil.com>
 <20160514231044.GA2968@debian-dorm>
 <20160515091953.GA19983@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160515091953.GA19983-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 15, 2016 at 11:19:53AM +0200, Francois Romieu wrote:
> 
> static void arc_emac_tx_clean(struct net_device *ndev)
> {
> [...]
>         for (i = 0; i < TX_BD_NUM; i++) {
>                 unsigned int *txbd_dirty = &priv->txbd_dirty;
>                 struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
>                 struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
>                 struct sk_buff *skb = tx_buff->skb;
>                 unsigned int info = le32_to_cpu(txbd->info);
> 
>                 if ((info & FOR_EMAC) || !txbd->data || !skb)
>                         break;
>                         ^^^^^
> 
> -> the "break" statement prevents reading all txbds. At most one extra
>    descriptor is read and this driver isn't in the Mpps business.
> 

You are right, I forgot the break statement.

> > I tried your advice, Tx throughput can only reach 5.52MB/s.
> 
> Even with the original code above ?

Yes, I left tx_clean unmodified, and took your advice below.
I tested it again just now, this time throughput do reach 9.8MB/s,
Maybe last time cpu is not idle.

I still have a question, is it possible that tx_clean() run
between   priv->tx_buff[*txbd_curr].skb = skb   and   dma_wmb()?

--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -685,13 +685,15 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
        wmb();
 
        skb_tx_timestamp(skb);
+       priv->tx_buff[*txbd_curr].skb = skb;
+
+       dma_wmb();
 
        *info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
        /* Make sure info word is set */
        wmb();
 
-       priv->tx_buff[*txbd_curr].skb = skb;
 
        /* Increment index to point to the next BD */
        *txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
