From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] qmi_wwan: Driver for WWAN devices requiring use of
 the QMI protocol
Date: Wed, 14 Dec 2011 11:08:21 -0600
Message-ID: <1323882501.2077.3.camel@dcbw.foobar.com>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
	 <1323750784-32608-4-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bjorn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323750784-32608-4-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-12-13 at 05:33 +0100, Bjorn Mork wrote:
> From: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>=20
> Some WWAN LTE/3G devices based on chipsets from Qualcomm provide
> near standard CDC ECM interfaces in addition to the usual serial
> interfaces.  But they cannot be fully configured using AT commands
> over a serial interface.  It is necessary to speak the proprietary
> Qualcomm Messaging Interface (QMI) protocol to the device to
> enable the ethernet proxy functionality.
>=20
> This protocol is exposed by the device through the standard CDC
> USB_CDC_SEND_ENCAPSULATED_COMMAND and USB_CDC_GET_ENCAPSULATED_RESPON=
SE
> control messages, and using USB_CDC_NOTIFY_RESPONSE_AVAILABLE
> notifications.
>=20
> This driver adds a usbnet minidriver with very rudimentary QMI
> support.
>=20
> The layout of the usb interfaces can vary a lot within a single
> device, depending on which "modeswitch" command has been used to
> switch it from usb-storage mode.  Control and data interfaces
> can be combined, or they can look like standard CDC ECM interfaces
> with the appropriate descriptors but with vendor specific class
> code. This driver is attempting to support them all, by reusing
> as much as possible of the existing usbnet infrastructure.

So I thought the protocol acronym stood for "Qualcomm MSM/Modem
Interface"  (see
https://www.codeaurora.org/gitweb/quic/le/?p=3Dkernel/msm.git;a=3Dcommi=
tdiff;h=3D5f6f87b51184e13b6c493012de787895d5d18765)

In any case, great work here.  But I'm a bit concerned about how all
this should fit together.  QMI is a huge protocol that does everything =
a
modem would ever want to do, and we'd likely want to be able to speak
QMI from userspace to the modem too so that modem managers can expose
the full functionality of the modems.  For example Gobi modems have a
very minimal AT command set and most of the functionality is exposed
over QMI or DM.  That's why the Qualcomm GobiNet driver also
exposed /dev/qmi for userspace access.

Second, does the modem actually respond to DHCP over the ECM interface?
If you take a look at the Android rmnet code (which is similar to your
driver) you'll see they extract the IP address and DNS details from the
QMI response.  Do we need to do that here too?

Dan

> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
>  drivers/net/usb/Kconfig         |   13 +
>  drivers/net/usb/Makefile        |    2 +
>  drivers/net/usb/qmi.c           |  730 +++++++++++++++++++++++++++++=
++++++++++
>  drivers/net/usb/qmi.h           |  101 ++++++
>  drivers/net/usb/qmi_wwan_core.c |  206 +++++++++++
>  5 files changed, 1052 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/usb/qmi.c
>  create mode 100644 drivers/net/usb/qmi.h
>  create mode 100644 drivers/net/usb/qmi_wwan_core.c
>=20
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 2335761..eed9a37 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -461,4 +461,17 @@ config USB_VL600
> =20
>  	  http://ubuntuforums.org/showpost.php?p=3D10589647&postcount=3D17
> =20
> +config USB_NET_QMI_WWAN
> +	tristate "USB-to-WWAN driver for QMI based 3G and LTE modems"
> +	depends on USB_NET_CDCETHER
> +	help
> +	  Support WWAN LTE/3G devices based on chipsets from Qualcomm,
> +	  using the Qualcomm Messaging Interface (QMI) protocol to
> +	  configure the device.
> +
> +	  Note that it is still necessary to configure some aspects of
> +	  the device using AT commands on a tty.  Select the option
> +	  driver to get this support.
> +
> +
>  endmenu
> diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
> index c203fa2..ed715da 100644
> --- a/drivers/net/usb/Makefile
> +++ b/drivers/net/usb/Makefile
> @@ -29,4 +29,6 @@ obj-$(CONFIG_USB_SIERRA_NET)	+=3D sierra_net.o
>  obj-$(CONFIG_USB_NET_CX82310_ETH)	+=3D cx82310_eth.o
>  obj-$(CONFIG_USB_NET_CDC_NCM)	+=3D cdc_ncm.o
>  obj-$(CONFIG_USB_VL600)		+=3D lg-vl600.o
> +obj-$(CONFIG_USB_NET_QMI_WWAN)	+=3D qmi_wwan.o
> +qmi_wwan-objs :=3D qmi_wwan_core.o qmi.o
> =20
> diff --git a/drivers/net/usb/qmi.c b/drivers/net/usb/qmi.c
> new file mode 100644
> index 0000000..b4f6a4b
> --- /dev/null
> +++ b/drivers/net/usb/qmi.c
> @@ -0,0 +1,730 @@
> +/*
> + * Copyright (c) 2011  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + */
> +
> +/*
> + * Dealing with devices using Qualcomm Messaging Interface (QMI) for
> + * configuration.  Full documentation of the protocol can be obtaine=
d
> + * from http://developer.qualcomm.com/
> + *
> + * Some of this code may be inspired by code from the Qualcomm Gobi
> + * 2000 and Gobi 3000 drivers, available at http://www.codeaurora.or=
g/
> + */
> +
> +#include <linux/module.h>
> +#include <linux/slab.h>
> +#include <linux/usb.h>
> +#include <linux/usb/cdc.h>
> +#include "qmi.h"
> +
> +
> +/* QMI protocol debug output */
> +static int qmi_debug;
> +module_param(qmi_debug, int, 0);
> +MODULE_PARM_DESC(qmi_debug, "Enable QMI protocol debugging");
> +
> +/* find and return a pointer to the requested tlv */
> +struct qmi_tlv *qmi_get_tlv(u8 type, u8 *buf, size_t len)
> +{
> +	u8 *p;
> +	struct qmi_tlv *t;
> +
> +	for (p =3D buf; p < buf + len; p +=3D t->len + sizeof(struct qmi_tl=
v)) {
> +		t =3D (struct qmi_tlv *)p;
> +		if (t->type =3D=3D type)
> +			return (p + t->len <=3D buf + len) ? t : NULL;
> +	}
> +	return NULL;
> +}
> +
> +
> +/* TLV 0x02 is status: return a negative QMI error code or 0 if OK *=
/
> +int qmi_verify_status_tlv(u8 *buf, size_t len)
> +{
> +	struct qmi_tlv *tlv =3D (void *)qmi_get_tlv(0x02, buf, len);
> +	struct qmi_tlv_response_data *r =3D (void *)tlv->bytes;
> +
> +	if (!tlv || tlv->len !=3D 2 * sizeof(__le16))
> +		return -1; /* QMI_ERR_MALFORMED_MSG */
> +
> +	return r->error ? -r->code : 0;
> +}
> +
> +static char *decode_trans_flags(const u8 flags)
> +{
> +	switch (flags) {
> +	case 0: return "request";
> +	case 2:	return "response";
> +	case 4:	return "indication";
> +	case 6:	return "reserved";
> +	default: return "invalid";
> +	}
> +}
> +
> +static char *qmi_system(u8 system)
> +{
> +	switch (system) {
> +	case 0:	return "QMI_CTL";
> +	case 1:	return "QMI_WDS";
> +	case 2:	return "QMI_DMS";
> +	default: return "(unknown)";
> +	}
> +}
> +
> +
> +/* debug print TLVs from a QMI message */
> +static void qmi_tlv_dump(struct qmi_state *qmi, u8 *data, size_t len=
, u8 system, __le16 msgid)
> +{
> +	u8 *p;
> +	struct qmi_tlv *t;
> +	char linebuf[100];
> +
> +	for (p =3D data; p < data + len; p +=3D t->len + sizeof(struct qmi_=
tlv)) {
> +		t =3D (struct qmi_tlv *)p;
> +
> +		/* mark an empty string */
> +		linebuf[0] =3D 0;
> +		if (t->type =3D=3D 0x02) { /* status response */
> +			struct qmi_tlv_response_data *r =3D (void *)t->bytes;
> +			snprintf(linebuf, sizeof(linebuf), "%s (0x%04x)",
> +				r->error ? "FAILED" : "SUCCESS", r->code);
> +		} else {
> +			switch (system) {
> +			case QMI_WDS:
> +				switch (msgid) {
> +				case 0x0001:
> +					switch (t->type) {
> +					case 0x16:
> +						snprintf(linebuf, sizeof(linebuf), "tx: %d bps, rx: %d bps",
> +							*(__le32 *)t->bytes, *(__le32 *)(t->bytes + 4));
> +					}
> +				}
> +				break;
> +			case QMI_DMS:
> +				switch (msgid) {
> +				case 0x002b:
> +					if (t->type =3D=3D 0x11 || t->type =3D=3D 0x12)
> +						snprintf(linebuf, sizeof(linebuf),
> +							"PIN%d status=3D%d, %d verify retries left, %d unblock retrie=
s left",
> +							t->type & 0x3, t->bytes[0], t->bytes[1], t->bytes[2]);
> +				}
> +			}
> +		}
> +
> +		/* do a default byte dump if the linebuf is empty */
> +		if (linebuf[0] =3D=3D 0)
> +			hex_dump_to_buffer(t->bytes, t->len, 16, 1, linebuf, sizeof(lineb=
uf), true);
> +
> +		dev_info(&qmi->dev->dev, "[0x%02x] (%d) %s\n", t->type, t->len, li=
nebuf);
> +	}
> +}
> +
> +/* verify QMUX message header and return pointer to the (first) mess=
age if OK */
> +static struct qmi_msg *qmi_qmux_verify(u8 *data, size_t len)
> +{
> +	struct qmux *h =3D  (void *)data;
> +	struct qmi_msg *m;
> +	ssize_t hsize =3D sizeof(struct qmux);
> +
> +	if (len < sizeof(struct qmux) || /* short packet */
> +		h->tf !=3D 0x01 || h->len !=3D (len - 1)) /* invalid QMUX packet! =
*/
> +		return NULL;
> +
> +	/* tid has a different size for QMI_CTL for some fucking stupid rea=
son */
> +	if (h->service =3D=3D QMI_CTL)
> +		hsize--;
> +
> +	m =3D (struct qmi_msg *)(data + hsize);
> +
> +	/* insanity checking before any further dereferencing... */
> +	if (hsize + sizeof(struct qmi_msg) + m->len > len)
> +		return NULL;
> +
> +	return m;
> +}
> +
> +/* debug print a QMUX packet */
> +static void qmi_dump_qmux(struct qmi_state *qmi, u8 *data, size_t le=
n)
> +{
> +	struct qmux *h =3D  (void *)data;
> +	struct qmi_msg *m;
> +
> +	m =3D qmi_qmux_verify(data, len);
> +	if (!m) {
> +		dev_info(&qmi->dev->dev, "invalid QMUX packet (%zu bytes)\n", len)=
;
> +		return;
> +	}
> +
> +	/* dump parts of the QMUX header and the message ID */
> +	dev_info(&qmi->dev->dev, "%s %s: msg 0x%04x (len %d) from \"%s\" wi=
th cid=3D0x%02x%s and TLVs:\n",
> +		qmi_system(h->service),
> +		decode_trans_flags(h->service =3D=3D QMI_CTL ? h->flags << 1 : h->=
flags),
> +		m->msgid,
> +		h->len,
> +		h->ctrl & 0x80 ? "service" : "control point",
> +		h->qmicid, h->qmicid =3D=3D 0xff ? " (broadcast)" : "");
> +
> +	/* dump the TLVs */
> +	qmi_tlv_dump(qmi, m->tlv, m->len, h->service, m->msgid);
> +}
> +
> +static int qmi_dms_parse(struct qmi_state *qmi, struct qmi_msg *m)
> +{
> +	int status;
> +	struct qmi_tlv *tlv;
> +
> +	if (!m)
> +		return -1;
> +
> +	/* check and save status TLV */
> +	status =3D qmi_verify_status_tlv(m->tlv, m->len);
> +
> +	/* no QMI_DMS messages requires parsing unless status is OK */
> +	if (status < 0)
> +		return status;
> +
> +	switch (m->msgid) {
> +	case 0x002b: /* QMI_DMS_UIM_GET_PIN_STATUS */
> +		if (status =3D=3D 0) {
> +			/* PIN1 status */
> +			tlv =3D qmi_get_tlv(0x11, m->tlv, m->len);
> +			if (tlv && tlv->len =3D=3D 3) {
> +				switch (tlv->bytes[0]) {
> +				case 2: /* PIN enabled, verified */
> +				case 3: /* PIN disabled */
> +					qmi->flags |=3D QMI_FLAG_PINOK;
> +				}
> +			}
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int qmi_ctl_parse(struct qmi_state *qmi, struct qmi_msg *m)
> +{
> +	int status;
> +	struct qmi_tlv *tlv;
> +
> +	if (!m)
> +		return -1;
> +
> +	/* check and save status TLV */
> +	status =3D qmi_verify_status_tlv(m->tlv, m->len);
> +
> +	if (status < 0)
> +		return status;
> +
> +	/* TLVs are message dependent */
> +	switch (m->msgid) {
> +	case 0x0022: /* allocate cid */
> +		/* TLV 0x01 is system + cid */
> +		tlv =3D qmi_get_tlv(0x01, m->tlv, m->len);
> +
> +		/* can only save CID if there is a slot for the subsystem */
> +		if (tlv && tlv->len =3D=3D 2 && tlv->bytes[0] < sizeof(qmi->cid))
> +			qmi->cid[tlv->bytes[0]] =3D tlv->bytes[1];
> +		else
> +			return -1;
> +	}
> +
> +	return status;
> +}
> +
> +static int qmi_wds_parse(struct qmi_state *qmi, struct qmi_msg *m)
> +{
> +	int status;
> +	struct qmi_tlv *tlv;
> +
> +	if (!m)
> +		return -1;
> +
> +	/* check and save status TLV */
> +	status =3D qmi_verify_status_tlv(m->tlv, m->len);
> +
> +	if (m->msgid =3D=3D 0x0020 && -status =3D=3D 0x001A) { /* QMI_ERR_N=
O_EFFECT */
> +		memset(qmi->handle, 0xff, sizeof(qmi->handle)); /* global handle *=
/
> +		return 0;
> +	}
> +
> +	if (status < 0)
> +		return status;
> +
> +	switch (m->msgid) {
> +	case 0x0020: /* QMI_WDS_START_NETWORK_INTERFACE */
> +		/* TLV 0x01 is a 4 byte packet data handle we need to keep */
> +		tlv =3D qmi_get_tlv(0x01, m->tlv, m->len);
> +		if (tlv && tlv->len =3D=3D sizeof(qmi->handle))
> +			memcpy(qmi->handle, tlv->bytes, sizeof(qmi->handle));
> +
> +		break;
> +
> +	case 0x0022: /* QMI_WDS_GET_PKT_SRVC_STATUS */
> +		/* TLV 0x01 is a 1 byte connection status */
> +		tlv =3D qmi_get_tlv(0x01, m->tlv, m->len);
> +		if (tlv && tlv->len =3D=3D 1)
> +			qmi->wds_status =3D tlv->bytes[0];
> +
> +	}
> +
> +	return status;
> +}
> +
> +static void qmi_read_callback(struct urb *urb)
> +{
> +	struct qmi_state *qmi =3D (void *)urb->context;
> +
> +	if (urb->status =3D=3D 0) {
> +		struct qmux *h =3D (void *)urb->transfer_buffer;
> +		struct qmi_msg *m =3D qmi_qmux_verify(urb->transfer_buffer, urb->a=
ctual_length);
> +
> +		switch (h->service) {
> +		case QMI_CTL:
> +			qmi_ctl_parse(qmi, m);
> +			break;
> +		case QMI_WDS:
> +			qmi_wds_parse(qmi, m);
> +			break;
> +		case QMI_DMS:
> +			qmi_dms_parse(qmi, m);
> +		}
> +
> +		if (qmi_debug)
> +			qmi_dump_qmux(qmi, urb->transfer_buffer, urb->actual_length);
> +	}
> +}
> +
> +static int qmi_recv_sync(struct qmi_state *qmi)
> +{
> +	int status;
> +
> +	status =3D usb_control_msg(qmi->dev,
> +			       usb_rcvctrlpipe(qmi->dev, 0),
> +			       USB_CDC_GET_ENCAPSULATED_RESPONSE, USB_DIR_IN|USB_TYPE_CLA=
SS|USB_RECIP_INTERFACE,
> +			       0, qmi->intfnr,
> +			       qmi->rcvbuf, QMI_BUFLEN, 1000);
> +
> +	if (status > 0 && qmi_debug)
> +		qmi_dump_qmux(qmi, qmi->rcvbuf, status);
> +
> +	return status;
> +}
> +
> +static int qmi_send_sync(struct qmi_state *qmi, unsigned char *msg, =
size_t len)
> +{
> +	int status;
> +
> +	status =3D usb_control_msg(qmi->dev,
> +				usb_sndctrlpipe(qmi->dev, 0),
> +				USB_CDC_SEND_ENCAPSULATED_COMMAND, USB_DIR_OUT|USB_TYPE_CLASS|US=
B_RECIP_INTERFACE,
> +				0, qmi->intfnr,
> +				msg, len, 1000);
> +
> +	if (qmi_debug) /* NOTE: regardless of status! */
> +		qmi_dump_qmux(qmi, msg, len);
> +
> +	return status;
> +}
> +
> +/* send message and wait for the reply - returns pointer to reply me=
ssage */
> +struct qmi_msg *qmi_send_and_wait_for_ack(struct qmi_state *qmi, uns=
igned char *data, size_t len, int timeout)
> +{
> +	int ret;
> +	u8 system;
> +	__le16 msgid;
> +	struct qmi_msg *msg =3D qmi_qmux_verify(data, len);
> +	struct qmux *h =3D (void *)data;
> +
> +	/* should never happen? */
> +	if (!msg)
> +		return NULL;
> +	msgid =3D msg->msgid;
> +	system =3D h->service;
> +
> +	/* flush any pending messages  */
> +	do {
> +		ret =3D qmi_recv_sync(qmi);
> +	} while (ret > 0);
> +
> +	/* send our message */
> +	ret =3D qmi_send_sync(qmi, data, len);
> +	if (ret !=3D len)
> +		return NULL;
> +
> +	/* wait a while for the (correct) reply */
> +	do {
> +		ret =3D qmi_recv_sync(qmi);
> +		msg =3D qmi_qmux_verify(qmi->rcvbuf, ret);
> +		if (msg) {
> +			h =3D (struct qmux *)qmi->rcvbuf;
> +			if (msg->msgid =3D=3D msgid && h->service =3D=3D system) /* found=
 it */
> +				return msg;
> +
> +		}
> +		if (timeout--)
> +			msleep(100);
> +	} while (timeout > 0);
> +
> +	/* no reply */
> +	return NULL;
> +}
> +
> +/* add a TLV to an existing QMUX */
> +static size_t qmi_add_tlv(u8 *buf, size_t buflen, u8 type, const u8 =
*tlvdata, size_t datalen)
> +{
> +	struct qmux *h =3D  (void *)buf;
> +	struct qmi_msg *m =3D (void *)(buf + sizeof(struct qmux) - (h->serv=
ice =3D=3D QMI_CTL));
> +	struct qmi_tlv *tlv =3D (void *)(buf + h->len + 1);
> +	size_t tlvlen =3D sizeof(struct qmi_tlv) + datalen;
> +
> +	if (buflen < h->len + tlvlen - 1)
> +		return -1;
> +
> +	tlv->type =3D type;
> +	tlv->len =3D datalen;
> +	memcpy(tlv->bytes, tlvdata, datalen);
> +	h->len +=3D tlvlen;
> +	m->len +=3D tlvlen;
> +	return h->len + 1;
> +}
> +
> +/* get a new transaction id */
> +static __le16 new_tid(void)
> +{
> +	static __le16 tid;
> +	return ++tid;
> +}
> +
> +/* assemble a complete QMUX packet with one QMI message */
> +static size_t qmi_create_msg(char *buf, size_t buflen, u8 cid, u8 sy=
stem, __le16 msgid)
> +{
> +	struct qmux *h =3D  (void *)buf;
> +	struct qmi_msg *m;
> +	size_t hsize =3D sizeof(struct qmux);
> +
> +	/* this is weird, but it seems as though QMI_CTL uses 1 byte
> +	   transaction ids while the other systems use 2 bytes as specified
> +	   in the standard */
> +	if (system =3D=3D QMI_CTL)
> +		hsize--;
> +
> +	/* sanity check */
> +	if (buflen < hsize + sizeof(struct qmi_msg))
> +		return -1;
> +
> +	h->tf =3D 1;     /* always 1 */
> +	h->ctrl =3D 0;   /* 0 - control point */
> +	h->service =3D system;
> +	h->qmicid =3D cid;
> +	h->flags =3D 0;  /* 0 - request */
> +
> +	/* see comment above */
> +	if (system =3D=3D QMI_CTL)
> +		h->tid.b =3D new_tid() & 0xff;
> +	else
> +		h->tid.w =3D new_tid();
> +
> +	m =3D (struct qmi_msg *)(buf + hsize);
> +	m->msgid =3D msgid;
> +
> +	h->len =3D hsize + sizeof(struct qmi_msg)  - 1;
> +	m->len =3D 0;
> +	return h->len + 1;
> +}
> +
> +/* QMI_CTL msg 0x0022 is "request cid", TLV 0x01 is system */
> +static int qmi_ctl_request_cid(struct qmi_state *qmi, u8 system)
> +{
> +	size_t len;
> +	u8 tlvdata[1] =3D { system };
> +	char buf[32];
> +
> +	/* return immediately if a CID is already allocated */
> +	if (qmi->cid[system])
> +		return qmi->cid[system];
> +
> +	/* else request a new one */
> +	len =3D qmi_create_msg(buf, sizeof(buf), 0, QMI_CTL, 0x0022);
> +	len =3D qmi_add_tlv(buf, sizeof(buf), 0x01, tlvdata, sizeof(tlvdata=
));
> +
> +	/* send message */
> +	return qmi_ctl_parse(qmi, qmi_send_and_wait_for_ack(qmi, buf, len, =
30));
> +}
> +
> +/* QMI_WDS msg 0x0001 is "" */
> +static int qmi_wds_report(struct qmi_state *qmi)
> +{
> +	size_t len;
> +	u8 cid =3D qmi->cid[QMI_WDS];
> +	u8 tlvdata[1] =3D { 1 };	/* generic "enable" */
> +	char buf[32];
> +
> +	/* enable connection status reports */
> +	len =3D qmi_create_msg(buf, sizeof(buf), cid, QMI_WDS, 0x0001);
> +	len =3D qmi_add_tlv(buf, sizeof(buf), 0x10, tlvdata, sizeof(tlvdata=
));	/* current channel rate */
> +	len =3D qmi_add_tlv(buf, sizeof(buf), 0x15, tlvdata, sizeof(tlvdata=
));	/* current data bearer tech */
> +
> +	/* send message */
> +	return qmi_wds_parse(qmi, qmi_send_and_wait_for_ack(qmi, buf, len, =
30));
> +}
> +
> +/* QMI_WDS msg 0x0020 is "" */
> +static int qmi_wds_start(struct qmi_state *qmi)
> +{
> +	size_t len;
> +	u8 cid =3D qmi->cid[QMI_WDS];
> +	char buf[32];
> +
> +	if (!cid)
> +		return -1;
> +
> +	len =3D qmi_create_msg(buf, sizeof(buf), cid, QMI_WDS, 0x0020);
> +
> +	/* send message */
> +	return qmi_wds_parse(qmi, qmi_send_and_wait_for_ack(qmi, buf, len, =
30));
> +}
> +
> +/* QMI_WDS msg 0x0021 is "" */
> +static int qmi_wds_stop(struct qmi_state *qmi)
> +{
> +	size_t len;
> +	u8 cid =3D qmi->cid[QMI_WDS];
> +	char buf[32];
> +
> +	if (!cid)
> +		return -1;
> +
> +	len =3D qmi_create_msg(buf, sizeof(buf), cid, QMI_WDS, 0x0021);
> +	len =3D qmi_add_tlv(buf, sizeof(buf), 0x01, qmi->handle, sizeof(qmi=
->handle));	 /* packet data handle */
> +
> +	return qmi_wds_parse(qmi, qmi_send_and_wait_for_ack(qmi, buf, len, =
30));
> +}
> +
> +/* QMI_WDS msg 0x0022 is "" */
> +static int qmi_wds_status(struct qmi_state *qmi)
> +{
> +	int ret;
> +	size_t len;
> +	u8 cid =3D qmi->cid[QMI_WDS];
> +	char buf[32];
> +
> +	if (!cid)
> +		return -1;
> +
> +	len =3D qmi_create_msg(buf, sizeof(buf), cid, QMI_WDS, 0x0022);
> +
> +	ret =3D qmi_wds_parse(qmi, qmi_send_and_wait_for_ack(qmi, buf, len,=
 30));
> +	if (ret < 0)
> +		return ret;
> +
> +	return qmi->wds_status;
> +}
> +
> +/* QMI_CTL msg 0x0023 is "release cid", TLV 0x01 is system + cid */
> +static int qmi_ctl_release_cid(struct qmi_state *qmi, u8 system)
> +{
> +	char buf[32];
> +	size_t len =3D qmi_create_msg(buf, sizeof(buf), 0, QMI_CTL, 0x0023)=
;
> +
> +	if (system < sizeof(qmi->cid)) {
> +		u8 tlvdata[2] =3D { system, qmi->cid[system] };
> +		len =3D qmi_add_tlv(buf, sizeof(buf), 0x01, tlvdata, sizeof(tlvdat=
a));
> +
> +	} else {
> +		return -1;
> +	}
> +
> +	/* no need to parse result - cant reuse CID in any case */
> +	qmi_send_and_wait_for_ack(qmi, buf, len, 30);
> +	qmi->cid[system] =3D 0;
> +
> +	return 1;
> +}
> +
> +static int qmi_dms_verify_pin(struct qmi_state *qmi)
> +{
> +	int ret;
> +	size_t len;
> +	u8 cid =3D qmi->cid[QMI_DMS];
> +	char buf[32];
> +
> +	if (!cid)
> +		return -1;
> +
> +	len =3D qmi_create_msg(buf, sizeof(buf), cid, QMI_DMS, 0x002b);
> +	ret =3D qmi_dms_parse(qmi, qmi_send_and_wait_for_ack(qmi, buf, len,=
 30));
> +	return qmi->flags && QMI_FLAG_PINOK;
> +}
> +
> +
> +/* ----- exported API ----- */
> +
> +int qmi_reset(struct qmi_state *qmi)
> +{
> +	/* NOTE:  We do NOT clear the allocated CIDs! */
> +	qmi->state =3D QMI_STATE_INIT;
> +	qmi->wds_status =3D 0;
> +	qmi->flags =3D 0;
> +	return 1;
> +}
> +
> +int qmi_disconnect(struct qmi_state *qmi)
> +{
> +	qmi->flags &=3D ~QMI_FLAG_RECV;         /* disable async receiving =
*/
> +	qmi_wds_stop(qmi);
> +	qmi_wds_status(qmi);
> +	qmi->state =3D QMI_STATE_DOWN;
> +	return 1;
> +}
> +
> +/* receive a QMUX can be called in interrupt context! */
> +int qmi_recv(struct qmi_state *qmi)
> +{
> +	if (qmi->flags & QMI_FLAG_RECV) /* async receiving enabled? */
> +		return usb_submit_urb(qmi->urb, GFP_ATOMIC);
> +	else
> +		return 0;
> +}
> +
> +/*
> + * return current connection state with side effects: will run throu=
gh
> + *  the states from INIT to CONN if possible
> + */
> +int qmi_conn_state(struct qmi_state *qmi)
> +{
> +	int ret;
> +
> +	dev_dbg(&qmi->dev->dev, ".state=3D%d, .cid[QMI_WDS]=3D0x%02x, .cid[=
QMI_DMS]=3D0x%02x, .flags=3D0x%08lx, .handle=3D0x%08x\n",
> +		qmi->state,
> +		qmi->cid[QMI_WDS],
> +		qmi->cid[QMI_DMS],
> +		qmi->flags,
> +		*(__le32 *)qmi->handle);
> +
> +	switch (qmi->state) {
> +	/* these states don't trigger any action */
> +	case QMI_STATE_DOWN:
> +		return 1;
> +	case QMI_STATE_UP:
> +		qmi->flags |=3D QMI_FLAG_RECV;  /* enable async receiving  */
> +		return 0;
> +	case QMI_STATE_ERR:
> +		return -1;
> +
> +	case QMI_STATE_INIT:
> +		qmi->flags &=3D ~QMI_FLAG_RECV;  /* disable async receiving */
> +
> +		/* request CIDs */
> +		if (qmi_ctl_request_cid(qmi, QMI_WDS) < 0 || qmi_ctl_request_cid(q=
mi, QMI_DMS) < 0) {
> +			qmi->state =3D QMI_STATE_ERR; /* FATAL - no way out except for un=
plugging the device */
> +			return -1;
> +		}
> +
> +		/* stay in this state until PIN code is entered */
> +		if (!qmi_dms_verify_pin(qmi)) {
> +			dev_notice(&qmi->dev->dev, "please enter PIN code using AT+CPIN=3D=
\"xxxx\" on a ttyUSB0 device\n");
> +			return 1;
> +		}
> +		/* check status */
> +		switch (qmi_wds_status(qmi)) {
> +		case 1: /* DISCONNECTED - attempt to connect */
> +			ret =3D qmi_wds_start(qmi);
> +			if (ret < 0) {
> +				dev_notice(&qmi->dev->dev, "connection failed: 0x%04x\n", -ret);
> +				break;
> +			}
> +
> +			/* fallthrough */
> +		case 2: /* CONNECTED - note that */
> +			qmi_wds_report(qmi); /* enable status reports */
> +			qmi->state =3D QMI_STATE_UP;
> +
> +		/* do nothing for the other states */
> +		}
> +		break;
> +
> +	default:
> +		dev_dbg(&qmi->dev->dev, "%s() unknown state=3D%d\n", __func__, qmi=
->state);
> +	}
> +	return 1;  /* not connected yet - */
> +}
> +
> +
> +/* allocate and initiate a QMI state device */
> +struct qmi_state *qmi_init(struct usb_interface *intf)
> +{
> +	struct qmi_state *qmi =3D kmalloc(sizeof(struct qmi_state), GFP_KER=
NEL);
> +
> +	if (!qmi)
> +		return NULL;
> +
> +	memset(qmi, 0, sizeof(*qmi));
> +
> +	/*
> +	 * keep track of the device receiving the control messages and the
> +	 * number of the CDC (like) control interface which is our target.
> +	 * Note that the interface might be disguised as vendor specific,
> +	 * and be a combined CDC control/data interface
> +	 */
> +	qmi->dev =3D interface_to_usbdev(intf);
> +	qmi->intfnr =3D intf->cur_altsetting->desc.bInterfaceNumber;
> +	/* FIXME: it would be useful to verify that this interface actually=
 talks CDC */
> +
> +	/* create async receive URB */
> +	qmi->urb =3D usb_alloc_urb(0, GFP_KERNEL);
> +	if (!qmi->urb) {
> +		kfree(qmi);
> +		return NULL;
> +	}
> +
> +	/* pre-allocate buffer for receiving */
> +	qmi->rcvbuf =3D kmalloc(QMI_BUFLEN, GFP_KERNEL);
> +
> +	if (!qmi->rcvbuf) {
> +		usb_free_urb(qmi->urb);
> +		kfree(qmi);
> +		return NULL;
> +	}
> +
> +	/* usb control setup */
> +	qmi->setup.bRequestType =3D USB_DIR_IN|USB_TYPE_CLASS|USB_RECIP_INT=
ERFACE;
> +	qmi->setup.bRequest =3D USB_CDC_GET_ENCAPSULATED_RESPONSE;
> +	qmi->setup.wValue =3D 0; /* zero */
> +	qmi->setup.wIndex =3D qmi->intfnr;
> +	qmi->setup.wLength =3D QMI_BUFLEN;
> +
> +	/* prepare the async receive URB */
> +	usb_fill_control_urb(qmi->urb, qmi->dev,
> +			usb_rcvctrlpipe(qmi->dev, 0),
> +			(char *)&qmi->setup,
> +			qmi->rcvbuf,
> +			QMI_BUFLEN,
> +			qmi_read_callback, qmi);
> +
> +	return qmi;
> +}
> +
> +/* disable and free a QMI state device */
> +int qmi_exit(struct qmi_state *qmi)
> +{
> +	int i;
> +
> +	/* release all CIDs - may need to sleep */
> +	for (i =3D 1; i < sizeof(qmi->cid); i++)
> +		qmi_ctl_release_cid(qmi, i);
> +
> +	/* free all buffers */
> +	kfree(qmi->rcvbuf);
> +
> +	/* free URBs */
> +	usb_free_urb(qmi->urb);
> +
> +	kfree(qmi);
> +
> +	return 0;
> +}
> diff --git a/drivers/net/usb/qmi.h b/drivers/net/usb/qmi.h
> new file mode 100644
> index 0000000..bff94f1
> --- /dev/null
> +++ b/drivers/net/usb/qmi.h
> @@ -0,0 +1,101 @@
> +/*
> + * Copyright (c) 2011  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + */
> +
> +/*
> + * Dealing with devices using Qualcomm Messaging Interface (QMI) for
> + * configuration.  Full documentation of the protocol can be obtaine=
d
> + * from http://developer.qualcomm.com/
> + *
> + * Some of this code may be inspired by code from the Qualcomm Gobi
> + * 2000 and Gobi 3000 drivers, available at http://www.codeaurora.or=
g/
> + */
> +
> +#define QMI_BUFLEN 128
> +
> +enum qmi_device_state {
> +	QMI_STATE_INIT =3D 0, /* allocate CIDs, verify pin code */
> +	QMI_STATE_DOWN,    /* connection is down */
> +	QMI_STATE_UP,      /* connection is up */
> +	QMI_STATE_ERR,     /* fatal and final error state, e.g. no CID avai=
lable - no way out of here! */
> +};
> +
> +/* the different QMI subsystems we are using */
> +enum qmi_subsystems {
> +	QMI_CTL =3D 0,
> +	QMI_WDS,
> +	QMI_DMS,
> +	QMI_SYSMAX,
> +};
> +
> +#define QMI_FLAG_RECV		0x00000001
> +#define QMI_FLAG_PINOK		0x00000002
> +
> +struct qmi_state {
> +	struct usb_device *dev;
> +	struct urb *urb;		/* receive urb */
> +	unsigned char *rcvbuf;		/* pre-allocated receive buffer */
> +	struct usb_ctrlrequest setup;	/* the receive setup - 8 bytes */
> +	unsigned long flags;		/* used for en/dis-abling functionality on th=
e fly */
> +	u8 state;			/* for connection state machine */
> +	u8 wds_status;			/* current value for QMI_WDS message 0x0022 or 0 i=
f uninitialized */
> +	__le16 intfnr;			/* keeping track of the interface we are referring=
 to */
> +	u8 handle[4];			/* connection handle needed for disconnect */
> +	u8 cid[QMI_SYSMAX];		/* keeping track of cid per subsystem */
> +};
> +
> +/* combined QMUX and SDU */
> +struct qmux {
> +	u8 tf;		/* always 1 */
> +	__le16 len;	/* excluding tf */
> +	u8 ctrl;	/* b7: sendertype 1 =3D> service, 0 =3D> control point */
> +	u8 service;	/* 0 =3D> QMI_CTL, 1 =3D> QMI_WDS, .. */
> +	u8 qmicid;	/* client id or 0xff for broadcast */
> +	u8 flags;	/* always 0 for req */
> +	union {
> +		__le16 w;  /* each control point maintains a transaction id counte=
r - non-zero */
> +		u8 b;	/* system QMI_CTL uses one byte transaction ids! */
> +	} tid;
> +	u8 msg[];	/* one or more messages */
> +} __packed;
> +
> +struct qmi_msg {
> +	__le16 msgid;
> +	__le16 len;
> +	u8 tlv[];	/* zero or more tlvs */
> +} __packed;
> +
> +struct qmi_tlv {
> +	u8 type;
> +	__le16 len;
> +	u8 bytes[];
> +} __packed;
> +
> +struct qmi_tlv_response_data {
> +	__le16 error;
> +	__le16 code;
> +} __packed;
> +
> +
> +/* reset state to INIT */
> +extern int qmi_reset(struct qmi_state *qmi);
> +
> +/* disconnect WWAN connection */
> +extern int qmi_disconnect(struct qmi_state *qmi);
> +
> +/* must be called whenever USB_CDC_NOTIFY_RESPONSE_AVAILABLE is rece=
ived */
> +extern int qmi_recv(struct qmi_state *qmi);
> +
> +/* called periodically, whenever a state transition is wanted */
> +extern int qmi_conn_state(struct qmi_state *qmi);
> +
> +/* initialize */
> +extern struct qmi_state *qmi_init(struct usb_interface *intf);
> +
> +/* clean up */
> +extern int qmi_exit(struct qmi_state *qmi);
> diff --git a/drivers/net/usb/qmi_wwan_core.c b/drivers/net/usb/qmi_ww=
an_core.c
> new file mode 100644
> index 0000000..bf25e33
> --- /dev/null
> +++ b/drivers/net/usb/qmi_wwan_core.c
> @@ -0,0 +1,206 @@
> +/*
> + * Copyright (c) 2011  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/mii.h>
> +#include <linux/usb.h>
> +#include <linux/usb/cdc.h>
> +#include <linux/usb/usbnet.h>
> +#include "qmi.h"
> +
> +/* overloading the cdc_state structure */
> +struct qmi_wwan_state {
> +	struct qmi_state		*qmi;
> +	struct usb_cdc_union_desc	*u;
> +	struct usb_cdc_ether_desc	*ether;
> +	struct usb_interface		*control;
> +	struct usb_interface		*data;
> +};
> +
> +
> +static void qmi_wwan_cdc_status(struct usbnet *dev, struct urb *urb)
> +{
> +	struct usb_cdc_notification	*event;
> +	struct qmi_wwan_state *info =3D (void *)&dev->data;
> +
> +	if (urb->actual_length < sizeof *event) {
> +		netdev_dbg(dev->net, "short status urb rcvd: %d bytes\n", urb->act=
ual_length);
> +		return;
> +	}
> +
> +	event =3D urb->transfer_buffer;
> +	switch (event->bNotificationType) {
> +	case USB_CDC_NOTIFY_RESPONSE_AVAILABLE:
> +		qmi_recv(info->qmi);	/* request response */
> +		break;
> +	default:
> +		/* reuse usbnet() for handling other messages */
> +		usbnet_cdc_status(dev, urb);
> +	}
> +}
> +
> +static int qmi_wwan_cdc_ecmlike_bind(struct usbnet *dev, struct usb_=
interface *intf)
> +{
> +	int status;
> +	struct qmi_wwan_state *info =3D (void *)&dev->data;
> +
> +	status =3D usbnet_generic_cdc_bind(dev, intf);
> +	if (status < 0)
> +		return status;
> +
> +	/* initialize QMI data */
> +	info->qmi =3D qmi_init(intf);
> +	if (!info->qmi) {
> +		usbnet_cdc_unbind(dev, intf);
> +		return -1;
> +	}
> +	return 0;
> +}
> +
> +static int qmi_wwan_cdc_bind(struct usbnet *dev, struct usb_interfac=
e *intf)
> +{
> +	int status;
> +	struct qmi_wwan_state *info =3D (void *)&dev->data;
> +
> +	memset(info, 0, sizeof(*info));
> +	status =3D usbnet_get_endpoints(dev, intf);
> +	if (status < 0)
> +		return status;
> +
> +	/* initialize QMI data */
> +	info->qmi =3D qmi_init(intf);
> +	if (!info->qmi)
> +		return -1;
> +
> +	info->control =3D intf;
> +	return 0;
> +}
> +
> +static void qmi_wwan_cdc_unbind(struct usbnet *dev, struct usb_inter=
face *intf)
> +{
> +	struct qmi_wwan_state *info =3D (void *)&dev->data;
> +
> +	/* release our private structure */
> +	qmi_exit(info->qmi);
> +	info->qmi =3D NULL;
> +
> +	/* disconnect */
> +	usbnet_cdc_unbind(dev, intf);
> +}
> +
> +static int qmi_wwan_reset(struct usbnet *dev)
> +{
> +	struct qmi_wwan_state *info =3D (void *)&dev->data;
> +
> +	qmi_reset(info->qmi);
> +	return 1;
> +}
> +
> +static int qmi_wwan_stop(struct usbnet *dev)
> +{
> +	struct qmi_wwan_state *info =3D (void *)&dev->data;
> +
> +	qmi_disconnect(info->qmi);
> +	return 1;
> +}
> +
> +/* abusing check_connect for triggering QMI state transitions */
> +static int qmi_wwan_check_connect(struct usbnet *dev)
> +{
> +	struct qmi_wwan_state *info =3D (void *)&dev->data;
> +	return qmi_conn_state(info->qmi);
> +}
> +
> +static const struct driver_info	qmi_wwan_ecm_info =3D {
> +	.description =3D	"QMI speaking CDC ECM like wwan device",
> +	.flags =3D	 FLAG_WWAN,
> +	.bind =3D		 qmi_wwan_cdc_ecmlike_bind,
> +	.unbind =3D	 qmi_wwan_cdc_unbind,
> +	.status =3D	 qmi_wwan_cdc_status,
> +	.check_connect =3D qmi_wwan_check_connect,
> +	.stop =3D          qmi_wwan_stop,
> +	.reset =3D         qmi_wwan_reset,
> +};
> +
> +static const struct driver_info	qmi_wwan_info =3D {
> +	.description =3D	"QMI speaking wwan device",
> +	.flags =3D	 FLAG_WWAN,
> +	.bind =3D		 qmi_wwan_cdc_bind,
> +	.unbind =3D	 qmi_wwan_cdc_unbind,
> +	.status =3D	 qmi_wwan_cdc_status,
> +	.check_connect =3D qmi_wwan_check_connect,
> +	.stop =3D          qmi_wwan_stop,
> +	.reset =3D         qmi_wwan_reset,
> +};
> +
> +#define HUAWEI_VENDOR_ID	0x12D1
> +
> +static const struct usb_device_id products[] =3D {
> +{
> +	/* Qmi_Wwan E392, E398, ++? */
> +	.match_flags    =3D   USB_DEVICE_ID_MATCH_VENDOR
> +		 | USB_DEVICE_ID_MATCH_INT_INFO,
> +	.idVendor               =3D HUAWEI_VENDOR_ID,
> +	.bInterfaceClass	=3D USB_CLASS_VENDOR_SPEC,
> +	.bInterfaceSubClass	=3D 1,
> +	.bInterfaceProtocol	=3D 9,
> +	.driver_info =3D (unsigned long)&qmi_wwan_ecm_info,
> +}, {
> +	/* Qmi_Wwan device id 1413 ++? */
> +	.match_flags    =3D   USB_DEVICE_ID_MATCH_VENDOR
> +		 | USB_DEVICE_ID_MATCH_INT_INFO,
> +	.idVendor               =3D HUAWEI_VENDOR_ID,
> +	.bInterfaceClass	=3D USB_CLASS_VENDOR_SPEC,
> +	.bInterfaceSubClass	=3D 6,
> +	.bInterfaceProtocol	=3D 255,
> +	.driver_info =3D (unsigned long)&qmi_wwan_ecm_info,
> +}, {
> +	/* Qmi_Wwan E392, E398, ++? "Windows mode" */
> +	.match_flags    =3D   USB_DEVICE_ID_MATCH_VENDOR
> +		 | USB_DEVICE_ID_MATCH_INT_INFO,
> +	.idVendor               =3D HUAWEI_VENDOR_ID,
> +	.bInterfaceClass	=3D USB_CLASS_VENDOR_SPEC,
> +	.bInterfaceSubClass	=3D 1,
> +	.bInterfaceProtocol	=3D 17,
> +	.driver_info =3D (unsigned long)&qmi_wwan_info,
> +},
> +{ },		/* END */
> +};
> +MODULE_DEVICE_TABLE(usb, products);
> +
> +static struct usb_driver qmi_wwan_driver =3D {
> +	.name =3D		"qmi_wwan",
> +	.id_table =3D	products,
> +	.probe =3D	usbnet_probe,
> +	.disconnect =3D	usbnet_disconnect,
> +	.suspend =3D	usbnet_suspend,
> +	.resume =3D	usbnet_resume,
> +	.reset_resume =3D	usbnet_resume,
> +	.supports_autosuspend =3D 1,
> +};
> +
> +static int __init qmi_wwan_init(void)
> +{
> +	/* we remap struct (cdc_state) so we should be compatible */
> +	BUILD_BUG_ON(sizeof(struct cdc_state) !=3D sizeof(struct qmi_wwan_s=
tate));
> +
> +	return usb_register(&qmi_wwan_driver);
> +}
> +module_init(qmi_wwan_init);
> +
> +static void __exit qmi_wwan_exit(void)
> +{
> +	usb_deregister(&qmi_wwan_driver);
> +}
> +module_exit(qmi_wwan_exit);
> +
> +MODULE_AUTHOR("Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>");
> +MODULE_DESCRIPTION("Qualcomm Messaging Interface (QMI) WWAN driver")=
;
> +MODULE_LICENSE("GPL");



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
