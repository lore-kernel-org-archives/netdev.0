From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: fix pppoe_dev deletion condition in pppoe_release()
Date: Thu, 22 Oct 2015 16:57:10 +0200
Message-ID: <6a9ae28f4128939528dcf64795f1de88b39a6118.1445525554.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>,
	Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
	Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:36810 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964891AbbJVO5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:57:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't rely on PPPOX_ZOMBIE to decide whether to clear po->pppoe_dev.
PPPOX_ZOMBIE can be set by pppoe_disc_rcv() even when po->pppoe_dev is
NULL. So we have no guarantee that (sk->sk_state & PPPOX_ZOMBIE) implies
(po->pppoe_dev != NULL).
Since we're releasing a PPPoE socket, we want to release the pppoe_dev
if it exists and reset sk_state to PPPOX_DEAD, no matter the previous
value of sk_state. So we can just check for po->pppoe_dev and avoid any
assumption on sk->sk_state.

Fixes: 2b018d57ff18 ("pppoe: drop PPPOX_ZOMBIEs in pppoe_release")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/pppoe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 2ed7506..5e0b432 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -589,7 +589,7 @@ static int pppoe_release(struct socket *sock)
 
 	po = pppox_sk(sk);
 
-	if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
+	if (po->pppoe_dev) {
 		dev_put(po->pppoe_dev);
 		po->pppoe_dev = NULL;
 	}
-- 
2.6.1
