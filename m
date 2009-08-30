From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 24/47] Bluetooth: Convert hdev->req_lock to a mutex
Date: Sun, 30 Aug 2009 01:50:38 -0700
Message-ID: <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53306 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbZH3IwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:19 -0400
In-Reply-To: <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

hdev->req_lock is used as mutex so make it a mutex.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci_core.h |    6 +++---
 net/bluetooth/hci_core.c         |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 25b8a03..7b640ae 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -117,7 +117,7 @@ struct hci_dev {
 	struct sk_buff		*sent_cmd;
 	struct sk_buff		*reassembly[3];
 
-	struct semaphore	req_lock;
+	struct mutex		req_lock;
 	wait_queue_head_t	req_wait_q;
 	__u32			req_status;
 	__u32			req_result;
@@ -704,8 +704,8 @@ struct hci_sec_filter {
 #define HCI_REQ_PEND	  1
 #define HCI_REQ_CANCELED  2
 
-#define hci_req_lock(d)		down(&d->req_lock)
-#define hci_req_unlock(d)	up(&d->req_lock)
+#define hci_req_lock(d)		mutex_lock(&d->req_lock)
+#define hci_req_unlock(d)	mutex_unlock(&d->req_lock)
 
 void hci_req_complete(struct hci_dev *hdev, int result);
 
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 406ad07..e1da8f6 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -911,7 +911,7 @@ int hci_register_dev(struct hci_dev *hdev)
 		hdev->reassembly[i] = NULL;
 
 	init_waitqueue_head(&hdev->req_wait_q);
-	init_MUTEX(&hdev->req_lock);
+	mutex_init(&hdev->req_lock);
 
 	inquiry_cache_init(hdev);
 
-- 
1.6.2.5

