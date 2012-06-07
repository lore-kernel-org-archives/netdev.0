From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Thu, 7 Jun 2012 22:53:56 +0200
Message-ID: <20120607205356.GA2491@electric-eye.fr.zoreil.com>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7ed49f446365ac625437702d92946add@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Fedoryshchenko <denys@visp.net.lb> :
[...]
> [ 8683.927442] ======================================================
> [ 8683.927555] [ INFO: possible circular locking dependency detected ]
> [ 8683.927672] 3.4.1-build-0061 #14 Not tainted
> [ 8683.927782] -------------------------------------------------------
> [ 8683.927895] swapper/0/0 is trying to acquire lock:
> [ 8683.928007]  (slock-AF_INET){+.-...}, at: [<e0fc73ec>]
> l2tp_xmit_skb+0x173/0x47e [l2tp_core]
> [ 8683.928121]
> [ 8683.928121] but task is already holding lock:
> [ 8683.928121]  (_xmit_ETHER#2){+.-...}, at: [<c02f062d>]
> sch_direct_xmit+0x36/0x119
> [ 8683.928121]
> [ 8683.928121] which lock already depends on the new lock.

Any reason why it could not be made LLTX ?

(untested patch against -git, applies to 3.4.1 with some offset)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 443591d..5725258 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -36,12 +36,20 @@
 /* Default device name. May be overridden by name specified by user */
 #define L2TP_ETH_DEV_NAME	"l2tpeth%d"
 
+struct l2tp_eth_stats {
+	u64			packets;
+	u64			bytes;
+	struct u64_stats_sync	syncp;
+};
+
 /* via netdev_priv() */
 struct l2tp_eth {
 	struct net_device	*dev;
 	struct sock		*tunnel_sock;
 	struct l2tp_session	*session;
 	struct list_head	list;
+	struct l2tp_eth_stats	rstats;
+	struct l2tp_eth_stats	tstats;
 };
 
 /* via l2tp_session_priv() */
@@ -87,25 +95,56 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct l2tp_eth *priv = netdev_priv(dev);
 	struct l2tp_session *session = priv->session;
+	struct l2tp_eth_stats *tstats = &priv->tstats;
 
 	l2tp_xmit_skb(session, skb, session->hdr_len);
 
-	dev->stats.tx_bytes += skb->len;
-	dev->stats.tx_packets++;
+	u64_stats_update_begin(&tstats->syncp);
+	tstats->packets++;
+	tstats->bytes += skb->len;
+	u64_stats_update_end(&tstats->syncp);
 
 	return 0;
 }
 
+static struct rtnl_link_stats64 *
+l2tp_eth_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
+{
+	struct l2tp_eth *priv = netdev_priv(dev);
+	struct l2tp_eth_stats *s;
+	unsigned int start;
+
+	s = &priv->rstats;
+	do {
+		start = u64_stats_fetch_begin_bh(&s->syncp);
+		stats->rx_packets	= s->packets;
+		stats->rx_bytes		= s->bytes;
+	} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+
+	s = &priv->tstats;
+	do {
+		start = u64_stats_fetch_begin_bh(&s->syncp);
+		stats->tx_packets	= s->packets;
+		stats->tx_bytes		= s->bytes;
+	} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+
+	stats->rx_errors = dev->stats.rx_errors;
+
+	return stats;
+}
+
 static struct net_device_ops l2tp_eth_netdev_ops = {
 	.ndo_init		= l2tp_eth_dev_init,
 	.ndo_uninit		= l2tp_eth_dev_uninit,
 	.ndo_start_xmit		= l2tp_eth_dev_xmit,
+	.ndo_get_stats64	= l2tp_eth_get_stats64,
 };
 
 static void l2tp_eth_dev_setup(struct net_device *dev)
 {
 	ether_setup(dev);
-	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->features		|= NETIF_F_LLTX;
+	dev->priv_flags		&= ~IFF_TX_SKB_SHARING;
 	dev->netdev_ops		= &l2tp_eth_netdev_ops;
 	dev->destructor		= free_netdev;
 }
@@ -139,8 +178,13 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 	nf_reset(skb);
 
 	if (dev_forward_skb(dev, skb) == NET_RX_SUCCESS) {
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += data_len;
+		struct l2tp_eth *priv = netdev_priv(dev);
+		struct l2tp_eth_stats *rstats = &priv->rstats;
+
+		u64_stats_update_begin(&rstats->syncp);
+		rstats->packets++;
+		rstats->bytes += data_len;
+		u64_stats_update_end(&rstats->syncp);
 	} else
 		dev->stats.rx_errors++;
 
