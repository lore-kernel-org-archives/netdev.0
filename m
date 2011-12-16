From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 3/3] qmi_wwan: Driver for WWAN devices requiring use of the QMI protocol
Date: Fri, 16 Dec 2011 17:03:42 +0100
Message-ID: <874nx0bj1d.fsf@nemi.mork.no>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
	<1323750784-32608-4-git-send-email-bjorn@mork.no>
	<1323882501.2077.3.camel@dcbw.foobar.com>
	<87r506b1ap.fsf@nemi.mork.no>
	<1323971530.23419.13.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323971530.23419.13.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org> (Dan Williams's
	message of "Thu, 15 Dec 2011 11:52:10 -0600")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> On Thu, 2011-12-15 at 11:02 +0100, Bj=C3=B8rn Mork wrote:
>
> But I agree that eventually the full QMI protocol should be made
>> available to userspace for other uses.  That should be fairly easy to do
>> if you just proxy the commands.  But I'm worring about the interface.
>> Is the /dev/qmi from GobiNet acceptable?  Why isn't it merged yet?
>
> It would have to be /dev/qmiX (in case you have more than one
> QMI-capable card in the system) and it would also have to have the right
> sysfs entries so that we could match the qmiX entry up with it's parent
> USB interface.  Not entirely sure how to do that.

The idea of creating multiple independent devices and then stitch them
together again using a sysfs API seems a little backwards to me.  How
about just use ioctls and forward both request and reply?  That won't
support unsolicited notifications, but otherwise it should be enough to
be useful.

The attached patch implements straight QMI forwarding.  Note that it is
only intended as a demo, and *not* a submission.  I have not yet decided
whether this is a good idea or not, and I assume that the API should
receive some more thought and blessings from others than me before
anything like this can be submitted.

It should maybe even be extended to something a little less
driver/device specific.  I believe a common WWAN API for settings things
like PIN code and APN would be very useful, in the same way the wireless
API has made WLAN usage possible without driver specific tools.


But anyway, the demo does work.  Using it to send this reqest for
firmware revision from userspace:

0000  01 0c 00 00 02 00 00 01  00 23 00 00 00

partly decoded as:

.tf =3D 0x01
.len =3D 0x000c
.ctrl =3D 0x00 control point
.service =3D 0x02
.qmicid =3D 0x00
.flags =3D 0x00 request
.tid =3D 0x0001
.msgid =3D 0x0023
.len =3D 000000


I get the expected reply:

0000  01 4c 00 80 02 00 02 01  00 23 00 40 00 02 04 00
0010  00 00 00 00 01 36 00 4d  39 32 30 30 42 2d 53 43
0020  41 51 44 42 5a 44 2d 33  2e 30 2e 33 35 30 30 32
0030  35 54 20 20 31 20 20 5b  41 75 67 20 31 31 20 32
0040  30 31 31 20 30 32 3a 30  30 3a 30 30 5d

partly decoded as:

.tf =3D 0x01
.len =3D 0x004c
.ctrl =3D 0x80 service
.service =3D 0x02
.qmicid =3D 0x00
.flags =3D 0x02 response
.tid =3D 0x0001
.msgid =3D 0x0023
.len =3D 0x0040
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (54) 4d 39 32 30 30 42 2d 53 43 41 51 44 42 5a 44 2d 33 2e 30 2e 33 =
35 30 30 32 35 54 20 20 31 20 20 5b 41 75 67 20 31 31 20 32 30 31 31 20 30 =
32 3a 30 30 3a 30 30 5d   M9200B-SCAQDBZD-3.0.350025T  1  [Aug 11 2011 02:0=
0:00]


This is while having an open connection and sending traffic over it (not
that that should matter, but anyway..)

> Huawei writes custom firmware for their dongles.=20

Somehow I find that hard to believe.  I can believe that they *build* a
custom firmware, enabling a vendor specific set of options, setting
their own USB descriptors etc.  And maybe even write some vendor
specific feature.  But I would be surprised if most of their firmware
code didn't come directly from the chipset vendor example code.

And the same goes for every other dongle maker.

