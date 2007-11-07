From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/2] qla3xxx:  bugfix: Move link state machine into a worker thread
Date: Wed,  7 Nov 2007 13:59:06 -0800
Message-ID: <1194472747331-git-send-email-ron.mercer@qlogic.com>
References: <20071107215608.GB7090@linux-7mw0.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:29948 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbXKGV7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 16:59:09 -0500
In-Reply-To: <20071107215608.GB7090@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The link state machine requires access to some resources that
are shared with the iSCSI function on the chip.  (See iSCSI
driver at drivers/scsi/qla4xxx)  If the interface is being
up/downed at a rapid pace this driver may need to sleep
waiting to get access to the common resources. For this we
are moving the state machine to run as a work thread.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   27 +++++++++++++--------------
 drivers/net/qla3xxx.h |    1 +
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 30adf72..4f0fd41 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1645,8 +1645,11 @@ static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 	return 0;
 }
 
-static void ql_link_state_machine(struct ql3_adapter *qdev)
+static void ql_link_state_machine_work(struct work_struct *work)
 {
+	struct ql3_adapter *qdev =
+		container_of(work, struct ql3_adapter, link_state_work.work);
+
 	u32 curr_link_state;
 	unsigned long hw_flags;
 
@@ -1661,6 +1664,10 @@ static void ql_link_state_machine(struct ql3_adapter *qdev)
 			       "state.\n", qdev->ndev->name);
 
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+
+		/* Restart timer on 2 second interval. */
+		mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);\
+
 		return;
 	}
 
@@ -1705,6 +1712,9 @@ static void ql_link_state_machine(struct ql3_adapter *qdev)
 		break;
 	}
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+
+	/* Restart timer on 2 second interval. */
+	mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
 }
 
 /*
@@ -3941,19 +3951,7 @@ static void ql_get_board_info(struct ql3_adapter *qdev)
 static void ql3xxx_timer(unsigned long ptr)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)ptr;
-
-	if (test_bit(QL_RESET_ACTIVE,&qdev->flags)) {
-		printk(KERN_DEBUG PFX
-		       "%s: Reset in progress.\n",
-		       qdev->ndev->name);
-		goto end;
-	}
-
-	ql_link_state_machine(qdev);
-
-	/* Restart timer on 2 second interval. */
-end:
-	mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
+	queue_delayed_work(qdev->workqueue, &qdev->link_state_work, 0);
 }
 
 static int __devinit ql3xxx_probe(struct pci_dev *pdev,
@@ -4103,6 +4101,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	qdev->workqueue = create_singlethread_workqueue(ndev->name);
 	INIT_DELAYED_WORK(&qdev->reset_work, ql_reset_work);
 	INIT_DELAYED_WORK(&qdev->tx_timeout_work, ql_tx_timeout_work);
+	INIT_DELAYED_WORK(&qdev->link_state_work, ql_link_state_machine_work);
 
 	init_timer(&qdev->adapter_timer);
 	qdev->adapter_timer.function = ql3xxx_timer;
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index fbcb0b9..d0ffb30 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1286,6 +1286,7 @@ struct ql3_adapter {
 	struct workqueue_struct *workqueue;
 	struct delayed_work reset_work;
 	struct delayed_work tx_timeout_work;
+	struct delayed_work link_state_work;
 	u32 max_frame_size;
 	u32 device_id;
 	u16 phyType;
-- 
1.5.0.rc4.16.g9e258

