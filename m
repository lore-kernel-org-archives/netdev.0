From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/5] isdn/gigaset: encode HLC and BC together
Date: Tue, 22 Jun 2010 01:55:05 +0200 (CEST)
Message-ID: <20100622-patch-gigaset-04.tilman@imap.cc>
References: <20100622-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:38343 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932919Ab0FVAEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 20:04:42 -0400
In-Reply-To: <20100622-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt to buggy device firmware which accepts setting HLC only in the
same command line as BC, by encoding HLC and BC in a single command
if both are specified, and rejecting HLC without BC.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c     |   83 +++++++++++++++++++++++---------------
 drivers/isdn/gigaset/ev-layer.c |    4 +-
 drivers/isdn/gigaset/gigaset.h  |    5 +-
 3 files changed, 53 insertions(+), 39 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index e685123..7d9549e 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1166,7 +1166,7 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	char **commands;
 	char *s;
 	u8 *pp;
-	int i, l;
+	int i, l, lbc, lhlc;
 	u16 info;
 
 	/* decode message */
@@ -1293,43 +1293,60 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 		goto error;
 	}
 
-	/* check/encode parameter: BC */
-	if (cmsg->BC && cmsg->BC[0]) {
-		/* explicit BC overrides CIP */
-		l = 2*cmsg->BC[0] + 7;
+	/*
+	 * check/encode parameters: BC & HLC
+	 * must be encoded together as device doesn't accept HLC separately
+	 * explicit parameters override values derived from CIP
+	 */
+
+	/* determine lengths */
+	if (cmsg->BC && cmsg->BC[0])		/* BC specified explicitly */
+		lbc = 2*cmsg->BC[0];
+	else if (cip2bchlc[cmsg->CIPValue].bc)	/* BC derived from CIP */
+		lbc = strlen(cip2bchlc[cmsg->CIPValue].bc);
+	else					/* no BC */
+		lbc = 0;
+	if (cmsg->HLC && cmsg->HLC[0])		/* HLC specified explicitly */
+		lhlc = 2*cmsg->HLC[0];
+	else if (cip2bchlc[cmsg->CIPValue].hlc)	/* HLC derived from CIP */
+		lhlc = strlen(cip2bchlc[cmsg->CIPValue].hlc);
+	else					/* no HLC */
+		lhlc = 0;
+
+	if (lbc) {
+		/* have BC: allocate and assemble command string */
+		l = lbc + 7;		/* "^SBC=" + value + "\r" + null byte */
+		if (lhlc)
+			l += lhlc + 7;	/* ";^SHLC=" + value */
 		commands[AT_BC] = kmalloc(l, GFP_KERNEL);
 		if (!commands[AT_BC])
 			goto oom;
 		strcpy(commands[AT_BC], "^SBC=");
-		decode_ie(cmsg->BC, commands[AT_BC]+5);
+		if (cmsg->BC && cmsg->BC[0])	/* BC specified explicitly */
+			decode_ie(cmsg->BC, commands[AT_BC] + 5);
+		else				/* BC derived from CIP */
+			strcpy(commands[AT_BC] + 5,
+			       cip2bchlc[cmsg->CIPValue].bc);
+		if (lhlc) {
+			strcpy(commands[AT_BC] + lbc + 5, ";^SHLC=");
+			if (cmsg->HLC && cmsg->HLC[0])
+				/* HLC specified explicitly */
+				decode_ie(cmsg->HLC,
+					  commands[AT_BC] + lbc + 12);
+			else	/* HLC derived from CIP */
+				strcpy(commands[AT_BC] + lbc + 12,
+				       cip2bchlc[cmsg->CIPValue].hlc);
+		}
 		strcpy(commands[AT_BC] + l - 2, "\r");
-	} else if (cip2bchlc[cmsg->CIPValue].bc) {
-		l = strlen(cip2bchlc[cmsg->CIPValue].bc) + 7;
-		commands[AT_BC] = kmalloc(l, GFP_KERNEL);
-		if (!commands[AT_BC])
-			goto oom;
-		snprintf(commands[AT_BC], l, "^SBC=%s\r",
-			 cip2bchlc[cmsg->CIPValue].bc);
-	}
-
-	/* check/encode parameter: HLC */
-	if (cmsg->HLC && cmsg->HLC[0]) {
-		/* explicit HLC overrides CIP */
-		l = 2*cmsg->HLC[0] + 7;
-		commands[AT_HLC] = kmalloc(l, GFP_KERNEL);
-		if (!commands[AT_HLC])
-			goto oom;
-		strcpy(commands[AT_HLC], "^SHLC=");
-		decode_ie(cmsg->HLC, commands[AT_HLC]+5);
-		strcpy(commands[AT_HLC] + l - 2, "\r");
-	} else if (cip2bchlc[cmsg->CIPValue].hlc) {
-		l = strlen(cip2bchlc[cmsg->CIPValue].hlc) + 7;
-		commands[AT_HLC] = kmalloc(l, GFP_KERNEL);
-		if (!commands[AT_HLC])
-			goto oom;
-		snprintf(commands[AT_HLC], l, "^SHLC=%s\r",
-			 cip2bchlc[cmsg->CIPValue].hlc);
-	}
+	} else {
+		/* no BC */
+		if (lhlc) {
+			dev_notice(cs->dev, "%s: cannot set HLC without BC\n",
+				   "CONNECT_REQ");
+			info = CapiIllMessageParmCoding; /* ? */
+			goto error;
+		}
+	}
 
 	/* check/encode parameter: B Protocol */
 	if (cmsg->BProtocol == CAPI_DEFAULT) {
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 206c380..ceaef9a 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -282,9 +282,7 @@ struct reply_t gigaset_tab_cid[] =
 /* dial */
 {EV_DIAL,	 -1,  -1, -1,			 -1, -1, {ACT_DIAL} },
 {RSP_INIT,	  0,   0, SEQ_DIAL,		601,  5, {ACT_CMD+AT_BC} },
-{RSP_OK,	601, 601, -1,			602,  5, {ACT_CMD+AT_HLC} },
-{RSP_NULL,	602, 602, -1,			603,  5, {ACT_CMD+AT_PROTO} },
-{RSP_OK,	602, 602, -1,			603,  5, {ACT_CMD+AT_PROTO} },
+{RSP_OK,	601, 601, -1,			603,  5, {ACT_CMD+AT_PROTO} },
 {RSP_OK,	603, 603, -1,			604,  5, {ACT_CMD+AT_TYPE} },
 {RSP_OK,	604, 604, -1,			605,  5, {ACT_CMD+AT_MSN} },
 {RSP_NULL,	605, 605, -1,			606,  5, {ACT_CMD+AT_CLIP} },
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index f77ec54..c4e6c26 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -186,10 +186,9 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define AT_BC		3
 #define AT_PROTO	4
 #define AT_TYPE		5
-#define AT_HLC		6
-#define AT_CLIP		7
+#define AT_CLIP		6
 /* total number */
-#define AT_NUM		8
+#define AT_NUM		7
 
 /* variables in struct at_state_t */
 #define VAR_ZSAU	0
-- 
1.6.5.3.298.g39add

