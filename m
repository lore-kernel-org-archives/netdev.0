From: Michal Sojka <sojkam1@fel.cvut.cz>
Subject: [PATCH v2 2/2] net: Make minimum SO_SNDBUF size dependent on the protocol family
Date: Wed, 22 Jan 2014 09:27:37 +0100
Message-ID: <1390379257-9040-2-git-send-email-sojkam1@fel.cvut.cz>
References: <1390379257-9040-1-git-send-email-sojkam1@fel.cvut.cz>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Michal Sojka <sojkam1@fel.cvut.cz>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1390379257-9040-1-git-send-email-sojkam1@fel.cvut.cz>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For CAN bus it is desired to have the per-socket send queue limit much
smaller than for Ethernet-based protocols (see the previous patch).
This patch makes the lower limit of accepted setsockopt(SO_SNDBUF)
values smaller for PF_CAN sockets.

The value of SOCK_MIN_SNDBUF is kept unchanged, because it is only
used in two functions (sk_stream_moderate_sndbuf, tcp_out_of_memory)
that seem to be called for TCP/IP related protocols only and the
change from a constant to sk->sk_prot->min_sndbuf could have negative
performance impact.

Changes since v1:
- SOCK_MIN_SNDBUF changed back to a constant.

Signed-off-by: Michal Sojka <sojkam1@fel.cvut.cz>
---
 include/net/sock.h | 1 +
 net/can/raw.c      | 1 +
 net/core/sock.c    | 6 ++++--
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 808cbc2..9ca3c0c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -969,6 +969,7 @@ struct proto {
 	int			*sysctl_rmem;
 	int			max_header;
 	bool			no_autobind;
+	int			min_sndbuf;
 
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
diff --git a/net/can/raw.c b/net/can/raw.c
index 4ad0bb2..b58f53f 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -818,6 +818,7 @@ static struct proto raw_proto __read_mostly = {
 	.owner      = THIS_MODULE,
 	.obj_size   = sizeof(struct raw_sock),
 	.init       = raw_init,
+	.min_sndbuf = SKB_TRUESIZE(sizeof(struct can_frame) + sizeof(struct can_skb_priv)),
 };
 
 static const struct can_proto raw_can_proto = {
diff --git a/net/core/sock.c b/net/core/sock.c
index 0b39e7a..fddb6be 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -625,7 +625,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, unsigned int optlen)
 {
 	struct sock *sk = sock->sk;
-	int val;
+	int val, min;
 	int valbool;
 	struct linger ling;
 	int ret = 0;
@@ -681,7 +681,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		val = min_t(u32, val, sysctl_wmem_max);
 set_sndbuf:
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
-		sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);
+		min = sk->sk_prot->min_sndbuf ?
+			sk->sk_prot->min_sndbuf : SOCK_MIN_SNDBUF;
+		sk->sk_sndbuf = max_t(u32, val * 2, min);
 		/* Wake up sending tasks if we upped the value. */
 		sk->sk_write_space(sk);
 		break;
-- 
1.8.5.2

