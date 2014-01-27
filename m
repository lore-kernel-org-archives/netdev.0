From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: Many USB ethernet devices are broken over xhci
Date: Mon, 27 Jan 2014 16:06:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D46624F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Many of the net/usb ethernet drivers (including common ones like
the smsc95xx) will fail to transmit all packet length properly
when connected to a USB3 port (ie using the xhci driver).

The underlying problem is that they assume the host controller
will honour the URB_ZERO_PACKET flag - which usbnet sets because
they specify FLAG_SEND_ZLP.

However no one has ever added support for URB_ZERO_PACKET to
the xhci driver - so packets that need padding (probably 512
bytes after any header is added) will not be sent correctly
and may have very adverse effects on the usb target.

The ax179_178a driver avoids this by not setting FLAG_SEND_ZLP,
modifying the packet header, and appending an extra zero byte.
(Which has been responsible for its own set of panics.)

I don't think this can be fixed by just clearing (or ignoring)
FLAG_SEND_ZLP as the extra byte will also confuse things.

It needs to be fixed in the xhci code.

I wrote this patch a while ago - worked for me with the ax179_178a
driver. http://www.spinics.net/lists/linux-usb/msg97370.html

The patch is a bit difficult to read, the v1 version contained a copy of
the new function. http://www.spinics.net/lists/linux-usb/msg97183.html

I don't think anything significant has changed (in the main kernel
sources) since I wrote the patch.

	David




--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
