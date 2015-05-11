From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: systemport: Implement TX coalescing control knobs
Date: Mon, 11 May 2015 15:12:41 -0700
Message-ID: <1431382362-22332-2-git-send-email-f.fainelli@gmail.com>
References: <1431382362-22332-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34876 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbbEKWOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:14:36 -0400
Received: by pabtp1 with SMTP id tp1so120320147pab.2
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:14:35 -0700 (PDT)
In-Reply-To: <1431382362-22332-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability to configure both 'tx-frames' which controls how many frames
are doing to trigger a single interrupt and 'tx-usecs' which dictates how long
to wait before an interrupt should be services.

Since our timer resolution is close to 8.192 us, we round up to the nearest
value the 'tx-usecs' timeout value.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 48 ++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 783543ad1fcf..29d5750a5738 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -456,6 +456,52 @@ static int bcm_sysport_set_wol(struct net_device *dev,
 	return 0;
 }
 
+static int bcm_sysport_get_coalesce(struct net_device *dev,
+				    struct ethtool_coalesce *ec)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	u32 reg;
+
+	reg = tdma_readl(priv, TDMA_DESC_RING_INTR_CONTROL(0));
+
+	ec->tx_coalesce_usecs = (reg >> RING_TIMEOUT_SHIFT) * 8192 / 1000;
+	ec->tx_max_coalesced_frames = reg & RING_INTR_THRESH_MASK;
+
+	return 0;
+}
+
+static int bcm_sysport_set_coalesce(struct net_device *dev,
+				    struct ethtool_coalesce *ec)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	unsigned int i;
+	u32 reg;
+
+	/* Base system clock is 125Mhz, TDMA timeout is this reference clock
+	 * divided by 1024, which yield roughly 8.192 us, our maximum value
+	 * has to fit in the RING_TIMEOUT_MASK (16 bits).
+	 */
+	if (ec->tx_max_coalesced_frames > RING_INTR_THRESH_MASK ||
+	    ec->tx_coalesce_usecs > (RING_TIMEOUT_MASK * 8) + 1)
+		return -EINVAL;
+
+	if (ec->tx_coalesce_usecs == 0 &&
+	    ec->tx_max_coalesced_frames == 0)
+		return -EINVAL;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		reg = tdma_readl(priv, TDMA_DESC_RING_INTR_CONTROL(i));
+		reg &= ~(RING_INTR_THRESH_MASK |
+			 RING_TIMEOUT_MASK << RING_TIMEOUT_SHIFT);
+		reg |= ec->tx_max_coalesced_frames;
+		reg |= DIV_ROUND_UP(ec->tx_coalesce_usecs * 1000, 8192) <<
+			 RING_TIMEOUT_SHIFT;
+		tdma_writel(priv, reg, TDMA_DESC_RING_INTR_CONTROL(i));
+	}
+
+	return 0;
+}
+
 static void bcm_sysport_free_cb(struct bcm_sysport_cb *cb)
 {
 	dev_kfree_skb_any(cb->skb);
@@ -1641,6 +1687,8 @@ static struct ethtool_ops bcm_sysport_ethtool_ops = {
 	.get_sset_count		= bcm_sysport_get_sset_count,
 	.get_wol		= bcm_sysport_get_wol,
 	.set_wol		= bcm_sysport_set_wol,
+	.get_coalesce		= bcm_sysport_get_coalesce,
+	.set_coalesce		= bcm_sysport_set_coalesce,
 };
 
 static const struct net_device_ops bcm_sysport_netdev_ops = {
-- 
2.1.0
