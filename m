From: Alan Ott <alan@signal11.us>
Subject: [PATCH v5 4/4] bt hidp: Add support for hidraw HIDIOCGFEATURE and HIDIOCSFEATURE
Date: Tue, 18 Jan 2011 03:04:40 -0500
Message-ID: <1295337880-12452-5-git-send-email-alan__32486.3840047785$1295339849$gmane$org@signal11.us>
References: <1295337880-12452-1-git-send-email-alan@signal11.us>
Cc: Alan Ott <alan@signal11.us>
To: Jiri Kosina <jkosina@suse.cz>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Alan Ott <alan@signal11.
Return-path: <netdev-owner@vger.kernel.org>
Received: from core.signal11.us ([64.251.29.136]:43406 "EHLO core.signal11.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740Ab1ARIgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 03:36:53 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by core.signal11.us (Postfix) with SMTP id E25C31CCABA2
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 03:05:11 -0500 (EST)
In-Reply-To: <1295337880-12452-1-git-send-email-alan@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support or getting and setting feature reports for bluetooth
HID devices from HIDRAW.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/bluetooth/hidp/core.c |  113 +++++++++++++++++++++++++++++++++++++++++++--
 net/bluetooth/hidp/hidp.h |    8 +++
 2 files changed, 117 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 5383e6c..6df8ea1 100644
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
@@ -409,6 +490,10 @@ static void hidp_process_handshake(struct hidp_session *session,
 	case HIDP_HSHK_ERR_INVALID_REPORT_ID:
 	case HIDP_HSHK_ERR_UNSUPPORTED_REQUEST:
 	case HIDP_HSHK_ERR_INVALID_PARAMETER:
+		if (test_bit(HIDP_WAITING_FOR_RETURN, &session->flags)) {
+			clear_bit(HIDP_WAITING_FOR_RETURN, &session->flags);
+			wake_up_interruptible(&session->report_queue);
+		}
 		/* FIXME: Call into SET_ GET_ handlers here */
 		break;
 
@@ -451,9 +536,11 @@ static void hidp_process_hid_control(struct hidp_session *session,
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
@@ -465,7 +552,6 @@ static void hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
 
 		if (session->hid)
 			hid_input_report(session->hid, HID_INPUT_REPORT, skb->data, skb->len, 0);
-
 		break;
 
 	case HIDP_DATA_RTYPE_OTHER:
@@ -477,12 +563,27 @@ static void hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
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
 
@@ -502,7 +603,7 @@ static void hidp_recv_ctrl_frame(struct hidp_session *session,
 		break;
 
 	case HIDP_TRANS_DATA:
-		hidp_process_data(session, skb, param);
+		free_skb = hidp_process_data(session, skb, param);
 		break;
 
 	default:
@@ -511,7 +612,8 @@ static void hidp_recv_ctrl_frame(struct hidp_session *session,
 		break;
 	}
 
-	kfree_skb(skb);
+	if (free_skb)
+		kfree_skb(skb);
 }
 
 static void hidp_recv_intr_frame(struct hidp_session *session,
@@ -845,6 +947,7 @@ static int hidp_setup_hid(struct hidp_session *session,
 	hid->dev.parent = hidp_get_device(session);
 	hid->ll_driver = &hidp_hid_driver;
 
+	hid->hid_get_raw_report = hidp_get_raw_report;
 	hid->hid_output_raw_report = hidp_output_raw_report;
 
 	return 0;
@@ -897,6 +1000,8 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	skb_queue_head_init(&session->ctrl_transmit);
 	skb_queue_head_init(&session->intr_transmit);
 
+	mutex_init(&session->report_mutex);
+	init_waitqueue_head(&session->report_queue);
 	init_waitqueue_head(&session->startup_queue);
 	session->waiting_for_startup = 1;
 	session->flags   = req->flags & (1 << HIDP_BLUETOOTH_VENDOR_ID);
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index 92e093e..13de5fa 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -80,6 +80,7 @@
 #define HIDP_VIRTUAL_CABLE_UNPLUG	0
 #define HIDP_BOOT_PROTOCOL_MODE		1
 #define HIDP_BLUETOOTH_VENDOR_ID	9
+#define	HIDP_WAITING_FOR_RETURN		10
 #define HIDP_WAITING_FOR_SEND_ACK	11
 
 struct hidp_connadd_req {
@@ -155,6 +156,13 @@ struct hidp_session {
 	struct sk_buff_head ctrl_transmit;
 	struct sk_buff_head intr_transmit;
 
+	/* Used in hidp_get_raw_report() */
+	int waiting_report_type; /* HIDP_DATA_RTYPE_* */
+	int waiting_report_number; /* -1 for not numbered */
+	struct mutex report_mutex;
+	struct sk_buff *report_return;
+	wait_queue_head_t report_queue;
+
 	/* Used in hidp_output_raw_report() */
 	int output_report_success; /* boolean */
 
-- 
1.7.0.4


