From: Dan Carpenter <error27@gmail.com>
Subject: [patch 1/2] qlcnic: clean up qlcnic_init_pci_info()
Date: Mon, 9 Aug 2010 12:36:05 +0200
Message-ID: <20100809103542.GG9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, "David S. Miller" <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61239 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756070Ab0HIKge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 06:36:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the original code we allocated memory conditionally and freed it in
the error handling unconditionally.  It turns out that this function is
only called during initialization and "adapter->npars" and
"adapter->eswitch" are always NULL at the start of the function.  I
removed those checks.

Also since I was cleaning things, I changed the error handling for
qlcnic_get_pci_info() and pulled everything in an indent level.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index b9615bd..2b0bc95 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -477,44 +477,45 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 	int i, ret = 0, err;
 	u8 pfn;
 
-	if (!adapter->npars)
-		adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
+	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
 				QLCNIC_MAX_PCI_FUNC, GFP_KERNEL);
 	if (!adapter->npars)
 		return -ENOMEM;
 
-	if (!adapter->eswitch)
-		adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
+	adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
 				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
 	if (!adapter->eswitch) {
 		err = -ENOMEM;
-		goto err_eswitch;
+		goto err_npars;
 	}
 
 	ret = qlcnic_get_pci_info(adapter, pci_info);
-	if (!ret) {
-		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-			pfn = pci_info[i].id;
-			if (pfn > QLCNIC_MAX_PCI_FUNC)
-				return QL_STATUS_INVALID_PARAM;
-			adapter->npars[pfn].active = pci_info[i].active;
-			adapter->npars[pfn].type = pci_info[i].type;
-			adapter->npars[pfn].phy_port = pci_info[i].default_port;
-			adapter->npars[pfn].mac_learning = DEFAULT_MAC_LEARN;
-			adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
-			adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
-		}
-
-		for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
-			adapter->eswitch[i].flags |= QLCNIC_SWITCH_ENABLE;
+	if (ret)
+		goto err_eswitch;
 
-		return ret;
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		pfn = pci_info[i].id;
+		if (pfn > QLCNIC_MAX_PCI_FUNC)
+			return QL_STATUS_INVALID_PARAM;
+		adapter->npars[pfn].active = pci_info[i].active;
+		adapter->npars[pfn].type = pci_info[i].type;
+		adapter->npars[pfn].phy_port = pci_info[i].default_port;
+		adapter->npars[pfn].mac_learning = DEFAULT_MAC_LEARN;
+		adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
+		adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
 	}
 
+	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
+		adapter->eswitch[i].flags |= QLCNIC_SWITCH_ENABLE;
+
+	return 0;
+
+err_eswitch:
 	kfree(adapter->eswitch);
 	adapter->eswitch = NULL;
-err_eswitch:
+err_npars:
 	kfree(adapter->npars);
+	adapter->eswitch = NULL;
 
 	return ret;
 }
