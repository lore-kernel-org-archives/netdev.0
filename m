From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 08/11] hso: move tty_unregister outside hso_serial_common_free()
Date: Tue, 20 Jan 2015 13:29:35 +0100
Message-ID: <1421756978-4093-9-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
 <1421756978-4093-4-git-send-email-olivier@sobrie.be>
 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
 <1421756978-4093-6-git-send-email-olivier@sobrie.be>
 <1421756978-4093-7-git-send-email-olivier@sobrie.be>
 <1421756978-4093-8-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421756978-4093-8-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function hso_serial_common_free() is called either by the cleanup
method of the tty or by the usb disconnect method.
In the former case, the usb_disconnect() has been already called
and the sysfs group associated to the device has been removed.
By calling tty_unregister directly from the usb_disconnect() method,
we avoid a warning due to the removal of the sysfs group of the usb
device.

Example of warning:
------------[ cut here ]------------
WARNING: CPU: 0 PID: 778 at fs/sysfs/group.c:225 sysfs_remove_group+0x50/0x94()
sysfs group c0645a88 not found for kobject 'ttyHS5'
Modules linked in:
CPU: 0 PID: 778 Comm: kworker/0:3 Tainted: G        W      3.18.0+ #105
Workqueue: events release_one_tty
[<c000dfe4>] (unwind_backtrace) from [<c000c014>] (show_stack+0x14/0x1c)
[<c000c014>] (show_stack) from [<c0016bac>] (warn_slowpath_common+0x5c/0x7c)
[<c0016bac>] (warn_slowpath_common) from [<c0016c60>] (warn_slowpath_fmt+0x30/0x40)
[<c0016c60>] (warn_slowpath_fmt) from [<c00ddd14>] (sysfs_remove_group+0x50/0x94)
[<c00ddd14>] (sysfs_remove_group) from [<c0221e44>] (device_del+0x30/0x190)
[<c0221e44>] (device_del) from [<c0221fb0>] (device_unregister+0xc/0x18)
[<c0221fb0>] (device_unregister) from [<c0221fec>] (device_destroy+0x30/0x3c)
[<c0221fec>] (device_destroy) from [<c01fe1dc>] (tty_unregister_device+0x2c/0x5c)
[<c01fe1dc>] (tty_unregister_device) from [<c029a428>] (hso_serial_common_free+0x2c/0x88)
[<c029a428>] (hso_serial_common_free) from [<c029a4c0>] (hso_serial_ref_free+0x3c/0xb8)
[<c029a4c0>] (hso_serial_ref_free) from [<c01ff430>] (release_one_tty+0x30/0x84)
[<c01ff430>] (release_one_tty) from [<c00271d4>] (process_one_work+0x21c/0x3c8)
[<c00271d4>] (process_one_work) from [<c0027758>] (worker_thread+0x3d8/0x560)
[<c0027758>] (worker_thread) from [<c002be4c>] (kthread+0xc0/0xcc)
[<c002be4c>] (kthread) from [<c0009630>] (ret_from_fork+0x14/0x24)
---[ end trace cb88537fdc8fa208 ]---

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 55074da..5b157ad 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2234,14 +2234,17 @@ static int hso_stop_serial_device(struct hso_device *hso_dev)
 	return 0;
 }
 
-static void hso_serial_common_free(struct hso_serial *serial)
+static void hso_serial_tty_unregister(struct hso_serial *serial)
 {
-	int i;
-
 	if (serial->parent->dev)
 		device_remove_file(serial->parent->dev, &dev_attr_hsotype);
 
 	tty_unregister_device(tty_drv, serial->minor);
+}
+
+static void hso_serial_common_free(struct hso_serial *serial)
+{
+	int i;
 
 	for (i = 0; i < serial->num_rx_urbs; i++) {
 		/* unlink and free RX URB */
@@ -2323,6 +2326,7 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 
 	return 0;
 exit:
+	hso_serial_tty_unregister(serial);
 	hso_serial_common_free(serial);
 	return -1;
 }
@@ -2683,6 +2687,7 @@ static struct hso_device *hso_create_bulk_serial_device(
 	return hso_dev;
 
 exit2:
+	hso_serial_tty_unregister(serial);
 	hso_serial_common_free(serial);
 exit:
 	hso_free_tiomget(serial);
@@ -3103,6 +3108,7 @@ static void hso_free_interface(struct usb_interface *interface)
 			mutex_lock(&serial->parent->mutex);
 			serial->parent->usb_gone = 1;
 			mutex_unlock(&serial->parent->mutex);
+			hso_serial_tty_unregister(serial);
 			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
 		}
 	}
-- 
2.2.0
