From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/4] isdn/gigaset: restructure modem response parser (4)
Date: Sat, 21 Mar 2015 20:15:32 +0100 (CET)
Message-ID: <7396c4e94b83d81a0bc9c3dc86bf804393f42d39.1426964840.git.tilman@imap.cc>
References: <cover.1426964840.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:43445 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720AbbCUTuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 15:50:13 -0400
In-Reply-To: <cover.1426964840.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restructure the control structure of the modem response parser
to improve readability and error handling.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c | 258 +++++++++++++++++++++++-----------------
 1 file changed, 151 insertions(+), 107 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index dc6e6a3..1cfcea6 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -389,6 +389,20 @@ zsau_resp[] =
 	{NULL,				ZSAU_UNKNOWN}
 };
 
+/* check for and remove fixed string prefix
+ * If s starts with prefix terminated by a non-alphanumeric character,
+ * return pointer to the first character after that, otherwise return NULL.
+ */
+static char *skip_prefix(char *s, const char *prefix)
+{
+	while (*prefix)
+		if (*s++ != *prefix++)
+			return NULL;
+	if (isalnum(*s))
+		return NULL;
+	return s;
+}
+
 /* queue event with CID */
 static void add_cid_event(struct cardstate *cs, int cid, int type,
 			  void *ptr, int parameter)
