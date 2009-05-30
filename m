From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/3] isdn: prevent NULL ptr oops in capi_cmsg2str()
Date: Sun, 31 May 2009 01:32:17 +0200 (CEST)
Message-ID: <20090531-patch-02.tilman@imap.cc>
References: <20090531-patch-00.tilman@imap.cc>
To: davem@davemloft.net, Karsten Keil <karsten-keil@t-online.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-ker
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:41634 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756561AbZE3Xc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2009 19:32:26 -0400
In-Reply-To: <20090531-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The capi_cmsg2str() function has the undocumented requirement that one
of the functions capi_cmsg2message() or capi_message2cmsg() must have
been called before it, otherwise a NULL pointer dereference occurs.
This patch adds a NULL pointer check to avoid the Oops, and also adds
kerneldoc comments to the exported functions in capiutil.c.

Impact: documentation and error handling improvement, no functional change
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c |   67 ++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index 29419a8..35ba711 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -490,7 +490,14 @@ static void pars_2_message(_cmsg * cmsg)
 	}
 }
 
-/*-------------------------------------------------------*/
+/**
+ * capi_cmsg2message() - assemble CAPI 2.0 message from _cmsg structure
+ * @cmsg:	_cmsg structure
+ * @msg:	buffer for assembled message
+ *
+ * Return value: 0 for success
+ */
+
 unsigned capi_cmsg2message(_cmsg * cmsg, u8 * msg)
 {
 	cmsg->m = msg;
@@ -553,7 +560,14 @@ static void message_2_pars(_cmsg * cmsg)
 	}
 }
 
-/*-------------------------------------------------------*/
+/**
+ * capi_message2cmsg() - disassemble CAPI 2.0 message into _cmsg structure
+ * @cmsg:	_cmsg structure
+ * @msg:	buffer for assembled message
+ *
+ * Return value: 0 for success
+ */
+
 unsigned capi_message2cmsg(_cmsg * cmsg, u8 * msg)
 {
 	memset(cmsg, 0, sizeof(_cmsg));
@@ -573,7 +587,18 @@ unsigned capi_message2cmsg(_cmsg * cmsg, u8 * msg)
 	return 0;
 }
 
-/*-------------------------------------------------------*/
+/**
+ * capi_cmsg_header() - initialize header part of _cmsg structure
+ * @cmsg:	_cmsg structure
+ * @_ApplId:	ApplID field value
+ * @_Command:	Command field value
+ * @_Subcommand:	Subcommand field value
+ * @_Messagenumber:	Message Number field value
+ * @_Controller:	Controller/PLCI/NCCI field value
+ *
+ * Return value: 0 for success
+ */
+
 unsigned capi_cmsg_header(_cmsg * cmsg, u16 _ApplId,
 			  u8 _Command, u8 _Subcommand,
 			  u16 _Messagenumber, u32 _Controller)
@@ -641,6 +666,14 @@ static char *mnames[] =
 	[0x4e] = "MANUFACTURER_RESP"
 };
 
+/**
+ * capi_cmd2str() - convert CAPI 2.0 command/subcommand number to name
+ * @cmd:	command number
+ * @subcmd:	subcommand number
+ *
+ * Return value: static string
+ */
+
 char *capi_cmd2str(u8 cmd, u8 subcmd)
 {
 	return mnames[command_2_index(cmd, subcmd)];
@@ -879,6 +912,11 @@ init:
 	return cdb;
 }
 
+/**
+ * cdebbuf_free() - free CAPI debug buffer
+ * @cdb:	buffer to free
+ */
+
 void cdebbuf_free(_cdebbuf *cdb)
 {
 	if (likely(cdb == g_debbuf)) {
@@ -891,6 +929,16 @@ void cdebbuf_free(_cdebbuf *cdb)
 }
 
 
+/**
+ * capi_message2str() - format CAPI 2.0 message for printing
+ * @msg:	CAPI 2.0 message
+ *
+ * Allocates a CAPI debug buffer and fills it with a printable representation
+ * of the CAPI 2.0 message in @msg.
+ * Return value: allocated debug buffer, NULL on error
+ * The returned buffer should be freed by a call to cdebbuf_free() after use.
+ */
+
 _cdebbuf *capi_message2str(u8 * msg)
 {
 	_cdebbuf *cdb;
@@ -926,10 +974,23 @@ _cdebbuf *capi_message2str(u8 * msg)
 	return cdb;
 }
 
+/**
+ * capi_cmsg2str() - format _cmsg structure for printing
+ * @cmsg:	_cmsg structure
+ *
+ * Allocates a CAPI debug buffer and fills it with a printable representation
+ * of the CAPI 2.0 message stored in @cmsg by a previous call to
+ * capi_cmsg2message() or capi_message2cmsg().
+ * Return value: allocated debug buffer, NULL on error
+ * The returned buffer should be freed by a call to cdebbuf_free() after use.
+ */
+
 _cdebbuf *capi_cmsg2str(_cmsg * cmsg)
 {
 	_cdebbuf *cdb;
 
+	if (!cmsg->m)
+		return NULL;	/* no message */
 	cdb = cdebbuf_alloc();
 	if (!cdb)
 		return NULL;
-- 
1.6.2.1.214.ge986c

