From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH RFC 6/6] gigaset: add Kernel CAPI interface
Date: Fri, 21 Aug 2009 19:21:34 +0200 (CEST)
Message-ID: <20090821-patch-06.tilman@imap.cc>
References: <20090821-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932703AbZHURWH@vger.kernel.org>
In-Reply-To: <20090821-patch-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a Kernel CAPI interface to the Gigaset driver.

Impact: new functionality
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/Kconfig    |   18 +-
 drivers/isdn/gigaset/Makefile   |    1 +
 drivers/isdn/gigaset/capi.c     | 1855 +++++++++++++++++++++++++++++++++++++++
 drivers/isdn/gigaset/common.c   |   19 +
 drivers/isdn/gigaset/ev-layer.c |   26 +-
 drivers/isdn/gigaset/gigaset.h  |    7 +-
 6 files changed, 1910 insertions(+), 16 deletions(-)
 create mode 100644 drivers/isdn/gigaset/capi.c

diff --git a/drivers/isdn/gigaset/Kconfig b/drivers/isdn/gigaset/Kconfig
index 6fd2dc1..dcefedc 100644
--- a/drivers/isdn/gigaset/Kconfig
+++ b/drivers/isdn/gigaset/Kconfig
@@ -10,20 +10,32 @@ menuconfig ISDN_DRV_GIGASET
 	  If you have one of these devices, say M here and for at least
 	  one of the connection specific parts that follow.
 	  This will build a module called "gigaset".
-	  Note: If you build the ISDN4Linux subsystem (ISDN_I4L)
+	  Note: If you build your ISDN subsystem (ISDN_CAPI or ISDN_I4L)
 	  as a module, you have to build this driver as a module too,
 	  otherwise the Gigaset device won't show up as an ISDN device.
 
 if ISDN_DRV_GIGASET
 
+config GIGASET_CAPI
+	bool "Gigaset CAPI support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	depends on ISDN_CAPI='y'||(ISDN_CAPI='m'&&ISDN_DRV_GIGASET='m')
+	default ISDN_I4L='n'
+	help
+	  Build the Gigaset driver as a CAPI 2.0 driver interfacing with
+	  the Kernel CAPI subsystem. To use it with the old ISDN4Linux
+	  subsystem you'll have to enable the capidrv glue driver.
+	  (select ISDN_CAPI_CAPIDRV.)
+	  Say N to build the old native ISDN4Linux variant.
+
 config GIGASET_I4L
 	bool
 	depends on ISDN_I4L='y'||(ISDN_I4L='m'&&ISDN_DRV_GIGASET='m')
-	default y
+	default !GIGASET_CAPI
 
 config GIGASET_DUMMYLL
 	bool
-	default !GIGASET_I4L
+	default !GIGASET_CAPI&&!GIGASET_I4L
 
 config GIGASET_BASE
 	tristate "Gigaset base station support"
diff --git a/drivers/isdn/gigaset/Makefile b/drivers/isdn/gigaset/Makefile
index d429202..c453b72 100644
--- a/drivers/isdn/gigaset/Makefile
+++ b/drivers/isdn/gigaset/Makefile
@@ -1,4 +1,5 @@
 gigaset-y := common.o interface.o proc.o ev-layer.o asyncdata.o
