From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next] gianfar: Change default HW Tx queue scheduling mode
Date: Thu, 20 Sep 2012 18:57:54 +0300
Message-ID: <1348156674-31551-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe006.messaging.microsoft.com ([216.32.180.189]:56881
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754886Ab2ITP6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 11:58:16 -0400
Received: from mail106-co1 (localhost [127.0.0.1])	by
 mail106-co1-R.bigfish.com (Postfix) with ESMTP id 159CE4C00D6	for
 <netdev@vger.kernel.org>; Thu, 20 Sep 2012 15:58:15 +0000 (UTC)
Received: from CO1EHSMHS009.bigfish.com (unknown [10.243.78.246])	by
 mail106-co1.bigfish.com (Postfix) with ESMTP id A940CC8003F	for
 <netdev@vger.kernel.org>; Thu, 20 Sep 2012 15:58:12 +0000 (UTC)
Received: from zro04-ws574.ea.freescale.net ([10.213.130.145])	by
 tx30smr01.am.freescale.net (8.14.3/8.14.0) with ESMTP id q8KFw7Bo030408	for
 <netdev@vger.kernel.org>; Thu, 20 Sep 2012 08:58:08 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is primarily to address transmission timeout occurrences, when
multiple H/W Tx queues are being used concurrently. Because in
the priority scheduling mode the controller does not service the
Tx queues equally (but in ascending index order), Tx timeouts are
being triggered rightaway for a basic test with multiple simultaneous
connections like:
iperf -c <server_ip> -n 100M -P 8

resulting in kernel trace:
NETDEV WATCHDOG: eth1 (fsl-gianfar): transmit queue <X> timed out
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255
...
and controller reset during intense traffic, and possibly further
complications.

This patch changes the default H/W Tx scheduling setting (TXSCHED)
for multi-queue devices, from priority scheduling mode to a weighted
round robin mode with equal weights for all H/W Tx queues, and
addresses the issue above.

The TXSCHED setting may be changed at runtime, via sysfs, for devices
using multiple H/W Tx queues. For single queue devices this config
option is disabled, as the TXSCHED setting is superfluous in those cases.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c       |   11 +++-
 drivers/net/ethernet/freescale/gianfar.h       |   11 +++-
 drivers/net/ethernet/freescale/gianfar_sysfs.c |   71 ++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4d5b58c..a1b52ec 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -394,7 +394,13 @@ static void gfar_init_mac(struct net_device *ndev)
 	if (ndev->features & NETIF_F_IP_CSUM)
 		tctrl |= TCTRL_INIT_CSUM;
 
-	tctrl |= TCTRL_TXSCHED_PRIO;
+	if (priv->prio_sched_en)
+		tctrl |= TCTRL_TXSCHED_PRIO;
+	else {
+		tctrl |= TCTRL_TXSCHED_WRRS;
+		gfar_write(&regs->tr03wt, DEFAULT_WRRS_WEIGHT);
+		gfar_write(&regs->tr47wt, DEFAULT_WRRS_WEIGHT);
+	}
 
 	gfar_write(&regs->tctrl, tctrl);
 
@@ -1160,6 +1166,9 @@ static int gfar_probe(struct platform_device *ofdev)
 	priv->rx_filer_enable = 1;
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
+	/* use pritority h/w tx queue scheduling for single queue devices */
+	if (priv->num_tx_queues == 1)
+		priv->prio_sched_en = 1;
 
 	/* Carrier starts down, phylib will bring it up */
 	netif_carrier_off(dev);
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 2136c7f..4141ef2 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -301,8 +301,16 @@ extern const char gfar_driver_version[];
 #define TCTRL_TFCPAUSE		0x00000008
 #define TCTRL_TXSCHED_MASK	0x00000006
 #define TCTRL_TXSCHED_INIT	0x00000000
+/* priority scheduling */
 #define TCTRL_TXSCHED_PRIO	0x00000002
+/* weighted round-robin scheduling (WRRS) */
 #define TCTRL_TXSCHED_WRRS	0x00000004
+/* default WRRS weight and policy setting,
+ * tailored to the tr03wt and tr47wt registers:
+ * equal weight for all Tx Qs, measured in 64byte units
+ */
+#define DEFAULT_WRRS_WEIGHT	0x18181818
+
 #define TCTRL_INIT_CSUM		(TCTRL_TUCSEN | TCTRL_IPCSEN)
 
 #define IEVENT_INIT_CLEAR	0xffffffff
@@ -1098,7 +1106,8 @@ struct gfar_private {
 		extended_hash:1,
 		bd_stash_en:1,
 		rx_filer_enable:1,
-		wol_en:1; /* Wake-on-LAN enabled */
+		wol_en:1, /* Wake-on-LAN enabled */
+		prio_sched_en:1; /* Enable priorty based Tx scheduling in Hw */
 	unsigned short padding;
 
 	/* PHY stuff */
diff --git a/drivers/net/ethernet/freescale/gianfar_sysfs.c b/drivers/net/ethernet/freescale/gianfar_sysfs.c
index cd14a4d..b942bfc 100644
--- a/drivers/net/ethernet/freescale/gianfar_sysfs.c
+++ b/drivers/net/ethernet/freescale/gianfar_sysfs.c
@@ -319,6 +319,76 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 static DEVICE_ATTR(fifo_starve_off, 0644, gfar_show_fifo_starve_off,
 		   gfar_set_fifo_starve_off);
 
+static ssize_t gfar_show_tx_prio_sched(struct device *dev,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+
+	return sprintf(buf, "%s\n", priv->prio_sched_en ? "on" : "off");
+}
+
+static ssize_t gfar_set_tx_prio_sched(struct device *dev,
+				      struct device_attribute *attr,
+				      const char *buf, size_t count)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+	bool new_setting;
+
+	/* no changes if device doesn't have multiple Tx queues */
+	if (priv->num_tx_queues <= 1)
+		return count;
+
+	/* find out the new setting */
+	if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
+		new_setting = 1;
+	else if (!strncmp("off", buf, count - 1) ||
+		 !strncmp("0", buf, count - 1))
+		new_setting = 0;
+	else
+		return count;
+
+	if (priv->prio_sched_en == new_setting)
+		return count;
+
+	/* Only stop and start the controller if it isn't already
+	 * stopped and we're about to update TCTRL with the new Tx
+	 * schedulling policy
+	 */
+	if (ndev->flags & IFF_UP) {
+		unsigned long flags;
+
+		/* Halt TX and RX, and process the frames which
+		 * have already been received
+		 */
+		netif_tx_stop_all_queues(ndev);
+		local_irq_save(flags);
+		lock_tx_qs(priv);
+		lock_rx_qs(priv);
+
+		gfar_halt(ndev);
+
+		unlock_tx_qs(priv);
+		unlock_rx_qs(priv);
+		local_irq_restore(flags);
+
+		/* take down the rings to rebuild them */
+		stop_gfar(ndev);
+
+		priv->prio_sched_en = new_setting;
+
+		startup_gfar(ndev);
+		netif_tx_wake_all_queues(ndev);
+	} else
+		priv->prio_sched_en = new_setting;
+
+	return count;
+}
+
+static DEVICE_ATTR(tx_prio_sched, 0644, gfar_show_tx_prio_sched,
+		   gfar_set_tx_prio_sched);
+
 void gfar_init_sysfs(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -336,6 +406,7 @@ void gfar_init_sysfs(struct net_device *dev)
 	rc |= device_create_file(&dev->dev, &dev_attr_fifo_threshold);
 	rc |= device_create_file(&dev->dev, &dev_attr_fifo_starve);
 	rc |= device_create_file(&dev->dev, &dev_attr_fifo_starve_off);
+	rc |= device_create_file(&dev->dev, &dev_attr_tx_prio_sched);
 	if (rc)
 		dev_err(&dev->dev, "Error creating gianfar sysfs files.\n");
 }
-- 
1.7.6.5
