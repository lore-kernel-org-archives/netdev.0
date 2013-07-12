From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: xt_socket: fix broken v0 support
Date: Thu, 11 Jul 2013 19:22:19 -0700
Message-ID: <1373595739.4600.123.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

commit 681f130f39e10 ("netfilter: xt_socket: add XT_SOCKET_NOWILDCARD
flag") added a potential NULL dereference if an old iptables package
uses v0 of the match.

Fix this by removing the test on @info in fast path.

IPv6 can remove the test as well, as it uses v1 or v2.

Reported-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_socket.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index f8b7191..20b1591 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -172,7 +172,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 
 		/* Ignore non-transparent sockets,
 		   if XT_SOCKET_TRANSPARENT is used */
-		if (info && info->flags & XT_SOCKET_TRANSPARENT)
+		if (info->flags & XT_SOCKET_TRANSPARENT)
 			transparent = ((sk->sk_state != TCP_TIME_WAIT &&
 					inet_sk(sk)->transparent) ||
 				       (sk->sk_state == TCP_TIME_WAIT &&
@@ -196,7 +196,11 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 static bool
 socket_mt4_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	return socket_match(skb, par, NULL);
+	static struct xt_socket_mtinfo1 xt_info_v0 = {
+		.flags = 0,
+	};
+
+	return socket_match(skb, par, &xt_info_v0);
 }
 
 static bool
@@ -314,7 +318,7 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 
 		/* Ignore non-transparent sockets,
 		   if XT_SOCKET_TRANSPARENT is used */
-		if (info && info->flags & XT_SOCKET_TRANSPARENT)
+		if (info->flags & XT_SOCKET_TRANSPARENT)
 			transparent = ((sk->sk_state != TCP_TIME_WAIT &&
 					inet_sk(sk)->transparent) ||
 				       (sk->sk_state == TCP_TIME_WAIT &&


