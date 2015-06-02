From: Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Subject: [PATCH 1/2] Bluetooth: Add reset_resume function
Date: Mon,  1 Jun 2015 18:14:41 -0700
Message-ID: <1433207682-15064-1-git-send-email-labbott@fedoraproject.org>
References: <DF182762-5B64-4B76-8D3E-AF3728102881@holtmann.org>
Cc: Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <DF182762-5B64-4B76-8D3E-AF3728102881-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bluetooth devices off of some buses such as USB may lose power across
suspend/resume. When this happens, drivers may need to have the setup
function called again and behave differently than a cold power on.
Add a reset_resume function for drivers to call. During the
reset_resume case, the flag HCI_RESET_RESUME will be set to allow
drivers to differentate.

Signed-off-by: Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
---
This matches with what hci_reset_dev does and also ensures
the setup function gets called again.
---
 include/net/bluetooth/hci.h      |  1 +
 include/net/bluetooth/hci_core.h |  1 +
 net/bluetooth/hci_core.c         | 16 ++++++++++++++++
 3 files changed, 18 insertions(+)

diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index d95da83..6285410 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -185,6 +185,7 @@ enum {
 	HCI_RAW,
 
 	HCI_RESET,
+	HCI_RESET_RESUME,
 };
 
 /* HCI socket flags */
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index a056c2b..14f9c72 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -941,6 +941,7 @@ int hci_register_dev(struct hci_dev *hdev);
 void hci_unregister_dev(struct hci_dev *hdev);
 int hci_suspend_dev(struct hci_dev *hdev);
 int hci_resume_dev(struct hci_dev *hdev);
+int hci_reset_resume_dev(struct hci_dev *hdev);
 int hci_reset_dev(struct hci_dev *hdev);
 int hci_dev_open(__u16 dev);
 int hci_dev_close(__u16 dev);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index c4802f3..090762b 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1558,6 +1558,7 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	BT_DBG("%s %p", hdev->name, hdev);
 
 	if (!hci_dev_test_flag(hdev, HCI_UNREGISTER) &&
+	    !test_bit(HCI_RESET_RESUME, &hdev->flags) &&
 	    test_bit(HCI_UP, &hdev->flags)) {
 		/* Execute vendor specific shutdown routine */
 		if (hdev->shutdown)
@@ -2110,6 +2111,7 @@ static void hci_power_on(struct work_struct *work)
 		 */
 		mgmt_index_added(hdev);
 	}
+	hci_dev_test_and_clear_flag(hdev, HCI_RESET_RESUME);
 }
 
 static void hci_power_off(struct work_struct *work)
@@ -3298,6 +3300,20 @@ int hci_reset_dev(struct hci_dev *hdev)
 }
 EXPORT_SYMBOL(hci_reset_dev);
 
+/*
+ * For USB reset_resume callbacks
+ */
+int hci_reset_resume_dev(struct hci_dev *hdev)
+{
+	set_bit(HCI_RESET_RESUME, &hdev->flags);
+	hci_dev_do_close(hdev);
+	hci_dev_set_flag(hdev, HCI_SETUP);
+
+	queue_work(hdev->req_workqueue, &hdev->power_on);
+	return 0;
+}
+EXPORT_SYMBOL(hci_reset_resume_dev);
+
 /* Receive frame from HCI drivers */
 int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb)
 {
-- 
2.4.1
