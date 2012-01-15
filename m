From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 3/3] net: usb: qmi_wwan: New driver for QMI WAN devices
Date: Sun, 15 Jan 2012 07:40:37 +0100
Message-ID: <5c992644ed56f727ed8507933fa8db6ef553eff6.1326607234.git.bjorn@mork.no>
References: <cover.1326607234.git.bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
In-Reply-To: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
References: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some WWAN LTE/3G devices based on chipsets from Qualcomm provide
near standard CDC ECM interfaces in addition to the usual serial
interfaces.  But they cannot be fully configured using AT commands
over a serial interface.  It is necessary to speak the proprietary
Qualcomm MSM Interface (QMI) protocol to the device to enable the
ethernet proxy functionality.

This driver uses the cdc_enc subdriver to get access to the
encapsulated QMI protocol interface, and implements the basic QMI
support needed to bring up and down the interface. There is still
a need to pre-configure some settings using e.g. a modem mananger
application.  Most users will want to set an APN and enter a PIN
code, and some may also have to confgure authentication.

The layout of the usb interfaces can vary a lot within a single
device, depending on which "modeswitch" command has been used to
switch it from usb-storage mode.  Control and data interfaces
can be combined, or they can look like standard CDC ECM interfaces
with the appropriate descriptors but with vendor specific class
code. This driver is attempting to support them all, by reusing
as much as possible of the existing usbnet infrastructure.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Changes from v1: Complete rewrite. The QMI protocol specific parts
are split out from the rest of the driver, and all unnecessary QMI
commands has been removed as per comments from Dan Williams.  The
full QMI protocol is instead exposed to userspace via a character=20
device provided by the cdc_enc subdriver.

Some comments regarding the other QMI driver implementations I've
come across:
 - Gobi: similar to this driver, but does not use usbnet. Does
     expose the QMI protocol via a character device, but requires
     the user to send a number of ioctls to use it.

     Should be less than problematic to create a compatible=20
     interface if there are any application using it.  Are there?

 - The Android MSM driver: uses a shared menory interface to talk
     to the modem, and does not expose QMI to userspace.  Does
     have nice QMI message parsing (I wish I had noticed before...)
     and some of it could probably be split out in some common part.
     But I don't know if it's worth it.



 drivers/net/usb/Kconfig         |   14 ++
 drivers/net/usb/Makefile        |    2 +
 drivers/net/usb/qmi_proto.c     |  475 +++++++++++++++++++++++++++++++=
++++++++
 drivers/net/usb/qmi_proto.h     |   98 ++++++++
 drivers/net/usb/qmi_wwan_core.c |  343 ++++++++++++++++++++++++++++
 5 files changed, 932 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/qmi_proto.c
 create mode 100644 drivers/net/usb/qmi_proto.h
 create mode 100644 drivers/net/usb/qmi_wwan_core.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 1425b08..cc93122 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -475,4 +475,18 @@ config USB_NET_CDC_ENC
=20
 	  The encapsulated protocol is exported as a character device.
=20
+config USB_NET_QMI_WWAN
+	tristate "QMI WWAN driver for Qualcomm MSM based 3G and LTE modems"
+	depends on USB_NET_CDCETHER
+	select USB_NET_CDC_ENC
+	help
+	  Support WWAN LTE/3G devices based on MSM chipsets from
+	  Qualcomm, using the Qualcomm MSM Interface (QMI) protocol to
+	  configure the device.
+
+	  Note that it is still necessary to configure parameters like
+	  PIN code, APN, username and password using AT commands on a
+	  ttyUSBx port.  Select the "option" driver to support these.
+
+
 endmenu
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 1edfc1b..644d512 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -30,4 +30,6 @@ obj-$(CONFIG_USB_NET_CX82310_ETH)	+=3D cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+=3D cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+=3D lg-vl600.o
 obj-$(CONFIG_USB_NET_CDC_ENC)	+=3D cdc_enc.o
