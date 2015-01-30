From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 09/11] hso: update serial_table in usb disconnect method
Date: Fri, 30 Jan 2015 13:22:01 +0100
Message-ID: <1422620523-15021-10-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-2-git-send-email-olivier@sobrie.be>
 <1422620523-15021-3-git-send-email-olivier@sobrie.be>
 <1422620523-15021-4-git-send-email-olivier@sobrie.be>
 <1422620523-15021-5-git-send-email-olivier@sobrie.be>
 <1422620523-15021-6-git-send-email-olivier@sobrie.be>
 <1422620523-15021-7-git-send-email-olivier@sobrie.be>
 <1422620523-15021-8-git-send-email-olivier@sobrie.be>
 <1422620523-15021-9-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422620523-15021-9-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The serial_table is used to map the minor number of the usb serial device
to its associated context. The table is updated in the probe method and
in hso_serial_ref_free() which is called either from the tty cleanup
method or from the usb disconnect method.
This patch ensures that the serial_table is updated in the disconnect
method and no more from the cleanup method to avoid the following
potential race condition.

 - hso_disconnect() is called for usb interface "x". Because the serial
   port was open and because the cleanup method of the tty_port hasn't
   been called yet, hso_serial_ref_free() is not run.
 - hso_probe() is called and fails for a new hso serial usb interface
   "y". The function hso_free_interface() is called and iterates
   over the element of serial_table to find the device associated to
   the usb interface context.
   If the usb interface context of usb interface "y" has been created
   at the same place as for usb interface "x", then the cleanup
   functions are called for usb interfaces "x" and "y" and
   hso_serial_ref_free() is called for both interfaces.
 - release_tty() is called for serial port linked to usb interface "x"
   and possibly crash because the tty_port structure contained in the
   hso_device structure has been freed.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 5b157ad..c916ab5 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2597,7 +2597,6 @@ static void hso_free_serial_device(struct hso_device *hso_dev)
 
 	if (!serial)
 		return;
-	set_serial_by_index(serial->minor, NULL);
 
 	hso_serial_common_free(serial);
 
@@ -3110,6 +3109,7 @@ static void hso_free_interface(struct usb_interface *interface)
 			mutex_unlock(&serial->parent->mutex);
 			hso_serial_tty_unregister(serial);
 			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
+			set_serial_by_index(i, NULL);
 		}
 	}
 
-- 
2.2.0
