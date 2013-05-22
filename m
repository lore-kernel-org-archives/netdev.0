From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: xt_socket: use IP early demux
Date: Wed, 22 May 2013 14:01:06 -0700
Message-ID: <1369256466.3301.364.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

With IP early demux added in linux-3.6, we perform TCP lookup in IP
layer before iptables hooks.

We can avoid doing a second lookup in xt_socket.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/xt_socket.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 63b2bdb..0270424 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -107,7 +107,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct udphdr _hdr, *hp = NULL;
-	struct sock *sk;
+	struct sock *sk = skb->sk;
 	__be32 uninitialized_var(daddr), uninitialized_var(saddr);
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
 	u8 uninitialized_var(protocol);
@@ -155,9 +155,11 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	}
 #endif
 
-	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
-				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
-	if (sk != NULL) {
+	if (!sk)
+		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
+					   saddr, daddr, sport, dport,
+					   par->in, NFT_LOOKUP_ANY);
+	if (sk) {
 		bool wildcard;
 		bool transparent = true;
 
@@ -173,7 +175,8 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 				       (sk->sk_state == TCP_TIME_WAIT &&
 					inet_twsk(sk)->tw_transparent));
 
-		xt_socket_put_sk(sk);
+		if (sk != skb->sk)
+			xt_socket_put_sk(sk);
 
 		if (wildcard || !transparent)
 			sk = NULL;
@@ -260,7 +263,7 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct udphdr _hdr, *hp = NULL;
-	struct sock *sk;
+	struct sock *sk = skb->sk;
 	struct in6_addr *daddr = NULL, *saddr = NULL;
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
 	int thoff = 0, uninitialized_var(tproto);
@@ -291,9 +294,11 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 		return false;
 	}
 
-	sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
-				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
-	if (sk != NULL) {
+	if (!sk)
+		sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+					   saddr, daddr, sport, dport,
+					   par->in, NFT_LOOKUP_ANY);
+	if (sk) {
 		bool wildcard;
 		bool transparent = true;
 
@@ -309,7 +314,8 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 				       (sk->sk_state == TCP_TIME_WAIT &&
 					inet_twsk(sk)->tw_transparent));
 
-		xt_socket_put_sk(sk);
+		if (sk != skb->sk)
+			xt_socket_put_sk(sk);
 
 		if (wildcard || !transparent)
 			sk = NULL;


