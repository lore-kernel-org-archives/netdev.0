From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/9] gigaset: CAPI module readability improvements
Date: Sun, 25 Oct 2009 20:29:37 +0100 (CET)
Message-ID: <20091023-patch-gigaset-01.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754037AbZJYT3w@vger.kernel.org>
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the "ignoring Additional Info" warning message by better
readable ones citing the specific subparameters being ignored.
Make parts of the code more readable by using a local cmsg
pointer variable.

Impact: readability improvement
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |  144 ++++++++++++++++++++++++-------------------
 1 files changed, 81 insertions(+), 63 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index c276a92..ac0a2da 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -168,14 +168,6 @@ static inline void ignore_cstruct_param(struct cardstate *cs, _cstruct param,
 			 msgname, paramname);
 }
 
-static inline void ignore_cmstruct_param(struct cardstate *cs, _cmstruct param,
-				       char *msgname, char *paramname)
-{
-	if (param != CAPI_DEFAULT)
-		dev_warn(cs->dev, "%s: ignoring unsupported parameter: %s\n",
-			 msgname, paramname);
-}
-
 /*
  * check for legal hex digit
  */
@@ -1062,6 +1054,7 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 			    struct sk_buff *skb)
 {
 	struct cardstate *cs = iif->ctr.driverdata;
+	_cmsg *cmsg = &iif->acmsg;
 	struct sk_buff *cskb;
 	u8 *pparam;
 	unsigned int msgsize = CAPI_FACILITY_CONF_BASELEN;
@@ -1069,14 +1062,14 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 	static u8 confparam[10];	/* max. 9 octets + length byte */
 
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_message2cmsg(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/*
 	 * Facility Request Parameter is not decoded by capi_message2cmsg()
 	 * encoding depends on Facility Selector
 	 */
-	switch (iif->acmsg.FacilitySelector) {
+	switch (cmsg->FacilitySelector) {
 	case CAPI_FACILITY_DTMF:	/* ToDo */
 		info = CapiFacilityNotSupported;
 		confparam[0] = 2;	/* length */
@@ -1093,7 +1086,7 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 
 	case CAPI_FACILITY_SUPPSVC:
 		/* decode Function parameter */
-		pparam = iif->acmsg.FacilityRequestParameter;
+		pparam = cmsg->FacilityRequestParameter;
 		if (pparam == NULL || *pparam < 2) {
 			dev_notice(cs->dev, "%s: %s missing\n", "FACILITY_REQ",
 				   "Facility Request Parameter");
@@ -1141,18 +1134,18 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 	}
 
 	/* send FACILITY_CONF with given Info and confirmation parameter */
-	capi_cmsg_answer(&iif->acmsg);
-	iif->acmsg.Info = info;
-	iif->acmsg.FacilityConfirmationParameter = confparam;
+	capi_cmsg_answer(cmsg);
+	cmsg->Info = info;
+	cmsg->FacilityConfirmationParameter = confparam;
 	msgsize += confparam[0];	/* length */
 	cskb = alloc_skb(msgsize, GFP_ATOMIC);
 	if (!cskb) {
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
-	capi_cmsg2message(&iif->acmsg, __skb_put(cskb, msgsize));
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
-		capi_ctr_handle_message(&iif->ctr, ap->id, cskb);
+	capi_cmsg2message(cmsg, __skb_put(cskb, msgsize));
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
+	capi_ctr_handle_message(&iif->ctr, ap->id, cskb);
 }
 
 
@@ -1207,8 +1200,8 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	u16 info;
 
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_message2cmsg(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* get free B channel & construct PLCI */
 	bcs = gigaset_get_free_channel(cs);
@@ -1411,8 +1404,16 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 					"CONNECT_REQ", "Calling pty subaddr");
 	ignore_cstruct_param(cs, cmsg->LLC,
 					"CONNECT_REQ", "LLC");
-	ignore_cmstruct_param(cs, cmsg->AdditionalInfo,
-					"CONNECT_REQ", "Additional Info");
+	if (cmsg->AdditionalInfo != CAPI_DEFAULT) {
+		ignore_cstruct_param(cs, cmsg->BChannelinformation,
+					"CONNECT_REQ", "B Channel Information");
+		ignore_cstruct_param(cs, cmsg->Keypadfacility,
+					"CONNECT_REQ", "Keypad Facility");
+		ignore_cstruct_param(cs, cmsg->Useruserdata,
+					"CONNECT_REQ", "User-User Data");
+		ignore_cstruct_param(cs, cmsg->Facilitydataarray,
+					"CONNECT_REQ", "Facility Data Array");
+	}
 
 	/* encode parameter: B channel to use */
 	commands[AT_ISO] = kmalloc(9, GFP_KERNEL);
@@ -1458,8 +1459,8 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_message2cmsg(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 	dev_kfree_skb(skb);
 
 	/* extract and check channel number from PLCI */
@@ -1524,8 +1525,16 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 					"CONNECT_RESP", "Connected Subaddress");
 		ignore_cstruct_param(cs, cmsg->LLC,
 					"CONNECT_RESP", "LLC");
-		ignore_cmstruct_param(cs, cmsg->AdditionalInfo,
-					"CONNECT_RESP", "Additional Info");
+		if (cmsg->AdditionalInfo != CAPI_DEFAULT) {
+			ignore_cstruct_param(cs, cmsg->BChannelinformation,
+					"CONNECT_RESP", "BChannel Information");
+			ignore_cstruct_param(cs, cmsg->Keypadfacility,
+					"CONNECT_RESP", "Keypad Facility");
+			ignore_cstruct_param(cs, cmsg->Useruserdata,
+					"CONNECT_RESP", "User-User Data");
+			ignore_cstruct_param(cs, cmsg->Facilitydataarray,
+					"CONNECT_RESP", "Facility Data Array");
+		}
 
 		/* Accept call */
 		if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
@@ -1587,17 +1596,18 @@ static void do_connect_b3_req(struct gigaset_capi_ctr *iif,
 			      struct sk_buff *skb)
 {
 	struct cardstate *cs = iif->ctr.driverdata;
+	_cmsg *cmsg = &iif->acmsg;
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_message2cmsg(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number from PLCI */
-	channel = (iif->acmsg.adr.adrPLCI >> 8) & 0xff;
+	channel = (cmsg->adr.adrPLCI >> 8) & 0xff;
 	if (!channel || channel > cs->channels) {
 		dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
-			   "CONNECT_B3_REQ", "PLCI", iif->acmsg.adr.adrPLCI);
+			   "CONNECT_B3_REQ", "PLCI", cmsg->adr.adrPLCI);
 		send_conf(iif, ap, skb, CapiIllContrPlciNcci);
 		return;
 	}
@@ -1606,14 +1616,12 @@ static void do_connect_b3_req(struct gigaset_capi_ctr *iif,
 	ap->connected = APCONN_ACTIVE;
 
 	/* build NCCI: always 1 (one B3 connection only) */
-	iif->acmsg.adr.adrNCCI |= 1 << 16;
+	cmsg->adr.adrNCCI |= 1 << 16;
 
 	/* NCPI parameter: not applicable for B3 Transparent */
-	ignore_cstruct_param(cs, iif->acmsg.NCPI,
-				"CONNECT_B3_REQ", "NCPI");
-	send_conf(iif, ap, skb,
-		  (iif->acmsg.NCPI && iif->acmsg.NCPI[0]) ?
-			CapiNcpiNotSupportedByProtocol : CapiSuccess);
+	ignore_cstruct_param(cs, cmsg->NCPI, "CONNECT_B3_REQ", "NCPI");
+	send_conf(iif, ap, skb, (cmsg->NCPI && cmsg->NCPI[0]) ?
+				CapiNcpiNotSupportedByProtocol : CapiSuccess);
 }
 
 /*
@@ -1628,27 +1636,28 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 			       struct sk_buff *skb)
 {
 	struct cardstate *cs = iif->ctr.driverdata;
-	struct bc_state *bcs = NULL;
+	_cmsg *cmsg = &iif->acmsg;
+	struct bc_state *bcs;
 	int channel;
 	unsigned int msgsize;
 	u8 command;
 
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_message2cmsg(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number and NCCI */
-	channel = (iif->acmsg.adr.adrNCCI >> 8) & 0xff;
+	channel = (cmsg->adr.adrNCCI >> 8) & 0xff;
 	if (!channel || channel > cs->channels ||
-	    ((iif->acmsg.adr.adrNCCI >> 16) & 0xffff) != 1) {
+	    ((cmsg->adr.adrNCCI >> 16) & 0xffff) != 1) {
 		dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
-			   "CONNECT_B3_RESP", "NCCI", iif->acmsg.adr.adrNCCI);
+			   "CONNECT_B3_RESP", "NCCI", cmsg->adr.adrNCCI);
 		dev_kfree_skb(skb);
 		return;
 	}
 	bcs = &cs->bcs[channel-1];
 
-	if (iif->acmsg.Reject) {
+	if (cmsg->Reject) {
 		/* Reject: clear B3 connect received flag */
 		ap->connected = APCONN_SETUP;
 
@@ -1673,11 +1682,11 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 		command = CAPI_CONNECT_B3_ACTIVE;
 		msgsize = CAPI_CONNECT_B3_ACTIVE_IND_BASELEN;
 	}
-	capi_cmsg_header(&iif->acmsg, ap->id, command, CAPI_IND,
-			 ap->nextMessageNumber++, iif->acmsg.adr.adrNCCI);
+	capi_cmsg_header(cmsg, ap->id, command, CAPI_IND,
+			 ap->nextMessageNumber++, cmsg->adr.adrNCCI);
 	__skb_trim(skb, msgsize);
-	capi_cmsg2message(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_cmsg2message(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
 
@@ -1691,28 +1700,37 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 			      struct sk_buff *skb)
 {
 	struct cardstate *cs = iif->ctr.driverdata;
+	_cmsg *cmsg = &iif->acmsg;
 	struct bc_state *bcs;
 	_cmsg *b3cmsg;
 	struct sk_buff *b3skb;
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_message2cmsg(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number from PLCI */
-	channel = (iif->acmsg.adr.adrPLCI >> 8) & 0xff;
+	channel = (cmsg->adr.adrPLCI >> 8) & 0xff;
 	if (!channel || channel > cs->channels) {
 		dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
-			   "DISCONNECT_REQ", "PLCI", iif->acmsg.adr.adrPLCI);
+			   "DISCONNECT_REQ", "PLCI", cmsg->adr.adrPLCI);
 		send_conf(iif, ap, skb, CapiIllContrPlciNcci);
 		return;
 	}
 	bcs = cs->bcs + channel - 1;
 
 	/* ToDo: process parameter: Additional info */
-	ignore_cmstruct_param(cs, iif->acmsg.AdditionalInfo,
-			      "DISCONNECT_REQ", "Additional Info");
+	if (cmsg->AdditionalInfo != CAPI_DEFAULT) {
+		ignore_cstruct_param(cs, cmsg->BChannelinformation,
+				     "DISCONNECT_REQ", "B Channel Information");
+		ignore_cstruct_param(cs, cmsg->Keypadfacility,
+				     "DISCONNECT_REQ", "Keypad Facility");
+		ignore_cstruct_param(cs, cmsg->Useruserdata,
+				     "DISCONNECT_REQ", "User-User Data");
+		ignore_cstruct_param(cs, cmsg->Facilitydataarray,
+				     "DISCONNECT_REQ", "Facility Data Array");
+	}
 
 	/* skip if DISCONNECT_IND already sent */
 	if (!ap->connected)
@@ -1733,7 +1751,7 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 		}
 		capi_cmsg_header(b3cmsg, ap->id, CAPI_DISCONNECT_B3, CAPI_IND,
 				 ap->nextMessageNumber++,
-				 iif->acmsg.adr.adrPLCI | (1 << 16));
+				 cmsg->adr.adrPLCI | (1 << 16));
 		b3cmsg->Reason_B3 = CapiProtocolErrorLayer1;
 		b3skb = alloc_skb(CAPI_DISCONNECT_B3_IND_BASELEN, GFP_KERNEL);
 		if (b3skb == NULL) {
@@ -1769,18 +1787,19 @@ static void do_disconnect_b3_req(struct gigaset_capi_ctr *iif,
 				 struct sk_buff *skb)
 {
 	struct cardstate *cs = iif->ctr.driverdata;
+	_cmsg *cmsg = &iif->acmsg;
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
-	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
+	capi_message2cmsg(cmsg, skb->data);
+	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number and NCCI */
-	channel = (iif->acmsg.adr.adrNCCI >> 8) & 0xff;
+	channel = (cmsg->adr.adrNCCI >> 8) & 0xff;
 	if (!channel || channel > cs->channels ||
-	    ((iif->acmsg.adr.adrNCCI >> 16) & 0xffff) != 1) {
+	    ((cmsg->adr.adrNCCI >> 16) & 0xffff) != 1) {
 		dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
-			   "DISCONNECT_B3_REQ", "NCCI", iif->acmsg.adr.adrNCCI);
+			   "DISCONNECT_B3_REQ", "NCCI", cmsg->adr.adrNCCI);
 		send_conf(iif, ap, skb, CapiIllContrPlciNcci);
 		return;
 	}
@@ -1803,11 +1822,10 @@ static void do_disconnect_b3_req(struct gigaset_capi_ctr *iif,
 	gigaset_schedule_event(cs);
 
 	/* NCPI parameter: not applicable for B3 Transparent */
-	ignore_cstruct_param(cs, iif->acmsg.NCPI,
+	ignore_cstruct_param(cs, cmsg->NCPI,
 				"DISCONNECT_B3_REQ", "NCPI");
-	send_conf(iif, ap, skb,
-		  (iif->acmsg.NCPI && iif->acmsg.NCPI[0]) ?
-			CapiNcpiNotSupportedByProtocol : CapiSuccess);
+	send_conf(iif, ap, skb, (cmsg->NCPI && cmsg->NCPI[0]) ?
+				CapiNcpiNotSupportedByProtocol : CapiSuccess);
 }
 
 /*
-- 
1.6.2.1.214.ge986c
