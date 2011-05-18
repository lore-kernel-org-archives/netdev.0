From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Enable SR-IOV for Lancer
Date: Wed, 18 May 2011 18:56:22 +0530
Message-ID: <55d7e67f-84d8-4b3a-9d39-a68fab9a2a54@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Mammatha Edhala <mammatha.edhala@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:4469 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756255Ab1ERN1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 09:27:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mammatha Edhala <mammatha.edhala@emulex.com>

Enable SR-IOV for Lancer

Signed-off-by: Mammatha Edhala <mammatha.edhala@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be.h      |    5 ++++-
 drivers/net/benet/be_main.c |   17 +++++++++--------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 0b73dcf..a7db870 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -49,6 +49,7 @@
 #define OC_DEVICE_ID1		0x700	/* Device Id for BE2 cards */
 #define OC_DEVICE_ID2		0x710	/* Device Id for BE3 cards */
 #define OC_DEVICE_ID3		0xe220	/* Device id for Lancer cards */
+#define OC_DEVICE_ID4           0xe228   /* Device id for VF in Lancer */
 
 static inline char *nic_name(struct pci_dev *pdev)
 {
@@ -58,6 +59,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 	case OC_DEVICE_ID2:
 		return OC_NAME_BE;
 	case OC_DEVICE_ID3:
+	case OC_DEVICE_ID4:
 		return OC_NAME_LANCER;
 	case BE_DEVICE_ID2:
 		return BE3_NAME;
@@ -383,7 +385,8 @@ struct be_adapter {
 #define BE_GEN2 2
 #define BE_GEN3 3
 
-#define lancer_chip(adapter)		(adapter->pdev->device == OC_DEVICE_ID3)
+#define lancer_chip(adapter)	((adapter->pdev->device == OC_DEVICE_ID3) || \
+				 (adapter->pdev->device == OC_DEVICE_ID4))
 
 extern const struct ethtool_ops be_ethtool_ops;
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7322a51..ce6edac 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -42,6 +42,7 @@ static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID2) },
 	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID3)},
+	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID4)},
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -3161,7 +3162,8 @@ static int be_get_config(struct be_adapter *adapter)
 
 	memset(mac, 0, ETH_ALEN);
 
-	if (be_physfn(adapter)) {
+	/* A default permanent address is given to each VF for Lancer*/
+	if (be_physfn(adapter) || lancer_chip(adapter)) {
 		status = be_cmd_mac_addr_query(adapter, mac,
 			MAC_ADDRESS_TYPE_NETWORK, true /*permanent */, 0);
 
@@ -3203,6 +3205,7 @@ static int be_dev_family_check(struct be_adapter *adapter)
 		adapter->generation = BE_GEN3;
 		break;
 	case OC_DEVICE_ID3:
+	case OC_DEVICE_ID4:
 		pci_read_config_dword(pdev, SLI_INTF_REG_OFFSET, &sli_intf);
 		if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
 						SLI_INTF_IF_TYPE_SHIFT;
@@ -3212,10 +3215,6 @@ static int be_dev_family_check(struct be_adapter *adapter)
 			dev_err(&pdev->dev, "SLI_INTF reg val is not valid\n");
 			return -EINVAL;
 		}
-		if (num_vfs > 0) {
-			dev_err(&pdev->dev, "VFs not supported\n");
-			return -EINVAL;
-		}
 		adapter->sli_family = ((sli_intf & SLI_INTF_FAMILY_MASK) >>
 					 SLI_INTF_FAMILY_SHIFT);
 		adapter->generation = BE_GEN3;
@@ -3381,9 +3380,11 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		bool link_up;
 		u16 vf, lnk_speed;
 
-		status = be_vf_eth_addr_config(adapter);
-		if (status)
-			goto unreg_netdev;
+		if (!lancer_chip(adapter)) {
+			status = be_vf_eth_addr_config(adapter);
+			if (status)
+				goto unreg_netdev;
+		}
 
 		for (vf = 0; vf < num_vfs; vf++) {
 			status = be_cmd_link_status_query(adapter, &link_up,
-- 
1.6.0.2

