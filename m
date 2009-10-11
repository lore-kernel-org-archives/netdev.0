From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.32-rc3] 3c574_cs: spin_lock the
 set_multicast_list function
Date: Sun, 11 Oct 2009 21:12:25 +0900
Message-ID: <20091011211225.35e6fb4a.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg500.nifty.com ([202.248.238.80]:63618 "EHLO
	userg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbZJKMNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 08:13:42 -0400
Received: from localhost.localdomain (eaoska168170.adsl.ppp.infoweb.ne.jp [219.116.17.170])by userg500.nifty.com with SMTP id n9BCD1MM005657
	for <netdev@vger.kernel.org>; Sun, 11 Oct 2009 21:13:01 +0900
In-Reply-To: <20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


3c574_cs:
 spin_lock the set_multicast_list function.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

3c574_cs.c |   13 ++++++++++++-
1 file changed, 12 insertions(+), 1 deletion(-)

--- linux-2.6.32-rc3/drivers/net/pcmcia/3c574_cs.c.orig	2009-10-10 15:08:05.000000000 +0900
+++ linux-2.6.32-rc3/drivers/net/pcmcia/3c574_cs.c	2009-10-10 15:10:27.000000000 +0900
@@ -251,6 +251,7 @@ static void el3_tx_timeout(struct net_de
 static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static void set_rx_mode(struct net_device *dev);
+static void set_multicast_list(struct net_device *dev);
 
 static void tc574_detach(struct pcmcia_device *p_dev);
 
@@ -266,7 +267,7 @@ static const struct net_device_ops el3_n
 	.ndo_tx_timeout 	= el3_tx_timeout,
 	.ndo_get_stats		= el3_get_stats,
 	.ndo_do_ioctl		= el3_ioctl,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_multicast_list = set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1161,6 +1162,16 @@ static void set_rx_mode(struct net_devic
 		outw(SetRxFilter | RxStation | RxBroadcast, ioaddr + EL3_CMD);
 }
 
+static void set_multicast_list(struct net_device *dev)
+{
+	struct el3_private *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->window_lock, flags);
+	set_rx_mode(dev);
+	spin_unlock_irqrestore(&lp->window_lock, flags);
+}
+
 static int el3_close(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