@@ -430,15 +444,11 @@ static void add_cid_event(struct cardstate *cs, int cid, int type,
  */
 void gigaset_handle_modem_response(struct cardstate *cs)
 {
-	unsigned char *argv[MAX_REC_PARAMS + 1];
-	int params;
-	int i, j;
-	char *psep, *ptr;
+	char *eoc, *psep, *ptr;
 	const struct resp_type_t *rt;
 	const struct zsau_resp_t *zr;
-	int curarg;
-	int abort;
 	int cid, parameter;
+	u8 type, value;
 
 	if (!cs->cbytes) {
 		/* ignore additional LFs/CRs (M10x config mode or cx100) */
@@ -456,6 +466,19 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		return;
 	}
 
+	/* look up response type */
+	for (rt = resp_type; rt->response; ++rt) {
+		eoc = skip_prefix(cs->respdata, rt->response);
+		if (eoc)
+			break;
+	}
+	if (!rt->response) {
+		add_cid_event(cs, 0, RSP_NONE, NULL, 0);
+		gig_dbg(DEBUG_EVENT, "unknown modem response: '%s'\n",
+			cs->respdata);
+		return;
+	}
+
 	/* check for CID */
 	psep = strrchr(cs->respdata, ';');
 	if (psep &&
@@ -468,120 +491,141 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		cid = 0;
 	}
 
-	/* parse line */
-	argv[0] = cs->respdata;
-	params = 1;
-	for (i = 0; i < cs->cbytes; i++)
-		switch (cs->respdata[i]) {
-		case ';':
-		case ',':
-		case '=':
-			cs->respdata[i] = 0;
-			if (params > MAX_REC_PARAMS)
-				dev_warn(cs->dev,
-					 "too many parameters in response\n");
-			else
-				argv[params++] = cs->respdata + i + 1;
-		}
-
-	gig_dbg(DEBUG_EVENT, "CMD received: %s", argv[0]);
+	gig_dbg(DEBUG_EVENT, "CMD received: %s", cs->respdata);
 	if (cid)
 		gig_dbg(DEBUG_EVENT, "CID: %d", cid);
-	gig_dbg(DEBUG_EVENT, "available params: %d", params - 1);
-	for (j = 1; j < params; j++)
-		gig_dbg(DEBUG_EVENT, "param %d: %s", j, argv[j]);
-
-	abort = 1;
-	curarg = 0;
-	while (curarg < params) {
-		for (rt = resp_type; rt->response; ++rt)
-			if (!strcmp(argv[curarg], rt->response))
-				break;
 
-		if (!rt->response) {
-			add_cid_event(cs, 0, RSP_NONE, NULL, 0);
-			gig_dbg(DEBUG_EVENT, "unknown modem response: '%s'\n",
-				argv[curarg]);
-			break;
-		}
+	switch (rt->type) {
+	case RT_NOTHING:
+		/* check parameter separator */
+		if (*eoc)
+			goto bad_param;	/* extra parameter */
 
-		++curarg;
+		add_cid_event(cs, cid, rt->resp_code, NULL, 0);
+		break;
 
-		switch (rt->type) {
-		case RT_NOTHING:
-			add_cid_event(cs, cid, rt->resp_code, NULL, 0);
-			break;
-		case RT_RING:
-			if (!cid) {
-				dev_err(cs->dev,
-					"received RING without CID!\n");
-				add_cid_event(cs, 0, RSP_INVAL, NULL, 0);
-				abort = 1;
-			} else {
-				add_cid_event(cs, 0, rt->resp_code, NULL, cid);
-				abort = 0;
-			}
-			break;
-		case RT_ZSAU:
-			if (curarg >= params) {
-				add_cid_event(cs, cid, rt->resp_code, NULL,
-					      ZSAU_NONE);
-				break;
-			}
-			for (zr = zsau_resp; zr->str; ++zr)
-				if (!strcmp(argv[curarg], zr->str))
+	case RT_RING:
+		/* check parameter separator */
+		if (!*eoc)
+			eoc = NULL;	/* no parameter */
+		else if (*eoc++ != ',')
+			goto bad_param;
+
+		add_cid_event(cs, 0, rt->resp_code, NULL, cid);
+
+		/* process parameters as individual responses */
+		while (eoc) {
+			/* look up parameter type */
+			psep = NULL;
+			for (rt = resp_type; rt->response; ++rt) {
+				psep = skip_prefix(eoc, rt->response);
+				if (psep)
 					break;
-			if (!zr->str)
+			}
+
+			/* all legal parameters are of type RT_STRING */
+			if (!psep || rt->type != RT_STRING) {
 				dev_warn(cs->dev,
-					 "%s: unknown parameter %s after ZSAU\n",
-					 __func__, argv[curarg]);
-			add_cid_event(cs, cid, rt->resp_code, NULL, zr->code);
-			++curarg;
-			break;
-		case RT_STRING:
-			if (curarg < params) {
-				ptr = kstrdup(argv[curarg], GFP_ATOMIC);
-				if (!ptr)
-					dev_err(cs->dev, "out of memory\n");
-				++curarg;
-			} else {
-				ptr = NULL;
+					 "illegal RING parameter: '%s'\n",
+					 eoc);
+				return;
 			}
-			gig_dbg(DEBUG_EVENT, "string==%s", ptr ? ptr : "NULL");
+
+			/* skip parameter value separator */
+			if (*psep++ != '=')
+				goto bad_param;
+
+			/* look up end of parameter */
+			eoc = strchr(psep, ',');
+			if (eoc)
+				*eoc++ = 0;
+
+			/* retrieve parameter value */
+			ptr = kstrdup(psep, GFP_ATOMIC);
+
+			/* queue event */
 			add_cid_event(cs, cid, rt->resp_code, ptr, 0);
-			break;
-		case RT_ZCAU:
-			parameter = -1;
-			if (curarg + 1 < params) {
-				u8 type, value;
-
-				i = kstrtou8(argv[curarg++], 16, &type);
-				j = kstrtou8(argv[curarg++], 16, &value);
-				if (i == 0 && j == 0)
-					parameter = (type << 8) | value;
-			} else
-				curarg = params - 1;
-			add_cid_event(cs, cid, rt->resp_code, NULL, parameter);
-			break;
-		case RT_NUMBER:
-			if (curarg >= params ||
-			    kstrtoint(argv[curarg++], 10, &parameter))
-				parameter = -1;
-			gig_dbg(DEBUG_EVENT, "parameter==%d", parameter);
-			add_cid_event(cs, cid, rt->resp_code, NULL, parameter);
-			if (rt->resp_code == RSP_ZDLE)
-				cs->dle = parameter;
-			break;
 		}
+		break;
 
-		if (abort)
+	case RT_ZSAU:
+		/* check parameter separator */
+		if (!*eoc) {
+			/* no parameter */
+			add_cid_event(cs, cid, rt->resp_code, NULL, ZSAU_NONE);
 			break;
-	}
+		}
+		if (*eoc++ != '=')
+			goto bad_param;
 
-	if (curarg != params)
-		gig_dbg(DEBUG_EVENT,
-			"invalid number of processed parameters: %d/%d",
-			curarg, params);
+		/* look up parameter value */
+		for (zr = zsau_resp; zr->str; ++zr)
+			if (!strcmp(eoc, zr->str))
+				break;
+		if (!zr->str)
+			goto bad_param;
+
+		add_cid_event(cs, cid, rt->resp_code, NULL, zr->code);
+		break;
+
+	case RT_STRING:
+		/* check parameter separator */
+		if (*eoc++ != '=')
+			goto bad_param;
+
+		/* retrieve parameter value */
+		ptr = kstrdup(eoc, GFP_ATOMIC);
+
+		/* queue event */
+		add_cid_event(cs, cid, rt->resp_code, ptr, 0);
+		break;
+
+	case RT_ZCAU:
+		/* check parameter separators */
+		if (*eoc++ != '=')
+			goto bad_param;
+		psep = strchr(eoc, ',');
+		if (!psep)
+			goto bad_param;
+		*psep++ = 0;
+
+		/* decode parameter values */
+		if (kstrtou8(eoc, 16, &type) || kstrtou8(psep, 16, &value)) {
+			*--psep = ',';
+			goto bad_param;
+		}
+		parameter = (type << 8) | value;
+
+		add_cid_event(cs, cid, rt->resp_code, NULL, parameter);
+		break;
+
+	case RT_NUMBER:
+		/* check parameter separator */
+		if (*eoc++ != '=')
+			goto bad_param;
+
+		/* decode parameter value */
+		if (kstrtoint(eoc, 10, &parameter))
+			goto bad_param;
+
+		/* special case ZDLE: set flag before queueing event */
+		if (rt->resp_code == RSP_ZDLE)
+			cs->dle = parameter;
+
+		add_cid_event(cs, cid, rt->resp_code, NULL, parameter);
+		break;
+
+bad_param:
+		/* parameter unexpected, incomplete or malformed */
+		dev_warn(cs->dev, "bad parameter in response '%s'\n",
+			 cs->respdata);
+		add_cid_event(cs, cid, rt->resp_code, NULL, -1);
+		break;
+
+	default:
+		dev_err(cs->dev, "%s: internal error on '%s'\n",
+			__func__, cs->respdata);
+	}
 }
 EXPORT_SYMBOL_GPL(gigaset_handle_modem_response);
 
-- 
1.9.2.459.g68773ac
