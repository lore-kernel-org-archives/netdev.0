From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 10/12] isdn/capi: handle CAPI 2.0 message parser failures
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <cd049391a1b887bd39d7c1f069e94288036d9eac.1413021631.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:58542 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbaJKLrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:04 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have callers of capi_cmsg2message and capi_message2cmsg handle
non-zero return values indicating failure.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
Note: The issue about printk(KERN_ERR which checkpatch is complaining
about is present in many more places in the original source file. I
deliberately preferred keeping the style consistent within the file.

 drivers/isdn/capi/capidrv.c |  24 +++++--
 drivers/isdn/gigaset/capi.c | 148 +++++++++++++++++++++++++++++++++++++-------
 2 files changed, 145 insertions(+), 27 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index fd6d28f..1cc6ca8 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -506,7 +506,10 @@ static void send_message(capidrv_contr *card, _cmsg *cmsg)
 	struct sk_buff *skb;
 	size_t len;
 
-	capi_cmsg2message(cmsg, cmsg->buf);
+	if (capi_cmsg2message(cmsg, cmsg->buf)) {
+		printk(KERN_ERR "capidrv::send_message: parser failure\n");
+		return;
+	}
 	len = CAPIMSG_LEN(cmsg->buf);
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (!skb) {
@@ -1578,7 +1581,12 @@ static _cmsg s_cmsg;
 
 static void capidrv_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 {
-	capi_message2cmsg(&s_cmsg, skb->data);
+	if (capi_message2cmsg(&s_cmsg, skb->data)) {
+		printk(KERN_ERR "capidrv: applid=%d: received invalid message\n",
+		       ap->applid);
+		kfree_skb(skb);
+		return;
+	}
 	if (debugmode > 3) {
 		_cdebbuf *cdb = capi_cmsg2str(&s_cmsg);
 
@@ -1903,7 +1911,11 @@ static int capidrv_command(isdn_ctrl *c, capidrv_contr *card)
 				       NULL,	/* Useruserdata */
 				       NULL	/* Facilitydataarray */
 			);
-		capi_cmsg2message(&cmdcmsg, cmdcmsg.buf);
+		if (capi_cmsg2message(&cmdcmsg, cmdcmsg.buf)) {
+			printk(KERN_ERR "capidrv-%d: capidrv_command: parser failure\n",
+			       card->contrnr);
+			return -EINVAL;
+		}
 		plci_change_state(card, bchan->plcip, EV_PLCI_CONNECT_RESP);
 		send_message(card, &cmdcmsg);
 		return 0;
@@ -2090,7 +2102,11 @@ static int if_sendbuf(int id, int channel, int doack, struct sk_buff *skb)
 	if (capidrv_add_ack(nccip, datahandle, doack ? (int)skb->len : -1) < 0)
 		return 0;
 
-	capi_cmsg2message(&sendcmsg, sendcmsg.buf);
+	if (capi_cmsg2message(&sendcmsg, sendcmsg.buf)) {
+		printk(KERN_ERR "capidrv-%d: if_sendbuf: parser failure\n",
+		       card->contrnr);
+		return -EINVAL;
+	}
 	msglen = CAPIMSG_LEN(sendcmsg.buf);
 	if (skb_headroom(skb) < msglen) {
 		struct sk_buff *nskb = skb_realloc_headroom(skb, msglen);
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 47e2a91..ccec777 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -647,7 +647,13 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 					__func__);
 				break;
 			}
-			capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize));
+			if (capi_cmsg2message(&iif->hcmsg,
+					      __skb_put(skb, msgsize))) {
+				dev_err(cs->dev, "%s: message parser failure\n",
+					__func__);
+				dev_kfree_skb_any(skb);
+				break;
+			}
 			dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
 
 			/* add to listeners on this B channel, update state */
