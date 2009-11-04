From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 10/13] wimax/i2400m: clarify and fix i2400m->{ready,updown}
Date: Wed,  4 Nov 2009 13:40:01 -0800
Message-ID: <c2315b4ea9ac9c3f8caf03c3511d86fabe4a5fcd.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20716 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932747AbZKDVmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:08 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m driver uses two different bits to distinguish how much the
driver is up. i2400m->ready is used to denote that the infrastructure
to communicate with the device is up and running. i2400m->updown is
used to indicate if 'ready' and the device is up and running, ready to
take control and data traffic.

However, all this was pretty dirty and not clear, with many open spots
where race conditions were present.

This commit cleans up the situation by:

 - documenting the usage of both bits

 - setting them only in specific, well controlled places
   (i2400m_dev_start, i2400m_dev_stop)

 - ensuring the i2400m workqueue can't get in the middle of the
   setting by flushing it when i2400m->ready is set to zero. This
   allows the report hook not having to check again for the bit to be
   set [rx.c:i2400m_report_hook_work()].

 - using i2400m->updown to determine if the device is up and running
   instead of the wimax state in i2400m_dev_reset_handle().

 - not loosing missed messages sent by the hardware before
   i2400m->ready is set. In rx.c, whatever the device sends can be
   sent to user space over the message pipes as soon as the wimax
   device is registered, so don't wait for i2400m->ready to be set.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   44 ++++++++++++++++++++++++------------
 drivers/net/wimax/i2400m/i2400m.h |   23 ++++++++++++++++++-
 drivers/net/wimax/i2400m/rx.c     |   16 ++++++-------
 drivers/net/wimax/i2400m/usb.c    |    7 +++++-
 include/net/wimax.h               |    6 +++++
 5 files changed, 70 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index a0ae199..6280646 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -455,6 +455,8 @@ retry:
 	result = i2400m->bus_dev_start(i2400m);
 	if (result < 0)
 		goto error_bus_dev_start;
+	i2400m->ready = 1;
+	wmb();		/* see i2400m->ready's documentation  */
 	result = i2400m_firmware_check(i2400m);	/* fw versions ok? */
 	if (result < 0)
 		goto error_fw_check;
@@ -462,7 +464,6 @@ retry:
 	result = i2400m_check_mac_addr(i2400m);
 	if (result < 0)
 		goto error_check_mac_addr;
-	i2400m->ready = 1;
 	wimax_state_change(wimax_dev, WIMAX_ST_UNINITIALIZED);
 	result = i2400m_dev_initialize(i2400m);
 	if (result < 0)
@@ -475,6 +476,9 @@ retry:
 
 error_dev_initialize:
 error_check_mac_addr:
+	i2400m->ready = 0;
+	wmb();		/* see i2400m->ready's documentation  */
+	flush_workqueue(i2400m->work_queue);
 error_fw_check:
 	i2400m->bus_dev_stop(i2400m);
 error_bus_dev_start:
@@ -498,11 +502,15 @@ error_bootstrap:
 static
 int i2400m_dev_start(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 {
-	int result;
+	int result = 0;
 	mutex_lock(&i2400m->init_mutex);	/* Well, start the device */
-	result = __i2400m_dev_start(i2400m, bm_flags);
-	if (result >= 0)
-		i2400m->updown = 1;
+	if (i2400m->updown == 0) {
+		result = __i2400m_dev_start(i2400m, bm_flags);
+		if (result >= 0) {
+			i2400m->updown = 1;
+			wmb();	/* see i2400m->updown's documentation */
+		}
+	}
 	mutex_unlock(&i2400m->init_mutex);
 	return result;
 }
@@ -529,7 +537,14 @@ void __i2400m_dev_stop(struct i2400m *i2400m)
 	wimax_state_change(wimax_dev, __WIMAX_ST_QUIESCING);
 	i2400m_net_wake_stop(i2400m);
 	i2400m_dev_shutdown(i2400m);
-	i2400m->ready = 0;
+	/*
+	 * Make sure no report hooks are running *before* we stop the
+	 * communication infrastructure with the device.
+	 */
+	i2400m->ready = 0;	/* nobody can queue work anymore */
+	wmb();		/* see i2400m->ready's documentation  */
+	flush_workqueue(i2400m->work_queue);
+
 	i2400m->bus_dev_stop(i2400m);
 	destroy_workqueue(i2400m->work_queue);
 	i2400m_rx_release(i2400m);
@@ -551,6 +566,7 @@ void i2400m_dev_stop(struct i2400m *i2400m)
 	if (i2400m->updown) {
 		__i2400m_dev_stop(i2400m);
 		i2400m->updown = 0;
+		wmb();	/* see i2400m->updown's documentation  */
 	}
 	mutex_unlock(&i2400m->init_mutex);
 }
