From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4/cxgb4vf: Add set VF mac address support
Date: Thu, 30 Jun 2016 16:30:48 +0530
Message-ID: <1467284449-28499-3-git-send-email-hariprasad@chelsio.com>
References: <1467284449-28499-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:18013 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751927AbcF3LEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 07:04:16 -0400
In-Reply-To: <1467284449-28499-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ndo_set_vf_mac support which allows to set the MAC address
for cxgb4vf interfaces from the host.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   33 ++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   42 +++++++++++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   24 ++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    3 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   63 ++++++++++++++++++--
 6 files changed, 161 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b4fceb9..f38735f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1520,4 +1520,7 @@ void t4_idma_monitor_init(struct adapter *adapter,
 void t4_idma_monitor(struct adapter *adapter,
 		     struct sge_idma_monitor_state *idma,
 		     int hz, int ticks);
+int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int pf, unsigned int vf,
+		      unsigned int naddr, u8 *addr);
+
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c45de49..d719c75 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3078,6 +3078,35 @@ static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 	return ret;
 }
 
+#ifdef CONFIG_PCI_IOV
+#define CXGB_PF_WITH_VF 4
+
+static int cxgb_set_vf_mac(struct net_device *dev, int pf, int vf, u8 *mac)
+{
+	struct port_info *pi = netdev_priv(dev);
+
+	/* validate the request */
+	if (pf >= CXGB_PF_WITH_VF) {
+		dev_err(pi->adapter->pdev_dev,
+			"Invalid PF Identifier %d\n", pf);
+		return -EINVAL;
+	}
+
+	/* verify MAC addr is valid */
+	if (!is_zero_ether_addr(mac) && !is_valid_ether_addr(mac) &&
+	    is_multicast_ether_addr(mac)) {
+		dev_err(pi->adapter->pdev_dev,
+			"Invalid Ethernet address %pM for PF %d VF %d\n",
+			mac, pf, vf);
+		return -EINVAL;
+	}
+
+	dev_info(pi->adapter->pdev_dev,
+		 "Setting MAC %pM on PF %d VF %d\n", mac, pf, vf);
+	return t4_set_vf_mac_acl(pi->adapter, pf, vf + 1, 1, mac);
+}
+#endif
+
 static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 {
 	int ret;
@@ -3136,7 +3165,9 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll        = cxgb_busy_poll,
 #endif
-
+#ifdef CONFIG_PCI_IOV
+	.ndo_set_vf_mac       = cxgb_set_vf_mac,
+#endif
 };
 
 void t4_fatal_err(struct adapter *adap)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a63addb..a92e74a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -8262,3 +8262,45 @@ void t4_idma_monitor(struct adapter *adapter,
 		t4_sge_decode_idma_state(adapter, idma->idma_state[i]);
 	}
 }
+
+/**
+ *	t4_set_vf_mac - Set MAC address for the specified VF
+ *	@adapter: The adapter
+ *	@pf: the PF
+ *	@vf: one of the VFs instantiated by the specified PF
+ *	@naddr: the number of MAC addresses
+ *	@addr: the MAC address(es) to be set to the specified VF
+ */
+int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int pf, unsigned int vf,
+		      unsigned int naddr, u8 *addr)
+{
+	struct fw_acl_mac_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_ACL_MAC_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_WRITE_F |
+				    FW_ACL_MAC_CMD_PFN_V(pf) |
+				    FW_ACL_MAC_CMD_VFN_V(vf));
+
+	/* Note: Do not enable the ACL */
+	cmd.en_to_len16 = cpu_to_be32((unsigned int)FW_LEN16(cmd));
+	cmd.nmac = naddr;
+
+	switch (pf) {
+	case 3:
+		memcpy(cmd.macaddr3, addr, sizeof(cmd.macaddr3));
+		break;
+	case 2:
+		memcpy(cmd.macaddr2, addr, sizeof(cmd.macaddr2));
+		break;
+	case 1:
+		memcpy(cmd.macaddr1, addr, sizeof(cmd.macaddr1));
+		break;
+	case 0:
+		memcpy(cmd.macaddr0, addr, sizeof(cmd.macaddr0));
+		break;
+	}
+
+	return t4_wr_mbox(adapter, adapter->mbox, &cmd, sizeof(cmd), &cmd);
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 8d9b2cb..eadf9b1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2695,6 +2695,7 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	struct adapter *adapter;
 	struct port_info *pi;
 	struct net_device *netdev;
+	unsigned int pf;
 
 	/*
 	 * Print our driver banner the first time we're called to initialize a
@@ -2819,8 +2820,11 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 * Allocate our "adapter ports" and stitch everything together.
 	 */
 	pmask = adapter->params.vfres.pmask;
