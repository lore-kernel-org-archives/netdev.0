From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 05/13] qla3xxx: Fix deadlock issue on error paths
Date: Mon, 26 Feb 2007 11:06:35 -0800
Message-ID: <11725168031232-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030461AbXBZTHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:44 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Li <benjamin.li@qlogic.com>

1) Fix deadlock issue when in QL_RESET_ACTIVE state and traversing
   through the Link State Machine
2) Fix deadlock issue when ethtool would call ql_get_settings()
3) Fix deadlock issue when adaptor is ifup'ed but adaptor fails to initialize

Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index b853669..59cebd6 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1388,6 +1388,8 @@ static void ql_link_state_machine(struct ql3_adapter *qdev)
 			printk(KERN_INFO PFX
 			       "%s: Reset in progress, skip processing link "
 			       "state.\n", qdev->ndev->name);
+
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);		
 		return;
 	}
 
@@ -1519,8 +1521,10 @@ static int ql_get_auto_cfg_status(struct ql3_adapter *qdev)
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+			 2) << 7)) {
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return 0;
+	}
 	status = ql_is_auto_cfg(qdev);
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
@@ -1534,8 +1538,10 @@ static u32 ql_get_speed(struct ql3_adapter *qdev)
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+			 2) << 7)) {
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return 0;
+	}
 	status = ql_get_link_speed(qdev);
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
@@ -1549,8 +1555,10 @@ static int ql_get_full_dup(struct ql3_adapter *qdev)
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+			 2) << 7)) {
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return 0;
+	}
 	status = ql_is_link_full_dup(qdev);
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
@@ -3312,6 +3320,7 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 err_init:
 	ql_sem_unlock(qdev, QL_DRVR_SEM_MASK);
 err_lock:
+	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	free_irq(qdev->pdev->irq, ndev);
 err_irq:
 	if (qdev->msi && test_bit(QL_MSI_ENABLED,&qdev->flags)) {
-- 
1.5.0.rc4.16.g9e258

