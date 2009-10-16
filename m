From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 6/7] netxen: fix error codes in for tools access
Date: Thu, 15 Oct 2009 23:09:12 -0700
Message-ID: <1255673353-31797-7-git-send-email-dhananjay@netxen.com>
References: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45979 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754490AbZJPGKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 02:10:31 -0400
In-Reply-To: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use -EIO or -EINVAL as error codes, these can get passed up
to applications (tools).

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |   49 +++++++++++++++++----------------
 drivers/net/netxen/netxen_nic_init.c |    6 ++++
 2 files changed, 31 insertions(+), 24 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index ce07d13..320ded9 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -332,7 +332,7 @@ netxen_pcie_sem_lock(struct netxen_adapter *adapter, int sem, u32 id_reg)
 		if (done == 1)
 			break;
 		if (++timeout >= NETXEN_PCIE_SEM_TIMEOUT)
-			return -1;
+			return -EIO;
 		msleep(1);
 	}
 
@@ -1083,7 +1083,7 @@ netxen_nic_pci_set_crbwindow_128M(struct netxen_adapter *adapter,
 }
 
 /*
- * Return -1 if off is not valid,
+ * Returns < 0 if off is not valid,
  *	 1 if window access is needed. 'off' is set to offset from
  *	   CRB space in 128M pci map
  *	 0 if no window access is needed. 'off' is set to 2M addr
@@ -1096,7 +1096,7 @@ netxen_nic_pci_get_crb_addr_2M(struct netxen_adapter *adapter, ulong *off)
 
 
 	if (*off >= NETXEN_CRB_MAX)
-		return -1;
+		return -EINVAL;
 
 	if (*off >= NETXEN_PCI_CAMQM && (*off < NETXEN_PCI_CAMQM_2M_END)) {
 		*off = (*off - NETXEN_PCI_CAMQM) + NETXEN_PCI_CAMQM_2M_BASE +
@@ -1105,7 +1105,7 @@ netxen_nic_pci_get_crb_addr_2M(struct netxen_adapter *adapter, ulong *off)
 	}
 
 	if (*off < NETXEN_PCI_CRBSPACE)
-		return -1;
+		return -EINVAL;
 
 	*off -= NETXEN_PCI_CRBSPACE;
 
@@ -1220,25 +1220,26 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter, ulong off, u32 data)
 
 	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off);
 
-	if (rv == -1) {
-		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
-				__func__, off);
-		dump_stack();
-		return -1;
+	if (rv == 0) {
+		writel(data, (void __iomem *)off);
+		return 0;
 	}
 
-	if (rv == 1) {
+	if (rv > 0) {
+		/* indirect access */
 		write_lock_irqsave(&adapter->ahw.crb_lock, flags);
 		crb_win_lock(adapter);
 		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
 		writel(data, (void __iomem *)off);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->ahw.crb_lock, flags);
-	} else
-		writel(data, (void __iomem *)off);
-
+		return 0;
+	}
 
-	return 0;
+	dev_err(&adapter->pdev->dev,
+			"%s: invalid offset: 0x%016lx\n", __func__, off);
+	dump_stack();
+	return -EIO;
 }
 
 static u32
@@ -1250,24 +1251,24 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off)
 
 	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off);
 
-	if (rv == -1) {
-		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
-				__func__, off);
-		dump_stack();
-		return -1;
-	}
+	if (rv == 0)
+		return readl((void __iomem *)off);
 
-	if (rv == 1) {
+	if (rv > 0) {
+		/* indirect access */
 		write_lock_irqsave(&adapter->ahw.crb_lock, flags);
 		crb_win_lock(adapter);
 		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
 		data = readl((void __iomem *)off);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->ahw.crb_lock, flags);
-	} else
-		data = readl((void __iomem *)off);
+		return data;
+	}
 
-	return data;
+	dev_err(&adapter->pdev->dev,
+			"%s: invalid offset: 0x%016lx\n", __func__, off);
+	dump_stack();
+	return -1;
 }
 
 /* window 1 registers only */
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index a524844..d8c4b70 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -832,6 +832,12 @@ void netxen_request_firmware(struct netxen_adapter *adapter)
 		goto request_fw;
 	}
 
+	if (NX_IS_REVISION_P3P(adapter->ahw.revision_id)) {
+		/* No file firmware for the time being */
+		fw_type = NX_FLASH_ROMIMAGE;
+		goto done;
+	}
+
 	fw_type = netxen_p3_has_mn(adapter) ?
 		NX_P3_MN_ROMIMAGE : NX_P3_CT_ROMIMAGE;
 
-- 
1.6.0.2

