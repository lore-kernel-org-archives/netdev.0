From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/2] netxen_nic: Print ULA information
Date: Fri, 27 Sep 2013 01:42:26 -0400
Message-ID: <1380260547-25903-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1380260547-25903-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45779 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751203Ab3I0GMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 02:12:19 -0400
In-Reply-To: <1380260547-25903-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch reads CAMRAM(0x178) where FW writes a key for ULA and non-ULA
adapter and based on the key, driver logs the message.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_hdr.h    |    1 +
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   28 ++++++++++++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
index 32c7906..0c64c82 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
@@ -958,6 +958,7 @@ enum {
 #define NETXEN_PEG_HALT_STATUS2 	(NETXEN_CAM_RAM(0xac))
 #define NX_CRB_DEV_REF_COUNT		(NETXEN_CAM_RAM(0x138))
 #define NX_CRB_DEV_STATE		(NETXEN_CAM_RAM(0x140))
+#define NETXEN_ULA_KEY			(NETXEN_CAM_RAM(0x178))
 
 /* MiniDIMM related macros */
 #define NETXEN_DIMM_CAPABILITY		(NETXEN_CAM_RAM(0x258))
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index cbd75f9..5ec21c5 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1415,6 +1415,32 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 	return 0;
 }
 
+#define NETXEN_ULA_ADAPTER_KEY		(0xdaddad01)
+#define NETXEN_NON_ULA_ADAPTER_KEY	(0xdaddad00)
+
+static void netxen_read_ula_info(struct netxen_adapter *adapter)
+{
+	u32 temp;
+
+	/* Print ULA info only once for an adapter */
+	if (adapter->portnum != 0)
+		return;
+
+	temp = NXRD32(adapter, NETXEN_ULA_KEY);
+	switch (temp) {
+	case NETXEN_ULA_ADAPTER_KEY:
+		dev_info(&adapter->pdev->dev, "ULA adapter");
+		break;
+	case NETXEN_NON_ULA_ADAPTER_KEY:
+		dev_info(&adapter->pdev->dev, "non ULA adapter");
+		break;
+	default:
+		break;
+	}
+
+	return;
+}
+
 #ifdef CONFIG_PCIEAER
 static void netxen_mask_aer_correctable(struct netxen_adapter *adapter)
 {
@@ -1561,6 +1587,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_disable_msi;
 	}
 
+	netxen_read_ula_info(adapter);
+
 	err = netxen_setup_netdev(adapter, netdev);
 	if (err)
 		goto err_out_disable_msi;
-- 
1.5.6
