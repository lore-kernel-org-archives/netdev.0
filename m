From: yuweizheng@139.com
Subject: [PATCH] Repair soft lockup with monitor mode of ath9k_htc card
Date: Thu, 29 Jan 2015 07:14:32 +0800
Message-ID: <1422486872-16308-1-git-send-email-yuweizheng@139.com>
Cc: netdev@vger.kernel.org, Yuwei Zheng <yuweizheng@139.com>,
	Yuwei Zheng <zhengyuwei@360.cn>
To: linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org, kvalo@codeaurora.org,
	ath9k-devel@qca.qualcomm.com, linux@rempel-privat.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from n9-22.mail.139.com ([221.176.9.22]:63219 "EHLO
	n9-22.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760800AbbA3Kdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 05:33:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuwei Zheng <yuweizheng@139.com>

In the environment with heavy wifi traffic, set the ar9271 into monitor mode, will
trigger a deadloop panic.
 
The ath9k_hif_usb_rx_cb function excute on  the interrupt context, and ath9k_rx_tasklet excute
on the soft irq context. In other words, the ath9k_hif_usb_rx_cb have more chance to excute than
ath9k_rx_tasklet.  So in the worst condition,  the rx.rxbuf receive list is always full,
and the do {}while(true) loop will not be break. The kernel get a soft lockup panic. 
 
[59011.007210] BUG: soft lockup - CPU#0 stuck for 23s!
[kworker/0:0:30609]
[59011.030560] BUG: scheduling while atomic: kworker/0:0/30609/0x40010100
[59013.804486] BUG: scheduling while atomic: kworker/0:0/30609/0x40010100
[59013.858522] Kernel panic - not syncing: softlockup: hung tasks
 
[59014.038891] Exception stack(0xdf4bbc38 to 0xdf4bbc80)
[59014.046834] bc20:                                                       de57b950 60000113
[59014.059579] bc40: 00000000 bb32bb32 60000113 de57b948 de57b500 dc7bb440 df4bbcd0 00000000
[59014.072337] bc60: de57b950 60000113 df4bbcd0 df4bbc80 c04c259d c04c25a0 60000133 ffffffff
[59014.085233] [<c04c28db>] (__irq_svc+0x3b/0x5c) from [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10)
[59014.100437] [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10) from [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc])
[59014.118267] [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc]) from [<c0036d23>] (tasklet_action+0x3b/0x98)
[59014.134132] [<c0036d23>] (tasklet_action+0x3b/0x98) from [<c0036709>] (__do_softirq+0x99/0x16c)
[59014.147784] [<c0036709>] (__do_softirq+0x99/0x16c) from [<c00369f7>] (irq_exit+0x5b/0x5c)
[59014.160653] [<c00369f7>] (irq_exit+0x5b/0x5c) from [<c000cfc3>] (handle_IRQ+0x37/0x78)
[59014.173124] [<c000cfc3>] (handle_IRQ+0x37/0x78) from [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68)
[59014.187225] [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68) from [<c04c28db>](__irq_svc+0x3b/0x5c)
 
This bug can be see with low performance board, such as uniprocessor beagle bone board.
 
 
Signed-off-by: Yuwei Zheng <zhengyuwei@360.cn>
Signed-off-by: Yuwei Zheng <yuweizheng@139.com>


---
 drivers/net/wireless/ath/ath9k/hif_usb.c       | 58 ++++++++++++++++++++++----
 drivers/net/wireless/ath/ath9k/hif_usb.h       |  5 +++
 drivers/net/wireless/ath/ath9k/htc.h           | 13 ++++++
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c | 49 ++++++++++++++++++++++
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c  | 26 ++++++++++++
 5 files changed, 144 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 8e7153b..18c6f0e 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -658,7 +658,6 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
 	default:
 		goto resubmit;
 	}
