From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 07/18] netdevice hamradio: Convert directly reference of netdev->priv
 to netdev->ml_priv
Date: Fri, 05 Sep 2008 11:17:49 +0800
Message-ID: <48C0A4DD.40601@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61485 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbYIEDUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:20:17 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv, because so many drivers reference to it
directly.

OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
and I want to kill netdev->priv later, I decided to convert all the direct
reference of netdev->priv first.

Different to readonly reference of netdev->priv, in this driver, netdev->priv
was changed. I use netdev->ml_priv to replace netdev->priv.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/hamradio/dmascc.c |   12 ++++++------
 drivers/net/hamradio/scc.c    |   12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index e8cfade..f97b825 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -572,7 +572,7 @@ static int __init setup_adapter(int card_base, int type, int n)
 		priv->param.persist = 256;
 		priv->param.dma = -1;
 		INIT_WORK(&priv->rx_work, rx_bh);
-		dev->priv = priv;
+		dev->ml_priv = priv;
 		sprintf(dev->name, "dmascc%i", 2 * n + i);
 		dev->base_addr = card_base;
 		dev->irq = irq;
@@ -720,7 +720,7 @@ static int read_scc_data(struct scc_priv *priv)
 
 static int scc_open(struct net_device *dev)
 {
-	struct scc_priv *priv = dev->priv;
+	struct scc_priv *priv = dev->ml_priv;
 	struct scc_info *info = priv->info;
 	int card_base = priv->card_base;
 
@@ -862,7 +862,7 @@ static int scc_open(struct net_device *dev)
 
 static int scc_close(struct net_device *dev)
 {
-	struct scc_priv *priv = dev->priv;
+	struct scc_priv *priv = dev->ml_priv;
 	struct scc_info *info = priv->info;
 	int card_base = priv->card_base;
 
@@ -891,7 +891,7 @@ static int scc_close(struct net_device *dev)
 
 static int scc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct scc_priv *priv = dev->priv;
+	struct scc_priv *priv = dev->ml_priv;
 
 	switch (cmd) {
 	case SIOCGSCCPARAM:
@@ -918,7 +918,7 @@ static int scc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct scc_priv *priv = dev->priv;
+	struct scc_priv *priv = dev->ml_priv;
 	unsigned long flags;
 	int i;
 
@@ -963,7 +963,7 @@ static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *scc_get_stats(struct net_device *dev)
 {
-	struct scc_priv *priv = dev->priv;
+	struct scc_priv *priv = dev->ml_priv;
 
 	return &priv->stats;
 }
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 45ae9d1..4c8bf2e 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1518,7 +1518,7 @@ static int scc_net_alloc(const char *name, struct scc_channel *scc)
 	if (!dev) 
 		return -ENOMEM;
 
-	dev->priv = scc;
+	dev->ml_priv = scc;
 	scc->dev = dev;
 	spin_lock_init(&scc->lock);
 	init_timer(&scc->tx_t);
@@ -1575,7 +1575,7 @@ static void scc_net_setup(struct net_device *dev)
 
 static int scc_net_open(struct net_device *dev)
 {
-	struct scc_channel *scc = (struct scc_channel *) dev->priv;
+	struct scc_channel *scc = (struct scc_channel *) dev->ml_priv;
 
  	if (!scc->init)
 		return -EINVAL;
@@ -1593,7 +1593,7 @@ static int scc_net_open(struct net_device *dev)
 
 static int scc_net_close(struct net_device *dev)
 {
-	struct scc_channel *scc = (struct scc_channel *) dev->priv;
+	struct scc_channel *scc = (struct scc_channel *) dev->ml_priv;
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1635,7 +1635,7 @@ static void scc_net_rx(struct scc_channel *scc, struct sk_buff *skb)
 
 static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct scc_channel *scc = (struct scc_channel *) dev->priv;
+	struct scc_channel *scc = (struct scc_channel *) dev->ml_priv;
 	unsigned long flags;
 	char kisscmd;
 
@@ -1705,7 +1705,7 @@ static int scc_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct scc_mem_config memcfg;
 	struct scc_hw_config hwcfg;
 	struct scc_calibrate cal;
-	struct scc_channel *scc = (struct scc_channel *) dev->priv;
+	struct scc_channel *scc = (struct scc_channel *) dev->ml_priv;
 	int chan;
 	unsigned char device_name[IFNAMSIZ];
 	void __user *arg = ifr->ifr_data;
@@ -1952,7 +1952,7 @@ static int scc_net_set_mac_address(struct net_device *dev, void *addr)
 
 static struct net_device_stats *scc_net_get_stats(struct net_device *dev)
 {
-	struct scc_channel *scc = (struct scc_channel *) dev->priv;
+	struct scc_channel *scc = (struct scc_channel *) dev->ml_priv;
 	
 	scc->dev_stat.rx_errors = scc->stat.rxerrs + scc->stat.rx_over;
 	scc->dev_stat.tx_errors = scc->stat.txerrs + scc->stat.tx_under;
-- 
1.5.3.4


