From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v1] gianfar: Change default HW Tx queue scheduling mode
Date: Mon, 24 Sep 2012 11:39:08 +0300
Message-ID: <1348475948-22721-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:53006
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751298Ab2IXIj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 04:39:27 -0400
Received: from mail35-co1 (localhost [127.0.0.1])	by mail35-co1-R.bigfish.com
 (Postfix) with ESMTP id B1BE35C00DD	for <netdev@vger.kernel.org>; Mon, 24 Sep
 2012 08:39:26 +0000 (UTC)
Received: from CO1EHSMHS010.bigfish.com (unknown [10.243.78.245])	by
 mail35-co1.bigfish.com (Postfix) with ESMTP id 0CCFB40047	for
 <netdev@vger.kernel.org>; Mon, 24 Sep 2012 08:39:24 +0000 (UTC)
Received: from zro04-ws574.ea.freescale.net ([10.213.130.145])	by
 az84smr01.freescale.net (8.14.3/8.14.0) with ESMTP id q8O8dINH018659	for
 <netdev@vger.kernel.org>; Mon, 24 Sep 2012 01:39:19 -0700
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

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v1: removed runtime config option of tx scheduling mode (i.e. prio_sched_en)
	(to be provided in a distinct patch)

 drivers/net/ethernet/freescale/gianfar.c |   11 ++++++++++-
 drivers/net/ethernet/freescale/gianfar.h |   11 ++++++++++-
 2 files changed, 20 insertions(+), 2 deletions(-)

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
-- 
1.7.6.5