+obj-$(CONFIG_USB_NET_QMI_WWAN)	+=3D qmi_wwan.o
+qmi_wwan-objs :=3D qmi_wwan_core.o qmi_proto.o
=20
diff --git a/drivers/net/usb/qmi_proto.c b/drivers/net/usb/qmi_proto.c
new file mode 100644
index 0000000..aa0c9b4
--- /dev/null
+++ b/drivers/net/usb/qmi_proto.c
@@ -0,0 +1,475 @@
+/*
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+ * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+/*
+ * Dealing with devices using Qualcomm MSM Interface (QMI) for
+ * configuration.  Full documentation of the protocol can be obtained
+ * from http://developer.qualcomm.com/
+ *
+ * Some of this code may be inspired by code from the Qualcomm Gobi
+ * 2000 and Gobi 3000 drivers, available at http://www.codeaurora.org/
+ */
+
+#include "cdc_enc.h"
+#include "qmi_proto.h"
+
+/* find and return a pointer to the requested tlv */
+static struct qmi_tlv *qmi_get_tlv(u8 type, u8 *buf, size_t len)
+{
+	u8 *p;
+	struct qmi_tlv *t;
+
+	for (p =3D buf; p < buf + len; p +=3D t->len + sizeof(struct qmi_tlv)=
) {
+		t =3D (struct qmi_tlv *)p;
+		if (t->type =3D=3D type)
+			return (p + t->len <=3D buf + len) ? t : NULL;
+	}
+	return NULL;
+}
+
+/* TLV 0x02 is status: return a negative QMI error code or 0 if OK */
+static int qmi_verify_status_tlv(u8 *buf, size_t len)
+{
+	struct qmi_tlv *tlv =3D qmi_get_tlv(0x02, buf, len);
+	struct qmi_tlv_response_data *r =3D (void *)tlv->bytes;
+
+	/* OK: indications and requests do not have any status TLV */
+	if (!tlv)
+		return 0;
+
+	if (tlv->len !=3D sizeof(struct qmi_tlv_response_data))
+		return -QMI_ERR_MALFORMED_MSG;
+
+	return r->error ? -r->code : 0;
+}
+
+/* verify QMUX message header and return pointer to the (first) messag=
e if OK */
+static struct qmi_msg *qmi_qmux_verify(u8 *data, size_t len)
+{
+	struct qmux_header *h =3D  (void *)data;
+	struct qmi_msg *m =3D NULL;
+
+	if (len < sizeof(struct qmux_header) || /* short packet */
+		h->tf !=3D 0x01 || h->len !=3D (len - 1)) /* invalid QMUX packet! */
+		goto err;
+
+	/* tid has a different size for QMI_CTL for some fucking stupid reaso=
n */
+	if (h->service =3D=3D QMI_CTL) {
+		struct qmi_ctl *ctl =3D (void *)data;
+		if (len >=3D sizeof(struct qmi_ctl) +  ctl->m.len)
+			m =3D &ctl->m;
+	} else {
+		struct qmi_wds *wds =3D (void *)data;
+		if (len >=3D sizeof(struct qmi_wds) +  wds->m.len)
+			m =3D &wds->m;
+	}
+
+err:
+	return m;
+}
+
+/* parse a QMI_CTL replies */
+static int qmi_ctl_parse(struct cdc_enc_client *client, struct qmi_msg=
 *m)
+{
+	struct qmi_state *state =3D (void *)&client->priv;
+	struct qmi_tlv *tlv;
+	int status;
+
+	/* check and save status TLV */
+	status =3D qmi_verify_status_tlv(m->tlv, m->len);
+
+	/* clear the saved transaction id */
+	state->ctl_tid =3D 0;
+
+	switch (m->msgid) {
+	case 0x0022: /* CTL_GET_CLIENT_ID_RESP */
+		/* there's no way out of this I think... */
+		if (status < 0) {
+			dev_err(&client->cdc_enc->intf->dev,
+				"Failed to get QMI_WDS client id %#06x\n", -status);
+			state->flags |=3D QMI_STATE_FLAG_CIDERR;
+			break;
+		}
+
+		/* TLV 0x01 is a 2 byte system + client ID */
+		tlv =3D qmi_get_tlv(0x01, m->tlv, m->len);
+		if (tlv && tlv->len =3D=3D 2) {
+			if (tlv->bytes[0] =3D=3D QMI_WDS)
+				state->wds_cid =3D tlv->bytes[1];
+		} else {
+			status =3D -QMI_ERR_MALFORMED_MSG;
+		}
+		break;
+	}
+	return status;
+}
+
+static int qmi_send_msg(struct cdc_enc_client *client, u8 system, __le=
16 msgid, struct qmi_tlv *tlv);
+
+/* parse a QMI_WDS indications looking connection status updates */
+static int qmi_wds_parse_ind(struct cdc_enc_client *client, struct qmi=
_msg *m)
+{
+	struct qmi_state *state =3D (void *)&client->priv;
+	struct qmi_tlv *tlv;
+	int status =3D 0;
+
+	switch (m->msgid) {
+	case 0x0022: /* QMI_WDS_PKT_SRVC_STATUS_IND */
+
+		/* TLV 0x01 is a 2 byte connection status. Note the
+		 * difference from replies: Indications use the second
+		 * byte for a "reconfiguration" flag. We ignore that..
+		 */
+		tlv =3D qmi_get_tlv(0x01, m->tlv, m->len);
+		if (tlv && tlv->len =3D=3D 2) {
+			dev_dbg(&client->cdc_enc->intf->dev,
+				"connstate %#04x =3D> %#04x (flags %04x)\n",
+				state->wds_status, tlv->bytes[0], state->flags);
+
+			state->wds_status =3D tlv->bytes[0];
+
+			/* this is a bit weird, but it seems that the
+			 * firmware *requires* us to request address
+			 * configuration before it will forward any
+			 * packets. DHCP does this just fine for us on
+			 * initial connect, but reconnecting will
+			 * cause us to blackhole packets unless we
+			 * send this QMI request.
+			 *
+			 * BUT: If we send this after the initial connection,
+			 * before the DHCP client has done it's job, then
+			 * we end up with a device sending ethernet header-
+			 * less frames.  Go figure.  Can you spell buggy
+			 * frimware?
+			 *
+			 * So we attemt to send this on reconnects only
+			 *
+			 * QMI_WDS msg 0x002d is "QMI_WDS_GET_RUNTIME_SETTINGS"
+			 */
+			if (state->wds_status =3D=3D 2) {
+				if (state->flags & QMI_STATE_FLAG_NOTFIRST)
+					qmi_send_msg(client, QMI_WDS, 0x002d, NULL);
+				else
+					state->flags |=3D QMI_STATE_FLAG_NOTFIRST;
+			}
+		} else {
+			status =3D -QMI_ERR_MALFORMED_MSG;
+		}
+		break;
+	}
+	return status;
+}
+
+
+/* parse a QMI_WDS replies looking connection status updates */
+static int qmi_wds_parse(struct cdc_enc_client *client, struct qmi_msg=
 *m)
