From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] hso: fix problem with wrong status code sent by
 OPTION GTM601 during RING indication
Date: Tue, 17 Dec 2013 16:27:22 -0600
Message-ID: <1387319242.28943.42.camel@dcbw.local>
References: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com>
	 <541AADAC-7D20-4410-90FC-3E354B0C1457@goldelico.com>
	 <1387222829.2156.51.camel@dcbw.foobar.com>
	 <174CD81C-6425-4560-A3FA-3BFAA83BA770@goldelico.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Belisko Marek <marek.belisko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, e.verdonck-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
To: "Dr. H. Nikolaus Schaller" <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <174CD81C-6425-4560-A3FA-3BFAA83BA770-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-17 at 20:56 +0100, Dr. H. Nikolaus Schaller wrote:
> Hi Dan,
> 
> Am 16.12.2013 um 20:40 schrieb Dan Williams:
> 
> > On Fri, 2013-12-13 at 15:43 +0100, Dr. H. Nikolaus Schaller wrote:
> >> Hi,
> >> 
> >> Am 02.10.2013 um 09:00 schrieb Dr. H. Nikolaus Schaller:
> >> 
> >>> Hi Jan,
> >>> 
> >>> we are using a GTM601 modem (Firmware 1.7) for a while and have spotted an
> >>> issue that under some conditions the modem sends a packed wIndex over USB
> >>> that is rejected by the hso driver making troubles afterwards. Not rejecting makes
> >>> it work fine.
> >>> 
> >>> BR,
> >>> Nikolaus Schaller
> >>> 
> >>> ---
> >>> 
> >>> From f5c7e15b61f2ce4fe3105ff914f6bfaf5d74af0d Mon Sep 17 00:00:00 2001
> >>> From: "H. Nikolaus Schaller" <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
> >>> Date: Thu, 15 Nov 2012 14:40:57 +0100
> >>> Subject: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION
> >>> GTM601 during RING indication
> >>> 
> >>> It has been observed that the GTM601 with 1.7 firmware sometimes sends a value
> >>> wIndex that has bit 0x04 set instead of being reset as the code expects. So we
> >>> mask it for the error check.
> >>> 
> >>> See http://lists.goldelico.com/pipermail/gta04-owner/2012-February/001643.html
> >>> 
> >>> Signed-off-by: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
> >>> Signed-off-by: H. Nikolaus Schaller <hns-xXXSsgcRVIAdwXzzRB9H2Q@public.gmane.org>
> >>> ---
> >>> drivers/net/usb/hso.c |    3 ++-
> >>> 1 files changed, 2 insertions(+), 1 deletions(-)
> >>> 
> >>> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> >>> index cba1d46..d146e26 100644
> >>> --- a/drivers/net/usb/hso.c
> >>> +++ b/drivers/net/usb/hso.c
> >>> @@ -1503,7 +1503,8 @@ static void tiocmget_intr_callback(struct urb *urb)
> >>> 	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
> >>> 	    serial_state_notification->bNotification != B_NOTIFICATION ||
> >>> 	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
> >>> -	    le16_to_cpu(serial_state_notification->wIndex) != W_INDEX ||
> >>> +	    (le16_to_cpu(serial_state_notification->wIndex) & ~0x4) !=
> >>> +		W_INDEX ||
> >>> 	    le16_to_cpu(serial_state_notification->wLength) != W_LENGTH) {
> >>> 		dev_warn(&usb->dev,
> >>> 			 "hso received invalid serial state notification\n");
> >>> -- 
> >>> 1.7.7.4
> >>> 
> >>> 
> >> 
> >> I have found this (better) proposal by OPTION, but wonder what did happen to it.
> >> It neither shows in mainline 3.13-rc nor linux-next:
> >> 
> >> https://lkml.org/lkml/2013/10/9/263
> > 
> > Likely because nobody formally submitted the patch with a signed-off-by,
> > which indicates their intent that the patch is tested, correct, and can
> > be merged to the kernel.
> 
> Ok, I see. I just wasn't aware of the proposal at all since I missed the discussion
> and wasn't on CC.
> 
> Therefore I have added Eric to the CC.
> 
> > 
> > I looked at this today, and I'm left wondering how any port other than
> > HSO_PORT_MODEM can get the notification via tiocmget_intr_callback().
> > "serial->tiocmget" is only created for HSO_PORT_MODEM serial ports (see
> > hso_create_bulk_serial_device()):
> > 
> > 	if ((port & HSO_PORT_MASK) == HSO_PORT_MODEM) {
> > 		num_urbs = 2;
> > 		serial->tiocmget = kzalloc(sizeof(struct hso_tiocmget),
> > 					   GFP_KERNEL);
> > 
> > and the code in tiocmget_intr_callback() does this:
> > 
> > 	tiocmget = serial->tiocmget;
> > 	if (!tiocmget)
> > 		return;
> > 
> > which should mean that only a HSO_PORT_MODEM will ever process the
> > notification.  Further, the tiocmget interrupt URB is only created and
> > submitted if serial->tiocmget != NULL, so only HSO_PORT_MODEM should
> > ever be calling into tiocmget_intr_callback().
> 
> Ok, that looks plausible.
> 
> > 
> > So I think Eric's patch is actually wrong because it will *always* pass
> > the new check.
> > 
> > The original code had the correct intention, but the original code was
> > obviously wrong for newer devices where the port layout is read from
> > firmware and not from static tables, and thus for recent devices where
> > the modem interface is not USB interface #2.
> 
> This explains why we did run into the problem with the GTM601.
> 
> > 
> > Can you confirm/deny that the 'modem' interface for your GTM601 is USB
> > interface #6?  For example, my Icon 452 has the following USB interface
> > layout:
> > 
> > 0: Diag
> > 1: GPS
> > 2: GPS control
> > 3: Application
> > 4: Control
> > 5: Network
> > 6: Modem
> > 
> > So like the GTM601, I would expect any RING notifications to appear for
> > wIndex=0x06.
> 
> Interestingly I see:
> 
> 0: Diagnostic
> 1: GPS
> 2: GPS Control
> 3: Application
> 4: Control
> 5: Modem
> 
> I.e. there is no Network interface. Originally we did focus on /dev/ttyHS3

How are you determining the number here?  Are you using:

cat /sys/class/tty/ttyHS_Modem/device/bInterfaceNumber

to determine the actual USB interface number associated with the Modem
port?  Or are you going off the pre-udev-rename ttyHSx numbers?

> to access the Application interface, but people reported that it is not stable
> or always so. Therefore we have some udev rule to add symbolic names
> (e.g. /dev/ttyHS_Application):
> 
> http://git.goldelico.com/?p=gta04-kernel.git;a=blob;f=GTA04/udev-rules/hso.rules;hb=HEAD
> 
> So I think the assignment is not even always the same on the same device.

The assignment will always be the same on the same device *and the same
firmware*.  That is because the hso driver asks the firmware for the
port layout, and that is what is put into the 'hsotype' file in sysfs
that the udev rules use.  So if your telephony/WWAN stack is using the
udev symbolic links or reading 'hsotype' directly, you can be assured
that ttyHS_Modem is always the port you should be using for PPP.

> And I am a little puzzled why we do see the wIndex == 6 if it is the interface
> number. Maybe it happens only in some scenario where the Modem becomes
> interface #6.

I'm still not convinced that that it isn't #6 until we agree on how
we're figuring that out :)  I may well assume to little of you, so
forgive me if you are actually reporting the real USB interface # of the
ports.  But I've seen too many people confuse the tty numbers with USB
interface numbers, so I must ask.

> > 
> > Does the following patch fix the problem for you?
> 
> I will try but need a little time to setup a test scenario (because I need to trigger
> RING indications) and will then report.

Here's a RING on the 452 with Modem @ usbif #6:

[65808.711323] tiocmget_intr_callback: W_INDEX 0006
[65808.711330] tiocmget_intr_callback: UART bits 000a
[65808.711333] tiocmget_intr_callback: Modem ifnum 06

and B_TX_CARRIER notification with GIO322 with Modem @ usbif #2:

[66029.365441] tiocmget_intr_callback: W_INDEX 0002
[66029.365444] tiocmget_intr_callback: UART bits 0002
[66029.365445] tiocmget_intr_callback: Modem ifnum 02

Dan

> BR,
> Nikolaus
> 
> > 
> > Dan
> > 
> > ---
> > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > index 86292e6..1c7bdeb 100644
> > --- a/drivers/net/usb/hso.c
> > +++ b/drivers/net/usb/hso.c
> > @@ -181,15 +181,14 @@ enum rx_ctrl_state{
> > 	RX_SENT,
> > 	RX_PENDING
> > };
> > 
> > #define BM_REQUEST_TYPE (0xa1)
> > #define B_NOTIFICATION  (0x20)
> > #define W_VALUE         (0x0)
> > -#define W_INDEX         (0x2)
> > #define W_LENGTH        (0x2)
> > 
> > #define B_OVERRUN       (0x1<<6)
> > #define B_PARITY        (0x1<<5)
> > #define B_FRAMING       (0x1<<4)
> > #define B_RING_SIGNAL   (0x1<<3)
> > #define B_BREAK         (0x1<<2)
> > @@ -1483,31 +1482,38 @@ static void tiocmget_intr_callback(struct urb *urb)
> > 	struct hso_serial *serial = urb->context;
> > 	struct hso_tiocmget *tiocmget;
> > 	int status = urb->status;
> > 	u16 UART_state_bitmap, prev_UART_state_bitmap;
> > 	struct uart_icount *icount;
> > 	struct hso_serial_state_notification *serial_state_notification;
> > 	struct usb_device *usb;
> > +	int if_num;
> > 
> > 	/* Sanity checks */
> > 	if (!serial)
> > 		return;
> > 	if (status) {
> > 		handle_usb_error(status, __func__, serial->parent);
> > 		return;
> > 	}
> > +
> > +	/* tiocmget is only supported on HSO_PORT_MODEM */
> > 	tiocmget = serial->tiocmget;
> > 	if (!tiocmget)
> > 		return;
> > +	BUG_ON((serial->parent->port_spec & HSO_PORT_MASK) != HSO_PORT_MODEM);
> > +
> > 	usb = serial->parent->usb;
> > +	if_num = serial->parent->interface->altsetting->desc.bInterfaceNumber;
> > +
> > 	serial_state_notification = &tiocmget->serial_state_notification;
> > 	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
> > 	    serial_state_notification->bNotification != B_NOTIFICATION ||
> > 	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
> > -	    le16_to_cpu(serial_state_notification->wIndex) != W_INDEX ||
> > +	    le16_to_cpu(serial_state_notification->wIndex) != if_num ||
> > 	    le16_to_cpu(serial_state_notification->wLength) != W_LENGTH) {
> > 		dev_warn(&usb->dev,
> > 			 "hso received invalid serial state notification\n");
> > 		DUMP(serial_state_notification,
> > 		     sizeof(struct hso_serial_state_notification));
> > 	} else {
> > 
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
