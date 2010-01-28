From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] be2net: Bug fix to support newer generation of BE ASIC
Date: Thu, 28 Jan 2010 13:26:44 +0530
Message-ID: <20100128075633.GA4785@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:28583 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754726Ab0A1H4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 02:56:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix in be2net for newer generation of BladeEngine ASIC.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    5 +++++
 drivers/net/benet/be_cmds.h |    3 ++-
 drivers/net/benet/be_main.c |   25 +++++++++++++++++++++++--
 3 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 9fd8e5e..5bc7459 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -276,8 +276,13 @@ struct be_adapter {
 	int link_speed;
 	u8 port_type;
 	u8 transceiver;
+	u8 generation;		/* BladeEngine ASIC generation */
 };
 
+/* BladeEngine Generation numbers */
+#define BE_GEN2 2
+#define BE_GEN3 3
+
 extern const struct ethtool_ops be_ethtool_ops;
 
 #define drvr_stats(adapter)		(&adapter->stats.drvr_stats)
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index c002b83..13b33c8 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -164,7 +164,8 @@ struct be_cmd_req_hdr {
 	u8 domain;		/* dword 0 */
 	u32 timeout;		/* dword 1 */
 	u32 request_length;	/* dword 2 */
-	u32 rsvd;		/* dword 3 */
+	u8 version;		/* dword 3 */
+	u8 rsvd[3];		/* dword 3 */
 };
 
 #define RESP_HDR_INFO_OPCODE_SHIFT	0	/* bits 0 - 7 */
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 33ab8c7..90c5661 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2051,6 +2051,7 @@ static void be_unmap_pci_bars(struct be_adapter *adapter)
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
 	u8 __iomem *addr;
+	int pcicfg_reg;
 
 	addr = ioremap_nocache(pci_resource_start(adapter->pdev, 2),
 			pci_resource_len(adapter->pdev, 2));
@@ -2064,8 +2065,13 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 		goto pci_map_err;
 	adapter->db = addr;
 
-	addr = ioremap_nocache(pci_resource_start(adapter->pdev, 1),
-			pci_resource_len(adapter->pdev, 1));
+	if (adapter->generation == BE_GEN2)
+		pcicfg_reg = 1;
+	else
+		pcicfg_reg = 0;
+
+	addr = ioremap_nocache(pci_resource_start(adapter->pdev, pcicfg_reg),
+			pci_resource_len(adapter->pdev, pcicfg_reg));
 	if (addr == NULL)
 		goto pci_map_err;
 	adapter->pcicfg = addr;
@@ -2162,6 +2168,7 @@ static int be_stats_init(struct be_adapter *adapter)
 	cmd->va = pci_alloc_consistent(adapter->pdev, cmd->size, &cmd->dma);
 	if (cmd->va == NULL)
 		return -1;
+	memset(cmd->va, cmd->size, 0);
 	return 0;
 }
 
@@ -2240,6 +2247,20 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		goto rel_reg;
 	}
 	adapter = netdev_priv(netdev);
+
+	switch (pdev->device) {
+	case BE_DEVICE_ID1:
+	case OC_DEVICE_ID1:
+		adapter->generation = BE_GEN2;
+		break;
+	case BE_DEVICE_ID2:
+	case OC_DEVICE_ID2:
+		adapter->generation = BE_GEN3;
+		break;
+	default:
+		adapter->generation = 0;
+	}
+
 	adapter->pdev = pdev;
 	pci_set_drvdata(pdev, adapter);
 	adapter->netdev = netdev;
-- 
1.6.3.3

