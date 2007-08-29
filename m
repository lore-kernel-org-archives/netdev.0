From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 10/12] sky2: hardware receive timestamp counter
Date: Wed, 29 Aug 2007 12:58:19 -0700
Message-ID: <20070829195843.180268244@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55135 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755619AbXH2UBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:01:51 -0400
Content-Disposition: inline; filename=sky2-rx-time.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use hardware timestamp counter to stamp receive packets.
It allows for higher resolution values without the hardware overhead
of doing gettimeofday.

Even though the network stack is smart enough to not stamp 
packets unless needed, any installation with dhcpd ends up 
using af_packet and that turns on timestamping by default.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/sky2.c |  159 +++++++++++++++++++++++++++++++++++++++--------------
 drivers/net/sky2.h |    5 +
 2 files changed, 124 insertions(+), 40 deletions(-)

--- a/drivers/net/sky2.c	2007-08-29 11:41:16.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-29 11:41:23.000000000 -0700
@@ -26,6 +26,7 @@
 #include <linux/kernel.h>
 #include <linux/version.h>
 #include <linux/module.h>
+#include <linux/reciprocal_div.h>
 #include <linux/netdevice.h>
 #include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
@@ -2186,6 +2187,36 @@ error:
 	goto resubmit;
 }
 
+static inline u32 sky2_tist2ns(const struct sky2_hw *hw, u32 clk)
+{
+	return reciprocal_divide(clk * 1000, hw->tist_rate);
+}
+
+/*
+ * Convert hardware timestamp clock into a real time value
+ */
+static void sky2_set_timestamp(struct sk_buff *skb,
+			       const struct sky2_hw *hw, u32 stamp)
+{
+	unsigned long seq;
+
+	do {
+		s32 delta;
+
+		seq = read_seqbegin(&hw->tist_lock);
+
+		/* ticks since last synchronization */
+		delta = stamp - hw->tist_base;
+
+		if (delta > 0)
+			skb->tstamp = ktime_add_ns(hw->tist_real,
+						   sky2_tist2ns(hw, delta));
+		else
+			skb->tstamp = ktime_sub_ns(hw->tist_real,
+						   sky2_tist2ns(hw, -delta));
+	} while (read_seqretry(&hw->tist_lock, seq));
+}
+
 /* Transmit complete */
 static inline void sky2_tx_done(struct net_device *dev, u16 last)
 {
@@ -2262,6 +2293,16 @@ static int sky2_status_intr(struct sky2_
 			break;
 
 #ifdef SKY2_VLAN_TAG_USED
+		case OP_RXTIMEVLAN:
+			sky2->rx_tag = length;
+			/* fall through */
+#endif
+		case OP_RXTIMESTAMP:
+			skb = sky2->rx_ring[sky2->rx_next].skb;
+			sky2_set_timestamp(skb, hw, status);
+			break;
+
+#ifdef SKY2_VLAN_TAG_USED
 		case OP_RXVLAN:
 			sky2->rx_tag = length;
 			break;
@@ -2457,11 +2498,15 @@ static void sky2_le_error(struct sky2_hw
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
-/* Check for lost IRQ once a second */
+/* Once a second timer for safety checking and polling for timestamp
+ *
+ * Note: receive and timer processing both happen under softirq
+ */
 static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
 
+	/* Look for lost IRQ */
 	if (sky2_read32(hw, B0_ISRC)) {
 		struct net_device *dev = hw->dev[0];
 
@@ -2469,6 +2514,14 @@ static void sky2_watchdog(unsigned long 
 			__netif_rx_schedule(dev);
 	}
 
+	/* Snapshot current system realtime at current timestamp value
+	 * @ 150Mhz counter wraps in 28.6 secs
+	 */
+	write_seqlock(&hw->tist_lock);
+	hw->tist_real = ktime_get_real();
+	hw->tist_base = sky2_read32(hw, GMAC_TI_ST_VAL);
+	write_sequnlock(&hw->tist_lock);
+
 	if (hw->active > 0)
 		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
@@ -2707,9 +2760,8 @@ static void sky2_reset(struct sky2_hw *h
 	/* Turn off descriptor polling */
 	sky2_write32(hw, B28_DPT_CTRL, DPT_STOP);
 
-	/* Turn off receive timestamp */
-	sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_STOP);
-	sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_CLR_IRQ);
+	/* Turn on receive timestamp */
+	sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_CLR_IRQ|GMT_ST_START);
 
 	/* enable the Tx Arbiters */
 	for (i = 0; i < hw->ports; i++)
@@ -4061,6 +4113,9 @@ static int __devinit sky2_probe(struct p
 			sky2_show_addr(dev1);
 	}
 
+	seqlock_init(&hw->tist_lock);
+	hw->tist_rate = reciprocal_value(sky2_mhz(hw));
+
 	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
--- a/drivers/net/sky2.h	2007-08-29 11:41:16.000000000 -0700
+++ b/drivers/net/sky2.h	2007-08-29 11:41:23.000000000 -0700
@@ -352,7 +352,7 @@ enum {
 
 /* Hardware error interrupt mask for Yukon 2 */
 enum {
-	Y2_IS_TIST_OV	= 1<<29,/* Time Stamp Timer overflow interrupt */
+	Y2_IS_TIST_OV	= 1<<29, /* Time Stamp Timer overflow interrupt */
 	Y2_IS_SENSOR	= 1<<28, /* Sensor interrupt */
 	Y2_IS_MST_ERR	= 1<<27, /* Master error interrupt */
 	Y2_IS_IRQ_STAT	= 1<<26, /* Status exception interrupt */
@@ -378,7 +378,7 @@ enum {
 	Y2_HWE_L2_MASK	= Y2_IS_PAR_RD2 | Y2_IS_PAR_WR2 | Y2_IS_PAR_MAC2 |
 			  Y2_IS_PAR_RX2 | Y2_IS_TCP_TXS2| Y2_IS_TCP_TXA2,
 
-	Y2_HWE_ALL_MASK	= Y2_IS_TIST_OV | Y2_IS_MST_ERR | Y2_IS_IRQ_STAT |
+	Y2_HWE_ALL_MASK	= Y2_IS_MST_ERR | Y2_IS_IRQ_STAT |
 			  Y2_HWE_L1_MASK | Y2_HWE_L2_MASK,
 };
 
@@ -2032,6 +2032,11 @@ struct sky2_hw {
 	u8		     ports;
 	u8		     active;
 
+	seqlock_t	     tist_lock;
+	ktime_t		     tist_real;
+	u32		     tist_base;
+	u32		     tist_rate;
+
 	struct sky2_status_le *st_le;
 	u32		     st_idx;
 	dma_addr_t   	     st_dma;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

