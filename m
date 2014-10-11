From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 05/12] isdn/gigaset: fix non-heap pointer deallocation
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <41653e83da96a157ec8ba176595478d9f6ab0da7.1413021630.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:56977 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

at_state structures may be allocated individually or as part of a
cardstate or bc_state structure. The disconnect() function handled
both cases, creating a risk that it might try to deallocate an
at_state structure that had not been allocated individually.
Fix by splitting disconnect() into two variants handling cases
with and without an associated B channel separately, and adding
an explicit check.

Spotted with Coverity.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c | 111 +++++++++++++++++++++++++---------------
 1 file changed, 70 insertions(+), 41 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 0f699eb..c8ced12 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -604,14 +604,14 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 }
 EXPORT_SYMBOL_GPL(gigaset_handle_modem_response);
 
-/* disconnect
+/* disconnect_nobc
  * process closing of connection associated with given AT state structure
+ * without B channel
  */
-static void disconnect(struct at_state_t **at_state_p)
+static void disconnect_nobc(struct at_state_t **at_state_p,
+			    struct cardstate *cs)
 {
 	unsigned long flags;
-	struct bc_state *bcs = (*at_state_p)->bcs;
-	struct cardstate *cs = (*at_state_p)->cs;
 
 	spin_lock_irqsave(&cs->lock, flags);
 	++(*at_state_p)->seq_index;
@@ -622,23 +622,44 @@ static void disconnect(struct at_state_t **at_state_p)
 		gig_dbg(DEBUG_EVENT, "Scheduling PC_UMMODE");
 		cs->commands_pending = 1;
 	}
-	spin_unlock_irqrestore(&cs->lock, flags);
 
-	if (bcs) {
-		/* B channel assigned: invoke hardware specific handler */
-		cs->ops->close_bchannel(bcs);
-		/* notify LL */
-		if (bcs->chstate & (CHS_D_UP | CHS_NOTIFY_LL)) {
-			bcs->chstate &= ~(CHS_D_UP | CHS_NOTIFY_LL);
-			gigaset_isdn_hupD(bcs);
-		}
-	} else {
-		/* no B channel assigned: just deallocate */
-		spin_lock_irqsave(&cs->lock, flags);
+	/* check for and deallocate temporary AT state */
+	if (!list_empty(&(*at_state_p)->list)) {
 		list_del(&(*at_state_p)->list);
 		kfree(*at_state_p);
 		*at_state_p = NULL;
-		spin_unlock_irqrestore(&cs->lock, flags);
+	}
+
+	spin_unlock_irqrestore(&cs->lock, flags);
+}
+
+/* disconnect_bc
+ * process closing of connection associated with given AT state structure
+ * and B channel
+ */
+static void disconnect_bc(struct at_state_t *at_state,
+			  struct cardstate *cs, struct bc_state *bcs)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cs->lock, flags);
+	++at_state->seq_index;
+
+	/* revert to selected idle mode */
+	if (!cs->cidmode) {
+		cs->at_state.pending_commands |= PC_UMMODE;
+		gig_dbg(DEBUG_EVENT, "Scheduling PC_UMMODE");
+		cs->commands_pending = 1;
+	}
+	spin_unlock_irqrestore(&cs->lock, flags);
+
+	/* invoke hardware specific handler */
+	cs->ops->close_bchannel(bcs);
+
+	/* notify LL */
+	if (bcs->chstate & (CHS_D_UP | CHS_NOTIFY_LL)) {
+		bcs->chstate &= ~(CHS_D_UP | CHS_NOTIFY_LL);
+		gigaset_isdn_hupD(bcs);
 	}
 }
 
@@ -646,7 +667,7 @@ static void disconnect(struct at_state_t **at_state_p)
  * get a free AT state structure: either one of those associated with the
  * B channels of the Gigaset device, or if none of those is available,
  * a newly allocated one with bcs=NULL
- * The structure should be freed by calling disconnect() after use.
+ * The structure should be freed by calling disconnect_nobc() after use.
  */
 static inline struct at_state_t *get_free_channel(struct cardstate *cs,
 						  int cid)
