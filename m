From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Tue, 8 Sep 2015 02:02:02 +0200
Message-ID: <20150908000202.GA5059@electric-eye.fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
 <20150907144412.GA26524@calimero.vinschen.de>
 <20150907215251.GA4897@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60864 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbbIHACf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 20:02:35 -0400
Content-Disposition: inline
In-Reply-To: <20150907215251.GA4897@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> Updated patch is on the way.

Fixed memcpy in patch 0001, moved counters allocation from open() 
to probe(), returned open() to its original state but something is
still wrong: the link does not come up.

Patches attached.

I'll try again tomorrow.

-- 
Ueimor

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-r8169-decouple-the-counters-data-and-the-device-priv.patch"

>From 8f1b87a115f6c340558b95f6a1748ddbf866d95f Mon Sep 17 00:00:00 2001
Message-Id: <8f1b87a115f6c340558b95f6a1748ddbf866d95f.1441670158.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 5 Sep 2015 13:26:30 +0200
Subject: [PATCH 1/3] r8169: decouple the counters data and the device private
 area.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c | 69 ++++++++++++++++++++++--------------
 1 file changed, 42 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 24dcbe6..ff1b834 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -833,7 +833,7 @@ struct rtl8169_private {
 	unsigned features;
 
 	struct mii_if_info mii;
-	struct rtl8169_counters counters;
+	struct rtl8169_counters *counters;
 	struct rtl8169_tc_offsets tc_offset;
 	u32 saved_wolopts;
 	u32 opts1_mask;
@@ -2284,7 +2284,7 @@ static bool rtl8169_update_counters(struct net_device *dev)
 		return false;
 
 	if (rtl_udelay_loop_wait_low(tp, &rtl_counters_cond, 10, 1000))
-		memcpy(&tp->counters, counters, sizeof(*counters));
+		memcpy(tp->counters, counters, sizeof(*counters));
 	else
 		ret = false;
 
@@ -2296,6 +2296,8 @@ static bool rtl8169_update_counters(struct net_device *dev)
 static bool rtl8169_init_counter_offsets(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_counters *counters = tp->counters;
+	struct rtl8169_tc_offsets *offset = &tp->tc_offset;
 	bool ret = false;
 
 	/*
@@ -2313,7 +2315,7 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 	 * set at open time by rtl_hw_start.
 	 */
 
-	if (tp->tc_offset.inited)
+	if (offset->inited)
 		return true;
 
 	/* If both, reset and update fail, propagate to caller. */
@@ -2323,10 +2325,10 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 	if (rtl8169_update_counters(dev))
 		ret = true;
 
-	tp->tc_offset.tx_errors = tp->counters.tx_errors;
-	tp->tc_offset.tx_multi_collision = tp->counters.tx_multi_collision;
-	tp->tc_offset.tx_aborted = tp->counters.tx_aborted;
-	tp->tc_offset.inited = true;
+	offset->tx_errors = counters->tx_errors;
+	offset->tx_multi_collision = counters->tx_multi_collision;
+	offset->tx_aborted = counters->tx_aborted;
+	offset->inited = true;
 
 	return ret;
 }
@@ -2335,24 +2337,25 @@ static void rtl8169_get_ethtool_stats(struct net_device *dev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_counters *c = tp->counters;
 
 	ASSERT_RTNL();
 
 	rtl8169_update_counters(dev);
 
-	data[0] = le64_to_cpu(tp->counters.tx_packets);
-	data[1] = le64_to_cpu(tp->counters.rx_packets);
-	data[2] = le64_to_cpu(tp->counters.tx_errors);
-	data[3] = le32_to_cpu(tp->counters.rx_errors);
-	data[4] = le16_to_cpu(tp->counters.rx_missed);
-	data[5] = le16_to_cpu(tp->counters.align_errors);
-	data[6] = le32_to_cpu(tp->counters.tx_one_collision);
-	data[7] = le32_to_cpu(tp->counters.tx_multi_collision);
-	data[8] = le64_to_cpu(tp->counters.rx_unicast);
-	data[9] = le64_to_cpu(tp->counters.rx_broadcast);
-	data[10] = le32_to_cpu(tp->counters.rx_multicast);
-	data[11] = le16_to_cpu(tp->counters.tx_aborted);
-	data[12] = le16_to_cpu(tp->counters.tx_underun);
+	data[ 0] = le64_to_cpu(c->tx_packets);
+	data[ 1] = le64_to_cpu(c->rx_packets);
+	data[ 2] = le64_to_cpu(c->tx_errors);
+	data[ 3] = le32_to_cpu(c->rx_errors);
+	data[ 4] = le16_to_cpu(c->rx_missed);
+	data[ 5] = le16_to_cpu(c->align_errors);
+	data[ 6] = le32_to_cpu(c->tx_one_collision);
+	data[ 7] = le32_to_cpu(c->tx_multi_collision);
+	data[ 8] = le64_to_cpu(c->rx_unicast);
+	data[ 9] = le64_to_cpu(c->rx_broadcast);
+	data[10] = le32_to_cpu(c->rx_multicast);
+	data[11] = le16_to_cpu(c->tx_aborted);
+	data[12] = le16_to_cpu(c->tx_underun);
 }
 
 static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -7779,6 +7782,8 @@ static struct rtnl_link_stats64 *
 rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_tc_offsets *offset = &tp->tc_offset;
+	struct rtl8169_counters *counters = tp->counters;
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int start;
 
@@ -7816,12 +7821,12 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	 * Subtract values fetched during initalization.
 	 * See rtl8169_init_counter_offsets for a description why we do that.
 	 */
-	stats->tx_errors = le64_to_cpu(tp->counters.tx_errors) -
-		le64_to_cpu(tp->tc_offset.tx_errors);
-	stats->collisions = le32_to_cpu(tp->counters.tx_multi_collision) -
-		le32_to_cpu(tp->tc_offset.tx_multi_collision);
-	stats->tx_aborted_errors = le16_to_cpu(tp->counters.tx_aborted) -
-		le16_to_cpu(tp->tc_offset.tx_aborted);
+	stats->tx_errors = le64_to_cpu(counters->tx_errors) -
+			   le64_to_cpu(offset->tx_errors);
+	stats->collisions = le32_to_cpu(counters->tx_multi_collision) -
+			    le32_to_cpu(offset->tx_multi_collision);
+	stats->tx_aborted_errors = le16_to_cpu(counters->tx_aborted) -
+				   le16_to_cpu(offset->tx_aborted);
 
 	return stats;
 }
