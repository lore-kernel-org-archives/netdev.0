From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw-mac80211: limit URB buffering in tx path
Date: Tue,  1 May 2007 04:01:00 +0100 (BST)
Message-ID: <20070501030100.BDE3D7B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:16867 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754586AbXEADBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 23:01:25 -0400
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

The old code allowed unlimited buffing of tx frames in URBs
submitted for transfer to the device. This patch stops the
ieee80211_hw queue(s) if to many URBs are ready for submit to the
device. Actually the ZD1211 device supports currently only one
queue.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.c |    6 +-
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.h |    4 +-
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c  |  327 +++++++++++++++++-----
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.h  |   23 ++
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c  |  173 +++++++++---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.h  |   30 ++-
 6 files changed, 450 insertions(+), 113 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
index d8bc0f1..fcf78ab 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
@@ -1606,20 +1606,22 @@ void zd_chip_disable_int(struct zd_chip *chip)
 	mutex_unlock(&chip->mutex);
 }
 
-int zd_chip_enable_rx(struct zd_chip *chip)
+int zd_chip_enable_rxtx(struct zd_chip *chip)
 {
 	int r;
 
 	mutex_lock(&chip->mutex);
+	zd_usb_enable_tx(&chip->usb);
 	r = zd_usb_enable_rx(&chip->usb);
 	mutex_unlock(&chip->mutex);
 	return r;
 }
 
-void zd_chip_disable_rx(struct zd_chip *chip)
+void zd_chip_disable_rxtx(struct zd_chip *chip)
 {
 	mutex_lock(&chip->mutex);
 	zd_usb_disable_rx(&chip->usb);
+	zd_usb_disable_tx(&chip->usb);
 	mutex_unlock(&chip->mutex);
 }
 
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
index 584b1c8..24f5913 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
@@ -824,8 +824,8 @@ int zd_chip_switch_radio_on(struct zd_chip *chip);
 int zd_chip_switch_radio_off(struct zd_chip *chip);
 int zd_chip_enable_int(struct zd_chip *chip);
 void zd_chip_disable_int(struct zd_chip *chip);
-int zd_chip_enable_rx(struct zd_chip *chip);
-void zd_chip_disable_rx(struct zd_chip *chip);
+int zd_chip_enable_rxtx(struct zd_chip *chip);
+void zd_chip_disable_rxtx(struct zd_chip *chip);
 int zd_chip_enable_hwint(struct zd_chip *chip);
 int zd_chip_disable_hwint(struct zd_chip *chip);
 int zd_chip_generic_patch_6m_band(struct zd_chip *chip, int channel);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index 91b908a..c3f8d30 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -118,17 +118,17 @@ static int zd_mac_open(struct ieee80211_hw *dev)
 	r = zd_write_mac_addr(chip, mac->hwaddr);
 	if (r)
 		goto disable_radio;
-	r = zd_chip_enable_rx(chip);
+	r = zd_chip_enable_rxtx(chip);
 	if (r < 0)
 		goto disable_radio;
 	r = zd_chip_enable_hwint(chip);
 	if (r < 0)
-		goto disable_rx;
+		goto disable_rxtx;
 
 	housekeeping_enable(mac);
 	return 0;
-disable_rx:
-	zd_chip_disable_rx(chip);
+disable_rxtx:
+	zd_chip_disable_rxtx(chip);
 disable_radio:
 	zd_chip_switch_radio_off(chip);
 disable_int:
@@ -137,11 +137,42 @@ out:
 	return r;
 }
 
