From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v4 3/7] via-velocity: Implement NAPI support
Date: Thu, 26 Nov 2009 09:10:26 +0100
Message-ID: <20091126091026.411482a1@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
	<20091126090429.39cb37ac@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:50898 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759453AbZKZIKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 03:10:23 -0500
In-Reply-To: <20091126090429.39cb37ac@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds NAPI support for VIA velocity. The new velocity_poll
function also pairs tx/rx handling twice which improves perforamance on
some workloads (e.g., netperf UDP_STREAM) significantly (that part is
from the VIA driver).

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |   81 +++++++++++++++++++++++++-------------------
 drivers/net/via-velocity.h |    3 ++
 2 files changed, 49 insertions(+), 35 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 85ee898..668cdf6 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -354,12 +354,6 @@ VELOCITY_PARAM(ValPktLen, "Receiving or Drop invalid 802.3 frame");
 */
 VELOCITY_PARAM(wol_opts, "Wake On Lan options");
 
-#define INT_WORKS_DEF   20
-#define INT_WORKS_MIN   10
-#define INT_WORKS_MAX   64
-
-VELOCITY_PARAM(int_works, "Number of packets per interrupt services");
-
 static int rx_copybreak = 200;
 module_param(rx_copybreak, int, 0644);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
@@ -516,7 +510,6 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 	velocity_set_bool_opt(&opts->flags, ValPktLen[index], VAL_PKT_LEN_DEF, VELOCITY_FLAGS_VAL_PKT_LEN, "ValPktLen", devname);
 	velocity_set_int_opt((int *) &opts->spd_dpx, speed_duplex[index], MED_LNK_MIN, MED_LNK_MAX, MED_LNK_DEF, "Media link mode", devname);
 	velocity_set_int_opt((int *) &opts->wol_opts, wol_opts[index], WOL_OPT_MIN, WOL_OPT_MAX, WOL_OPT_DEF, "Wake On Lan options", devname);
-	velocity_set_int_opt((int *) &opts->int_works, int_works[index], INT_WORKS_MIN, INT_WORKS_MAX, INT_WORKS_DEF, "Interrupt service works", devname);
 	opts->numrx = (opts->numrx & ~3);
 }
 
@@ -2123,13 +2116,14 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
  *	any received packets from the receive queue. Hand the ring
  *	slots back to the adapter for reuse.
  */
-static int velocity_rx_srv(struct velocity_info *vptr, int status)
+static int velocity_rx_srv(struct velocity_info *vptr, int status,
+		int budget_left)
 {
 	struct net_device_stats *stats = &vptr->dev->stats;
 	int rd_curr = vptr->rx.curr;
 	int works = 0;
 
-	do {
+	while (works < budget_left) {
 		struct rx_desc *rd = vptr->rx.ring + rd_curr;
 
 		if (!vptr->rx.info[rd_curr].skb)
@@ -2160,7 +2154,8 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 		rd_curr++;
 		if (rd_curr >= vptr->options.numrx)
 			rd_curr = 0;
-	} while (++works <= 15);
+		works++;
+	}
 
 	vptr->rx.curr = rd_curr;
 
@@ -2171,6 +2166,40 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 	return works;
 }
 
+static int velocity_poll(struct napi_struct *napi, int budget)
+{
+	struct velocity_info *vptr = container_of(napi,
+			struct velocity_info, napi);
+	unsigned int rx_done;
+	u32 isr_status;
+
+	spin_lock(&vptr->lock);
+	isr_status = mac_read_isr(vptr->mac_regs);
+
+	/* Ack the interrupt */
+	mac_write_isr(vptr->mac_regs, isr_status);
+	if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
+		velocity_error(vptr, isr_status);
+
+	/*
+	 * Do rx and tx twice for performance (taken from the VIA
+	 * out-of-tree driver).
+	 */
+	rx_done = velocity_rx_srv(vptr, isr_status, budget / 2);
+	velocity_tx_srv(vptr, isr_status);
+	rx_done += velocity_rx_srv(vptr, isr_status, budget - rx_done);
+	velocity_tx_srv(vptr, isr_status);
+
+	spin_unlock(&vptr->lock);
+
+	/* If budget not fully consumed, exit the polling mode */
+	if (rx_done < budget) {
+		napi_complete(napi);
+		mac_enable_int(vptr->mac_regs);
+	}
+
+	return rx_done;
+}
 
 /**
  *	velocity_intr		-	interrupt callback
@@ -2187,8 +2216,6 @@ static irqreturn_t velocity_intr(int irq, void *dev_instance)
 	struct net_device *dev = dev_instance;
 	struct velocity_info *vptr = netdev_priv(dev);
 	u32 isr_status;
-	int max_count = 0;
-
 
 	spin_lock(&vptr->lock);
 	isr_status = mac_read_isr(vptr->mac_regs);
@@ -2199,32 +2226,13 @@ static irqreturn_t velocity_intr(int irq, void *dev_instance)
 		return IRQ_NONE;
 	}
 
-	mac_disable_int(vptr->mac_regs);
-
-	/*
-	 *	Keep processing the ISR until we have completed
-	 *	processing and the isr_status becomes zero
-	 */
-
-	while (isr_status != 0) {
-		mac_write_isr(vptr->mac_regs, isr_status);
-		if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
-			velocity_error(vptr, isr_status);
-		if (isr_status & (ISR_PRXI | ISR_PPRXI))
-			max_count += velocity_rx_srv(vptr, isr_status);
-		if (isr_status & (ISR_PTXI | ISR_PPTXI))
-			max_count += velocity_tx_srv(vptr, isr_status);
-		isr_status = mac_read_isr(vptr->mac_regs);
-		if (max_count > vptr->options.int_works) {
-			printk(KERN_WARNING "%s: excessive work at interrupt.\n",
-				dev->name);
-			max_count = 0;
-		}
+	if (likely(napi_schedule_prep(&vptr->napi))) {
+		mac_disable_int(vptr->mac_regs);
+		__napi_schedule(&vptr->napi);
 	}
 	spin_unlock(&vptr->lock);
-	mac_enable_int(vptr->mac_regs);
-	return IRQ_HANDLED;
 
+	return IRQ_HANDLED;
 }
 
 /**
@@ -2264,6 +2272,7 @@ static int velocity_open(struct net_device *dev)
 
 	mac_enable_int(vptr->mac_regs);
 	netif_start_queue(dev);
+	napi_enable(&vptr->napi);
 	vptr->flags |= VELOCITY_FLAGS_OPENED;
 out:
 	return ret;
@@ -2499,6 +2508,7 @@ static int velocity_close(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 
+	napi_disable(&vptr->napi);
 	netif_stop_queue(dev);
 	velocity_shutdown(vptr);
 
@@ -2818,6 +2828,7 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	dev->irq = pdev->irq;
 	dev->netdev_ops = &velocity_netdev_ops;
 	dev->ethtool_ops = &velocity_ethtool_ops;
+	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
 
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_HW_VLAN_RX;
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 6091946..22bfea4 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -32,6 +32,7 @@
 #define VELOCITY_VERSION       "1.14"
 
 #define VELOCITY_IO_SIZE	256
+#define VELOCITY_NAPI_WEIGHT	64
 
 #define PKT_BUF_SZ          1540
 
@@ -1564,6 +1565,8 @@ struct velocity_info {
 	u32 ticks;
 
 	u8 rev_id;
+
+	struct napi_struct napi;
 };
 
 /**
-- 
1.6.0.4

