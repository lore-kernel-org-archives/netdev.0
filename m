From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH 1/3] bluetooth: hci_ldisc: fix memory leak on tty_close
Date: Fri,  9 Mar 2012 16:43:24 +0100
Message-ID: <1331307806-21761-2-git-send-email-jhovold@gmail.com>
References: <1331307806-21761-1-git-send-email-jhovold@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	David Herrmann <dh.herrmann@googlemail.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Johan Hovold <jhovold@gmail.com>,
	stable <stable@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331307806-21761-1-git-send-email-jhovold@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hci_uart is never freed when tty is closed if the protocol has not
been set.

This was discovered by David Hermann and fixed in bluetooth-next. Those
patches are more intrusive as they remove the mandatory destructor
completely.

This is the minimal fix, which leaves the destructor as an empty dummy
call for now.

Cc: David Herrmann <dh.herrmann@googlemail.com>
Cc: stable <stable@vger.kernel.org>
Signed-off-by: Johan Hovold <jhovold@gmail.com>
---
 drivers/bluetooth/hci_ldisc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index 0711448..97c5faa 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -237,7 +237,6 @@ static void hci_uart_destruct(struct hci_dev *hdev)
 		return;
 
 	BT_DBG("%s", hdev->name);
-	kfree(hdev->driver_data);
 }
 
 /* ------ LDISC part ------ */
@@ -316,6 +315,7 @@ static void hci_uart_tty_close(struct tty_struct *tty)
 				hci_free_dev(hdev);
 			}
 		}
+		kfree(hu);
 	}
 }
 
-- 
1.7.8.4
