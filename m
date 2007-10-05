From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 15:49:58 -0700 (PDT)
Message-ID: <20071005.154958.111196594.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083556.7076dd43@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761983AbXJEWuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 18:50:00 -0400
In-Reply-To: <20071005083556.7076dd43@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:35:56 -0700

> These match with existing netif_msg_XXX and your
> driver already has msglvl ethtool hook.
 ...
> Do you really want to print all these at KERN_ERR level?

Both fixed, thanks!

>From c97391da9c6f0c92a9babdf7ecd569e2effa9828 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 5 Oct 2007 15:41:43 -0700
Subject: [PATCH] [NIU]: Use netif_msg_*().

Suggested by Stephen Hemminger.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |  100 +++++++++++++++++++++++++---------------------------
 1 files changed, 48 insertions(+), 52 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0dfabbe..1d56a1a 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -86,34 +86,26 @@ MODULE_DEVICE_TABLE(pci, niu_pci_tbl);
 #define nr64_xpcs(reg)		readq(np->regs + np->xpcs_off + (reg))
 #define nw64_xpcs(reg, val)	writeq((val), np->regs + np->xpcs_off + (reg))
 
-static unsigned int niu_debug;
-#define NIU_DEBUG_INTERRUPT	0x00000001
-#define NIU_DEBUG_TX_WORK	0x00000002
-#define NIU_DEBUG_RX_WORK	0x00000004
-#define NIU_DEBUG_POLL		0x00000008
-#define NIU_DEBUG_PROBE		0x00010000
-#define NIU_DEBUG_MDIO		0x00020000
-#define NIU_DEBUG_MII		0x00040000
-#define NIU_DEBUG_INIT_HW	0x00080000
-#define NIU_DEBUG_STOP_HW	0x00100000
-
-module_param(niu_debug, int, 0);
-MODULE_PARM_DESC(niu_debug,
-"NIU bitmapped debugging message enable value:\n"
-"	0x00000001	Log interrupt events\n"
-"	0x00000002	Log TX work\n"
-"	0x00000004	Log RX work\n"
-"	0x00000008	Log NAPI poll\n"
-"	0x00010000	Log device probe events\n"
-"	0x00020000	Log MDIO reads and writes\n"
-"	0x00040000	Log MII reads and writes\n"
-"	0x00080000	Log HW initialization\n"
-"	0x00100000	Log HW shutdown\n"
-);
+#define NIU_MSG_DEFAULT (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
+
+static int niu_debug = 0;
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "NIU debug level");
 
 #define niudbg(TYPE, f, a...) \
