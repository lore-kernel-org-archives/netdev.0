From: Alan Ott <alan@signal11.us>
Subject: [PATCH v5 1/4] bt hidp: Move hid_add_device() call to after hidp_session() has started.
Date: Tue, 18 Jan 2011 03:04:37 -0500
Message-ID: <1295337880-12452-2-git-send-email-alan__25500.4852232107$1295339833$gmane$org@signal11.us>
References: <1295337880-12452-1-git-send-email-alan@signal11.us>
Cc: Alan Ott <alan@signal11.us>
To: Jiri Kosina <jkosina@suse.cz>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Alan Ott <alan@signal11.
Return-path: <netdev-owner@vger.kernel.org>
Received: from core.signal11.us ([64.251.29.136]:43404 "EHLO core.signal11.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673Ab1ARIgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 03:36:52 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by core.signal11.us (Postfix) with SMTP id EA0C01CCABAB
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 03:05:09 -0500 (EST)
In-Reply-To: <1295337880-12452-1-git-send-email-alan@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the call to hid_add_device() (which calls a device's probe() function)
to after the kernel_thread() call which starts the hidp_session() thread.
This ensures the Bluetooth receive socket is fully running by the time a
device's probe() function is called. This way, a device can communicate
(send and receive) with the Bluetooth device from its probe() function.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/bluetooth/hidp/core.c |   28 ++++++++++++++++++++--------
 net/bluetooth/hidp/hidp.h |    3 +++
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 29544c2..67cc4bc 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -563,6 +563,8 @@ static int hidp_session(void *arg)
 	init_waitqueue_entry(&intr_wait, current);
 	add_wait_queue(sk_sleep(ctrl_sk), &ctrl_wait);
 	add_wait_queue(sk_sleep(intr_sk), &intr_wait);
+	session->waiting_for_startup = 0;
+	wake_up_interruptible(&session->startup_queue);
 	while (!atomic_read(&session->terminate)) {
 		set_current_state(TASK_INTERRUPTIBLE);
 
@@ -754,6 +756,8 @@ static struct hid_ll_driver hidp_hid_driver = {
 	.hidinput_input_event = hidp_hidinput_event,
 };
 
+/* This function sets up the hid device. It does not add it
+   to the HID system. That is done in hidp_add_connection(). */
 static int hidp_setup_hid(struct hidp_session *session,
 				struct hidp_connadd_req *req)
 {
@@ -795,16 +799,8 @@ static int hidp_setup_hid(struct hidp_session *session,
 
 	hid->hid_output_raw_report = hidp_output_raw_report;
 
-	err = hid_add_device(hid);
-	if (err < 0)
-		goto failed;
-
 	return 0;
 
-failed:
-	hid_destroy_device(hid);
-	session->hid = NULL;
-
 fault:
 	kfree(session->rd_data);
 	session->rd_data = NULL;
@@ -853,6 +849,8 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	skb_queue_head_init(&session->ctrl_transmit);
 	skb_queue_head_init(&session->intr_transmit);
 
+	init_waitqueue_head(&session->startup_queue);
+	session->waiting_for_startup = 1;
 	session->flags   = req->flags & (1 << HIDP_BLUETOOTH_VENDOR_ID);
 	session->idle_to = req->idle_to;
 
@@ -875,6 +873,14 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	err = kernel_thread(hidp_session, session, CLONE_KERNEL);
 	if (err < 0)
 		goto unlink;
+	while (session->waiting_for_startup) {
+		wait_event_interruptible(session->startup_queue,
+			!session->waiting_for_startup);
+	}
+
+	err = hid_add_device(session->hid);
+	if (err < 0)
+		goto err_add_device;
 
 	if (session->input) {
 		hidp_send_ctrl_message(session,
@@ -888,6 +894,12 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	up_write(&hidp_session_sem);
 	return 0;
 
+err_add_device:
+	hid_destroy_device(session->hid);
+	session->hid = NULL;
+	atomic_inc(&session->terminate);
+	hidp_schedule(session);
+
 unlink:
 	hidp_del_timer(session);
 
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index 8d934a1..2cc35dc 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -157,6 +157,9 @@ struct hidp_session {
 	/* Report descriptor */
 	__u8 *rd_data;
 	uint rd_size;
+
+	wait_queue_head_t startup_queue;
+	int waiting_for_startup;
 };
 
 static inline void hidp_schedule(struct hidp_session *session)
-- 
1.7.0.4


