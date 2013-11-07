From: Andreas Herrmann <andreas.herrmann@calxeda.com>
Subject: [PATCH v2] net: calxedaxgmac: Fix panic caused by MTU change of
 active interface
Date: Thu, 7 Nov 2013 12:07:56 +0100
Message-ID: <20131107110756.GQ5661@alberich>
References: <20131106133126.GL22917@alberich>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Grant Likely <grant.likely@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rob Herring <rob.herring@calxeda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.dfw.emailsrvr.com ([67.192.241.121]:60939 "EHLO
	smtp121.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab3KGLIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 06:08:00 -0500
Content-Disposition: inline
In-Reply-To: <20131106133126.GL22917@alberich>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing MTU size of an xgmac network interface while it is active can
cause a panic like

  skbuff: skb_over_panic: text:c03bc62c len:1090 put:1090 head:edfb6900 data:edfb6942 tail:0xedfb6d84 end:0xedfb6bc0 dev:eth0
  ------------[ cut here ]------------
  kernel BUG at net/core/skbuff.c:126!
  Internal error: Oops - BUG: 0 [#1] SMP ARM
  Modules linked in:
  CPU: 0 PID: 762 Comm: python Tainted: G        W    3.10.0-00015-g3e33cd7 #309
  task: edcfe000 ti: ed67e000 task.ti: ed67e000
  PC is at skb_panic+0x64/0x70
  LR is at wake_up_klogd+0x5c/0x68

This happens because xgmac_change_mtu modifies dev->mtu before the
network interface is quiesced. And thus there still might be buffers
in use which have a buffer size based on the old MTU.

To fix this I moved the change of dev->mtu after the call to
xgmac_stop.

Another modification is required (in xgmac_stop) to ensure that
xgmac_xmit is really not called anymore (xgmac_tx_complete might wake
up the queue again).

I've tested the fix by switching MTU size every second between 600 and
1500 while network traffic was going on. The test box survived a test
of several hours (until I've stopped it) whereas w/o this fix above
panic occurs after several minutes (at most).

Change since v1:
- remove call to netif_stop_queue at beginning of xgmac_stop
- use netif_tx_disable instead of locking+netif_stop_queue

Signed-off-by: Andreas Herrmann <andreas.herrmann@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Patch is against v3.12-1714-gaafc090.


Regards,
Andreas

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 48f5288..4fc5c8e 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1060,13 +1060,13 @@ static int xgmac_stop(struct net_device *dev)
 {
 	struct xgmac_priv *priv = netdev_priv(dev);
 
-	netif_stop_queue(dev);
-
 	if (readl(priv->base + XGMAC_DMA_INTR_ENA))
 		napi_disable(&priv->napi);
 
 	writel(0, priv->base + XGMAC_DMA_INTR_ENA);
 
+	netif_tx_disable(dev);
+
 	/* Disable the MAC core */
 	xgmac_mac_disable(priv->base);
 
@@ -1370,11 +1370,8 @@ static int xgmac_change_mtu(struct net_device *dev, int new_mtu)
 	}
 
 	old_mtu = dev->mtu;
-	dev->mtu = new_mtu;
 
 	/* return early if the buffer sizes will not change */
-	if (old_mtu <= ETH_DATA_LEN && new_mtu <= ETH_DATA_LEN)
-		return 0;
 	if (old_mtu == new_mtu)
 		return 0;
 
@@ -1382,8 +1379,9 @@ static int xgmac_change_mtu(struct net_device *dev, int new_mtu)
 	if (!netif_running(dev))
 		return 0;
 
-	/* Bring the interface down and then back up */
+	/* Bring interface down, change mtu and bring interface back up */
 	xgmac_stop(dev);
+	dev->mtu = new_mtu;
 	return xgmac_open(dev);
 }
 
-- 
1.7.9.5
