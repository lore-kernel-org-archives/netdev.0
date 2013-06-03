From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH nf-next] netfilter: xt_socket: add XT_SOCKET_NOWILDCARD flag
Date: Mon, 03 Jun 2013 15:57:29 -0700
Message-ID: <1370300249.24311.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

xt_socket module can be a nice replacement to conntrack module
in some cases (SYN filtering for example)

But it lacks the ability to match the 3rd packet of TCP
handshake (ACK coming from the client).

Add a XT_SOCKET_NOWILDCARD flag to disable the wildcard mechanism

iptables -I INPUT -p tcp --syn -j SYN_CHAIN
iptables -I INPUT -m socket -j ACCEPT


Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/uapi/linux/netfilter/xt_socket.h |    1 +
 net/netfilter/xt_socket.c                |   14 ++++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_socket.h b/include/uapi/linux/netfilter/xt_socket.h
index 26d7217..be1994fb 100644
--- a/include/uapi/linux/netfilter/xt_socket.h
+++ b/include/uapi/linux/netfilter/xt_socket.h
@@ -5,6 +5,7 @@
 
 enum {
 	XT_SOCKET_TRANSPARENT = 1 << 0,
+	XT_SOCKET_NOWILDCARD = 1 << 1,
 };
 
 struct xt_socket_mtinfo1 {
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 0270424..9843314 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -163,8 +163,11 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 		bool wildcard;
 		bool transparent = true;
 
-		/* Ignore sockets listening on INADDR_ANY */
-		wildcard = (sk->sk_state != TCP_TIME_WAIT &&
+		/* Ignore sockets listening on INADDR_ANY,
+		 * unless XT_SOCKET_NOWILDCARD is set
+		 */
+		wildcard = (!(info->flags & XT_SOCKET_NOWILDCARD) &&
+			    sk->sk_state != TCP_TIME_WAIT &&
 			    inet_sk(sk)->inet_rcv_saddr == 0);
 
 		/* Ignore non-transparent sockets,
@@ -302,8 +305,11 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 		bool wildcard;
 		bool transparent = true;
 
-		/* Ignore sockets listening on INADDR_ANY */
-		wildcard = (sk->sk_state != TCP_TIME_WAIT &&
+		/* Ignore sockets listening on INADDR_ANY
+		 * unless XT_SOCKET_NOWILDCARD is set
+		 */
+		wildcard = (!(info->flags & XT_SOCKET_NOWILDCARD) &&
+			    sk->sk_state != TCP_TIME_WAIT &&
 			    ipv6_addr_any(&inet6_sk(sk)->rcv_saddr));
 
 		/* Ignore non-transparent sockets,


