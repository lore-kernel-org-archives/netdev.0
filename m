From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH net-next] net: pppoe: use correct MTU when using Multilink
 PPP with PPPoE
Date: Fri, 11 Jul 2014 09:09:53 +0200
Message-ID: <53BF8DC1.1040905@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, mostrows@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server721-han.de-nserver.de ([85.158.180.102]:43520 "EHLO
	server721-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751420AbaGKHPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 03:15:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Schulz <develop@kristov.de>

The PPP channel MTU is used with Multilink PPP when ppp_mp_explode() (see
ppp_generic module) tries to determine how big a fragment might be. If we
don't subtract 2 bytes (which corresponds to the PPP protocol number), the
payload becomes 1-2 bytes too big (1 byte if PPP protocol compression is
used, 2 otherwise), which causes the generated Ethernet packets to be dropped.
This is due to code in ppp_mp_explode() which says:

		/*
		 * hdrlen includes the 2-byte PPP protocol field, but the
		 * MTU counts only the payload excluding the protocol field.
		 * (RFC1661 Section 2)
		 */
		mtu = pch->chan->mtu - (hdrlen - 2);

This is correct, but the pppoe module does not account for it and includes
the 2-byte PPP protocol field into the computed MTU, which is wrong. This
error only manifests itself when using Multilink PPP, as otherwise the channel
MTU is not used anywhere.

The bug was introduced in commit c9aa6895371b2a257401f59d3393c9f7ac5a8698
("[PPPOE]: Advertise PPPoE MTU") from the very beginning. This patch applies
to 3.10 upwards but the fix can be applied (with minor modifications) to
kernels as old as 2.6.32.

Signed-off-by: Christoph Schulz <develop@kristov.de>
---
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 2ea7efd..6c9c16d 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -675,7 +675,7 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
 		po->chan.hdrlen = (sizeof(struct pppoe_hdr) +
 				   dev->hard_header_len);
 
-		po->chan.mtu = dev->mtu - sizeof(struct pppoe_hdr);
+		po->chan.mtu = dev->mtu - sizeof(struct pppoe_hdr) - 2;
 		po->chan.private = sk;
 		po->chan.ops = &pppoe_chan_ops;
 
