From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] isdn: icn: buffer overflow in icn_command()
Date: Wed, 16 Apr 2014 14:25:16 +0300
Message-ID: <20140416112516.GA12917@mwanda>
References: <1397490748.2803.18.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Joe Perches <joe@perches.com>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1397490748.2803.18.camel@joe-AO722>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This buffer over was detected using static analysis:

	drivers/isdn/icn/icn.c:1325 icn_command()
	error: format string overflow. buf_size: 60 length: 98

The calculation for the length of the string is off because it assumes
that the dial[] buffer holds a 50 character string, but actually it is
at most 31 characters and NUL.  I have removed the dial[] buffer because
it isn't needed.

The maximum length of the string is actually 79 characters and a NUL.  I
have made the cbuf[] array large enough to hold it and changed the
sprintf() to an snprintf() as a further safety enhancement.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: update changelog.

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

