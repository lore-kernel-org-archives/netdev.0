From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/8] qlge: Expand coverage of hw lock for config register.
Date: Thu,  2 Jul 2009 09:06:06 -0700
Message-ID: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbZGBQLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware semaphore covers the configuration register as well as the
ICB registers.  The ICB high and low regs contain the address of the
initialization control block and the config register is used to signal
the hardware that a block is ready to be downloaded.  Currently we were
only protecting the ICB regs.  This changes expands to cover the config
register as well.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 90d1f76..7f37267 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -214,6 +214,10 @@ int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
 		return -ENOMEM;
 	}
 
+	status = ql_sem_spinlock(qdev, SEM_ICB_MASK);
+	if (status)
+		return status;
+
 	status = ql_wait_cfg(qdev, bit);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR,
@@ -221,12 +225,8 @@ int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
 		goto exit;
 	}
 
-	status = ql_sem_spinlock(qdev, SEM_ICB_MASK);
-	if (status)
-		goto exit;
 	ql_write32(qdev, ICB_L, (u32) map);
 	ql_write32(qdev, ICB_H, (u32) (map >> 32));
-	ql_sem_unlock(qdev, SEM_ICB_MASK);	/* does flush too */
 
 	mask = CFG_Q_MASK | (bit << 16);
 	value = bit | (q_id << CFG_Q_SHIFT);
@@ -237,6 +237,7 @@ int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
 	 */
 	status = ql_wait_cfg(qdev, bit);
 exit:
+	ql_sem_unlock(qdev, SEM_ICB_MASK);	/* does flush too */
 	pci_unmap_single(qdev->pdev, map, size, direction);
 	return status;
 }
-- 
1.6.0.2