@@ -8022,6 +8027,8 @@ static void rtl_remove_one(struct pci_dev *pdev)
 
 	unregister_netdev(dev);
 
+	kfree(tp->counters);
+
 	rtl_release_firmware(tp);
 
 	if (pci_dev_run_wake(pdev))
@@ -8447,9 +8454,15 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
+	tp->counters = kmalloc(sizeof(*tp->counters), GFP_KERNEL);
+	if (!tp->counters) {
+		rc = -ENOMEM;
+		goto err_out_msi_4;
+	}
+
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_msi_4;
+		goto err_out_counters_5;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -8483,6 +8496,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
+err_out_counters_5:
+	kfree(tp->counters);
 err_out_msi_4:
 	netif_napi_del(&tp->napi);
 	rtl_disable_msi(pdev, tp);
-- 
2.4.3


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-r8169-use-a-single-condition-to-check-the-completion.patch"

>From d7467f45553b5dca2c6ef094c49e15b2385e3659 Mon Sep 17 00:00:00 2001
Message-Id: <d7467f45553b5dca2c6ef094c49e15b2385e3659.1441670158.git.romieu@fr.zoreil.com>
In-Reply-To: <8f1b87a115f6c340558b95f6a1748ddbf866d95f.1441670158.git.romieu@fr.zoreil.com>
References: <8f1b87a115f6c340558b95f6a1748ddbf866d95f.1441670158.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 5 Sep 2015 13:30:41 +0200
Subject: [PATCH 2/3] r8169: use a single condition to check the completion of
 counters commands.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ff1b834..f8a81a9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2190,6 +2190,13 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+DECLARE_RTL_COND(rtl_cmd_counters_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(CounterAddrLow) & (CounterReset | CounterDump);
+}
+
 static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
 						     dma_addr_t *paddr,
 						     u32 counter_cmd)
@@ -2224,13 +2231,6 @@ static void rtl8169_unmap_counters (struct net_device *dev,
 	dma_free_coherent(d, sizeof(*counters), counters, paddr);
 }
 
-DECLARE_RTL_COND(rtl_reset_counters_cond)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	return RTL_R32(CounterAddrLow) & CounterReset;
-}
-
 static bool rtl8169_reset_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2249,7 +2249,7 @@ static bool rtl8169_reset_counters(struct net_device *dev)
 	if (!counters)
 		return false;
 
-	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
+	if (!rtl_udelay_loop_wait_low(tp, &rtl_cmd_counters_cond, 10, 1000))
 		ret = false;
 
 	rtl8169_unmap_counters(dev, paddr, counters);
@@ -2257,13 +2257,6 @@ static bool rtl8169_reset_counters(struct net_device *dev)
 	return ret;
 }
 
