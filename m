From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 06/47] Bluetooth: Let HIDP grab the device reference for connections
Date: Sun, 30 Aug 2009 01:50:20 -0700
Message-ID: <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53270 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbZH3Iv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:56 -0400
In-Reply-To: <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The core exports the hci_conn_hold_device() and hci_conn_put_device()
functions for device reference of connections. Use this to ensure that
the uevents from the parent are send after the child ones.

Based on a report by Brian Rogers <brian@xyzw.org>

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hidp/core.c |   62 +++++++++++++++++++++++++++++---------------
 net/bluetooth/hidp/hidp.h |    2 +
 2 files changed, 43 insertions(+), 21 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index f912d65..09bedeb 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -93,10 +93,14 @@ static void __hidp_link_session(struct hidp_session *session)
 {
 	__module_get(THIS_MODULE);
 	list_add(&session->list, &hidp_session_list);
+
+	hci_conn_hold_device(session->conn);
 }
 
 static void __hidp_unlink_session(struct hidp_session *session)
 {
+	hci_conn_put_device(session->conn);
+
 	list_del(&session->list);
 	module_put(THIS_MODULE);
 }
@@ -577,7 +581,9 @@ static int hidp_session(void *arg)
 			hidinput_disconnect(session->hid);
 		if (session->hid->claimed & HID_CLAIMED_HIDRAW)
 			hidraw_disconnect(session->hid);
+
 		hid_destroy_device(session->hid);
+		session->hid = NULL;
 	}
 
 	/* Wakeup user-space polling for socket errors */
@@ -605,25 +611,27 @@ static struct device *hidp_get_device(struct hidp_session *session)
 {
 	bdaddr_t *src = &bt_sk(session->ctrl_sock->sk)->src;
 	bdaddr_t *dst = &bt_sk(session->ctrl_sock->sk)->dst;
+	struct device *device = NULL;
 	struct hci_dev *hdev;
-	struct hci_conn *conn;
 
 	hdev = hci_get_route(dst, src);
 	if (!hdev)
 		return NULL;
 
-	conn = hci_conn_hash_lookup_ba(hdev, ACL_LINK, dst);
+	session->conn = hci_conn_hash_lookup_ba(hdev, ACL_LINK, dst);
+	if (session->conn)
+		device = &session->conn->dev;
 
 	hci_dev_put(hdev);
 
-	return conn ? &conn->dev : NULL;
+	return device;
 }
 
 static int hidp_setup_input(struct hidp_session *session,
 				struct hidp_connadd_req *req)
 {
 	struct input_dev *input;
-	int i;
+	int err, i;
 
 	input = input_allocate_device();
 	if (!input)
@@ -670,7 +678,13 @@ static int hidp_setup_input(struct hidp_session *session,
 
 	input->event = hidp_input_event;
 
-	return input_register_device(input);
+	err = input_register_device(input);
+	if (err < 0) {
+		hci_conn_put_device(session->conn);
+		return err;
+	}
+
+	return 0;
 }
 
 static int hidp_open(struct hid_device *hid)
@@ -752,13 +766,11 @@ static int hidp_setup_hid(struct hidp_session *session,
 {
 	struct hid_device *hid;
 	bdaddr_t src, dst;
-	int ret;
+	int err;
 
 	hid = hid_allocate_device();
-	if (IS_ERR(hid)) {
-		ret = PTR_ERR(session->hid);
-		goto err;
-	}
+	if (IS_ERR(hid))
+		return PTR_ERR(session->hid);
 
 	session->hid = hid;
 	session->req = req;
@@ -780,16 +792,17 @@ static int hidp_setup_hid(struct hidp_session *session,
 	hid->dev.parent = hidp_get_device(session);
 	hid->ll_driver = &hidp_hid_driver;
 
-	ret = hid_add_device(hid);
-	if (ret)
-		goto err_hid;
+	err = hid_add_device(hid);
+	if (err < 0)
+		goto failed;
 
 	return 0;
-err_hid:
+
+failed:
 	hid_destroy_device(hid);
 	session->hid = NULL;
-err:
-	return ret;
+
+	return err;
 }
 
 int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock, struct socket *intr_sock)
@@ -839,13 +852,13 @@ int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock,
 	if (req->rd_size > 0) {
 		err = hidp_setup_hid(session, req);
 		if (err && err != -ENODEV)
-			goto err_skb;
+			goto purge;
 	}
 
 	if (!session->hid) {
 		err = hidp_setup_input(session, req);
 		if (err < 0)
-			goto err_skb;
+			goto purge;
 	}
 
 	__hidp_link_session(session);
@@ -873,13 +886,20 @@ unlink:
 
 	__hidp_unlink_session(session);
 
-	if (session->input)
+	if (session->input) {
 		input_unregister_device(session->input);
-	if (session->hid)
+		session->input = NULL;
+	}
+
+	if (session->hid) {
 		hid_destroy_device(session->hid);
-err_skb:
+		session->hid = NULL;
+	}
+
+purge:
 	skb_queue_purge(&session->ctrl_transmit);
 	skb_queue_purge(&session->intr_transmit);
+
 failed:
 	up_write(&hidp_session_sem);
 
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index e503c89..faf3d74 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -126,6 +126,8 @@ int hidp_get_conninfo(struct hidp_conninfo *ci);
 struct hidp_session {
 	struct list_head list;
 
+	struct hci_conn *conn;
+
 	struct socket *ctrl_sock;
 	struct socket *intr_sock;
 
-- 
1.6.2.5

