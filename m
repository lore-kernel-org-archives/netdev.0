From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 4/7] netxen: fix cmd ring init
Date: Fri,  1 Aug 2008 03:14:58 -0700
Message-ID: <1217585701-13958-5-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:42819 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753190AbYHAKPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 06:15:06 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize producer and consumer indices during netdev open(), only
for old firmware/chip.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 320d010..311a4bd 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -702,13 +702,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->status   &= ~NETXEN_NETDEV_STATUS;
 	adapter->rx_csum = 1;
 	adapter->mc_enabled = 0;
-	if (NX_IS_REVISION_P3(revision_id)) {
+	if (NX_IS_REVISION_P3(revision_id))
 		adapter->max_mc_count = 38;
-		adapter->max_rds_rings = 2;
-	} else {
+	else
 		adapter->max_mc_count = 16;
-		adapter->max_rds_rings = 3;
-	}
 
 	netdev->open		   = netxen_nic_open;
 	netdev->stop		   = netxen_nic_close;
@@ -781,10 +778,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		if (adapter->portnum == 0)
 			first_driver = 1;
 	}
-	adapter->crb_addr_cmd_producer = crb_cmd_producer[adapter->portnum];
-	adapter->crb_addr_cmd_consumer = crb_cmd_consumer[adapter->portnum];
-	netxen_nic_update_cmd_producer(adapter, 0);
-	netxen_nic_update_cmd_consumer(adapter, 0);
 
 	if (first_driver) {
 		first_boot = adapter->pci_read_normalize(adapter,
@@ -1055,6 +1048,11 @@ static int netxen_nic_open(struct net_device *netdev)
 			return -EIO;
 		}
 
+		if (adapter->fw_major < 4)
+			adapter->max_rds_rings = 3;
+		else
+			adapter->max_rds_rings = 2;
+
 		err = netxen_alloc_sw_resources(adapter);
 		if (err) {
 			printk(KERN_ERR "%s: Error in setting sw resources\n",
@@ -1076,10 +1074,10 @@ static int netxen_nic_open(struct net_device *netdev)
 				crb_cmd_producer[adapter->portnum];
 			adapter->crb_addr_cmd_consumer =
 				crb_cmd_consumer[adapter->portnum];
-		}
 
-		netxen_nic_update_cmd_producer(adapter, 0);
-		netxen_nic_update_cmd_consumer(adapter, 0);
+			netxen_nic_update_cmd_producer(adapter, 0);
+			netxen_nic_update_cmd_consumer(adapter, 0);
+		}
 
 		for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 			for (ring = 0; ring < adapter->max_rds_rings; ring++)
-- 
1.5.4.3

