From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 1/2] ppp: don't set sk_state to PPPOX_ZOMBIE in
 pppoe_disc_rcv()
Date: Thu, 19 Nov 2015 12:52:56 +0100
Message-ID: <a441d2b02deaccf42e7c6e90f168c63a074d4c0e.1447931252.git.g.nault@alphalink.fr>
References: <cover.1447931252.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@earthlink.net>,
	Simon Farnsworth <simon@farnz.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42648 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723AbbKSLw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 06:52:59 -0500
Content-Disposition: inline
In-Reply-To: <cover.1447931252.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 287f3a943fef ("pppoe: Use workqueue to die properly when a PADT
is received"), pppoe_disc_rcv() disconnects the socket by scheduling
pppoe_unbind_sock_work(). This is enough to stop socket transmission
and makes the PPPOX_ZOMBIE state uncessary.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/pppoe.c | 22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 5e0b432..1dedfbf 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -500,27 +500,9 @@ static int pppoe_disc_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	pn = pppoe_pernet(dev_net(dev));
 	po = get_item(pn, ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
-	if (po) {
-		struct sock *sk = sk_pppox(po);
-
-		bh_lock_sock(sk);
-
-		/* If the user has locked the socket, just ignore
-		 * the packet.  With the way two rcv protocols hook into
-		 * one socket family type, we cannot (easily) distinguish
-		 * what kind of SKB it is during backlog rcv.
-		 */
-		if (sock_owned_by_user(sk) == 0) {
-			/* We're no longer connect at the PPPOE layer,
-			 * and must wait for ppp channel to disconnect us.
-			 */
-			sk->sk_state = PPPOX_ZOMBIE;
-		}
-
-		bh_unlock_sock(sk);
+	if (po)
 		if (!schedule_work(&po->proto.pppoe.padt_work))
-			sock_put(sk);
-	}
+			sock_put(sk_pppox(po));
 
 abort:
 	kfree_skb(skb);
-- 
2.6.2