-
 	if (likely(urb->actual_length != 0)) {
 		skb_put(skb, urb->actual_length);
 		ath9k_hif_usb_rx_stream(hif_dev, skb);
@@ -667,12 +666,18 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
 resubmit:
 	skb_reset_tail_pointer(skb);
 	skb_trim(skb, 0);
-
-	usb_anchor_urb(urb, &hif_dev->rx_submitted);
-	ret = usb_submit_urb(urb, GFP_ATOMIC);
-	if (ret) {
-		usb_unanchor_urb(urb);
-		goto free;
+	if (atomic_read(&hif_dev->rx_urb_submit_delay) > 0) {
+		usb_anchor_urb(urb, &hif_dev->rx_delayed_submitted);
+		ret = tasklet_hrtimer_start(&hif_dev->rx_submit_timer,
+						ktime_set(0, atomic_read(&hif_dev->rx_urb_submit_delay)*1000),
+						HRTIMER_MODE_REL);
+	} else {
+		usb_anchor_urb(urb, &hif_dev->rx_submitted);
+		ret = usb_submit_urb(urb, GFP_ATOMIC);
+		if (ret) {
+			usb_unanchor_urb(urb);
+			goto free;
+		}
 	}
 
 	return;
@@ -818,9 +823,39 @@ err:
 	return -ENOMEM;
 }
 
+static enum hrtimer_restart rx_urb_submit_timer_handler(struct hrtimer *me)
+{
+	struct tasklet_hrtimer *thr =
+		container_of(me, struct tasklet_hrtimer, timer);
+	struct  hif_device_usb *hif_dev =
+		container_of(thr, struct hif_device_usb, rx_submit_timer);
+	struct urb *urb = NULL;
+	struct sk_buff *skb = NULL;
+	int ret;
+
+	while (true) {
+		urb = usb_get_from_anchor(&hif_dev->rx_delayed_submitted);
+		if (urb != NULL) {
+			skb = (struct sk_buff *)urb->context;
+			ret = usb_submit_urb(urb, GFP_ATOMIC);
+			if (ret != -EBUSY) {
+				usb_unanchor_urb(urb);
+				dev_kfree_skb_any(skb);
+				urb->context = NULL;
+			}
+		} else {
+			break;
+		}
+	}
+
+	return HRTIMER_NORESTART;
+}
+
 static void ath9k_hif_usb_dealloc_rx_urbs(struct hif_device_usb *hif_dev)
 {
 	usb_kill_anchored_urbs(&hif_dev->rx_submitted);
+	usb_kill_anchored_urbs(&hif_dev->rx_delayed_submitted);
+	tasklet_hrtimer_cancel(&hif_dev->rx_submit_timer);
 }
 
 static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)
@@ -830,6 +865,8 @@ static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)
 	int i, ret;
 
 	init_usb_anchor(&hif_dev->rx_submitted);
+	init_usb_anchor(&hif_dev->rx_delayed_submitted);
+
 	spin_lock_init(&hif_dev->rx_lock);
 
 	for (i = 0; i < MAX_RX_URB_NUM; i++) {
@@ -871,6 +908,13 @@ static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)
 		usb_free_urb(urb);
 	}
 
