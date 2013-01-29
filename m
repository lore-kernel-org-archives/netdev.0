From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net v2] net: usbnet: prevent buggy devices from killing us
Date: Tue, 29 Jan 2013 10:51:28 +0100
Message-ID: <1359453088-12370-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Joe Perches <joe@perches.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37794 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545Ab3A2Jw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 04:52:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A device sending 0 length frames as fast as it can has been
observed killing the host system due to the resulting memory
pressure.

Temporarily disable RX skb allocation and URB submission when
the current error ratio is high, preventing us from trying to
allocate an infinite number of skbs.  Reenable as soon as we
are finished processing the done queue, allowing the device
to continue working after short error bursts.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

---
v2 changes:
 - reset counters in open to avoid starting in previous error state
 - remove superfluous debug logging.  Errors are logged per packet
   when debugging is on anyway.

The removal of the debug logging should address your concerns, Joe?

Note that I have not added any new device reset or the like, Oliver.  I=
t
does not seem to help for the device I am testing.  And being a composi=
te
device, where this bug only affects *one* function, I do not think it
would be appropriate even if it did help.  Note that the device may be
configured with multiple usbnet functions as well, and that the bug
only hits one of them.  All other functions work fine, as long as this
patch protects the host.

Noting that since the bug triggers when coming out of CDC MBIM mode, I
also tried using the MBIM class specific RESET_FUNCTION request before
leaving MBIM mode.  But this didn't have any effect either.  Just FYI.

As it is, I do not see any way we can do any sensible error handling
here. Let us concentrate on making usbnet survive the flood and leave
further error handling to the user.


Bj=C3=B8rn

 drivers/net/usb/usbnet.c   |   25 +++++++++++++++++++++++++
 include/linux/usb/usbnet.h |    2 ++
 2 files changed, 27 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f34b2eb..9778377 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -380,6 +380,12 @@ static int rx_submit (struct usbnet *dev, struct u=
rb *urb, gfp_t flags)
 	unsigned long		lockflags;
 	size_t			size =3D dev->rx_urb_size;
=20
+	/* prevent rx skb allocation when error ratio is high */
+	if (test_bit(EVENT_RX_KILL, &dev->flags)) {
+		usb_free_urb(urb);
+		return -ENOLINK;
+	}
+
 	skb =3D __netdev_alloc_skb_ip_align(dev->net, size, flags);
 	if (!skb) {
 		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
@@ -539,6 +545,17 @@ block:
 		break;
 	}
=20
+	/* stop rx if packet error rate is high */
+	if (++dev->pkt_cnt > 30) {
+		dev->pkt_cnt =3D 0;
+		dev->pkt_err =3D 0;
+	} else {
+		if (state =3D=3D rx_cleanup)
+			dev->pkt_err++;
+		if (dev->pkt_err > 20)
+			set_bit(EVENT_RX_KILL, &dev->flags);
+	}
+
 	state =3D defer_bh(dev, skb, &dev->rxq, state);
=20
 	if (urb) {
@@ -791,6 +808,11 @@ int usbnet_open (struct net_device *net)
 		   (dev->driver_info->flags & FLAG_FRAMING_AX) ? "ASIX" :
 		   "simple");
=20
+	/* reset rx error state */
+	dev->pkt_cnt =3D 0;
+	dev->pkt_err =3D 0;
+	clear_bit(EVENT_RX_KILL, &dev->flags);
+
 	// delay posting reads until we're fully open
 	tasklet_schedule (&dev->bh);
 	if (info->manage_power) {
@@ -1254,6 +1276,9 @@ static void usbnet_bh (unsigned long param)
 		}
 	}
=20
+	/* restart RX again after disabling due to high error rate */
+	clear_bit(EVENT_RX_KILL, &dev->flags);
+
 	// waiting for all pending urbs to complete?
 	if (dev->wait) {
 		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) =3D=3D 0) {
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 5de7a22..0de078d 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -33,6 +33,7 @@ struct usbnet {
 	wait_queue_head_t	*wait;
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;
+	unsigned char		pkt_cnt, pkt_err;
=20
 	/* i/o info: pipes etc */
 	unsigned		in, out;
@@ -70,6 +71,7 @@ struct usbnet {
 #		define EVENT_DEV_OPEN	7
 #		define EVENT_DEVICE_REPORT_IDLE	8
 #		define EVENT_NO_RUNTIME_PM	9
+#		define EVENT_RX_KILL	10
 };
=20
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
--=20
1.7.10.4
