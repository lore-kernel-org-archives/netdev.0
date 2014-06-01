From: Kiran Kumar Raparthy <kiran.kumar@linaro.org>
Subject: [RFC v3] Bluetooth: Keep master role when SCO or eSCO is active
Date: Sun,  1 Jun 2014 10:50:34 +0530
Message-ID: <1401600034-16687-1-git-send-email-kiran.kumar@linaro.org>
Cc: "hyungseoung.yoo" <hyungseoung.yoo@samsung.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Android Kernel Team <kernel-team@android.com>,
	John Stultz <john.stultz@linaro.org>,
	Jaikumar Ganesh <jaikumarg@android.com>,
	Kiran Raparthy <kiran.kumar@linaro.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "hyungseoung.yoo" <hyungseoung.yoo@samsung.com>

Preserve the master role when SCO or eSCO is active
as this improves compatability with lots of
headset and chipset combinations.

This is one of the number of patches from the Android AOSP
common.git tree, which is used on almost all Android devices.
It looks like it would improve support for compatibility with
lot of headset,so I wanted to submit it for review to see
if it should go upstream.

v3: Fixed formatting issues pointed by Sergei

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-bluetooth@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Android Kernel Team <kernel-team@android.com>
Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: hyungseoung.yoo <hyungseoung.yoo@samsung.com>
Signed-off-by: Jaikumar Ganesh <jaikumarg@android.com>
[kiran: Added context to commit message]
Signed-off-by: Kiran Raparthy <kiran.kumar@linaro.org>
---
 net/bluetooth/hci_event.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 15010a2..cfb1355 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1915,6 +1915,14 @@ unlock:
 	hci_conn_check_pending(hdev);
 }
 
+static inline bool is_sco_active(struct hci_dev *hdev)
+{
+	if (hci_conn_hash_lookup_state(hdev, SCO_LINK, BT_CONNECTED) ||
+	    hci_conn_hash_lookup_state(hdev, ESCO_LINK, BT_CONNECTED))
+		return true;
+	return false;
+}
+
 static void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct hci_ev_conn_request *ev = (void *) skb->data;
@@ -1961,7 +1969,9 @@ static void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *skb)
 
 			bacpy(&cp.bdaddr, &ev->bdaddr);
 
-			if (lmp_rswitch_capable(hdev) && (mask & HCI_LM_MASTER))
+			if (lmp_rswitch_capable(hdev) &&
+			    ((mask & HCI_LM_MASTER) ||
+			    is_sco_active(hdev)))
 				cp.role = 0x00; /* Become master */
 			else
 				cp.role = 0x01; /* Remain slave */
-- 
1.8.2.1
