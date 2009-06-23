From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: fix firmware init handshake
Date: Mon, 22 Jun 2009 23:26:21 -0700
Message-ID: <1245738381-30163-2-git-send-email-dhananjay@netxen.com>
References: <1245738381-30163-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:51580 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751495AbZFWG0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 02:26:23 -0400
In-Reply-To: <1245738381-30163-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure all functions run firmware init handshake.

If PCI function 0 fails to initialize firmware, mark the
state failed so that other functions on the same board
bail out quickly instead of waiting 30s for firmware
handshake.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |   37 ++++++++++++++++++---------------
 drivers/net/netxen/netxen_nic_main.c |    3 +-
 2 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index bdb143d..055bb61 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -944,28 +944,31 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 	u32 val = 0;
 	int retries = 60;
 
-	if (!pegtune_val) {
-		do {
-			val = NXRD32(adapter, CRB_CMDPEG_STATE);
+	if (pegtune_val)
+		return 0;
 
-			if (val == PHAN_INITIALIZE_COMPLETE ||
-				val == PHAN_INITIALIZE_ACK)
-				return 0;
+	do {
+		val = NXRD32(adapter, CRB_CMDPEG_STATE);
 
-			msleep(500);
+		switch (val) {
+		case PHAN_INITIALIZE_COMPLETE:
+		case PHAN_INITIALIZE_ACK:
+			return 0;
+		case PHAN_INITIALIZE_FAILED:
+			goto out_err;
+		default:
+			break;
+		}
 
-		} while (--retries);
+		msleep(500);
 
-		if (!retries) {
-			pegtune_val = NXRD32(adapter,
-					NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
-			printk(KERN_WARNING "netxen_phantom_init: init failed, "
-					"pegtune_val=%x\n", pegtune_val);
-			return -1;
-		}
-	}
+	} while (--retries);
 
-	return 0;
+	NXWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
+
+out_err:
+	dev_warn(&adapter->pdev->dev, "firmware init failed\n");
+	return -EIO;
 }
 
 static int
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 43ac333..2919a2d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -705,7 +705,7 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 		first_driver = (adapter->ahw.pci_func == 0);
 
 	if (!first_driver)
-		return 0;
+		goto wait_init;
 
 	first_boot = NXRD32(adapter, NETXEN_CAM_RAM(0x1fc));
 
@@ -752,6 +752,7 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 		| (_NETXEN_NIC_LINUX_SUBVERSION);
 	NXWR32(adapter, CRB_DRIVER_VERSION, val);
 
+wait_init:
 	/* Handshake with the card before we register the devices. */
 	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	if (err) {
-- 
1.6.0.2

