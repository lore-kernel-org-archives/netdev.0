From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/6] isdn/gigaset: beautify ev-layer.c
Date: Mon, 21 Jan 2013 22:57:21 +0100 (CET)
Message-ID: <20130121-patch-isdn-05.tilman@imap.cc>
References: <20130121-patch-isdn-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130121-patch-isdn-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cosmetic changes to drivers/isdn/gigaset/ev-layer.c and
drivers/isdn/gigaset/gigaset.h to improve readability.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c |  119 +++++++++++++++++++--------------------
 drivers/isdn/gigaset/gigaset.h  |    9 ++-
 2 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index e2383ec..7459b12 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -351,10 +351,11 @@ struct reply_t gigaset_tab_cid[] =
 
 
 static const struct resp_type_t {
-	unsigned char	*response;
-	int		resp_code;
-	int		type;
-} resp_type[] =
+	char	*response;
+	int	resp_code;
+	int	type;
+}
+resp_type[] =
 {
 	{"OK",		RSP_OK,		RT_NOTHING},
 	{"ERROR",	RSP_ERROR,	RT_NOTHING},
@@ -374,11 +375,12 @@ static const struct resp_type_t {
 };
 
 static const struct zsau_resp_t {
-	unsigned char	*str;
-	int		code;
-} zsau_resp[] =
+	char	*str;
+	int	code;
+}
+zsau_resp[] =
 {
-	{"OUTGOING_CALL_PROCEEDING",	ZSAU_OUTGOING_CALL_PROCEEDING},
+	{"OUTGOING_CALL_PROCEEDING",	ZSAU_PROCEEDING},
 	{"CALL_DELIVERED",		ZSAU_CALL_DELIVERED},
 	{"ACTIVE",			ZSAU_ACTIVE},
 	{"DISCONNECT_IND",		ZSAU_DISCONNECT_IND},
@@ -434,7 +436,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 	len = cs->cbytes;
 	if (!len) {
 		/* ignore additional LFs/CRs (M10x config mode or cx100) */
-		gig_dbg(DEBUG_MCMD, "skipped EOL [%02X]", cs->respdata[len]);
+		gig_dbg(DEBUG_MCMD, "skipped EOL [%02X]", cs->respdata[0]);
 		return;
 	}
 	cs->respdata[len] = 0;
@@ -707,27 +709,29 @@ static void schedule_init(struct cardstate *cs, int state)
 	cs->commands_pending = 1;
 }
 
-/* Add "AT" to a command, add the cid, dle encode it, send the result to the
-   hardware. */
-static void send_command(struct cardstate *cs, const char *cmd, int cid,
-			 int dle, gfp_t kmallocflags)
+/* send an AT command
+ * adding the "AT" prefix, cid and DLE encapsulation as appropriate
+ */
+static void send_command(struct cardstate *cs, const char *cmd,
+			 struct at_state_t *at_state)
 {
+	int cid = at_state->cid;
 	struct cmdbuf_t *cb;
 	size_t buflen;
 
 	buflen = strlen(cmd) + 12; /* DLE ( A T 1 2 3 4 5 <cmd> DLE ) \0 */
-	cb = kmalloc(sizeof(struct cmdbuf_t) + buflen, kmallocflags);
+	cb = kmalloc(sizeof(struct cmdbuf_t) + buflen, GFP_ATOMIC);
 	if (!cb) {
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
 	if (cid > 0 && cid <= 65535)
 		cb->len = snprintf(cb->buf, buflen,
-				   dle ? "\020(AT%d%s\020)" : "AT%d%s",
+				   cs->dle ? "\020(AT%d%s\020)" : "AT%d%s",
 				   cid, cmd);
 	else
 		cb->len = snprintf(cb->buf, buflen,
-				   dle ? "\020(AT%s\020)" : "AT%s",
+				   cs->dle ? "\020(AT%s\020)" : "AT%s",
 				   cmd);
 	cb->offset = 0;
 	cb->next = NULL;
@@ -886,7 +890,7 @@ static void finish_shutdown(struct cardstate *cs)
 		gigaset_isdn_stop(cs);
 	}
 
-	/* The rest is done by cleanup_cs () in user mode. */
+	/* The rest is done by cleanup_cs() in process context. */
 
 	cs->cmd_result = -ENODEV;
 	cs->waiting = 0;
@@ -976,10 +980,9 @@ exit:
 }
 
 static void handle_icall(struct cardstate *cs, struct bc_state *bcs,
-			 struct at_state_t **p_at_state)
+			 struct at_state_t *at_state)
 {
 	int retval;
-	struct at_state_t *at_state = *p_at_state;
 
 	retval = gigaset_isdn_icall(at_state);
 	switch (retval) {
@@ -1176,7 +1179,7 @@ static void do_action(int action, struct cardstate *cs,
 		spin_unlock_irqrestore(&cs->lock, flags);
 		break;
 	case ACT_ICALL:
-		handle_icall(cs, bcs, p_at_state);
+		handle_icall(cs, bcs, at_state);
 		break;
 	case ACT_FAILSDOWN:
 		dev_warn(cs->dev, "Could not shut down the device.\n");
@@ -1264,7 +1267,7 @@ static void do_action(int action, struct cardstate *cs,
 			cs->commands_pending = 1;
 			break;
 		}
-		/* fall through */
+		/* bad cid: fall through */
 	case ACT_FAILCID:
 		cs->cur_at_seq = SEQ_NONE;
 		channel = cs->curchannel;
@@ -1339,7 +1342,6 @@ static void do_action(int action, struct cardstate *cs,
 			*p_resp_code = RSP_ERROR;
 			break;
 		}
-		/*at_state->getstring = 1;*/
 		cs->gotfwver = 0;
 		break;
 	case ACT_GOTVER:
@@ -1471,7 +1473,6 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 	int rcode;
 	int genresp = 0;
 	int resp_code = RSP_ERROR;
-	int sendcid;
 	struct at_state_t *at_state;
 	int index;
 	int curact;
@@ -1499,7 +1500,6 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 		at_state->ConState, ev->type);
 
 	bcs = at_state->bcs;
-	sendcid = at_state->cid;
 
 	/* Setting the pointer to the dial array */
 	rep = at_state->replystruct;
@@ -1510,10 +1510,12 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 		    || !at_state->timer_active) {
 			ev->type = RSP_NONE; /* old timeout */
 			gig_dbg(DEBUG_EVENT, "old timeout");
-		} else if (!at_state->waiting)
-			gig_dbg(DEBUG_EVENT, "timeout occurred");
-		else
-			gig_dbg(DEBUG_EVENT, "stopped waiting");
+		} else {
+			if (at_state->waiting)
+				gig_dbg(DEBUG_EVENT, "stopped waiting");
+			else
+				gig_dbg(DEBUG_EVENT, "timeout occurred");
+		}
 	}
 	spin_unlock_irqrestore(&cs->lock, flags);
 