+gigaset-$(CONFIG_GIGASET_CAPI) += capi.o
 gigaset-$(CONFIG_GIGASET_I4L) += i4l.o
 gigaset-$(CONFIG_GIGASET_DUMMYLL) += dummyll.o
 usb_gigaset-y := usb-gigaset.o
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
new file mode 100644
index 0000000..9ff1063
--- /dev/null
+++ b/drivers/isdn/gigaset/capi.c
@@ -0,0 +1,1855 @@
+/*
+ * Kernel CAPI interface for the Gigaset driver
+ *
+ * Copyright (c) 2009 by Tilman Schmidt <tilman@imap.cc>.
+ *
+ * =====================================================================
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License as
+ *	published by the Free Software Foundation; either version 2 of
+ *	the License, or (at your option) any later version.
+ * =====================================================================
+ */
+
+#include "gigaset.h"
+#include <linux/ctype.h>
+#include <linux/isdn/capilli.h>
+#include <linux/isdn/capicmd.h>
+#include <linux/isdn/capiutil.h>
+
+/* missing from kernelcapi.h */
+#define CapiNcpiNotSupportedByProtocol	0x0001
+#define CapiFlagsNotSupportedByProtocol	0x0002
+#define CapiAlertAlreadySent		0x0003
+
+/* missing from capicmd.h */
+#define CAPI_CONNECT_IND_BASELEN	(CAPI_MSG_BASELEN+4+2+8*1)
+#define CAPI_CONNECT_ACTIVE_IND_BASELEN	(CAPI_MSG_BASELEN+4+3*1)
+#define CAPI_CONNECT_B3_IND_BASELEN	(CAPI_MSG_BASELEN+4+1)
+#define CAPI_CONNECT_B3_ACTIVE_IND_BASELEN	(CAPI_MSG_BASELEN+4+1)
+#undef CAPI_DATA_B3_REQ_LEN
+#define CAPI_DATA_B3_REQ_LEN		(CAPI_MSG_BASELEN+4+4+2+2+2+8)
+#define CAPI_DATA_B3_CONF_LEN		(CAPI_MSG_BASELEN+4+2+2)
+#define CAPI_DISCONNECT_IND_LEN		(CAPI_MSG_BASELEN+4+2)
+#define CAPI_DISCONNECT_B3_IND_BASELEN	(CAPI_MSG_BASELEN+4+2+1)
+/* most _CONF messages contain only Controller/PLCI/NCCI and Info parameters */
+#define CAPI_STDCONF_LEN		(CAPI_MSG_BASELEN+4+2)
+
+/* missing from capiutil.h */
+#define CAPIMSG_DATAHANDLE(m)	CAPIMSG_U16(m,18) /* DATA_B3_REQ */
+#define CAPIMSG_FLAGS(m)	CAPIMSG_U16(m,20) /* DATA_B3_REQ */
+
+/* Flags (DATA_B3_REQ, DATA_B3_IND) */
+#define CAPI_FLAGS_DELIVERY_CONFIRMATION	0x04
+#define CAPI_FLAGS_RESERVED	(~0x1f)
+
+/* buffer sizes */
+#define MAX_BC_OCTETS 11
+#define MAX_HLC_OCTETS 3
+#define MAX_NUMBER_DIGITS 20
+#define MAX_FMT_IE_LEN 20
+
+/* registered application data structure */
+struct gigaset_capi_appl {
+	struct list_head ctrlist;
+	struct gigaset_capi_appl *bcnext;
+	u16 id;
+	u32 listenInfoMask;
+	u32 listenCIPmask;
+	u16 nextMessageNumber;
+};
+
+/* CAPI specific controller data structure */
+struct gigaset_capi_ctr {
+	struct capi_ctr ctr;
+	struct list_head appls;
+	int b3conn[BAS_CHANNELS];
+	struct mutex ctr_mtx;
+	/* two _cmsg structures possibly used concurrently: */
+	_cmsg hcmsg;	/* for message composition triggered from hardware */
+	_cmsg acmsg;	/* for dissection of messages sent from application */
+	u8 bc_buf[MAX_BC_OCTETS+1];
+	u8 hlc_buf[MAX_HLC_OCTETS+1];
+	u8 cgpty_buf[MAX_NUMBER_DIGITS+3];
+	u8 cdpty_buf[MAX_NUMBER_DIGITS+2];
+};
+
+/* CIP Value table (from CAPI 2.0 standard, ch. 6.1) */
+struct {
+	u8 *bc;
+	u8 *hlc;
+} cip2bchlc[] = {
+	[ 1] = { "8090A3", NULL },
+		/* Speech (A-law) */
+	[ 2] = { "8890", NULL },
+		/* Unrestricted digital information */
+	[ 3] = { "8990", NULL },
+		/* Restricted digital information */
+	[ 4] = { "9090A3", NULL },
+		/* 3,1 kHz audio (A-law) */
+	[ 5] = { "9190", NULL },
+		/* 7 kHz audio */
+	[ 6] = { "9890", NULL },
+		/* Video */
+	[ 7] = { "88C0C6E6", NULL },
+		/* Packet mode */
+	[ 8] = { "8890218F", NULL },
+		/* 56 kbit/s rate adaptation */
+	[ 9] = { "9190A5", NULL },
+		/* Unrestricted digital information with tones/announcements */
+	[16] = { "8090A3", "9181" },
+		/* Telephony */
+	[17] = { "9090A3", "9184" },
+		/* Group 2/3 facsimile */
+	[18] = { "8890", "91A1" },
+		/* Group 4 facsimile Class 1 */
+	[19] = { "8890", "91A4" },
+		/* Teletex service basic and mixed mode
+		   and Group 4 facsimile service Classes II and III */
+	[20] = { "8890", "91A8" },
+		/* Teletex service basic and processable mode */
+	[21] = { "8890", "91B1" },
+		/* Teletex service basic mode */
+	[22] = { "8890", "91B2" },
+		/* International interworking for Videotex */
+	[23] = { "8890", "91B5" },
+		/* Telex */
+	[24] = { "8890", "91B8" },
+		/* Message Handling Systems in accordance with X.400 */
+	[25] = { "8890", "91C1" },
+		/* OSI application in accordance with X.200 */
+	[26] = { "9190A5", "9181" },
+		/* 7 kHz telephony */
+	[27] = { "9190A5", "916001" },
+		/* Video telephony, first connection */
+	[28] = { "8890", "916002" },
+		/* Video telephony, second connection */
+};
+
+/*
+ * helper functions
+ * ================
+ */
+
+/*
+ * emit unsupported parameter warning
+ */
+static inline void ignore_cstruct_param(struct cardstate *cs, _cstruct param,
+				       char *msgname, char *paramname)
+{
+	if (param && *param)
+		dev_warn(cs->dev, "%s: ignoring unsupported parameter: %s\n",
+			 msgname, paramname);
+}
+
+static inline void ignore_cmstruct_param(struct cardstate *cs, _cmstruct param,
+				       char *msgname, char *paramname)
+{
+	if (param != CAPI_DEFAULT)
+		dev_warn(cs->dev, "%s: ignoring unsupported parameter: %s\n",
+			 msgname, paramname);
+}
+
+/*
+ * check for legal hex digit
+ */
+static inline int ishexdigit(char c)
+{
+	if (c >= '0' && c <= '9')
+		return 1;
+	if (c >= 'A' && c <= 'F')
+		return 1;
+	if (c >= 'a' && c <= 'f')
+		return 1;
+	return 0;
+}
+
+/*
+ * convert hex to binary
+ */
+static inline u8 hex2bin(char c)
+{
+	int result = c & 0x0f;
+	if (c & 0x40) result += 9;
+	return result;
+}
+
+/*
+ * convert an IE from Gigaset hex string to ETSI binary representation
+ * including length byte
+ * return value: result length, -1 on error
+ */
+static int encode_ie(char *in, u8 *out, int maxlen)
+{
+	int l = 0;
+	while (*in) {
+		if (!ishexdigit(in[0]) || !ishexdigit(in[1]) || l >= maxlen)
+			return -1;
+		out[++l] = (hex2bin(in[0]) << 4) + hex2bin(in[1]);
+		in += 2;
+	}
+	out[0] = l;
+	return l;
+}
+
+/*
+ * convert an IE from ETSI binary representation including length byte
+ * to Gigaset hex string
+ */
+static void decode_ie(u8 *in, char *out)
+{
+	int i = *in;
+	while (i-- > 0) {
+		/* ToDo: conversion to upper case necessary? */
+		*out++ = toupper(hex_asc_hi(*++in));
+		*out++ = toupper(hex_asc_lo(*in));
+	}
+}
+
+/*
+ * retrieve application data structure for an application ID
+ */
+static inline struct gigaset_capi_appl *
+get_appl(struct gigaset_capi_ctr *iif, u16 appl)
+{
+	struct gigaset_capi_appl *ap;
+
+	list_for_each_entry(ap, &iif->appls, ctrlist)
+		if (ap->id == appl)
+			return ap;
+	return NULL;
+}
+
+/*
+ * dump CAPI message to kernel messages for debugging
+ */
+static inline void dump_cmsg(enum debuglevel level, const char *tag, _cmsg *p)
+{
+#ifdef CONFIG_GIGASET_DEBUG
+	_cdebbuf *cdb;
+
+	if (!(gigaset_debuglevel & level))
+		return;
+
+	cdb = capi_cmsg2str(p);
+	if (cdb) {
+		gig_dbg(level, "%s: [%d] %s", tag, p->ApplId, cdb->buf);
+		cdebbuf_free(cdb);
+	} else {
+		gig_dbg(level, "%s: [%d] %s", tag, p->ApplId,
+			capi_cmd2str(p->Command, p->Subcommand));
+	}
+#endif
+}
+
+/*
+ * format CAPI IE as string
+ */
+
+static const char *format_ie(const char *ie)
+{
+	static char result[3*MAX_FMT_IE_LEN];
+	int len, count;
+	char *pout = result;
+
+	if (!ie)
+		return "NULL";
+
+	count = len = ie[0];
+	if (count > MAX_FMT_IE_LEN)
+		count = MAX_FMT_IE_LEN-1;
+	while (count--) {
+		*pout++ = hex_asc_hi(*++ie);
+		*pout++ = hex_asc_lo(*ie);
+		*pout++ = ' ';
+	}
+	if (len > MAX_FMT_IE_LEN) {
+		*pout++ = '.';
+		*pout++ = '.';
+		*pout++ = '.';
+	}
+	*--pout = 0;
+	return result;
+}
+
+
+/*
+ * driver interface functions
+ * ==========================
+ */
+
+/**
+ * gigaset_skb_sent() - acknowledge transmission of outgoing skb
+ * @bcs:	B channel descriptor structure.
+ * @skb:	sent data.
+ *
+ * Called by hardware module {bas,ser,usb}_gigaset when the data in a
+ * skb has been successfully sent, for signalling completion to the LL.
+ */
+void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct gigaset_capi_appl *ap = bcs->ap;
+	struct sk_buff *cskb;
+	u16 flags;
+
+	/* update statistics */
+	++bcs->trans_up;
+
+	if (!ap) {
+		dev_err(cs->dev, "%s: no application\n", __func__);
+		return;
+	}
+
+	/* don't send further B3 messages if logical connection disconnected */
+	if (!iif->b3conn[bcs->channel])
+		return;
+
+	/* prepare DATA_B3_CONF message */
+	/* ToDo: optimization (avoid _cmsg overhead) */
+	capi_cmsg_header(&iif->hcmsg, ap->id, CAPI_DATA_B3, CAPI_CONF,
+			 ap->nextMessageNumber++,
+			 iif->ctr.cnr | ((bcs->channel + 1) << 8) | (1 << 16));
+	iif->hcmsg.DataHandle = CAPIMSG_DATAHANDLE(dskb->head);
+	iif->hcmsg.Info = CAPI_NOERROR;
+
+	/* ToDo: honor unset "delivery confirmation" bit */
+	flags = CAPIMSG_FLAGS(dskb->head);
+
+	/* any other flags are unsupported */
+	if (flags & ~CAPI_FLAGS_DELIVERY_CONFIRMATION)
+		iif->hcmsg.Info = CapiFlagsNotSupportedByProtocol;
+
+	/* build and emit DATA_B3_CONF message */
+	if ((cskb = alloc_skb(CAPI_DATA_B3_CONF_LEN, GFP_ATOMIC)) == NULL) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	capi_cmsg2message(&iif->hcmsg, __skb_put(cskb, CAPI_DATA_B3_CONF_LEN));
+	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
+	capi_ctr_handle_message(&iif->ctr, ap->id, cskb);
+}
+EXPORT_SYMBOL_GPL(gigaset_skb_sent);
+
+/**
+ * gigaset_skb_rcvd() - pass received skb to LL
+ * @bcs:	B channel descriptor structure.
+ * @skb:	received data.
+ *
+ * Called by hardware module {bas,ser,usb}_gigaset when user data has
+ * been successfully received, for passing to the LL.
+ * Warning: skb must not be accessed anymore!
+ */
+void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct gigaset_capi_appl *ap = bcs->ap;
+
+	/* update statistics */
+	bcs->trans_down++;
+
+	if (!ap) {
+		dev_err(cs->dev, "%s: no application\n", __func__);
+		return;
+	}
+
+	/*
+	 * prepare DATA_B3_IND message
+	 * Parameters: NCCI = 1, all others 0/unused
+	 */
+	/* ToDo: optimization (avoid _cmsg overhead) */
+	capi_cmsg_header(&iif->hcmsg, ap->id, CAPI_DATA_B3, CAPI_IND,
+			 ap->nextMessageNumber++,
+			 iif->ctr.cnr | ((bcs->channel + 1) << 8) | (1 << 16));
+
+	/* prepend message to payload */
+	if (skb_headroom(skb) < CAPI_DATA_B3_REQ_LEN) {
+		/* shouldn't happen */
+		dev_err(cs->dev,
+			"%s: insufficient skb headroom (%d), packet dropped\n",
+			__func__, skb_headroom(skb));
+		dev_kfree_skb(skb);
+		return;
+	}
+	capi_cmsg2message(&iif->hcmsg, skb_push(skb, CAPI_DATA_B3_REQ_LEN));
+	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
+	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
+}
+EXPORT_SYMBOL_GPL(gigaset_skb_rcvd);
+
+/**
+ * gigaset_isdn_rcv_err() - signal receive error
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by hardware module {bas,ser,usb}_gigaset when a receive error
+ * has occurred, for signalling to the LL.
+ */
+void gigaset_isdn_rcv_err(struct bc_state *bcs)
+{
+	/* if currently ignoring packets, just count down */
+	if (bcs->ignore) {
+		bcs->ignore--;
+		return;
+	}
+
+	/* update statistics */
+	bcs->corrupted++;
+
+	/* ToDo: signal error -> LL */
+}
+EXPORT_SYMBOL_GPL(gigaset_isdn_rcv_err);
+
+/**
+ * gigaset_isdn_icall() - signal incoming call
+ * @at_state:	connection state structure.
+ *
+ * Called by main module at tasklet level to notify the LL that an incoming
+ * call has been received. @at_state contains the parameters of the call.
+ *
+ * Return value: call disposition (ICALL_*)
+ */
+int gigaset_isdn_icall(struct at_state_t *at_state)
+{
+	struct cardstate *cs = at_state->cs;
+	struct bc_state *bcs = at_state->bcs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct gigaset_capi_appl *ap;
+	u32 actCIPmask;
+	struct sk_buff *skb;
+	unsigned int msgsize;
+	int i;
+
+	/*
+	 * ToDo: signal calls without a free B channel, too
+	 * (requires a u8 handle for the at_state structure that can
+	 * be stored in the PLCI and used in the CONNECT_RESP message
+	 * handler to retrieve it)
+	 */
+	if (!bcs)
+		return ICALL_IGNORE;
+
+	/* prepare CONNECT_IND message, using B channel number as PLCI */
+	capi_cmsg_header(&iif->hcmsg, 0, CAPI_CONNECT, CAPI_IND, 0,
+			 iif->ctr.cnr | ((bcs->channel + 1) << 8));
+
+	/* minimum size, all structs empty */
+	msgsize = CAPI_CONNECT_IND_BASELEN;
+
+	/* Bearer Capability (mandatory) */
+	if (at_state->str_var[STR_ZBC]) {
+		/* pass on BC from Gigaset */
+		if (encode_ie(at_state->str_var[STR_ZBC], iif->bc_buf,
+			      MAX_BC_OCTETS) < 0) {
+			dev_warn(cs->dev, "RING ignored - bad BC %s\n",
+				 at_state->str_var[STR_ZBC]);
+			return ICALL_IGNORE;
+		}
+
+		/* look up corresponding CIP value */
+		iif->hcmsg.CIPValue = 0;	/* default if nothing found */
+		for (i = 0; i < ARRAY_SIZE(cip2bchlc); i++)
+			if (cip2bchlc[i].bc != NULL &&
+			    cip2bchlc[i].hlc == NULL &&
+			    !strcmp(cip2bchlc[i].bc,
+				    at_state->str_var[STR_ZBC])) {
+				iif->hcmsg.CIPValue = i;
+				break;
+			}
+	} else {
+		/* no BC (internal call): assume CIP 1 (speech, A-law) */
+		iif->hcmsg.CIPValue = 1;
+		encode_ie(cip2bchlc[1].bc, iif->bc_buf, MAX_BC_OCTETS);
+	}
+	iif->hcmsg.BC = iif->bc_buf;
+	msgsize += iif->hcmsg.BC[0];
+
+	/* High Layer Compatibility (optional) */
+	if (at_state->str_var[STR_ZHLC]) {
+		/* pass on HLC from Gigaset */
+		if (encode_ie(at_state->str_var[STR_ZHLC], iif->hlc_buf,
+			      MAX_HLC_OCTETS) < 0) {
+			dev_warn(cs->dev, "RING ignored - bad HLC %s\n",
+				 at_state->str_var[STR_ZHLC]);
+			return ICALL_IGNORE;
+		}
+		iif->hcmsg.HLC = iif->hlc_buf;
+		msgsize += iif->hcmsg.HLC[0];
+
+		/* look up corresponding CIP value */
+		/* keep BC based CIP value if none found */
+		if (at_state->str_var[STR_ZBC])
+			for (i = 0; i < ARRAY_SIZE(cip2bchlc); i++)
+				if (cip2bchlc[i].hlc != NULL &&
+				    !strcmp(cip2bchlc[i].hlc,
+					    at_state->str_var[STR_ZHLC]) &&
+				    !strcmp(cip2bchlc[i].bc,
+					    at_state->str_var[STR_ZBC])) {
+					iif->hcmsg.CIPValue = i;
+					break;
+				}
+	}
+
+	/* Called Party Number (optional) */
+	if (at_state->str_var[STR_ZCPN]) {
+		i = strlen(at_state->str_var[STR_ZCPN]);
+		if (i > MAX_NUMBER_DIGITS) {
+			dev_warn(cs->dev, "RING ignored - bad number %s\n",
+				 at_state->str_var[STR_ZBC]);
+			return ICALL_IGNORE;
+		}
+		iif->cdpty_buf[0] = i + 1;
+		iif->cdpty_buf[1] = 0x80; /* type / numbering plan unknown */
+		memcpy(iif->cdpty_buf+2, at_state->str_var[STR_ZCPN], i);
+		iif->hcmsg.CalledPartyNumber = iif->cdpty_buf;
+		msgsize += iif->hcmsg.CalledPartyNumber[0];
+	}
+
+	/* Calling Party Number (optional) */
+	if (at_state->str_var[STR_NMBR]) {
+		i = strlen(at_state->str_var[STR_NMBR]);
+		if (i > MAX_NUMBER_DIGITS) {
+			dev_warn(cs->dev, "RING ignored - bad number %s\n",
+				 at_state->str_var[STR_ZBC]);
+			return ICALL_IGNORE;
+		}
+		iif->cgpty_buf[0] = i + 2;
+		iif->cgpty_buf[1] = 0x00; /* type / numbering plan unknown */
+		iif->cgpty_buf[2] = 0x80; /* pres. allowed, not screened */
+		memcpy(iif->cgpty_buf+3, at_state->str_var[STR_NMBR], i);
+		iif->hcmsg.CallingPartyNumber = iif->cgpty_buf;
+		msgsize += iif->hcmsg.CallingPartyNumber[0];
+	}
+
+	/* remaining parameters (not supported, always left NULL):
+	 * - CalledPartySubaddress
+	 * - CallingPartySubaddress
+	 * - AdditionalInfo
+	 *   - BChannelinformation
+	 *   - Keypadfacility
+	 *   - Useruserdata
+	 *   - Facilitydataarray
+	 */
+
+	gig_dbg(DEBUG_CMD, "icall: PLCI %x CIP %d BC %s",
+		iif->hcmsg.adr.adrPLCI, iif->hcmsg.CIPValue,
+		format_ie(iif->hcmsg.BC));
+	gig_dbg(DEBUG_CMD, "icall: HLC %s",
+		format_ie(iif->hcmsg.HLC));
+	gig_dbg(DEBUG_CMD, "icall: CgPty %s",
+		format_ie(iif->hcmsg.CallingPartyNumber));
+	gig_dbg(DEBUG_CMD, "icall: CdPty %s",
+		format_ie(iif->hcmsg.CalledPartyNumber));
+
+	/* scan application list for matching listeners */
+	bcs->ap = NULL;
+	actCIPmask = 1 | (1 << iif->hcmsg.CIPValue);
+	list_for_each_entry(ap, &iif->appls, ctrlist)
+		if (actCIPmask & ap->listenCIPmask) {
+			/* send CONNECT_IND message to this application */
+			iif->hcmsg.ApplId = ap->id;
+			iif->hcmsg.Messagenumber = ap->nextMessageNumber++;
+
+			if ((skb = alloc_skb(msgsize, GFP_ATOMIC)) == NULL) {
+				dev_err(cs->dev, "%s: out of memory\n",
+					__func__);
+				break;
+			}
+			capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize));
+			dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
+			capi_ctr_handle_message(&iif->ctr, ap->id, skb);
+
+			/* add to listeners on this B channel */
+			ap->bcnext = bcs->ap;
+			bcs->ap = ap;
+			bcs->chstate |= CHS_NOTIFY_LL;
+		}
+
+	/*
+	 * Return "accept" if any listeners.
+	 * Gigaset will send ALERTING.
+	 * There doesn't seem to be a way to avoid this.
+	 */
+	return bcs->ap ? ICALL_ACCEPT : ICALL_IGNORE;
+}
+
+/*
+ * send a DISCONNECT_IND message to an application
+ * does not sleep, clobbers the controller's hcmsg structure
+ */
+static void send_disconnect_ind(struct bc_state *bcs,
+				struct gigaset_capi_appl *ap, u16 reason)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct sk_buff *skb;
+
+	/* prepare DISCONNECT_IND message */
+	capi_cmsg_header(&iif->hcmsg, ap->id, CAPI_DISCONNECT, CAPI_IND,
+			 ap->nextMessageNumber++,
+			 iif->ctr.cnr | ((bcs->channel + 1) << 8));
+	iif->hcmsg.Reason = reason;
+
+	/* build and emit DISCONNECT_IND message */
+	if ((skb = alloc_skb(CAPI_DISCONNECT_IND_LEN, GFP_ATOMIC)) == NULL) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, CAPI_DISCONNECT_IND_LEN));
+	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
+	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
+}
+
+/*
+ * send a DISCONNECT_B3_IND message to an application
+ * Parameters: NCCI = 1, NCPI empty, Reason_B3 = 0
+ * does not sleep, clobbers the controller's hcmsg structure
+ */
+void send_disconnect_b3_ind(struct bc_state *bcs, struct gigaset_capi_appl *ap)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct sk_buff *skb;
+
+	capi_cmsg_header(&iif->hcmsg, ap->id, CAPI_DISCONNECT_B3, CAPI_IND,
+			 ap->nextMessageNumber++,
+			 iif->ctr.cnr | ((bcs->channel + 1) << 8) | (1 << 16));
+	if ((skb = alloc_skb(CAPI_DISCONNECT_B3_IND_BASELEN, GFP_ATOMIC))
+	    == NULL) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	capi_cmsg2message(&iif->hcmsg,
+			  __skb_put(skb, CAPI_DISCONNECT_B3_IND_BASELEN));
+	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
+	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
+}
+
+/**
+ * gigaset_isdn_connD() - signal D channel connect
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module at tasklet level to notify the LL that the D channel
+ * connection has been established.
+ */
+void gigaset_isdn_connD(struct bc_state *bcs)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct gigaset_capi_appl *ap = bcs->ap;
+	struct sk_buff *skb;
+	unsigned int msgsize;
+
+	if (!ap) {
+		dev_err(cs->dev, "%s: no application\n", __func__);
+		return;
+	}
+	while (ap->bcnext) {
+		/* this should never happen */
+		dev_warn(cs->dev, "%s: dropping extra application %u\n",
+			 __func__, ap->bcnext->id);
+		send_disconnect_ind(bcs, ap->bcnext,
+				    CapiCallGivenToOtherApplication);
+		ap->bcnext = ap->bcnext->bcnext;
+	}
+
+	/* prepare CONNECT_ACTIVE_IND message
+	 * Note: LLC not supported by device
+	 */
+	capi_cmsg_header(&iif->hcmsg, ap->id, CAPI_CONNECT_ACTIVE, CAPI_IND,
+			 ap->nextMessageNumber++,
+			 iif->ctr.cnr | ((bcs->channel + 1) << 8));
+
+	/* minimum size, all structs empty */
+	msgsize = CAPI_CONNECT_ACTIVE_IND_BASELEN;
+
+	/* ToDo: set parameter: Connected number
+	 * (requires ev-layer state machine extension to collect
+	 * ZCON device reply)
+	 */
+
+	/* build and emit CONNECT_ACTIVE_IND message */
+	if ((skb = alloc_skb(msgsize, GFP_ATOMIC)) == NULL) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize));
+	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
+	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
+}
+
+/**
+ * gigaset_isdn_hupD() - signal D channel hangup
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module at tasklet level to notify the LL that the D channel
+ * connection has been shut down.
+ */
+void gigaset_isdn_hupD(struct bc_state *bcs)
+{
+	struct gigaset_capi_ctr *iif = bcs->cs->iif;
+	struct gigaset_capi_appl *ap;
+
+	/*
+	 * ToDo: pass on reason code reported by device
+	 * (requires ev-layer state machine extension to collect
+	 * ZCAU device reply)
+	 */
+	for (ap = bcs->ap; ap != NULL; ap = ap->bcnext) {
+		if (iif->b3conn[bcs->channel]) {
+			iif->b3conn[bcs->channel] = 0;
+		 	send_disconnect_b3_ind(bcs, ap);
+		}
+		send_disconnect_ind(bcs, ap, 0);
+	}
+	bcs->ap = NULL;
+}
+
+/**
+ * gigaset_isdn_connB() - signal B channel connect
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module at tasklet level to notify the LL that the B channel
+ * connection has been established.
+ */
+void gigaset_isdn_connB(struct bc_state *bcs)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct gigaset_capi_appl *ap = bcs->ap;
+	struct sk_buff *skb;
+	unsigned int msgsize;
+	u8 command;
+
+	if (!ap) {
+		dev_err(cs->dev, "%s: no application\n", __func__);
+		return;
+	}
+	while (ap->bcnext) {
+		/* this should never happen */
+		dev_warn(cs->dev, "%s: dropping extra application %u\n",
+			 __func__, ap->bcnext->id);
+		send_disconnect_ind(bcs, ap->bcnext,
+				    CapiCallGivenToOtherApplication);
+		ap->bcnext = ap->bcnext->bcnext;
+	}
+
+	/*
+	 * emit CONNECT_B3_ACTIVE_IND if we already got CONNECT_B3_REQ;
+	 * otherwise we have to emit CONNECT_B3_IND first, and follow up with
+	 * CONNECT_B3_ACTIVE_IND in reply to CONNECT_B3_RESP
+	 * Parameters in both cases always: NCCI = 1, NCPI empty
+	 */
+	if (iif->b3conn[bcs->channel]) {
+		command = CAPI_CONNECT_B3_ACTIVE;
+		msgsize = CAPI_CONNECT_B3_ACTIVE_IND_BASELEN;
+	} else {
+		command = CAPI_CONNECT_B3;
+		msgsize = CAPI_CONNECT_B3_IND_BASELEN;
+	}
+	capi_cmsg_header(&iif->hcmsg, ap->id, command, CAPI_IND,
+			 ap->nextMessageNumber++,
+			 iif->ctr.cnr | ((bcs->channel + 1) << 8) | (1 << 16));
+	if ((skb = alloc_skb(msgsize, GFP_ATOMIC)) == NULL) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize));
+	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
+	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
+	iif->b3conn[bcs->channel] = 1;
+}
+
+/**
+ * gigaset_isdn_hupB() - signal B channel hangup
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module to notify the LL that the B channel connection has
+ * been shut down.
+ */
+void gigaset_isdn_hupB(struct bc_state *bcs)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_ctr *iif = cs->iif;
+	struct gigaset_capi_appl *ap = bcs->ap;
+
+	/* ToDo: assure order of DISCONNECT_B3_IND and DISCONNECT_IND ? */
+
+	/* nothing to do if no logical connection active */
+	if (!iif->b3conn[bcs->channel])
+		return;
+	iif->b3conn[bcs->channel] = 0;
+
+	if (!ap) {
+		dev_err(cs->dev, "%s: no application\n", __func__);
+		return;
+	}
+
+	send_disconnect_b3_ind(bcs, ap);
+}
+
+/**
+ * gigaset_isdn_start() - signal device availability
+ * @cs:		device descriptor structure.
+ *
+ * Called by main module to notify the LL that the device is available for
+ * use.
+ */
+void gigaset_isdn_start(struct cardstate *cs)
+{
+	struct gigaset_capi_ctr *iif = cs->iif;
+
+	/* fill profile data: manufacturer name */
+	strcpy(iif->ctr.manu, "Siemens");
+	/* CAPI and device version */
+	iif->ctr.version.majorversion = 2;		/* CAPI 2.0 */
+	iif->ctr.version.minorversion = 0;
+	/* ToDo: check/assert cs->gotfwver? */
+	iif->ctr.version.majormanuversion = cs->fwver[0];
+	iif->ctr.version.minormanuversion = cs->fwver[1];
+	/* number of B channels supported */
+	iif->ctr.profile.nbchannel = cs->channels;
+	/* global options: internal controller, supplementary services */
+	iif->ctr.profile.goptions = 0x11;
+	/* B1 protocols: 64 kbit/s HDLC or transparent */
+	iif->ctr.profile.support1 =  0x03;
+	/* B2 protocols: transparent only */
+	/* ToDo: X.75 SLP ? */
+	iif->ctr.profile.support2 =  0x02;
+	/* B3 protocols: transparent only */
+	iif->ctr.profile.support3 =  0x01;
+	/* no serial number */
+	strcpy(iif->ctr.serial, "0");
+	capi_ctr_ready(&iif->ctr);
+}
+
+/**
+ * gigaset_isdn_stop() - signal device unavailability
+ * @cs:		device descriptor structure.
+ *
+ * Called by main module to notify the LL that the device is no longer
+ * available for use.
+ */
+void gigaset_isdn_stop(struct cardstate *cs)
+{
+	struct gigaset_capi_ctr *iif = cs->iif;
+	capi_ctr_down(&iif->ctr);
+}
+
+/*
+ * kernel CAPI callback methods
+ * ============================
+ */
+
+/*
+ * load firmware
+ */
+static int gigaset_load_firmware(struct capi_ctr *ctr, capiloaddata *data)
+{
+	struct cardstate *cs = ctr->driverdata;
+
+	/* AVM specific operation, not needed for Gigaset -- ignore */
+	dev_notice(cs->dev, "load_firmware ignored\n");
+
+	return 0;
+}
+
+/*
+ * reset (deactivate) controller
+ */
+static void gigaset_reset_ctr(struct capi_ctr *ctr)
+{
+	struct cardstate *cs = ctr->driverdata;
+
+	/* AVM specific operation, not needed for Gigaset -- ignore */
+	dev_notice(cs->dev, "reset_ctr ignored\n");
+}
+
+/*
+ * register CAPI application
+ */
+static void gigaset_register_appl(struct capi_ctr *ctr, u16 appl,
+			   capi_register_params *rp)
+{
+	struct gigaset_capi_ctr *iif
+		= container_of(ctr, struct gigaset_capi_ctr, ctr);
+	struct cardstate *cs = ctr->driverdata;
+	struct gigaset_capi_appl *ap;
+
+	list_for_each_entry(ap, &iif->appls, ctrlist)
+		if (ap->id == appl) {
+			dev_notice(cs->dev,
+				   "application %u already registered\n", appl);
+			return;
+		}
+
+	if ((ap = kzalloc(sizeof(*ap), GFP_KERNEL)) == NULL) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	ap->id = appl;
+
+	list_add(&ap->ctrlist, &iif->appls);
+}
+
+/*
+ * release CAPI application
+ */
+static void gigaset_release_appl(struct capi_ctr *ctr, u16 appl)
+{
+	struct gigaset_capi_ctr *iif
+		= container_of(ctr, struct gigaset_capi_ctr, ctr);
+	struct gigaset_capi_appl *ap, *tmp;
+
+	list_for_each_entry_safe(ap, tmp, &iif->appls, ctrlist)
+		if (ap->id == appl) {
+			list_del(&ap->ctrlist);
+			kfree(ap);
+		}
+
+}
+
+/*
+ * process CONNECT_REQ message
+ * allocates a B channel, prepares dial commands, and queues a DIAL event
+ * return value: CAPI Info value, CAPI_MSGOSRESOURCEERR if out of memory
+ */
+static u16 do_connect_req(struct cardstate *cs, _cmsg *cmsg,
+			  struct gigaset_capi_appl *ap)
+{
+	struct bc_state *bcs;
+	char **commands;
+	char *s;
+	u8 *pp;
+	int i, l;
+
+	/* get free B channel & construct PLCI */
+	if ((bcs = gigaset_get_free_channel(cs)) == NULL) {
+		dev_notice(cs->dev, "%s: no B channel available\n",
+			   "CONNECT_REQ");
+		return CapiNoPlciAvailable;
+	}
+	ap->bcnext = NULL;
+	bcs->ap = ap;
+	cmsg->adr.adrPLCI |= (bcs->channel + 1) << 8;
+
+	/* build command table */
+	if ((commands = kzalloc(AT_NUM*(sizeof *commands), GFP_KERNEL)) == NULL)
+		goto oom;
+
+	/* encode parameter: Called party number */
+	pp = cmsg->CalledPartyNumber;
+	if (pp == NULL || *pp == 0) {
+		dev_notice(cs->dev, "%s: %s missing\n",
+			   "CONNECT_REQ", "Called party number");
+		return CapiIllMessageParmCoding;
+	}
+	l = *pp++;
+	/* check number type/numbering plan byte */
+	if (*pp != 0x80) {
+		dev_notice(cs->dev, "%s: %s type/plan 0x%02x unsupported\n",
+			   "CONNECT_REQ", "Called party number", *pp);
+		return CapiIllMessageParmCoding;
+	}
+	pp++;
+	l--;
+	/* translate "**" internal call prefix to CTP value */
+	if (l >= 2 && pp[0] == '*' && pp[1] == '*') {
+		s = "^SCTP=0\r";
+		pp += 2;
+		l -= 2;
+	} else {
+		s = "^SCTP=1\r";
+	}
+	if ((commands[AT_TYPE] = kstrdup(s, GFP_KERNEL)) == NULL ||
+	    (commands[AT_DIAL] = kmalloc(l+3, GFP_KERNEL)) == NULL)
+		goto oom;
+	snprintf(commands[AT_DIAL], l+3, "D%*s\r", l, pp);
+
+	/* encode parameter: Calling party number */
+	pp = cmsg->CallingPartyNumber;
+	if (pp != NULL && *pp > 0) {
+		l = *pp++;
+		/* check number type/numbering plan byte */
+		if (*pp & 0x7f) {
+			dev_notice(cs->dev,
+				   "%s: %s type/plan 0x%02x unsupported\n",
+				   "CONNECT_REQ", "Calling party number",
+				   *pp & 0x7f);
+			return CapiIllMessageParmCoding;
+		}
+		if (*pp & 0x80) {
+			/* octet 3a present */
+			if (l < 2) {
+				dev_notice(cs->dev, "%s: %s IE truncated\n",
+					   "CONNECT_REQ",
+					   "Calling party number");
+				return CapiIllMessageParmCoding;
+			}
+			pp++;
+			l--;
+			/* Presentation/Screening indicator */
+			switch (*pp) {
+			case 0x00:	/* Presentation allowed */
+				s = "^SCLIP=1\r";
+				break;
+			case 0x20:	/* Presentation restricted */
+				s = "^SCLIP=0\r";
+				break;
+			default:
+				dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
+					   "CONNECT_REQ",
+					   "Presentation/Screening indicator",
+					   *pp);
+				return CapiIllMessageParmCoding;
+			}
+			if ((commands[AT_CLIP] = kstrdup(s, GFP_KERNEL))
+			    == NULL)
+				goto oom;
+		}
+		pp++;
+		l--;
+		if (l) {
+			/* number */
+			if ((commands[AT_MSN] = kmalloc(l+8, GFP_KERNEL))
+			    == NULL)
+				goto oom;
+			snprintf(commands[AT_MSN], l+8, "^SMSN=%*s\r", l, pp);
+		}
+	}
+
+	/* check parameter: CIP Value */
+	if (cmsg->CIPValue > ARRAY_SIZE(cip2bchlc) ||
+	    (cmsg->CIPValue > 0 && cip2bchlc[cmsg->CIPValue].bc == NULL)) {
+		dev_notice(cs->dev, "%s: unknown CIP value %d\n",
+			   "CONNECT_REQ", cmsg->CIPValue);
+		return CapiCipValueUnknown;
+	}
+
+	/* check/encode parameter: BC */
+	if (cmsg->BC && cmsg->BC[0]) {
+		/* explicit BC overrides CIP */
+		l = 2*cmsg->BC[0] + 7;
+		if ((commands[AT_BC] = kmalloc(l, GFP_KERNEL)) == NULL)
+			goto oom;
+		strcpy(commands[AT_BC], "^SBC=");
+		decode_ie(cmsg->BC, commands[AT_BC]+5);
+		strcpy(commands[AT_BC] + l - 2, "\r");
+	} else if (cip2bchlc[cmsg->CIPValue].bc) {
+		l = strlen(cip2bchlc[cmsg->CIPValue].bc) + 7;
+		if ((commands[AT_BC] = kmalloc(l, GFP_KERNEL)) == NULL)
+			goto oom;
+		snprintf(commands[AT_BC], l, "^SBC=%s\r",
+			 cip2bchlc[cmsg->CIPValue].bc);
+	}
+
+	/* check/encode parameter: HLC */
+	if (cmsg->HLC && cmsg->HLC[0]) {
+		/* explicit HLC overrides CIP */
+		l = 2*cmsg->HLC[0] + 7;
+		if ((commands[AT_HLC] = kmalloc(l, GFP_KERNEL)) == NULL)
+			goto oom;
+		strcpy(commands[AT_HLC], "^SHLC=");
+		decode_ie(cmsg->HLC, commands[AT_HLC]+5);
+		strcpy(commands[AT_HLC] + l - 2, "\r");
+	} else if (cip2bchlc[cmsg->CIPValue].hlc) {
+		l = strlen(cip2bchlc[cmsg->CIPValue].hlc) + 7;
+		if ((commands[AT_HLC] = kmalloc(l, GFP_KERNEL)) == NULL)
+			goto oom;
+		snprintf(commands[AT_HLC], l, "^SHLC=%s\r",
+			 cip2bchlc[cmsg->CIPValue].hlc);
+	}
+
+	/* check/encode parameter: B Protocol */
+	if (cmsg->BProtocol == CAPI_DEFAULT) {
+		bcs->proto2 = L2_HDLC;
+		dev_warn(cs->dev,
+		    "B2 Protocol X.75 SLP unsupported, using Transparent\n");
+	} else {
+		switch (cmsg->B1protocol) {
+		case 0:
+			bcs->proto2 = L2_HDLC;
+			break;
+		case 1:
+			bcs->proto2 = L2_BITSYNC;
+			break;
+		default:
+			dev_warn(cs->dev,
+			    "B1 Protocol %u unsupported, using Transparent\n",
+				 cmsg->B1protocol);
+			bcs->proto2 = L2_BITSYNC;
+		}
+		if (cmsg->B2protocol != 1)
+			dev_warn(cs->dev,
+			    "B2 Protocol %u unsupported, using Transparent\n",
+				 cmsg->B2protocol);
+		if (cmsg->B3protocol != 0)
+			dev_warn(cs->dev,
+			    "B3 Protocol %u unsupported, using Transparent\n",
+				 cmsg->B3protocol);
+		ignore_cstruct_param(cs, cmsg->B1configuration,
+					"CONNECT_REQ", "B1 Configuration");
+		ignore_cstruct_param(cs, cmsg->B2configuration,
+					"CONNECT_REQ", "B2 Configuration");
+		ignore_cstruct_param(cs, cmsg->B3configuration,
+					"CONNECT_REQ", "B3 Configuration");
+	}
+	if ((commands[AT_PROTO] = kmalloc(9, GFP_KERNEL)) == NULL)
+		goto oom;
+	snprintf(commands[AT_PROTO], 9, "^SBPR=%u\r", bcs->proto2);
+
+	/* ToDo: check/encode remaining parameters */
+	ignore_cstruct_param(cs, cmsg->CalledPartySubaddress,
+					"CONNECT_REQ", "Called pty subaddr");
+	ignore_cstruct_param(cs, cmsg->CallingPartySubaddress,
+					"CONNECT_REQ", "Calling pty subaddr");
+	ignore_cstruct_param(cs, cmsg->LLC,
+					"CONNECT_REQ", "LLC");
+	ignore_cmstruct_param(cs, cmsg->AdditionalInfo,
+					"CONNECT_REQ", "Additional Info");
+
+	/* encode parameter: B channel to use */
+	if ((commands[AT_ISO] = kmalloc(9, GFP_KERNEL)) == NULL)
+		goto oom;
+	snprintf(commands[AT_ISO], 9, "^SISO=%u\r",
+		 (unsigned) bcs->channel + 1);
+
+	/* queue & schedule EV_DIAL event */
+	if (!gigaset_add_event(cs, &bcs->at_state, EV_DIAL, commands,
+			       bcs->at_state.seq_index, NULL))
+		goto oom;
+	gig_dbg(DEBUG_CMD, "scheduling DIAL");
+	gigaset_schedule_event(cs);
+	return CapiSuccess;
+
+oom:
+	dev_err(cs->dev, "%s: out of memory\n", __func__);
+	if (commands)
+		for (i = 0; i < AT_NUM; i++)
+			kfree(commands[i]);
+	kfree(commands);
+	gigaset_free_channel(bcs);
+	return CAPI_MSGOSRESOURCEERR;
+}
+
+/*
+ * process DISCONNECT_REQ message
+ * schedule EV_HUP and emit DISCONNECT_B3_IND if necessary
+ * return value: CAPI Info value, CAPI_MSGOSRESOURCEERR if out of memory
+ */
+static u16 do_disconnect_req(struct cardstate *cs, struct gigaset_capi_ctr *iif,
+			     struct gigaset_capi_appl *ap)
+{
+	struct bc_state *bcs;
+	_cmsg *b3cmsg;
+	struct sk_buff *skb;
+	int channel;
+
+	/* extract and check channel number from PLCI */
+	channel = (iif->acmsg.adr.adrPLCI >> 8) & 0xff;
+	if (!channel || channel > cs->channels) {
+		dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
+			   "CAPI_DISCONNECT_REQ", "PLCI",
+			   iif->acmsg.adr.adrPLCI);
+		return CapiIllContrPlciNcci;
+	}
+	bcs = cs->bcs + channel - 1;
+
+	/* ToDo: process parameter: Additional info */
+	ignore_cmstruct_param(cs, iif->acmsg.AdditionalInfo,
+			      "DISCONNECT_REQ", "Additional Info");
+
+	/* check for active logical connection */
+	if (iif->b3conn[channel-1]) {
+		/*
+		 * emit DISCONNECT_B3_IND with cause 0x3301
+		 * use separate cmsg structure, as the content of iif->acmsg
+		 * is still needed for creating the _CONF message
+		 */
+		if ((b3cmsg = kmalloc(sizeof(*b3cmsg), GFP_KERNEL)) == NULL) {
+			dev_err(cs->dev, "%s: out of memory\n", __func__);
+			return CAPI_MSGOSRESOURCEERR;
+		}
+		capi_cmsg_header(b3cmsg, ap->id, CAPI_DISCONNECT_B3, CAPI_IND,
+				 ap->nextMessageNumber++,
+				 iif->ctr.cnr | ((bcs->channel + 1) << 8) |
+				 (1 << 16));
+		b3cmsg->Reason_B3 = CapiProtocolErrorLayer1;
+		skb = alloc_skb(CAPI_DISCONNECT_B3_IND_BASELEN, GFP_KERNEL);
+		if (skb == NULL) {
+			dev_err(cs->dev, "%s: out of memory\n", __func__);
+			return CAPI_MSGOSRESOURCEERR;
+		}
+		capi_cmsg2message(b3cmsg,
+			__skb_put(skb, CAPI_DISCONNECT_B3_IND_BASELEN));
+		kfree(b3cmsg);
+	}
+
+	/* trigger hangup, causing eventual DISCONNECT_IND */
+	/* ToDo: skip if DISCONNECT_IND already sent */
+	if (!gigaset_add_event(cs, &bcs->at_state, EV_HUP, NULL, 0, NULL)) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return CAPI_MSGOSRESOURCEERR;
+	}
+	gig_dbg(DEBUG_CMD, "scheduling HUP");
+	gigaset_schedule_event(cs);
+	return CapiSuccess;
+}
+
+/*
+ * process CONNECT_RESP message
+ * checks protocol parameters and queues an ACCEPT or HUP event
+ * return value: CAPI result code, CAPI_MSGOSRESOURCEERR if out of memory
+ */
+static int do_connect_resp(struct cardstate *cs, _cmsg *cmsg,
+			   struct gigaset_capi_appl *ap)
+{
+	struct bc_state *bcs;
+	struct gigaset_capi_appl *oap;
+	int channel;
+
+	/* extract and check channel number from PLCI */
+	channel = (cmsg->adr.adrPLCI >> 8) & 0xff;
+	if (!channel || channel > cs->channels) {
+		dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
+			   "CAPI_CONNECT_RESP", "PLCI", cmsg->adr.adrPLCI);
+		return CapiIllContrPlciNcci;
+	}
+	bcs = cs->bcs + channel - 1;
+
+	switch (cmsg->Reject) {
+	case 0:		/* Accept */
+		/* drop all competing applications, keep only this one */
+		for (oap = bcs->ap; oap != NULL; oap = oap->bcnext)
+			if (oap != ap)
+				send_disconnect_ind(bcs, oap,
+					CapiCallGivenToOtherApplication);
+		ap->bcnext = NULL;
+		bcs->ap = ap;
+		bcs->chstate |= CHS_NOTIFY_LL;
+
+		/* check/encode B channel protocol */
+		if (cmsg->BProtocol == CAPI_DEFAULT) {
+			bcs->proto2 = L2_HDLC;
+			dev_warn(cs->dev,
+		"B2 Protocol X.75 SLP unsupported, using Transparent\n");
+		} else {
+			switch (cmsg->B1protocol) {
+			case 0:
+				bcs->proto2 = L2_HDLC;
+				break;
+			case 1:
+				bcs->proto2 = L2_BITSYNC;
+				break;
+			default:
+				dev_warn(cs->dev,
+			"B1 Protocol %u unsupported, using Transparent\n",
+					 cmsg->B1protocol);
+				bcs->proto2 = L2_BITSYNC;
+			}
+			if (cmsg->B2protocol != 1)
+				dev_warn(cs->dev,
+			"B2 Protocol %u unsupported, using Transparent\n",
+					 cmsg->B2protocol);
+			if (cmsg->B3protocol != 0)
+				dev_warn(cs->dev,
+			"B3 Protocol %u unsupported, using Transparent\n",
+					 cmsg->B3protocol);
+			ignore_cstruct_param(cs, cmsg->B1configuration,
+					"CONNECT_RESP", "B1 Configuration");
+			ignore_cstruct_param(cs, cmsg->B2configuration,
+					"CONNECT_RESP", "B2 Configuration");
+			ignore_cstruct_param(cs, cmsg->B3configuration,
+					"CONNECT_RESP", "B3 Configuration");
+		}
+
+		/* ToDo: check/encode remaining parameters */
+		ignore_cstruct_param(cs, cmsg->ConnectedNumber,
+					"CONNECT_RESP", "Connected Number");
+		ignore_cstruct_param(cs, cmsg->ConnectedSubaddress,
+					"CONNECT_RESP", "Connected Subaddress");
+		ignore_cstruct_param(cs, cmsg->LLC,
+					"CONNECT_RESP", "LLC");
+		ignore_cmstruct_param(cs, cmsg->AdditionalInfo,
+					"CONNECT_RESP", "Additional Info");
+
+		/* Accept call */
+		if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
+				       EV_ACCEPT, NULL, 0, NULL))
+			return CAPI_MSGOSRESOURCEERR;
+		gig_dbg(DEBUG_CMD, "scheduling ACCEPT");
+		gigaset_schedule_event(cs);
+		return CAPI_NOERROR;
+
+	case 1:			/* Ignore */
+		/* send DISCONNECT_IND to this application */
+		send_disconnect_ind(bcs, ap, 0);
+
+		/* remove it from the list of listening apps */
+		if (bcs->ap == ap) {
+			if ((bcs->ap = ap->bcnext) == NULL)
+				/* last one: stop ev-layer hupD notifications */
+				bcs->chstate &= ~CHS_NOTIFY_LL;
+			return CAPI_NOERROR;
+		} else {
+			for (oap = bcs->ap; oap != NULL; oap = oap->bcnext)
+				if (oap->bcnext == ap) {
+					oap->bcnext = oap->bcnext->bcnext;
+					return CAPI_NOERROR;
+				}
+		}
+		dev_err(cs->dev, "%s: application %u not found", __func__,
+			ap->id);
+		/* don't bother our caller */
+		return CAPI_NOERROR;
+
+	default:		/* Reject */
+		/* drop all competing applications, keep only this one */
+		for (oap = bcs->ap; oap != NULL; oap = oap->bcnext)
+			if (oap != ap)
+				send_disconnect_ind(bcs, oap,
+					CapiCallGivenToOtherApplication);
+		ap->bcnext = NULL;
+		bcs->ap = ap;
+
+		/* reject call - will trigger DISCONNECT_IND for this app */
+		dev_info(cs->dev, "%s: Reject=%x\n",
+			 "CAPI_CONNECT_RESP", cmsg->Reject);
+		if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
+				       EV_HUP, NULL, 0, NULL))
+			return CAPI_MSGOSRESOURCEERR;
+		gig_dbg(DEBUG_CMD, "scheduling HUP");
+		gigaset_schedule_event(cs);
+		return CAPI_NOERROR;
+	}
+}
+
+/*
+ * send CAPI message
+ * Return value: CAPI error code
+ * Note: capidrv (and probably others, too) only uses the return value to
+ * decide whether it has to free the skb (only if result != CAPI_NOERROR (0))
+ */
+static u16 gigaset_send_message(struct capi_ctr *ctr, struct sk_buff *skb)
+{
+	struct gigaset_capi_ctr *iif
+		= container_of(ctr, struct gigaset_capi_ctr, ctr);
+	struct cardstate *cs = ctr->driverdata;
+	struct bc_state *bcs = NULL;
+	struct gigaset_capi_appl *ap;
+	u16 applid = CAPIMSG_APPID(skb->data);
+	int channel;
+	u16 len;
+	u16 result;
+
+	/* retrieve application data structure */
+	if ((ap = get_appl(iif, applid)) == NULL) {
+		dev_notice(cs->dev, "%s: application %u not registered\n",
+			   __func__, applid);
+		return CAPI_ILLAPPNR;
+	}
+
+	/* serialize */
+	mutex_lock(&iif->ctr_mtx);
+
+	/* ToDo: streamline DATA_B3 case (avoid _cmsg overhead) */
+
+	/* decode message */
+	capi_message2cmsg(&iif->acmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+
+	switch (CAPIMSG_CMD(skb->data)) {
+	case CAPI_LISTEN_REQ:
+		/* store listening parameters */
+		ap->listenInfoMask = iif->acmsg.InfoMask;
+		ap->listenCIPmask = iif->acmsg.CIPmask;
+		iif->acmsg.Info = CapiSuccess;
+		goto send_conf;
+
+	case CAPI_ALERT_REQ:
+		/* nothing to do - Gigaset base always sends ALERT */
+		ignore_cmstruct_param(cs, iif->acmsg.AdditionalInfo,
+					"ALERT_REQ", "Additional Info");
+		iif->acmsg.Info = CapiAlertAlreadySent;
+		goto send_conf;
+
+	case CAPI_CONNECT_REQ:
+		/* generate DIAL event */
+		result = do_connect_req(cs, &iif->acmsg, ap);
+		if (result == CAPI_MSGOSRESOURCEERR)
+			break;
+		iif->acmsg.Info = result;
+		goto send_conf;
+
+	case CAPI_INFO_REQ:
+		/*
+		 * ToDo: support overlap sending
+		 * (requires ev-layer state machine extension to generate
+		 * additional ATD commands)
+		 */
+		ignore_cstruct_param(cs, iif->acmsg.CalledPartyNumber,
+					"INFO_REQ", "Called party number");
+
+		/* ToDo: process parameter: Additional info */
+		ignore_cmstruct_param(cs, iif->acmsg.AdditionalInfo,
+					"INFO_REQ", "Additional Info");
+
+		/* unsupported */
+		iif->acmsg.Info = CapiMessageNotSupportedInCurrentState;
+		goto send_conf;
+
+	case CAPI_SELECT_B_PROTOCOL_REQ:
+		/* unsupported */
+		iif->acmsg.Info = CapiMessageNotSupportedInCurrentState;
+		goto send_conf;
+
+	case CAPI_DISCONNECT_REQ:
+		/* schedule EV_HUP event */
+		result = do_disconnect_req(cs, iif, ap);
+		if (result == CAPI_MSGOSRESOURCEERR ||
+		    result == CapiIllContrPlciNcci)
+			break;
+		iif->acmsg.Info = result;
+		goto send_conf;
+
+	case CAPI_CONNECT_B3_REQ:
+		/* extract and check channel number from PLCI */
+		channel = (iif->acmsg.adr.adrPLCI >> 8) & 0xff;
+		if (!channel || channel > cs->channels) {
+			dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
+				   "CAPI_CONNECT_B3_REQ", "PLCI",
+				   iif->acmsg.adr.adrPLCI);
+			result = CapiIllContrPlciNcci;
+			break;
+		}
+
+		/* reject if logical connection already active */
+		if (iif->b3conn[channel-1]) {
+			iif->acmsg.Info = CapiNoNcciAvailable;
+			goto send_conf;
+		}
+
+		/* mark logical connection active */
+		iif->b3conn[channel-1] = 1;
+
+		/* build NCCI: always 1 (one B3 connection only) */
+		iif->acmsg.adr.adrNCCI |= 1 << 16;
+
+		/* NCPI parameter: not applicable for B3 Transparent */
+		ignore_cstruct_param(cs, iif->acmsg.NCPI,
+					"CONNECT_B3_REQ", "NCPI");
+		iif->acmsg.Info = iif->acmsg.NCPI ?
+			CapiNcpiNotSupportedByProtocol : CapiSuccess;
+		goto send_conf;
+
+	case CAPI_DISCONNECT_B3_REQ:
+		/* extract and check channel number and NCCI */
+		channel = (iif->acmsg.adr.adrNCCI >> 8) & 0xff;
+		if (!channel || channel > cs->channels ||
+		    ((iif->acmsg.adr.adrNCCI >> 16) & 0xffff) != 1) {
+			dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
+				   "CAPI_DISCONNECT_B3_REQ", "NCCI",
+				   iif->acmsg.adr.adrNCCI);
+			result = CapiIllContrPlciNcci;
+			break;
+		}
+
+		/* reject if logical connection not active */
+		if (!iif->b3conn[channel-1]) {
+			iif->acmsg.Info = CapiMessageNotSupportedInCurrentState;
+			goto send_conf;
+		}
+
+		/* trigger hangup, causing eventual DISCONNECT_B3_IND */
+		if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
+				       EV_HUP, NULL, 0, NULL)) {
+			dev_err(cs->dev, "%s: out of memory\n", __func__);
+			result = CAPI_MSGOSRESOURCEERR;
+			break;
+		}
+		gig_dbg(DEBUG_CMD, "scheduling HUP");
+		gigaset_schedule_event(cs);
+
+		/* NCPI parameter: not applicable for B3 Transparent */
+		ignore_cstruct_param(cs, iif->acmsg.NCPI,
+					"DISCONNECT_B3_REQ", "NCPI");
+		iif->acmsg.Info = iif->acmsg.NCPI ?
+			CapiNcpiNotSupportedByProtocol : CapiSuccess;
+		goto send_conf;
+
+	case CAPI_DATA_B3_REQ:
+		/* extract and check channel number and NCCI */
+		channel = (iif->acmsg.adr.adrNCCI >> 8) & 0xff;
+		if (!channel || channel > cs->channels ||
+		    ((iif->acmsg.adr.adrNCCI >> 16) & 0xffff) != 1) {
+			dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
+				   "CAPI_DATA_B3_REQ", "NCCI",
+				   iif->acmsg.adr.adrNCCI);
+			result = CapiIllContrPlciNcci;
+			break;
+		}
+		bcs = &cs->bcs[channel-1];
+
+		/* reject if logical connection not active */
+		if (!iif->b3conn[channel-1]) {
+			iif->acmsg.Info = CapiMessageNotSupportedInCurrentState;
+			goto send_conf;
+		}
+
+		/* check parameters */
+		len = iif->acmsg.DataLength;
+		if (CAPIMSG_LEN(skb->data) != CAPI_DATA_B3_REQ_LEN)
+			dev_notice(cs->dev, "%s: unexpected length %d\n",
+				   "CAPI_DATA_B3_REQ", CAPIMSG_LEN(skb->data));
+		if (CAPI_DATA_B3_REQ_LEN + len != skb->len)
+			dev_notice(cs->dev, "%s: length mismatch (%d+%d!=%d)\n",
+				   "CAPI_DATA_B3_REQ",
+				   CAPI_DATA_B3_REQ_LEN, len, skb->len);
+		if (CAPI_DATA_B3_REQ_LEN + len > skb->len) {
+			/* message too short for announced data length */
+			result = CapiIllMessageParmCoding; /* ? */
+			break;
+		}
+		if (iif->acmsg.Flags & CAPI_FLAGS_RESERVED) {
+			result = CapiIllMessageParmCoding;
+			break;
+		}
+		gig_dbg(DEBUG_LLDATA,
+			"Receiving data from LL (ch: %d, flg: %x, sz: %d)",
+			channel, iif->acmsg.Flags, len);
+
+		/*
+		 * pull CAPI message from skb,
+		 * pass payload data to device-specific module
+		 * CAPI message will be preserved in headroom
+		 */
+		skb_pull(skb, CAPI_DATA_B3_REQ_LEN);
+		if (cs->ops->send_skb(bcs, skb) < 0)
+			result = CAPI_MSGOSRESOURCEERR;
+		else
+			result = CAPI_NOERROR;
+		/* DATA_B3_CONF reply will be sent by gigaset_skb_sent() */
+
+		/*
+		 * ToDo: send DATA_B3_CONF immediately
+		 * if Delivery Confirmation flag not set?
+		 */
+		break;
+
+send_conf:
+		/* create reply message with previously set result */
+		capi_cmsg_answer(&iif->acmsg);
+
+		/*
+		 * _CONF replies always only have NCCI and Info parameters
+		 * so they'll fit into the _REQ message skb
+		 */
+		capi_cmsg2message(&iif->acmsg, skb->data);
+		__skb_trim(skb, CAPI_STDCONF_LEN);
+		dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+		capi_ctr_handle_message(ctr, applid, skb);
+		result = CAPI_NOERROR;
+		break;
+
+	case CAPI_CONNECT_RESP:
+		/* generate ACCEPT/HUP event */
+		result = do_connect_resp(cs, &iif->acmsg, ap);
+		if (result == CAPI_NOERROR)
+			dev_kfree_skb(skb);
+		break;
+
+	case CAPI_CONNECT_B3_RESP:
+		/* extract and check channel number and NCCI */
+		channel = (iif->acmsg.adr.adrNCCI >> 8) & 0xff;
+		if (!channel || channel > cs->channels ||
+		    ((iif->acmsg.adr.adrNCCI >> 16) & 0xffff) != 1) {
+			dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
+				   "CAPI_CONNECT_B3_RESP", "NCCI",
+				   iif->acmsg.adr.adrNCCI);
+			result = CapiIllContrPlciNcci;
+			break;
+		}
+		bcs = &cs->bcs[channel-1];
+
+		if (iif->acmsg.Reject) {
+			/* Reject: clear B3 connect received flag */
+			iif->b3conn[bcs->channel] = 0;
+
+			/* trigger hangup, causing eventual DISCONNECT_IND */
+			if (!gigaset_add_event(cs, &bcs->at_state,
+					       EV_HUP, NULL, 0, NULL)) {
+				dev_err(cs->dev, "%s: out of memory\n",
+					__func__);
+				result = CAPI_MSGOSRESOURCEERR;
+				break;
+			}
+			gig_dbg(DEBUG_CMD, "scheduling HUP");
+			gigaset_schedule_event(cs);
+
+			/* emit DISCONNECT_B3_IND */
+			capi_cmsg_header(&iif->acmsg, ap->id,
+					 CAPI_DISCONNECT_B3, CAPI_IND,
+					 ap->nextMessageNumber++,
+					 iif->ctr.cnr |
+					 ((bcs->channel + 1) << 8) |
+					 (1 << 16));
+
+			/*
+			 * message is shorter than the received _RESP message,
+			 * reuse skb
+			 */
+			capi_cmsg2message(&iif->acmsg, skb->data);
+			__skb_trim(skb, CAPI_DISCONNECT_B3_IND_BASELEN);
+		} else {
+			/*
+			 * Accept: emit CONNECT_B3_ACTIVE_IND immediately, as
+			 * we only send CONNECT_B3_IND if the B channel is up
+			 */
+			capi_cmsg_header(&iif->acmsg, ap->id,
+					 CAPI_CONNECT_B3_ACTIVE, CAPI_IND,
+					 ap->nextMessageNumber++,
+					 iif->ctr.cnr |
+					 ((bcs->channel + 1) << 8) |
+					 (1 << 16));
+
+			/*
+			 * message is shorter than the received _RESP message,
+			 * reuse skb
+			 */
+			capi_cmsg2message(&iif->acmsg, skb->data);
+			__skb_trim(skb, CAPI_CONNECT_B3_ACTIVE_IND_BASELEN);
+		}
+
+		dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+		capi_ctr_handle_message(ctr, applid, skb);
+		result = CAPI_NOERROR;
+		break;
+
+	case CAPI_CONNECT_ACTIVE_RESP:
+	case CAPI_CONNECT_B3_ACTIVE_RESP:
+	case CAPI_CONNECT_B3_T90_ACTIVE_RESP:
+	case CAPI_DISCONNECT_RESP:
+	case CAPI_INFO_RESP:
+	case CAPI_DISCONNECT_B3_RESP:
+	case CAPI_DATA_B3_RESP:
+		/* nothing to do */
+		dev_kfree_skb(skb);
+		result = CAPI_NOERROR;
+		break;
+
+	/* ToDo */
+	case CAPI_RESET_B3_REQ:
+	case CAPI_RESET_B3_RESP:
+	case CAPI_FACILITY_REQ:
+	case CAPI_FACILITY_RESP:
+	case CAPI_MANUFACTURER_REQ:
+	case CAPI_MANUFACTURER_RESP:
+		/* not yet implemented */
+	default:
+		/* unknown command */
+		dev_notice(cs->dev, "unsupported CAPI message: %s\n",
+			   capi_cmd2str(iif->acmsg.Command,
+					iif->acmsg.Subcommand));
+		result = CAPI_ILLCMDORSUBCMDORMSGTOSMALL;
+	}
+
+	mutex_unlock(&iif->ctr_mtx);
+	return result;
+}
+
+/**
+ * gigaset_procinfo() - build single line description for controller
+ * @ctr:	controller descriptor structure.
+ *
+ * Return value: pointer to generated string (null terminated)
+ */
+static char *gigaset_procinfo(struct capi_ctr *ctr)
+{
+	return ctr->name;	/* ToDo: more? */
+}
+
+/**
+ * gigaset_ctr_read_proc() - build controller proc file entry
+ * @page:	buffer of PAGE_SIZE bytes for receiving the entry.
+ * @start:	unused.
+ * @off:	unused.
+ * @count:	unused.
+ * @eof:	unused.
+ * @ctr:	controller descriptor structure.
+ *
+ * Return value: length of generated entry
+ */
+static int gigaset_ctr_read_proc(char *page, char **start, off_t off,
+			  int count, int *eof, struct capi_ctr *ctr)
+{
+	struct cardstate *cs = ctr->driverdata;
+	char *s;
+	int i;
+	int len = 0;
+	len += sprintf(page+len, "%-16s %s\n", "name", ctr->name);
+	len += sprintf(page+len, "%-16s %s %s\n", "dev",
+			dev_driver_string(cs->dev), dev_name(cs->dev));
+	len += sprintf(page+len, "%-16s %d\n", "id", cs->myid);
+	if (cs->gotfwver)
+		len += sprintf(page+len, "%-16s %d.%d.%d.%d\n", "firmware",
+			cs->fwver[0], cs->fwver[1], cs->fwver[2], cs->fwver[3]);
+	len += sprintf(page+len, "%-16s %d\n", "channels",
+			cs->channels);
+	len += sprintf(page+len, "%-16s %s\n", "onechannel",
+			cs->onechannel ? "yes" : "no");
+
+	switch (cs->mode) {
+	case M_UNKNOWN:
+		s = "unknown";
+		break;
+	case M_CONFIG:
+		s = "config";
+		break;
+	case M_UNIMODEM:
+		s = "Unimodem";
+		break;
+	case M_CID:
+		s = "CID";
+		break;
+	default:
+		s = "??";
+	}
+	len += sprintf(page+len, "%-16s %s\n", "mode", s);
+
+	switch (cs->mstate) {
+	case MS_UNINITIALIZED:
+		s = "uninitialized";
+		break;
+	case MS_INIT:
+		s = "init";
+		break;
+	case MS_LOCKED:
+		s = "locked";
+		break;
+	case MS_SHUTDOWN:
+		s = "shutdown";
+		break;
+	case MS_RECOVER:
+		s = "recover";
+		break;
+	case MS_READY:
+		s = "ready";
+		break;
+	default:
+		s = "??";
+	}
+	len += sprintf(page+len, "%-16s %s\n", "mstate", s);
+
+	len += sprintf(page+len, "%-16s %s\n", "running",
+			cs->running ? "yes" : "no");
+	len += sprintf(page+len, "%-16s %s\n", "connected",
+			cs->connected ? "yes" : "no");
+	len += sprintf(page+len, "%-16s %s\n", "isdn_up",
+			cs->isdn_up ? "yes" : "no");
+	len += sprintf(page+len, "%-16s %s\n", "cidmode",
+			cs->cidmode ? "yes" : "no");
+
+	for (i = 0; i < cs->channels; i++) {
+		len += sprintf(page+len, "[%d]%-13s %d\n", i, "corrupted",
+				cs->bcs[i].corrupted);
+		len += sprintf(page+len, "[%d]%-13s %d\n", i, "trans_down",
+				cs->bcs[i].trans_down);
+		len += sprintf(page+len, "[%d]%-13s %d\n", i, "trans_up",
+				cs->bcs[i].trans_up);
+		len += sprintf(page+len, "[%d]%-13s %d\n", i, "chstate",
+				cs->bcs[i].chstate);
+		switch (cs->bcs[i].proto2) {
+		case L2_BITSYNC:
+			s = "bitsync";
+			break;
+		case L2_HDLC:
+			s = "HDLC";
+			break;
+		case L2_VOICE:
+			s = "voice";
+			break;
+		default:
+			s = "??";
+		}
+		len += sprintf(page+len, "[%d]%-13s %s\n", i, "proto2", s);
+	}
+	return len;
+}
+
+
+static struct capi_driver capi_driver_gigaset = {
+	.name		= "gigaset",
+	.revision	= "1.0",
+};
+
+/**
+ * gigaset_isdn_register() - register to LL
+ * @cs:		device descriptor structure.
+ * @isdnid:	device name.
+ *
+ * Called by main module to register the device with the LL.
+ *
+ * Return value: 1 for success, 0 for failure
+ */
+int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
+{
+	struct gigaset_capi_ctr *iif;
+	int i, rc;
+
+	pr_info("Kernel CAPI interface\n");
+
+	if ((iif = kmalloc(sizeof(*iif), GFP_KERNEL)) == NULL) {
+		pr_err("%s: out of memory\n", __func__);
+		return 0;
+	}
+
+	/* register driver with CAPI (ToDo: what for?) */
+	register_capi_driver(&capi_driver_gigaset);
+
+	/* prepare controller structure */
+	iif->ctr.owner         = THIS_MODULE;
+	iif->ctr.driverdata    = cs;
+	strncpy(iif->ctr.name, isdnid, sizeof(iif->ctr.name));
+	iif->ctr.driver_name   = "gigaset";
+	iif->ctr.load_firmware = gigaset_load_firmware;
+	iif->ctr.reset_ctr     = gigaset_reset_ctr;
+	iif->ctr.register_appl = gigaset_register_appl;
+	iif->ctr.release_appl  = gigaset_release_appl;
+	iif->ctr.send_message  = gigaset_send_message;
+	iif->ctr.procinfo      = gigaset_procinfo;
+	iif->ctr.ctr_read_proc = gigaset_ctr_read_proc;
+	INIT_LIST_HEAD(&iif->appls);
+	mutex_init(&iif->ctr_mtx);
+	for (i = 0; i < BAS_CHANNELS; i++)
+		iif->b3conn[i] = 0;
+
+	/* register controller with CAPI */
+	rc = attach_capi_ctr(&iif->ctr);
+	if (rc) {
+		pr_err("attach_capi_ctr failed (%d)\n", rc);
+		unregister_capi_driver(&capi_driver_gigaset);
+		kfree(iif);
+		return 0;
+	}
+
+	cs->iif = iif;
+	cs->hw_hdr_len = CAPI_DATA_B3_REQ_LEN;
+	return 1;
+}
+
+/**
+ * gigaset_isdn_unregister() - unregister from LL
+ * @cs:		device descriptor structure.
+ *
+ * Called by main module to unregister the device from the LL.
+ */
+void gigaset_isdn_unregister(struct cardstate *cs)
+{
+	struct gigaset_capi_ctr *iif = cs->iif;
+
+	detach_capi_ctr(&iif->ctr);
+	kfree(iif);
+	cs->iif = NULL;
+	unregister_capi_driver(&capi_driver_gigaset);
+}
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index a2847c2..e72091c 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -207,6 +207,25 @@ int gigaset_get_channel(struct bc_state *bcs)
 	return 1;
 }
 
