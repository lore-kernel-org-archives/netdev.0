From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 08/12] isdn/capi: refactor command/subcommand table accesses
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <87bc0bfeb6dda43c417a8c81c18ce73b787d61a3.1413021631.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:35862 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Encapsulate accesses to the CAPI 2.0 command/subcommand name and
parameter tables in a single place in preparation for redesign.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index b501d76..8e401ed 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -212,6 +212,19 @@ static unsigned command_2_index(unsigned c, unsigned sc)
 	return (sc & 3) * (0x9 + 0x9) + c;
 }
 
+/**
+ * capi_cmd2par() - find parameter string for CAPI 2.0 command/subcommand
+ * @cmd:	command number
+ * @subcmd:	subcommand number
+ *
+ * Return value: static string, NULL if command/subcommand unknown
+ */
+
+static unsigned char *capi_cmd2par(u8 cmd, u8 subcmd)
+{
+	return cpars[command_2_index(cmd, subcmd)];
+}
+
 /*-------------------------------------------------------*/
 #define TYP (cdef[cmsg->par[cmsg->p]].typ)
 #define OFF (((u8 *)cmsg) + cdef[cmsg->par[cmsg->p]].off)
@@ -304,7 +317,7 @@ unsigned capi_cmsg2message(_cmsg *cmsg, u8 *msg)
 	cmsg->m = msg;
 	cmsg->l = 8;
 	cmsg->p = 0;
-	cmsg->par = cpars[command_2_index(cmsg->Command, cmsg->Subcommand)];
+	cmsg->par = capi_cmd2par(cmsg->Command, cmsg->Subcommand);
 
 	pars_2_message(cmsg);
 
@@ -377,7 +390,7 @@ unsigned capi_message2cmsg(_cmsg *cmsg, u8 *msg)
 	cmsg->p = 0;
 	byteTRcpy(cmsg->m + 4, &cmsg->Command);
 	byteTRcpy(cmsg->m + 5, &cmsg->Subcommand);
-	cmsg->par = cpars[command_2_index(cmsg->Command, cmsg->Subcommand)];
+	cmsg->par = capi_cmd2par(cmsg->Command, cmsg->Subcommand);
 
 	message_2_pars(cmsg);
 
@@ -761,10 +774,10 @@ _cdebbuf *capi_message2str(u8 *msg)
 	cmsg->p = 0;
 	byteTRcpy(cmsg->m + 4, &cmsg->Command);
 	byteTRcpy(cmsg->m + 5, &cmsg->Subcommand);
-	cmsg->par = cpars[command_2_index(cmsg->Command, cmsg->Subcommand)];
+	cmsg->par = capi_cmd2par(cmsg->Command, cmsg->Subcommand);
 
 	cdb = bufprint(cdb, "%-26s ID=%03d #0x%04x LEN=%04d\n",
-		       mnames[command_2_index(cmsg->Command, cmsg->Subcommand)],
+		       capi_cmd2str(cmsg->Command, cmsg->Subcommand),
 		       ((unsigned short *) msg)[1],
 		       ((unsigned short *) msg)[3],
 		       ((unsigned short *) msg)[0]);
@@ -798,7 +811,7 @@ _cdebbuf *capi_cmsg2str(_cmsg *cmsg)
 	cmsg->l = 8;
 	cmsg->p = 0;
 	cdb = bufprint(cdb, "%s ID=%03d #0x%04x LEN=%04d\n",
-		       mnames[command_2_index(cmsg->Command, cmsg->Subcommand)],
+		       capi_cmd2str(cmsg->Command, cmsg->Subcommand),
 		       ((u16 *) cmsg->m)[1],
 		       ((u16 *) cmsg->m)[3],
 		       ((u16 *) cmsg->m)[0]);
-- 
1.9.2.459.g68773ac
