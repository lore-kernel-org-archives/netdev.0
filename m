From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] r8169: Don't update statistics counters when interface is down
Date: Wed,  4 Feb 2009 11:31:58 +0100
Message-ID: <1233743518-8271-1-git-send-email-ivecera@redhat.com>
References: <20090203214641.GA354@electric-eye.fr.zoreil.com>
Cc: netdev@vger.kernel.org, ivecera@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41042 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbZBDKcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 05:32:08 -0500
In-Reply-To: <20090203214641.GA354@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> 
> int dev_close(struct net_device *dev)
> {
> [...]
> 	clear_bit(__LINK_STATE_START, &dev->state);
>         -> netif_running is not true anymore
> [...]
> 	if (ops->ndo_stop)
> 		ops->ndo_stop(dev);
> 
> -> Calling rtl8169_update_counters in rtl8169_close looks like a no-op.
Yes that's true, it's better to test whether the receiver is enabled or not.

> 
> Aside from that, I do not understand from the description the need for
> the "while (wait--)" loop.
To avoid potential endless loop, only for sure.

> 
> Aside from the aside, the diff can probably be shorter if a local "counters"
> variable is kept in the ethtool function (nit).
I wanted to update counters also when the interface is going down and this needs
to store the counters in device struct. These will be returned when the
interface is down (resp. the receiver is disabled).

Updated patch with correct test condition:
---
 drivers/net/r8169.c |   93 +++++++++++++++++++++++++++++++-------------------
 1 files changed, 58 insertions(+), 35 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2c73ca6..0771eb6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -437,6 +437,22 @@ enum features {
 	RTL_FEATURE_GMII	= (1 << 2),
 };
 
+struct rtl8169_counters {
+	__le64	tx_packets;
+	__le64	rx_packets;
+	__le64	tx_errors;
+	__le32	rx_errors;
+	__le16	rx_missed;
+	__le16	align_errors;
+	__le32	tx_one_collision;
+	__le32	tx_multi_collision;
+	__le64	rx_unicast;
+	__le64	rx_broadcast;
+	__le32	rx_multicast;
+	__le16	tx_aborted;
+	__le16	tx_underun;
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
@@ -480,6 +496,7 @@ struct rtl8169_private {
 	unsigned features;
 
 	struct mii_if_info mii;
+	struct rtl8169_counters counters;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -1100,22 +1117,6 @@ static const char rtl8169_gstrings[][ETH_GSTRING_LEN] = {
 	"tx_underrun",
 };
 
-struct rtl8169_counters {
-	__le64	tx_packets;
-	__le64	rx_packets;
-	__le64	tx_errors;
-	__le32	rx_errors;
-	__le16	rx_missed;
-	__le16	align_errors;
-	__le32	tx_one_collision;
-	__le32	tx_multi_collision;
-	__le64	rx_unicast;
-	__le64	rx_broadcast;
-	__le32	rx_multicast;
-	__le16	tx_aborted;
-	__le16	tx_underun;
-};
-
 static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
@@ -1126,16 +1127,21 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
-static void rtl8169_get_ethtool_stats(struct net_device *dev,
-				      struct ethtool_stats *stats, u64 *data)
+static void rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct rtl8169_counters *counters;
 	dma_addr_t paddr;
 	u32 cmd;
+	int wait = 1000;
 
-	ASSERT_RTNL();
+	/*
+	 * Some chips are unable to dump tally counters when the receiver
+	 * is disabled.
+	 */
+	if ((RTL_R8(ChipCmd) & CmdRxEnb) == 0)
+		return;
 
 	counters = pci_alloc_consistent(tp->pci_dev, sizeof(*counters), &paddr);
 	if (!counters)
@@ -1146,31 +1152,45 @@ static void rtl8169_get_ethtool_stats(struct net_device *dev,
 	RTL_W32(CounterAddrLow, cmd);
 	RTL_W32(CounterAddrLow, cmd | CounterDump);
 
-	while (RTL_R32(CounterAddrLow) & CounterDump) {
-		if (msleep_interruptible(1))
+	while (wait--) {
+		if ((RTL_R32(CounterAddrLow) & CounterDump) == 0) {
+			/* copy updated counters */
+			memcpy(&tp->counters, counters, sizeof(*counters));
 			break;
+		}
+		udelay(10);
 	}
 
 	RTL_W32(CounterAddrLow, 0);
 	RTL_W32(CounterAddrHigh, 0);
 
-	data[0] = le64_to_cpu(counters->tx_packets);
-	data[1] = le64_to_cpu(counters->rx_packets);
-	data[2] = le64_to_cpu(counters->tx_errors);
-	data[3] = le32_to_cpu(counters->rx_errors);
-	data[4] = le16_to_cpu(counters->rx_missed);
-	data[5] = le16_to_cpu(counters->align_errors);
-	data[6] = le32_to_cpu(counters->tx_one_collision);
-	data[7] = le32_to_cpu(counters->tx_multi_collision);
-	data[8] = le64_to_cpu(counters->rx_unicast);
-	data[9] = le64_to_cpu(counters->rx_broadcast);
-	data[10] = le32_to_cpu(counters->rx_multicast);
-	data[11] = le16_to_cpu(counters->tx_aborted);
-	data[12] = le16_to_cpu(counters->tx_underun);
-
 	pci_free_consistent(tp->pci_dev, sizeof(*counters), counters, paddr);
 }
 
+static void rtl8169_get_ethtool_stats(struct net_device *dev,
+				      struct ethtool_stats *stats, u64 *data)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	ASSERT_RTNL();
+
+	rtl8169_update_counters(dev);
+
+	data[0] = le64_to_cpu(tp->counters.tx_packets);
+	data[1] = le64_to_cpu(tp->counters.rx_packets);
+	data[2] = le64_to_cpu(tp->counters.tx_errors);
+	data[3] = le32_to_cpu(tp->counters.rx_errors);
+	data[4] = le16_to_cpu(tp->counters.rx_missed);
+	data[5] = le16_to_cpu(tp->counters.align_errors);
+	data[6] = le32_to_cpu(tp->counters.tx_one_collision);
+	data[7] = le32_to_cpu(tp->counters.tx_multi_collision);
+	data[8] = le64_to_cpu(tp->counters.rx_unicast);
+	data[9] = le64_to_cpu(tp->counters.rx_broadcast);
+	data[10] = le32_to_cpu(tp->counters.rx_multicast);
+	data[11] = le16_to_cpu(tp->counters.tx_aborted);
+	data[12] = le16_to_cpu(tp->counters.tx_underun);
+}
+
 static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	switch(stringset) {
@@ -3682,6 +3702,9 @@ static int rtl8169_close(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
 
+	/* update counters before going down */
+	rtl8169_update_counters(dev);
+
 	rtl8169_down(dev);
 
 	free_irq(dev->irq, dev);
-- 
1.5.6.3

