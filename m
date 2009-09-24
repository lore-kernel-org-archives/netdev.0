From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 13/12] gigaset: add some more CAPI message handling
Date: Fri, 25 Sep 2009 00:04:18 +0200 (CEST)
Message-ID: <20090924-patch-gigaset-13.tilman@imap.cc>
References: <20090924-patch-0.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, davem@davemloft.net,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752513AbZIXWEc@vger.kernel.org>
In-Reply-To: <20090924-patch-0.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rejecting unsupported CAPI messages with code 0x1102 "illegal command
or subcommand" makes some real-world CAPI apps rather unhappy. This
patch adds code to reply to FACILITY_REQ and RESET_B3_REQ messages
with an appropriate "not supported" message, to accept but ignore
FACILITY_RESP, RESET_B3_RESP and MANUFACTURER messages, and to log
any messages still rejected as illegal.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |  171 +++++++++++++++++++++++++++++++++++++++---
 1 files changed, 158 insertions(+), 13 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 6ea2b1d..8afff37 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -21,6 +21,7 @@
 #define CapiNcpiNotSupportedByProtocol	0x0001
 #define CapiFlagsNotSupportedByProtocol	0x0002
 #define CapiAlertAlreadySent		0x0003
+#define CapiFacilitySpecificFunctionNotSupported	0x3011
 
 /* missing from capicmd.h */
 #define CAPI_CONNECT_IND_BASELEN	(CAPI_MSG_BASELEN+4+2+8*1)
@@ -31,9 +32,19 @@
 #define CAPI_DATA_B3_CONF_LEN		(CAPI_MSG_BASELEN+4+2+2)
 #define CAPI_DISCONNECT_IND_LEN		(CAPI_MSG_BASELEN+4+2)
 #define CAPI_DISCONNECT_B3_IND_BASELEN	(CAPI_MSG_BASELEN+4+2+1)
+#define CAPI_FACILITY_CONF_BASELEN	(CAPI_MSG_BASELEN+4+2+2+1)
 /* most _CONF messages contain only Controller/PLCI/NCCI and Info parameters */
 #define CAPI_STDCONF_LEN		(CAPI_MSG_BASELEN+4+2)
 
+#define CAPI_FACILITY_HANDSET	0x0000
+#define CAPI_FACILITY_DTMF	0x0001
+#define CAPI_FACILITY_V42BIS	0x0002
+#define CAPI_FACILITY_SUPPSVC	0x0003
+#define CAPI_FACILITY_WAKEUP	0x0004
+#define CAPI_FACILITY_LI	0x0005
+
+#define CAPI_SUPPSVC_GETSUPPORTED	0x0000
+
 /* missing from capiutil.h */
 #define CAPIMSG_PLCI_PART(m)	CAPIMSG_U8(m, 9)
 #define CAPIMSG_NCCI_PART(m)	CAPIMSG_U16(m, 10)