-do {	if (niu_debug & NIU_DEBUG_##TYPE) \
-		printk(KERN_ERR PFX f, ## a); \
+do {	if ((np)->msg_enable & NETIF_MSG_##TYPE) \
+		printk(KERN_DEBUG PFX f, ## a); \
+} while (0)
+
+#define niuinfo(TYPE, f, a...) \
+do {	if ((np)->msg_enable & NETIF_MSG_##TYPE) \
+		printk(KERN_INFO PFX f, ## a); \
+} while (0)
+
+#define niuwarn(TYPE, f, a...) \
+do {	if ((np)->msg_enable & NETIF_MSG_##TYPE) \
+		printk(KERN_WARNING PFX f, ## a); \
 } while (0)
 
 #define niu_lock_parent(np, flags) \
@@ -1071,7 +1063,7 @@ static int niu_link_status_common(struct niu *np, int link_up)
 	unsigned long flags;
 
 	if (!netif_carrier_ok(dev) && link_up) {
-		printk(KERN_INFO PFX "%s: Link is up at %s, %s duplex\n",
+		niuinfo(LINK, "%s: Link is up at %s, %s duplex\n",
 		       dev->name,
 		       (lp->active_speed == SPEED_10000 ?
 			"10Gb/sec" :
@@ -1088,7 +1080,7 @@ static int niu_link_status_common(struct niu *np, int link_up)
 
 		netif_carrier_on(dev);
 	} else if (netif_carrier_ok(dev) && !link_up) {
-		printk(KERN_WARNING PFX "%s: Link is down\n", dev->name);
+		niuwarn(LINK, "%s: Link is down\n", dev->name);
 		netif_carrier_off(dev);
 	}
 
@@ -2359,7 +2351,7 @@ static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 
 	cons = rp->cons;
 
-	niudbg(TX_WORK, "%s: niu_tx_work() pkt_cnt[%u] cons[%d]\n",
+	niudbg(TX_DONE, "%s: niu_tx_work() pkt_cnt[%u] cons[%d]\n",
 	       np->dev->name, pkt_cnt, cons);
 
 	while (pkt_cnt--)
@@ -2395,7 +2387,7 @@ static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
 	mbox->rx_dma_ctl_stat = 0;
 	mbox->rcrstat_a = 0;
 
-	niudbg(RX_WORK, "%s: niu_rx_work(chan[%d]), stat[%llx] qlen=%d\n",
+	niudbg(RX_STATUS, "%s: niu_rx_work(chan[%d]), stat[%llx] qlen=%d\n",
 	       np->dev->name, rp->rx_channel, (unsigned long long) stat, qlen);
 
 	rcr_done = work_done = 0;
@@ -2429,7 +2421,7 @@ static int niu_poll_core(struct niu *np, struct niu_ldg *lp, int budget)
 	u32 rx_vec = (v0 & 0xffffffff);
 	int i, work_done = 0;
 
-	niudbg(POLL, "%s: niu_poll_core() v0[%016llx]\n",
+	niudbg(INTR, "%s: niu_poll_core() v0[%016llx]\n",
 	       np->dev->name, (unsigned long long) v0);
 
 	for (i = 0; i < np->num_tx_rings; i++) {
@@ -2823,7 +2815,7 @@ static void niu_rxchan_intr(struct niu *np, struct rx_ring_info *rp,
 		      RX_DMA_CTL_STAT_RCRTO);
 	nw64(RX_DMA_CTL_STAT(rp->rx_channel), stat_write);
 
-	niudbg(INTERRUPT, "%s: rxchan_intr stat[%llx]\n",
+	niudbg(INTR, "%s: rxchan_intr stat[%llx]\n",
 	       np->dev->name, (unsigned long long) stat);
 }
 
@@ -2832,7 +2824,7 @@ static void niu_txchan_intr(struct niu *np, struct tx_ring_info *rp,
 {
 	rp->tx_cs = nr64(TX_CS(rp->tx_channel));
 
-	niudbg(INTERRUPT, "%s: txchan_intr cs[%llx]\n",
+	niudbg(INTR, "%s: txchan_intr cs[%llx]\n",
 	       np->dev->name, (unsigned long long) rp->tx_cs);
 }
 
@@ -2890,7 +2882,7 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 	unsigned long flags;
 	u64 v0, v1, v2;
 
-	if (niu_debug & NIU_DEBUG_INTERRUPT)
+	if (netif_msg_intr(np))
 		printk(KERN_ERR PFX "niu_interrupt() ldg[%p](%d) ",
 		       lp, ldg);
 
@@ -2900,7 +2892,7 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 	v1 = nr64(LDSV1(ldg));
 	v2 = nr64(LDSV2(ldg));
 
-	if (niu_debug & NIU_DEBUG_INTERRUPT)
+	if (netif_msg_intr(np))
 		printk("v0[%llx] v1[%llx] v2[%llx]\n",
 		       (unsigned long long) v0,
 		       (unsigned long long) v1,
@@ -4581,12 +4573,12 @@ static int niu_init_hw(struct niu *np)
 {
 	int i, err;
 
-	niudbg(INIT_HW, "%s: Initialize TXC\n", np->dev->name);
+	niudbg(IFUP, "%s: Initialize TXC\n", np->dev->name);
 	niu_txc_enable_port(np, 1);
 	niu_txc_port_dma_enable(np, 1);
 	niu_txc_set_imask(np, 0);
 
-	niudbg(INIT_HW, "%s: Initialize TX channels\n", np->dev->name);
+	niudbg(IFUP, "%s: Initialize TX channels\n", np->dev->name);
 	for (i = 0; i < np->num_tx_rings; i++) {
 		struct tx_ring_info *rp = &np->tx_rings[i];
 
@@ -4595,27 +4587,27 @@ static int niu_init_hw(struct niu *np)
 			return err;
 	}
 
-	niudbg(INIT_HW, "%s: Initialize RX channels\n", np->dev->name);
+	niudbg(IFUP, "%s: Initialize RX channels\n", np->dev->name);
 	err = niu_init_rx_channels(np);
 	if (err)
 		goto out_uninit_tx_channels;
 
-	niudbg(INIT_HW, "%s: Initialize classifier\n", np->dev->name);
+	niudbg(IFUP, "%s: Initialize classifier\n", np->dev->name);
 	err = niu_init_classifier_hw(np);
 	if (err)
 		goto out_uninit_rx_channels;
 
-	niudbg(INIT_HW, "%s: Initialize ZCP\n", np->dev->name);
+	niudbg(IFUP, "%s: Initialize ZCP\n", np->dev->name);
 	err = niu_init_zcp(np);
 	if (err)
 		goto out_uninit_rx_channels;
 
-	niudbg(INIT_HW, "%s: Initialize IPP\n", np->dev->name);
+	niudbg(IFUP, "%s: Initialize IPP\n", np->dev->name);
 	err = niu_init_ipp(np);
 	if (err)
 		goto out_uninit_rx_channels;
 
-	niudbg(INIT_HW, "%s: Initialize MAC\n", np->dev->name);
+	niudbg(IFUP, "%s: Initialize MAC\n", np->dev->name);
 	err = niu_init_mac(np);
 	if (err)
 		goto out_uninit_ipp;
@@ -4623,16 +4615,16 @@ static int niu_init_hw(struct niu *np)
 	return 0;
 
 out_uninit_ipp:
-	niudbg(INIT_HW, "%s: Uninit IPP\n", np->dev->name);
+	niudbg(IFUP, "%s: Uninit IPP\n", np->dev->name);
 	niu_disable_ipp(np);
 
 out_uninit_rx_channels:
-	niudbg(INIT_HW, "%s: Uninit RX channels\n", np->dev->name);
+	niudbg(IFUP, "%s: Uninit RX channels\n", np->dev->name);
 	niu_stop_rx_channels(np);
 	niu_reset_rx_channels(np);
 
 out_uninit_tx_channels:
-	niudbg(INIT_HW, "%s: Uninit TX channels\n", np->dev->name);
+	niudbg(IFUP, "%s: Uninit TX channels\n", np->dev->name);
 	niu_stop_tx_channels(np);
 	niu_reset_tx_channels(np);
 
@@ -4641,25 +4633,25 @@ out_uninit_tx_channels:
 
 static void niu_stop_hw(struct niu *np)
 {
-	niudbg(STOP_HW, "%s: Disable interrupts\n", np->dev->name);
+	niudbg(IFDOWN, "%s: Disable interrupts\n", np->dev->name);
 	niu_enable_interrupts(np, 0);
 
-	niudbg(STOP_HW, "%s: Disable RX MAC\n", np->dev->name);
+	niudbg(IFDOWN, "%s: Disable RX MAC\n", np->dev->name);
 	niu_enable_rx_mac(np, 0);
 
-	niudbg(STOP_HW, "%s: Disable IPP\n", np->dev->name);
+	niudbg(IFDOWN, "%s: Disable IPP\n", np->dev->name);
 	niu_disable_ipp(np);
 
-	niudbg(STOP_HW, "%s: Stop TX channels\n", np->dev->name);
+	niudbg(IFDOWN, "%s: Stop TX channels\n", np->dev->name);
 	niu_stop_tx_channels(np);
 
-	niudbg(STOP_HW, "%s: Stop RX channels\n", np->dev->name);
+	niudbg(IFDOWN, "%s: Stop RX channels\n", np->dev->name);
 	niu_stop_rx_channels(np);
 
-	niudbg(STOP_HW, "%s: Reset TX channels\n", np->dev->name);
+	niudbg(IFDOWN, "%s: Reset TX channels\n", np->dev->name);
 	niu_reset_tx_channels(np);
 
-	niudbg(STOP_HW, "%s: Reset RX channels\n", np->dev->name);
+	niudbg(IFDOWN, "%s: Reset RX channels\n", np->dev->name);
 	niu_reset_rx_channels(np);
 }
 
@@ -7376,6 +7368,8 @@ static struct net_device * __devinit niu_alloc_and_init(struct device *gen_dev,
 	np->device = gen_dev;
 	np->ops = ops;
 
+	np->msg_enable = niu_debug;
+
 	spin_lock_init(&np->lock);
 	INIT_WORK(&np->reset_task, niu_reset_task);
 
@@ -7913,6 +7907,8 @@ static int __init niu_init(void)
 		       (PAGE_SIZE % (8 * 1024)) != 0 &&
 		       (PAGE_SIZE % (4 * 1024)) != 0)));
 
+	niu_debug = netif_msg_init(debug, NIU_MSG_DEFAULT);
+
 #ifdef CONFIG_SPARC64
 	err = of_register_driver(&niu_of_driver, &of_bus_type);
 #endif
-- 
1.5.3.3

