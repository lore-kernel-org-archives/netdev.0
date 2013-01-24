From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 13:47:40 +0100
Message-ID: <87y5fig32r.fsf@nemi.mork.no>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no>
	<2321910.EQLkSoxl50@linux-5eaq.site> <877gn2hlkh.fsf@nemi.mork.no>
	<1809412.hrq33TVdWp@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34193 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865Ab3AXMsm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 07:48:42 -0500
In-Reply-To: <1809412.hrq33TVdWp@linux-5eaq.site> (Oliver Neukum's message of
	"Thu, 24 Jan 2013 12:31:08 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:
> On Thursday 24 January 2013 12:22:54 Bj=C3=B8rn Mork wrote:
>
>> Sorry for being daft, but how do I code the "20 among the last 30" p=
art
>> there?
>
> Just by agreeing that you can live with false negatives but not false=
 positives
>
> if (++counter > 30) {
> 	counter =3D bogus =3D 0;
> } else {
> 	if (is_bogus(packet)
> 		bogus++;
> 	if (bogus > counter/2)
> 		throttle();
> }

So, add two new counters to struct usbnet for this?  That seems a littl=
e
overkill to me, but I don't see how else to implement anything like tha=
t.

It is still not completely clear to me how the throttling/unthrottling
should be done.  It tested with static counters (to avoid having to
rebuild everything for this test) and a new EVENT_RX_THROTTLE flag.
Still on top of my previous patch just for safety while testing, as I a=
m
fed up of having to reboot all the time :-)

Doing the flag test in rx_submit seems simpler than trying to track all
the places this is called.  Still checking the dev->done.qlen to be abl=
e
to unthrottle.

Was this along the lines you thought?




diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 85c7ffd..e3a1d63 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -380,6 +382,13 @@ static int rx_submit (struct usbnet *dev, struct u=
rb *urb, gfp_t flags)
 	unsigned long		lockflags;
 	size_t			size =3D dev->rx_urb_size;
=20
+
+	if (test_bit(EVENT_RX_THROTTLE, &dev->flags) && dev->done.qlen > 0) {
+		netif_dbg(dev, rx_err, dev->net, "%s: EVENT_RX_THROTTLE: (done.qlen=3D=
%u)\n", __func__, dev->done.qlen);
+		usb_free_urb(urb);
+		return -ENOLINK;
+	}
+
 	/* Do not let a device flood us to death! */
 	if (dev->done.qlen > 1024) {
 		netif_dbg(dev, rx_err, dev->net, "done queue filling up (%u) - throt=
tling\n", dev->done.qlen);
@@ -482,6 +491,7 @@ static void rx_complete (struct urb *urb)
 	struct usbnet		*dev =3D entry->dev;
 	int			urb_status =3D urb->status;
 	enum skb_state		state;
+	static int counter, bogus;
=20
 	skb_put (skb, urb->actual_length);
 	state =3D rx_done;
@@ -547,6 +557,17 @@ block:
 		break;
 	}
=20
+	/* keep track of bogus packet ratio */
+	if (++counter > 30) {
+		counter =3D bogus =3D 0;
+		clear_bit(EVENT_RX_THROTTLE, &dev->flags);
+	} else {
+		if (state =3D=3D rx_cleanup)
+			bogus++;
+		if (bogus > counter/2)
+			set_bit(EVENT_RX_THROTTLE, &dev->flags);
+	}
+
 	state =3D defer_bh(dev, skb, &dev->rxq, state);
=20
 	if (urb) {