@@ -1044,6 +1055,108 @@ static void send_conf(struct gigaset_capi_ctr *iif,
 }
 
 /*
+ * process FACILITY_REQ message
+ */
+static void do_facility_req(struct gigaset_capi_ctr *iif,
+			    struct gigaset_capi_appl *ap,
+			    struct sk_buff *skb)
+{
+	struct cardstate *cs = iif->ctr.driverdata;
+	struct sk_buff *cskb;
+	u8 *pparam;
+	unsigned int msgsize = CAPI_FACILITY_CONF_BASELEN;
+	u16 function, info;
+	static u8 confparam[10];	/* max. 9 octets + length byte */
+
+	/* decode message */
+	capi_message2cmsg(&iif->acmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+
+	/*
+	 * Facility Request Parameter is not decoded by capi_message2cmsg()
+	 * encoding depends on Facility Selector
+	 */
+	switch (iif->acmsg.FacilitySelector) {
+	case CAPI_FACILITY_DTMF:	/* ToDo */
+		info = CapiFacilityNotSupported;
+		confparam[0] = 2;	/* length */
+		/* DTMF information: Unknown DTMF request */
+		capimsg_setu16(confparam, 1, 2);
+		break;
+
+	case CAPI_FACILITY_V42BIS:	/* not supported */
+		info = CapiFacilityNotSupported;
+		confparam[0] = 2;	/* length */
+		/* V.42 bis information: not available */
+		capimsg_setu16(confparam, 1, 1);
+		break;
+
+	case CAPI_FACILITY_SUPPSVC:
+		/* decode Function parameter */
+		pparam = iif->acmsg.FacilityRequestParameter;
+		if (pparam == NULL || *pparam < 2) {
+			dev_notice(cs->dev, "%s: %s missing\n", "FACILITY_REQ",
+				   "Facility Request Parameter");
+			send_conf(iif, ap, skb, CapiIllMessageParmCoding);
+			return;
+		}
+		function = CAPIMSG_U16(pparam, 1);
+		switch (function) {
+		case CAPI_SUPPSVC_GETSUPPORTED:
+			info = CapiSuccess;
+			/* Supplementary Service specific parameter */
+			confparam[3] = 6;	/* length */
+			/* Supplementary services info: Success */
+			capimsg_setu16(confparam, 4, CapiSuccess);
+			/* Supported Services: none */
+			capimsg_setu32(confparam, 6, 0);
+			break;
+		/* ToDo: add supported services */
+		default:
+			info = CapiFacilitySpecificFunctionNotSupported;
+			/* Supplementary Service specific parameter */
+			confparam[3] = 2;	/* length */
+			/* Supplementary services info: not supported */
+			capimsg_setu16(confparam, 4,
+				       CapiSupplementaryServiceNotSupported);
+		}
+
+		/* Facility confirmation parameter */
+		confparam[0] = confparam[3] + 3;	/* total length */
+		/* Function: copy from _REQ message */
+		capimsg_setu16(confparam, 1, function);
+		/* Supplementary Service specific parameter already set above */
+		break;
+
+	case CAPI_FACILITY_WAKEUP:	/* ToDo */
+		info = CapiFacilityNotSupported;
+		confparam[0] = 2;	/* length */
+		/* Number of accepted awake request parameters: 0 */
+		capimsg_setu16(confparam, 1, 0);
+		break;
+
+	default:
+		info = CapiFacilityNotSupported;
+		confparam[0] = 0;	/* empty struct */
+	}
+
+	/* send FACILITY_CONF with given Info and confirmation parameter */
+	capi_cmsg_answer(&iif->acmsg);
+	iif->acmsg.Info = info;
+	iif->acmsg.FacilityConfirmationParameter = confparam;
+	msgsize += confparam[0];	/* length */
+	cskb = alloc_skb(msgsize, GFP_ATOMIC);
+	if (!cskb) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		return;
+	}
+	capi_cmsg2message(&iif->acmsg, __skb_put(cskb, msgsize));
+	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+		capi_ctr_handle_message(&iif->ctr, ap->id, cskb);
+}
+
+
+/*
  * process LISTEN_REQ message
  * just store the masks in the application data structure
  */
