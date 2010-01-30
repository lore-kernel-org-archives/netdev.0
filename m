From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 5/5] Bluetooth: Use the control channel for raw HID reports
Date: Sat, 30 Jan 2010 06:08:48 -0800
Message-ID: <6bf8268f9a91f1065c99503161ebd061492bebe3.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
 <fcafde2e6d81aa7901f9b10e6a097592f0637b79.1264859950.git.marcel@holtmann.org>
 <e420aba331f44de0eed6871441293a6124d566d1.1264859950.git.marcel@holtmann.org>
 <7427847d2d044d85f478757ea03165ae3cfe87c4.1264859950.git.marcel@holtmann.org>
 <9670d80a9a6e24725c4111bef5d6cc7786ad0dc5.1264859950.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60253 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab0A3OJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 09:09:40 -0500
In-Reply-To: <9670d80a9a6e24725c4111bef5d6cc7786ad0dc5.1264859950.git.marcel@holtmann.org>
In-Reply-To: <cover.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bastien Nocera <hadess@hadess.net>

In commit 2da31939a42f7a676a0bc5155d6a0a39ed8451f2, support
for Bluetooth hid_output_raw_report was added, but it pushes
the data to the interrupt channel instead of the contol one.

This patch makes hid_output_raw_report use the control channel
instead. Using the interrupt channel was a mistake.

Signed-off-by: Bastien Nocera <hadess@hadess.net>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hidp/core.c |   70 +++++++++++++++++++++++----------------------
 1 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 18e7f5a..6cf526d 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -243,6 +243,39 @@ static void hidp_input_report(struct hidp_session *session, struct sk_buff *skb)
 	input_sync(dev);
 }
 
+static int __hidp_send_ctrl_message(struct hidp_session *session,
+			unsigned char hdr, unsigned char *data, int size)
+{
+	struct sk_buff *skb;
+
+	BT_DBG("session %p data %p size %d", session, data, size);
+
+	if (!(skb = alloc_skb(size + 1, GFP_ATOMIC))) {
+		BT_ERR("Can't allocate memory for new frame");
+		return -ENOMEM;
+	}
+
+	*skb_put(skb, 1) = hdr;
+	if (data && size > 0)
+		memcpy(skb_put(skb, size), data, size);
+
+	skb_queue_tail(&session->ctrl_transmit, skb);
+
+	return 0;
+}
+
+static inline int hidp_send_ctrl_message(struct hidp_session *session,
+			unsigned char hdr, unsigned char *data, int size)
+{
+	int err;
+
+	err = __hidp_send_ctrl_message(session, hdr, data, size);
+
+	hidp_schedule(session);
+
+	return err;
+}
+
 static int hidp_queue_report(struct hidp_session *session,
 				unsigned char *data, int size)
 {
@@ -282,7 +315,9 @@ static int hidp_send_report(struct hidp_session *session, struct hid_report *rep
 
 static int hidp_output_raw_report(struct hid_device *hid, unsigned char *data, size_t count)
 {
-	if (hidp_queue_report(hid->driver_data, data, count))
+	if (hidp_send_ctrl_message(hid->driver_data,
+			HIDP_TRANS_SET_REPORT | HIDP_DATA_RTYPE_FEATURE,
+			data, count))
 		return -ENOMEM;
 	return count;
 }
@@ -307,39 +342,6 @@ static inline void hidp_del_timer(struct hidp_session *session)
 		del_timer(&session->timer);
 }
 
-static int __hidp_send_ctrl_message(struct hidp_session *session,
-			unsigned char hdr, unsigned char *data, int size)
-{
-	struct sk_buff *skb;
-
-	BT_DBG("session %p data %p size %d", session, data, size);
-
-	if (!(skb = alloc_skb(size + 1, GFP_ATOMIC))) {
-		BT_ERR("Can't allocate memory for new frame");
-		return -ENOMEM;
-	}
-
-	*skb_put(skb, 1) = hdr;
-	if (data && size > 0)
-		memcpy(skb_put(skb, size), data, size);
-
-	skb_queue_tail(&session->ctrl_transmit, skb);
-
-	return 0;
-}
-
-static inline int hidp_send_ctrl_message(struct hidp_session *session,
-			unsigned char hdr, unsigned char *data, int size)
-{
-	int err;
-
-	err = __hidp_send_ctrl_message(session, hdr, data, size);
-
-	hidp_schedule(session);
-
-	return err;
-}
-
 static void hidp_process_handshake(struct hidp_session *session,
 					unsigned char param)
 {
-- 
1.6.6

