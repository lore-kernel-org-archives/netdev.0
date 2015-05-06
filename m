From: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [net-next PATCH v3 4/4] net: macb: Add change_mtu callback with jumbo support
Date: Wed, 6 May 2015 22:27:18 +0530
Message-ID: <1430931438-32592-4-git-send-email-harinik@xilinx.com>
References: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1430931438-32592-1-git-send-email-harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add macb_change_mtu callback; if jumbo frame support is present allow
mtu size changes upto (jumbo max length allowed - headers).

Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
---

v3:
Check for jumbo capability in macb_config.

v2:
Move constant definition.

---
 drivers/net/ethernet/cadence/macb.c |   24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index cb84587..97c6646 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -54,6 +54,8 @@
 #define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
 #define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
 
+#define GEM_MTU_MIN_SIZE	68
+
 /*
  * Graceful stop timeouts in us. We should allow up to
  * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
@@ -1855,6 +1857,26 @@ static int macb_close(struct net_device *dev)
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
+	if (bp->caps | MACB_CAPS_JUMBO)
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
@@ -2131,7 +2153,7 @@ static const struct net_device_ops macb_netdev_ops = {
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
