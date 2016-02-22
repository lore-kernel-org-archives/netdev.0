From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 3/5] ppp: protect ppp->debug in ppp_ioctl()
Date: Mon, 22 Feb 2016 20:47:17 +0100
Message-ID: <4d46a495be31d67fa3616c54aa03f18073e5f8bb.1456167043.git.g.nault@alphalink.fr>
References: <cover.1456167043.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53770 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742AbcBVUtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:49:22 -0500
Content-Disposition: inline
In-Reply-To: <cover.1456167043.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ppp->debug is read in the Tx and Rx paths while under protection of
ppp_xmit_lock() and ppp_recv_lock() respectively.
So ppp_ioctl() must hold both locks before concurrently updating it.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
Locking is not strictly necessary for PPPIOCGDEBUG, because ppp->debug
can only be modified by ioctl(PPPIOCSDEBUG) which is guaranteed not to
run concurrently thanks to ppp_mutex. I've added the locking in
PPPIOCGDEBUG in order to respect the general locking semantic of
ppp->debug and to avoid relying on ppp_mutex.

 drivers/net/ppp/ppp_generic.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 4af548b..183d89c 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -708,12 +708,19 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case PPPIOCSDEBUG:
 		if (get_user(val, p))
 			break;
+		ppp_lock(ppp);
 		ppp->debug = val;
+		ppp_unlock(ppp);
+
 		err = 0;
 		break;
 
 	case PPPIOCGDEBUG:
-		if (put_user(ppp->debug, p))
+		ppp_lock(ppp);
+		val = ppp->debug;
+		ppp_unlock(ppp);
+
+		if (put_user(val, p))
 			break;
 		err = 0;
 		break;
-- 
2.7.0
