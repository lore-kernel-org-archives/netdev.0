From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] cdc_ncm: workaround for EM7455 "silent" data interface
Date: Sun,  3 Jul 2016 22:24:50 +0200
Message-ID: <1467577490-27810-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Several Lenovo users have reported problems with their Sierra
Wireless EM7455 modem. The driver has loaded successfully and
the MBIM management channel has appeared to work, including
establishing a connection to the mobile network. But no frames
have been received over the data interface.

The problem affects all EM7455 and MC7455, and is assumed to
affect other modems based on the same Qualcomm chipset and
baseband firmware.

Testing narrowed the problem down to what seems to be a
firmware timing bug during initialization. Adding a short sleep
while probing is sufficient to make the problem disappear.
Experiments have shown that 1-2 ms is too little to have any
effect, while 10-20 ms is enough to reliably succeed.

Reported-by: Stefan Armbruster <ml001-v/iS5pZ/V4yNgfvolfaAKQ@public.gmane.org>
Reported-by: Ralph Plawetzki <ralph-pY4NoiSaI/Zg9hUCZPvPmw@public.gmane.org>
Reported-by: Andreas Fett <andreas.fett-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Reported-by: Rasmus Lerdorf <rasmus-zLLba4SOMilBDgjK7y7TUQ@public.gmane.org>
Reported-by: Samo Ratnik <samo.ratnik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reported-and-tested-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
I hope this unconditional short sleep during probing is acceptable,
as I don't want to start a new non-maintainable quirk device list for
this.  The EM7455 is already used by a number of laptop vendors, each
using their own device ID.  More are likely to come.  And that's only
the modems we *know* are affected...

 drivers/net/usb/cdc_ncm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 53759c315b97..877c9516e781 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -854,6 +854,13 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct=
 usb_interface *intf, u8 data_
 	if (cdc_ncm_init(dev))
 		goto error2;
=20
+	/* Some firmwares need a pause here or they will silently fail
+	 * to set up the interface properly.  This value was decided
+	 * empirically on a Sierra Wireless MC7455 running 02.08.02.00
+	 * firmware.
+	 */
+	usleep_range(10000, 20000);
+
 	/* configure data interface */
 	temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
 	if (temp) {
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