> Gobi devices and other
> devices that talk QMI don't  necessarily have such a full quite of AT
> commands, yet they all talk the same QMI protocol.  It makes sense to
> have a generic driver for this if we can.  That probably means a QMI
> core (like you've got with the qmi_wwan stuff) and device-specific
> drives.  The Huawei device would use the ECM-like stuff while the Gobi
> bits would implement what gobi_net does.  They might even be almost the
> same, I haven't looked in a while.  But they are similar enough that
> they should be sharing most of the code.

Yes, I absolutely agree. That's why I tried to keep the qmi specific
code as driver agnostic as possible.  Well, I could probably have done
better, but it's a start..



Bj=C3=B8rn


--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-qmi_wwan-allow-QMI-proxying-via-netdev-ioctl.patch
Content-Transfer-Encoding: quoted-printable

>From 250a8a1214ffb80bfc93e7d93f01796564dabd24 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 16 Dec 2011 16:31:43 +0100
Subject: [PATCH] qmi_wwan: allow QMI proxying via netdev ioctl
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Proxy QMI requests received via ioctl to embedded CDC commands, and
return the embedded CDC responses.  Will not allow QMI_CTL commands.
Shared subsystem client IDs are allocated on-demand by the driver.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi.c           |  118 +++++++++++++++++++++++++++++++++++=
++++
 drivers/net/usb/qmi.h           |    6 ++
 drivers/net/usb/qmi_wwan_core.c |   60 ++++++++++++++++++++
 3 files changed, 184 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/qmi.c b/drivers/net/usb/qmi.c
index 78269a3..b3c022b 100644
--- a/drivers/net/usb/qmi.c
+++ b/drivers/net/usb/qmi.c
@@ -459,6 +459,10 @@ static int qmi_ctl_request_cid(struct qmi_state *qmi, =
u8 system)
 	u8 tlvdata[1] =3D { system };
 	char buf[32];
=20
+	/* fail if we have no slot for the cid */
+	if (system >=3D sizeof(qmi->cid))
+		return -1;
+
 	/* return immediately if a CID is already allocated */
 	if (qmi->cid[system])
 		return qmi->cid[system];
@@ -579,6 +583,120 @@ static int qmi_dms_verify_pin(struct qmi_state *qmi)
=20
 /* ----- exported API ----- */
=20
+/* proxy QMI requests, using our own client and transaction IDs */
+int qmi_ioctl_proxy(struct qmi_state *qmi, void __user *arg, size_t buflen)
+{
+	char *buf;
+	struct qmux *h;
+	struct qmi_msg *m;
+	size_t len;
+	u8 ucid;
+	__le16 utid, tid;
+	unsigned long flags =3D qmi->flags;
+	int ret =3D -EFAULT;
+	int timeout =3D 30;
+
+	/* we don't allow QMI_CTL, so the minimum QMI message size is: */
+	if (buflen < sizeof(*buf) + sizeof(*m))
+                return -EINVAL;
+
+
+	buf =3D kmalloc(buflen, GFP_ATOMIC);
+	if (!buf)
+		return -ENOMEM;
+
+	if (copy_from_user(buf, arg, buflen))
+		goto error;
+
+	/* verify that what we got is a valid QMI message and that we have a CID =
for the system */
+	h =3D (struct qmux *)buf;
+	len =3D h->len + 1; /* total QMUX length including the tf byte */
+
+
+
+	/* sanity.  Note that we disallow the QMI_CTL subsystem */
+	if (h->tf !=3D 0x01 || len > buflen || h->service =3D=3D QMI_CTL) {
+		ret =3D -EINVAL;
+		goto error;
+	}
+
+	m =3D (struct qmi_msg *)h->msg;
+
+	/* require an exact length match */
+	if (sizeof(*h) + sizeof(*m) + m->len !=3D len) {
+		ret =3D -EINVAL;
+		goto error;
+	}
+
+	/* attempt to get a client ID for the requested subsystem */
+	if (qmi_ctl_request_cid(qmi, h->service) < 0)
+		goto error;
+
+	/* use our private cid and tid, saving the user's so that we can restore =
them on return */
+	ucid =3D h->qmicid;
+	utid =3D h->tid.w;
+	tid =3D new_tid();
+	h->qmicid =3D qmi->cid[h->service];
+	h->tid.w =3D tid;
+
+	/* turn off async reads and send the request */
+	qmi->flags &=3D ~QMI_FLAG_RECV;
+	if (usb_control_msg(qmi->dev, usb_sndctrlpipe(qmi->dev, 0),
+				USB_CDC_SEND_ENCAPSULATED_COMMAND,
+				USB_DIR_OUT|USB_TYPE_CLASS|USB_RECIP_INTERFACE,
+				0, qmi->intfnr, buf, len, 1000) !=3D len)
+		goto error;
+
+	/* read the reply into the same buffer */
+
+	/* wait a while for the (correct) reply */
+	do {
+		ret =3D usb_control_msg(qmi->dev, usb_rcvctrlpipe(qmi->dev, 0),
+			       USB_CDC_GET_ENCAPSULATED_RESPONSE, USB_DIR_IN|USB_TYPE_CLASS|USB=
_RECIP_INTERFACE,
+			       0, qmi->intfnr, buf, buflen, 1000);
+		if (ret < 0)
+			goto error;
+=09=09
+		m =3D qmi_qmux_verify(buf, ret);
+		if (m && h->tid.w =3D=3D tid) /* got it */
+			break;
+
+		/* handle other packets returned while waiting for the correct one */
+		if (ret && m) {
+			switch (h->service) {
+			case QMI_CTL:
+				qmi_ctl_parse(qmi, m);
+				break;
+			case QMI_WDS:
+				qmi_wds_parse(qmi, m);
+				break;
+			case QMI_DMS:
+				qmi_dms_parse(qmi, m);
+			}
+			if (qmi_debug)
+				qmi_dump_qmux(qmi, buf, h->len + 1);
+		}
+		msleep(100);
+	} while (timeout-- > 0);
+	if (timeout =3D=3D 0)
+		goto error;
+
+	/* restore the users input to hide our internal id's */
+	h->qmicid =3D ucid;
+	h->tid.w =3D utid;
+
+	/* return the reply to the user */
+	if (copy_to_user(arg, buf, h->len + 1))
+		goto error;
+
+	ret =3D 0;
+
+error:
+	qmi->flags =3D flags;
+	kfree(buf);
+	return ret;
+}
+
 int qmi_reset(struct qmi_state *qmi)
 {
 	/* NOTE:  We do NOT clear the allocated CIDs! */
diff --git a/drivers/net/usb/qmi.h b/drivers/net/usb/qmi.h
index 53ebafe..bf9c8fd 100644
--- a/drivers/net/usb/qmi.h
+++ b/drivers/net/usb/qmi.h
@@ -82,6 +82,12 @@ struct qmi_tlv_response_data {
 } __packed;
=20
=20
+/* <linux/if.h> extension */
+#define IF_IFACE_WWAN 0x1042
+
+/* proxy QMI requests via ioctl */
+extern int qmi_ioctl_proxy(struct qmi_state *qmi, void __user *arg, size_t=
 buflen);
+
 /* reset state to INIT */
 extern int qmi_reset(struct qmi_state *qmi);
=20
diff --git a/drivers/net/usb/qmi_wwan_core.c b/drivers/net/usb/qmi_wwan_cor=
e.c
index 6d96465..79c3b1a 100644
--- a/drivers/net/usb/qmi_wwan_core.c
+++ b/drivers/net/usb/qmi_wwan_core.c
@@ -8,6 +8,7 @@
=20
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/usb.h>
@@ -46,6 +47,57 @@ static void qmi_wwan_cdc_status(struct usbnet *dev, stru=
ct urb *urb)
 	}
 }
