From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/5] isdn/gigaset: correct CAPI connection state storage
Date: Tue, 22 Jun 2010 01:55:20 +0200 (CEST)
Message-ID: <20100622-patch-gigaset-05.tilman@imap.cc>
References: <20100622-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:38349 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933014Ab0FVAEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 20:04:55 -0400
In-Reply-To: <20100622-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAPI applications can handle several connections in parallel,
so one connection state per application isn't sufficient.
Store the connection state in the channel structure instead.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c    |  225 ++++++++++++++++++++++++++++++---------
 drivers/isdn/gigaset/common.c  |    4 +
 drivers/isdn/gigaset/gigaset.h |    4 +-
 3 files changed, 180 insertions(+), 53 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 7d9549e..c38750c 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -70,7 +70,7 @@
 #define MAX_NUMBER_DIGITS 20
 #define MAX_FMT_IE_LEN 20
 
-/* values for gigaset_capi_appl.connected */
+/* values for bcs->apconnstate */
 #define APCONN_NONE	0	/* inactive/listening */
 #define APCONN_SETUP	1	/* connecting */
 #define APCONN_ACTIVE	2	/* B channel up */
@@ -84,7 +84,6 @@ struct gigaset_capi_appl {
 	u16 nextMessageNumber;
 	u32 listenInfoMask;
 	u32 listenCIPmask;
-	int connected;
 };
 
 /* CAPI specific controller data structure */
@@ -384,7 +383,7 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 	}
 
 	/* don't send further B3 messages if disconnected */
-	if (ap->connected < APCONN_ACTIVE) {
+	if (bcs->apconnstate < APCONN_ACTIVE) {
 		gig_dbg(DEBUG_LLDATA, "disconnected, discarding ack");
 		return;
 	}
@@ -428,7 +427,7 @@ void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
 	}
 
 	/* don't send further B3 messages if disconnected */
