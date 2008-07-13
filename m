From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [RFC][-rc9 PATCH] Bluetooth: fix oops in rfcomm
Date: Sun, 13 Jul 2008 19:23:18 +0200
Message-ID: <20080713172318.GA6180@damson.getinternet.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Soeren Sonnenburg <kernel@nn7.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Dave Young <hidave.darkstar@gmail.com>,
	linux-kernel@vger.kernel.org,
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:10926 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbYGMRX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 13:23:26 -0400
Received: by ug-out-1314.google.com with SMTP id h2so147080ugf.16
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2008 10:23:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Disclaimer: This is just an RFC as I don't really know the code in
question. But I did try to do it correctly and yes, it DOES fix the
oops for me. But I'd be really happy if somebody who uses Bluetooth
in the first place could test & review.

(In other words, you may use this patch for inspiration, etc. if you
 decide to give it a try yourself.)


Vegard


>From 675b50291f0af40974074590e2fd16ae0546ecde Mon Sep 17 00:00:00 2001
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Sun, 13 Jul 2008 19:02:11 +0200
Subject: [PATCH] Bluetooth: fix race between rfcomm and tty

Soeren Sonnenburg reported:
> this oops happened after a couple of s2ram cycles so it might be very
> well crap. However I somehow triggered it by /etc/init.d/bluetooth
> stop/start's which also call hid2hci maybe even a connection was about
> to be established at that time. As I remember having seen a problem like
> this before I thought I report it (even though I have a madwifi tainted
> kernel).
>
> kobject_add_internal failed for rfcomm0 with -EEXIST, don't try to register things with the same name in the same directory.

It turns out that the following sequence of actions will reproduce the
oops:

  1. Create a new rfcomm device (using RFCOMMCREATEDEV ioctl)
  2. (Try to) open the device
  3. Release the rfcomm device (using RFCOMMRELEASEDEV ioctl)

At this point, the "rfcomm?" tty is still in use, but the device is gone
from the internal rfcomm list, so the device id can be reused.

  4. Create a new rfcomm device with the same device id as before

And now kobject will complain that the tty already exists.

This patch attempts to correct this by only removing the device from the
internal rfcomm list of devices at the final unregister, so that the id
won't get reused until the device has been completely destructed.

This should be safe as the RFCOMM_TTY_RELEASED bit will be set for the
device and prevent the device from being reopened after it has been
released.

We also fix a race at the same time by including the call to
tty_unregister_device inside the rfcomm_dev_lock (the lock protecting
the list of devices).

Reported-by: Soeren Sonnenburg <kernel@nn7.de>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 net/bluetooth/rfcomm/tty.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index c919187..e289568 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -95,6 +95,8 @@ static void rfcomm_dev_destruct(struct rfcomm_dev *dev)
 
 	BT_DBG("dev %p dlc %p", dev, dlc);
 
+	write_lock_bh(&rfcomm_dev_lock);
+
 	/* Refcount should only hit zero when called from rfcomm_dev_del()
 	   which will have taken us off the list. Everything else are
 	   refcounting bugs. */
@@ -108,8 +110,11 @@ static void rfcomm_dev_destruct(struct rfcomm_dev *dev)
 
 	rfcomm_dlc_put(dlc);
 
+	list_del_init(&dev->list);
 	tty_unregister_device(rfcomm_tty_driver, dev->id);
 
+	write_unlock_bh(&rfcomm_dev_lock);
+
 	kfree(dev);
 
 	/* It's safe to call module_put() here because socket still
@@ -278,14 +283,14 @@ static int rfcomm_dev_add(struct rfcomm_dev_req *req, struct rfcomm_dlc *dlc)
 	__module_get(THIS_MODULE);
 
 out:
-	write_unlock_bh(&rfcomm_dev_lock);
-
 	if (err < 0) {
+		write_unlock_bh(&rfcomm_dev_lock);
 		kfree(dev);
 		return err;
 	}
 
 	dev->tty_dev = tty_register_device(rfcomm_tty_driver, dev->id, NULL);
+	write_unlock_bh(&rfcomm_dev_lock);
 
 	if (IS_ERR(dev->tty_dev)) {
 		err = PTR_ERR(dev->tty_dev);
@@ -314,10 +319,6 @@ static void rfcomm_dev_del(struct rfcomm_dev *dev)
 	else
 		set_bit(RFCOMM_TTY_RELEASED, &dev->flags);
 
-	write_lock_bh(&rfcomm_dev_lock);
-	list_del_init(&dev->list);
-	write_unlock_bh(&rfcomm_dev_lock);
-
 	rfcomm_dev_put(dev);
 }
 
-- 
1.5.4.1

