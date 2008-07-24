From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 16:05:52 -0700
Message-ID: <20080724160552.7eb1dca5@extreme>
References: <200807241922.57361.opurdila@ixiacom.com>
	<20080724.145600.30988015.davem@davemloft.net>
	<20080724145811.2d2b9ec6@extreme>
	<200807250135.53241.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51891 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754746AbYGXXFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 19:05:55 -0400
In-Reply-To: <200807250135.53241.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jul 2008 01:35:52 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> On Friday 25 July 2008, Stephen Hemminger wrote:
> 
> > How hard would it be to add PLL support to use same kind of timestamp.
> > Enlist the help of some NTP/clock experts to help.
> 
> Let me see if I got this correctly: modify the hardware so that the CPU is 
> synchronized with the NIC timestamping unit. If so, I will agree that this is 
> the cleanest possible solution. 
> 
> Thanks,
> tavi

Perodically, sample the hardware clock and the system time of day,
and resynchronize the clocks.  I did something like this in a prototype
that never got integrated...
------------------------
Subject: sky2: hardware receive timestamp counter

Use hardware timestamp counter to stamp receive packets.
It allows for higher resolution values without the hardware overhead
of doing gettimeofday.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/sky2.c |  159 +++++++++++++++++++++++++++++++++++++++--------------
 drivers/net/sky2.h |    5 +
 2 files changed, 124 insertions(+), 40 deletions(-)

--- a/drivers/net/sky2.c	2007-08-29 11:41:16.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-30 13:05:39.000000000 -0700
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
@@ -2375,9 +2416,6 @@ static void sky2_hw_intr(struct sky2_hw 
 {
 	struct pci_dev *pdev = hw->pdev;
 	u32 status = sky2_read32(hw, B0_HWE_ISRC);
-	u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
-
-	status &= hwmsk;
 
 	if (status & Y2_IS_TIST_OV)
 		sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_CLR_IRQ);
@@ -2457,11 +2495,15 @@ static void sky2_le_error(struct sky2_hw
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
 
@@ -2469,6 +2511,14 @@ static void sky2_watchdog(unsigned long 
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
@@ -2476,9 +2526,6 @@ static void sky2_watchdog(unsigned long 
 /* Hardware/software error handling */
 static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 {
-	if (net_ratelimit())
-		dev_warn(&hw->pdev->dev, "error interrupt status=%#x\n", status);
-
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
 
@@ -2707,9 +2754,9 @@ static void sky2_reset(struct sky2_hw *h
 	/* Turn off descriptor polling */
 	sky2_write32(hw, B28_DPT_CTRL, DPT_STOP);
 
-	/* Turn off receive timestamp */
-	sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_STOP);
-	sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_CLR_IRQ);
+	/* Turn on receive timestamp */
+	sky2_write32(hw, GMAC_TI_ST_VAL, 0);
+	sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_CLR_IRQ|GMT_ST_START);
 
 	/* enable the Tx Arbiters */
 	for (i = 0; i < hw->ports; i++)
@@ -4061,6 +4108,9 @@ static int __devinit sky2_probe(struct p
 			sky2_show_addr(dev1);
 	}
 
+	seqlock_init(&hw->tist_lock);
+	hw->tist_rate = reciprocal_value(sky2_mhz(hw));
+
 	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
--- a/drivers/net/sky2.h	2007-08-29 11:41:16.000000000 -0700
+++ b/drivers/net/sky2.h	2007-08-30 13:01:50.000000000 -0700
@@ -352,7 +352,7 @@ enum {
 
 /* Hardware error interrupt mask for Yukon 2 */
 enum {
-	Y2_IS_TIST_OV	= 1<<29,/* Time Stamp Timer overflow interrupt */
+	Y2_IS_TIST_OV	= 1<<29, /* Time Stamp Timer overflow interrupt */
 	Y2_IS_SENSOR	= 1<<28, /* Sensor interrupt */
 	Y2_IS_MST_ERR	= 1<<27, /* Master error interrupt */
 	Y2_IS_IRQ_STAT	= 1<<26, /* Status exception interrupt */
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