+struct bc_state *gigaset_get_free_channel(struct cardstate *cs)
+{
+	unsigned long flags;
+	int i;
+
+	spin_lock_irqsave(&cs->lock, flags);
+	for (i = 0; i < cs->channels; ++i)
+		if (!cs->bcs[i].use_count) {
+			++cs->bcs[i].use_count;
+			cs->bcs[i].busy = 1;
+			spin_unlock_irqrestore(&cs->lock, flags);
+			gig_dbg(DEBUG_ANY, "allocated channel %d", i);
+			return cs->bcs + i;
+		}
+	spin_unlock_irqrestore(&cs->lock, flags);
+	gig_dbg(DEBUG_ANY, "no free channel");
+	return NULL;
+}
+
 void gigaset_free_channel(struct bc_state *bcs)
 {
 	unsigned long flags;
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index ad5ad7b..2d6dab8 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -291,21 +291,23 @@ struct reply_t gigaset_tab_cid[] =
 	{RSP_OK,      602,602, -1,                603, 5, {ACT_CMD+AT_PROTO}},
 	{RSP_OK,      603,603, -1,                604, 5, {ACT_CMD+AT_TYPE}},
 	{RSP_OK,      604,604, -1,                605, 5, {ACT_CMD+AT_MSN}},
-	{RSP_OK,      605,605, -1,                606, 5, {ACT_CMD+AT_ISO}},
-	{RSP_NULL,    605,605, -1,                606, 5, {ACT_CMD+AT_ISO}},
-	{RSP_OK,      606,606, -1,                607, 5, {0}, "+VLS=17\r"},
-	{RSP_OK,      607,607, -1,                608,-1},
-	{RSP_ZSAU,    608,608,ZSAU_PROCEEDING,    609, 5, {ACT_CMD+AT_DIAL}},
-	{RSP_OK,      609,609, -1,                650, 0, {ACT_DIALING}},
-
-	{RSP_ERROR,   601,609, -1,                  0, 0, {ACT_ABORTDIAL}},
-	{EV_TIMEOUT,  601,609, -1,                  0, 0, {ACT_ABORTDIAL}},
+	{RSP_NULL,    605,605, -1,                606, 5, {ACT_CMD+AT_CLIP}},
+	{RSP_OK,      605,605, -1,                606, 5, {ACT_CMD+AT_CLIP}},
+	{RSP_NULL,    606,606, -1,                607, 5, {ACT_CMD+AT_ISO}},
+	{RSP_OK,      606,606, -1,                607, 5, {ACT_CMD+AT_ISO}},
+	{RSP_OK,      607,607, -1,                608, 5, {0}, "+VLS=17\r"},
+	{RSP_OK,      608,608, -1,                609,-1},
+	{RSP_ZSAU,    609,609,ZSAU_PROCEEDING,    610, 5, {ACT_CMD+AT_DIAL}},
+	{RSP_OK,      610,610, -1,                650, 0, {ACT_DIALING}},
+
+	{RSP_ERROR,   601,610, -1,                  0, 0, {ACT_ABORTDIAL}},
+	{EV_TIMEOUT,  601,610, -1,                  0, 0, {ACT_ABORTDIAL}},
 
 	/* optional dialing responses */
 	{EV_BC_OPEN,  650,650, -1,                651,-1},
-	{RSP_ZVLS,    608,651, 17,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ZCTP,    609,651, -1,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ZCPN,    609,651, -1,                 -1,-1, {ACT_DEBUG}},
+	{RSP_ZVLS,    609,651, 17,                 -1,-1, {ACT_DEBUG}},
+	{RSP_ZCTP,    610,651, -1,                 -1,-1, {ACT_DEBUG}},
+	{RSP_ZCPN,    610,651, -1,                 -1,-1, {ACT_DEBUG}},
 	{RSP_ZSAU,    650,651,ZSAU_CALL_DELIVERED, -1,-1, {ACT_DEBUG}},
 
 	/* connect */
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 8777a9c..4458796 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -191,7 +191,9 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define AT_PROTO	4
 #define AT_TYPE		5
 #define AT_HLC		6
-#define AT_NUM		7
+#define AT_CLIP		7
+/* total number */
+#define AT_NUM		8
 
 /* variables in struct at_state_t */
 #define VAR_ZSAU	0
@@ -412,6 +414,8 @@ struct bc_state {
 		struct usb_bc_state *usb;	/* usb hardware driver (m105) */
 		struct bas_bc_state *bas;	/* usb hardware driver (base) */
 	} hw;
+
+	void *ap;			/* LL application structure */
 };
 
 struct cardstate {
@@ -725,6 +729,7 @@ void gigaset_bcs_reinit(struct bc_state *bcs);
 void gigaset_at_init(struct at_state_t *at_state, struct bc_state *bcs,
 		     struct cardstate *cs, int cid);
 int gigaset_get_channel(struct bc_state *bcs);
+struct bc_state *gigaset_get_free_channel(struct cardstate *cs);
 void gigaset_free_channel(struct bc_state *bcs);
 int gigaset_get_channels(struct cardstate *cs);
 void gigaset_free_channels(struct cardstate *cs);

-- 
1.6.2.1.214.ge986c