+	/* add for flow control*/
+	atomic_set(&hif_dev->rx_urb_submit_delay, 0);
+	tasklet_hrtimer_init(&hif_dev->rx_submit_timer,
+				rx_urb_submit_timer_handler,
+				CLOCK_MONOTONIC,
+				HRTIMER_MODE_REL);
+
 	return 0;
 
 err_submit:
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.h b/drivers/net/wireless/ath/ath9k/hif_usb.h
index 51496e7..56d6be8 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.h
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.h
@@ -98,9 +98,14 @@ struct hif_device_usb {
 	struct hif_usb_tx tx;
 	struct usb_anchor regout_submitted;
 	struct usb_anchor rx_submitted;
+	struct usb_anchor rx_delayed_submitted; /* delayed submit anchor */
 	struct usb_anchor reg_in_submitted;
 	struct usb_anchor mgmt_submitted;
 	struct sk_buff *remain_skb;
+
+	struct tasklet_hrtimer  rx_submit_timer;/* delayed submit hrtimer */
+	atomic_t  rx_urb_submit_delay; /*us*/
+
 	const char *fw_name;
 	int rx_remain_len;
 	int rx_pkt_len;
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index 9dde265..453d0a8 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -331,6 +331,10 @@ static inline struct ath9k_htc_tx_ctl *HTC_SKB_CB(struct sk_buff *skb)
 
 #define TX_QSTAT_INC(q) (priv->debug.tx_stats.queue_stats[q]++)
 
+#define TASKLETRX_STAT_INC(c) (hif_dev->htc_handle->drv_priv->debug.taskletrx_stats.c++)
+#define TASKLETRX_STAT_ADD(c, a) (hif_dev->htc_handle->drv_priv->debug.taskletrx_stats.c += a)
+#define TASKLETRX_STAT_SET(c, a) (hif_dev->htc_handle->drv_priv->debug.taskletrx_stats.c = a)
+
 void ath9k_htc_err_stat_rx(struct ath9k_htc_priv *priv,
 			   struct ath_rx_status *rs);
 
@@ -352,11 +356,20 @@ struct ath_skbrx_stats {
 	u32 skb_dropped;
 };
 
+struct ath_taskletrx_stats {
+	u32 taskletrx_looptimes;
+	u32 taskletrx_highwater;
+	u32 taskletrx_lowwater;
+	u32 taskletrx_watermark_triggered;
+	u32 taskletrx_urb_submit_delay;
+};
+
 struct ath9k_debug {
 	struct dentry *debugfs_phy;
 	struct ath_tx_stats tx_stats;
 	struct ath_rx_stats rx_stats;
 	struct ath_skbrx_stats skbrx_stats;
+	struct ath_taskletrx_stats taskletrx_stats;
 };
 
 void ath9k_htc_get_et_strings(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
index 8cef1ed..7c8322e 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
@@ -286,6 +286,51 @@ static const struct file_operations fops_skb_rx = {
 	.llseek = default_llseek,
 };
 
+static ssize_t read_file_tasklet_rx(struct file *file, char __user *user_buf,
+				    size_t count, loff_t *ppos)
+{
+	struct ath9k_htc_priv *priv = file->private_data;
+	char *buf;
+	unsigned int len = 0, size = 1500;
+	ssize_t retval = 0;
+
+	buf = kzalloc(size, GFP_KERNEL);
+	if (buf == NULL)
+		return -ENOMEM;
+
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "Loop times",
+			priv->debug.taskletrx_stats.taskletrx_looptimes);
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "High watermark",
+			priv->debug.taskletrx_stats.taskletrx_highwater);
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "Low watermark",
+			priv->debug.taskletrx_stats.taskletrx_lowwater);
+
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "WM triggered",
+			priv->debug.taskletrx_stats.taskletrx_watermark_triggered);
+
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "URB delay",
+			priv->debug.taskletrx_stats.taskletrx_urb_submit_delay);
+	if (len > size)
+		len = size;
+
+	retval = simple_read_from_buffer(user_buf, count, ppos, buf, len);
+	kfree(buf);
+
+	return retval;
+}
+
+static const struct file_operations fops_tasklet_rx = {
+	.read = read_file_tasklet_rx,
+	.open = simple_open,
+	.owner = THIS_MODULE,
+	.llseek = default_llseek,
+};
+
 static ssize_t read_file_slot(struct file *file, char __user *user_buf,
 			      size_t count, loff_t *ppos)
 {
@@ -518,7 +563,11 @@ int ath9k_htc_init_debug(struct ath_hw *ah)
 	debugfs_create_file("skb_rx", S_IRUSR, priv->debug.debugfs_phy,
 			    priv, &fops_skb_rx);
 
+	debugfs_create_file("tasklet_rx", S_IRUSR, priv->debug.debugfs_phy,
+			    priv, &fops_tasklet_rx);
+
 	ath9k_cmn_debug_recv(priv->debug.debugfs_phy, &priv->debug.rx_stats);
+
 	ath9k_cmn_debug_phy_err(priv->debug.debugfs_phy, &priv->debug.rx_stats);
 
 	debugfs_create_file("slot", S_IRUSR, priv->debug.debugfs_phy,
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index a0f58e2..f5e6217 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -1061,7 +1061,28 @@ void ath9k_rx_tasklet(unsigned long data)
 	unsigned long flags;
 	struct ieee80211_hdr *hdr;
 
+	/* add for adaptive flow control*/
+	int looptimes = 0;
+	int highwatermark = ATH9K_HTC_RXBUF*3/4;
+	int lowwatermark = ATH9K_HTC_RXBUF/4;
+	unsigned int delay = 0;
+
+	struct htc_target *htc = priv->htc;
+	struct hif_device_usb *hif_dev = htc->hif_dev;
+
+	TASKLETRX_STAT_SET(taskletrx_highwater, highwatermark);
+	TASKLETRX_STAT_SET(taskletrx_lowwater, lowwatermark);
+
 	do {
+		looptimes++;
+		TASKLETRX_STAT_SET(taskletrx_looptimes, looptimes);
+		if (looptimes > highwatermark) {
+			delay = looptimes*10;
+			atomic_set(&hif_dev->rx_urb_submit_delay, delay);
+			TASKLETRX_STAT_INC(taskletrx_watermark_triggered);
+			TASKLETRX_STAT_SET(taskletrx_urb_submit_delay, delay);
+		}
+
 		spin_lock_irqsave(&priv->rx.rxbuflock, flags);
 		list_for_each_entry(tmp_buf, &priv->rx.rxbuf, list) {
 			if (tmp_buf->in_process) {
@@ -1072,6 +1093,11 @@ void ath9k_rx_tasklet(unsigned long data)
 
 		if (rxbuf == NULL) {
 			spin_unlock_irqrestore(&priv->rx.rxbuflock, flags);
+			if (looptimes < lowwatermark) {
+				atomic_set(&hif_dev->rx_urb_submit_delay, 0);
+				TASKLETRX_STAT_SET(taskletrx_urb_submit_delay, 0);
+			}
+
 			break;
 		}
 
-- 
1.9.1
