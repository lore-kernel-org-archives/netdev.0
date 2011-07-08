From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] hso: fix a use after free condition
Date: Fri, 8 Jul 2011 06:45:25 -0700
Message-ID: <20110708134525.GA5069@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This needs to go to netdev:

From: Octavian Purdila <octavian.purdila-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

In hso_free_net_device hso_net pointer is freed and then used to
cleanup urb pools. Catched with SLAB_DEBUG during S3 resume:

[   95.824442] Pid: 389, comm: khubd Tainted: G         C  2.6.36greenridge-01400-g423cf13-dirty #154 Type2 - Board Product Name1/OakTrail
[   95.824442] EIP: 0060:[<c1151551>] EFLAGS: 00010202 CPU: 0
[   95.824442] EIP is at kref_put+0x29/0x42
[   95.824442] EAX: 6b6b6b6b EBX: 6b6b6b6b ECX: c2806b40 EDX: 00000037
[   95.824442] ESI: c1258d56 EDI: edd3d128 EBP: ee8cde0c ESP: ee8cde04
[   95.824442]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[   95.824442] Process khubd (pid: 389, ti=ee8cc000 task=ee95ed10 task.ti=ee8cc000)
[   95.824442] Stack:
[   95.824442]  edd07020 00000000 ee8cde14 c1258b77 ee8cde38 ef933a44 ef93572b ef935dec
[   95.824442] <0> 0000099a 6b6b6b6b 00000000 ee2da748 edd3e0c0 ee8cde54 ef933b9f ee3b53f8
[   95.824442] <0> 00000002 ee2da748 ee2da764 ef936658 ee8cde60 ef933d0c ee2da748 ee8cde84
[   95.824442] Call Trace:
[   95.824442]  [<c1258b77>] ? usb_free_urb+0x11/0x13
[   95.824442]  [<ef933a44>] ? hso_free_net_device+0x81/0xd8 [hso]
[   95.824442]  [<ef933b9f>] ? hso_free_interface+0x104/0x111 [hso]
[   95.824442]  [<ef933d0c>] ? hso_disconnect+0xb/0x18 [hso]
[   95.824442]  [<c125b7f1>] ? usb_unbind_interface+0x44/0x14a
[   95.824442]  [<c11e56e8>] ? __device_release_driver+0x6f/0xb1
[   95.824442]  [<c11e57c7>] ? device_release_driver+0x18/0x23
[   95.824442]  [<c11e4e92>] ? bus_remove_device+0x8a/0xa1
[   95.824442]  [<c11e3970>] ? device_del+0x129/0x163
[   95.824442]  [<c11e2dc0>] ? put_device+0xf/0x11
[   95.824442]  [<c11e39bc>] ? device_unregister+0x12/0x15
[   95.824442]  [<c125915f>] ? usb_disable_device+0x90/0xf0
[   95.824442]  [<c125544f>] ? usb_disconnect+0x6d/0xf8
[   95.824442]  [<c1255f91>] ? hub_thread+0x3fc/0xc57
[   95.824442]  [<c1048526>] ? autoremove_wake_function+0x0/0x2f
[   95.824442]  [<c102529d>] ? complete+0x34/0x3e
[   95.824442]  [<c1255b95>] ? hub_thread+0x0/0xc57
[   95.824442]  [<c10481fc>] ? kthread+0x63/0x68
[   95.824442]  [<c1048199>] ? kthread+0x0/0x68
[   95.824442]  [<c1002d76>] ? kernel_thread_helper+0x6/0x10

Signed-off-by: Octavian Purdila <octavian.purdila-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---

 drivers/net/usb/hso.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 387ca43..304fe78 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2421,10 +2421,8 @@ static void hso_free_net_device(struct hso_device *hso_dev)
 
 	remove_net_device(hso_net->parent);
 
-	if (hso_net->net) {
+	if (hso_net->net)
 		unregister_netdev(hso_net->net);
-		free_netdev(hso_net->net);
-	}
 
 	/* start freeing */
 	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
@@ -2436,6 +2434,9 @@ static void hso_free_net_device(struct hso_device *hso_dev)
 	kfree(hso_net->mux_bulk_tx_buf);
 	hso_net->mux_bulk_tx_buf = NULL;
 
+	if (hso_net->net)
+		free_netdev(hso_net->net);
+
 	kfree(hso_dev);
 }
 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

----- End forwarded message -----
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