@@ -1561,45 +1563,40 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 		do_action(rep->action[curact], cs, bcs, &at_state, &p_command,
 			  &genresp, &resp_code, ev);
 		if (!at_state)
-			break; /* may be freed after disconnect */
+			/* at_state destroyed by disconnect */
+			return;
 	}
 
-	if (at_state) {
-		/* Jump to the next con-state regarding the array */
-		if (rep->new_ConState >= 0)
-			at_state->ConState = rep->new_ConState;
+	/* Jump to the next con-state regarding the array */
+	if (rep->new_ConState >= 0)
+		at_state->ConState = rep->new_ConState;
 
-		if (genresp) {
-			spin_lock_irqsave(&cs->lock, flags);
+	if (genresp) {
+		spin_lock_irqsave(&cs->lock, flags);
+		at_state->timer_expires = 0;
+		at_state->timer_active = 0;
+		spin_unlock_irqrestore(&cs->lock, flags);
+		gigaset_add_event(cs, at_state, resp_code, NULL, 0, NULL);
+	} else {
+		/* Send command to modem if not NULL... */
+		if (p_command) {
+			if (cs->connected)
+				send_command(cs, p_command, at_state);
+			else
+				gigaset_add_event(cs, at_state, RSP_NODEV,
+						  NULL, 0, NULL);
+		}
+
+		spin_lock_irqsave(&cs->lock, flags);
+		if (!rep->timeout) {
 			at_state->timer_expires = 0;
 			at_state->timer_active = 0;
-			spin_unlock_irqrestore(&cs->lock, flags);
-			gigaset_add_event(cs, at_state, resp_code,
-					  NULL, 0, NULL);
-		} else {
-			/* Send command to modem if not NULL... */
-			if (p_command) {
-				if (cs->connected)
-					send_command(cs, p_command,
-						     sendcid, cs->dle,
-						     GFP_ATOMIC);
-				else
-					gigaset_add_event(cs, at_state,
-							  RSP_NODEV,
-							  NULL, 0, NULL);
-			}
-
-			spin_lock_irqsave(&cs->lock, flags);
-			if (!rep->timeout) {
-				at_state->timer_expires = 0;
-				at_state->timer_active = 0;
-			} else if (rep->timeout > 0) { /* new timeout */
-				at_state->timer_expires = rep->timeout * 10;
-				at_state->timer_active = 1;
-				++at_state->timer_index;
-			}
-			spin_unlock_irqrestore(&cs->lock, flags);
+		} else if (rep->timeout > 0) { /* new timeout */
+			at_state->timer_expires = rep->timeout * 10;
+			at_state->timer_active = 1;
+			++at_state->timer_index;
 		}
+		spin_unlock_irqrestore(&cs->lock, flags);
 	}
 }
 
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 8e2fc8f..eb63a0f 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -111,11 +111,10 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 
 /* connection state */
 #define ZSAU_NONE			0
-#define ZSAU_DISCONNECT_IND		4
-#define ZSAU_OUTGOING_CALL_PROCEEDING	1
 #define ZSAU_PROCEEDING			1
 #define ZSAU_CALL_DELIVERED		2
 #define ZSAU_ACTIVE			3
+#define ZSAU_DISCONNECT_IND		4
 #define ZSAU_NULL			5
 #define ZSAU_DISCONNECT_REQ		6
 #define ZSAU_UNKNOWN			-1
@@ -183,18 +182,22 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define AT_NUM		7
 
 /* variables in struct at_state_t */
+/* - numeric */
 #define VAR_ZSAU	0
 #define VAR_ZDLE	1
 #define VAR_ZCTP	2
+/* total number */
 #define VAR_NUM		3
-
+/* - string */
 #define STR_NMBR	0
 #define STR_ZCPN	1
 #define STR_ZCON	2
 #define STR_ZBC		3
 #define STR_ZHLC	4
+/* total number */
 #define STR_NUM		5
 
+/* event types */
 #define EV_TIMEOUT	-105
 #define EV_IF_VER	-106
 #define EV_PROC_CIDMODE	-107
-- 
1.7.3.4
