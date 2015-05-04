From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [net-next PATCH v2 3/3] net: macb: Add change_mtu callback with jumbo support
Date: Mon, 4 May 2015 13:22:40 +0530
Message-ID: <dd84c056-ade8-4030-979f-d759e9132d14@BN1AFFO11OLC001.protection.gbl>
References: <1430725960-8441-1-git-send-email-harinik@xilinx.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0055.outbound.protection.outlook.com ([157.56.110.55]:28009
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751918AbbEDHxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 03:53:01 -0400
In-Reply-To: <1430725960-8441-1-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add macb_change_mtu callback; if jumbo frame support is present allow
mtu size changes upto (jumbo max length allowed - headers).

Signed-off-by: Harini Katakam <harinik@xilinx.com>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---

v2:
Move constant definition.

---
 drivers/net/ethernet/cadence/macb.c |   24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a065283..e4a9c17 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -54,6 +54,8 @@
 #define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
 #define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
 
+#define GEM_MTU_MIN_SIZE	68
+
 #define GEM_ZYNQMP_JUMBO_MAX	10240
 
 /*
@@ -1857,6 +1859,26 @@ static int macb_close(struct net_device *dev)
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
@@ -2133,7 +2155,7 @@ static const struct net_device_ops macb_netdev_ops = {
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
