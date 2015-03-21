From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/4] isdn/gigaset: restructure modem response parser (2)
Date: Sat, 21 Mar 2015 20:15:32 +0100 (CET)
Message-ID: <623b4ecde8d3521ab31b030575a8630795512ca9.1426964840.git.tilman@imap.cc>
References: <cover.1426964840.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:43445 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbbCUTuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 15:50:07 -0400
In-Reply-To: <cover.1426964840.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate literal string handling from main parser loop.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c | 126 ++++++++++++++++++----------------------
 1 file changed, 57 insertions(+), 69 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index d1b84f4..b2a1fb1 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -455,91 +455,79 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 	const struct resp_type_t *rt;
 	const struct zsau_resp_t *zr;
 	int curarg;
-	int resp_code;
-	int param_type;
 	int abort;
-	size_t len;
 	int cid, parameter;
-	int rawstring;
 
-	len = cs->cbytes;
-	if (!len) {
+	if (!cs->cbytes) {
 		/* ignore additional LFs/CRs (M10x config mode or cx100) */
 		gig_dbg(DEBUG_MCMD, "skipped EOL [%02X]", cs->respdata[0]);
 		return;
 	}
-	cs->respdata[len] = 0;
-	argv[0] = cs->respdata;
-	params = 1;
+	cs->respdata[cs->cbytes] = 0;
+
 	if (cs->at_state.getstring) {
-		/* getstring only allowed without cid at the moment */
+		/* state machine wants next line verbatim */
 		cs->at_state.getstring = 0;
-		rawstring = 1;
-		cid = 0;
-	} else {
-		/* parse line */
-		for (i = 0; i < len; i++)
-			switch (cs->respdata[i]) {
-			case ';':
-			case ',':
-			case '=':
-				if (params > MAX_REC_PARAMS) {
-					dev_warn(cs->dev,
-						 "too many parameters in response\n");
-					/* need last parameter (might be CID) */
-					params--;
-				}
-				argv[params++] = cs->respdata + i + 1;
-			}
+		ptr = kstrdup(cs->respdata, GFP_ATOMIC);
+		gig_dbg(DEBUG_EVENT, "string==%s", ptr ? ptr : "NULL");
+		add_cid_event(cs, 0, RSP_STRING, ptr, 0);
+		return;
+	}
 
-		rawstring = 0;
-		cid = params > 1 ? cid_of_response(argv[params - 1]) : 0;
-		if (cid < 0) {
-			gigaset_add_event(cs, &cs->at_state, RSP_INVAL,
-					  NULL, 0, NULL);
-			return;
+	/* parse line */
+	argv[0] = cs->respdata;
+	params = 1;
+	for (i = 0; i < cs->cbytes; i++)
+		switch (cs->respdata[i]) {
+		case ';':
+		case ',':
+		case '=':
+			if (params > MAX_REC_PARAMS) {
+				dev_warn(cs->dev,
+					 "too many parameters in response\n");
+				/* need last parameter (might be CID) */
+				params--;
+			}
+			argv[params++] = cs->respdata + i + 1;
 		}
 
-		for (j = 1; j < params; ++j)
-			argv[j][-1] = 0;
+	cid = params > 1 ? cid_of_response(argv[params - 1]) : 0;
+	if (cid < 0) {
+		gigaset_add_event(cs, &cs->at_state, RSP_INVAL, NULL, 0, NULL);
+		return;
+	}
+
+	for (j = 1; j < params; ++j)
+		argv[j][-1] = 0;
 
-		gig_dbg(DEBUG_EVENT, "CMD received: %s", argv[0]);
-		if (cid) {
-			--params;
-			gig_dbg(DEBUG_EVENT, "CID: %s", argv[params]);
-		}
-		gig_dbg(DEBUG_EVENT, "available params: %d", params - 1);
-		for (j = 1; j < params; j++)
-			gig_dbg(DEBUG_EVENT, "param %d: %s", j, argv[j]);
+	gig_dbg(DEBUG_EVENT, "CMD received: %s", argv[0]);
+	if (cid) {
+		--params;
+		gig_dbg(DEBUG_EVENT, "CID: %s", argv[params]);
 	}
+	gig_dbg(DEBUG_EVENT, "available params: %d", params - 1);
+	for (j = 1; j < params; j++)
+		gig_dbg(DEBUG_EVENT, "param %d: %s", j, argv[j]);
 
 	abort = 1;
 	curarg = 0;
 	while (curarg < params) {
-		if (rawstring) {
-			resp_code = RSP_STRING;
-			param_type = RT_STRING;
-		} else {
-			for (rt = resp_type; rt->response; ++rt)
-				if (!strcmp(argv[curarg], rt->response))
-					break;
-
-			if (!rt->response) {
-				add_cid_event(cs, 0, RSP_NONE, NULL, 0);
-				gig_dbg(DEBUG_EVENT,
-					"unknown modem response: '%s'\n",
-					argv[curarg]);
+		for (rt = resp_type; rt->response; ++rt)
+			if (!strcmp(argv[curarg], rt->response))
 				break;
-			}
 
-			resp_code = rt->resp_code;
-			param_type = rt->type;
-			++curarg;
+		if (!rt->response) {
+			add_cid_event(cs, 0, RSP_NONE, NULL, 0);
+			gig_dbg(DEBUG_EVENT, "unknown modem response: '%s'\n",
+				argv[curarg]);
+			break;
 		}
 
-		switch (param_type) {
+		++curarg;
+
+		switch (rt->type) {
 		case RT_NOTHING:
-			add_cid_event(cs, cid, resp_code, NULL, 0);
+			add_cid_event(cs, cid, rt->resp_code, NULL, 0);
 			break;
 		case RT_RING:
 			if (!cid) {
@@ -548,13 +536,13 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				add_cid_event(cs, 0, RSP_INVAL, NULL, 0);
 				abort = 1;
 			} else {
-				add_cid_event(cs, 0, resp_code, NULL, cid);
+				add_cid_event(cs, 0, rt->resp_code, NULL, cid);
 				abort = 0;
 			}
 			break;
 		case RT_ZSAU:
 			if (curarg >= params) {
-				add_cid_event(cs, cid, resp_code, NULL,
+				add_cid_event(cs, cid, rt->resp_code, NULL,
 					      ZSAU_NONE);
 				break;
 			}
@@ -565,7 +553,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				dev_warn(cs->dev,
 					 "%s: unknown parameter %s after ZSAU\n",
 					 __func__, argv[curarg]);
-			add_cid_event(cs, cid, resp_code, NULL, zr->code);
+			add_cid_event(cs, cid, rt->resp_code, NULL, zr->code);
 			++curarg;
 			break;
 		case RT_STRING:
@@ -578,7 +566,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				ptr = NULL;
 			}
 			gig_dbg(DEBUG_EVENT, "string==%s", ptr ? ptr : "NULL");
-			add_cid_event(cs, cid, resp_code, ptr, 0);
+			add_cid_event(cs, cid, rt->resp_code, ptr, 0);
 			break;
 		case RT_ZCAU:
 			parameter = -1;
@@ -591,15 +579,15 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 					parameter = (type << 8) | value;
 			} else
 				curarg = params - 1;
-			add_cid_event(cs, cid, resp_code, NULL, parameter);
+			add_cid_event(cs, cid, rt->resp_code, NULL, parameter);
 			break;
 		case RT_NUMBER:
 			if (curarg >= params ||
 			    kstrtoint(argv[curarg++], 10, &parameter))
 				parameter = -1;
 			gig_dbg(DEBUG_EVENT, "parameter==%d", parameter);
-			add_cid_event(cs, cid, resp_code, NULL, parameter);
-			if (resp_code == RSP_ZDLE)
+			add_cid_event(cs, cid, rt->resp_code, NULL, parameter);
+			if (rt->resp_code == RSP_ZDLE)
 				cs->dle = parameter;
 			break;
 		}
-- 
1.9.2.459.g68773ac
