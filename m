From: Alan Ott <alan@signal11.us>
Subject: [PATCH v4 2/2] Bluetooth: hidp: Add support for hidraw  HIDIOCGFEATURE  and HIDIOCSFEATURE
Date: Mon, 16 Aug 2010 16:20:59 -0400
Message-ID: <1281990059-3562-3-git-send-email-alan__12070.8387614743$1281990153$gmane$org@signal11.us>
References: <1281442367.12579.206.camel@localhost.localdomain>
Cc: Alan Ott <alan@signal11.us>
To: Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	Antonio Ospite <ospite@studenti.unina.it>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel
Return-path: <netdev-owner@vger.kernel.org>
Received: from core.signal11.us ([64.251.29.136]:46252 "EHLO core.signal11.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756389Ab0HPUVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 16:21:51 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by core.signal11.us (Postfix) with SMTP id E3C9D1CCAA48
	for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 16:21:49 -0400 (EDT)
In-Reply-To: <1281442367.12579.206.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support or getting and setting feature reports for bluetooth
HID devices from HIDRAW.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/bluetooth/hidp/core.c |  114 +++++++++++++++++++++++++++++++++++++++++++--
 net/bluetooth/hidp/hidp.h |    8 +++
 2 files changed, 118 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index bfe641b..0e4880e 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -36,6 +36,7 @@
 #include <linux/file.h>
 #include <linux/init.h>
 #include <linux/wait.h>
+#include <linux/mutex.h>
 #include <net/sock.h>
 
 #include <linux/input.h>
@@ -313,6 +314,86 @@ static int hidp_send_report(struct hidp_session *session, struct hid_report *rep
 	return hidp_queue_report(session, buf, rsize);
 }
 
+static int hidp_get_raw_report(struct hid_device *hid,
+		unsigned char report_number,
+		unsigned char *data, size_t count,
+		unsigned char report_type)
+{
+	struct hidp_session *session = hid->driver_data;
+	struct sk_buff *skb;
+	size_t len;
+	int numbered_reports = hid->report_enum[report_type].numbered;
+
+	switch (report_type) {
+	case HID_FEATURE_REPORT:
+		report_type = HIDP_TRANS_GET_REPORT | HIDP_DATA_RTYPE_FEATURE;
+		break;
+	case HID_INPUT_REPORT:
+		report_type = HIDP_TRANS_GET_REPORT | HIDP_DATA_RTYPE_INPUT;
+		break;
+	case HID_OUTPUT_REPORT:
+		report_type = HIDP_TRANS_GET_REPORT | HIDP_DATA_RTYPE_OUPUT;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (mutex_lock_interruptible(&session->report_mutex))
+		return -ERESTARTSYS;
+
+	/* Set up our wait, and send the report request to the device. */
+	session->waiting_report_type = report_type & HIDP_DATA_RTYPE_MASK;
+	session->waiting_report_number = numbered_reports ? report_number : -1;
+	set_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
+	data[0] = report_number;
+	if (hidp_send_ctrl_message(hid->driver_data, report_type, data, 1))
+		goto err_eio;
+
+	/* Wait for the return of the report. The returned report
+	   gets put in session->report_return.  */
+	while (test_bit(HIDP_WAITING_FOR_RETURN, &session->flags)) {
+		int res;
+
+		res = wait_event_interruptible_timeout(session->report_queue,
+			!test_bit(HIDP_WAITING_FOR_RETURN, &session->flags),
+			5*HZ);
+		if (res == 0) {
+			/* timeout */
+			goto err_eio;
+		}
+		if (res < 0) {
+			/* signal */
+			goto err_restartsys;
+		}
+	}
+
+	skb = session->report_return;
+	if (skb) {
+		len = skb->len < count ? skb->len : count;
+		memcpy(data, skb->data, len);
+
+		kfree_skb(skb);
+		session->report_return = NULL;
+	} else {
+		/* Device returned a HANDSHAKE, indicating  protocol error. */
+		len = -EIO;
+	}
+
+	clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
+	mutex_unlock(&session->report_mutex);
+
+	return len;
+
+err_restartsys:
+	clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
+	mutex_unlock(&session->report_mutex);
+	return -ERESTARTSYS;
+err_eio:
+	clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
+	mutex_unlock(&session->report_mutex);
+	return -EIO;
+}
+
 static int hidp_output_raw_report(struct hid_device *hid, unsigned char *data, size_t count,
 		unsigned char report_type)
 {
@@ -367,6 +448,10 @@ static void hidp_process_handshake(struct hidp_session *session,
 	case HIDP_HSHK_ERR_INVALID_REPORT_ID:
 	case HIDP_HSHK_ERR_UNSUPPORTED_REQUEST:
 	case HIDP_HSHK_ERR_INVALID_PARAMETER:
+		if (test_bit(HIDP_WAITING_FOR_RETURN, &session->flags)) {
+			clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
+			wake_up_interruptible(&session->report_queue);
+		}
 		/* FIXME: Call into SET_ GET_ handlers here */
 		break;
 
@@ -403,9 +488,11 @@ static void hidp_process_hid_control(struct hidp_session *session,
 	}
 }
 
-static void hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
+/* Returns true if the passed-in skb should be freed by the caller. */
+static int hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
 				unsigned char param)
 {
+	int done_with_skb = 1;
 	BT_DBG("session %p skb %p len %d param 0x%02x", session, skb, skb->len, param);
 
 	switch (param) {
@@ -417,7 +504,6 @@ static void hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
 
 		if (session->hid)
 			hid_input_report(session->hid, HID_INPUT_REPORT, skb->data, skb->len, 0);
-
 		break;
 
 	case HIDP_DATA_RTYPE_OTHER:
@@ -429,12 +515,27 @@ static void hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
 		__hidp_send_ctrl_message(session,
 			HIDP_TRANS_HANDSHAKE | HIDP_HSHK_ERR_INVALID_PARAMETER, NULL, 0);
 	}
+
+	if (test_bit(HIDP_WAITING_FOR_RETURN, &session->flags) &&
+				param == session->waiting_report_type) {
+		if (session->waiting_report_number < 0 ||
+		    session->waiting_report_number == skb->data[0]) {
+			/* hidp_get_raw_report() is waiting on this report. */
+			session->report_return = skb;
+			done_with_skb = 0;
+			clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
+			wake_up_interruptible(&session->report_queue);
+		}
+	}
+
+	return done_with_skb;
 }
 
 static void hidp_recv_ctrl_frame(struct hidp_session *session,
 					struct sk_buff *skb)
 {
 	unsigned char hdr, type, param;
+	int free_skb = 1;
 
 	BT_DBG("session %p skb %p len %d", session, skb, skb->len);
 
@@ -454,7 +555,7 @@ static void hidp_recv_ctrl_frame(struct hidp_session *session,
 		break;
 
 	case HIDP_TRANS_DATA:
-		hidp_process_data(session, skb, param);
+		free_skb = hidp_process_data(session, skb, param);
 		break;
 
 	default:
@@ -463,7 +564,8 @@ static void hidp_recv_ctrl_frame(struct hidp_session *session,
 		break;
 	}
 
-	kfree_skb(skb);
+	if (free_skb)
+		kfree_skb(skb);
 }
 
 static void hidp_recv_intr_frame(struct hidp_session *session,
@@ -797,6 +899,7 @@ static int hidp_setup_hid(struct hidp_session *session,
 	hid->dev.parent = hidp_get_device(session);
 	hid->ll_driver = &hidp_hid_driver;
 
+	hid->hid_get_raw_report = hidp_get_raw_report;
 	hid->hid_output_raw_report = hidp_output_raw_report;
 
 	err = hid_add_device(hid);
@@ -857,6 +960,9 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	skb_queue_head_init(&session->ctrl_transmit);
 	skb_queue_head_init(&session->intr_transmit);
 
+	mutex_init(&session->report_mutex);
+	init_waitqueue_head(&session->report_queue);
+
 	session->flags   = req->flags & (1 << HIDP_BLUETOOTH_VENDOR_ID);
 	session->idle_to = req->idle_to;
 
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index 8d934a1..00e71dd 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -80,6 +80,7 @@
 #define HIDP_VIRTUAL_CABLE_UNPLUG	0
 #define HIDP_BOOT_PROTOCOL_MODE		1
 #define HIDP_BLUETOOTH_VENDOR_ID	9
+#define	HIDP_WAITING_FOR_RETURN		10
 
 struct hidp_connadd_req {
 	int   ctrl_sock;	// Connected control socket
@@ -154,6 +155,13 @@ struct hidp_session {
 	struct sk_buff_head ctrl_transmit;
 	struct sk_buff_head intr_transmit;
 
+	/* Used in hidp_get_raw_report() */
+	int waiting_report_type; /* HIDP_DATA_RTYPE_* */
+	int waiting_report_number; /* -1 for not numbered */
+	struct mutex report_mutex;
+	struct sk_buff *report_return;
+	wait_queue_head_t report_queue;
+
 	/* Report descriptor */
 	__u8 *rd_data;
 	uint rd_size;
-- 
1.7.0.4


