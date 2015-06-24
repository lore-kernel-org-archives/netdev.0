From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 20/22] fjes: epstop_task
Date: Wed, 24 Jun 2015 11:55:52 +0900
Message-ID: <1435114554-7151-21-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds epstop_task.
This task is used to process other receiver's
cancellation request.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c   | 30 ++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h   |  1 +
 drivers/net/fjes/fjes_main.c |  1 +
 3 files changed, 32 insertions(+)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 8756d3e..1c66218 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -23,6 +23,7 @@
 #include "fjes.h"
 
 static void fjes_hw_update_zone_task(struct work_struct *);
+static void fjes_hw_epstop_task(struct work_struct *);
 
 /* supported MTU list */
 const u32 fjes_support_mtu[] = {
@@ -326,6 +327,7 @@ int fjes_hw_init(struct fjes_hw *hw)
 	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
 
 	INIT_WORK(&hw->update_zone_task, fjes_hw_update_zone_task);
+	INIT_WORK(&hw->epstop_task, fjes_hw_epstop_task);
 
 	mutex_init(&hw->hw_info.lock);
 
@@ -356,6 +358,7 @@ void fjes_hw_exit(struct fjes_hw *hw)
 	fjes_hw_cleanup(hw);
 
 	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
 }
 
 static enum fjes_dev_command_response_e
@@ -1090,3 +1093,30 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 	}
 }
 
+static void fjes_hw_epstop_task(struct work_struct *work)
+{
+	struct fjes_hw *hw = container_of(work, struct fjes_hw, epstop_task);
+	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	int epid_bit;
+	unsigned long remain_bit;
+
+	while ((remain_bit = hw->epstop_req_bit)) {
+		for (epid_bit = 0; remain_bit; remain_bit >>= 1, epid_bit++) {
+			if (remain_bit & 1) {
+				hw->ep_shm_info[epid_bit].
+					tx.info->v1i.rx_status |=
+						FJES_RX_STOP_REQ_DONE;
+
+				clear_bit(epid_bit, &hw->epstop_req_bit);
+				set_bit(epid_bit,
+					&adapter->unshare_watch_bitmask);
+
+				if (!work_pending(&adapter->unshare_watch_task))
+					queue_work(
+						adapter->control_wq,
+						&adapter->unshare_watch_task);
+			}
+		}
+	}
+}
+
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index d80b8c8..4ef15ad 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -282,6 +282,7 @@ struct fjes_hw {
 	unsigned long txrx_stop_req_bit;
 	unsigned long epstop_req_bit;
 	struct work_struct update_zone_task;
+	struct work_struct epstop_task;
 
 	int my_epid;
 	int max_epid;
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index b37e909..df4a292 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -319,6 +319,7 @@ static int fjes_close(struct net_device *netdev)
 	cancel_work_sync(&adapter->tx_stall_task);
 
 	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
 
 	fjes_hw_wait_epstop(hw);
 
-- 
1.8.3.1

