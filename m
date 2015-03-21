From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/4] isdn/gigaset: restructure modem response parser (1)
Date: Sat, 21 Mar 2015 20:15:32 +0100 (CET)
Message-ID: <f5f3b5dbd48039cd632d1c78e58d6bbb84d5affc.1426964840.git.tilman@imap.cc>
References: <cover.1426964840.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:43445 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbbCUTuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 15:50:04 -0400
In-Reply-To: <cover.1426964840.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out queueing of modem response events into helper function
add_cid_event().

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c | 99 +++++++++++++++++++++++------------------
 1 file changed, 55 insertions(+), 44 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index c8ced12..d1b84f4 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -407,6 +407,37 @@ static int cid_of_response(char *s)
 	return cid;
 }
 
+/* queue event with CID */
+static void add_cid_event(struct cardstate *cs, int cid, int type,
+			  void *ptr, int parameter)
+{
+	unsigned long flags;
+	unsigned next, tail;
+	struct event_t *event;
+
+	gig_dbg(DEBUG_EVENT, "queueing event %d for cid %d", type, cid);
+
+	spin_lock_irqsave(&cs->ev_lock, flags);
+
+	tail = cs->ev_tail;
+	next = (tail + 1) % MAX_EVENTS;
+	if (unlikely(next == cs->ev_head)) {
+		dev_err(cs->dev, "event queue full\n");
+		kfree(ptr);
+	} else {
+		event = cs->events + tail;
+		event->type = type;
+		event->cid = cid;
+		event->ptr = ptr;
+		event->arg = NULL;
+		event->parameter = parameter;
+		event->at_state = NULL;
+		cs->ev_tail = next;
+	}
+
+	spin_unlock_irqrestore(&cs->ev_lock, flags);
+}
+
 /**
  * gigaset_handle_modem_response() - process received modem response
  * @cs:		device descriptor structure.
@@ -420,17 +451,15 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 	unsigned char *argv[MAX_REC_PARAMS + 1];
 	int params;
 	int i, j;
+	char *ptr;
 	const struct resp_type_t *rt;
 	const struct zsau_resp_t *zr;
 	int curarg;
-	unsigned long flags;
-	unsigned next, tail, head;
-	struct event_t *event;
 	int resp_code;
 	int param_type;
 	int abort;
 	size_t len;
-	int cid;
+	int cid, parameter;
 	int rawstring;
 
 	len = cs->cbytes;
@@ -484,26 +513,9 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 			gig_dbg(DEBUG_EVENT, "param %d: %s", j, argv[j]);
 	}
 
-	spin_lock_irqsave(&cs->ev_lock, flags);
-	head = cs->ev_head;
-	tail = cs->ev_tail;
-
 	abort = 1;
 	curarg = 0;
 	while (curarg < params) {
-		next = (tail + 1) % MAX_EVENTS;
-		if (unlikely(next == head)) {
-			dev_err(cs->dev, "event queue full\n");
-			break;
-		}
-
-		event = cs->events + tail;
-		event->at_state = NULL;
-		event->cid = cid;
-		event->ptr = NULL;
-		event->arg = NULL;
-		tail = next;
-
 		if (rawstring) {
 			resp_code = RSP_STRING;
 			param_type = RT_STRING;
@@ -513,7 +525,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 					break;
 
 			if (!rt->response) {
-				event->type = RSP_NONE;
+				add_cid_event(cs, 0, RSP_NONE, NULL, 0);
 				gig_dbg(DEBUG_EVENT,
 					"unknown modem response: '%s'\n",
 					argv[curarg]);
@@ -525,78 +537,77 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 			++curarg;
 		}
 
-		event->type = resp_code;
-
 		switch (param_type) {
 		case RT_NOTHING:
+			add_cid_event(cs, cid, resp_code, NULL, 0);
 			break;
 		case RT_RING:
 			if (!cid) {
 				dev_err(cs->dev,
 					"received RING without CID!\n");
-				event->type = RSP_INVAL;
+				add_cid_event(cs, 0, RSP_INVAL, NULL, 0);
 				abort = 1;
 			} else {
-				event->cid = 0;
-				event->parameter = cid;
+				add_cid_event(cs, 0, resp_code, NULL, cid);
 				abort = 0;
 			}
 			break;
 		case RT_ZSAU:
 			if (curarg >= params) {
-				event->parameter = ZSAU_NONE;
+				add_cid_event(cs, cid, resp_code, NULL,
+					      ZSAU_NONE);
 				break;
 			}
 			for (zr = zsau_resp; zr->str; ++zr)
 				if (!strcmp(argv[curarg], zr->str))
 					break;
-			event->parameter = zr->code;
 			if (!zr->str)
 				dev_warn(cs->dev,
 					 "%s: unknown parameter %s after ZSAU\n",
 					 __func__, argv[curarg]);
+			add_cid_event(cs, cid, resp_code, NULL, zr->code);
 			++curarg;
 			break;
 		case RT_STRING:
 			if (curarg < params) {
-				event->ptr = kstrdup(argv[curarg], GFP_ATOMIC);
-				if (!event->ptr)
+				ptr = kstrdup(argv[curarg], GFP_ATOMIC);
+				if (!ptr)
 					dev_err(cs->dev, "out of memory\n");
 				++curarg;
+			} else {
+				ptr = NULL;
 			}
-			gig_dbg(DEBUG_EVENT, "string==%s",
-				event->ptr ? (char *) event->ptr : "NULL");
+			gig_dbg(DEBUG_EVENT, "string==%s", ptr ? ptr : "NULL");
+			add_cid_event(cs, cid, resp_code, ptr, 0);
 			break;
 		case RT_ZCAU:
-			event->parameter = -1;
+			parameter = -1;
 			if (curarg + 1 < params) {
 				u8 type, value;
 
 				i = kstrtou8(argv[curarg++], 16, &type);
 				j = kstrtou8(argv[curarg++], 16, &value);
 				if (i == 0 && j == 0)
-					event->parameter = (type << 8) | value;
+					parameter = (type << 8) | value;
 			} else
 				curarg = params - 1;
+			add_cid_event(cs, cid, resp_code, NULL, parameter);
 			break;
 		case RT_NUMBER:
 			if (curarg >= params ||
-			    kstrtoint(argv[curarg++], 10, &event->parameter))
-				event->parameter = -1;
-			gig_dbg(DEBUG_EVENT, "parameter==%d", event->parameter);
+			    kstrtoint(argv[curarg++], 10, &parameter))
+				parameter = -1;
+			gig_dbg(DEBUG_EVENT, "parameter==%d", parameter);
+			add_cid_event(cs, cid, resp_code, NULL, parameter);
+			if (resp_code == RSP_ZDLE)
+				cs->dle = parameter;
 			break;
 		}
 
-		if (resp_code == RSP_ZDLE)
-			cs->dle = event->parameter;
-
 		if (abort)
 			break;
 	}
 
-	cs->ev_tail = tail;
-	spin_unlock_irqrestore(&cs->ev_lock, flags);
-
 	if (curarg != params)
 		gig_dbg(DEBUG_EVENT,
 			"invalid number of processed parameters: %d/%d",
-- 
1.9.2.459.g68773ac
