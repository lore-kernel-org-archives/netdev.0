From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bluetooth: btusb: Fix issue with suspend
Date: Fri,  5 Sep 2014 10:16:34 -0500
Message-ID: <1409930194-6318-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>

Suspend could fail for some platforms because
btusb_suspend==> btusb_stop_traffic ==> usb_kill_anchored_urbs,

When btusb_bulk_complete returns before system suspend and resubmits an urb,
the system cannot enter suspend state.

Signed-off-by: Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
Johan,

To help Champion with the process, I have formatted the patch in
the correct manner. I hope I understand the issue correctly and
stated it in a coherent manner in the commit message.

Larry
---
 drivers/bluetooth/btusb.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 292c38e..45a7211 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -330,6 +330,9 @@ static void btusb_intr_complete(struct urb *urb)
 			BT_ERR("%s corrupted event packet", hdev->name);
 			hdev->stat.err_rx++;
 		}
+	} else if (urb->status == -ENOENT) {
+		/* Avoid suspend failed when usb_kill_urb */
+		return;
 	}
 
 	if (!test_bit(BTUSB_INTR_RUNNING, &data->flags))
@@ -417,6 +420,9 @@ static void btusb_bulk_complete(struct urb *urb)
 						urb->actual_length) < 0) {
 			BT_ERR("%s corrupted ACL packet", hdev->name);
 			hdev->stat.err_rx++;
+		} else if (urb->status == -ENOENT) {
+			/* Avoid suspend failed when usb_kill_urb */
+			return;
 		}
 	}
 
@@ -512,6 +518,9 @@ static void btusb_isoc_complete(struct urb *urb)
 				hdev->stat.err_rx++;
 			}
 		}
+	} else if (urb->status == -ENOENT) {
+		/* Avoid suspend failed when usb_kill_urb */
+		return;
 	}
 
 	if (!test_bit(BTUSB_ISOC_RUNNING, &data->flags))
-- 
1.8.4.5
