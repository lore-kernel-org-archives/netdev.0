From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 11/12] qlcnic: rom lock recovery
Date: Thu, 19 Aug 2010 08:08:32 -0700
Message-ID: <1282230513-25286-12-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:59605 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753929Ab0HSPIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:35 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Fw can get stuck while holding pci semaphore. Driver will not
be able to perform fw initialization, without this lock.
Release semaphore forcefully in that case.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c   |    4 ++--
 drivers/net/qlcnic/qlcnic_init.c |   14 ++++++++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 9d40ce0..5e6f486 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -297,8 +297,8 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 			break;
 		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
 			dev_err(&adapter->pdev->dev,
-				"Failed to acquire sem=%d lock;reg_id=%d\n",
-				sem, id_reg);
+				"Failed to acquire sem=%d lock; holdby=%d\n",
+				sem, id_reg ? QLCRD32(adapter, id_reg) : -1);
 			return -EIO;
 		}
 		msleep(1);
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index e7a399f..a174521 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -928,15 +928,25 @@ qlcnic_get_bios_version(struct qlcnic_adapter *adapter)
 	return (bios_ver << 16) + ((bios_ver >> 8) & 0xff00) + (bios_ver >> 24);
 }
 
+static void qlcnic_rom_lock_recovery(struct qlcnic_adapter *adapter)
+{
+	if (qlcnic_pcie_sem_lock(adapter, 2, QLCNIC_ROM_LOCK_ID))
+		dev_info(&adapter->pdev->dev, "Resetting rom_lock\n");
+
+	qlcnic_pcie_sem_unlock(adapter, 2);
+}
+
 int
 qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
 {
 	u32 val, version, major, minor, build;
 
-	if (adapter->need_fw_reset)
+	if (qlcnic_check_fw_status(adapter)) {
+		qlcnic_rom_lock_recovery(adapter);
 		return 1;
+	}
 
-	if (qlcnic_check_fw_status(adapter))
+	if (adapter->need_fw_reset)
 		return 1;
 
 	/* check if we have got newer or different file firmware */
-- 
1.6.0.2

