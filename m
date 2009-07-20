From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Mon, 20 Jul 2009 09:35:18 +0300
Message-ID: <200907200935.19103.remi.denis-courmont@nokia.com>
References: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com> <200907171547.39815.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: ext Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200907171547.39815.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 17 July 2009 16:47:38 ext Oliver Neukum wrote:
> Am Freitag, 17. Juli 2009 11:56:06 schrieb R=C3=A9mi Denis-Courmont:
> > +       atomic_dec(&pnd->tx_queue);
> > +       netif_wake_queue(dev);
>
> Now that I think about it this seems to be a race condition.
> What makes sure that your are still below the limit when you
> wake the queue?

The netif TX queue serializes usbpn_xmit() against itself. Then, at all=
 times:=20
tx_queue + !netif_queue_stopped() <=3D tx_queue_len (in other words eit=
her=20
tx_queue =3D tx_queue_len and queue is stopped, or tx_queue < tx_queue_=
len).

Initially:
0 + 1 <=3D tx_queue_len, the assertion is initially true.

Recurrently:
If usbpn_xmit() is called, then the queue was not stopped, so tx_queue =
<=20
tx_queue_len. Then the queue is stopped. In the race free cases, either=
=20
tx_queue is incremented up to the limit, and the queue remains stopped;=
 the=20
assertion is still valid.
Alternatively tx_queue remains below limit and the queue gets woken aga=
in; the=20
assertion is still valid.

In the racy case, tx_complete() fires, incrementation in usbpn_xmit() a=
nd=20
decrementation in tx_complete() will cancel each other. So, regardless =
of=20
their respective order, tx_queue will be unchanged, and the assertion r=
emains=20
valid. A fortiori, it works fine if usbpn_xmit() races with more than o=
ne call=20
of tx_complete().

The cases that tx_complete() runs while the queue is not transmitting i=
s=20
evident.


--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
