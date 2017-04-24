From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 2/6] qed/qede: Enable tunnel offloads based on hw configuration
Date: Mon, 24 Apr 2017 10:00:45 -0700
Message-ID: <20170424170049.16027-3-manish.chopra@cavium.com>
References: <20170424170049.16027-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0089.outbound.protection.outlook.com ([104.47.33.89]:48256
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S975232AbdDXRB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:01:26 -0400
In-Reply-To: <20170424170049.16027-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables tunnel feature offloads based on hw configuration
at initialization time instead of enabling them always.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c     | 15 +++++++++++
 drivers/net/ethernet/qlogic/qede/qede_filter.c |  6 +++++
 drivers/net/ethernet/qlogic/qede/qede_main.c   | 36 ++++++++++++++++++--------
 include/linux/qed/qed_if.h                     |  5 ++++
 4 files changed, 51 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index a622d75..e650281 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -230,10 +230,25 @@ static int qed_init_pci(struct qed_dev *cdev, struct pci_dev *pdev)
 int qed_fill_dev_info(struct qed_dev *cdev,
 		      struct qed_dev_info *dev_info)
 {
+	struct qed_tunnel_info *tun = &cdev->tunnel;
 	struct qed_ptt  *ptt;
 
 	memset(dev_info, 0, sizeof(struct qed_dev_info));
 
+	if (tun->vxlan.tun_cls == QED_TUNN_CLSS_MAC_VLAN &&
+	    tun->vxlan.b_mode_enabled)
+		dev_info->vxlan_enable = true;
+
+	if (tun->l2_gre.b_mode_enabled && tun->ip_gre.b_mode_enabled &&
+	    tun->l2_gre.tun_cls == QED_TUNN_CLSS_MAC_VLAN &&
+	    tun->ip_gre.tun_cls == QED_TUNN_CLSS_MAC_VLAN)
+		dev_info->gre_enable = true;
+
+	if (tun->l2_geneve.b_mode_enabled && tun->ip_geneve.b_mode_enabled &&
+	    tun->l2_geneve.tun_cls == QED_TUNN_CLSS_MAC_VLAN &&
+	    tun->ip_geneve.tun_cls == QED_TUNN_CLSS_MAC_VLAN)
+		dev_info->geneve_enable = true;
+
 	dev_info->num_hwfns = cdev->num_hwfns;
 	dev_info->pci_mem_start = cdev->pci_params.mem_start;
 	dev_info->pci_mem_end = cdev->pci_params.mem_end;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 34473fb..23e0c16 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -887,6 +887,9 @@ void qede_udp_tunnel_add(struct net_device *dev, struct udp_tunnel_info *ti)
 
 	switch (ti->type) {
 	case UDP_TUNNEL_TYPE_VXLAN:
+		if (!edev->dev_info.common.vxlan_enable)
+			return;
+
 		if (edev->vxlan_dst_port)
 			return;
 
@@ -898,6 +901,9 @@ void qede_udp_tunnel_add(struct net_device *dev, struct udp_tunnel_info *ti)
 		set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
 		break;
 	case UDP_TUNNEL_TYPE_GENEVE:
+		if (!edev->dev_info.common.geneve_enable)
+			return;
+
 		if (edev->geneve_dst_port)
 			return;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 02b305c..42f043b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -609,6 +609,7 @@ static void qede_init_ndev(struct qede_dev *edev)
 {
 	struct net_device *ndev = edev->ndev;
 	struct pci_dev *pdev = edev->pdev;
+	bool udp_tunnel_enable = false;
 	netdev_features_t hw_features;
 
 	pci_set_drvdata(pdev, ndev);
@@ -631,20 +632,33 @@ static void qede_init_ndev(struct qede_dev *edev)
 		      NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		      NETIF_F_TSO | NETIF_F_TSO6;
 
-	/* Encap features*/
-	hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
-		       NETIF_F_TSO_ECN | NETIF_F_GSO_UDP_TUNNEL_CSUM |
-		       NETIF_F_GSO_GRE_CSUM;
-
 	if (!IS_VF(edev) && edev->dev_info.common.num_hwfns == 1)
 		hw_features |= NETIF_F_NTUPLE;
 
-	ndev->hw_enc_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO_ECN |
-				NETIF_F_TSO6 | NETIF_F_GSO_GRE |
-				NETIF_F_GSO_UDP_TUNNEL | NETIF_F_RXCSUM |
-				NETIF_F_GSO_UDP_TUNNEL_CSUM |
-				NETIF_F_GSO_GRE_CSUM;
+	if (edev->dev_info.common.vxlan_enable ||
+	    edev->dev_info.common.geneve_enable)
+		udp_tunnel_enable = true;
+
+	if (udp_tunnel_enable || edev->dev_info.common.gre_enable) {
+		hw_features |= NETIF_F_TSO_ECN;
+		ndev->hw_enc_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+					NETIF_F_SG | NETIF_F_TSO |
+					NETIF_F_TSO_ECN | NETIF_F_TSO6 |
+					NETIF_F_RXCSUM;
+	}
+
+	if (udp_tunnel_enable) {
+		hw_features |= (NETIF_F_GSO_UDP_TUNNEL |
+				NETIF_F_GSO_UDP_TUNNEL_CSUM);
+		ndev->hw_enc_features |= (NETIF_F_GSO_UDP_TUNNEL |
+					  NETIF_F_GSO_UDP_TUNNEL_CSUM);
+	}
+
+	if (edev->dev_info.common.gre_enable) {
+		hw_features |= (NETIF_F_GSO_GRE | NETIF_F_GSO_GRE_CSUM);
+		ndev->hw_enc_features |= (NETIF_F_GSO_GRE |
+					  NETIF_F_GSO_GRE_CSUM);
+	}
 
 	ndev->vlan_features = hw_features | NETIF_F_RXHASH | NETIF_F_RXCSUM |
 			      NETIF_F_HIGHDMA;
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 9f966be895..5544d7b 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -338,6 +338,11 @@ struct qed_dev_info {
 	bool wol_support;
 
 	enum qed_dev_type dev_type;
+
+	/* Output parameters for qede */
+	bool		vxlan_enable;
+	bool		gre_enable;
+	bool		geneve_enable;
 };
 
 enum qed_sb_type {
-- 
2.7.2