@@ -632,7 +648,6 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 	const char *reason;
 	struct i2400m *i2400m = iw->i2400m;
 	struct device *dev = i2400m_dev(i2400m);
-	enum wimax_st wimax_state;
 	struct i2400m_reset_ctx *ctx = i2400m->reset_ctx;
 
 	if (WARN_ON(iw->pl_size != sizeof(reason)))
@@ -647,29 +662,28 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 		/* We are still in i2400m_dev_start() [let it fail] or
 		 * i2400m_dev_stop() [we are shutting down anyway, so
 		 * ignore it] or we are resetting somewhere else. */
-		dev_err(dev, "device rebooted\n");
+		dev_err(dev, "device rebooted somewhere else?\n");
 		i2400m_msg_to_dev_cancel_wait(i2400m, -EL3RST);
 		complete(&i2400m->msg_completion);
 		goto out;
 	}
-	wimax_state = wimax_state_get(&i2400m->wimax_dev);
-	if (wimax_state < WIMAX_ST_UNINITIALIZED) {
-		dev_info(dev, "%s: it is down, ignoring\n", reason);
-		goto out_unlock;	/* ifconfig up/down wasn't called */
+	if (i2400m->updown == 0)  {
+		dev_info(dev, "%s: device is down, doing nothing\n", reason);
+		goto out_unlock;
 	}
 	dev_err(dev, "%s: reinitializing driver\n", reason);
 	__i2400m_dev_stop(i2400m);
-	i2400m->updown = 0;
 	result = __i2400m_dev_start(i2400m,
 				    I2400M_BRI_SOFT | I2400M_BRI_MAC_REINIT);
 	if (result < 0) {
+		i2400m->updown = 0;
+		wmb();		/* see i2400m->updown's documentation  */
 		dev_err(dev, "%s: cannot start the device: %d\n",
 			reason, result);
 		result = i2400m->bus_reset(i2400m, I2400M_RT_BUS);
 		if (result >= 0)
 			result = -ENODEV;
-	} else
-		i2400m->updown = 1;
+	}
 out_unlock:
 	if (i2400m->reset_ctx) {
 		ctx->result = result;
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 2b9c400..fbc156d 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -307,6 +307,27 @@ struct i2400m_barker_db;
  *     force this to be the first field so that we can get from
  *     netdev_priv() the right pointer.
  *
+ * @updown: the device is up and ready for transmitting control and
+ *     data packets. This implies @ready (communication infrastructure
+ *     with the device is ready) and the device's firmware has been
+ *     loaded and the device initialized.
+ *
+ *     Write to it only inside a i2400m->init_mutex protected area
+ *     followed with a wmb(); rmb() before accesing (unless locked
+ *     inside i2400m->init_mutex). Read access can be loose like that
+ *     [just using rmb()] because the paths that use this also do
+ *     other error checks later on.
+ *
+ * @ready: Communication infrastructure with the device is ready, data
+ *     frames can start to be passed around (this is lighter than
+ *     using the WiMAX state for certain hot paths).
+ *
+ *     Write to it only inside a i2400m->init_mutex protected area
+ *     followed with a wmb(); rmb() before accesing (unless locked
+ *     inside i2400m->init_mutex). Read access can be loose like that
+ *     [just using rmb()] because the paths that use this also do
+ *     other error checks later on.
+ *
  * @rx_reorder: 1 if RX reordering is enabled; this can only be
  *     set at probe time.
  *
@@ -458,7 +479,7 @@ struct i2400m {
 	unsigned updown:1;		/* Network device is up or down */
 	unsigned boot_mode:1;		/* is the device in boot mode? */
 	unsigned sboot:1;		/* signed or unsigned fw boot */
-	unsigned ready:1;		/* all probing steps done */
+	unsigned ready:1;		/* Device comm infrastructure ready */
 	unsigned rx_reorder:1;		/* RX reorder is enabled */
 	u8 trace_msg_from_user;		/* echo rx msgs to 'trace' pipe */
 					/* typed u8 so /sys/kernel/debug/u8 can tweak */
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index bcd411f..82c200a 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -177,8 +177,7 @@ void i2400m_report_hook_work(struct work_struct *ws)
 	struct i2400m_work *iw =
 		container_of(ws, struct i2400m_work, ws);
 	struct i2400m_report_hook_args *args = (void *) iw->pl;
-	if (iw->i2400m->ready)
-		i2400m_report_hook(iw->i2400m, args->l3l4_hdr, args->size);
+	i2400m_report_hook(iw->i2400m, args->l3l4_hdr, args->size);
 	kfree_skb(args->skb_rx);
 	i2400m_put(iw->i2400m);
 	kfree(iw);
@@ -305,11 +304,12 @@ void i2400m_rx_ctl(struct i2400m *i2400m, struct sk_buff *skb_rx,
 			.l3l4_hdr = l3l4_hdr,
 			.size = size
 		};
-		if (unlikely(i2400m->ready == 0))	/* only send if up */
-			return;
-		skb_get(skb_rx);
-		i2400m_queue_work(i2400m, i2400m_report_hook_work,
-				  GFP_KERNEL, &args, sizeof(args));
+		rmb();		/* see i2400m->ready's documentation  */
+		if (likely(i2400m->ready)) {	/* only send if up */
+			skb_get(skb_rx);
+			i2400m_queue_work(i2400m, i2400m_report_hook_work,
+					  GFP_KERNEL, &args, sizeof(args));
+		}
 		if (unlikely(i2400m->trace_msg_from_user))
 			wimax_msg(&i2400m->wimax_dev, "echo",
 				  l3l4_hdr, size, GFP_KERNEL);
@@ -363,8 +363,6 @@ void i2400m_rx_trace(struct i2400m *i2400m,
 		 msg_type & I2400M_MT_REPORT_MASK ? "REPORT" : "CMD/SET/GET",
 		 msg_type, size);
 	d_dump(2, dev, l3l4_hdr, size);
-	if (unlikely(i2400m->ready == 0))	/* only send if up */
-		return;
 	result = wimax_msg(wimax_dev, "trace", l3l4_hdr, size, GFP_KERNEL);
 	if (result < 0)
 		dev_err(dev, "error sending trace to userspace: %d\n",
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 07653de..f4dfb60 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -516,7 +516,10 @@ void i2400mu_disconnect(struct usb_interface *iface)
  * So at the end, the three cases require common handling.
  *
  * If at the time of this call the device's firmware is not loaded,
- * nothing has to be done.
+ * nothing has to be done. Note we can be "loose" about not reading
+ * i2400m->updown under i2400m->init_mutex. If it happens to change
+ * inmediately, other parts of the call flow will fail and effectively
+ * catch it.
  *
  * If the firmware is loaded, we need to:
  *
@@ -555,6 +558,7 @@ int i2400mu_suspend(struct usb_interface *iface, pm_message_t pm_msg)
 #endif
 
 	d_fnstart(3, dev, "(iface %p pm_msg %u)\n", iface, pm_msg.event);
+	rmb();		/* see i2400m->updown's documentation  */
 	if (i2400m->updown == 0)
 		goto no_firmware;
 	if (i2400m->state == I2400M_SS_DATA_PATH_CONNECTED && is_autosuspend) {
@@ -608,6 +612,7 @@ int i2400mu_resume(struct usb_interface *iface)
 	struct i2400m *i2400m = &i2400mu->i2400m;
 
 	d_fnstart(3, dev, "(iface %p)\n", iface);
+	rmb();		/* see i2400m->updown's documentation  */
 	if (i2400m->updown == 0) {
 		d_printf(1, dev, "fw was down, no resume neeed\n");
 		goto out;
diff --git a/include/net/wimax.h b/include/net/wimax.h
index 2af7bf8..d69c4a7 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -195,6 +195,12 @@
  *    defining the `struct nla_policy` for each message, it has to have
  *    an array size of WIMAX_GNL_ATTR_MAX+1.
  *
+ * The op_*() function pointers will not be called if the wimax_dev is
+ * in a state <= %WIMAX_ST_UNINITIALIZED. The exception is:
+ *
+ * - op_reset: can be called at any time after wimax_dev_add() has
+ *   been called.
+ *
  * THE PIPE INTERFACE:
  *
  * This interface is kept intentionally simple. The driver can send
-- 
1.6.2.5

