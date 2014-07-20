From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] isdn/capi: avoid index overrun from command_2_index()
Date: Sun, 20 Jul 2014 15:49:12 +0200 (CEST)
Message-ID: <20140720134913.13895140074@xenon.ts.pxnet.com>
Cc: David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:35188 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623AbaGTOSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2014 10:18:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The result of the function command_2_index() is used to index two
arrays mnames[] and cpars[] with max. index 0x4e but in its current
form that function can produce results up to 3*(0x9+0x9)+0x7f = 0xb5.
Legal values for the function's first argument (c) according to the
CAPI 2.0 standard are 0x00..0x08, 0x41, 0x80, 0x82..0x88, and 0xff.
This patch modifies command_2_index() in such a way that the result
is unchanged for legal values of c, and guaranteed to be less or
equal to 0x4e for any argument values.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index 6e797e5..b666d8b 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -201,15 +201,10 @@ static unsigned char *cpars[] =
 #define structTRcpyovl(x, y, l) memmove(y, x, l)
 
 /*-------------------------------------------------------*/
-static unsigned command_2_index(unsigned c, unsigned sc)
+static unsigned command_2_index(u8 c, u8 sc)
 {
-	if (c & 0x80)
+	if (c & 0xf0)
 		c = 0x9 + (c & 0x0f);
-	else if (c <= 0x0f);
-	else if (c == 0x41)
-		c = 0x9 + 0x1;
-	else if (c == 0xff)
-		c = 0x00;
 	return (sc & 3) * (0x9 + 0x9) + c;
 }
 
-- 
1.9.2.459.g68773ac
