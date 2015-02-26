From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v2 2/7] net: bluetooth: compact struct bt_skb_cb by converting boolean fields to bit fields
Date: Thu, 26 Feb 2015 21:06:59 +0200
Message-ID: <1424977624-649-3-git-send-email-eyal.birger@gmail.com>
References: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:38753 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497AbbBZTH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:07:27 -0500
In-Reply-To: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert boolean fields incoming and req_start to bit fields and move
force_active in order save space in bt_skb_cb in an effort to use
a portion of skb->cb[] for storing skb->dropcount.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 include/net/bluetooth/bluetooth.h | 6 +++---
 net/bluetooth/hci_core.c          | 2 +-
 net/bluetooth/hci_request.c       | 2 +-
 net/bluetooth/hci_sock.c          | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 0989366..4500bf8 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -277,11 +277,11 @@ typedef void (*hci_req_complete_t)(struct hci_dev *hdev, u8 status, u16 opcode);
 
 struct bt_skb_cb {
 	__u8 pkt_type;
-	__u8 incoming;
+	__u8 force_active;
 	__u16 opcode;
 	__u16 expect;
-	__u8 force_active;
-	bool req_start;
+	__u8 incoming:1;
+	__u8 req_start:1;
 	u8 req_event;
 	hci_req_complete_t req_complete;
 	struct l2cap_chan *chan;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 85a0655..80f40e8 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -3517,7 +3517,7 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen,
 	/* Stand-alone HCI commands must be flagged as
 	 * single-command requests.
 	 */
-	bt_cb(skb)->req_start = true;
+	bt_cb(skb)->req_start = 1;
 
 	skb_queue_tail(&hdev->cmd_q, skb);
 	queue_work(hdev->workqueue, &hdev->cmd_work);
diff --git a/net/bluetooth/hci_request.c b/net/bluetooth/hci_request.c
index db2f45a..f857e76 100644
--- a/net/bluetooth/hci_request.c
+++ b/net/bluetooth/hci_request.c
@@ -116,7 +116,7 @@ void hci_req_add_ev(struct hci_request *req, u16 opcode, u32 plen,
 	}
 
 	if (skb_queue_empty(&req->cmd_q))
-		bt_cb(skb)->req_start = true;
+		bt_cb(skb)->req_start = 1;
 
 	bt_cb(skb)->req_event = event;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index f003818..37198fb 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -965,7 +965,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 			/* Stand-alone HCI commands must be flagged as
 			 * single-command requests.
 			 */
-			bt_cb(skb)->req_start = true;
+			bt_cb(skb)->req_start = 1;
 
 			skb_queue_tail(&hdev->cmd_q, skb);
 			queue_work(hdev->workqueue, &hdev->cmd_work);
-- 
2.1.4
