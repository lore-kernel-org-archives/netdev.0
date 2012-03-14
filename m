From: Maximilian Schwerin <mvs@tigris.de>
Subject: [PATCH] usbnet: fix spinlock recursion
Date: Wed, 14 Mar 2012 18:14:34 +0100
Message-ID: <1331745274-24039-1-git-send-email-mvs@tigris.de>
Cc: netdev@vger.kernel.org, Albert Herranz <albert_herranz@yahoo.es>,
	Maximilian Schwerin <mvs@tigris.de>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www45.your-server.de ([213.133.104.45]:43764 "EHLO
	www45.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760621Ab2CNRl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 13:41:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Albert Herranz <albert_herranz@yahoo.es>

This patch fixes the following spinlock recursion bug seen when bringing down
the ethernet interface.

[   87.354683] BUG: spinlock recursion on CPU#0, ifconfig/1722
[   87.360899]  lock: d2e01cd0, .magic: dead4ead, .owner: ifconfig/1722, .owner_cpu: 0
[   87.373410] Call Trace:
[   87.379546] [d2f13c30] [c0008394] show_stack+0x3c/0x160 (unreliable)
[   87.386227] [d2f13c60] [c0169dd8] spin_bug+0x8c/0xd0
[   87.392858] [d2f13c80] [c016a0e4] _raw_spin_lock+0xb4/0xb8
[   87.399570] [d2f13c90] [c02c855c] _spin_lock_irqsave+0x30/0x48
[   87.406258] [d2f13cb0] [c01aa5d4] defer_bh+0x28/0xfc
[   87.412726] [d2f13cd0] [c01c32e8] usb_hcd_giveback_urb+0x5c/0xdc
[   87.419209] [d2f13ce0] [c01d2cec] sthcd_giveback_urb+0x30/0x50
[   87.425762] [d2f13d00] [c01d488c] sthcd_urb_dequeue+0x7c/0xac
[   87.432318] [d2f13d30] [c01c3478] unlink1+0x3c/0x4c
[   87.438960] [d2f13d40] [c01c45c8] usb_hcd_unlink_urb+0x88/0xa4
[   87.445629] [d2f13d60] [c01c49ac] usb_unlink_urb+0x54/0x5c
[   87.452210] [d2f13d70] [c01aa170] unlink_urbs+0x40/0xb0
[   87.458762] [d2f13d90] [c01ab470] usbnet_stop+0xdc/0x1a0
[   87.465320] [d2f13df0] [c023bf18] dev_close+0xa0/0xdc
[   87.471639] [d2f13e00] [c023bc98] dev_change_flags+0x84/0x1b4
[   87.477908] [d2f13e20] [c0283f50] devinet_ioctl+0x5ec/0x6b8
[   87.484222] [d2f13e90] [c0284cbc] inet_ioctl+0x98/0xbc
[   87.490450] [d2f13ea0] [c022a300] sock_ioctl+0x60/0x284
[   87.496566] [d2f13ec0] [c00a2714] vfs_ioctl+0x44/0xa8
[   87.502657] [d2f13ee0] [c00a2d24] do_vfs_ioctl+0x88/0x24c
[   87.508707] [d2f13f10] [c00a2f28] sys_ioctl+0x40/0x74
[   87.514728] [d2f13f40] [c0011bbc] ret_from_syscall+0x0/0x38
[   87.520780] --- Exception: c01 at 0xff59878
[   87.520783]     LR = 0xff597dc

unlink_urbs() takes the sk_buff queue lock &q->lock before removing the
queued URBs via usb_unlink_urb().
The issue here is that the completion handler of a queued TX URB will
get called when the URB is unlinked, then tx_complete() will call defer_bh()
which will try to take the queue lock again and fail.

The fix here is to release the list lock before unlinking a URB.

Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
Signed-off-by: Maximilian Schwerin <mvs@tigris.de>
---
 drivers/net/usb/usbnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index fae0fbd..b06bfd8 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -591,7 +591,9 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
+		spin_unlock(&q->lock);
 		retval = usb_unlink_urb (urb);
+		spin_lock(&q->lock);
 		if (retval != -EINPROGRESS && retval != 0)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
-- 
1.7.0.4
