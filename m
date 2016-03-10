From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: pci: Implement reset done check
Date: Thu, 10 Mar 2016 23:10:21 +0100
Message-ID: <1457647821-2839-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38084 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932441AbcCJWKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 17:10:25 -0500
Received: by mail-wm0-f53.google.com with SMTP id l68so5469787wml.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 14:10:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Firmware now tells us that the reset is done by passing a magic value
via register. Use it to shorten the wait in case this is supported.
With old firmware, we still wait until the timeout is reached.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 15 +++++++++++----
 drivers/net/ethernet/mellanox/mlxsw/pci.h |  3 +++
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 7992c55..7f4173c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1681,11 +1681,18 @@ static const struct mlxsw_bus mlxsw_pci_bus = {
 
 static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci)
 {
+	unsigned long end;
+
 	mlxsw_pci_write32(mlxsw_pci, SW_RESET, MLXSW_PCI_SW_RESET_RST_BIT);
-	/* Current firware does not let us know when the reset is done.
-	 * So we just wait here for constant time and hope for the best.
-	 */
-	msleep(MLXSW_PCI_SW_RESET_TIMEOUT_MSECS);
+	wmb(); /* reset needs to be written before we read control register */
+	end = jiffies + msecs_to_jiffies(MLXSW_PCI_SW_RESET_TIMEOUT_MSECS);
+	do {
+		u32 val = mlxsw_pci_read32(mlxsw_pci, FW_READY);
+
+		if ((val & MLXSW_PCI_FW_READY_MASK) == MLXSW_PCI_FW_READY_MAGIC)
+			break;
+		cond_resched();
+	} while (time_before(jiffies, end));
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
index 9121060..d942a3e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -61,6 +61,9 @@
 #define MLXSW_PCI_SW_RESET			0xF0010
 #define MLXSW_PCI_SW_RESET_RST_BIT		BIT(0)
 #define MLXSW_PCI_SW_RESET_TIMEOUT_MSECS	5000
+#define MLXSW_PCI_FW_READY			0xA1844
+#define MLXSW_PCI_FW_READY_MASK			0xFF
+#define MLXSW_PCI_FW_READY_MAGIC		0x5E
 
 #define MLXSW_PCI_DOORBELL_SDQ_OFFSET		0x000
 #define MLXSW_PCI_DOORBELL_RDQ_OFFSET		0x200
-- 
2.5.0