@@ -1766,7 +1879,28 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 }
 
 /*
- * CAPI message handler: just reply "not supported in current state"
+ * process RESET_B3_REQ message
+ * just always reply "not supported by current protocol"
+ */
+static void do_reset_b3_req(struct gigaset_capi_ctr *iif,
+			    struct gigaset_capi_appl *ap,
+			    struct sk_buff *skb)
+{
+	/* decode message */
+	capi_message2cmsg(&iif->acmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	send_conf(iif, ap, skb,
+		  CapiResetProcedureNotSupportedByCurrentProtocol);
+}
+
+/*
+ * dump unsupported/ignored messages at most twice per minute,
+ * some apps send those very frequently
+ */
+static unsigned long ignored_msg_dump_time;
+
+/*
+ * unsupported CAPI message handler
  */
 static void do_unsupported(struct gigaset_capi_ctr *iif,
 			   struct gigaset_capi_appl *ap,
@@ -1774,7 +1908,8 @@ static void do_unsupported(struct gigaset_capi_ctr *iif,
 {
 	/* decode message */
 	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	if (printk_timed_ratelimit(&ignored_msg_dump_time, 30 * 1000))
+		dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 	send_conf(iif, ap, skb, CapiMessageNotSupportedInCurrentState);
 }
 
@@ -1785,7 +1920,11 @@ static void do_nothing(struct gigaset_capi_ctr *iif,
 		       struct gigaset_capi_appl *ap,
 		       struct sk_buff *skb)
 {
-	dump_rawmsg(DEBUG_CMD, __func__, skb->data);
+	if (printk_timed_ratelimit(&ignored_msg_dump_time, 30 * 1000)) {
+		/* decode message */
+		capi_message2cmsg(&iif->acmsg, skb->data);
+		dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	}
 	dev_kfree_skb(skb);
 }
 
@@ -1809,6 +1948,7 @@ static struct {
 	/* most frequent messages first for faster lookup */
 	{ CAPI_DATA_B3_REQ, do_data_b3_req },
 	{ CAPI_DATA_B3_RESP, do_data_b3_resp },
+
 	{ CAPI_ALERT_REQ, do_alert_req },
 	{ CAPI_CONNECT_ACTIVE_RESP, do_nothing },
 	{ CAPI_CONNECT_B3_ACTIVE_RESP, do_nothing },
@@ -1821,23 +1961,25 @@ static struct {
 	{ CAPI_DISCONNECT_B3_RESP, do_nothing },
 	{ CAPI_DISCONNECT_REQ, do_disconnect_req },
 	{ CAPI_DISCONNECT_RESP, do_nothing },
-	{ CAPI_INFO_REQ, do_unsupported },
+	{ CAPI_FACILITY_REQ, do_facility_req },
+	{ CAPI_FACILITY_RESP, do_nothing },
+	{ CAPI_LISTEN_REQ, do_listen_req },
+	{ CAPI_SELECT_B_PROTOCOL_REQ, do_unsupported },
+	{ CAPI_RESET_B3_REQ, do_reset_b3_req },
+	{ CAPI_RESET_B3_RESP, do_nothing },
+
 	/*
 	 * ToDo: support overlap sending (requires ev-layer state
 	 * machine extension to generate additional ATD commands)
 	 */
+	{ CAPI_INFO_REQ, do_unsupported },
 	{ CAPI_INFO_RESP, do_nothing },
-	{ CAPI_LISTEN_REQ, do_listen_req },
-	{ CAPI_SELECT_B_PROTOCOL_REQ, do_unsupported },
+
 	/*
-	 * ToDo:
-	 * CAPI_FACILITY_REQ
-	 * CAPI_FACILITY_RESP
-	 * CAPI_MANUFACTURER_REQ
-	 * CAPI_MANUFACTURER_RESP
-	 * CAPI_RESET_B3_REQ
-	 * CAPI_RESET_B3_RESP
+	 * ToDo: what's the proper response for these?
 	 */
+	{ CAPI_MANUFACTURER_REQ, do_nothing },
+	{ CAPI_MANUFACTURER_RESP, do_nothing },
 };
 
 /* look up handler */
@@ -1887,6 +2029,9 @@ static u16 gigaset_send_message(struct capi_ctr *ctr, struct sk_buff *skb)
 	handler = lookup_capi_send_handler(CAPIMSG_CMD(skb->data));
 	if (!handler) {
 		/* unknown/unsupported message type */
+		if (printk_ratelimit())
+			dev_notice(cs->dev, "%s: unsupported message %u\n",
+				   __func__, CAPIMSG_CMD(skb->data));
 		return CAPI_ILLCMDORSUBCMDORMSGTOSMALL;
 	}
 
-- 
1.6.2.1.214.ge986c
