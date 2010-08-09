From: Dan Carpenter <error27@gmail.com>
Subject: [patch 2/2] qlcnic: using too much stack
Date: Mon, 9 Aug 2010 12:37:27 +0200
Message-ID: <20100809103727.GH9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, "David S. Miller" <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40151 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756092Ab0HIKjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 06:39:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qlcnic_pci_info structs are 128 bytes so an array of 8 uses 1024 bytes.
That's a lot if you run with 4K stacks.  I allocated them with kcalloc()
instead.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 7f27e2a..da84229 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -473,14 +473,20 @@ qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
 static int
 qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
-	struct qlcnic_pci_info pci_info[QLCNIC_MAX_PCI_FUNC];
+	struct qlcnic_pci_info *pci_info;
 	int i, ret = 0, err;
 	u8 pfn;
 
+	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
+	if (!pci_info)
+		return -ENOMEM;
+
 	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
 				QLCNIC_MAX_PCI_FUNC, GFP_KERNEL);
-	if (!adapter->npars)
-		return -ENOMEM;
+	if (!adapter->npars) {
+		err = -ENOMEM;
+		goto err_pci_info;
+	}
 
 	adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
 				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
@@ -508,6 +514,7 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
 		adapter->eswitch[i].flags |= QLCNIC_SWITCH_ENABLE;
 
+	kfree(pci_info);
 	return 0;
 
 err_eswitch:
@@ -516,6 +523,8 @@ err_eswitch:
 err_npars:
 	kfree(adapter->npars);
 	adapter->eswitch = NULL;
+err_pci_info:
+	kfree(pci_info);
 
 	return ret;
 }
@@ -3362,15 +3371,21 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_pci_func_cfg pci_cfg[QLCNIC_MAX_PCI_FUNC];
-	struct qlcnic_pci_info	pci_info[QLCNIC_MAX_PCI_FUNC];
+	struct qlcnic_pci_info *pci_info;
 	int i, ret;
 
 	if (size != sizeof(pci_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
+	if (!pci_info)
+		return -ENOMEM;
+
 	ret = qlcnic_get_pci_info(adapter, pci_info);
-	if (ret)
+	if (ret) {
+		kfree(pci_info);
 		return ret;
+	}
 
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
 		pci_cfg[i].pci_func = pci_info[i].id;
@@ -3381,8 +3396,8 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 		memcpy(&pci_cfg[i].def_mac_addr, &pci_info[i].mac, ETH_ALEN);
 	}
 	memcpy(buf, &pci_cfg, size);
+	kfree(pci_info);
 	return size;
-
 }
 static struct bin_attribute bin_attr_npar_config = {
 	.attr = {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
