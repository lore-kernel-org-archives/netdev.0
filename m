From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 03/11] isdn/gigaset: ignore irrelevant device responses
Date: Tue,  6 Jul 2010 02:18:48 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-03.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Downgrade the Gigaset driver's reaction to unknown AT responses from
the device from warning to debug level, and remove the handling of
some device responses which aren't relevant for the driver's
operation.

Impact: cleanup
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c |   67 ++++++++------------------------------
 drivers/isdn/gigaset/gigaset.h  |    5 +--
 2 files changed, 16 insertions(+), 56 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 0d5984a..657757b 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -35,53 +35,40 @@
 #define RT_RING		2
 #define RT_NUMBER	3
 #define RT_STRING	4
-#define RT_HEX		5
 #define RT_ZCAU		6
 
 /* Possible ASCII responses */
 #define RSP_OK		0
-#define RSP_BUSY	1
-#define RSP_CONNECT	2
+#define RSP_ERROR	1
 #define RSP_ZGCI	3
 #define RSP_RING	4
-#define RSP_ZAOC	5
-#define RSP_ZCSTR	6
-#define RSP_ZCFGT	7
-#define RSP_ZCFG	8
-#define RSP_ZCCR	9
-#define RSP_EMPTY	10
-#define RSP_ZLOG	11
-#define RSP_ZCAU	12
-#define RSP_ZMWI	13
-#define RSP_ZABINFO	14
-#define RSP_ZSMLSTCHG	15
+#define RSP_ZVLS	5
+#define RSP_ZCAU	6
+
+/* responses with values to store in at_state */
+/* - numeric */
 #define RSP_VAR		100
 #define RSP_ZSAU	(RSP_VAR + VAR_ZSAU)
 #define RSP_ZDLE	(RSP_VAR + VAR_ZDLE)
-#define RSP_ZVLS	(RSP_VAR + VAR_ZVLS)
 #define RSP_ZCTP	(RSP_VAR + VAR_ZCTP)
+/* - string */
 #define RSP_STR		(RSP_VAR + VAR_NUM)
 #define RSP_NMBR	(RSP_STR + STR_NMBR)
 #define RSP_ZCPN	(RSP_STR + STR_ZCPN)
 #define RSP_ZCON	(RSP_STR + STR_ZCON)
 #define RSP_ZBC		(RSP_STR + STR_ZBC)
 #define RSP_ZHLC	(RSP_STR + STR_ZHLC)
-#define RSP_ERROR	-1	/* ERROR              */
+
 #define RSP_WRONG_CID	-2	/* unknown cid in cmd */
-#define RSP_UNKNOWN	-4	/* unknown response   */
-#define RSP_FAIL	-5	/* internal error     */
 #define RSP_INVAL	-6	/* invalid response   */
+#define RSP_NODEV	-9	/* device not connected */
 
 #define RSP_NONE	-19
 #define RSP_STRING	-20
 #define RSP_NULL	-21
-#define RSP_RETRYFAIL	-22
-#define RSP_RETRY	-23
-#define RSP_SKIP	-24
 #define RSP_INIT	-27
 #define RSP_ANY		-26
 #define RSP_LAST	-28
-#define RSP_NODEV	-9
 
 /* actions for process_response */
 #define ACT_NOTHING		0
@@ -259,13 +246,6 @@ struct reply_t gigaset_tab_nocid[] =
 
 /* misc. */
 {RSP_ERROR,	 -1,  -1, -1,			 -1, -1, {ACT_ERROR} },
-{RSP_ZCFGT,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZCFG,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZLOG,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZMWI,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZABINFO,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZSMLSTCHG,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-
 {RSP_ZCAU,	 -1,  -1, -1,			 -1, -1, {ACT_ZCAU} },
 {RSP_NONE,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
 {RSP_ANY,	 -1,  -1, -1,			 -1, -1, {ACT_WARN} },
@@ -361,10 +341,6 @@ struct reply_t gigaset_tab_cid[] =
 
 /* misc. */
 {RSP_ZCON,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZCCR,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZAOC,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-{RSP_ZCSTR,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
-
 {RSP_ZCAU,	 -1,  -1, -1,			 -1, -1, {ACT_ZCAU} },
 {RSP_NONE,	 -1,  -1, -1,			 -1, -1, {ACT_DEBUG} },
 {RSP_ANY,	 -1,  -1, -1,			 -1, -1, {ACT_WARN} },
@@ -387,20 +363,11 @@ static const struct resp_type_t {
 	{"ZVLS",	RSP_ZVLS,	RT_NUMBER},
 	{"ZCTP",	RSP_ZCTP,	RT_NUMBER},
 	{"ZDLE",	RSP_ZDLE,	RT_NUMBER},
-	{"ZCFGT",	RSP_ZCFGT,	RT_NUMBER},
-	{"ZCCR",	RSP_ZCCR,	RT_NUMBER},
-	{"ZMWI",	RSP_ZMWI,	RT_NUMBER},
 	{"ZHLC",	RSP_ZHLC,	RT_STRING},
 	{"ZBC",		RSP_ZBC,	RT_STRING},
 	{"NMBR",	RSP_NMBR,	RT_STRING},
 	{"ZCPN",	RSP_ZCPN,	RT_STRING},
 	{"ZCON",	RSP_ZCON,	RT_STRING},
-	{"ZAOC",	RSP_ZAOC,	RT_STRING},
-	{"ZCSTR",	RSP_ZCSTR,	RT_STRING},
-	{"ZCFG",	RSP_ZCFG,	RT_HEX},
-	{"ZLOG",	RSP_ZLOG,	RT_NOTHING},
-	{"ZABINFO",	RSP_ZABINFO,	RT_NOTHING},
-	{"ZSMLSTCHG",	RSP_ZSMLSTCHG,	RT_NOTHING},
 	{NULL,		0,		0}
 };
 
@@ -588,10 +555,10 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 					break;
 
 			if (!rt->response) {
-				event->type = RSP_UNKNOWN;
-				dev_warn(cs->dev,
-					 "unknown modem response: %s\n",
-					 argv[curarg]);
+				event->type = RSP_NONE;
+				gig_dbg(DEBUG_EVENT,
+					"unknown modem response: '%s'\n",
+					argv[curarg]);
 				break;
 			}
 
@@ -655,14 +622,8 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				curarg = params - 1;
 			break;
 		case RT_NUMBER:
-		case RT_HEX:
 			if (curarg < params) {
-				if (param_type == RT_HEX)
-					event->parameter =
-						isdn_gethex(argv[curarg]);
-				else
-					event->parameter =
-						isdn_getnum(argv[curarg]);
+				event->parameter = isdn_getnum(argv[curarg]);
 				++curarg;
 			} else
 				event->parameter = -1;
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 1d0999b..add3d0c 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -193,9 +193,8 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 /* variables in struct at_state_t */
 #define VAR_ZSAU	0
 #define VAR_ZDLE	1
-#define VAR_ZVLS	2
-#define VAR_ZCTP	3
-#define VAR_NUM		4
+#define VAR_ZCTP	2
+#define VAR_NUM		3
 
 #define STR_NMBR	0
 #define STR_ZCPN	1
-- 
1.6.5.3.298.g39add
