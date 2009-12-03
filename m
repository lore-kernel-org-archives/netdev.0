From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 08/18] Bluetooth: Unobfuscate tasklet_schedule usage
Date: Thu,  3 Dec 2009 19:45:45 +0100
Message-ID: <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37648 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbZLCSp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:58 -0500
In-Reply-To: <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tasklet schedule function helpers are just an obfuscation. So remove
them and call the schedule functions directly.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci_core.h |   16 ----------------
 net/bluetooth/hci_core.c         |   18 ++++++++++++------
 net/bluetooth/hci_event.c        |    6 +++---
 net/bluetooth/hci_sock.c         |    6 +++---
 4 files changed, 18 insertions(+), 28 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 8460f22..7b86094 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -367,22 +367,6 @@ static inline void hci_conn_put(struct hci_conn *conn)
 	}
 }
 
-/* ----- HCI tasks ----- */
-static inline void hci_sched_cmd(struct hci_dev *hdev)
-{
-	tasklet_schedule(&hdev->cmd_task);
-}
-
-static inline void hci_sched_rx(struct hci_dev *hdev)
-{
-	tasklet_schedule(&hdev->rx_task);
-}
-
-static inline void hci_sched_tx(struct hci_dev *hdev)
-{
-	tasklet_schedule(&hdev->tx_task);
-}
-
 /* ----- HCI Devices ----- */
 static inline void __hci_dev_put(struct hci_dev *d)
 {
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 3fc90e5..94ba349 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -193,8 +193,9 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 	while ((skb = skb_dequeue(&hdev->driver_init))) {
 		bt_cb(skb)->pkt_type = HCI_COMMAND_PKT;
 		skb->dev = (void *) hdev;
+
 		skb_queue_tail(&hdev->cmd_q, skb);
-		hci_sched_cmd(hdev);
+		tasklet_schedule(&hdev->cmd_task);
 	}
 	skb_queue_purge(&hdev->driver_init);
 
@@ -1005,7 +1006,8 @@ int hci_recv_frame(struct sk_buff *skb)
 
 	/* Queue frame for rx task */
 	skb_queue_tail(&hdev->rx_q, skb);
-	hci_sched_rx(hdev);
+	tasklet_schedule(&hdev->rx_task);
+
 	return 0;
 }
 EXPORT_SYMBOL(hci_recv_frame);
@@ -1216,8 +1218,9 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void *param)
 
 	bt_cb(skb)->pkt_type = HCI_COMMAND_PKT;
 	skb->dev = (void *) hdev;
+
 	skb_queue_tail(&hdev->cmd_q, skb);
-	hci_sched_cmd(hdev);
+	tasklet_schedule(&hdev->cmd_task);
 
 	return 0;
 }
@@ -1294,7 +1297,8 @@ int hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 flags)
 		spin_unlock_bh(&conn->data_q.lock);
 	}
 
-	hci_sched_tx(hdev);
+	tasklet_schedule(&hdev->tx_task);
+
 	return 0;
 }
 EXPORT_SYMBOL(hci_send_acl);
@@ -1321,8 +1325,10 @@ int hci_send_sco(struct hci_conn *conn, struct sk_buff *skb)
 
 	skb->dev = (void *) hdev;
 	bt_cb(skb)->pkt_type = HCI_SCODATA_PKT;
+
 	skb_queue_tail(&conn->data_q, skb);
-	hci_sched_tx(hdev);
+	tasklet_schedule(&hdev->tx_task);
+
 	return 0;
 }
 EXPORT_SYMBOL(hci_send_sco);
@@ -1635,7 +1641,7 @@ static void hci_cmd_task(unsigned long arg)
 			hdev->cmd_last_tx = jiffies;
 		} else {
 			skb_queue_head(&hdev->cmd_q, skb);
-			hci_sched_cmd(hdev);
+			tasklet_schedule(&hdev->cmd_task);
 		}
 	}
 }
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index e99fe38..28517ba 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1320,7 +1320,7 @@ static inline void hci_cmd_complete_evt(struct hci_dev *hdev, struct sk_buff *sk
 	if (ev->ncmd) {
 		atomic_set(&hdev->cmd_cnt, 1);
 		if (!skb_queue_empty(&hdev->cmd_q))
-			hci_sched_cmd(hdev);
+			tasklet_schedule(&hdev->cmd_task);
 	}
 }
 
@@ -1386,7 +1386,7 @@ static inline void hci_cmd_status_evt(struct hci_dev *hdev, struct sk_buff *skb)
 	if (ev->ncmd) {
 		atomic_set(&hdev->cmd_cnt, 1);
 		if (!skb_queue_empty(&hdev->cmd_q))
-			hci_sched_cmd(hdev);
+			tasklet_schedule(&hdev->cmd_task);
 	}
 }
 
@@ -1454,7 +1454,7 @@ static inline void hci_num_comp_pkts_evt(struct hci_dev *hdev, struct sk_buff *s
 		}
 	}
 
-	hci_sched_tx(hdev);
+	tasklet_schedule(&hdev->tx_task);
 
 	tasklet_enable(&hdev->tx_task);
 }
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index c3701f3..688cfeb 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -445,10 +445,10 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (test_bit(HCI_RAW, &hdev->flags) || (ogf == 0x3f)) {
 			skb_queue_tail(&hdev->raw_q, skb);
-			hci_sched_tx(hdev);
+			tasklet_schedule(&hdev->tx_task);
 		} else {
 			skb_queue_tail(&hdev->cmd_q, skb);
-			hci_sched_cmd(hdev);
+			tasklet_schedule(&hdev->cmd_task);
 		}
 	} else {
 		if (!capable(CAP_NET_RAW)) {
@@ -457,7 +457,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		skb_queue_tail(&hdev->raw_q, skb);
-		hci_sched_tx(hdev);
+		tasklet_schedule(&hdev->tx_task);
 	}
 
 	err = len;
-- 
1.6.5.2