@@ -1057,7 +1078,7 @@ static void do_action(int action, struct cardstate *cs,
 		      struct event_t *ev)
 {
 	struct at_state_t *at_state = *p_at_state;
-	struct at_state_t *at_state2;
+	struct bc_state *bcs2;
 	unsigned long flags;
 
 	int channel;
@@ -1156,8 +1177,8 @@ static void do_action(int action, struct cardstate *cs,
 		break;
 	case ACT_RING:
 		/* get fresh AT state structure for new CID */
-		at_state2 = get_free_channel(cs, ev->parameter);
-		if (!at_state2) {
+		at_state = get_free_channel(cs, ev->parameter);
+		if (!at_state) {
 			dev_warn(cs->dev,
 				 "RING ignored: could not allocate channel structure\n");
 			break;
@@ -1166,16 +1187,16 @@ static void do_action(int action, struct cardstate *cs,
 		/* initialize AT state structure
 		 * note that bcs may be NULL if no B channel is free
 		 */
-		at_state2->ConState = 700;
+		at_state->ConState = 700;
 		for (i = 0; i < STR_NUM; ++i) {
-			kfree(at_state2->str_var[i]);
-			at_state2->str_var[i] = NULL;
+			kfree(at_state->str_var[i]);
+			at_state->str_var[i] = NULL;
 		}
-		at_state2->int_var[VAR_ZCTP] = -1;
+		at_state->int_var[VAR_ZCTP] = -1;
 
 		spin_lock_irqsave(&cs->lock, flags);
-		at_state2->timer_expires = RING_TIMEOUT;
-		at_state2->timer_active = 1;
+		at_state->timer_expires = RING_TIMEOUT;
+		at_state->timer_active = 1;
 		spin_unlock_irqrestore(&cs->lock, flags);
 		break;
 	case ACT_ICALL:
@@ -1213,14 +1234,17 @@ static void do_action(int action, struct cardstate *cs,
 	case ACT_DISCONNECT:
 		cs->cur_at_seq = SEQ_NONE;
 		at_state->cid = -1;
-		if (bcs && cs->onechannel && cs->dle) {
+		if (!bcs) {
+			disconnect_nobc(p_at_state, cs);
+		} else if (cs->onechannel && cs->dle) {
 			/* Check for other open channels not needed:
 			 * DLE only used for M10x with one B channel.
 			 */
 			at_state->pending_commands |= PC_DLE0;
 			cs->commands_pending = 1;
-		} else
-			disconnect(p_at_state);
+		} else {
+			disconnect_bc(at_state, cs, bcs);
+		}
 		break;
 	case ACT_FAKEDLE0:
 		at_state->int_var[VAR_ZDLE] = 0;
@@ -1228,25 +1252,27 @@ static void do_action(int action, struct cardstate *cs,
 		/* fall through */
 	case ACT_DLE0:
 		cs->cur_at_seq = SEQ_NONE;
-		at_state2 = &cs->bcs[cs->curchannel].at_state;
-		disconnect(&at_state2);
+		bcs2 = cs->bcs + cs->curchannel;
+		disconnect_bc(&bcs2->at_state, cs, bcs2);
 		break;
 	case ACT_ABORTHUP:
 		cs->cur_at_seq = SEQ_NONE;
 		dev_warn(cs->dev, "Could not hang up.\n");
 		at_state->cid = -1;
-		if (bcs && cs->onechannel)
+		if (!bcs)
+			disconnect_nobc(p_at_state, cs);
+		else if (cs->onechannel)
 			at_state->pending_commands |= PC_DLE0;
 		else
-			disconnect(p_at_state);
+			disconnect_bc(at_state, cs, bcs);
 		schedule_init(cs, MS_RECOVER);
 		break;
 	case ACT_FAILDLE0:
 		cs->cur_at_seq = SEQ_NONE;
 		dev_warn(cs->dev, "Error leaving DLE mode.\n");
 		cs->dle = 0;
-		at_state2 = &cs->bcs[cs->curchannel].at_state;
-		disconnect(&at_state2);
+		bcs2 = cs->bcs + cs->curchannel;
+		disconnect_bc(&bcs2->at_state, cs, bcs2);
 		schedule_init(cs, MS_RECOVER);
 		break;
 	case ACT_FAILDLE1:
@@ -1275,14 +1301,14 @@ static void do_action(int action, struct cardstate *cs,
 		if (reinit_and_retry(cs, channel) < 0) {
 			dev_warn(cs->dev,
 				 "Could not get a call ID. Cannot dial.\n");
-			at_state2 = &cs->bcs[channel].at_state;
-			disconnect(&at_state2);
+			bcs2 = cs->bcs + channel;
+			disconnect_bc(&bcs2->at_state, cs, bcs2);
 		}
 		break;
 	case ACT_ABORTCID:
 		cs->cur_at_seq = SEQ_NONE;
-		at_state2 = &cs->bcs[cs->curchannel].at_state;
-		disconnect(&at_state2);
+		bcs2 = cs->bcs + cs->curchannel;
+		disconnect_bc(&bcs2->at_state, cs, bcs2);
 		break;
 
 	case ACT_DIALING:
@@ -1291,7 +1317,10 @@ static void do_action(int action, struct cardstate *cs,
 		break;
 
 	case ACT_ABORTACCEPT:	/* hangup/error/timeout during ICALL procssng */
-		disconnect(p_at_state);
+		if (bcs)
+			disconnect_bc(at_state, cs, bcs);
+		else
+			disconnect_nobc(p_at_state, cs);
 		break;
 
 	case ACT_ABORTDIAL:	/* error/timeout during dial preparation */
-- 
1.9.2.459.g68773ac
