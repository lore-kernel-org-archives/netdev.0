From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 1/5] ppp: lock ppp structure before modifying mru in
 ppp_ioctl()
Date: Mon, 22 Feb 2016 20:47:13 +0100
Message-ID: <be5fc2cf38f44951ea15f366bc52fb4d780009d2.1456167043.git.g.nault@alphalink.fr>
References: <cover.1456167043.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53800 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbcBVUtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:49:24 -0500
Content-Disposition: inline
In-Reply-To: <cover.1456167043.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPP's Tx and Rx paths read ppp->mru under protection of ppp_xmit_lock()
and ppp_recv_lock() respectively.
Therefore ppp_ioctl() must hold the xmit and recv locks before
concurrently updating ppp->mru.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index fc8ad00..4d342ae 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -654,7 +654,10 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case PPPIOCSMRU:
 		if (get_user(val, p))
 			break;
+		ppp_lock(ppp);
 		ppp->mru = val;
+		ppp_unlock(ppp);
+
 		err = 0;
 		break;
 
-- 
2.7.0
