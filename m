From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Mon, 09 Feb 2015 12:51:54 +0100
Message-ID: <87a90nqp45.fsf@nemi.mork.no>
References: <1423477027-10869-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46384 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbbBILwG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 06:52:06 -0500
In-Reply-To: <1423477027-10869-1-git-send-email-kristian.evensen@gmail.com>
	(Kristian Evensen's message of "Mon, 9 Feb 2015 11:17:07 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kristian Evensen <kristian.evensen@gmail.com> writes:

> From: Kristian Evensen <kristian.evensen@gmail.com>
>
> Sierra Wireless MC73xx interface 10 is not usable with QMI, as the in=
terface
> does not respond to any QMI messages.

Really?  I don't have any such devices to test with unfortunately, but
the Sierra Wireless (SWI) "USB Driver Developer's Guide - AirPrime
MC73xx" [1] claims that interfaces 8, 10 and 11 represent RMNET1, RMNET=
2
and RMNET3 respectively.  It is confirmed [2] from SWI that RMNET3 is
non-functional, similar to the status of the MC77xx devices, but RMNET2
is believed to work. At least I believe so until you sent this patch...

Just to be sure: You do have a configuration where interfaces #10 and
#11 are visible, but none of them respond to any QMI at all?  Not even
CTL SYNC?  Could you get a minimal usbmon trace of that?

Note that interface #10 (RMNET2) still is enabled for 1199:68c0 in the
current (Version S2.20N2.27) out-of-tree drivers from SWI [3],
indicating that they believe it works:


#define BIT_9X15    (31)
=2E.
static int GobiNetDriverBind(
   struct usbnet *         pDev,
   struct usb_interface *  pIntf )
{
=2E.
   /* We only accept certain interfaces */
   if (pIntf->cur_altsetting->desc.bInterfaceClass !=3D USB_CLASS_VENDO=
R_SPEC )
   {
      DBG( "Ignoring non vendor class interface #%d\n",
           pIntf->cur_altsetting->desc.bInterfaceNumber );
      return -ENODEV;
   }
   else if (pDev->driver_info->data &&
          !test_bit(pIntf->cur_altsetting->desc.bInterfaceNumber, &pDev=
->driver_info->data)) {
      DBG( "invalid interface %d\n",
           pIntf->cur_altsetting->desc.bInterfaceNumber );
      return -ENODEV;
   }
=2E.
static const struct driver_info GobiNetInfo_9x15 =3D {
   .description   =3D "GobiNet Ethernet Device",
   .flags         =3D FLAG_ETHER,
   .bind          =3D GobiNetDriverBind,
   .unbind        =3D GobiNetDriverUnbind,
#ifdef DATA_MODE_RP
   .rx_fixup      =3D GobiNetDriverRxFixup,
   .tx_fixup      =3D GobiNetDriverTxFixup,
#elif defined(QOS_MODE)
   .tx_fixup      =3D GobiNetDriverTxQoS,
   //WORD AROUND integrated from qmi_wwan.c::qmi_wwan_rx_fixup
   .rx_fixup      =3D GobiNetDriverLteRxFixup,
#else
   .rx_fixup      =3D GobiNetDriverLteRxFixup,
#endif
   .data          =3D BIT(8) | BIT(10) | BIT(BIT_9X15),
};

#define QMI_G3K_DEVICE(vend, prod) \
   USB_DEVICE(vend, prod), \
   .driver_info =3D (unsigned long)&GobiNetInfo_gobi

#define QMI_9X15_DEVICE(vend, prod) \
   USB_DEVICE(vend, prod), \
   .driver_info =3D (unsigned long)&GobiNetInfo_9x15

/*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D*/
// Qualcomm Gobi 3000 VID/PIDs
/*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D*/
static const struct usb_device_id GobiVIDPIDTable [] =3D
{
   // Sierra Wireless MC7750 QMI Device VID/PID
   {
      USB_DEVICE( 0x1199, 0x68a2 ),
      .driver_info =3D (unsigned long)&GobiNetInfo_qmi,
   },

   // Gobi 3000
   {QMI_G3K_DEVICE(0x05c6, 0x920d)},
   {QMI_G3K_DEVICE(0x1199, 0x9011)},
   {QMI_G3K_DEVICE(0x1199, 0x9013)},
   {QMI_G3K_DEVICE(0x1199, 0x9015)},
   {QMI_G3K_DEVICE(0x1199, 0x9019)},
   {QMI_G3K_DEVICE(0x03f0, 0x371d)},
   // 9x15
   {QMI_9X15_DEVICE(0x1199, 0x68C0)},
   {QMI_9X15_DEVICE(0x1199, 0x9041)},
   {QMI_9X15_DEVICE(0x1199, 0x9051)},
   {QMI_9X15_DEVICE(0x1199, 0x9053)},
   {QMI_9X15_DEVICE(0x1199, 0x9054)},
   {QMI_9X15_DEVICE(0x1199, 0x9055)},
   {QMI_9X15_DEVICE(0x1199, 0x9056)},
   {QMI_9X15_DEVICE(0x1199, 0x9061)},

   //Terminating entry
   { }
};

MODULE_DEVICE_TABLE( usb, GobiVIDPIDTable );



AFAICS, this code makes the driver bind to interfaces 8 and 10 on all
QMI_9X15_DEVICEs.  The BIT_9X15 is higher than any interface number in
use on these devices, and is used to trigger a slightly different QMI
startup sequence for 9x15 devices (this driver does some QMI internally=
,
contrary to the in-kernel driver which leaves all that to userspace).

> We are now left with interface 8 for the
> MC73xx, which is consistent with most other Sierra Wireless QMI-devic=
es.

Well, I do have an MC7710 and it most certainly support both RMNET1 and
RMNET2 (on interface #19).  So if the MC73xx is to be consistent with
other SWI QMI devices, then I would expect it to support RMNET2 as well=
,
only using interface #10 instead of #19.  And that's how I understood
the reply from SWI in [2].


Access to these documents might require registration, but I include the
references here for completeness since these are my primary sources of
information:

[1] http://source.sierrawireless.com/resources/airprime/minicard/airpri=
me_mc73xx_usb_driver_developers_guide/
[2] https://forum.sierrawireless.com/viewtopic.php?f=3D117&t=3D6110&p=3D=
32629#p32629
[3] http://source.sierrawireless.com/resources/airprime/software/usb-dr=
ivers-linux-qmi-software/



Bj=C3=B8rn