+{
+	struct qmi_state *state =3D (void *)&client->priv;
+	struct qmi_tlv *tlv;
+	int status;
+
+	/* check and save status TLV */
+	status =3D qmi_verify_status_tlv(m->tlv, m->len);
+
+	/* note that we continue with per message processing on
+	 * errors, to be able to clear wait states etc.
+	 */
+	switch (m->msgid) {
+	case 0x0020: /* QMI_WDS_START_NETWORK_INTERFACE_RESP */
+		/* got a reply - clear flag */
+		state->flags &=3D ~QMI_STATE_FLAG_START;
+		if (status < 0) {
+			__le32 reason =3D -1;
+
+			/* TLV 0x11 is a 4 byte call end reason type */
+			tlv =3D qmi_get_tlv(0x11, m->tlv, m->len);
+			if (tlv)
+				reason =3D *(__le32 *)tlv->bytes;
+
+			dev_info(&client->cdc_enc->intf->dev,
+				"Connection failed with status %#06x and reason %#010x\n",
+				-status, reason);
+			break;
+		}
+
+		/* TLV 0x01 is a 4 byte connection handle */
+		tlv =3D qmi_get_tlv(0x01, m->tlv, m->len);
+		if (tlv && tlv->len =3D=3D sizeof(state->wds_handle))
+			memcpy(state->wds_handle, tlv->bytes, sizeof(state->wds_handle));
+		else
+			status =3D -QMI_ERR_MALFORMED_MSG;
+		break;
+	case 0x0022: /* QMI_WDS_GET_PKT_SRVC_STATUS_RESP */
+		if (status < 0)
+			break;
+
+		/* TLV 0x01 is a 1 byte connection status */
+		tlv =3D qmi_get_tlv(0x01, m->tlv, m->len);
+		if (tlv && tlv->len =3D=3D 1)
+			state->wds_status =3D tlv->bytes[0];
+		else
+			status =3D -QMI_ERR_MALFORMED_MSG;
+		break;
+	case 0x002d: /* might as well parse this then... */
+		if (status < 0)
+			break;
+
+		/* TLV 0x14 is APN name */
+		tlv =3D qmi_get_tlv(0x14, m->tlv, m->len);
+		if (!tlv)
+			break;
+
+		/* we "know" the buffer has space for this */
+		tlv->bytes[tlv->len] =3D 0;
+		dev_info(&client->cdc_enc->intf->dev,
+			"Connected to APN \"%s\"\n", tlv->bytes);
+
+		break;
+	}
+	return status;
+}
+
+/* parse the buffered message and update the saved QMI state if it's f=
or us */
+int qmi_parse_qmux(struct cdc_enc_client *client)
+{
+	struct qmi_ctl *qmux;
+	struct qmi_msg *m;
+	int ret =3D -1;
+	struct qmi_state *state =3D (void *)&client->priv;
+
+	/* any unread data available? */
+	if (!test_bit(CDC_ENC_CLIENT_RX, &client->flags))
+		return 0;
+
+	/* someone else is using the buffer... */
+	if (test_and_set_bit(CDC_ENC_CLIENT_BUSY, &client->flags))
+		return -1;
+
+	m =3D qmi_qmux_verify(client->buf, client->len);
+	if (!m)
+		goto done;
+
+	/* we only use the common header for QMI_WDS so this will work */
+	qmux =3D (struct qmi_ctl *)client->buf;
+
+	/* verify that the message is for our eyes */
+	if (qmux->h.ctrl !=3D 0x80) /* must be "service" */
+		goto done;
+
+	switch (qmux->h.service) {
+	case QMI_CTL:
+		/* only for us if the transaction ID matches */
+		if (state->ctl_tid =3D=3D qmux->tid)
+			ret =3D qmi_ctl_parse(client, m);
+		break;
+	case QMI_WDS:
+		/* for us if it's a broadcast or the client ID matches */
+		if (qmux->h.qmicid =3D=3D 0xff || qmux->h.qmicid =3D=3D state->wds_c=
id) {
+			switch (qmux->h.flags) {
+			case 0x02: /* reply */
+				ret =3D qmi_wds_parse(client, m);
+				break;
+			case 0x04: /* unsolicited indication */
+				ret =3D qmi_wds_parse_ind(client, m);
+				break;
+			}
+		}
+		break;
+	}
+
+done:
+	/* order is important! */
+	clear_bit(CDC_ENC_CLIENT_RX, &client->flags);
+	clear_bit(CDC_ENC_CLIENT_BUSY, &client->flags);
+	return ret;
+}
+
+/* Get a new transaction id - yeah, yeah, atomic operations blah, blah=
, blah
+ * Fact is that we don't really need to care much about collisions, so=
 this
+ * will do
+ */
+static __le16 new_tid(void)
+{
+	static __le16 tid;
+	return ++tid;
+}
+
+/* assemble a QMI_WDS packet */
+static size_t qmi_create_wds_msg(struct cdc_enc_client *client, __le16=
 msgid, struct qmi_tlv *tlv)
