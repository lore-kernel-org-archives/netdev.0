From: Jaswinder Singh <jaswinder@infradead.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Tue, 29 Jul 2008 21:39:46 +0530
Message-ID: <1217347786.2885.11.camel@jaswinder.satnam>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
	 <1217248585.22789.58.camel@obelisk.thedillows.org>
	 <1217253260.17632.6.camel@jaswinder.satnam>
	 <1217295498.28682.16.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40503 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523AbYG2QLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 12:11:09 -0400
In-Reply-To: <1217295498.28682.16.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

On Mon, 2008-07-28 at 21:38 -0400, David Dillow wrote:
> > +
> > +	/* firmware */
> > +	u8			*tp_fw_image;
> >  };
>=20
> Now you keep one copy per NIC, which doubles the memory usage. Just u=
se
> static struct firmware *typhoon_fw;
>=20

OK, Fixed.

> > +static int typhoon_init_firmware(struct typhoon *tp)
> > +{
> > +	const struct firmware *fw;
> > +	const char fw_name[] =3D "3com/typhoon.bin";
>=20
> If you use the #define and the global static, you can get rid of the
> above. Just use the define in place of fw_name below:
>=20

OK, Fixed.

> > +	tp->tp_fw_image =3D vmalloc(fw->size);
> > +	if (!tp->tp_fw_image) {
> > +		err =3D -ENOMEM;
> > +		printk(KERN_ERR "%s: \"%s\" Failed %d\n",
> > +		       tp->name, fw_name, err);
> > +		goto out;
> > +	}
>=20
> Then you can get rid of the double allocation and memcpy. Just put th=
e
> call to release_firmware() in typhoon_cleanup().
>=20

OK, Fixed.

> > +	err =3D typhoon_init_firmware(tp);
> > +	if (err)
> > +		goto out_irq;
> > +
>=20
> This should move to either typhoon_init() or typhoon_init_one(). Putt=
ing
> it in typhoon_init() means we waste memory when the module is loaded =
if
> there is no typhoon NIC; putting it in typhoon_init_one() means it ne=
eds
> protection from threaded probing, should that ever be put back in. Gi=
ven
> that most modern distros don't do probing by blinding loading modules=
,
> typhoon_init() seems a safe bet.
>=20

Sorry Dave, I need tp->pdev so =EF=BB=BFtyphoon_init_one() seems better=
=2E
I hope you do not mind this.

> > @@ -2155,6 +2189,9 @@ typhoon_close(struct net_device *dev)
>=20
> > +	if (tp->tp_fw_image)
> > +		vfree(tp->tp_fw_image);
> > +
>=20
> This goes away and is replaced by a release_firmware() in
> typhoon_cleanup() if you do the above.
>=20

OK, Fixed :)

Here is updated patch for typhoon.c :-

Subject: [PATCH] typhoon: use request_firmware

made following const as we treat firmware data as const:
        struct typhoon_file_header *fHdr
        struct typhoon_section_header *sHdr
        u8 *image_data

Signed-off-by: Jaswinder Singh <jaswinder@infradead.org>
---
 drivers/net/typhoon.c          |   33 +-
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index c0dd25b..a57941a 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -130,16 +130,18 @@ static const int multicast_filter_limit =3D 32;
 #include <linux/in6.h>
 #include <linux/version.h>
 #include <linux/dma-mapping.h>
+#include <linux/firmware.h>
=20
 #include "typhoon.h"
-#include "typhoon-firmware.h"
=20
 static char version[] __devinitdata =3D
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE "=
)\n";
=20
+#define FIRMWARE_NAME		"3com/typhoon.bin"
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_LICENSE("GPL");
+MODULE_FIRMWARE(FIRMWARE_NAME);
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)"=
);
 MODULE_PARM_DESC(rx_copybreak, "Packets smaller than this are copied a=
nd "
 			       "the buffer given back to the NIC. Default "
@@ -1347,14 +1349,28 @@ typhoon_init_rings(struct typhoon *tp)
 	tp->txHiRing.lastRead =3D 0;
 }
=20
+static const struct firmware *typhoon_fw;
+
+static int typhoon_init_firmware(struct typhoon *tp)
+{
+	int err;
+
+	err =3D request_firmware(&typhoon_fw, FIRMWARE_NAME, &tp->pdev->dev);
+	if (err)
+		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
+		       tp->name, FIRMWARE_NAME);
+
+	return err;
+}
+
 static int
 typhoon_download_firmware(struct typhoon *tp)
 {
 	void __iomem *ioaddr =3D tp->ioaddr;
 	struct pci_dev *pdev =3D tp->pdev;
-	struct typhoon_file_header *fHdr;
-	struct typhoon_section_header *sHdr;
-	u8 *image_data;
+	const struct typhoon_file_header *fHdr;
+	const struct typhoon_section_header *sHdr;
+	const u8 *image_data;
 	void *dpage;
 	dma_addr_t dpage_dma;
 	__sum16 csum;
@@ -1369,7 +1385,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	int err;
=20
 	err =3D -EINVAL;
-	fHdr =3D (struct typhoon_file_header *) typhoon_firmware_image;
+	fHdr =3D (struct typhoon_file_header *) typhoon_fw->data;
 	image_data =3D (u8 *) fHdr;
=20
 	if(memcmp(fHdr->tag, "TYPHOON", 8)) {
@@ -2445,6 +2461,10 @@ typhoon_init_one(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
 	 */
 	tp->name =3D pci_name(pdev);
=20
+	err =3D typhoon_init_firmware(tp);
+	if (err)
+		goto error_out_reset;
+
 	typhoon_init_interface(tp);
 	typhoon_init_rings(tp);
=20
@@ -2625,6 +2645,9 @@ typhoon_init(void)
 static void __exit
 typhoon_cleanup(void)
 {
+	if (typhoon_fw)
+		release_firmware(typhoon_fw);
+
 	pci_unregister_driver(&typhoon_driver);
 }
=20
You can check complete patch from :-
http://git.infradead.org/users/jaswinder/firm-jsr-2.6.git

Thank you,

Jaswinder Singh.