+	pf = t4vf_get_pf_from_vf(adapter); 
 	for_each_port(adapter, pidx) {
 		int port_id, viid;
+		u8 mac[ETH_ALEN];
+		unsigned int naddr = 1;
 
 		/*
 		 * We simplistically allocate our virtual interfaces
@@ -2891,6 +2895,26 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 				pidx);
 			goto err_free_dev;
 		}
+
+		err = t4vf_get_vf_mac_acl(adapter, pf, &naddr, mac);
+		if (err) {
+			dev_err(&pdev->dev,
+				"unable to determine MAC ACL address, "
+				"continuing anyway.. (status %d)\n", err);
+		} else if (naddr && adapter->params.vfres.nvi == 1) {
+			struct sockaddr addr;
+
+			ether_addr_copy(addr.sa_data, mac);
+			err = cxgb4vf_set_mac_addr(netdev, &addr);
+			if (err) {
+				dev_err(&pdev->dev,
+					"unable to set MAC address %pM\n",
+					mac);
+				goto err_free_dev;
+			}
+			dev_info(&pdev->dev,
+				 "Using assigned MAC ACL: %pM\n", mac);
+		}
 	}
 
 	/* See what interrupts we'll be using.  If we've been configured to
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 438374a..b880401 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -346,6 +346,7 @@ int t4vf_bar2_sge_qregs(struct adapter *adapter,
 			u64 *pbar2_qoffset,
 			unsigned int *pbar2_qid);
 
+unsigned int t4vf_get_pf_from_vf(struct adapter *);
 int t4vf_get_sge_params(struct adapter *);
 int t4vf_get_vpd_params(struct adapter *);
 int t4vf_get_dev_params(struct adapter *);
@@ -380,5 +381,7 @@ int t4vf_eth_eq_free(struct adapter *, unsigned int);
 
 int t4vf_handle_fw_rpl(struct adapter *, const __be64 *);
 int t4vf_prep_adapter(struct adapter *);
+int t4vf_get_vf_mac_acl(struct adapter *adapter, unsigned int pf,
+			unsigned int *naddr, u8 *addr);
 
 #endif /* __T4VF_COMMON_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 955ff7c..9895bd2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -583,6 +583,15 @@ int t4vf_bar2_sge_qregs(struct adapter *adapter,
 	return 0;
 }
 
+unsigned int t4vf_get_pf_from_vf(struct adapter *adapter)
+{
+        u32 whoami;
+
+        whoami = t4_read_reg(adapter, T4VF_PL_BASE_ADDR + PL_VF_WHOAMI_A);
+        return (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5 ?
+			SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami));
+}
+
 /**
  *	t4vf_get_sge_params - retrieve adapter Scatter gather Engine parameters
  *	@adapter: the adapter
@@ -660,7 +669,6 @@ int t4vf_get_sge_params(struct adapter *adapter)
 	 * read.
 	 */
 	if (!is_t4(adapter->params.chip)) {
-		u32 whoami;
 		unsigned int pf, s_hps, s_qpp;
 
 		params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
@@ -684,11 +692,7 @@ int t4vf_get_sge_params(struct adapter *adapter)
 		 * register we just read. Do it once here so other code in
 		 * the driver can just use it.
 		 */
-		whoami = t4_read_reg(adapter,
-				     T4VF_PL_BASE_ADDR + PL_VF_WHOAMI_A);
-		pf = CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5 ?
-			SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami);
-
+		pf = t4vf_get_pf_from_vf(adapter);
 		s_hps = (HOSTPAGESIZEPF0_S +
 			 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * pf);
 		sge_params->sge_vf_hps =
@@ -1749,3 +1753,50 @@ int t4vf_prep_adapter(struct adapter *adapter)
 
 	return 0;
 }
+
+/**
+ *	t4vf_get_vf_mac_acl - Get the MAC address to be set to
+ *			      the VI of this VF.
+ *	@adapter: The adapter
+ *	@pf: The pf associated with vf 
+ *	@naddr: the number of ACL MAC addresses returned in addr
+ *	@addr: Placeholder for MAC addresses
+ *
+ *	Find the MAC address to be set to the VF's VI. The requested MAC address
+ *	is from the host OS via callback in the PF driver.
+ */
+int t4vf_get_vf_mac_acl(struct adapter *adapter, unsigned int pf,
+			unsigned int *naddr, u8 *addr)
+{
+	struct fw_acl_mac_cmd cmd;
+	int ret;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_ACL_MAC_CMD) |
+				    FW_CMD_REQUEST_F |
+				    FW_CMD_READ_F);
+	cmd.en_to_len16 = cpu_to_be32((unsigned int)FW_LEN16(cmd));
+	ret = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &cmd);
+	if (ret)
+		return ret;
+
+	if (cmd.nmac < *naddr)
+		*naddr = cmd.nmac;
+
+	switch (pf) {
+	case 3:
+		memcpy(addr, cmd.macaddr3, sizeof(cmd.macaddr3));
+		break;
+	case 2:
+		memcpy(addr, cmd.macaddr2, sizeof(cmd.macaddr2));
+		break;
+	case 1:
+		memcpy(addr, cmd.macaddr1, sizeof(cmd.macaddr1));
+		break;
+	case 0:
+		memcpy(addr, cmd.macaddr0, sizeof(cmd.macaddr0));
+		break;
+	}
+
+	return ret;
+}
-- 
1.7.3
