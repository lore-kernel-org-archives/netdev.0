From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 01/12] netxen: refresh firmware info after reset
Date: Sun, 26 Jul 2009 23:07:36 -0700
Message-ID: <1248674867-18821-2-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33556 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751106AbZG0GHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:47 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o move dma mask update to netxen_start_firmware() so that
  if firmware changes across suspend (e.g. file -> flash)
  it reflects right dma mask.
o re-read firmware capabilities after firmware reset.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |    3 +++
 drivers/net/netxen/netxen_nic_init.c |    4 ----
 drivers/net/netxen/netxen_nic_main.c |    9 ++++-----
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index b9123d4..3c614c3 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2047,6 +2047,9 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 		dev_info(&pdev->dev, "firmware running in %s mode\n",
 		adapter->ahw.cut_through ? "cut-through" : "legacy");
 	}
+
+	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222))
+		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
 }
 
 int
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 5d3343e..847f78b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1083,10 +1083,6 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 	NXWR32(adapter, CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
 	NXWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
-	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222)) {
-		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
-	}
-
 	return err;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 637ac8b..4c7e4c2 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -764,6 +764,10 @@ wait_init:
 		return err;
 	}
 
+	nx_update_dma_mask(adapter);
+
+	netxen_nic_get_firmware_info(adapter);
+
 	return 0;
 }
 
@@ -1071,11 +1075,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = netxen_start_firmware(adapter, 1);
 	if (err)
 		goto err_out_iounmap;
-
-	nx_update_dma_mask(adapter);
-
-	netxen_nic_get_firmware_info(adapter);
-
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
-- 
1.6.0.2

