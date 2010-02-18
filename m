From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] 3c5xx: use netdev_mc_* helpers
Date: Thu, 18 Feb 2010 10:12:15 +0100
Message-ID: <20100218091214.GC2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754324Ab0BRJMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 04:12:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/3c501.c |    2 +-
 drivers/net/3c505.c |    9 ++++-----
 drivers/net/3c515.c |    2 +-
 drivers/net/3c523.c |    9 ++++-----
 drivers/net/3c527.c |    8 ++------
 drivers/net/3c59x.c |    2 +-
 6 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 4d4cad3..b6de7b1 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -812,7 +812,7 @@ static void set_multicast_list(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		outb(RX_PROM, RX_CMD);
 		inb(RX_STATUS);
-	} else if (dev->mc_list || dev->flags & IFF_ALLMULTI) {
+	} else if (!netdev_mc_empty(dev) || dev->flags & IFF_ALLMULTI) {
 		/* Multicast or all multicast is the same */
 		outb(RX_MULT, RX_CMD);
 		inb(RX_STATUS);		/* Clear status. */
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index dadb46a..04b5bba 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1216,7 +1216,7 @@ static int elp_close(struct net_device *dev)
 static void elp_set_mc_list(struct net_device *dev)
 {
 	elp_device *adapter = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	int i;
 	unsigned long flags;
 
@@ -1230,10 +1230,9 @@ static void elp_set_mc_list(struct net_device *dev)
 		/* if num_addrs==0 the list will be cleared */
 		adapter->tx_pcb.command = CMD_LOAD_MULTICAST_LIST;
 		adapter->tx_pcb.length = 6 * netdev_mc_count(dev);
-		for (i = 0; i < netdev_mc_count(dev); i++) {
-			memcpy(adapter->tx_pcb.data.multicast[i], dmi->dmi_addr, 6);
-			dmi = dmi->next;
-		}
+		i = 0;
+		netdev_for_each_mc_addr(dmi, dev)
+			memcpy(adapter->tx_pcb.data.multicast[i++], dmi->dmi_addr, 6);
 		adapter->got[CMD_LOAD_MULTICAST_LIST] = 0;
 		if (!send_pcb(dev, &adapter->tx_pcb))
 			pr_err("%s: couldn't send set_multicast command\n", dev->name);
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 063b049..1e898b1 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -1536,7 +1536,7 @@ static void set_rx_mode(struct net_device *dev)
 			pr_debug("%s: Setting promiscuous mode.\n",
 			       dev->name);
 		new_mode = SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm;
-	} else if ((dev->mc_list) || (dev->flags & IFF_ALLMULTI)) {
+	} else if (!netdev_mc_empty(dev) || dev->flags & IFF_ALLMULTI) {
 		new_mode = SetRxFilter | RxStation | RxMulticast | RxBroadcast;
 	} else
 		new_mode = SetRxFilter | RxStation | RxBroadcast;
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 6948d66..beed4fa 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -625,7 +625,7 @@ static int init586(struct net_device *dev)
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	int num_addrs = netdev_mc_count(dev);
 
 	ptr = (void *) ((char *) p->scb + sizeof(struct scb_struct));
@@ -787,10 +787,9 @@ static int init586(struct net_device *dev)
 			mc_cmd->cmd_cmd = CMD_MCSETUP | CMD_LAST;
 			mc_cmd->cmd_link = 0xffff;
 			mc_cmd->mc_cnt = num_addrs * 6;
-			for (i = 0; i < num_addrs; i++) {
-				memcpy((char *) mc_cmd->mc_list[i], dmi->dmi_addr, 6);
-				dmi = dmi->next;
-			}
+			i = 0;
+			netdev_for_each_mc_addr(dmi, dev)
+				memcpy((char *) mc_cmd->mc_list[i++], dmi->dmi_addr, 6);
 			p->scb->cbl_offset = make16(mc_cmd);
 			p->scb->cmd = CUC_START;
 			elmc_id_attn586();
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index ce98269..5c07b14 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1533,9 +1533,7 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 	{
 		unsigned char block[62];
 		unsigned char *bp;
-		struct dev_mc_list *dmc=dev->mc_list;
-
-		int i;
+		struct dev_mc_list *dmc;
 
 		if(retry==0)
 			lp->mc_list_valid = 0;
@@ -1545,11 +1543,9 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 			block[0]=netdev_mc_count(dev);
 			bp=block+2;
 
-			for(i=0;i<netdev_mc_count(dev);i++)
-			{
+			netdev_for_each_mc_addr(dmc, dev) {
 				memcpy(bp, dmc->dmi_addr, 6);
 				bp+=6;
-				dmc=dmc->next;
 			}
 			if(mc32_command_nowait(dev, 2, block,
 					       2+6*netdev_mc_count(dev))==-1)
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 5df46c2..f965431 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2970,7 +2970,7 @@ static void set_rx_mode(struct net_device *dev)
 		if (vortex_debug > 3)
 			pr_notice("%s: Setting promiscuous mode.\n", dev->name);
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast|RxProm;
-	} else	if ((dev->mc_list)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else	if (!netdev_mc_empty(dev) || dev->flags & IFF_ALLMULTI) {
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast;
 	} else
 		new_mode = SetRxFilter | RxStation | RxBroadcast;
-- 
1.6.6

