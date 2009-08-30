From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 05/47] Bluetooth: Add extra device reference counting for connections
Date: Sun, 30 Aug 2009 01:50:19 -0700
Message-ID: <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53266 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbZH3Ivz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:55 -0400
In-Reply-To: <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device model itself has no real usable reference counting at the
moment and this causes problems if parents are deleted before their
children. The device model itself handles the memory details of this
correctly, but the uevent order is not consistent. This causes various
problems for systems like HAL or even X.

So until device_put() does a proper cleanup, the device for Bluetooth
connection will be protected with an extra reference counting to ensure
the correct order of uevents when connections are terminated.

This is not an automatic feature. Higher Bluetooth layers like HIDP or
BNEP should grab this new reference to ensure that their uevents are
send before the ones from the parent device.

Based on a report by Brian Rogers <brian@xyzw.org>

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci_core.h |    4 ++++
 net/bluetooth/hci_conn.c         |   17 ++++++++++++++++-
 net/bluetooth/hci_event.c        |    2 ++
 3 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index c4ca422..25b8a03 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -187,6 +187,7 @@ struct hci_conn {
 	struct work_struct work_del;
 
 	struct device	dev;
+	atomic_t	devref;
 
 	struct hci_dev	*hdev;
 	void		*l2cap_data;
@@ -339,6 +340,9 @@ int hci_conn_switch_role(struct hci_conn *conn, __u8 role);
 void hci_conn_enter_active_mode(struct hci_conn *conn);
 void hci_conn_enter_sniff_mode(struct hci_conn *conn);
 
+void hci_conn_hold_device(struct hci_conn *conn);
+void hci_conn_put_device(struct hci_conn *conn);
+
 static inline void hci_conn_hold(struct hci_conn *conn)
 {
 	atomic_inc(&conn->refcnt);
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index fa47d5d..a975098 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -246,6 +246,8 @@ struct hci_conn *hci_conn_add(struct hci_dev *hdev, int type, bdaddr_t *dst)
 	if (hdev->notify)
 		hdev->notify(hdev, HCI_NOTIFY_CONN_ADD);
 
+	atomic_set(&conn->devref, 0);
+
 	hci_conn_init_sysfs(conn);
 
 	tasklet_enable(&hdev->tx_task);
@@ -288,7 +290,7 @@ int hci_conn_del(struct hci_conn *conn)
 
 	skb_queue_purge(&conn->data_q);
 
-	hci_conn_del_sysfs(conn);
+	hci_conn_put_device(conn);
 
 	hci_dev_put(hdev);
 
@@ -583,6 +585,19 @@ void hci_conn_check_pending(struct hci_dev *hdev)
 	hci_dev_unlock(hdev);
 }
 
+void hci_conn_hold_device(struct hci_conn *conn)
+{
+	atomic_inc(&conn->devref);
+}
+EXPORT_SYMBOL(hci_conn_hold_device);
+
+void hci_conn_put_device(struct hci_conn *conn)
+{
+	if (atomic_dec_and_test(&conn->devref))
+		hci_conn_del_sysfs(conn);
+}
+EXPORT_SYMBOL(hci_conn_put_device);
+
 int hci_get_conn_list(void __user *arg)
 {
 	struct hci_conn_list_req req, *cl;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 184ba0a..e99fe38 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -887,6 +887,7 @@ static inline void hci_conn_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 		} else
 			conn->state = BT_CONNECTED;
 
+		hci_conn_hold_device(conn);
 		hci_conn_add_sysfs(conn);
 
 		if (test_bit(HCI_AUTH, &hdev->flags))
@@ -1693,6 +1694,7 @@ static inline void hci_sync_conn_complete_evt(struct hci_dev *hdev, struct sk_bu
 		conn->handle = __le16_to_cpu(ev->handle);
 		conn->state  = BT_CONNECTED;
 
+		hci_conn_hold_device(conn);
 		hci_conn_add_sysfs(conn);
 		break;
 
-- 
1.6.2.5

