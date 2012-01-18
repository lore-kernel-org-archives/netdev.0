From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/4] enic: Add sriov vf device id checks in port
	profile code
Date: Wed, 18 Jan 2012 06:24:02 -0800
Message-ID: <20120118142400.7877.61121.stgit@rhel6.1>
References: <20120118142336.7877.67031.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:49555 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab2ARGkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 01:40:08 -0500
In-Reply-To: <20120118142336.7877.67031.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds checks for sriov vf's in enic port profile handling code.
sriov vf's are same as dynamic vnics but with a different device id.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index a634f58..9f37d92 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -444,7 +444,7 @@ static void enic_mtu_check(struct enic *enic)
 
 	if (mtu && mtu != enic->port_mtu) {
 		enic->port_mtu = mtu;
-		if (enic_is_dynamic(enic)) {
+		if (enic_is_dynamic(enic) || enic_is_sriov_vf(enic)) {
 			mtu = max_t(int, ENIC_MIN_MTU,
 				min_t(int, ENIC_MAX_MTU, mtu));
 			if (mtu != netdev->mtu)
@@ -856,7 +856,7 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 {
 	struct enic *enic = netdev_priv(netdev);
 
-	if (enic_is_dynamic(enic)) {
+	if (enic_is_dynamic(enic) || enic_is_sriov_vf(enic)) {
 		if (!is_valid_ether_addr(addr) && !is_zero_ether_addr(addr))
 			return -EADDRNOTAVAIL;
 	} else {
@@ -1615,7 +1615,7 @@ static int enic_open(struct net_device *netdev)
 	for (i = 0; i < enic->rq_count; i++)
 		vnic_rq_enable(&enic->rq[i]);
 
-	if (!enic_is_dynamic(enic))
+	if (!enic_is_dynamic(enic) && !enic_is_sriov_vf(enic))
 		enic_dev_add_station_addr(enic);
 
 	enic_set_rx_mode(netdev);
@@ -1666,7 +1666,7 @@ static int enic_stop(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 
-	if (!enic_is_dynamic(enic))
+	if (!enic_is_dynamic(enic) && !enic_is_sriov_vf(enic))
 		enic_dev_del_station_addr(enic);
 
 	for (i = 0; i < enic->wq_count; i++) {
@@ -1703,7 +1703,7 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 	if (new_mtu < ENIC_MIN_MTU || new_mtu > ENIC_MAX_MTU)
 		return -EINVAL;
 
-	if (enic_is_dynamic(enic))
+	if (enic_is_dynamic(enic) || enic_is_sriov_vf(enic))
 		return -EOPNOTSUPP;
 
 	if (running)
@@ -2433,7 +2433,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	 * called later by an upper layer.
 	 */
 
-	if (!enic_is_dynamic(enic)) {
+	if (!enic_is_dynamic(enic) && !enic_is_sriov_vf(enic)) {
 		err = vnic_dev_init(enic->vdev, 0);
 		if (err) {
 			dev_err(dev, "vNIC dev init failed, aborting\n");
@@ -2467,8 +2467,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	(void)enic_change_mtu(netdev, enic->port_mtu);
 
 #ifdef CONFIG_PCI_IOV
-	if (enic_is_dynamic(enic) && pdev->is_virtfn &&
-		is_zero_ether_addr(enic->mac_addr))
+	if (enic_is_sriov_vf(enic) && is_zero_ether_addr(enic->mac_addr))
 		random_ether_addr(enic->mac_addr);
 #endif
 
@@ -2481,7 +2480,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
 	enic->rx_coalesce_usecs = enic->tx_coalesce_usecs;
 
-	if (enic_is_dynamic(enic))
+	if (enic_is_dynamic(enic) || enic_is_sriov_vf(enic))
 		netdev->netdev_ops = &enic_netdev_dynamic_ops;
 	else
 		netdev->netdev_ops = &enic_netdev_ops;
