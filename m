From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 07/18] Bluetooth: Turn hci_recv_frame into an exported function
Date: Thu,  3 Dec 2009 19:45:44 +0100
Message-ID: <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756522AbZLCSp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:57 -0500
In-Reply-To: <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For future simplification it is important that the hci_recv_frame
function is no longer an inline function. So move it into the module
itself and export it.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci_core.h |   23 +----------------------
 net/bluetooth/hci_core.c         |   23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 7b640ae..8460f22 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -437,28 +437,7 @@ int hci_inquiry(void __user *arg);
 
 void hci_event_packet(struct hci_dev *hdev, struct sk_buff *skb);
 
-/* Receive frame from HCI drivers */
-static inline int hci_recv_frame(struct sk_buff *skb)
-{
-	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
-	if (!hdev || (!test_bit(HCI_UP, &hdev->flags) 
-			&& !test_bit(HCI_INIT, &hdev->flags))) {
-		kfree_skb(skb);
-		return -ENXIO;
-	}
-
-	/* Incomming skb */
-	bt_cb(skb)->incoming = 1;
-
-	/* Time stamp */
-	__net_timestamp(skb);
-
-	/* Queue frame for rx task */
-	skb_queue_tail(&hdev->rx_q, skb);
-	hci_sched_rx(hdev);
-	return 0;
-}
-
+int hci_recv_frame(struct sk_buff *skb);
 int hci_recv_fragment(struct hci_dev *hdev, int type, void *data, int count);
 
 int hci_register_sysfs(struct hci_dev *hdev);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index e1da8f6..3fc90e5 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -987,6 +987,29 @@ int hci_resume_dev(struct hci_dev *hdev)
 }
 EXPORT_SYMBOL(hci_resume_dev);
 
+/* Receive frame from HCI drivers */
+int hci_recv_frame(struct sk_buff *skb)
+{
+	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
+	if (!hdev || (!test_bit(HCI_UP, &hdev->flags)
+				&& !test_bit(HCI_INIT, &hdev->flags))) {
+		kfree_skb(skb);
+		return -ENXIO;
+	}
+
+	/* Incomming skb */
+	bt_cb(skb)->incoming = 1;
+
+	/* Time stamp */
+	__net_timestamp(skb);
+
+	/* Queue frame for rx task */
+	skb_queue_tail(&hdev->rx_q, skb);
+	hci_sched_rx(hdev);
+	return 0;
+}
+EXPORT_SYMBOL(hci_recv_frame);
+
 /* Receive packet type fragment */
 #define __reassembly(hdev, type)  ((hdev)->reassembly[(type) - 2])
 
-- 
1.6.5.2

