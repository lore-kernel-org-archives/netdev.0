From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 15 May 2016 20:07:34 +0200
Message-ID: <20160515180734.GA23253@electric-eye.fr.zoreil.com>
References: <20160514161602.GA3347@debian-dorm>
 <20160514200356.GA14105@electric-eye.fr.zoreil.com>
 <20160514231044.GA2968@debian-dorm>
 <20160515091953.GA19983@electric-eye.fr.zoreil.com>
 <20160515123829.GA2831@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160515123829.GA2831@debian-dorm>
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
> I still have a question, is it possible that tx_clean() run
> between   priv->tx_buff[*txbd_curr].skb = skb   and   dma_wmb()?

A (previous) run can take place after priv->tx_buff[*txbd_curr].skb and
before *info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len).

So, yes, the driver must check in arc_emac_tx_clean() that 1) either
txbd_dirty != txbd_curr or 2) "info" is not consistent with a still-not-used
status word. Please be patient with me and get rid of the useless "i"

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..337ea3b 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -153,9 +153,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &ndev->stats;
-	unsigned int i;
 
-	for (i = 0; i < TX_BD_NUM; i++) {
+	while (priv->txbd_dirty != priv->txbd_curr) {
 		unsigned int *txbd_dirty = &priv->txbd_dirty;
 		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
 		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];

-- 
Ueimor
