From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 20/22] fjes: epstop_task
Date: Thu, 18 Jun 2015 09:49:45 +0900
Message-ID: <1434588587-25655-20-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds epstop_task.
This task is used to process other receiver's
cancellation request.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_hw.c   | 34 ++++++++++++++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_hw.h   |  1 +
 drivers/platform/x86/fjes/fjes_main.c |  1 +
 3 files changed, 36 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
index e07b266..c22679a 100644
--- a/drivers/platform/x86/fjes/fjes_hw.c
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -23,6 +23,7 @@
 #include "fjes.h"
 
 static void fjes_hw_update_zone_task(struct work_struct *);
+static void fjes_hw_epstop_task(struct work_struct *);
 
 /* supported MTU list */
 u32 fjes_support_mtu[] = {
@@ -334,6 +335,7 @@ int fjes_hw_init(struct fjes_hw *hw)
 	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
 
 	INIT_WORK(&hw->update_zone_task, fjes_hw_update_zone_task);
+	INIT_WORK(&hw->epstop_task, fjes_hw_epstop_task);
 
 	mutex_init(&hw->hw_info.lock);
 
@@ -364,6 +366,7 @@ void fjes_hw_exit(struct fjes_hw *hw)
 	fjes_hw_cleanup(hw);
 
 	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
 }
 
 static enum fjes_dev_command_response_e fjes_hw_issue_request_command(
@@ -1123,3 +1126,34 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 	}
 }
 
+static void fjes_hw_epstop_task(struct work_struct *work)
+{
+	struct fjes_hw *hw = container_of(work,
+			struct fjes_hw, epstop_task);
+	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	int epid_bit;
+	unsigned long remain_bit;
+
+	while ((remain_bit = hw->epstop_req_bit)) {
+
+		for (epid_bit = 0; remain_bit; (remain_bit >>= 1),
+			(epid_bit++)) {
+
+			if (remain_bit & 1) {
+
+				hw->ep_shm_info[epid_bit].
+					tx.info->v1i.rx_status |=
+						FJES_RX_STOP_REQ_DONE;
+
+				clear_bit(epid_bit, &hw->epstop_req_bit);
+				set_bit(epid_bit,
+					&adapter->unshare_watch_bitmask);
+
+				if (!work_pending(&adapter->unshare_watch_task))
+					queue_work(adapter->control_wq,
+						&adapter->unshare_watch_task);
+			}
+		}
+	}
+}
+
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
index 1b0afc0..e242a04 100644
--- a/drivers/platform/x86/fjes/fjes_hw.h
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -285,6 +285,7 @@ struct fjes_hw {
 	unsigned long txrx_stop_req_bit;
 	unsigned long epstop_req_bit;
 	struct work_struct update_zone_task;
+	struct work_struct epstop_task;
 
 	int my_epid;
 	int max_epid;
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 900aa65..f42441f 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -324,6 +324,7 @@ static int fjes_close(struct net_device *netdev)
 	cancel_work_sync(&adapter->tx_stall_task);
 
 	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
 
 	fjes_hw_wait_epstop(hw);
 
-- 
1.8.3.1

