From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: net: qmi_wwan: bind to both control and data interface
Date: Fri, 22 Jun 2012 19:56:17 +0300
Message-ID: <20120622165616.GI5390@mwanda>
References: <20120622142534.GA19617@elgon.mountain>
 <87395nl3bu.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:40566 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756097Ab2FVQ4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 12:56:34 -0400
Content-Disposition: inline
In-Reply-To: <87395nl3bu.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 22, 2012 at 06:27:17PM +0200, Bj=F8rn Mork wrote:
> Dan Carpenter <dan.carpenter@oracle.com> writes:
>=20
> > The patch 230718bda1be: "net: qmi_wwan: bind to both control and da=
ta=20
> > interface" from Jun 19, 2012, leads to the following Smatch warning=
:
> > drivers/net/usb/qmi_wwan.c:206 qmi_wwan_bind()
> > 	 error: potential NULL dereference 'cdc_union'.
> >
> > drivers/net/usb/qmi_wwan.c
> >    205          /* verify CDC Union */
> >    206          if (desc->bInterfaceNumber !=3D cdc_union->bMasterI=
nterface0) {
> >                                               ^^^^^^^^^
> >
> > cdc_union is only non-NULL for USB_CDC_UNION_TYPE.  We used to chec=
k for
> > NULL here but your patch removes the check.  I just want to verify =
that
> > that was intended.
> >
> >    207                  dev_err(&intf->dev, "bogus CDC Union: maste=
r=3D%u\n", cdc_union->bMasterInterface0);
> >    208                  goto err;
> >    209          }
> >    210 =20
>=20
> Thanks for the notification, but this was intentional while touching =
the
> code anyway.  The test always was redundant because the parsing code
> ensure that cdc_union cannot be NULL at that point.
>=20

Yeah.  I see that now.  I think it would be more readable if the
check were rewritten like this.  That way you can see immediately
that it's checking for USB_CDC_UNION_TYPE without scrolling back and
forth in the code.

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index f1e7791..23cb13c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -129,7 +129,6 @@ static int qmi_wwan_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 	struct usb_interface_descriptor *desc =3D &intf->cur_altsetting->desc=
;
 	struct usb_cdc_union_desc *cdc_union =3D NULL;
 	struct usb_cdc_ether_desc *cdc_ether =3D NULL;
-	u32 required =3D 1 << USB_CDC_HEADER_TYPE | 1 << USB_CDC_UNION_TYPE;
 	u32 found =3D 0;
 	struct usb_driver *driver =3D driver_of(intf);
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
@@ -197,7 +196,8 @@ next_desc:
 	}
=20
 	/* did we find all the required ones? */
-	if ((found & required) !=3D required) {
+	if (!(found & (1 << USB_CDC_HEADER_TYPE)) ||
+	    !(found & (1 << USB_CDC_UNION_TYPE))) {
 		dev_err(&intf->dev, "CDC functional descriptors missing\n");
 		goto err;
 	}
