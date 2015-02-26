From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next 1/7] net: bluetooth: compact struct bt_skb_cb by inlining struct hci_req_ctrl
Date: Thu, 26 Feb 2015 04:10:06 +0200
Message-ID: <1424916612-744-2-git-send-email-eyal.birger@gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	marcel@holtmann.org, netdev@vger.kernel.org,
	Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:49610 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbbBZCK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 21:10:28 -0500
Received: by mail-wi0-f173.google.com with SMTP id bs8so37696490wib.0
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 18:10:27 -0800 (PST)
In-Reply-To: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct hci_req_ctrl is never used outside of struct bt_skb_cb;
Inlining it frees 8 bytes on a 64 bit system in skb->cb[] allowing
the addition of more ancillary data.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 include/net/bluetooth/bluetooth.h | 10 +++-------
 net/bluetooth/hci_core.c          | 12 ++++++------
 net/bluetooth/hci_event.c         |  4 ++--
 net/bluetooth/hci_request.c       |  6 +++---
 net/bluetooth/hci_sock.c          |  2 +-
 5 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index e00455a..0989366 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -275,21 +275,17 @@ struct hci_dev;
 
 typedef void (*hci_req_complete_t)(struct hci_dev *hdev, u8 status, u16 opcode);
 
-struct hci_req_ctrl {
-	bool			start;
-	u8			event;
-	hci_req_complete_t	complete;
-};
-
 struct bt_skb_cb {
 	__u8 pkt_type;
 	__u8 incoming;
 	__u16 opcode;
 	__u16 expect;
 	__u8 force_active;
+	bool req_start;
+	u8 req_event;
+	hci_req_complete_t req_complete;
 	struct l2cap_chan *chan;
 	struct l2cap_ctrl control;
-	struct hci_req_ctrl req;
 	bdaddr_t bdaddr;
 	__le16 psm;
 };
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 3322d3f..85a0655 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -3517,7 +3517,7 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen,
 	/* Stand-alone HCI commands must be flagged as
 	 * single-command requests.
 	 */
-	bt_cb(skb)->req.start = true;
+	bt_cb(skb)->req_start = true;
 
 	skb_queue_tail(&hdev->cmd_q, skb);
 	queue_work(hdev->workqueue, &hdev->cmd_work);
@@ -4195,7 +4195,7 @@ static bool hci_req_is_complete(struct hci_dev *hdev)
 	if (!skb)
 		return true;
 
-	return bt_cb(skb)->req.start;
+	return bt_cb(skb)->req_start;
 }
 
 static void hci_resend_last(struct hci_dev *hdev)
@@ -4255,14 +4255,14 @@ void hci_req_cmd_complete(struct hci_dev *hdev, u16 opcode, u8 status)
 	 * command queue (hdev->cmd_q).
 	 */
 	if (hdev->sent_cmd) {
-		req_complete = bt_cb(hdev->sent_cmd)->req.complete;
+		req_complete = bt_cb(hdev->sent_cmd)->req_complete;
 
 		if (req_complete) {
 			/* We must set the complete callback to NULL to
 			 * avoid calling the callback more than once if
 			 * this function gets called again.
 			 */
-			bt_cb(hdev->sent_cmd)->req.complete = NULL;
+			bt_cb(hdev->sent_cmd)->req_complete = NULL;
 
 			goto call_complete;
 		}
@@ -4271,12 +4271,12 @@ void hci_req_cmd_complete(struct hci_dev *hdev, u16 opcode, u8 status)
 	/* Remove all pending commands belonging to this request */
 	spin_lock_irqsave(&hdev->cmd_q.lock, flags);
 	while ((skb = __skb_dequeue(&hdev->cmd_q))) {
-		if (bt_cb(skb)->req.start) {
+		if (bt_cb(skb)->req_start) {
 			__skb_queue_head(&hdev->cmd_q, skb);
 			break;
 		}
 
-		req_complete = bt_cb(skb)->req.complete;
+		req_complete = bt_cb(skb)->req_complete;
 		kfree_skb(skb);
 	}
 	spin_unlock_irqrestore(&hdev->cmd_q.lock, flags);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index a3fb094..8e8c433 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -3106,7 +3106,7 @@ static void hci_cmd_status_evt(struct hci_dev *hdev, struct sk_buff *skb)
 		cancel_delayed_work(&hdev->cmd_timer);
 
 	if (ev->status ||
-	    (hdev->sent_cmd && !bt_cb(hdev->sent_cmd)->req.event))
+	    (hdev->sent_cmd && !bt_cb(hdev->sent_cmd)->req_event))
 		hci_req_cmd_complete(hdev, opcode, ev->status);
 
 	if (ev->ncmd && !test_bit(HCI_RESET, &hdev->flags)) {
@@ -5039,7 +5039,7 @@ void hci_event_packet(struct hci_dev *hdev, struct sk_buff *skb)
 
 	skb_pull(skb, HCI_EVENT_HDR_SIZE);
 
-	if (hdev->sent_cmd && bt_cb(hdev->sent_cmd)->req.event == event) {
+	if (hdev->sent_cmd && bt_cb(hdev->sent_cmd)->req_event == event) {
 		struct hci_command_hdr *cmd_hdr = (void *) hdev->sent_cmd->data;
 		u16 opcode = __le16_to_cpu(cmd_hdr->opcode);
 
diff --git a/net/bluetooth/hci_request.c b/net/bluetooth/hci_request.c
index b59f92c..db2f45a 100644
--- a/net/bluetooth/hci_request.c
+++ b/net/bluetooth/hci_request.c
@@ -55,7 +55,7 @@ int hci_req_run(struct hci_request *req, hci_req_complete_t complete)
 		return -ENODATA;
 
 	skb = skb_peek_tail(&req->cmd_q);
-	bt_cb(skb)->req.complete = complete;
+	bt_cb(skb)->req_complete = complete;
 
 	spin_lock_irqsave(&hdev->cmd_q.lock, flags);
 	skb_queue_splice_tail(&req->cmd_q, &hdev->cmd_q);
@@ -116,9 +116,9 @@ void hci_req_add_ev(struct hci_request *req, u16 opcode, u32 plen,
 	}
 
 	if (skb_queue_empty(&req->cmd_q))
-		bt_cb(skb)->req.start = true;
+		bt_cb(skb)->req_start = true;
 
-	bt_cb(skb)->req.event = event;
+	bt_cb(skb)->req_event = event;
 
 	skb_queue_tail(&req->cmd_q, skb);
 }
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 1d65c5b..f003818 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -965,7 +965,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 			/* Stand-alone HCI commands must be flagged as
 			 * single-command requests.
 			 */
-			bt_cb(skb)->req.start = true;
+			bt_cb(skb)->req_start = true;
 
 			skb_queue_tail(&hdev->cmd_q, skb);
 			queue_work(hdev->workqueue, &hdev->cmd_work);
-- 
2.1.4
