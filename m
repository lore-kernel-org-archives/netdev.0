From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [net-next PATCH 3/3] net: macb: Add change_mtu callback with jumbo support
Date: Fri, 10 Apr 2015 14:47:21 +0530
Message-ID: <9376b508-694b-4582-8f2c-4e85e2bab2b5@BY2FFO11FD054.protection.gbl>
References: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add macb_change_mtu callback; if jumbo frame support is present allow
mtu size changes upto (jumbo max length allowed - headers).

Signed-off-by: Harini Katakam <harinik@xilinx.com>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c |   26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 85de91d..33f3283 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -54,6 +54,10 @@
 #define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
 #define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
 
+#define GEM_MTU_MIN_SIZE	68
+
+#define GEM_ZYNQMP_JUMBO_MAX	10240
+
 /*
  * Graceful stop timeouts in us. We should allow up to
  * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
@@ -1852,6 +1856,26 @@ static int macb_close(struct net_device *dev)
 	return 0;
 }
 
+static int macb_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct macb *bp = netdev_priv(dev);
+	u32 max_mtu;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	max_mtu = ETH_DATA_LEN;
+	if (bp->isjumbo)
+		max_mtu = gem_readl(bp, JML) - ETH_HLEN - ETH_FCS_LEN;
+
+	if ((new_mtu > max_mtu) || (new_mtu < GEM_MTU_MIN_SIZE))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
 static void gem_update_stats(struct macb *bp)
 {
 	int i;
@@ -2128,7 +2152,7 @@ static const struct net_device_ops macb_netdev_ops = {
 	.ndo_get_stats		= macb_get_stats,
 	.ndo_do_ioctl		= macb_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_change_mtu		= macb_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= macb_poll_controller,
-- 
1.7.9.5
