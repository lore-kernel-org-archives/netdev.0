From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 11:25:52 +0100
Message-ID: <1359023152-32576-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60676 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438Ab3AXK07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 05:26:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A device sending 0 length frames as fast as it can has been
observed killing the host system due to the resulting memory
pressure. We handle the done queue as fast as we can, so
if this queue is filling up then that is an indication that we
are under too heavy pressure.  Refusing further allocations
until the done queue is handled prevents the buggy device
from taking the system down.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Hello Oliver,

The MBIM firmware for the Sierra Wireless MC7710 is a nice source
of "interesting" device issues.  One of the uglier ones is that
it under certain conditions will start flooding us with frames
having length 0 as fast as it can.  And that is pretty fast...

My older laptop dies immediately under this.  It just cannot keep
up with the infinite allocations usbnet will do when the done
queue first starts growing beyond reason.

I really do not have a clue how to handle this problem, but this
patch seems to do the job for me without affecting normal devices.
The queue limit is just a number which Works For Me, leaving the
system running with the buggy device and not kicking in under
normal load.

What do you think? Is there some other way this should be solved?



Bj=C3=B8rn

 drivers/net/usb/usbnet.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f34b2eb..85c7ffd 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -380,6 +380,14 @@ static int rx_submit (struct usbnet *dev, struct u=
rb *urb, gfp_t flags)
 	unsigned long		lockflags;
 	size_t			size =3D dev->rx_urb_size;
=20
+	/* Do not let a device flood us to death! */
+	if (dev->done.qlen > 1024) {
+		netif_dbg(dev, rx_err, dev->net, "done queue filling up (%u) - throt=
tling\n", dev->done.qlen);
+		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
+		usb_free_urb (urb);
+		return -ENOMEM;
+	}
+
 	skb =3D __netdev_alloc_skb_ip_align(dev->net, size, flags);
 	if (!skb) {
 		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
--=20
1.7.2.5
