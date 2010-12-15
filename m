From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 01/12] cxgb4: enable PCIe relaxed ordering
Date: Tue, 14 Dec 2010 23:36:44 -0800
Message-ID: <1292398615-26527-2-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18942 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICG004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:18 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7auLw026577
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:56 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7au2m026576
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:56 -0800
In-Reply-To: <1292398615-26527-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable relaxed ordering for descriptor reads and packet I/O.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   14 ++++++++++++++
 drivers/net/cxgb4/sge.c        |    5 +++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 848f89d..953d62a 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3535,6 +3535,19 @@ static void __devinit print_port_info(struct adapter *adap)
 	}
 }
 
+static void __devinit enable_pcie_relaxed_ordering(struct pci_dev *dev)
+{
+	u16 v;
+	int pos;
+
+	pos = pci_pcie_cap(dev);
+	if (pos > 0) {
+		pci_read_config_word(dev, pos + PCI_EXP_DEVCTL, &v);
+		v |= PCI_EXP_DEVCTL_RELAX_EN;
+		pci_write_config_word(dev, pos + PCI_EXP_DEVCTL, v);
+	}
+}
+
 /*
  * Free the following resources:
  * - memory used for tables
@@ -3609,6 +3622,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	}
 
 	pci_enable_pcie_error_reporting(pdev);
+	enable_pcie_relaxed_ordering(pdev);
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 1702225..cc0b997 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -2014,6 +2014,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 
 		flsz = fl->size / 8 + STAT_LEN / sizeof(struct tx_desc);
 		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_FL0PACKEN |
+					    FW_IQ_CMD_FL0FETCHRO(1) |
+					    FW_IQ_CMD_FL0DATARO(1) |
 					    FW_IQ_CMD_FL0PADEN);
 		c.fl0dcaen_to_fl0cidxfthresh = htons(FW_IQ_CMD_FL0FBMIN(2) |
 				FW_IQ_CMD_FL0FBMAX(3));
@@ -2106,6 +2108,7 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 	c.viid_pkd = htonl(FW_EQ_ETH_CMD_VIID(pi->viid));
 	c.fetchszm_to_iqid = htonl(FW_EQ_ETH_CMD_HOSTFCMODE(2) |
 				   FW_EQ_ETH_CMD_PCIECHN(pi->tx_chan) |
+				   FW_EQ_ETH_CMD_FETCHRO(1) |
 				   FW_EQ_ETH_CMD_IQID(iqid));
 	c.dcaen_to_eqsize = htonl(FW_EQ_ETH_CMD_FBMIN(2) |
 				  FW_EQ_ETH_CMD_FBMAX(3) |
@@ -2158,6 +2161,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 	c.physeqid_pkd = htonl(0);
 	c.fetchszm_to_iqid = htonl(FW_EQ_CTRL_CMD_HOSTFCMODE(2) |
 				   FW_EQ_CTRL_CMD_PCIECHN(pi->tx_chan) |
+				   FW_EQ_CTRL_CMD_FETCHRO |
 				   FW_EQ_CTRL_CMD_IQID(iqid));
 	c.dcaen_to_eqsize = htonl(FW_EQ_CTRL_CMD_FBMIN(2) |
 				  FW_EQ_CTRL_CMD_FBMAX(3) |
@@ -2207,6 +2211,7 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 				 FW_EQ_OFLD_CMD_EQSTART | FW_LEN16(c));
 	c.fetchszm_to_iqid = htonl(FW_EQ_OFLD_CMD_HOSTFCMODE(2) |
 				   FW_EQ_OFLD_CMD_PCIECHN(pi->tx_chan) |
+				   FW_EQ_OFLD_CMD_FETCHRO(1) |
 				   FW_EQ_OFLD_CMD_IQID(iqid));
 	c.dcaen_to_eqsize = htonl(FW_EQ_OFLD_CMD_FBMIN(2) |
 				  FW_EQ_OFLD_CMD_FBMAX(3) |
-- 
1.5.4

