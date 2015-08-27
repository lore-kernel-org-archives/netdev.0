From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/3] mlxsw: Make mailboxes 4KB aligned
Date: Thu, 27 Aug 2015 17:59:57 +0200
Message-ID: <1440691197-25780-4-git-send-email-jiri@resnulli.us>
References: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34759 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbH0QAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 12:00:05 -0400
Received: by widdq5 with SMTP id dq5so82538307wid.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 09:00:04 -0700 (PDT)
In-Reply-To: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The HW-SW contract requires mailboxes passed to the firmware to be 4KB
aligned. Previously, these mailboxes were mapped using streaming DMA
routines, which do not guarantee the bus addresses to be 4KB aligned.
Under certain conditions this constraint was indeed violated and errors
were observed.

By using consistent DMA mapping routines together with a mailbox size of
4KB we are guaranteed not to violate the constraint.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 83 +++++++++++++++++++------------
 1 file changed, 50 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 045f98f..462cea3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -46,6 +46,7 @@
 #include <linux/log2.h>
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
+#include <linux/string.h>
 
 #include "pci.h"
 #include "core.h"
@@ -174,6 +175,8 @@ struct mlxsw_pci {
 		struct mlxsw_pci_mem_item *items;
 	} fw_area;
 	struct {
+		struct mlxsw_pci_mem_item out_mbox;
+		struct mlxsw_pci_mem_item in_mbox;
 		struct mutex lock; /* Lock access to command registers */
 		bool nopoll;
 		wait_queue_head_t wait;
@@ -1341,6 +1344,32 @@ static irqreturn_t mlxsw_pci_eq_irq_handler(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static int mlxsw_pci_mbox_alloc(struct mlxsw_pci *mlxsw_pci,
+				struct mlxsw_pci_mem_item *mbox)
+{
+	struct pci_dev *pdev = mlxsw_pci->pdev;
+	int err = 0;
+
+	mbox->size = MLXSW_CMD_MBOX_SIZE;
+	mbox->buf = pci_alloc_consistent(pdev, MLXSW_CMD_MBOX_SIZE,
+					 &mbox->mapaddr);
+	if (!mbox->buf) {
+		dev_err(&pdev->dev, "Failed allocating memory for mailbox\n");
+		err = -ENOMEM;
+	}
+
+	return err;
+}
+
+static void mlxsw_pci_mbox_free(struct mlxsw_pci *mlxsw_pci,
+				struct mlxsw_pci_mem_item *mbox)
+{
+	struct pci_dev *pdev = mlxsw_pci->pdev;
+
+	pci_free_consistent(pdev, MLXSW_CMD_MBOX_SIZE, mbox->buf,
+			    mbox->mapaddr);
+}
+
 static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 			  const struct mlxsw_config_profile *profile)
 {
@@ -1358,6 +1387,15 @@ static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 	mbox = mlxsw_cmd_mbox_alloc();
 	if (!mbox)
 		return -ENOMEM;
+
+	err = mlxsw_pci_mbox_alloc(mlxsw_pci, &mlxsw_pci->cmd.in_mbox);
+	if (err)
+		goto mbox_put;
+
+	err = mlxsw_pci_mbox_alloc(mlxsw_pci, &mlxsw_pci->cmd.out_mbox);
+	if (err)
+		goto err_out_mbox_alloc;
+
 	err = mlxsw_cmd_query_fw(mlxsw_core, mbox);
 	if (err)
 		goto err_query_fw;
@@ -1420,6 +1458,9 @@ err_fw_area_init:
 err_doorbell_page_bar:
 err_iface_rev:
 err_query_fw:
+	mlxsw_pci_mbox_free(mlxsw_pci, &mlxsw_pci->cmd.out_mbox);
+err_out_mbox_alloc:
+	mlxsw_pci_mbox_free(mlxsw_pci, &mlxsw_pci->cmd.in_mbox);
 mbox_put:
 	mlxsw_cmd_mbox_free(mbox);
 	return err;
@@ -1432,6 +1473,8 @@ static void mlxsw_pci_fini(void *bus_priv)
 	free_irq(mlxsw_pci->msix_entry.vector, mlxsw_pci);
 	mlxsw_pci_aqs_fini(mlxsw_pci);
 	mlxsw_pci_fw_area_fini(mlxsw_pci);
+	mlxsw_pci_mbox_free(mlxsw_pci, &mlxsw_pci->cmd.out_mbox);
+	mlxsw_pci_mbox_free(mlxsw_pci, &mlxsw_pci->cmd.in_mbox);
 }
 
 static struct mlxsw_pci_queue *
@@ -1524,8 +1567,8 @@ static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
 			      u8 *p_status)
 {
 	struct mlxsw_pci *mlxsw_pci = bus_priv;
-	dma_addr_t in_mapaddr = 0;
-	dma_addr_t out_mapaddr = 0;
+	dma_addr_t in_mapaddr = mlxsw_pci->cmd.in_mbox.mapaddr;
+	dma_addr_t out_mapaddr = mlxsw_pci->cmd.out_mbox.mapaddr;
 	bool evreq = mlxsw_pci->cmd.nopoll;
 	unsigned long timeout = msecs_to_jiffies(MLXSW_PCI_CIR_TIMEOUT_MSECS);
 	bool *p_wait_done = &mlxsw_pci->cmd.wait_done;
@@ -1537,27 +1580,11 @@ static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
 	if (err)
 		return err;
 
-	if (in_mbox) {
-		in_mapaddr = pci_map_single(mlxsw_pci->pdev, in_mbox,
-					    in_mbox_size, PCI_DMA_TODEVICE);
-		if (unlikely(pci_dma_mapping_error(mlxsw_pci->pdev,
-						   in_mapaddr))) {
-			err = -EIO;
-			goto err_in_mbox_map;
-		}
-	}
+	if (in_mbox)
+		memcpy(mlxsw_pci->cmd.in_mbox.buf, in_mbox, in_mbox_size);
 	mlxsw_pci_write32(mlxsw_pci, CIR_IN_PARAM_HI, in_mapaddr >> 32);
 	mlxsw_pci_write32(mlxsw_pci, CIR_IN_PARAM_LO, in_mapaddr);
 
-	if (out_mbox) {
-		out_mapaddr = pci_map_single(mlxsw_pci->pdev, out_mbox,
-					     out_mbox_size, PCI_DMA_FROMDEVICE);
-		if (unlikely(pci_dma_mapping_error(mlxsw_pci->pdev,
-						   out_mapaddr))) {
-			err = -EIO;
-			goto err_out_mbox_map;
-		}
-	}
 	mlxsw_pci_write32(mlxsw_pci, CIR_OUT_PARAM_HI, out_mapaddr >> 32);
 	mlxsw_pci_write32(mlxsw_pci, CIR_OUT_PARAM_LO, out_mapaddr);
 
@@ -1601,7 +1628,7 @@ static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
 	}
 
 	if (!err && out_mbox && out_mbox_direct) {
-		/* Some commands does not use output param as address to mailbox
+		/* Some commands don't use output param as address to mailbox
 		 * but they store output directly into registers. In that case,
 		 * copy registers into mbox buffer.
 		 */
@@ -1615,19 +1642,9 @@ static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
 							   CIR_OUT_PARAM_LO));
 			memcpy(out_mbox + sizeof(tmp), &tmp, sizeof(tmp));
 		}
-	}
-
-	if (out_mapaddr)
-		pci_unmap_single(mlxsw_pci->pdev, out_mapaddr, out_mbox_size,
-				 PCI_DMA_FROMDEVICE);
-
-	/* fall through */
+	} else if (!err && out_mbox)
+		memcpy(out_mbox, mlxsw_pci->cmd.out_mbox.buf, out_mbox_size);
 
-err_out_mbox_map:
-	if (in_mapaddr)
-		pci_unmap_single(mlxsw_pci->pdev, in_mapaddr, in_mbox_size,
-				 PCI_DMA_TODEVICE);
-err_in_mbox_map:
 	mutex_unlock(&mlxsw_pci->cmd.lock);
 
 	return err;
-- 
1.9.3
