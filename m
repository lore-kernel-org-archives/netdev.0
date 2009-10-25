From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 9/9] gigaset: convert strcmp chain to table lookup
Date: Sun, 25 Oct 2009 20:30:57 +0100 (CET)
Message-ID: <20091023-patch-gigaset-09.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:43602 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134AbZJYTbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2009 15:31:03 -0400
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the sequence of strcmp calls for interpreting ZSAU parameter
strings by a table of known strings and lookup loop to improve
readability.

Impact: readability improvement, no functional change
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c |   42 +++++++++++++++++++++++---------------
 drivers/isdn/gigaset/gigaset.h  |    6 -----
 2 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index a9a3975..ddeb045 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -374,7 +374,11 @@ struct reply_t gigaset_tab_cid[] =
 };
 
 
-static const struct resp_type_t resp_type[] =
+static const struct resp_type_t {
+	unsigned char	*response;
+	int		resp_code;
+	int		type;
+} resp_type[] =
 {
 	{"OK",		RSP_OK,		RT_NOTHING},
 	{"ERROR",	RSP_ERROR,	RT_NOTHING},
@@ -402,6 +406,20 @@ static const struct resp_type_t resp_type[] =
 	{NULL,		0,		0}
 };
 
+static const struct zsau_resp_t {
+	unsigned char	*str;
+	int		code;
+} zsau_resp[] =
+{
+	{"OUTGOING_CALL_PROCEEDING",	ZSAU_OUTGOING_CALL_PROCEEDING},
+	{"CALL_DELIVERED",		ZSAU_CALL_DELIVERED},
+	{"ACTIVE",			ZSAU_ACTIVE},
+	{"DISCONNECT_IND",		ZSAU_DISCONNECT_IND},
+	{"NULL",			ZSAU_NULL},
+	{"DISCONNECT_REQ",		ZSAU_DISCONNECT_REQ},
+	{NULL,				ZSAU_UNKNOWN}
+};
+
 /*
  * Get integer from char-pointer
  */
@@ -480,6 +498,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 	int params;
 	int i, j;
 	const struct resp_type_t *rt;
+	const struct zsau_resp_t *zr;
 	int curarg;
 	unsigned long flags;
 	unsigned next, tail, head;
@@ -606,25 +625,14 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				event->parameter = ZSAU_NONE;
 				break;
 			}
-			if (!strcmp(argv[curarg], "OUTGOING_CALL_PROCEEDING"))
-				event->parameter =
-					ZSAU_OUTGOING_CALL_PROCEEDING;
-			else if (!strcmp(argv[curarg], "CALL_DELIVERED"))
-				event->parameter = ZSAU_CALL_DELIVERED;
-			else if (!strcmp(argv[curarg], "ACTIVE"))
-				event->parameter = ZSAU_ACTIVE;
-			else if (!strcmp(argv[curarg], "DISCONNECT_IND"))
-				event->parameter = ZSAU_DISCONNECT_IND;
-			else if (!strcmp(argv[curarg], "NULL"))
-				event->parameter = ZSAU_NULL;
-			else if (!strcmp(argv[curarg], "DISCONNECT_REQ"))
-				event->parameter = ZSAU_DISCONNECT_REQ;
-			else {
-				event->parameter = ZSAU_UNKNOWN;
+			for (zr = zsau_resp; zr->str; ++zr)
+				if (!strcmp(argv[curarg], zr->str))
+					break;
+			event->parameter = zr->code;
+			if (!zr->str)
 				dev_warn(cs->dev,
 					"%s: unknown parameter %s after ZSAU\n",
 					 __func__, argv[curarg]);
-			}
 			++curarg;
 			break;
 		case RT_STRING:
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 3c74cd1..e963a6c 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -357,12 +357,6 @@ struct at_state_t {
 	struct bc_state		*bcs;
 };
 
-struct resp_type_t {
-	unsigned char	*response;
-	int		resp_code;	/* RSP_XXXX */
-	int		type;		/* RT_XXXX */
-};
-
 struct event_t {
 	int type;
 	void *ptr, *arg;
-- 
1.6.2.1.214.ge986c

