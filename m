From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH net-next 1/1] net: ppp: reset nextseq counter when enabling
 SC_MULTILINK
Date: Tue, 15 Jul 2014 11:51:03 +0200
Message-ID: <53C4F987.1040401@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server721-han.de-nserver.de ([85.158.180.102]:46901 "EHLO
	server721-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758516AbaGOJvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 05:51:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Schulz <develop@kristov.de>

If using a demand-dialled PPP unit for a PPP multilink master, the pppd
daemon needs to reset the sequence counter between two connections. This
allows the daemon to reuse the PPP unit instead of destroying and recreating
it. As there is no API to reset the counter, this patch resets the counter
whenever the SC_MULTILINK flag is set.

Signed-off-by: Christoph Schulz <develop@kristov.de>
---
Note that the stock pppd does not yet support multilink PPP over a
demand-dialled interface. I used a locally patched version for testing.

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 91d6c12..a0aae43 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -661,6 +661,8 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			break;
 		ppp_lock(ppp);
 		cflags = ppp->flags & ~val;
+		if (!(ppp->flags & SC_MULTILINK) && (val & SC_MULTILINK))
+			ppp->nextseq = 0;
 		ppp->flags = val & SC_FLAG_BITS;
 		ppp_unlock(ppp);
 		if (cflags & SC_CCP_OPEN)
