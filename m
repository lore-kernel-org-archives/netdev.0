From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 01/15] wimax/i2400m: USB driver uses a configurable endpoint map
Date: Wed,  4 Nov 2009 13:39:42 -0800
Message-ID: <2093586de29418820b89aae05746511392f8ad73.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758264AbZKDVl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:57 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

Newer generations of the i2400m USB WiMAX device use a different
endpoint map; in order to make it easy to support it, we make the
endpoint-to-function mapeable instead of static.

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m-usb.h |   14 ++++++++------
 drivers/net/wimax/i2400m/usb-fw.c     |    5 +++--
 drivers/net/wimax/i2400m/usb-notif.c  |    3 ++-
 drivers/net/wimax/i2400m/usb-rx.c     |    2 +-
 drivers/net/wimax/i2400m/usb-tx.c     |    2 +-
 drivers/net/wimax/i2400m/usb.c        |   20 ++++++++++++++------
 6 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 79c3753..f73a067 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -88,6 +88,13 @@ struct edc {
 	u16 errorcount;
 };
 
+struct i2400m_endpoint_cfg {
+	unsigned char bulk_out;
+	unsigned char notification;
+	unsigned char reset_cold;
+	unsigned char bulk_in;
+};
+
 static inline void edc_init(struct edc *edc)
 {
 	edc->timestart = jiffies;
@@ -141,12 +148,6 @@ enum {
 	I2400MU_MAX_NOTIFICATION_LEN = 256,
 	I2400MU_BLK_SIZE = 16,
 	I2400MU_PL_SIZE_MAX = 0x3EFF,
-
-	/* Endpoints */
-	I2400MU_EP_BULK_OUT = 0,
-	I2400MU_EP_NOTIFICATION,
-	I2400MU_EP_RESET_COLD,
-	I2400MU_EP_BULK_IN,
 };
 
 
@@ -216,6 +217,7 @@ struct i2400mu {
 	struct usb_device *usb_dev;
 	struct usb_interface *usb_iface;
 	struct edc urb_edc;		/* Error density counter */
+	struct i2400m_endpoint_cfg endpoint_cfg;
 
 	struct urb *notif_urb;
 	struct task_struct *tx_kthread;
diff --git a/drivers/net/wimax/i2400m/usb-fw.c b/drivers/net/wimax/i2400m/usb-fw.c
index 5ad287c..a2250e4 100644
--- a/drivers/net/wimax/i2400m/usb-fw.c
+++ b/drivers/net/wimax/i2400m/usb-fw.c
@@ -99,7 +99,7 @@ ssize_t i2400mu_tx_bulk_out(struct i2400mu *i2400mu, void *buf, size_t buf_size)
 		dev_err(dev, "BM-CMD: can't get autopm: %d\n", result);
 		do_autopm = 0;
 	}
-	epd = usb_get_epd(i2400mu->usb_iface, I2400MU_EP_BULK_OUT);
+	epd = usb_get_epd(i2400mu->usb_iface, i2400mu->endpoint_cfg.bulk_out);
 	pipe = usb_sndbulkpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 retry:
 	result = usb_bulk_msg(i2400mu->usb_dev, pipe, buf, buf_size, &len, HZ);
@@ -226,7 +226,8 @@ int i2400mu_notif_submit(struct i2400mu *i2400mu, struct urb *urb,
 	struct usb_endpoint_descriptor *epd;
 	int pipe;
 
-	epd = usb_get_epd(i2400mu->usb_iface, I2400MU_EP_NOTIFICATION);
+	epd = usb_get_epd(i2400mu->usb_iface,
+			  i2400mu->endpoint_cfg.notification);
 	pipe = usb_rcvintpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 	usb_fill_int_urb(urb, i2400mu->usb_dev, pipe,
 			 i2400m->bm_ack_buf, I2400M_BM_ACK_BUF_SIZE,
diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
index 6add27c..3e11e35 100644
--- a/drivers/net/wimax/i2400m/usb-notif.c
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -220,7 +220,8 @@ int i2400mu_notification_setup(struct i2400mu *i2400mu)
 		dev_err(dev, "notification: cannot allocate URB\n");
 		goto error_alloc_urb;
 	}
-	epd = usb_get_epd(i2400mu->usb_iface, I2400MU_EP_NOTIFICATION);
+	epd = usb_get_epd(i2400mu->usb_iface,
+			  i2400mu->endpoint_cfg.notification);
 	usb_pipe = usb_rcvintpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 	usb_fill_int_urb(i2400mu->notif_urb, i2400mu->usb_dev, usb_pipe,
 			 buf, I2400MU_MAX_NOTIFICATION_LEN,
diff --git a/drivers/net/wimax/i2400m/usb-rx.c b/drivers/net/wimax/i2400m/usb-rx.c
index a314799..e494e37 100644
--- a/drivers/net/wimax/i2400m/usb-rx.c
+++ b/drivers/net/wimax/i2400m/usb-rx.c
@@ -204,7 +204,7 @@ struct sk_buff *i2400mu_rx(struct i2400mu *i2400mu, struct sk_buff *rx_skb)
 		dev_err(dev, "RX: can't get autopm: %d\n", result);
 		do_autopm = 0;
 	}
-	epd = usb_get_epd(i2400mu->usb_iface, I2400MU_EP_BULK_IN);
+	epd = usb_get_epd(i2400mu->usb_iface, i2400mu->endpoint_cfg.bulk_in);
 	usb_pipe = usb_rcvbulkpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 retry:
 	rx_size = skb_end_pointer(rx_skb) - rx_skb->data - rx_skb->len;
diff --git a/drivers/net/wimax/i2400m/usb-tx.c b/drivers/net/wimax/i2400m/usb-tx.c
index dfd8933..90dfff1 100644
--- a/drivers/net/wimax/i2400m/usb-tx.c
+++ b/drivers/net/wimax/i2400m/usb-tx.c
@@ -101,7 +101,7 @@ int i2400mu_tx(struct i2400mu *i2400mu, struct i2400m_msg_hdr *tx_msg,
 		dev_err(dev, "TX: can't get autopm: %d\n", result);
 		do_autopm = 0;
 	}
-	epd = usb_get_epd(i2400mu->usb_iface, I2400MU_EP_BULK_OUT);
+	epd = usb_get_epd(i2400mu->usb_iface, i2400mu->endpoint_cfg.bulk_out);
 	usb_pipe = usb_sndbulkpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 retry:
 	result = usb_bulk_msg(i2400mu->usb_dev, usb_pipe,
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 8f7b16a..a5879e2 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -232,13 +232,15 @@ int i2400mu_bus_reset(struct i2400m *i2400m, enum i2400m_reset_type rt)
 
 	d_fnstart(3, dev, "(i2400m %p rt %u)\n", i2400m, rt);
 	if (rt == I2400M_RT_WARM)
-		result = __i2400mu_send_barker(i2400mu, i2400m_WARM_BOOT_BARKER,
-					       sizeof(i2400m_WARM_BOOT_BARKER),
-					       I2400MU_EP_BULK_OUT);
+		result = __i2400mu_send_barker(
+			i2400mu, i2400m_WARM_BOOT_BARKER,
+			sizeof(i2400m_WARM_BOOT_BARKER),
+			i2400mu->endpoint_cfg.bulk_out);
 	else if (rt == I2400M_RT_COLD)
-		result = __i2400mu_send_barker(i2400mu, i2400m_COLD_BOOT_BARKER,
-					       sizeof(i2400m_COLD_BOOT_BARKER),
-					       I2400MU_EP_RESET_COLD);
+		result = __i2400mu_send_barker(
+			i2400mu, i2400m_COLD_BOOT_BARKER,
+			sizeof(i2400m_COLD_BOOT_BARKER),
+			i2400mu->endpoint_cfg.reset_cold);
 	else if (rt == I2400M_RT_BUS) {
 do_bus_reset:
 		result = usb_reset_device(i2400mu->usb_dev);
@@ -412,6 +414,12 @@ int i2400mu_probe(struct usb_interface *iface,
 	i2400m->bus_fw_names = i2400mu_bus_fw_names;
 	i2400m->bus_bm_mac_addr_impaired = 0;
 
+	{
+		i2400mu->endpoint_cfg.bulk_out = 0;
+		i2400mu->endpoint_cfg.notification = 1;
+		i2400mu->endpoint_cfg.reset_cold = 2;
+		i2400mu->endpoint_cfg.bulk_in = 3;
+	}
 #ifdef CONFIG_PM
 	iface->needs_remote_wakeup = 1;		/* autosuspend (15s delay) */
 	device_init_wakeup(dev, 1);
-- 
1.6.2.5

