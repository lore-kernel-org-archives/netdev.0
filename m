From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 05/12] cxgb4: print port information after registering each netdev
Date: Tue, 14 Dec 2010 23:36:48 -0800
Message-ID: <1292398615-26527-6-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
 <1292398615-26527-3-git-send-email-dm@chelsio.com>
 <1292398615-26527-4-git-send-email-dm@chelsio.com>
 <1292398615-26527-5-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4472 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICO004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:19 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7aujW026593
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:56 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7auIX026592
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:56 -0800
In-Reply-To: <1292398615-26527-5-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print information about each port when its netdev is registered instead
of looping separately over the ports at the end.  The bulk of this patch
is due to indentation change.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   54 ++++++++++++++++-----------------------
 1 files changed, 22 insertions(+), 32 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 3f33d51..089b753 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3490,50 +3490,41 @@ static int __devinit init_rss(struct adapter *adap)
 	return 0;
 }
 
-static void __devinit print_port_info(struct adapter *adap)
+static void __devinit print_port_info(const struct net_device *dev)
 {
 	static const char *base[] = {
 		"R XFI", "R XAUI", "T SGMII", "T XFI", "T XAUI", "KX4", "CX4",
 		"KX", "KR", "R SFP+", "KR/KX", "KR/KX/KX4"
 	};
 
-	int i;
 	char buf[80];
+	char *bufp = buf;
 	const char *spd = "";
+	const struct port_info *pi = netdev_priv(dev);
+	const struct adapter *adap = pi->adapter;
 
 	if (adap->params.pci.speed == PCI_EXP_LNKSTA_CLS_2_5GB)
 		spd = " 2.5 GT/s";
 	else if (adap->params.pci.speed == PCI_EXP_LNKSTA_CLS_5_0GB)
 		spd = " 5 GT/s";
 
-	for_each_port(adap, i) {
-		struct net_device *dev = adap->port[i];
-		const struct port_info *pi = netdev_priv(dev);
-		char *bufp = buf;
-
-		if (!test_bit(i, &adap->registered_device_map))
-			continue;
-
-		if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_100M)
-			bufp += sprintf(bufp, "100/");
-		if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_1G)
-			bufp += sprintf(bufp, "1000/");
-		if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_10G)
-			bufp += sprintf(bufp, "10G/");
-		if (bufp != buf)
-			--bufp;
-		sprintf(bufp, "BASE-%s", base[pi->port_type]);
-
-		netdev_info(dev, "Chelsio %s rev %d %s %sNIC PCIe x%d%s%s\n",
-			    adap->params.vpd.id, adap->params.rev,
-			    buf, is_offload(adap) ? "R" : "",
-			    adap->params.pci.width, spd,
-			    (adap->flags & USING_MSIX) ? " MSI-X" :
-			    (adap->flags & USING_MSI) ? " MSI" : "");
-		if (adap->name == dev->name)
-			netdev_info(dev, "S/N: %s, E/C: %s\n",
-				    adap->params.vpd.sn, adap->params.vpd.ec);
-	}
+	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_100M)
+		bufp += sprintf(bufp, "100/");
+	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_1G)
+		bufp += sprintf(bufp, "1000/");
+	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_10G)
+		bufp += sprintf(bufp, "10G/");
+	if (bufp != buf)
+		--bufp;
+	sprintf(bufp, "BASE-%s", base[pi->port_type]);
+
+	netdev_info(dev, "Chelsio %s rev %d %s %sNIC PCIe x%d%s%s\n",
+		    adap->params.vpd.id, adap->params.rev, buf,
+		    is_offload(adap) ? "R" : "", adap->params.pci.width, spd,
+		    (adap->flags & USING_MSIX) ? " MSI-X" :
+		    (adap->flags & USING_MSI) ? " MSI" : "");
+	netdev_info(dev, "S/N: %s, E/C: %s\n",
+		    adap->params.vpd.sn, adap->params.vpd.ec);
 }
 
 static void __devinit enable_pcie_relaxed_ordering(struct pci_dev *dev)
@@ -3753,6 +3744,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 			__set_bit(i, &adapter->registered_device_map);
 			adapter->chan_map[pi->tx_chan] = i;
+			print_port_info(adapter->port[i]);
 		}
 	}
 	if (!adapter->registered_device_map) {
@@ -3769,8 +3761,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 	if (is_offload(adapter))
 		attach_ulds(adapter);
 
-	print_port_info(adapter);
-
 sriov:
 #ifdef CONFIG_PCI_IOV
 	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
-- 
1.5.4

