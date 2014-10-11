From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 09/12] isdn/capi: prevent NULL pointer dereference on invalid
 CAPI command
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <4abb1283653cd558823c5aa4f274b9f57422111f.1413021631.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:48078 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An invalid CAPI 2.0 command/subcommand combination may retrieve a
NULL pointer from the cpars[] array which will later be dereferenced
by the parser routines.
Fix by adding NULL pointer checks in strategic places.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index 8e401ed..36835ef 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -318,6 +318,8 @@ unsigned capi_cmsg2message(_cmsg *cmsg, u8 *msg)
 	cmsg->l = 8;
 	cmsg->p = 0;
 	cmsg->par = capi_cmd2par(cmsg->Command, cmsg->Subcommand);
+	if (!cmsg->par)
+		return 1;	/* invalid command/subcommand */
 
 	pars_2_message(cmsg);
 
@@ -391,6 +393,8 @@ unsigned capi_message2cmsg(_cmsg *cmsg, u8 *msg)
 	byteTRcpy(cmsg->m + 4, &cmsg->Command);
 	byteTRcpy(cmsg->m + 5, &cmsg->Subcommand);
 	cmsg->par = capi_cmd2par(cmsg->Command, cmsg->Subcommand);
+	if (!cmsg->par)
+		return 1;	/* invalid command/subcommand */
 
 	message_2_pars(cmsg);
 
@@ -640,6 +644,9 @@ static _cdebbuf *printstruct(_cdebbuf *cdb, u8 *m)
 
 static _cdebbuf *protocol_message_2_pars(_cdebbuf *cdb, _cmsg *cmsg, int level)
 {
+	if (!cmsg->par)
+		return NULL;	/* invalid command/subcommand */
+
 	for (; TYP != _CEND; cmsg->p++) {
 		int slen = 29 + 3 - level;
 		int i;
-- 
1.9.2.459.g68773ac