-DECLARE_RTL_COND(rtl_counters_cond)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	return RTL_R32(CounterAddrLow) & CounterDump;
-}
-
 static bool rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2283,7 +2276,7 @@ static bool rtl8169_update_counters(struct net_device *dev)
 	if (!counters)
 		return false;
 
-	if (rtl_udelay_loop_wait_low(tp, &rtl_counters_cond, 10, 1000))
+	if (rtl_udelay_loop_wait_low(tp, &rtl_cmd_counters_cond, 10, 1000))
 		memcpy(tp->counters, counters, sizeof(*counters));
 	else
 		ret = false;
-- 
2.4.3


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-r8169-increase-the-lifespan-of-the-hardware-counters.patch"

>From 2f02fd78d644e076bc11b24e4f16c89883aa8a24 Mon Sep 17 00:00:00 2001
Message-Id: <2f02fd78d644e076bc11b24e4f16c89883aa8a24.1441670158.git.romieu@fr.zoreil.com>
In-Reply-To: <8f1b87a115f6c340558b95f6a1748ddbf866d95f.1441670158.git.romieu@fr.zoreil.com>
References: <8f1b87a115f6c340558b95f6a1748ddbf866d95f.1441670158.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 8 Sep 2015 00:11:58 +0200
Subject: [PATCH 3/3] r8169: increase the lifespan of the hardware counters
 dump area.
X-Organisation: Land of Sunshine Inc.

It avoids sleepable allocation when retrieving statistics as they can
happen with spinlock held (see net/core/net-sysfs.c::netstat_show).

- receive ring, transmit ring and counters dump area allocation failures
  are all considered fatal during open().
- netif_warn is now redundant with rtl_reset_counters_cond built-in
  failure message.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=104031
Fixes: 6e85d5ad36a2 ("r8169: Add values missing in @get_stats64 from HW counters")
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c | 112 +++++++++++++----------------------
 1 file changed, 42 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f8a81a9..afe7810 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -833,8 +833,11 @@ struct rtl8169_private {
 	unsigned features;
 
 	struct mii_if_info mii;
+
 	struct rtl8169_counters *counters;
 	struct rtl8169_tc_offsets tc_offset;
+	dma_addr_t counters_map;
+
 	u32 saved_wolopts;
 	u32 opts1_mask;
 
@@ -2197,104 +2200,65 @@ DECLARE_RTL_COND(rtl_cmd_counters_cond)
 	return RTL_R32(CounterAddrLow) & (CounterReset | CounterDump);
 }
 
-static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
-						     dma_addr_t *paddr,
-						     u32 counter_cmd)
+static int rtl8169_cmd_counters(struct net_device *dev, u32 counter_cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct device *d = &tp->pci_dev->dev;
-	struct rtl8169_counters *counters;
+	dma_addr_t paddr = tp->counters_map;
 	u32 cmd;
+	int rc;
 
-	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL);
-	if (counters) {
-		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
-		cmd = (u64)*paddr & DMA_BIT_MASK(32);
-		RTL_W32(CounterAddrLow, cmd);
-		RTL_W32(CounterAddrLow, cmd | counter_cmd);
-	}
-	return counters;
-}
+	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
+	cmd = (u64)paddr & DMA_BIT_MASK(32);
+	RTL_W32(CounterAddrLow, cmd);
+	RTL_W32(CounterAddrLow, cmd | counter_cmd);
 
-static void rtl8169_unmap_counters (struct net_device *dev,
-				    dma_addr_t paddr,
-				    struct rtl8169_counters *counters)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	struct device *d = &tp->pci_dev->dev;
+	rc = rtl_udelay_loop_wait_low(tp, &rtl_cmd_counters_cond, 10, 1000);
 
 	RTL_W32(CounterAddrLow, 0);
 	RTL_W32(CounterAddrHigh, 0);
 
-	dma_free_coherent(d, sizeof(*counters), counters, paddr);
+	return rc;
 }
 
-static bool rtl8169_reset_counters(struct net_device *dev)
+static int rtl8169_reset_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	struct rtl8169_counters *counters;
-	dma_addr_t paddr;
-	bool ret = true;
 
 	/*
 	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
 	 * tally counters.
 	 */
 	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
-		return true;
-
-	counters = rtl8169_map_counters(dev, &paddr, CounterReset);
-	if (!counters)
-		return false;
-
-	if (!rtl_udelay_loop_wait_low(tp, &rtl_cmd_counters_cond, 10, 1000))
-		ret = false;
-
-	rtl8169_unmap_counters(dev, paddr, counters);
+		return -EINVAL;
 
-	return ret;
+	return rtl8169_cmd_counters(dev, CounterReset);
 }
 
