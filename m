From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: qlge: convert to hw_features
Date: Tue, 19 Apr 2011 01:31:21 +0200 (CEST)
Message-ID: <20110418233121.2FF0113A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46017 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753491Ab1DRXbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 19:31:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another simple conversion.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/qlge/qlge_ethtool.c |   34 -------------------------------=
---
 drivers/net/qlge/qlge_main.c    |   21 ++++++++-------------
 2 files changed, 8 insertions(+), 47 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_et=
htool.c
index 687754d..78dc40c 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -655,32 +655,6 @@ static int ql_set_pauseparam(struct net_device *ne=
tdev,
 	return status;
 }
=20
-static u32 ql_get_rx_csum(struct net_device *netdev)
-{
-	struct ql_adapter *qdev =3D netdev_priv(netdev);
-	return qdev->rx_csum;
-}
-
-static int ql_set_rx_csum(struct net_device *netdev, uint32_t data)
-{
-	struct ql_adapter *qdev =3D netdev_priv(netdev);
-	qdev->rx_csum =3D data;
-	return 0;
-}
-
-static int ql_set_tso(struct net_device *ndev, uint32_t data)
-{
-
-	if (data) {
-		ndev->features |=3D NETIF_F_TSO;
-		ndev->features |=3D NETIF_F_TSO6;
-	} else {
-		ndev->features &=3D ~NETIF_F_TSO;
-		ndev->features &=3D ~NETIF_F_TSO6;
-	}
-	return 0;
-}
-
 static u32 ql_get_msglevel(struct net_device *ndev)
 {
 	struct ql_adapter *qdev =3D netdev_priv(ndev);
@@ -707,14 +681,6 @@ const struct ethtool_ops qlge_ethtool_ops =3D {
 	.self_test		 =3D ql_self_test,
 	.get_pauseparam		 =3D ql_get_pauseparam,
 	.set_pauseparam		 =3D ql_set_pauseparam,
-	.get_rx_csum =3D ql_get_rx_csum,
-	.set_rx_csum =3D ql_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ql_set_tso,
 	.get_coalesce =3D ql_get_coalesce,
 	.set_coalesce =3D ql_set_coalesce,
 	.get_sset_count =3D ql_get_sset_count,
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index f61e717..6c9d124 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1571,7 +1571,7 @@ static void ql_process_mac_rx_page(struct ql_adap=
ter *qdev,
 	skb->protocol =3D eth_type_trans(skb, ndev);
 	skb_checksum_none_assert(skb);
=20
-	if (qdev->rx_csum &&
+	if ((ndev->features & NETIF_F_RXCSUM) &&
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
 		/* TCP frame. */
 		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
@@ -1684,7 +1684,7 @@ static void ql_process_mac_rx_skb(struct ql_adapt=
er *qdev,
 	/* If rx checksum is on, and there are no
 	 * csum or frame errors.
 	 */
-	if (qdev->rx_csum &&
+	if ((ndev->features & NETIF_F_RXCSUM) &&
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
 		/* TCP frame. */
 		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
@@ -2004,7 +2004,7 @@ static void ql_process_mac_split_rx_intr(struct q=
l_adapter *qdev,
 	/* If rx checksum is on, and there are no
 	 * csum or frame errors.
 	 */
-	if (qdev->rx_csum &&
+	if ((ndev->features & NETIF_F_RXCSUM) &&
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
 		/* TCP frame. */
 		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
@@ -4621,7 +4621,6 @@ static int __devinit ql_init_device(struct pci_de=
v *pdev,
 	/*
 	 * Set up the operating parameters.
 	 */
-	qdev->rx_csum =3D 1;
 	qdev->workqueue =3D create_singlethread_workqueue(ndev->name);
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
@@ -4695,15 +4694,11 @@ static int __devinit qlge_probe(struct pci_dev =
*pdev,
=20
 	qdev =3D netdev_priv(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-	ndev->features =3D (0
-			  | NETIF_F_IP_CSUM
-			  | NETIF_F_SG
-			  | NETIF_F_TSO
-			  | NETIF_F_TSO6
-			  | NETIF_F_TSO_ECN
-			  | NETIF_F_HW_VLAN_TX
-			  | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER);
-	ndev->features |=3D NETIF_F_GRO;
+	ndev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN |
+		NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
+	ndev->features =3D ndev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
=20
 	if (test_bit(QL_DMA64, &qdev->flags))
 		ndev->features |=3D NETIF_F_HIGHDMA;
--=20
1.7.2.5

