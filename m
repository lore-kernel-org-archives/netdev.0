From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 07/11] can: bcm: check for null sk before deferencing it via the call to sock_net
Date: Thu, 19 Oct 2017 13:19:41 +0200
Message-ID: <20171019111945.13580-8-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Colin Ian King <colin.king@canonical.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:52597 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752964AbdJSLT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:19:56 -0400
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The assignment of net via call sock_net will dereference sk. This
is performed before a sanity null check on sk, so there could be
a potential null dereference on the sock_net call if sk is null.
Fix this by assigning net after the sk null check. Also replace
the sk == NULL with the more usual !sk idiom.

Detected by CoverityScan CID#1431862 ("Dereference before null check")

Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM protocol")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/can/bcm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 47a8748d953a..13690334efa3 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1493,13 +1493,14 @@ static int bcm_init(struct sock *sk)
 static int bcm_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sock_net(sk);
+	struct net *net;
 	struct bcm_sock *bo;
 	struct bcm_op *op, *next;
 
-	if (sk == NULL)
+	if (!sk)
 		return 0;
 
+	net = sock_net(sk);
 	bo = bcm_sk(sk);
 
 	/* remove bcm_ops, timer, rx_unregister(), etc. */
-- 
2.14.2
