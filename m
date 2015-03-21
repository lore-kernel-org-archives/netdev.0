From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/4] isdn/gigaset: restructure modem response parser (3)
Date: Sat, 21 Mar 2015 20:15:32 +0100 (CET)
Message-ID: <b199df3f08e05a09518442c95be709857c320a01.1426964840.git.tilman@imap.cc>
References: <cover.1426964840.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:43445 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720AbbCUTuB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 15:50:01 -0400
In-Reply-To: <cover.1426964840.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate CID detection from main parser loop.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c | 56 ++++++++++++++---------------------------
 1 file changed, 19 insertions(+), 37 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index b2a1fb1..dc6e6a3 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -389,24 +389,6 @@ zsau_resp[] =
 	{NULL,				ZSAU_UNKNOWN}
 };
 
-/* retrieve CID from parsed response
- * returns 0 if no CID, -1 if invalid CID, or CID value 1..65535
- */
-static int cid_of_response(char *s)
-{
-	int cid;
-	int rc;
-
-	if (s[-1] != ';')
-		return 0;	/* no CID separator */
-	rc = kstrtoint(s, 10, &cid);
-	if (rc)
-		return 0;	/* CID not numeric */
-	if (cid < 1 || cid > 65535)
-		return -1;	/* CID out of range */
-	return cid;
-}
-
 /* queue event with CID */
 static void add_cid_event(struct cardstate *cs, int cid, int type,
 			  void *ptr, int parameter)
@@ -451,7 +433,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 	unsigned char *argv[MAX_REC_PARAMS + 1];
 	int params;
 	int i, j;
-	char *ptr;
+	char *psep, *ptr;
 	const struct resp_type_t *rt;
 	const struct zsau_resp_t *zr;
 	int curarg;
@@ -474,6 +456,18 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		return;
 	}
 
+	/* check for CID */
+	psep = strrchr(cs->respdata, ';');
+	if (psep &&
+	    !kstrtoint(psep + 1, 10, &cid) &&
+	    cid >= 1 && cid <= 65535) {
+		/* valid CID: chop it off */
+		*psep = 0;
+	} else {
+		/* no valid CID: leave unchanged */
+		cid = 0;
+	}
+
 	/* parse line */
 	argv[0] = cs->respdata;
 	params = 1;
@@ -482,29 +476,17 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		case ';':
 		case ',':
 		case '=':
-			if (params > MAX_REC_PARAMS) {
+			cs->respdata[i] = 0;
+			if (params > MAX_REC_PARAMS)
 				dev_warn(cs->dev,
 					 "too many parameters in response\n");
-				/* need last parameter (might be CID) */
-				params--;
-			}
-			argv[params++] = cs->respdata + i + 1;
+			else
+				argv[params++] = cs->respdata + i + 1;
 		}
 
-	cid = params > 1 ? cid_of_response(argv[params - 1]) : 0;
-	if (cid < 0) {
-		gigaset_add_event(cs, &cs->at_state, RSP_INVAL, NULL, 0, NULL);
-		return;
-	}
-
-	for (j = 1; j < params; ++j)
-		argv[j][-1] = 0;
-
 	gig_dbg(DEBUG_EVENT, "CMD received: %s", argv[0]);
-	if (cid) {
-		--params;
-		gig_dbg(DEBUG_EVENT, "CID: %s", argv[params]);
-	}
+	if (cid)
+		gig_dbg(DEBUG_EVENT, "CID: %d", cid);
 	gig_dbg(DEBUG_EVENT, "available params: %d", params - 1);
 	for (j = 1; j < params; j++)
 		gig_dbg(DEBUG_EVENT, "param %d: %s", j, argv[j]);
-- 
1.9.2.459.g68773ac
