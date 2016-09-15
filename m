From: Phil Turnbull <phil.turnbull@oracle.com>
Subject: [PATCH] irda: Free skb on irda_accept error path.
Date: Thu, 15 Sep 2016 12:41:44 -0400
Message-ID: <20160915164144.24472-1-phil.turnbull@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Samuel Ortiz <samuel@sortiz.org>,
        Phil Turnbull <phil.turnbull@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36936 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbcIOQqH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 12:46:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb is not freed if newsk is NULL. Rework the error path so free_skb is
unconditionally called on function exit.

Fixes: c3ea9fa27413 ("[IrDA] af_irda: IRDA_ASSERT cleanups")
Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>
---
 net/irda/af_irda.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 8d2f7c9b491d..ccc244406fb9 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -832,7 +832,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sock *sk = sock->sk;
 	struct irda_sock *new, *self = irda_sk(sk);
 	struct sock *newsk;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	int err;
 
 	err = irda_create(sock_net(sk), newsock, sk->sk_protocol, 0);
@@ -900,7 +900,6 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	err = -EPERM; /* value does not seem to make sense. -arnd */
 	if (!new->tsap) {
 		pr_debug("%s(), dup failed!\n", __func__);
-		kfree_skb(skb);
 		goto out;
 	}
 
@@ -919,7 +918,6 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	/* Clean up the original one to keep it in listen state */
 	irttp_listen(self->tsap);
 
-	kfree_skb(skb);
 	sk->sk_ack_backlog--;
 
 	newsock->state = SS_CONNECTED;
@@ -927,6 +925,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	irda_connect_response(new);
 	err = 0;
 out:
+	kfree_skb(skb);
 	release_sock(sk);
 	return err;
 }
-- 
2.9.0.rc2
