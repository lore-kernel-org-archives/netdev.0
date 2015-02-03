From: yuweizheng@139.com
Subject: [PATCH] ath9k_htc: add adaptive usb flow control to repair soft lockup with monitor mode
Date: Tue,  3 Feb 2015 17:59:45 +0800
Message-ID: <1422957585-19736-1-git-send-email-yuweizheng@139.com>
Cc: netdev@vger.kernel.org, Yuwei Zheng <yuweizheng@139.com>,
	Yuwei Zheng <zhengyuwei@360.cn>
To: linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org, kvalo@codeaurora.org,
	ath9k-devel@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/wireless/ath/ath9k/hif_usb.c       | 61 +++++++++++++++++++++++---
 drivers/net/wireless/ath/ath9k/hif_usb.h       |  6 +++
 drivers/net/wireless/ath/ath9k/htc.h           | 18 ++++++++
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c | 46 +++++++++++++++++++
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c  | 25 +++++++++++
 5 files changed, 149 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 8e7153b..718bbd6 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -640,6 +640,7 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
 	struct hif_device_usb *hif_dev =
 		usb_get_intfdata(usb_ifnum_to_if(urb->dev, 0));
 	int ret;
+	int delay;
 
 	if (!skb)
 		return;
@@ -658,7 +659,6 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
 	default:
 		goto resubmit;
 	}
-
 	if (likely(urb->actual_length != 0)) {
 		skb_put(skb, urb->actual_length);
 		ath9k_hif_usb_rx_stream(hif_dev, skb);
@@ -667,12 +667,18 @@ static void ath9k_hif_usb_rx_cb(struct urb *urb)
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
+		delay = atomic_read(&hif_dev->rx_urb_submit_delay);
+		schedule_delayed_work(&hif_dev->rx_submit_delayed_work,
+				      usecs_to_jiffies(delay));
+	} else {
+		usb_anchor_urb(urb, &hif_dev->rx_submitted);
+		ret = usb_submit_urb(urb, GFP_ATOMIC);
+		if (ret) {
+			usb_unanchor_urb(urb);
+			goto free;
+		}
 	}
 
 	return;
@@ -818,9 +824,43 @@ err:
 	return -ENOMEM;
 }
 
+static void rx_urb_delayed_submit_handler(struct work_struct *work)
+{
+	struct hif_device_usb *hif_dev =
+		container_of(work,
+			     struct hif_device_usb,
+			     rx_submit_delayed_work.work);
+
+	struct urb *urb = NULL;
+	struct sk_buff *skb = NULL;
+	int ret;
+	int loop_times = 0;
+
+	while (true) {
+		loop_times++;
+		if (loop_times > (MAX_RX_URB_NUM))
+			atomic_add(ARC_RX_STEP, &hif_dev->rx_urb_submit_delay);
+
+		urb = usb_get_from_anchor(&hif_dev->rx_delayed_submitted);
+		if (urb) {
+			skb = (struct sk_buff *)urb->context;
+			ret = usb_submit_urb(urb, GFP_KERNEL);
+			if (ret != 0) {
+				usb_unanchor_urb(urb);
+				dev_kfree_skb_any(skb);
+				urb->context = NULL;
+			}
+		} else {
+			break;
+		}
+	}
+}
+
 static void ath9k_hif_usb_dealloc_rx_urbs(struct hif_device_usb *hif_dev)
 {
 	usb_kill_anchored_urbs(&hif_dev->rx_submitted);
+	usb_kill_anchored_urbs(&hif_dev->rx_delayed_submitted);
+	flush_delayed_work(&hif_dev->rx_submit_delayed_work);
 }
 
 static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)
@@ -830,6 +870,8 @@ static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)
 	int i, ret;
 
 	init_usb_anchor(&hif_dev->rx_submitted);
