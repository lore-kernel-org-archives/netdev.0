From: Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] Bluetooth: hci_core: Avoid mixing up req_complete and req_complete_skb
Date: Fri, 19 Feb 2016 14:25:21 -0800
Message-ID: <1455920722-20892-1-git-send-email-dianders@chromium.org>
Cc: Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org,
	johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johan Hedberg <johan.hedberg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In commit 44d271377479 ("Bluetooth: Compress the size of struct
hci_ctrl") we squashed down the size of the structure by using a union
with the assumption that all users would use the flag to determine
whether we had a req_complete or a req_complete_skb.

Unfortunately we had a case in hci_req_cmd_complete() where we weren't
looking at the flag.  This can result in a situation where we might be
storing a hci_req_complete_skb_t in a hci_req_complete_t variable, or
vice versa.

During some testing I found at least one case where the function
hci_req_sync_complete() was called improperly because the kernel thought
that it didn't require an SKB.  Looking through the stack in kgdb I
found that it was called by hci_event_packet() and that
hci_event_packet() had both of its locals "req_complete" and
"req_complete_skb" pointing to the same place: both to
hci_req_sync_complete().

Let's make sure we always check the flag.

For more details on debugging done, see <http://crbug.com/588288>.

Fixes: 44d271377479 ("Bluetooth: Compress the size of struct hci_ctrl")
Signed-off-by: Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
Testing was done on a Chrome OS device on kernel 3.14 w/
bluetooth-next backports.  Since I couldn't reliably reproduce the
problem, I simply confirmed that existing functionality worked.

 net/bluetooth/hci_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 541760fe53d4..9c0a6830ff92 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -4118,8 +4118,10 @@ void hci_req_cmd_complete(struct hci_dev *hdev, u16 opcode, u8 status,
 			break;
 		}
 
-		*req_complete = bt_cb(skb)->hci.req_complete;
-		*req_complete_skb = bt_cb(skb)->hci.req_complete_skb;
+		if (bt_cb(skb)->hci.req_flags & HCI_REQ_SKB)
+			*req_complete_skb = bt_cb(skb)->hci.req_complete_skb;
+		else
+			*req_complete = bt_cb(skb)->hci.req_complete;
 		kfree_skb(skb);
 	}
 	spin_unlock_irqrestore(&hdev->cmd_q.lock, flags);
-- 
2.7.0.rc3.207.g0ac5344
