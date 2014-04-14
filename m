From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: icn: buffer overflow in icn_command()
Date: Mon, 14 Apr 2014 11:07:56 +0300
Message-ID: <20140414080756.GA13372@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17108 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbaDNIIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 04:08:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cbuf[] buffer is 60 characters but we're putting a potential 79
characters and a NUL into it.  I've made it 80 characters and changed
the sprintf() to snprintf().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
index 53d487f..88c0603 100644
--- a/drivers/isdn/icn/icn.c
+++ b/drivers/isdn/icn/icn.c
@@ -1155,7 +1155,7 @@ icn_command(isdn_ctrl *c, icn_card *card)
 	ulong a;
 	ulong flags;
 	int i;
-	char cbuf[60];
+	char cbuf[80];
 	isdn_ctrl cmd;
 	icn_cdef cdef;
 	char __user *arg;
@@ -1309,7 +1309,6 @@ icn_command(isdn_ctrl *c, icn_card *card)
 			break;
 		if ((c->arg & 255) < ICN_BCH) {
 			char *p;
-			char dial[50];
 			char dcode[4];
 
 			a = c->arg;
@@ -1321,10 +1320,10 @@ icn_command(isdn_ctrl *c, icn_card *card)
 			} else
 				/* Normal Dial */
 				strcpy(dcode, "CAL");
-			strcpy(dial, p);
-			sprintf(cbuf, "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
-				dcode, dial, c->parm.setup.si1,
-				c->parm.setup.si2, c->parm.setup.eazmsn);
+			snprintf(cbuf, sizeof(cbuf),
+				 "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
+				 dcode, p, c->parm.setup.si1,
+				 c->parm.setup.si2, c->parm.setup.eazmsn);
 			i = icn_writecmd(cbuf, strlen(cbuf), 0, card);
 		}
 		break;