-	if (ap->connected < APCONN_ACTIVE) {
+	if (bcs->apconnstate < APCONN_ACTIVE) {
 		gig_dbg(DEBUG_LLDATA, "disconnected, discarding data");
 		dev_kfree_skb_any(skb);
 		return;
@@ -500,6 +499,7 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 	u32 actCIPmask;
 	struct sk_buff *skb;
 	unsigned int msgsize;
+	unsigned long flags;
 	int i;
 
 	/*
@@ -624,7 +624,14 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 		format_ie(iif->hcmsg.CalledPartyNumber));
 
 	/* scan application list for matching listeners */
-	bcs->ap = NULL;
+	spin_lock_irqsave(&bcs->aplock, flags);
+	if (bcs->ap != NULL || bcs->apconnstate != APCONN_NONE) {
+		dev_warn(cs->dev, "%s: channel not properly cleared (%p/%d)\n",
+			 __func__, bcs->ap, bcs->apconnstate);
+		bcs->ap = NULL;
+		bcs->apconnstate = APCONN_NONE;
+	}
+	spin_unlock_irqrestore(&bcs->aplock, flags);
 	actCIPmask = 1 | (1 << iif->hcmsg.CIPValue);
 	list_for_each_entry(ap, &iif->appls, ctrlist)
 		if (actCIPmask & ap->listenCIPmask) {
@@ -642,10 +649,12 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 			dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
 
 			/* add to listeners on this B channel, update state */
+			spin_lock_irqsave(&bcs->aplock, flags);
 			ap->bcnext = bcs->ap;
 			bcs->ap = ap;
 			bcs->chstate |= CHS_NOTIFY_LL;
-			ap->connected = APCONN_SETUP;
+			bcs->apconnstate = APCONN_SETUP;
+			spin_unlock_irqrestore(&bcs->aplock, flags);
 
 			/* emit message */
 			capi_ctr_handle_message(&iif->ctr, ap->id, skb);
@@ -670,7 +679,7 @@ static void send_disconnect_ind(struct bc_state *bcs,
 	struct gigaset_capi_ctr *iif = cs->iif;
 	struct sk_buff *skb;
 
-	if (ap->connected == APCONN_NONE)
+	if (bcs->apconnstate == APCONN_NONE)
 		return;
 
 	capi_cmsg_header(&iif->hcmsg, ap->id, CAPI_DISCONNECT, CAPI_IND,
@@ -684,7 +693,6 @@ static void send_disconnect_ind(struct bc_state *bcs,
 	}
 	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, CAPI_DISCONNECT_IND_LEN));
 	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
-	ap->connected = APCONN_NONE;
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
 
@@ -701,9 +709,9 @@ static void send_disconnect_b3_ind(struct bc_state *bcs,
 	struct sk_buff *skb;
 
 	/* nothing to do if no logical connection active */
-	if (ap->connected < APCONN_ACTIVE)
+	if (bcs->apconnstate < APCONN_ACTIVE)
 		return;
-	ap->connected = APCONN_SETUP;
+	bcs->apconnstate = APCONN_SETUP;
 
 	capi_cmsg_header(&iif->hcmsg, ap->id, CAPI_DISCONNECT_B3, CAPI_IND,
 			 ap->nextMessageNumber++,
@@ -730,14 +738,25 @@ void gigaset_isdn_connD(struct bc_state *bcs)
 {
 	struct cardstate *cs = bcs->cs;
 	struct gigaset_capi_ctr *iif = cs->iif;
-	struct gigaset_capi_appl *ap = bcs->ap;
+	struct gigaset_capi_appl *ap;
 	struct sk_buff *skb;
 	unsigned int msgsize;
+	unsigned long flags;
 
+	spin_lock_irqsave(&bcs->aplock, flags);
+	ap = bcs->ap;
 	if (!ap) {
+		spin_unlock_irqrestore(&bcs->aplock, flags);
 		dev_err(cs->dev, "%s: no application\n", __func__);
 		return;
 	}
+	if (bcs->apconnstate == APCONN_NONE) {
+		spin_unlock_irqrestore(&bcs->aplock, flags);
+		dev_warn(cs->dev, "%s: application %u not connected\n",
+			 __func__, ap->id);
+		return;
+	}
+	spin_unlock_irqrestore(&bcs->aplock, flags);
 	while (ap->bcnext) {
 		/* this should never happen */
 		dev_warn(cs->dev, "%s: dropping extra application %u\n",
@@ -746,11 +765,6 @@ void gigaset_isdn_connD(struct bc_state *bcs)
 				    CapiCallGivenToOtherApplication);
 		ap->bcnext = ap->bcnext->bcnext;
 	}
-	if (ap->connected == APCONN_NONE) {
-		dev_warn(cs->dev, "%s: application %u not connected\n",
-			 __func__, ap->id);
-		return;
-	}
 
 	/* prepare CONNECT_ACTIVE_IND message
 	 * Note: LLC not supported by device
@@ -788,17 +802,24 @@ void gigaset_isdn_connD(struct bc_state *bcs)
 void gigaset_isdn_hupD(struct bc_state *bcs)
 {
 	struct gigaset_capi_appl *ap;
+	unsigned long flags;
 
 	/*
 	 * ToDo: pass on reason code reported by device
 	 * (requires ev-layer state machine extension to collect
 	 * ZCAU device reply)
 	 */
-	for (ap = bcs->ap; ap != NULL; ap = ap->bcnext) {
+	spin_lock_irqsave(&bcs->aplock, flags);
+	while (bcs->ap != NULL) {
+		ap = bcs->ap;
+		bcs->ap = ap->bcnext;
+		spin_unlock_irqrestore(&bcs->aplock, flags);
 		send_disconnect_b3_ind(bcs, ap);
 		send_disconnect_ind(bcs, ap, 0);
+		spin_lock_irqsave(&bcs->aplock, flags);
 	}
-	bcs->ap = NULL;
+	bcs->apconnstate = APCONN_NONE;
+	spin_unlock_irqrestore(&bcs->aplock, flags);
 }
 
 /**
@@ -812,24 +833,21 @@ void gigaset_isdn_connB(struct bc_state *bcs)
 {
 	struct cardstate *cs = bcs->cs;
 	struct gigaset_capi_ctr *iif = cs->iif;
-	struct gigaset_capi_appl *ap = bcs->ap;
+	struct gigaset_capi_appl *ap;
 	struct sk_buff *skb;
+	unsigned long flags;
 	unsigned int msgsize;
 	u8 command;
 
+	spin_lock_irqsave(&bcs->aplock, flags);
+	ap = bcs->ap;
 	if (!ap) {
+		spin_unlock_irqrestore(&bcs->aplock, flags);
 		dev_err(cs->dev, "%s: no application\n", __func__);
 		return;
 	}
-	while (ap->bcnext) {
-		/* this should never happen */
-		dev_warn(cs->dev, "%s: dropping extra application %u\n",
-			 __func__, ap->bcnext->id);
-		send_disconnect_ind(bcs, ap->bcnext,
-				    CapiCallGivenToOtherApplication);
-		ap->bcnext = ap->bcnext->bcnext;
-	}
-	if (!ap->connected) {
+	if (!bcs->apconnstate) {
+		spin_unlock_irqrestore(&bcs->aplock, flags);
 		dev_warn(cs->dev, "%s: application %u not connected\n",
 			 __func__, ap->id);
 		return;
@@ -841,13 +859,26 @@ void gigaset_isdn_connB(struct bc_state *bcs)
 	 * CONNECT_B3_ACTIVE_IND in reply to CONNECT_B3_RESP
 	 * Parameters in both cases always: NCCI = 1, NCPI empty
 	 */
-	if (ap->connected >= APCONN_ACTIVE) {
+	if (bcs->apconnstate >= APCONN_ACTIVE) {
 		command = CAPI_CONNECT_B3_ACTIVE;
 		msgsize = CAPI_CONNECT_B3_ACTIVE_IND_BASELEN;
 	} else {
 		command = CAPI_CONNECT_B3;
 		msgsize = CAPI_CONNECT_B3_IND_BASELEN;
 	}
+	bcs->apconnstate = APCONN_ACTIVE;
+
+	spin_unlock_irqrestore(&bcs->aplock, flags);
+
+	while (ap->bcnext) {
+		/* this should never happen */
+		dev_warn(cs->dev, "%s: dropping extra application %u\n",
+			 __func__, ap->bcnext->id);
+		send_disconnect_ind(bcs, ap->bcnext,
+				    CapiCallGivenToOtherApplication);
+		ap->bcnext = ap->bcnext->bcnext;
+	}
+
 	capi_cmsg_header(&iif->hcmsg, ap->id, command, CAPI_IND,
 			 ap->nextMessageNumber++,
 			 iif->ctr.cnr | ((bcs->channel + 1) << 8) | (1 << 16));
@@ -858,7 +889,6 @@ void gigaset_isdn_connB(struct bc_state *bcs)
 	}
 	capi_cmsg2message(&iif->hcmsg, __skb_put(skb, msgsize));
 	dump_cmsg(DEBUG_CMD, __func__, &iif->hcmsg);
-	ap->connected = APCONN_ACTIVE;
 	capi_ctr_handle_message(&iif->ctr, ap->id, skb);
 }
 
@@ -964,6 +994,61 @@ static void gigaset_register_appl(struct capi_ctr *ctr, u16 appl,
 	ap->rp = *rp;
 
 	list_add(&ap->ctrlist, &iif->appls);
+	dev_info(cs->dev, "application %u registered\n", ap->id);
+}
+
+/*
+ * remove CAPI application from channel
+ * helper function to keep indentation levels down and stay in 80 columns
+ */
+
+static inline void remove_appl_from_channel(struct bc_state *bcs,
+					    struct gigaset_capi_appl *ap)
+{
+	struct cardstate *cs = bcs->cs;
+	struct gigaset_capi_appl *bcap;
+	unsigned long flags;
+	int prevconnstate;
+
+	spin_lock_irqsave(&bcs->aplock, flags);
+	bcap = bcs->ap;
+	if (bcap == NULL) {
+		spin_unlock_irqrestore(&bcs->aplock, flags);
+		return;
+	}
+
+	/* check first application on channel */
+	if (bcap == ap) {
+		bcs->ap = ap->bcnext;
+		if (bcs->ap != NULL) {
+			spin_unlock_irqrestore(&bcs->aplock, flags);
+			return;
+		}
+
+		/* none left, clear channel state */
+		prevconnstate = bcs->apconnstate;
+		bcs->apconnstate = APCONN_NONE;
+		spin_unlock_irqrestore(&bcs->aplock, flags);
+
+		if (prevconnstate == APCONN_ACTIVE) {
+			dev_notice(cs->dev, "%s: hanging up channel %u\n",
+				   __func__, bcs->channel);
+			gigaset_add_event(cs, &bcs->at_state,
+					  EV_HUP, NULL, 0, NULL);
+			gigaset_schedule_event(cs);
+		}
+		return;
+	}
+
+	/* check remaining list */
+	do {
+		if (bcap->bcnext == ap) {
+			bcap->bcnext = bcap->bcnext->bcnext;
+			return;
+		}
+		bcap = bcap->bcnext;
+	} while (bcap != NULL);
+	spin_unlock_irqrestore(&bcs->aplock, flags);
 }
 
 /*
@@ -975,19 +1060,19 @@ static void gigaset_release_appl(struct capi_ctr *ctr, u16 appl)
 		= container_of(ctr, struct gigaset_capi_ctr, ctr);
 	struct cardstate *cs = iif->ctr.driverdata;
 	struct gigaset_capi_appl *ap, *tmp;
+	unsigned ch;
 
 	list_for_each_entry_safe(ap, tmp, &iif->appls, ctrlist)
 		if (ap->id == appl) {
-			if (ap->connected != APCONN_NONE) {
-				dev_err(cs->dev,
-					"%s: application %u still connected\n",
-					__func__, ap->id);
-				/* ToDo: clear active connection */
-			}
+			/* remove from any channels */
+			for (ch = 0; ch < cs->channels; ch++)
+				remove_appl_from_channel(&cs->bcs[ch], ap);
+
+			/* remove from registration list */
 			list_del(&ap->ctrlist);
 			kfree(ap);
+			dev_info(cs->dev, "application %u released\n", appl);
 		}
-
 }
 
 /*
@@ -1166,6 +1251,7 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	char **commands;
 	char *s;
 	u8 *pp;
+	unsigned long flags;
 	int i, l, lbc, lhlc;
 	u16 info;
 
@@ -1181,8 +1267,15 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 		send_conf(iif, ap, skb, CapiNoPlciAvailable);
 		return;
 	}
+	spin_lock_irqsave(&bcs->aplock, flags);
+	if (bcs->ap != NULL || bcs->apconnstate != APCONN_NONE)
+		dev_warn(cs->dev, "%s: channel not properly cleared (%p/%d)\n",
+			 __func__, bcs->ap, bcs->apconnstate);
 	ap->bcnext = NULL;
 	bcs->ap = ap;
+	bcs->apconnstate = APCONN_SETUP;
+	spin_unlock_irqrestore(&bcs->aplock, flags);
+
 	bcs->rx_bufsize = ap->rp.datablklen;
 	dev_kfree_skb(bcs->rx_skb);
 	gigaset_new_rx_skb(bcs);
@@ -1419,7 +1512,6 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 		goto error;
 	}
 	gigaset_schedule_event(cs);
-	ap->connected = APCONN_SETUP;
 	send_conf(iif, ap, skb, CapiSuccess);
 	return;
 
@@ -1447,6 +1539,7 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 	_cmsg *cmsg = &iif->acmsg;
 	struct bc_state *bcs;
 	struct gigaset_capi_appl *oap;
+	unsigned long flags;
 	int channel;
 
 	/* decode message */
@@ -1466,12 +1559,21 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 	switch (cmsg->Reject) {
 	case 0:		/* Accept */
 		/* drop all competing applications, keep only this one */
-		for (oap = bcs->ap; oap != NULL; oap = oap->bcnext)
-			if (oap != ap)
+		spin_lock_irqsave(&bcs->aplock, flags);
+		while (bcs->ap != NULL) {
+			oap = bcs->ap;
+			bcs->ap = oap->bcnext;
+			if (oap != ap) {
+				spin_unlock_irqrestore(&bcs->aplock, flags);
 				send_disconnect_ind(bcs, oap,
 					CapiCallGivenToOtherApplication);
+				spin_lock_irqsave(&bcs->aplock, flags);
+			}
+		}
 		ap->bcnext = NULL;
 		bcs->ap = ap;
+		spin_unlock_irqrestore(&bcs->aplock, flags);
+
 		bcs->rx_bufsize = ap->rp.datablklen;
 		dev_kfree_skb(bcs->rx_skb);
 		gigaset_new_rx_skb(bcs);
@@ -1542,31 +1644,45 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 		send_disconnect_ind(bcs, ap, 0);
 
 		/* remove it from the list of listening apps */
+		spin_lock_irqsave(&bcs->aplock, flags);
 		if (bcs->ap == ap) {
 			bcs->ap = ap->bcnext;
-			if (bcs->ap == NULL)
+			if (bcs->ap == NULL) {
 				/* last one: stop ev-layer hupD notifications */
+				bcs->apconnstate = APCONN_NONE;
 				bcs->chstate &= ~CHS_NOTIFY_LL;
+			}
+			spin_unlock_irqrestore(&bcs->aplock, flags);
 			return;
 		}
 		for (oap = bcs->ap; oap != NULL; oap = oap->bcnext) {
 			if (oap->bcnext == ap) {
 				oap->bcnext = oap->bcnext->bcnext;
+				spin_unlock_irqrestore(&bcs->aplock, flags);
 				return;
 			}
 		}
+		spin_unlock_irqrestore(&bcs->aplock, flags);
 		dev_err(cs->dev, "%s: application %u not found\n",
 			__func__, ap->id);
 		return;
 
 	default:		/* Reject */
 		/* drop all competing applications, keep only this one */
-		for (oap = bcs->ap; oap != NULL; oap = oap->bcnext)
-			if (oap != ap)
+		spin_lock_irqsave(&bcs->aplock, flags);
+		while (bcs->ap != NULL) {
+			oap = bcs->ap;
+			bcs->ap = oap->bcnext;
+			if (oap != ap) {
+				spin_unlock_irqrestore(&bcs->aplock, flags);
 				send_disconnect_ind(bcs, oap,
 					CapiCallGivenToOtherApplication);
+				spin_lock_irqsave(&bcs->aplock, flags);
+			}
+		}
 		ap->bcnext = NULL;
 		bcs->ap = ap;
+		spin_unlock_irqrestore(&bcs->aplock, flags);
 
 		/* reject call - will trigger DISCONNECT_IND for this app */
 		dev_info(cs->dev, "%s: Reject=%x\n",
@@ -1589,6 +1705,7 @@ static void do_connect_b3_req(struct gigaset_capi_ctr *iif,
 {
 	struct cardstate *cs = iif->ctr.driverdata;
 	_cmsg *cmsg = &iif->acmsg;
+	struct bc_state *bcs;
 	int channel;
 
 	/* decode message */
@@ -1603,9 +1720,10 @@ static void do_connect_b3_req(struct gigaset_capi_ctr *iif,
 		send_conf(iif, ap, skb, CapiIllContrPlciNcci);
 		return;
 	}
+	bcs = &cs->bcs[channel-1];
 
 	/* mark logical connection active */
-	ap->connected = APCONN_ACTIVE;
+	bcs->apconnstate = APCONN_ACTIVE;
 
 	/* build NCCI: always 1 (one B3 connection only) */
 	cmsg->adr.adrNCCI |= 1 << 16;
@@ -1651,7 +1769,7 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 
 	if (cmsg->Reject) {
 		/* Reject: clear B3 connect received flag */
-		ap->connected = APCONN_SETUP;
+		bcs->apconnstate = APCONN_SETUP;
 
 		/* trigger hangup, causing eventual DISCONNECT_IND */
 		if (!gigaset_add_event(cs, &bcs->at_state,
@@ -1723,11 +1841,11 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 	}
 
 	/* skip if DISCONNECT_IND already sent */
-	if (!ap->connected)
+	if (!bcs->apconnstate)
 		return;
 
 	/* check for active logical connection */
-	if (ap->connected >= APCONN_ACTIVE) {
+	if (bcs->apconnstate >= APCONN_ACTIVE) {
 		/*
 		 * emit DISCONNECT_B3_IND with cause 0x3301
 		 * use separate cmsg structure, as the content of iif->acmsg
@@ -1776,6 +1894,7 @@ static void do_disconnect_b3_req(struct gigaset_capi_ctr *iif,
 {
 	struct cardstate *cs = iif->ctr.driverdata;
 	_cmsg *cmsg = &iif->acmsg;
+	struct bc_state *bcs;
 	int channel;
 
 	/* decode message */
@@ -1791,17 +1910,17 @@ static void do_disconnect_b3_req(struct gigaset_capi_ctr *iif,
 		send_conf(iif, ap, skb, CapiIllContrPlciNcci);
 		return;
 	}
+	bcs = &cs->bcs[channel-1];
 
 	/* reject if logical connection not active */
-	if (ap->connected < APCONN_ACTIVE) {
+	if (bcs->apconnstate < APCONN_ACTIVE) {
 		send_conf(iif, ap, skb,
 			  CapiMessageNotSupportedInCurrentState);
 		return;
 	}
 
 	/* trigger hangup, causing eventual DISCONNECT_B3_IND */
-	if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
-			       EV_HUP, NULL, 0, NULL)) {
+	if (!gigaset_add_event(cs, &bcs->at_state, EV_HUP, NULL, 0, NULL)) {
 		send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
 		return;
 	}
@@ -1822,6 +1941,7 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 			   struct sk_buff *skb)
 {
 	struct cardstate *cs = iif->ctr.driverdata;
+	struct bc_state *bcs;
 	int channel = CAPIMSG_PLCI_PART(skb->data);
 	u16 ncci = CAPIMSG_NCCI_PART(skb->data);
 	u16 msglen = CAPIMSG_LEN(skb->data);
@@ -1844,6 +1964,7 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 		send_conf(iif, ap, skb, CapiIllContrPlciNcci);
 		return;
 	}
+	bcs = &cs->bcs[channel-1];
 	if (msglen != CAPI_DATA_B3_REQ_LEN && msglen != CAPI_DATA_B3_REQ_LEN64)
 		dev_notice(cs->dev, "%s: unexpected length %d\n",
 			   "DATA_B3_REQ", msglen);
@@ -1863,7 +1984,7 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 	}
 
 	/* reject if logical connection not active */
-	if (ap->connected < APCONN_ACTIVE) {
+	if (bcs->apconnstate < APCONN_ACTIVE) {
 		send_conf(iif, ap, skb, CapiMessageNotSupportedInCurrentState);
 		return;
 	}
@@ -1874,7 +1995,7 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 	skb_pull(skb, msglen);
 
 	/* pass to device-specific module */
-	if (cs->ops->send_skb(&cs->bcs[channel-1], skb) < 0) {
+	if (cs->ops->send_skb(bcs, skb) < 0) {
 		send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
 		return;
 	}
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 9778fab..5d4befb 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -649,6 +649,10 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	for (i = 0; i < AT_NUM; ++i)
 		bcs->commands[i] = NULL;
 
+	spin_lock_init(&bcs->aplock);
+	bcs->ap = NULL;
+	bcs->apconnstate = 0;
+
 	gig_dbg(DEBUG_INIT, "  setting up bcs[%d]->hw", channel);
 	if (cs->ops->initbcshw(bcs))
 		return bcs;
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index c4e6c26..8738b08 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -403,7 +403,9 @@ struct bc_state {
 		struct bas_bc_state *bas;	/* usb hardware driver (base) */
 	} hw;
 
-	void *ap;			/* LL application structure */
+	void *ap;			/* associated LL application */
+	int apconnstate;		/* LL application connection state */
+	spinlock_t aplock;
 };
 
 struct cardstate {
-- 
1.6.5.3.298.g39add

