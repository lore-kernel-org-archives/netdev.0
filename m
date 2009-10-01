From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] gigaset/CAPI: accept any number type/plan
Date: Thu,  1 Oct 2009 11:53:13 +0200 (CEST)
Message-ID: <20090930-patch-gigaset-14.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, davem@davemloft.net,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756094AbZJAJx0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Be more liberal in accepting CAPI CONNECT_REQ message parameters
Called Party Number and Calling Party Number:
* Accept Numbering plan "ISDN/Telephony" as supported.
* Ignore unsupported values for Type of number, Numbering plan,
  Presentation indicator and Screening indicator with a warning
  instead of rejecting the entire request.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
A second small fix to the new Gigaset CAPI interface resulting from
testing with more applications. Please tell me if you'd prefer me
to reissue "[PATCH 12/12] gigaset: add Kernel CAPI interface" with
both fixes folded in.

 drivers/isdn/gigaset/capi.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 8afff37..c276a92 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1236,12 +1236,14 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 		goto error;
 	}
 	l = *pp++;
-	/* check number type/numbering plan byte */
-	if (*pp != 0x80) {
+	/* check type of number/numbering plan byte */
+	switch (*pp) {
+	case 0x80:	/* unknown type / unknown numbering plan */
+	case 0x81:	/* unknown type / ISDN/Telephony numbering plan */
+		break;
+	default:	/* others: warn about potential misinterpretation */
 		dev_notice(cs->dev, "%s: %s type/plan 0x%02x unsupported\n",
 			   "CONNECT_REQ", "Called party number", *pp);
-		info = CapiIllMessageParmCoding;
-		goto error;
 	}
 	pp++;
 	l--;
@@ -1266,26 +1268,28 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	if (pp != NULL && *pp > 0) {
 		l = *pp++;
 
-		/* check number type/numbering plan byte */
-		if (*pp) {
-			/* ToDo: allow for Ext=1? */
+		/* check type of number/numbering plan byte */
+		/* ToDo: handle Ext=1? */
+		switch (*pp) {
+		case 0x00:	/* unknown type / unknown numbering plan */
+		case 0x01:	/* unknown type / ISDN/Telephony num. plan */
+			break;
+		default:
 			dev_notice(cs->dev,
 				   "%s: %s type/plan 0x%02x unsupported\n",
 				   "CONNECT_REQ", "Calling party number", *pp);
-			info = CapiIllMessageParmCoding;
-			goto error;
 		}
 		pp++;
 		l--;
 
-		/* check presentation/screening indicator */
+		/* check presentation indicator */
 		if (!l) {
 			dev_notice(cs->dev, "%s: %s IE truncated\n",
 				   "CONNECT_REQ", "Calling party number");
 			info = CapiIllMessageParmCoding;
 			goto error;
 		}
-		switch (*pp) {
+		switch (*pp & 0xfc) { /* ignore Screening indicator */
 		case 0x80:	/* Presentation allowed */
 			s = "^SCLIP=1\r";
 			break;
@@ -1297,8 +1301,7 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 				   "CONNECT_REQ",
 				   "Presentation/Screening indicator",
 				   *pp);
-			info = CapiIllMessageParmCoding;
-			goto error;
+			s = "^SCLIP=1\r";
 		}
 		commands[AT_CLIP] = kstrdup(s, GFP_KERNEL);
 		if (!commands[AT_CLIP])
-- 
1.6.2.1.214.ge986c
