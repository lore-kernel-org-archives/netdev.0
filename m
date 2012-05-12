From: Gustavo Padovan <gustavo@padovan.org>
Subject: [PATCH 2/2] Bluetooth: mgmt: Fix device_connected sending order
Date: Sat, 12 May 2012 16:11:50 -0300
Message-ID: <1336849910-29064-2-git-send-email-gustavo@padovan.org>
References: <20120512190900.GA15956@joana>
 <1336849910-29064-1-git-send-email-gustavo@padovan.org>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Johan Hedberg <johan.hedberg@intel.com>
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336849910-29064-1-git-send-email-gustavo@padovan.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg@intel.com>

The mgmt_ev_device_connected signal must be sent before any event
indications happen for sockets associated with the connection. Otherwise
e.g. device authorization for the sockets will fail with ENOTCONN as
user space things that there is no baseband link.

This patch fixes the issue by ensuring that the device_connected event
if sent (if it hasn't been so already) as soon as the first ACL data
packet arrives from the remote device.

Signed-off-by: Johan Hedberg <johan.hedberg@intel.com>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_core.c  |    8 ++++++++
 net/bluetooth/hci_event.c |    4 ++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index a7607e4..b5bab83 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2785,6 +2785,14 @@ static inline void hci_acldata_packet(struct hci_dev *hdev, struct sk_buff *skb)
 	if (conn) {
 		hci_conn_enter_active_mode(conn, BT_POWER_FORCE_ACTIVE_OFF);
 
+		hci_dev_lock(hdev);
+		if (test_bit(HCI_MGMT, &hdev->dev_flags) &&
+		    !test_and_set_bit(HCI_CONN_MGMT_CONNECTED, &conn->flags))
+			mgmt_device_connected(hdev, &conn->dst, conn->type,
+					      conn->dst_type, 0, NULL, 0,
+					      conn->dev_class);
+		hci_dev_unlock(hdev);
+
 		/* Send to upper protocol */
 		l2cap_recv_acldata(conn, skb, flags);
 		return;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index ff38cc6..7d66b8b 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -2110,7 +2110,7 @@ static inline void hci_remote_features_evt(struct hci_dev *hdev, struct sk_buff
 		goto unlock;
 	}
 
-	if (!ev->status) {
+	if (!ev->status && !test_bit(HCI_CONN_MGMT_CONNECTED, &conn->flags)) {
 		struct hci_cp_remote_name_req cp;
 		memset(&cp, 0, sizeof(cp));
 		bacpy(&cp.bdaddr, &conn->dst);
@@ -2879,7 +2879,7 @@ static inline void hci_remote_ext_features_evt(struct hci_dev *hdev, struct sk_b
 	if (conn->state != BT_CONFIG)
 		goto unlock;
 
-	if (!ev->status) {
+	if (!ev->status && !test_bit(HCI_CONN_MGMT_CONNECTED, &conn->flags)) {
 		struct hci_cp_remote_name_req cp;
 		memset(&cp, 0, sizeof(cp));
 		bacpy(&cp.bdaddr, &conn->dst);
-- 
1.7.10.1