=20
+static int qmi_wwan_ioctl(struct net_device *net, struct ifreq *ifr, int c=
md)
+{
+        struct usbnet *dev =3D netdev_priv(net);
+	struct if_settings *settings =3D &ifr->ifr_settings;
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	switch (cmd) {
+	case SIOCDEVPRIVATE + 0: /* get something to verify that the private ioct=
l protocol */
+		/* FIMXE: implement this! */
+		return 0;
+
+	case SIOCDEVPRIVATE + 1: /* set SIM PIN */
+		/* FIMXE: implement this! */
+		return 0;
+
+	case SIOCDEVPRIVATE + 2: /* set APN */
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		/* cannot change APN if interface is up */
+		if (net->flags & IFF_UP)
+			return -EBUSY;
+
+		/* FIMXE: implement this! */
+		return 0;
+
+	case SIOCDEVPRIVATE + 3: /* proxy QMI */
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (settings->type !=3D IF_IFACE_WWAN)
+			return -EINVAL;
+		netdev_dbg(net, "proxying userspace QMI request\n");
+		return qmi_ioctl_proxy(info->qmi, settings->ifs_ifsu.fr, settings->size);
+=09=09
+	default:
+		netdev_dbg(net, "ioctl 0x%08x\n", cmd);
+	}
+        return -EINVAL;
+}
+
+/* same as usbnet_netdev_ops but ioctl added */
+static const struct net_device_ops qmi_wwan_netdev_ops =3D {
+        .ndo_open               =3D usbnet_open,
+        .ndo_stop               =3D usbnet_stop,
+        .ndo_start_xmit         =3D usbnet_start_xmit,
+        .ndo_tx_timeout         =3D usbnet_tx_timeout,
+        .ndo_set_mac_address    =3D eth_mac_addr,
+        .ndo_validate_addr      =3D eth_validate_addr,
+        .ndo_do_ioctl           =3D qmi_wwan_ioctl,
+};
+
 static int qmi_wwan_cdc_ecmlike_bind(struct usbnet *dev, struct usb_interf=
ace *intf)
 {
 	int status;
@@ -61,6 +113,10 @@ static int qmi_wwan_cdc_ecmlike_bind(struct usbnet *dev=
, struct usb_interface *i
 		usbnet_cdc_unbind(dev, intf);
 		return -1;
 	}
+
+	/* override default usbnet ops so that we can handle ioctls */
+        dev->net->netdev_ops =3D &qmi_wwan_netdev_ops;
+
 	return 0;
 }
=20
@@ -80,6 +136,10 @@ static int qmi_wwan_cdc_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 		return -1;
=20
 	info->control =3D intf;
+
+	/* override default usbnet ops so that we can handle ioctls */
+        dev->net->netdev_ops =3D &qmi_wwan_netdev_ops;
+
 	return 0;
 }
=20
--=20
1.7.7.3


--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
