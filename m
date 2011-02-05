From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 3/5] enic: Bug Fix: Reorder firmware devcmds -
	CMD_INIT and CMD_IG_VLAN_REWRITE_MODE
Date: Fri, 04 Feb 2011 18:17:16 -0800
Message-ID: <20110205021715.8510.40710.stgit@savbu-pc100.cisco.com>
References: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:25782 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab1BECRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 21:17:16 -0500
In-Reply-To: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Firmware requires CMD_IG_VLAN_REWRITE_MODE be issued before a CMD_INIT.

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |   28 ++++++++++++++++------------
 2 files changed, 17 insertions(+), 13 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index f38ad63..7316267 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.4"
+#define DRV_VERSION		"2.1.1.5"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 3893370..d6cdecc 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2359,13 +2359,6 @@ static int enic_dev_init(struct enic *enic)
 		goto err_out_free_vnic_resources;
 	}
 
-	err = enic_dev_set_ig_vlan_rewrite_mode(enic);
-	if (err) {
-		dev_err(dev,
-			"Failed to set ingress vlan rewrite mode, aborting.\n");
-		goto err_out_free_vnic_resources;
-	}
-
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	default:
 		netif_napi_add(netdev, &enic->napi[0], enic_poll, 64);
@@ -2504,6 +2497,22 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		goto err_out_vnic_unregister;
 	}
 
+	/* Setup devcmd lock
+	 */
+
+	spin_lock_init(&enic->devcmd_lock);
+
+	/*
+	 * Set ingress vlan rewrite mode before vnic initialization
+	 */
+
+	err = enic_dev_set_ig_vlan_rewrite_mode(enic);
+	if (err) {
+		dev_err(dev,
+			"Failed to set ingress vlan rewrite mode, aborting.\n");
+		goto err_out_dev_close;
+	}
+
 	/* Issue device init to initialize the vnic-to-switch link.
 	 * We'll start with carrier off and wait for link UP
 	 * notification later to turn on carrier.  We don't need
@@ -2527,11 +2536,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		}
 	}
 
-	/* Setup devcmd lock
-	 */
-
-	spin_lock_init(&enic->devcmd_lock);
-
 	err = enic_dev_init(enic);
 	if (err) {
 		dev_err(dev, "Device initialization failed, aborting\n");

