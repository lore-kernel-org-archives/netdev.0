From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 6/6] Bluetooth: Keep a copy of each HID device's report descriptor
Date: Fri,  5 Feb 2010 12:05:39 -0800
Message-ID: <15c697ce1c5b408c5e20dcdc6aea2968d1125b75.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
 <1038a00b458997661bcd0e780a24dc280a8841fc.1265399549.git.marcel@holtmann.org>
 <485f1eff73a7b932fd3abb0dfcf804e1a1f59025.1265399549.git.marcel@holtmann.org>
 <6c2718da59613d76013b501bf0f8bcf9d7794b2d.1265399549.git.marcel@holtmann.org>
 <88d1a0cf659438a66135661538ae332b23f8635a.1265399549.git.marcel@holtmann.org>
 <c390216b3e868b16d8154939f4b6f8c16dbd9a9f.1265399549.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54203 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757286Ab0BEUGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:06:49 -0500
In-Reply-To: <c390216b3e868b16d8154939f4b6f8c16dbd9a9f.1265399549.git.marcel@holtmann.org>
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Poole <mdpoole@troilus.org>

The report descriptor is read by user space (via the Service
Discovery Protocol), so it is only available during the ioctl
to connect. However, the HID probe function that needs the
descriptor might not be called until a specific module is
loaded. Keep a copy of the descriptor so it is available for
later use.

Signed-off-by: Michael Poole <mdpoole@troilus.org>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hidp/core.c |   49 ++++++++++++++++++++++-----------------------
 net/bluetooth/hidp/hidp.h |    4 ++-
 2 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 6cf526d..fc6ec1e 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -703,29 +703,9 @@ static void hidp_close(struct hid_device *hid)
 static int hidp_parse(struct hid_device *hid)
 {
 	struct hidp_session *session = hid->driver_data;
-	struct hidp_connadd_req *req = session->req;
-	unsigned char *buf;
-	int ret;
-
-	buf = kmalloc(req->rd_size, GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
-	if (copy_from_user(buf, req->rd_data, req->rd_size)) {
-		kfree(buf);
-		return -EFAULT;
-	}
-
-	ret = hid_parse_report(session->hid, buf, req->rd_size);
-
-	kfree(buf);
-
-	if (ret)
-		return ret;
-
-	session->req = NULL;
 
-	return 0;
+	return hid_parse_report(session->hid, session->rd_data,
+			session->rd_size);
 }
 
 static int hidp_start(struct hid_device *hid)
@@ -770,12 +750,24 @@ static int hidp_setup_hid(struct hidp_session *session,
 	bdaddr_t src, dst;
 	int err;
 
+	session->rd_data = kzalloc(req->rd_size, GFP_KERNEL);
+	if (!session->rd_data)
+		return -ENOMEM;
+
+	if (copy_from_user(session->rd_data, req->rd_data, req->rd_size)) {
+		err = -EFAULT;
+		goto fault;
+	}
+	session->rd_size = req->rd_size;
+
 	hid = hid_allocate_device();
-	if (IS_ERR(hid))
-		return PTR_ERR(hid);
+	if (IS_ERR(hid)) {
+		err = PTR_ERR(hid);
+		goto fault;
+	}
 
 	session->hid = hid;
-	session->req = req;
+
 	hid->driver_data = session;
 
 	baswap(&src, &bt_sk(session->ctrl_sock->sk)->src);
@@ -806,6 +798,10 @@ failed:
 	hid_destroy_device(hid);
 	session->hid = NULL;
 
+fault:
+	kfree(session->rd_data);
+	session->rd_data = NULL;
+
 	return err;
 }
 
@@ -900,6 +896,9 @@ unlink:
 		session->hid = NULL;
 	}
 
+	kfree(session->rd_data);
+	session->rd_data = NULL;
+
 purge:
 	skb_queue_purge(&session->ctrl_transmit);
 	skb_queue_purge(&session->intr_transmit);
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index faf3d74..a4e215d 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -154,7 +154,9 @@ struct hidp_session {
 	struct sk_buff_head ctrl_transmit;
 	struct sk_buff_head intr_transmit;
 
-	struct hidp_connadd_req *req;
+	/* Report descriptor */
+	__u8 *rd_data;
+	uint rd_size;
 };
 
 static inline void hidp_schedule(struct hidp_session *session)
-- 
1.6.6