@@ -693,7 +699,12 @@ static void send_disconnect_ind(struct bc_state *bcs,
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
-	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, CAPI_DISCONNECT_IND_LEN));
+	if (capi_cmsg2message(&iif->hcmsg,
+			      __skb_put(skb, CAPI_DISCONNECT_IND_LEN))) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
@@ -723,8 +734,12 @@ static void send_disconnect_b3_ind(struct bc_state *bcs,
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
-	capi_cmsg2message(&iif->hcmsg,
-			  __skb_put(skb, CAPI_DISCONNECT_B3_IND_BASELEN));
+	if (capi_cmsg2message(&iif->hcmsg,
+			  __skb_put(skb, CAPI_DISCONNECT_B3_IND_BASELEN))) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
@@ -789,7 +804,11 @@ void gigaset_isdn_connD(struct bc_state *bcs)
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
-	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize));
+	if (capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize))) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
@@ -889,7 +908,11 @@ void gigaset_isdn_connB(struct bc_state *bcs)
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
-	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize));
+	if (capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize))) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
@@ -1096,13 +1119,19 @@ static void send_conf(struct gigaset_capi_ctr *iif,
 		      struct sk_buff *skb,
 		      u16 info)
 {
+	struct cardstate *cs = iif->ctr.driverdata;
+
 	/*
 	 * _CONF replies always only have NCCI and Info parameters
 	 * so they'll fit into the _REQ message skb
 	 */
 	capi_cmsg_answer(&iif->acmsg);
 	iif->acmsg.Info = info;
-	capi_cmsg2message(&iif->acmsg, skb->data);
+	if (capi_cmsg2message(&iif->acmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	__skb_trim(skb, CAPI_STDCONF_LEN);
 	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
@@ -1124,7 +1153,11 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 	static u8 confparam[10];	/* max. 9 octets + length byte */
 
 	/* decode message */
-	capi_message2cmsg(cmsg, skb->data);
+	if (capi_message2cmsg(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/*
@@ -1223,6 +1256,7 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 	}
 
 	/* send FACILITY_CONF with given Info and confirmation parameter */
+	dev_kfree_skb_any(skb);
 	capi_cmsg_answer(cmsg);
 	cmsg->Info = info;
 	cmsg->FacilityConfirmationParameter = confparam;
@@ -1232,7 +1266,11 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
-	capi_cmsg2message(cmsg, __skb_put(cskb, msgsize));
+	if (capi_cmsg2message(cmsg, __skb_put(cskb, msgsize))) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(cskb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, cskb);
 }
@@ -1246,8 +1284,14 @@ static void do_listen_req(struct gigaset_capi_ctr *iif,
 			  struct gigaset_capi_appl *ap,
 			  struct sk_buff *skb)
 {
+	struct cardstate *cs = iif->ctr.driverdata;
+
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
+	if (capi_message2cmsg(&iif->acmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 
 	/* store listening parameters */
@@ -1264,8 +1308,14 @@ static void do_alert_req(struct gigaset_capi_ctr *iif,
 			 struct gigaset_capi_appl *ap,
 			 struct sk_buff *skb)
 {
+	struct cardstate *cs = iif->ctr.driverdata;
+
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
+	if (capi_message2cmsg(&iif->acmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 	send_conf(iif, ap, skb, CapiAlertAlreadySent);
 }
@@ -1290,7 +1340,11 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	u16 info;
 
 	/* decode message */
-	capi_message2cmsg(cmsg, skb->data);
+	if (capi_message2cmsg(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* get free B channel & construct PLCI */
@@ -1577,7 +1631,11 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(cmsg, skb->data);
+	if (capi_message2cmsg(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 	dev_kfree_skb_any(skb);
 
@@ -1743,7 +1801,11 @@ static void do_connect_b3_req(struct gigaset_capi_ctr *iif,
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(cmsg, skb->data);
+	if (capi_message2cmsg(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number from PLCI */
@@ -1788,7 +1850,11 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 	u8 command;
 
 	/* decode message */
-	capi_message2cmsg(cmsg, skb->data);
+	if (capi_message2cmsg(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number and NCCI */
@@ -1828,7 +1894,11 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 	capi_cmsg_header(cmsg, ap->id, command, CAPI_IND,
 			 ap->nextMessageNumber++, cmsg->adr.adrNCCI);
 	__skb_trim(skb, msgsize);
-	capi_cmsg2message(cmsg, skb->data);
+	if (capi_cmsg2message(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
@@ -1850,7 +1920,11 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(cmsg, skb->data);
+	if (capi_message2cmsg(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number from PLCI */
@@ -1906,8 +1980,14 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 			kfree(b3cmsg);
 			return;
 		}
-		capi_cmsg2message(b3cmsg,
-				  __skb_put(b3skb, CAPI_DISCONNECT_B3_IND_BASELEN));
+		if (capi_cmsg2message(b3cmsg,
+				      __skb_put(b3skb, CAPI_DISCONNECT_B3_IND_BASELEN))) {
+			dev_err(cs->dev, "%s: message parser failure\n",
+				__func__);
+			kfree(b3cmsg);
+			dev_kfree_skb_any(b3skb);
+			return;
+		}
 		dump_cmsg(DEBUG_CMD, __func__, b3cmsg);
 		kfree(b3cmsg);
 		capi_ctr_handle_message(&iif->ctr, ap->id, b3skb);
@@ -1938,7 +2018,11 @@ static void do_disconnect_b3_req(struct gigaset_capi_ctr *iif,
 	int channel;
 
 	/* decode message */
-	capi_message2cmsg(cmsg, skb->data);
+	if (capi_message2cmsg(cmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
 
 	/* extract and check channel number and NCCI */
@@ -2055,8 +2139,14 @@ static void do_reset_b3_req(struct gigaset_capi_ctr *iif,
 			    struct gigaset_capi_appl *ap,
 			    struct sk_buff *skb)
 {
+	struct cardstate *cs = iif->ctr.driverdata;
+
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
+	if (capi_message2cmsg(&iif->acmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 	send_conf(iif, ap, skb,
 		  CapiResetProcedureNotSupportedByCurrentProtocol);
@@ -2069,8 +2159,14 @@ static void do_unsupported(struct gigaset_capi_ctr *iif,
 			   struct gigaset_capi_appl *ap,
 			   struct sk_buff *skb)
 {
+	struct cardstate *cs = iif->ctr.driverdata;
+
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
+	if (capi_message2cmsg(&iif->acmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 	send_conf(iif, ap, skb, CapiMessageNotSupportedInCurrentState);
 }
@@ -2082,8 +2178,14 @@ static void do_nothing(struct gigaset_capi_ctr *iif,
 		       struct gigaset_capi_appl *ap,
 		       struct sk_buff *skb)
 {
+	struct cardstate *cs = iif->ctr.driverdata;
+
 	/* decode message */
-	capi_message2cmsg(&iif->acmsg, skb->data);
+	if (capi_message2cmsg(&iif->acmsg, skb->data)) {
+		dev_err(cs->dev, "%s: message parser failure\n", __func__);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 	dev_kfree_skb_any(skb);
 }
-- 
1.9.2.459.g68773ac