+{
+	struct qmi_wds *wds =3D (void *)client->tx_buf;
+	struct qmi_state *state =3D (void *)&client->priv;
+
+	/* cannot send QMI_WDS requests without a client ID */
+	if (!state->wds_cid)
+		return 0;
+
+	memset(wds, 0, sizeof(*wds));
+	wds->h.tf =3D 1;     /* always 1 */
+	wds->h.service =3D QMI_WDS;
+	wds->h.qmicid =3D state->wds_cid;
+	wds->h.len =3D sizeof(*wds) - 1;
+	wds->tid =3D new_tid();
+	wds->m.msgid =3D msgid;
+	if (tlv) {
+		ssize_t tlvsize =3D tlv->len + sizeof(struct qmi_tlv);
+		memcpy(wds->m.tlv, tlv, tlvsize);
+		wds->m.len =3D tlvsize;
+		wds->h.len +=3D tlvsize;
+	}
+	return wds->h.len + 1;
+}
+
+/* assemble a QMI_CTL packet */
+static size_t qmi_create_ctl_msg(struct cdc_enc_client *client, __le16=
 msgid, struct qmi_tlv *tlv)
+{
+	struct qmi_ctl *ctl =3D (void *)client->tx_buf;
+	struct qmi_state *state =3D (void *)&client->priv;
+
+	/* only allowing one outstanding CTL request */
+	if (state->ctl_tid)
+		return 0;
+
+	memset(ctl, 0, sizeof(*ctl));
+	ctl->h.tf =3D 1;     /* always 1 */
+	ctl->h.len =3D sizeof(*ctl) - 1;
+	while (ctl->tid =3D=3D 0 || ctl->tid =3D=3D 0xff) /* illegal values *=
/
+		ctl->tid =3D new_tid() & 0xff;
+
+	/* save allocated transaction ID for reply matching */
+	state->ctl_tid =3D ctl->tid;
+
+	ctl->m.msgid =3D msgid;
+	if (tlv) {
+		ssize_t tlvsize =3D tlv->len + sizeof(struct qmi_tlv);
+		memcpy(ctl->m.tlv, tlv, tlvsize);
+		ctl->m.len =3D tlvsize;
+		ctl->h.len +=3D tlvsize;
+	}
+	return ctl->h.len + 1;
+
+}
+
+/* send a QMI message syncronously */
+static int qmi_send_msg(struct cdc_enc_client *client, u8 system, __le=
16 msgid, struct qmi_tlv *tlv)
+{
+	int ret =3D -1;
+	size_t len =3D 0;
+
+	/* lock client buffer */
+	if (test_and_set_bit(CDC_ENC_CLIENT_TX, &client->flags))
+		goto err_noclear;
+
+	/* create message */
+	switch (system) {
+	case QMI_CTL:
+		len =3D qmi_create_ctl_msg(client, msgid, tlv);
+		break;
+	case QMI_WDS:
+		len =3D qmi_create_wds_msg(client, msgid, tlv);
+		break;
+	}
+
+	if (!len)
+		goto err;
+
+	/* send it */
+	ret =3D cdc_enc_send_sync(client, client->tx_buf, len) - len;
+
+err:
+	clear_bit(CDC_ENC_CLIENT_TX, &client->flags);
+err_noclear:
+	return ret;
+}
+
+/* QMI_CTL msg 0x0022 is "request cid", TLV 0x01 is system */
+int qmi_ctl_request_wds_cid(struct cdc_enc_client *client)
+{
+	static struct qmi_tlv tlvreq =3D {
+		.type =3D 0x01,
+		.len =3D 1,
+		.bytes =3D { QMI_WDS },
+	};
+	struct qmi_state *state =3D (void *)&client->priv;
+
+	/* return immediately if a CID is already allocated */
+	if (state->wds_cid)
+		return 0;
+
+	return qmi_send_msg(client, QMI_CTL, 0x0022, &tlvreq);
+}
+
+/* QMI_CTL msg 0x0023 is "release cid", TLV 0x01 is system + cid */
+int qmi_ctl_release_wds_cid(struct cdc_enc_client *client)
+{
+	static struct qmi_tlv tlvreq =3D {
+		.type =3D 0x01,
+		.len =3D 2,
+		.bytes =3D { QMI_WDS, 0 },
+	};
+	struct qmi_state *state =3D (void *)&client->priv;
+
+
+	/* return immediately if no CID is allocated */
+	if (!state->wds_cid)
+		return 0;
+
+	tlvreq.bytes[1] =3D state->wds_cid;
+	state->wds_cid =3D 0;
+
+	return qmi_send_msg(client, QMI_CTL, 0x0023, &tlvreq);
+}
+
+/* QMI_WDS msg 0x0020 is "QMI_WDS_START_NETWORK_INTERFACE" */
+int qmi_wds_start(struct cdc_enc_client *client)
+{
+	struct qmi_state *state =3D (void *)&client->priv;
+
+	/* avoid sending multiple start messages on top of each other */
+	if (state->flags & QMI_STATE_FLAG_START)
+		return 0;
+
+	state->flags |=3D QMI_STATE_FLAG_START;
+	return qmi_send_msg(client, QMI_WDS, 0x0020, NULL);
+}
+
+/* QMI_WDS msg 0x0021 is "QMI_WDS_STOP_NETWORK_INTERFACE" */
+int qmi_wds_stop(struct cdc_enc_client *client)
+{
+	static struct qmi_tlv tlvreq =3D {
+		.type =3D 0x01,
+		.len =3D 4,
+		.bytes =3D { 0, 0, 0, 0 },
+	};
+	struct qmi_state *state =3D (void *)&client->priv;
+
+	/* cannot send stop unless we have a handle */
+	if (!*(u32 *)state->wds_handle)
+		return 0;
+
+	memcpy(&tlvreq.bytes, state->wds_handle, sizeof(state->wds_handle));
+	return qmi_send_msg(client, QMI_WDS, 0x0021, &tlvreq);
+}
+
+/* QMI_WDS msg 0x0022 is "QMI_WDS_GET_PKT_SRVC_STATUS" */
+int qmi_wds_status(struct cdc_enc_client *client)
+{
+	return qmi_send_msg(client, QMI_WDS, 0x0022, NULL);
+}
+
+/* reset everything but the allocated QMI_WDS client ID */
+void qmi_state_reset(struct cdc_enc_client *client)
+{
+	struct qmi_state *state =3D (void *)&client->priv;
+
+	memset(state->wds_handle, 0, sizeof(state->wds_handle));
+	state->ctl_tid =3D 0;
+	state->wds_status =3D 0;
+	state->flags =3D 0;
+}
diff --git a/drivers/net/usb/qmi_proto.h b/drivers/net/usb/qmi_proto.h
new file mode 100644
index 0000000..cf1d96d
--- /dev/null
+++ b/drivers/net/usb/qmi_proto.h
@@ -0,0 +1,98 @@
+/*
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+ * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+/*
+ * Dealing with devices using Qualcomm MSM Interface (QMI) for
+ * configuration.  Full documentation of the protocol can be obtained
+ * from http://developer.qualcomm.com/
+ *
+ * Some of this code may be inspired by code from the Qualcomm Gobi
+ * 2000 and Gobi 3000 drivers, available at http://www.codeaurora.org/
+ */
+
+#ifndef _QMI_PROTO_H_
+#define _QMI_PROTO_H_
+
+#include "cdc_enc.h"
+
+/* the different QMI subsystems */
+#define	QMI_CTL	0x00
+#define	QMI_WDS 0x01
+
+/* Error codes */
+#define QMI_ERR_MALFORMED_MSG 0x0001
+
+/* QMI protocol structures */
+struct qmux_header {
+	u8 tf;		/* always 1 */
+	__le16 len;	/* excluding tf */
+	u8 ctrl;	/* b7: sendertype 1 =3D> service, 0 =3D> control point */
+	u8 service;	/* 0 =3D> QMI_CTL, 1 =3D> QMI_WDS, .. */
+	u8 qmicid;	/* client id or 0xff for broadcast */
+	u8 flags;	/* always 0 for req */
+} __packed;
+
+struct qmi_msg {
+	__le16 msgid;
+	__le16 len;
+	u8 tlv[];	/* zero or more tlvs */
+} __packed;
+
+struct qmi_ctl {
+	struct qmux_header h;
+	u8 tid;	/* system QMI_CTL uses one byte transaction ids! */
+	struct qmi_msg m;
+} __packed;
+
+struct qmi_wds {
+	struct qmux_header h;
+	__le16 tid;
+	struct qmi_msg m;
+} __packed;
+
+struct qmi_tlv {
+	u8 type;
+	__le16 len;
+	u8 bytes[];
+} __packed;
+
+struct qmi_tlv_response_data {
+	__le16 error;
+	__le16 code;
+} __packed;
+
+/* for QMI_WDS state tracking */
+struct qmi_state {
+	u8 wds_handle[4];	/* connection handle */
+	u8 ctl_tid;		/* for matching up QMI_CTL replies */
+	u8 wds_cid;		/* allocated QMI_WDS client ID */
+	u8 wds_status;		/* result of the last QMI_WDS_GET_PKT_SRVC_STATUS mes=
sage */
+	u8 flags;
+} __packed;
+
+#define QMI_STATE_FLAG_START	0x01	/* START in progress */
+#define QMI_STATE_FLAG_CIDERR	0x02	/* client ID allocation failure */
+#define QMI_STATE_FLAG_NOTFIRST	0x04	/* have been connected before */
+
+/* parsing the buffered QMUX message */
+extern int qmi_parse_qmux(struct cdc_enc_client *client);
+
+/* reset state variables */
+extern void qmi_state_reset(struct cdc_enc_client *client);
+
+/* QMI_CTL commands */
+extern int qmi_ctl_request_wds_cid(struct cdc_enc_client *client);
+extern int qmi_ctl_release_wds_cid(struct cdc_enc_client *client);
+
+/* QMI_WDS commands */
+extern int qmi_wds_start(struct cdc_enc_client *client);
+extern int qmi_wds_stop(struct cdc_enc_client *client);
+extern int qmi_wds_status(struct cdc_enc_client *client);
+
+#endif /* _QMI_PROTO_H_ */
diff --git a/drivers/net/usb/qmi_wwan_core.c b/drivers/net/usb/qmi_wwan=
_core.c
new file mode 100644
index 0000000..7bcdf78
--- /dev/null
+++ b/drivers/net/usb/qmi_wwan_core.c
@@ -0,0 +1,343 @@
+/*
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/cdc.h>
+#include <linux/usb/usbnet.h>
+#include "cdc_enc.h"
+#include "qmi_proto.h"
+
+/*
+ * Overloading the cdc_state structure...
+ *
+ * We use usbnet_cdc_bind() because that suits us well, but it maps
+ * the whole struct usbnet "data" field to it's own struct cdc_state.
+ * The three functional descriptor pointers are however not used after
+ * bind, so we remap the "data" field to our own structure with a
+ * pointer to the cdc_enc subdriver instead of the CDC header descript=
or
+ */
+struct qmi_wwan_state {
+	/* replacing "struct usb_cdc_header_desc *header" */
+	struct cdc_enc_client		*wwan;
+
+	/* keeping these for now */
+	struct usb_cdc_union_desc	*u;
+	struct usb_cdc_ether_desc	*ether;
+
+	/* the rest *must* be identical to "struct cdc_state" */
+	struct usb_interface		*control;
+	struct usb_interface		*data;
+};
+
+/* callback doing the parsing for us */
+static void qmux_received_callback(struct work_struct *work)
+{
+	struct cdc_enc_client *client =3D container_of(work, struct cdc_enc_c=
lient, work);
+
+	qmi_parse_qmux(client);
+}
+
+/* we have two additional requirements for usbnet_cdc_status():
+ *  1) handle USB_CDC_NOTIFY_RESPONSE_AVAILABLE
+ *  2) resubmit interrupt urb even if the ethernet interface is down
+ */
+static void qmi_wwan_cdc_status(struct usbnet *dev, struct urb *urb)
+{
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	struct usb_cdc_notification *event;
+
+	if (urb->actual_length < sizeof(*event)) {
+		netdev_dbg(dev->net, "short status urb rcvd: %d bytes\n", urb->actua=
l_length);
+		return;
+	}
+
+	event =3D urb->transfer_buffer;
+	switch (event->bNotificationType) {
+	case USB_CDC_NOTIFY_RESPONSE_AVAILABLE:
+		/* the device has QMI data for us =3D> submit read URB */
+		cdc_enc_submit_readurb(info->wwan->cdc_enc, GFP_ATOMIC);
+		break;
+	default:
+		/* let usbnet_cdc_status() handle the other CDC messages */
+		usbnet_cdc_status(dev, urb);
+	}
+
+	/* usbnet won't resubmit unless netif is running */
+	if (!netif_running(dev->net))
+		usb_submit_urb(urb, GFP_ATOMIC);
+}
+
+/* we need to do some work after binding, but possibly before usbnet w=
ill
+ * call any of our other methods
+ */
+static struct qmi_wwan_delayed_type {
+	struct delayed_work dwork;
+	struct usbnet *dev;
+} qmi_wwan_delayed;
+
+static void qmi_wwan_deferred_bind(struct work_struct *work)
+{
+	struct qmi_wwan_delayed_type *dtype =3D container_of(work, struct qmi=
_wwan_delayed_type, dwork.work);
+	struct qmi_wwan_state *info =3D (void *)&dtype->dev->data;
+
+	/* if not ready yet, then wait and retry */
+	if (!dtype->dev->interrupt) {
+		schedule_delayed_work(&qmi_wwan_delayed.dwork, 100);
+		return;
+	}
+
+	/* usbnet will happily kill the interrupt status URB when it
+	 * doesn't need it.  Let cdc_enc submit the URB in cases where
+	 * it needs the interrupts. Hack alert!
+	 */
+	cdc_enc_set_interrupt(info->wwan->cdc_enc, dtype->dev->interrupt);
+}
+
+static int qmi_wwan_cdc_bind(struct usbnet *dev, struct usb_interface =
*intf)
+{
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	struct cdc_enc_state *cdc_enc;
+	int status;
+
+	status =3D usbnet_cdc_bind(dev, intf);
+	if (status < 0) {
+		/* Some Huawei devices have multiple sets of
+		 * descriptors, selectable by mode switching.  Some of
+		 * these sets, like the one used by Windows, do not
+		 * have the CDC functional descriptors required by
+		 * usbnet_cdc_bind().  But they still provide the
+		 * exact same functionality on a single combined
+		 * interface, with the missing MAC address string
+		 * descriptor being the only exception.
+		 */
+		dev_info(&intf->dev, "no CDC descriptors - will generate a MAC addre=
ss\n");
+		status =3D usbnet_get_endpoints(dev, intf);
+	}
+	if (status < 0)
+		goto err_cdc_bind;
+
+	/* allocate and initiate a QMI device with a client */
+	cdc_enc =3D cdc_enc_init_one(intf, "qmi");
+	if (!cdc_enc)
+		goto err_cdc_enc;
+
+	/* add the wwan client */
+	info->wwan =3D cdc_enc_add_client(cdc_enc, qmux_received_callback);
+	if (!info->wwan)
+		goto err_wwan;
+
+	/* need to run this after usbnet has finished initialisation */
+	qmi_wwan_delayed.dev =3D dev;
+	INIT_DELAYED_WORK(&qmi_wwan_delayed.dwork, qmi_wwan_deferred_bind);
+	schedule_delayed_work(&qmi_wwan_delayed.dwork, 100);
+
+	dev_info(&intf->dev, "Use one of the ttyUSBx devices to configure PIN=
 code, APN or other required settings\n");
+
+	return 0;
+
+err_wwan:
+	cdc_enc_free_one(cdc_enc);
+err_cdc_enc:
+	/* usbnet_cdc_unbind() makes sure that the driver is unbound
+	 * from both the control and data interface.  It will be a
+	 * harmless noop if usbnet_cdc_bind() failed above.
+	 */
+	usbnet_cdc_unbind(dev, intf);
+	status =3D -1;
+err_cdc_bind:
+	return status;
+}
+
+static void qmi_wwan_cdc_unbind(struct usbnet *dev, struct usb_interfa=
ce *intf)
+{
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	struct cdc_enc_state *cdc_enc;
+
+	/* release allocated client ID - no need to wait for the reply */
+	qmi_ctl_release_wds_cid(info->wwan);
+
+	/* release our private structure */
+	cdc_enc =3D info->wwan->cdc_enc ;
+	cdc_enc_destroy_client(info->wwan);
+	cdc_enc_free_one(cdc_enc);
+	info->wwan =3D NULL;
+
+	/* disconnect from data interface as well, if there is one */
+	usbnet_cdc_unbind(dev, intf);
+}
+
+static int qmi_wwan_reset(struct usbnet *dev)
+{
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	/* reset QMI state to a something sane */
+	qmi_state_reset(info->wwan);
+
+	/* trigger client ID allocation if needed */
+	qmi_ctl_request_wds_cid(info->wwan);
+
+	return 1;
+}
+
+static int qmi_wwan_stop(struct usbnet *dev)
+{
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	/* disconnect from mobile network */
+	qmi_wds_stop(info->wwan);
+	return 1;
+}
+
+static int qmi_wwan_suspend(struct usb_interface *intf, pm_message_t m=
essage)
+{
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	/* kill the read URB */
+	if (!dev->suspend_count)
+		cdc_enc_kill_readurb(info->wwan->cdc_enc);
+
+	return usbnet_suspend(intf, message);
+}
+
+static int qmi_wwan_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+	int ret;
+
+	ret =3D usbnet_resume(intf);
+
+	/* resume interrupt URB in case usbnet didn't do it */
+	if (!dev->suspend_count && dev->interrupt && !test_bit(EVENT_DEV_OPEN=
, &dev->flags))
+		usb_submit_urb(dev->interrupt, GFP_NOIO);
+
+	return ret;
+}
+
+/* stolen from cdc_ether.c */
+static int qmi_wwan_manage_power(struct usbnet *dev, int on)
+{
+	dev->intf->needs_remote_wakeup =3D on;
+	return 0;
+}
+
+/* abusing check_connect for triggering QMI state transitions */
+static int qmi_wwan_check_connect(struct usbnet *dev)
+{
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	struct cdc_enc_client *wwan =3D info->wwan;
+	struct qmi_state *qmi =3D (void *)&wwan->priv;
+
+	/* reset was supposed to allocate a CID - not way out if that failed!=
 */
+	if (qmi->flags & QMI_STATE_FLAG_CIDERR) {
+		netdev_info(dev->net, "QMI_WDS client ID allocation failed - cannot =
continue\n");
+		return -1;
+	}
+
+	switch (qmi->wds_status) {
+	case 0: /* no status set yet - trigger an update */
+		qmi_wds_status(wwan);
+		break;
+	case 1: /* disconnected - trigger a connection */
+		qmi_wds_start(wwan);
+		break;
+	case 2: /* connected */
+		return 0;
+	/* other states may indicate connection in progress - do nothing */
+	}
+
+	/* usbnet_open() will fail unless we kill their URB here */
+	if (!test_bit(EVENT_DEV_OPEN, &dev->flags))
+		usb_kill_urb(dev->interrupt);
+
+	return 1;  /* "not connected" */
+}
+
+static const struct driver_info	qmi_wwan_info =3D {
+	.description	=3D "QMI speaking wwan device",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_cdc_bind,
+	.unbind		=3D qmi_wwan_cdc_unbind,
+	.status		=3D qmi_wwan_cdc_status,
+	.manage_power	=3D qmi_wwan_manage_power,
+	.check_connect	=3D qmi_wwan_check_connect,
+	.stop		=3D qmi_wwan_stop,
+	.reset		=3D qmi_wwan_reset,
+};
+
+#define HUAWEI_VENDOR_ID	0x12D1
+
+static const struct usb_device_id products[] =3D {
+{
+	/* Qmi_Wwan E392, E398, ++? */
+	.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_MA=
TCH_INT_INFO,
+	.idVendor           =3D HUAWEI_VENDOR_ID,
+	.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
+	.bInterfaceSubClass =3D 1,
+	.bInterfaceProtocol =3D 9,
+	.driver_info        =3D (unsigned long)&qmi_wwan_info,
+}, {
+	/* Qmi_Wwan device id 1413 ++? */
+	.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_MA=
TCH_INT_INFO,
+	.idVendor           =3D HUAWEI_VENDOR_ID,
+	.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
+	.bInterfaceSubClass =3D 6,
+	.bInterfaceProtocol =3D 255,
+	.driver_info        =3D (unsigned long)&qmi_wwan_info,
+}, {
+	/* Qmi_Wwan E392, E398, ++? "Windows mode" using a combined
+	 * control and data interface without any CDC functional
+	 * descriptors */
+	.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_MA=
TCH_INT_INFO,
+	.idVendor           =3D HUAWEI_VENDOR_ID,
+	.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
+	.bInterfaceSubClass =3D 1,
+	.bInterfaceProtocol =3D 17,
+	.driver_info	    =3D (unsigned long)&qmi_wwan_info,
+},
+{ },		/* END */
+};
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver qmi_wwan_driver =3D {
+	.name		      =3D "qmi_wwan",
+	.id_table	      =3D products,
+	.probe		      =3D	usbnet_probe,
+	.disconnect	      =3D usbnet_disconnect,
+	.suspend	      =3D qmi_wwan_suspend,
+	.resume		      =3D	qmi_wwan_resume,
+	.reset_resume         =3D qmi_wwan_resume,
+	.supports_autosuspend =3D 1,
+};
+
+static int __init qmi_wwan_init(void)
+{
+	/* we remap struct (cdc_state) so we should be compatible */
+	BUILD_BUG_ON(sizeof(struct cdc_state) !=3D sizeof(struct qmi_wwan_sta=
te) ||
+		offsetof(struct cdc_state, control) !=3D offsetof(struct qmi_wwan_st=
ate, control) ||
+		offsetof(struct cdc_state, data) !=3D offsetof(struct qmi_wwan_state=
, data));
+
+	BUILD_BUG_ON(sizeof(struct qmi_state) > sizeof(unsigned long));
+
+	return usb_register(&qmi_wwan_driver);
+}
+module_init(qmi_wwan_init);
+
+static void __exit qmi_wwan_exit(void)
+{
+	usb_deregister(&qmi_wwan_driver);
+}
+module_exit(qmi_wwan_exit);
+
+MODULE_AUTHOR("Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>");
+MODULE_DESCRIPTION("Qualcomm MSM Interface (QMI) WWAN driver");
+MODULE_LICENSE("GPL");
--=20
1.7.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