+	init_usb_anchor(&hif_dev->rx_delayed_submitted);
+
 	spin_lock_init(&hif_dev->rx_lock);
 
 	for (i = 0; i < MAX_RX_URB_NUM; i++) {
@@ -871,6 +913,11 @@ static int ath9k_hif_usb_alloc_rx_urbs(struct hif_device_usb *hif_dev)
 		usb_free_urb(urb);
 	}
 
+	/* add for adaptive rate control*/
+	atomic_set(&hif_dev->rx_urb_submit_delay, 0);
+	INIT_DELAYED_WORK(&hif_dev->rx_submit_delayed_work,
+			  rx_urb_delayed_submit_handler);
+
 	return 0;
 
 err_submit:
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.h b/drivers/net/wireless/ath/ath9k/hif_usb.h
index 51496e7..2127e50 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.h
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.h
@@ -41,6 +41,7 @@
 #define MAX_RX_URB_NUM  8
 #define MAX_RX_BUF_SIZE 16384
 #define MAX_PKT_NUM_IN_TRANSFER 10
+#define ARC_RX_STEP 100 /* 100us */
 
 #define MAX_REG_OUT_URB_NUM  1
 #define MAX_REG_IN_URB_NUM   64
@@ -98,9 +99,14 @@ struct hif_device_usb {
 	struct hif_usb_tx tx;
 	struct usb_anchor regout_submitted;
 	struct usb_anchor rx_submitted;
+	struct usb_anchor rx_delayed_submitted; /* delayed submit anchor */
 	struct usb_anchor reg_in_submitted;
 	struct usb_anchor mgmt_submitted;
 	struct sk_buff *remain_skb;
+
+	struct delayed_work rx_submit_delayed_work;
+	atomic_t  rx_urb_submit_delay; /*us*/
+
 	const char *fw_name;
 	int rx_remain_len;
 	int rx_pkt_len;
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index 9dde265..3061dfa 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -331,6 +331,13 @@ static inline struct ath9k_htc_tx_ctl *HTC_SKB_CB(struct sk_buff *skb)
 
 #define TX_QSTAT_INC(q) (priv->debug.tx_stats.queue_stats[q]++)
 
+#define ARCRX_STAT_INC(c) \
+	(hif_dev->htc_handle->drv_priv->debug.arcrx_stats.c++)
+#define ARCRX_STAT_ADD(c, a) \
+	(hif_dev->htc_handle->drv_priv->debug.arcrx_stats.c += a)
+#define ARCRX_STAT_SET(c, a) \
+	(hif_dev->htc_handle->drv_priv->debug.arcrx_stats.c = a)
+
 void ath9k_htc_err_stat_rx(struct ath9k_htc_priv *priv,
 			   struct ath_rx_status *rs);
 
@@ -352,11 +359,19 @@ struct ath_skbrx_stats {
 	u32 skb_dropped;
 };
 
+struct ath_arcrx_stats {
+	u32 arcrx_highwater;
+	u32 arcrx_lowwater;
+	u32 arcrx_watermark_triggered;
+	u32 arcrx_urb_submit_delay;
+};
+
 struct ath9k_debug {
 	struct dentry *debugfs_phy;
 	struct ath_tx_stats tx_stats;
 	struct ath_rx_stats rx_stats;
 	struct ath_skbrx_stats skbrx_stats;
+	struct ath_arcrx_stats arcrx_stats;
 };
 
 void ath9k_htc_get_et_strings(struct ieee80211_hw *hw,
@@ -377,6 +392,9 @@ void ath9k_htc_get_et_stats(struct ieee80211_hw *hw,
 
 #define TX_QSTAT_INC(c) do { } while (0)
 
+#define ARCRX_STAT_INC(c) do {} while (0)
+#define ARCRX_STAT_ADD(c, a) do {} while (0)
+#define ARCRX_STAT_SET(c, a) do {} while (0)
 static inline void ath9k_htc_err_stat_rx(struct ath9k_htc_priv *priv,
 					 struct ath_rx_status *rs)
 {
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
index 8cef1ed..45cc79d 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
@@ -286,6 +286,48 @@ static const struct file_operations fops_skb_rx = {
 	.llseek = default_llseek,
 };
 
+static ssize_t read_file_arc_rx(struct file *file, char __user *user_buf,
+				size_t count, loff_t *ppos)
+{
+	struct ath9k_htc_priv *priv = file->private_data;
+	char *buf;
+	unsigned int len = 0, size = 1500;
+	ssize_t retval = 0;
+
+	buf = kzalloc(size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "High watermark",
+			priv->debug.arcrx_stats.arcrx_highwater);
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "Low watermark",
+			priv->debug.arcrx_stats.arcrx_lowwater);
+
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "WM triggered",
+			priv->debug.arcrx_stats.arcrx_watermark_triggered);
+
+	len += scnprintf(buf + len, size - len,
+			"%20s : %10u\n", "URB delay",
+			priv->debug.arcrx_stats.arcrx_urb_submit_delay);
+	if (len > size)
+		len = size;
+
+	retval = simple_read_from_buffer(user_buf, count, ppos, buf, len);
+	kfree(buf);
+
+	return retval;
+}
+
+static const struct file_operations fops_arc_rx = {
+	.read = read_file_arc_rx,
+	.open = simple_open,
+	.owner = THIS_MODULE,
+	.llseek = default_llseek,
+};
+
 static ssize_t read_file_slot(struct file *file, char __user *user_buf,
 			      size_t count, loff_t *ppos)
 {
@@ -518,7 +560,11 @@ int ath9k_htc_init_debug(struct ath_hw *ah)
 	debugfs_create_file("skb_rx", S_IRUSR, priv->debug.debugfs_phy,
 			    priv, &fops_skb_rx);
 
+	debugfs_create_file("arc_rx", S_IRUSR, priv->debug.debugfs_phy,
+			    priv, &fops_arc_rx);
+
 	ath9k_cmn_debug_recv(priv->debug.debugfs_phy, &priv->debug.rx_stats);
+
 	ath9k_cmn_debug_phy_err(priv->debug.debugfs_phy, &priv->debug.rx_stats);
 
 	debugfs_create_file("slot", S_IRUSR, priv->debug.debugfs_phy,
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index a0f58e2..9d2dc33 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -1061,7 +1061,27 @@ void ath9k_rx_tasklet(unsigned long data)
 	unsigned long flags;
 	struct ieee80211_hdr *hdr;
 
+	/* add for adaptive flow control*/
+	int looptimes = 0;
+	int highwatermark = ATH9K_HTC_RXBUF*3/4;
+	int lowwatermark = ATH9K_HTC_RXBUF/32;
+	unsigned int delay = 0;
+
+	struct htc_target *htc = priv->htc;
+	struct hif_device_usb *hif_dev = htc->hif_dev;
+
+	ARCRX_STAT_SET(arcrx_highwater, highwatermark);
+	ARCRX_STAT_SET(arcrx_lowwater, lowwatermark);
+
 	do {
+		looptimes++;
+		if (looptimes > highwatermark) {
+			delay = looptimes*ARC_RX_STEP;
+			atomic_set(&hif_dev->rx_urb_submit_delay, delay);
+			ARCRX_STAT_INC(arcrx_watermark_triggered);
+			ARCRX_STAT_SET(arcrx_urb_submit_delay, delay);
+		}
+
 		spin_lock_irqsave(&priv->rx.rxbuflock, flags);
 		list_for_each_entry(tmp_buf, &priv->rx.rxbuf, list) {
 			if (tmp_buf->in_process) {
@@ -1072,6 +1092,11 @@ void ath9k_rx_tasklet(unsigned long data)
 
 		if (rxbuf == NULL) {
 			spin_unlock_irqrestore(&priv->rx.rxbuflock, flags);
+			if (looptimes < lowwatermark) {
+				atomic_set(&hif_dev->rx_urb_submit_delay, 0);
+				ARCRX_STAT_SET(arcrx_urb_submit_delay, 0);
+			}
+
 			break;
 		}
 
-- 
1.9.1
