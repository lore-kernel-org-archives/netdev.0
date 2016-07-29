From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 2/3] macsec: RXSAs don't need to hold a reference on RXSCs
Date: Fri, 29 Jul 2016 15:37:54 +0200
Message-ID: <274de318b0cad01f83b23833f95b3f46c374e80f.1469782905.git.sd@queasysnail.net>
References: <cover.1469782905.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbcG2NiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 09:38:08 -0400
In-Reply-To: <cover.1469782905.git.sd@queasysnail.net>
In-Reply-To: <cover.1469782905.git.sd@queasysnail.net>
References: <cover.1469782905.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following the previous patch, RXSCs are held and properly refcounted in
the RX path (instead of being implicitly held by their SA), so the SA
doesn't need to hold a reference on its parent RXSC.

This also avoids panics on module unload caused by the double layer of
RCU callbacks (call_rcu frees the RXSA, which puts the final reference
on the RXSC and allows to free it in its own call_rcu) that commit
b196c22af5c3 ("macsec: add rcu_barrier() on module exit") didn't
protect against.
There were also some refcounting bugs in macsec_add_rxsa where I didn't
put the reference on the RXSC on the error paths, which would lead to
memory leaks.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 718cf98023ff..7f5c5e0f9cf9 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -344,7 +344,6 @@ static void free_rxsa(struct rcu_head *head)
 
 	crypto_free_aead(sa->key.tfm);
 	free_percpu(sa->stats);
-	macsec_rxsc_put(sa->sc);
 	kfree(sa);
 }
 
@@ -1653,7 +1652,7 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
 
 	rtnl_lock();
 	rx_sc = get_rxsc_from_nl(genl_info_net(info), attrs, tb_rxsc, &dev, &secy);
-	if (IS_ERR(rx_sc) || !macsec_rxsc_get(rx_sc)) {
+	if (IS_ERR(rx_sc)) {
 		rtnl_unlock();
 		return PTR_ERR(rx_sc);
 	}
-- 
2.9.0
