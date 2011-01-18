From: Alan Ott <alan@signal11.us>
Subject: [PATCH v5 2/4] bt hidp: Wait for ACK on Sent Reports
Date: Tue, 18 Jan 2011 03:04:38 -0500
Message-ID: <1295337880-12452-3-git-send-email-alan__7983.33885982192$1295339851$gmane$org@signal11.us>
References: <1295337880-12452-1-git-send-email-alan@signal11.us>
Cc: Alan Ott <alan@signal11.us>
To: Jiri Kosina <jkosina@suse.cz>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Alan Ott <alan@signal11.
Return-path: <netdev-owner@vger.kernel.org>
Received: from core.signal11.us ([64.251.29.136]:43408 "EHLO core.signal11.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765Ab1ARIgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 03:36:53 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by core.signal11.us (Postfix) with SMTP id 9F0DC1CCABAD
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 03:05:10 -0500 (EST)
In-Reply-To: <1295337880-12452-1-git-send-email-alan@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wait for an ACK from the device before returning from
hidp_output_raw_report(). This way, failures can be returned to the user
application. Also, it prevents ACK/NAK packets from an output packet from
being confused with ACK/NAK packets from an input request packet.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/bluetooth/hidp/core.c |   54 ++++++++++++++++++++++++++++++++++++++++++--
 net/bluetooth/hidp/hidp.h |    4 +++
 2 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 67cc4bc..5383e6c 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -316,6 +316,9 @@ static int hidp_send_report(struct hidp_session *session, struct hid_report *rep
 static int hidp_output_raw_report(struct hid_device *hid, unsigned char *data, size_t count,
 		unsigned char report_type)
 {
+	struct hidp_session *session = hid->driver_data;
+	int ret;
+
 	switch (report_type) {
 	case HID_FEATURE_REPORT:
 		report_type = HIDP_TRANS_SET_REPORT | HIDP_DATA_RTYPE_FEATURE;
@@ -327,10 +330,47 @@ static int hidp_output_raw_report(struct hid_device *hid, unsigned char *data, s
 		return -EINVAL;
 	}
 
+	if (mutex_lock_interruptible(&session->report_mutex))
+		return -ERESTARTSYS;
+
+	/* Set up our wait, and send the report request to the device. */
+	set_bit(HIDP_WAITING_FOR_SEND_ACK, &session->flags);
 	if (hidp_send_ctrl_message(hid->driver_data, report_type,
-			data, count))
-		return -ENOMEM;
-	return count;
+			data, count)) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	/* Wait for the ACK from the device. */
+	while (test_bit(HIDP_WAITING_FOR_SEND_ACK, &session->flags)) {
+		int res;
+
+		res = wait_event_interruptible_timeout(session->report_queue,
+			!test_bit(HIDP_WAITING_FOR_SEND_ACK, &session->flags),
+			10*HZ);
+		if (res == 0) {
+			/* timeout */
+			ret = -EIO;
+			goto err;
+		}
+		if (res < 0) {
+			/* signal */
+			ret = -ERESTARTSYS;
+			goto err;
+		}
+	}
+
+	if (!session->output_report_success) {
+		ret = -EIO;
+		goto err;
+	}
+
+	ret = count;
+
+err:
+	clear_bit(HIDP_WAITING_FOR_SEND_ACK, &session->flags);
+	mutex_unlock(&session->report_mutex);
+	return ret;
 }
 
 static void hidp_idle_timeout(unsigned long arg)
@@ -357,10 +397,12 @@ static void hidp_process_handshake(struct hidp_session *session,
 					unsigned char param)
 {
 	BT_DBG("session %p param 0x%02x", session, param);
+	session->output_report_success = 0; /* default condition */
 
 	switch (param) {
 	case HIDP_HSHK_SUCCESSFUL:
 		/* FIXME: Call into SET_ GET_ handlers here */
+		session->output_report_success = 1;
 		break;
 
 	case HIDP_HSHK_NOT_READY:
@@ -385,6 +427,12 @@ static void hidp_process_handshake(struct hidp_session *session,
 			HIDP_TRANS_HANDSHAKE | HIDP_HSHK_ERR_INVALID_PARAMETER, NULL, 0);
 		break;
 	}
+
+	/* Wake up the waiting thread. */
+	if (test_bit(HIDP_WAITING_FOR_SEND_ACK, &session->flags)) {
+		clear_bit(HIDP_WAITING_FOR_SEND_ACK, &session->flags);
+		wake_up_interruptible(&session->report_queue);
+	}
 }
 
 static void hidp_process_hid_control(struct hidp_session *session,
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index 2cc35dc..92e093e 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -80,6 +80,7 @@
 #define HIDP_VIRTUAL_CABLE_UNPLUG	0
 #define HIDP_BOOT_PROTOCOL_MODE		1
 #define HIDP_BLUETOOTH_VENDOR_ID	9
+#define HIDP_WAITING_FOR_SEND_ACK	11
 
 struct hidp_connadd_req {
 	int   ctrl_sock;	// Connected control socket
@@ -154,6 +155,9 @@ struct hidp_session {
 	struct sk_buff_head ctrl_transmit;
 	struct sk_buff_head intr_transmit;
 
+	/* Used in hidp_output_raw_report() */
+	int output_report_success; /* boolean */
+
 	/* Report descriptor */
 	__u8 *rd_data;
 	uint rd_size;
-- 
1.7.0.4


