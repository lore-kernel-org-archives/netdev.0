From: Nolan Leake <nolan@cumulusnetworks.com>
Subject: [PATCH] tun: keep link (carrier) state up to date
Date: Tue, 27 Jul 2010 16:53:43 -0700
Message-ID: <1280274823.23381.59.camel@voxel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from phong.sigbus.net ([65.49.35.42]:48872 "EHLO phong.sigbus.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206Ab0G1ABm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 20:01:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, only ethtool can get accurate link state of a tap device.
With this patch, IFF_RUNNING and IF_OPER_UP/DOWN are kept up to date as
well.

Signed-off-by: Nolan Leake <nolan@cumulusnetworks.com>
---
 drivers/net/tun.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4fdfa2a..393273c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -144,6 +144,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	err = 0;
 	tfile->tun = tun;
 	tun->tfile = tfile;
+	netif_carrier_on(tun->dev);
 	dev_hold(tun->dev);
 	sock_hold(tun->socket.sk);
 	atomic_inc(&tfile->count);
@@ -157,6 +158,7 @@ static void __tun_detach(struct tun_struct *tun)
 {
 	/* Detach from net device */
 	netif_tx_lock_bh(tun->dev);
+	netif_carrier_off(tun->dev);
 	tun->tfile = NULL;
 	netif_tx_unlock_bh(tun->dev);
 
@@ -1425,12 +1427,6 @@ static void tun_set_msglevel(struct net_device *dev, u32 value)
 #endif
 }
 
-static u32 tun_get_link(struct net_device *dev)
-{
-	struct tun_struct *tun = netdev_priv(dev);
-	return !!tun->tfile;
-}
-
 static u32 tun_get_rx_csum(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
@@ -1452,7 +1448,7 @@ static const struct ethtool_ops tun_ethtool_ops = {
 	.get_drvinfo	= tun_get_drvinfo,
 	.get_msglevel	= tun_get_msglevel,
 	.set_msglevel	= tun_set_msglevel,
-	.get_link	= tun_get_link,
+	.get_link	= ethtool_op_get_link,
 	.get_rx_csum	= tun_get_rx_csum,
 	.set_rx_csum	= tun_set_rx_csum
 };

