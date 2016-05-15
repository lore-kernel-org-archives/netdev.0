From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 15 May 2016 11:19:53 +0200
Message-ID: <20160515091953.GA19983@electric-eye.fr.zoreil.com>
References: <20160514161602.GA3347@debian-dorm>
 <20160514200356.GA14105@electric-eye.fr.zoreil.com>
 <20160514231044.GA2968@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160514231044.GA2968@debian-dorm>
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

Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> :
[...]
> I don't think taking txbd_curr and txbd_dirty only as hints is a good idea.
> That could be a big waste, since tx_clean have to go through all the txbds.

Sorry if my point was not clear: arc_emac_tx_clean() does not need
to change (at least not for the reason given in the commit message) :o)

Current code:

static void arc_emac_tx_clean(struct net_device *ndev)
{
[...]
        for (i = 0; i < TX_BD_NUM; i++) {
                unsigned int *txbd_dirty = &priv->txbd_dirty;
                struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
                struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
                struct sk_buff *skb = tx_buff->skb;
                unsigned int info = le32_to_cpu(txbd->info);

                if ((info & FOR_EMAC) || !txbd->data || !skb)
                        break;
                        ^^^^^

-> the "break" statement prevents reading all txbds. At most one extra
   descriptor is read and this driver isn't in the Mpps business.

> I tried your advice, Tx throughput can only reach 5.52MB/s.

Even with the original code above ?

> Leaving one sent packet in tx_clean is acceptable if we respect to txbd_curr
> and txbd_dirty, since the ignored packet will be cleaned when new packets
> arrive.

There is no reason to leave tx packet roting in the first place. Really.
I doubt it would help bql for one.

Packet may rot because of unexpected hardware behavior and driver should
cope with it when it is diagnosed, sure. However, you don't want the driver
to opens it own unbounded window. Next packet: 10 us, 10 ms, 10 s ?

-- 
Ueimor