+/**
+ * clear_tx_skb_control_block - clears the control block of tx skbuffs
+ * @skb: a &struct sk_buff pointer
+ *
+ * This clears the control block of skbuff buffers, which were transmitted to
+ * the device. Notify that the function is not thread-safe, so prevent
+ * multiple calls.
+ */
+static void clear_tx_skb_control_block(struct sk_buff *skb)
+{
+	struct zd_tx_skb_control_block *cb =
+		(struct zd_tx_skb_control_block *)skb->cb;
+
+	kfree(cb->control);
+	cb->control = NULL;
+}
+
+/**
+ * kfree_tx_skb - frees a tx skbuff
+ * @skb: a &struct sk_buff pointer
+ *
+ * Frees the tx skbuff. Frees also the allocated control structure in the
+ * control block if necessary.
+ */
+static void kfree_tx_skb(struct sk_buff *skb)
+{
+	clear_tx_skb_control_block(skb);
+	dev_kfree_skb_any(skb);
+}
+
 static int zd_mac_stop(struct ieee80211_hw *dev)
 {
 	struct zd_mac *mac = zd_dev_mac(dev);
 	struct zd_chip *chip = &mac->chip;
 	struct sk_buff *skb;
+	struct sk_buff_head *tx_queue = &mac->tx_queue;
 
 	/*
 	 * The order here deliberately is a little different from the open()
@@ -149,23 +180,155 @@ static int zd_mac_stop(struct ieee80211_hw *dev)
 	 * frames to be processed by softmac after we have stopped it.
 	 */
 
-	zd_chip_disable_rx(chip);
+	zd_chip_disable_rxtx(chip);
 	housekeeping_disable(mac);
 
 	zd_chip_disable_hwint(chip);
 	zd_chip_switch_radio_off(chip);
 	zd_chip_disable_int(chip);
 
-	while ((skb = skb_dequeue(&mac->tx_queue))) {
-		struct ieee80211_tx_control *control =
-			*(struct ieee80211_tx_control **)skb->cb;
-		kfree(control);
-		dev_kfree_skb(skb);
+
+	while ((skb = skb_dequeue(tx_queue)))
+		kfree_tx_skb(skb);
+
+	return 0;
+}
+
+/**
+ * wake_queues - wakes all queues
+ * @hw: a &struct ieee80211_hw pointer
+ *
+ * Such a function is not provided by mac80211, so we have to provide them on
+ * our own.
+ */
+static void wake_queues(struct ieee80211_hw *hw)
+{
+	int i;
+
+	for (i = 0; i < hw->queues; i++)
+		ieee80211_wake_queue(hw, i);
+}
+
+/**
+ * tx_frames - returns the number of incompleted frames
+ * @mac: a &struct zd_mac pointer
+ *
+ * This is the number of frames, which have not been completed so far.
+ * Packets without ACKs are completed if the have been transmitted to the
+ * decice and all others if they have been removed from the tx_queue.
+ */
+static int tx_frames(struct zd_mac *mac)
+{
+	return skb_queue_len(&mac->tx_queue) + zd_usb_tx_frames(&mac->chip.usb);
+}
+
+/**
+ * try_stop - if necessary closes the incoming network queues
+ * @dev: a &struct ieee80211_hw pointer
+ *
+ * If the number of incompleted frames is higher than @tx_high, the function
+ * stops the incoming queues of the mac80211 stack. Nothing happens if the
+ * queues have already been stopped.
+ */
+static void try_stop(struct ieee80211_hw *dev)
+{
+	unsigned long flags;
+	struct zd_mac *mac = zd_dev_mac(dev);
+
+	spin_lock_irqsave(&mac->lock, flags);
+	if (!mac->tx_stopped && tx_frames(mac) > mac->tx_high) {
+		ieee80211_stop_queues(dev);
+		mac->tx_stopped = 1;
+	}
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
+/**
+ * try_wakeup - wake queue
+ * @dev: a &struct ieee80211_hw pointer
+ *
+ * If the number of incompleted frames drops under the the low level and the
+ * upper-layer transfer queues have been stopped, the queues will be wakened
+ * again.
+ */
+static void try_wakeup(struct ieee80211_hw *dev)
+{
+	unsigned long flags;
+	struct zd_mac *mac = zd_dev_mac(dev);
+
+	spin_lock_irqsave(&mac->lock, flags);
+	if (mac->tx_stopped && tx_frames(mac) <= mac->tx_low) {
+		wake_queues(dev);
+		mac->tx_stopped = 0;
+	}
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
+/**
+ * init_tx_skb_control_block - initializes skb control block
+ * @skb: a &sk_buff pointer
+ * @dev: pointer to the mac80221 device
+ * @control: mac80211 tx control applying for the frame in @skb
+ *
+ * Initializes the control block of the skbuff to be transmitted. Notify that
+ * the control parameter will be only copied into the control block, if ACKs
+ * are requieed.
+ */
+static int init_tx_skb_control_block(struct sk_buff *skb,
+				     struct ieee80211_hw *dev,
+	                             struct ieee80211_tx_control *control)
+{
+	struct zd_tx_skb_control_block *cb =
+		(struct zd_tx_skb_control_block *)skb->cb;
+
+	ZD_ASSERT(sizeof(*cb) <= sizeof(skb->cb));
+	memset(cb, 0, sizeof(*cb));
+	cb->dev = dev;
+	if (!(control->flags & IEEE80211_TXCTL_NO_ACK)) {
+		cb->control = kmalloc(sizeof(*control), GFP_ATOMIC);
+		if (cb->control == NULL)
+			return -ENOMEM;
+		memcpy(cb->control, control, sizeof(*control));
 	}
 
 	return 0;
 }
 
+/**
+ * zd_mac_tx_to_dev - callback for USB layer
+ * @skb: a &sk_buff pointer
+ * @error: error value, 0 if transmission successful
+ *
+ * Informs the MAC layer that the frame has successfully transferred to the
+ * device. If an ACK is required and the transfer to the device has been
+ * successful, the packets are put on the @tx_queue with
+ * the control set removed.
+ */
+void zd_mac_tx_to_dev(struct sk_buff *skb, int error)
+{
+	struct zd_tx_skb_control_block *cb =
+		(struct zd_tx_skb_control_block *)skb->cb;
+	struct ieee80211_hw *dev = cb->dev;
+
+	if (likely(cb->control)) {
+		skb_pull(skb, sizeof(struct zd_ctrlset));
+		if (unlikely(error)) {
+			struct ieee80211_tx_status status = {{0}};
+
+			memcpy(&status.control,
+				cb->control, sizeof(status.control));
+			clear_tx_skb_control_block(skb);
+			ieee80211_tx_status_irqsafe(dev, skb, &status);
+		} else {
+			skb_queue_tail(&zd_dev_mac(dev)->tx_queue, skb);
+			return;
+		}
+	} else {
+		kfree_tx_skb(skb);
+	}
+	try_wakeup(dev);
+}
+
 static int zd_calc_tx_length_us(u8 *service, u8 cs_rate, u16 tx_length)
 {
 	static const u8 rate_divisor[] = {
@@ -304,55 +467,64 @@ static int fill_ctrlset(struct zd_mac *mac,
 	return 0;
 }
 
+/**
+ * zd_mac_tx - transmits a network frame to the device
+ *
+ * @dev: mac80211 hardware device
+ * @skb: socket buffer
+ * @control: the control structure
+ *
+ * This function transmit an IEEE 802.11 network frame to the device. The
+ * control block of the skbuff will be initialized. If necessary the incoming
+ * mac80211 queues will be stopped.
+ */
 static int zd_mac_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
 		     struct ieee80211_tx_control *control)
 {
 	struct zd_mac *mac = zd_dev_mac(dev);
-	struct ieee80211_tx_control *control_copy;
 	int r;
 
 	r = fill_ctrlset(mac, skb, control);
 	if (r)
 		return r;
-	r = zd_usb_tx(&mac->chip.usb, skb->data, skb->len);
+
+	r = init_tx_skb_control_block(skb, dev, control);
 	if (r)
 		return r;
-
-	if (control->flags & IEEE80211_TXCTL_NO_ACK) {
-		dev_kfree_skb(skb);
-		return 0;
+	r = zd_usb_tx(&mac->chip.usb, skb);
+	if (r) {
+		clear_tx_skb_control_block(skb);
+		return r;
 	}
-
-	control_copy = kmalloc(sizeof(*control_copy), GFP_ATOMIC);
-	if (control_copy)
-		memcpy(control_copy, control, sizeof(*control_copy));
-
-	*(struct ieee80211_tx_control **)skb->cb = control_copy;
-	skb_pull(skb, sizeof(struct zd_ctrlset));
-	skb_queue_tail(&mac->tx_queue, skb);
+	try_stop(dev);
 	return 0;
 }
 
+/**
+ * zd_mac_tx_failed - callback for failed frames
+ * @dev: the mac80211 wireless device
+ *
+ * This function is called if a frame couldn't be succesfully be
+ * transferred. The first frame from the tx queue, will be selected and
+ * reported as error to the upper layers.
+ */
 void zd_mac_tx_failed(struct ieee80211_hw *dev)
 {
-	struct zd_mac *mac = zd_dev_mac(dev);
-	struct ieee80211_tx_control *control;
+	struct sk_buff_head *tx_queue = &zd_dev_mac(dev)->tx_queue;
 	struct sk_buff *skb;
+	struct ieee80211_tx_status status;
+	struct zd_tx_skb_control_block *cb;
 
-	skb = skb_dequeue(&mac->tx_queue);
-	if (!skb)
+	skb = skb_dequeue(tx_queue);
+	if (skb == NULL)
 		return;
-
-	control = *(struct ieee80211_tx_control **)skb->cb;
-	if (control) {
-		struct ieee80211_tx_status status = {{0}};
-		memcpy(&status.control, control, sizeof(status.control));
-		ieee80211_tx_status_irqsafe(dev, skb, &status);
-		kfree(control);
-	} else
-		dev_kfree_skb_any(skb);
-
-	return;
+	cb = (struct zd_tx_skb_control_block *)skb->cb;
+	ZD_ASSERT(cb->control != NULL);
+	memset(&status, 0, sizeof(status));
+	memcpy(&status.control, cb->control, sizeof(status.control));
+	clear_tx_skb_control_block(skb);
+	ieee80211_tx_status_irqsafe(dev, skb, &status);
+	try_wakeup(dev);
 }
 
 struct zd_rt_hdr {
@@ -416,49 +588,57 @@ static int fill_rx_stats(struct ieee80211_rx_status *stats,
 	return 0;
 }
 
+/**
+ * filter_ack - filters incoming packets for acknowledgements
+ * @dev: the mac80211 device
+ * @rx_hdr: received header
+ * @stats: the status for the received packet
+ *
+ * This functions looks for ACK packets and tries to match them with the
+ * frames in the tx queue. If a match is found the frame will be dequeued and
+ * the upper layers is informed about the successful transmission. If
+ * mac80211 queues have been stopped and the number of frames still to be
+ * transmitted is low the queues will be opened again.
+ */
 static int filter_ack(struct ieee80211_hw *dev, struct ieee80211_hdr *rx_hdr,
 		      struct ieee80211_rx_status *stats)
 {
-	struct zd_mac *mac = zd_dev_mac(dev);
 	u16 fc = le16_to_cpu(rx_hdr->frame_control);
 	struct sk_buff *skb;
-	struct ieee80211_hdr *tx_hdr;
-	struct ieee80211_tx_control *control;
-	struct ieee80211_tx_status status = {{0}};
+	struct sk_buff_head *tx_queue;
+	unsigned long flags;
 
 	if ((fc & (IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) !=
 	    (IEEE80211_FTYPE_CTL | IEEE80211_STYPE_ACK))
 		return 0;
 
-	spin_lock(&mac->tx_queue.lock);
-
-	skb = skb_peek(&mac->tx_queue);
-	if (!skb) {
-		spin_unlock(&mac->tx_queue.lock);
-		return 1;
-	}
-
-	tx_hdr = (struct ieee80211_hdr *) skb->data;
-
-	if (!compare_ether_addr(tx_hdr->addr2, rx_hdr->addr1))
-		skb = __skb_dequeue(&mac->tx_queue);
-	else {
-		spin_unlock(&mac->tx_queue.lock);
-		return 1;
+	tx_queue = &zd_dev_mac(dev)->tx_queue;
+	spin_lock_irqsave(&tx_queue->lock, flags);
+	for (skb = tx_queue->next; skb != (struct sk_buff *)tx_queue;
+	     skb = skb->next)
+	{
+		struct ieee80211_hdr *tx_hdr;
+		struct zd_tx_skb_control_block *cb =
+			(struct zd_tx_skb_control_block *)skb->cb;
+
+		ZD_ASSERT(cb->control != NULL);
+		tx_hdr = (struct ieee80211_hdr *)skb->data;
+		if (likely(!compare_ether_addr(tx_hdr->addr2, rx_hdr->addr1)))
+		{
+			struct ieee80211_tx_status status = {{0}};
+			memcpy(&status.control,
+		               cb->control, sizeof(status.control));
+			status.flags = IEEE80211_TX_STATUS_ACK;
+			status.ack_signal = stats->ssi;
+			__skb_unlink(skb, tx_queue);
+			clear_tx_skb_control_block(skb);
+			ieee80211_tx_status_irqsafe(dev, skb, &status);
+			try_wakeup(dev);
+			goto out;
+		}
 	}
-
-	spin_unlock(&mac->tx_queue.lock);
-
-	control = *(struct ieee80211_tx_control **)skb->cb;
-	if (control) {
-		memcpy(&status.control, control, sizeof(status.control));
-		status.flags = IEEE80211_TX_STATUS_ACK;
-		status.ack_signal = stats->ssi;
-		ieee80211_tx_status_irqsafe(dev, skb, &status);
-		kfree(control);
-	} else
-		dev_kfree_skb_any(skb);
-
+out:
+	spin_unlock_irqrestore(&tx_queue->lock, flags);
 	return 1;
 }
 
@@ -639,6 +819,10 @@ struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf)
 	dev->queues = 1;
 	dev->extra_tx_headroom = sizeof(struct zd_ctrlset);
 
+	mac->tx_low = ZD_MAC_TX_LOW;
+	mac->tx_high = ZD_MAC_TX_HIGH;
+	skb_queue_head_init(&mac->tx_queue);
+
 	for (i = 0; i < 2; i++) {
 		if (ieee80211_register_hwmode(dev, &mac->modes[i])) {
 			dev_dbg_f(&intf->dev, "cannot register hwmode\n");
@@ -647,7 +831,6 @@ struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf)
 		}
 	}
 
-	skb_queue_head_init(&mac->tx_queue);
 	zd_chip_init(&mac->chip, dev, intf);
 	housekeeping_init(mac);
 	INIT_WORK(&mac->set_multicast_hash_work, set_multicast_hash_handler);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
index ec02765..615c5fb 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
@@ -122,8 +122,27 @@ struct housekeeping {
 	struct delayed_work link_led_work;
 };
 
+/**
+ * struct zd_tx_skb_control_block - control block for tx skbuffs
+ * @control: &struct ieee80211_tx_control pointer
+ * @context: context pointer
+ *
+ * This structure is used to fill the cb field in an &sk_buff to transmit.
+ * The control field is NULL, if there is no requirement from the mac80211
+ * stack to report about the packet ACK. This is the case if the flag
+ * IEEE80211_TXCTL_NO_ACK is not set in &struct ieee80211_tx_control.
+ */
+struct zd_tx_skb_control_block {
+	struct ieee80211_tx_control *control;
+	struct ieee80211_hw *dev;
+	void *context;
+};
+
 #define ZD_MAC_STATS_BUFFER_SIZE 16
 
+#define ZD_MAC_TX_HIGH 6
+#define ZD_MAC_TX_LOW 2
+
 struct zd_mac {
 	struct zd_chip chip;
 	spinlock_t lock;
@@ -137,6 +156,9 @@ struct zd_mac {
 	int associated;
 	u8 *hwaddr;
 	struct sk_buff_head tx_queue;
+	int tx_high;
+	int tx_low;
+	int tx_stopped;
 	struct ieee80211_channel channels[14];
 	struct ieee80211_rate rates[12];
 	struct ieee80211_hw_mode modes[2];
@@ -166,6 +188,7 @@ int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type);
 
 int zd_mac_rx(struct ieee80211_hw *dev, const u8 *buffer, unsigned int length);
 void zd_mac_tx_failed(struct ieee80211_hw *dev);
+void zd_mac_tx_to_dev(struct sk_buff *skb, int error);
 
 #ifdef DEBUG
 void zd_dump_rx_status(const struct rx_status *status);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 533f189..4212310 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -574,7 +574,7 @@ resubmit:
 	usb_submit_urb(urb, GFP_ATOMIC);
 }
 
-static struct urb *alloc_urb(struct zd_usb *usb)
+static struct urb *alloc_rx_urb(struct zd_usb *usb)
 {
 	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	struct urb *urb;
@@ -598,7 +598,7 @@ static struct urb *alloc_urb(struct zd_usb *usb)
 	return urb;
 }
 
-static void free_urb(struct urb *urb)
+static void free_rx_urb(struct urb *urb)
 {
 	if (!urb)
 		return;
@@ -616,11 +616,11 @@ int zd_usb_enable_rx(struct zd_usb *usb)
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
 	r = -ENOMEM;
-	urbs = kcalloc(URBS_COUNT, sizeof(struct urb *), GFP_KERNEL);
+	urbs = kcalloc(RX_URBS_COUNT, sizeof(struct urb *), GFP_KERNEL);
 	if (!urbs)
 		goto error;
-	for (i = 0; i < URBS_COUNT; i++) {
-		urbs[i] = alloc_urb(usb);
+	for (i = 0; i < RX_URBS_COUNT; i++) {
+		urbs[i] = alloc_rx_urb(usb);
 		if (!urbs[i])
 			goto error;
 	}
@@ -633,10 +633,10 @@ int zd_usb_enable_rx(struct zd_usb *usb)
 		goto error;
 	}
 	rx->urbs = urbs;
-	rx->urbs_count = URBS_COUNT;
+	rx->urbs_count = RX_URBS_COUNT;
 	spin_unlock_irq(&rx->lock);
 
-	for (i = 0; i < URBS_COUNT; i++) {
+	for (i = 0; i < RX_URBS_COUNT; i++) {
 		r = usb_submit_urb(urbs[i], GFP_KERNEL);
 		if (r)
 			goto error_submit;
@@ -644,7 +644,7 @@ int zd_usb_enable_rx(struct zd_usb *usb)
 
 	return 0;
 error_submit:
-	for (i = 0; i < URBS_COUNT; i++) {
+	for (i = 0; i < RX_URBS_COUNT; i++) {
 		usb_kill_urb(urbs[i]);
 	}
 	spin_lock_irq(&rx->lock);
@@ -653,8 +653,8 @@ error_submit:
 	spin_unlock_irq(&rx->lock);
 error:
 	if (urbs) {
-		for (i = 0; i < URBS_COUNT; i++)
-			free_urb(urbs[i]);
+		for (i = 0; i < RX_URBS_COUNT; i++)
+			free_rx_urb(urbs[i]);
 	}
 	return r;
 }
@@ -676,7 +676,7 @@ void zd_usb_disable_rx(struct zd_usb *usb)
 
 	for (i = 0; i < count; i++) {
 		usb_kill_urb(urbs[i]);
-		free_urb(urbs[i]);
+		free_rx_urb(urbs[i]);
 	}
 	kfree(urbs);
 
@@ -686,9 +686,109 @@ void zd_usb_disable_rx(struct zd_usb *usb)
 	spin_unlock_irqrestore(&rx->lock, flags);
 }
 
+/**
+ * zd_usb_disable_tx - disable transmission
+ * @usb: the zd1211rw-private USB structure
+ *
+ * Frees all URBs in the free list and marks the transmission as disabled.
+ */
+void zd_usb_disable_tx(struct zd_usb *usb)
+{
+	struct zd_usb_tx *tx = &usb->tx;
+	unsigned long flags;
+	struct list_head *pos, *n;
+
+	spin_lock_irqsave(&tx->lock, flags);
+	list_for_each_safe(pos, n, &tx->free_urb_list) {
+		list_del(pos);
+		usb_free_urb(list_entry(pos, struct urb, urb_list));
+	}
+	tx->enabled = 0;
+	atomic_set(&tx->submitted_urbs, 0);
+	spin_unlock_irqrestore(&tx->lock, flags);
+}
+
+/**
+ * zd_usb_enable_tx - enables transmission
+ * @usb: a &struct zd_usb pointer
+ *
+ * This function enables transmission and prepares the &zd_usb_tx data
+ * structure.
+ */
+void zd_usb_enable_tx(struct zd_usb *usb)
+{
+	unsigned long flags;
+	struct zd_usb_tx *tx = &usb->tx;
+
+	spin_lock_irqsave(&tx->lock, flags);
+	tx->enabled = 1;
+	atomic_set(&tx->submitted_urbs, 0);
+	spin_unlock_irqrestore(&tx->lock, flags);
+}
+
+/**
+ * alloc_tx_urb - provides an tx URB
+ * @usb: a &struct zd_usb pointer
+ *
+ * Allocates a new URB. If possible takes the urb from the free list in
+ * usb->tx.
+ */
+static struct urb *alloc_tx_urb(struct zd_usb *usb)
+{
+	struct zd_usb_tx *tx = &usb->tx;
+	unsigned long flags;
+	struct list_head *entry;
+	struct urb *urb;
+
+	spin_lock_irqsave(&tx->lock, flags);
+	if (list_empty(&tx->free_urb_list)) {
+		urb = usb_alloc_urb(0, GFP_ATOMIC);
+		goto out;
+	}
+	entry = tx->free_urb_list.next;
+	list_del(entry);
+	urb = list_entry(entry, struct urb, urb_list);
+out:
+	spin_unlock_irqrestore(&tx->lock, flags);
+	return urb;
+}
+
+/**
+ * free_tx_urb - frees a used tx URB
+ * @usb: a &struct zd_usb pointer
+ * @urb: URB to be freed
+ *
+ * Frees the the transmission URB, which means to put it on the free URB
+ * list.
+ */
+static void free_tx_urb(struct zd_usb *usb, struct urb *urb)
+{
+	struct zd_usb_tx *tx = &usb->tx;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tx->lock, flags);
+	if (!tx->enabled) {
+		usb_free_urb(urb);
+		goto out;
+	}
+	list_add(&urb->urb_list, &tx->free_urb_list);
+out:
+	spin_unlock_irqrestore(&tx->lock, flags);
+}
+
+/**
+ * tx_urb_complete - completes the execution of an URB
+ * @urb: a URB
+ *
+ * This function is called if the URB has been transferred to a device or an
+ * error has happened.
+ */
 static void tx_urb_complete(struct urb *urb)
 {
 	int r;
+	struct sk_buff *skb;
+	struct zd_tx_skb_control_block *cb;
+	struct zd_usb *usb;
 
 	switch (urb->status) {
 	case 0:
@@ -706,9 +806,12 @@ static void tx_urb_complete(struct urb *urb)
 		goto resubmit;
 	}
 free_urb:
-	usb_buffer_free(urb->dev, urb->transfer_buffer_length,
-		        urb->transfer_buffer, urb->transfer_dma);
-	usb_free_urb(urb);
+	skb = (struct sk_buff *)urb->context;
+	zd_mac_tx_to_dev(skb, urb->status);
+	cb = (struct zd_tx_skb_control_block *)skb->cb;
+	usb = &zd_dev_mac(cb->dev)->chip.usb;
+	atomic_dec(&usb->tx.submitted_urbs);
+	free_tx_urb(usb, urb);
 	return;
 resubmit:
 	r = usb_submit_urb(urb, GFP_ATOMIC);
@@ -718,43 +821,40 @@ resubmit:
 	}
 }
 
-/* Puts the frame on the USB endpoint. It doesn't wait for
- * completion. The frame must contain the control set.
+/**
+ * zd_usb_tx: initiates transfer of a frame of the device
+ *
+ * @usb: the zd1211rw-private USB structure
+ * @skb: a &struct sk_buff pointer
+ *
+ * This function tranmits a frame to the device. It doesn't wait for
+ * completion. The frame must contain the control set and have all the
+ * control set information available.
+ *
+ * The function returns 0 if the transfer has been successfully initiated.
  */
-int zd_usb_tx(struct zd_usb *usb, const u8 *frame, unsigned int length)
+int zd_usb_tx(struct zd_usb *usb, struct sk_buff *skb)
 {
 	int r;
 	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	struct urb *urb;
-	void *buffer;
 
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	urb = alloc_tx_urb(usb);
 	if (!urb) {
 		r = -ENOMEM;
 		goto out;
 	}
 
-	buffer = usb_buffer_alloc(zd_usb_to_usbdev(usb), length, GFP_ATOMIC,
-		                  &urb->transfer_dma);
-	if (!buffer) {
-		r = -ENOMEM;
-		goto error_free_urb;
-	}
-	memcpy(buffer, frame, length);
-
 	usb_fill_bulk_urb(urb, udev, usb_sndbulkpipe(udev, EP_DATA_OUT),
-		          buffer, length, tx_urb_complete, NULL);
-	urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+		          skb->data, skb->len, tx_urb_complete, skb);
 
 	r = usb_submit_urb(urb, GFP_ATOMIC);
 	if (r)
 		goto error;
+	atomic_inc(&usb->tx.submitted_urbs);
 	return 0;
 error:
-	usb_buffer_free(zd_usb_to_usbdev(usb), length, buffer,
-		        urb->transfer_dma);
-error_free_urb:
-	usb_free_urb(urb);
+	free_tx_urb(usb, urb);
 out:
 	return r;
 }
@@ -783,8 +883,11 @@ static inline void init_usb_rx(struct zd_usb *usb)
 
 static inline void init_usb_tx(struct zd_usb *usb)
 {
-	/* FIXME: at this point we will allocate a fixed number of urb's for
-	 * use in a cyclic scheme */
+	struct zd_usb_tx *tx = &usb->tx;
+	spin_lock_init(&tx->lock);
+	tx->enabled = 0;
+	INIT_LIST_HEAD(&tx->free_urb_list);
+	atomic_set(&tx->submitted_urbs, 0);
 }
 
 void zd_usb_init(struct zd_usb *usb, struct ieee80211_hw *dev,
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h
index bcc55e8..f01d0bb 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.h
@@ -165,7 +165,7 @@ static inline struct usb_int_regs *get_read_regs(struct zd_usb_interrupt *intr)
 	return (struct usb_int_regs *)intr->read_regs.buffer;
 }
 
-#define URBS_COUNT 5
+#define RX_URBS_COUNT 5
 
 struct zd_usb_rx {
 	spinlock_t lock;
@@ -176,8 +176,19 @@ struct zd_usb_rx {
 	int urbs_count;
 };
 
+/**
+ * struct zd_usb_tx - structure used for transmitting frames
+ * @lock: lock for transmission
+ * @free_urb_list: list of free URBs, contains all the URBs, which can be used
+ * @submitted_urbs: atomic integer that counts the URBs having sent to the
+ *	device, which haven't been completed
+ * @enabled: enabled flag, indicates whether tx is enabled
+ */
 struct zd_usb_tx {
 	spinlock_t lock;
+	struct list_head free_urb_list;
+	atomic_t submitted_urbs;
+	int enabled;
 };
 
 /* Contains the usb parts. The structure doesn't require a lock because intf
@@ -220,7 +231,22 @@ void zd_usb_disable_int(struct zd_usb *usb);
 int zd_usb_enable_rx(struct zd_usb *usb);
 void zd_usb_disable_rx(struct zd_usb *usb);
 
-int zd_usb_tx(struct zd_usb *usb, const u8 *frame, unsigned int length);
+void zd_usb_enable_tx(struct zd_usb *usb);
+void zd_usb_disable_tx(struct zd_usb *usb);
+
+int zd_usb_tx(struct zd_usb *usb, struct sk_buff *skb);
+
+/**
+ * zd_usb_tx_frames - frames in transfer to the device
+ * @usb: a &struct zd_usb pointer
+ *
+ * This function returns the number of frames, which are currently
+ * transmitted to the device.
+ */
+static inline int zd_usb_tx_frames(struct zd_usb *usb)
+{
+	return atomic_read(&usb->tx.submitted_urbs);
+}
 
 int zd_usb_ioread16v(struct zd_usb *usb, u16 *values,
 	         const zd_addr_t *addresses, unsigned int count);
-- 
1.5.1.2

