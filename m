From: Colin King <colin.king@canonical.com>
Subject: [PATCH] can: check for null sk before deferencing it via the call to sock_net
Date: Fri,  8 Sep 2017 16:02:35 +0100
Message-ID: <20170908150235.2931-1-colin.king@canonical.com>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S . Miller" <davem@davemloft.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The assignment of net via call sock_net will dereference sk. This
is performed before a sanity null check on sk, so there could be
a potential null dereference on the sock_net call if sk is null.
Fix this by assigning net after the sk null check. Also replace
the sk == NULL with the more usual !sk idiom.

Detected by CoverityScan CID#1431862 ("Dereference before null check")

Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM protocol")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/can/bcm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 47a8748d953a..a3791674b8ce 100644
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
2.14.1
