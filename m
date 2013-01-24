From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 20:16:56 +0100
Message-ID: <1359055016-13603-1-git-send-email-bjorn@mork.no>
References: <2556579.vjYlY1iKn5@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2556579.vjYlY1iKn5-7ztolUikljGernLeA6q8OA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A device sending 0 length frames as fast as it can has been
observed killing the host system due to the resulting memory
pressure.

Temporarily disable RX skb allocation and URB submission when
the current error ratio is high, preventing us from trying to
allocate an infinite number of skbs.  Reenable as soon as we
are finished processing the done queue, allowing the device
to continue working after short error bursts.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
So is this starting to look OK?

usbnet already uses "throttle", "halt" and "stop" for other
functions, so I decided to name the new flag "kill".  No other
reason.

Didn't see any point in calculating the error limit.  A fixed
number works just as well.

Restarting in usbnet_bh was a simple way to achieve what I
wanted: enabling RX again when we know we can handle it.


Bj=C3=B8rn

 drivers/net/usb/usbnet.c   |   26 ++++++++++++++++++++++++++
 include/linux/usb/usbnet.h |    2 ++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f34b2eb..64657d6 100644
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
@@ -539,6 +545,22 @@ block:
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
+		if (dev->pkt_err > 20) {
+			set_bit(EVENT_RX_KILL, &dev->flags);
+			if (net_ratelimit())
+				netif_dbg(dev, rx_err, dev->net,
+					  "rx kill: high error rate\n");
+			dev->pkt_err =3D 0;
+		}
+	}
+
 	state =3D defer_bh(dev, skb, &dev->rxq, state);
=20
 	if (urb) {
@@ -1254,6 +1276,10 @@ static void usbnet_bh (unsigned long param)
 		}
 	}
=20
+	/* restart RX again after disabling due to high error rate */
+	if (test_and_clear_bit(EVENT_RX_KILL, &dev->flags) && net_ratelimit()=
)
+		netif_dbg(dev, rx_err, dev->net, "rx kill: restarting\n");
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
1.7.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