-static bool rtl8169_update_counters(struct net_device *dev)
+static int rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct rtl8169_counters *counters;
-	dma_addr_t paddr;
-	bool ret = true;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
 	 * is disabled.
 	 */
 	if ((RTL_R8(ChipCmd) & CmdRxEnb) == 0)
-		return true;
-
-	counters = rtl8169_map_counters(dev, &paddr, CounterDump);
-	if (!counters)
-		return false;
-
-	if (rtl_udelay_loop_wait_low(tp, &rtl_cmd_counters_cond, 10, 1000))
-		memcpy(tp->counters, counters, sizeof(*counters));
-	else
-		ret = false;
-
-	rtl8169_unmap_counters(dev, paddr, counters);
+		return -EINVAL;
 
-	return ret;
+	return rtl8169_cmd_counters(dev, CounterDump);
 }
 
-static bool rtl8169_init_counter_offsets(struct net_device *dev)
+static int rtl_init_counter_offsets(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct rtl8169_counters *counters = tp->counters;
 	struct rtl8169_tc_offsets *offset = &tp->tc_offset;
-	bool ret = false;
+	int rc;
 
 	/*
-	 * rtl8169_init_counter_offsets is called from rtl_open.  On chip
+	 * rtl_init_counter_offsets is called from rtl_open.  On chip
 	 * versions prior to RTL_GIGA_MAC_VER_19 the tally counters are only
 	 * reset by a power cycle, while the counter values collected by the
 	 * driver are reset at every driver unload/load cycle.
@@ -2303,27 +2267,29 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 	 * values, we collect the initial values at first open(*) and use them
 	 * as offsets to normalize the values returned by @get_stats64.
 	 *
-	 * (*) We can't call rtl8169_init_counter_offsets from rtl_init_one
+	 * (*) We can't call rtl_init_counter_offsets from rtl_init_one
 	 * for the reason stated in rtl8169_update_counters; CmdRxEnb is only
 	 * set at open time by rtl_hw_start.
 	 */
 
 	if (offset->inited)
-		return true;
+		return 0;
 
 	/* If both, reset and update fail, propagate to caller. */
-	if (rtl8169_reset_counters(dev))
-		ret = true;
+	rc = rtl8169_reset_counters(dev);
+	if (!rc)
+		goto out;
 
-	if (rtl8169_update_counters(dev))
-		ret = true;
+	rc = rtl8169_update_counters(dev);
+	if (rc < 0)
+		goto out;
 
 	offset->tx_errors = counters->tx_errors;
 	offset->tx_multi_collision = counters->tx_multi_collision;
 	offset->tx_aborted = counters->tx_aborted;
 	offset->inited = true;
-
-	return ret;
+out:
+	return rc;
 }
 
 static void rtl8169_get_ethtool_stats(struct net_device *dev,
@@ -7741,7 +7707,8 @@ static int rtl_open(struct net_device *dev)
 
 	rtl_hw_start(dev);
 
-	if (!rtl8169_init_counter_offsets(dev))
+	retval = rtl_init_counter_offsets(dev);
+	if (retval < 0)
 		netif_warn(tp, hw, dev, "counter reset/update failed\n");
 
 	netif_start_queue(dev);
@@ -8020,8 +7987,6 @@ static void rtl_remove_one(struct pci_dev *pdev)
 
 	unregister_netdev(dev);
 
-	kfree(tp->counters);
-
 	rtl_release_firmware(tp);
 
 	if (pci_dev_run_wake(pdev))
@@ -8031,6 +7996,10 @@ static void rtl_remove_one(struct pci_dev *pdev)
 	rtl_rar_set(tp, dev->perm_addr);
 
 	rtl_disable_msi(pdev, tp);
+
+	dma_free_coherent(&pdev->dev, sizeof(*tp->counters), tp->counters,
+			  tp->counters_map);
+
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 }
 
@@ -8447,7 +8416,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
-	tp->counters = kmalloc(sizeof(*tp->counters), GFP_KERNEL);
+	tp->counters = dma_alloc_coherent(&pdev->dev, sizeof(*tp->counters),
+					  &tp->counters_map, GFP_KERNEL);
 	if (!tp->counters) {
 		rc = -ENOMEM;
 		goto err_out_msi_4;
@@ -8490,7 +8460,9 @@ out:
 	return rc;
 
 err_out_counters_5:
-	kfree(tp->counters);
+	dma_free_coherent(&pdev->dev, sizeof(*tp->counters), tp->counters,
+			  tp->counters_map);
+	tp->counters = NULL;
 err_out_msi_4:
 	netif_napi_del(&tp->napi);
 	rtl_disable_msi(pdev, tp);
-- 
2.4.3


--r5Pyd7+fXNt84Ff3--
