From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] ppp: deflate: never return len larger than output buffer
Date: Wed, 28 Jan 2015 10:56:04 +0100
Message-ID: <1422438964-7937-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38133 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763900AbbA2DPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 22:15:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we've run out of space in the output buffer to store more data, we
will call zlib_deflate with a NULL output buffer until we've consumed
remaining input.

When this happens, olen contains the size the output buffer would have
consumed iff we'd have had enough room.

This can later cause skb_over_panic when ppp_generic skb_put()s
the returned length.

Reported-by: Iain Douglas <centos@1n6.org.uk>
Signed-off-by: Florian Westphal <fw@strlen.de>
---

diff --git a/drivers/net/ppp/ppp_deflate.c b/drivers/net/ppp/ppp_deflate.c
index 602c625..b5edc7f 100644
--- a/drivers/net/ppp/ppp_deflate.c
+++ b/drivers/net/ppp/ppp_deflate.c
@@ -246,7 +246,7 @@ static int z_compress(void *arg, unsigned char *rptr, unsigned char *obuf,
 	/*
 	 * See if we managed to reduce the size of the packet.
 	 */
-	if (olen < isize) {
+	if (olen < isize && olen <= osize) {
 		state->stats.comp_bytes += olen;
 		state->stats.comp_packets++;
 	} else {
-- 
2.0.5
