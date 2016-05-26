From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] net: l2tp: Make l2tp_ip6 namespace aware
Date: Thu, 26 May 2016 20:16:36 +0300
Message-ID: <1464282996-9323-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chris Elston <celston@katalix.com>,
	James Chapman <jchapman@katalix.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34088 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbcEZRRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 13:17:16 -0400
Received: by mail-wm0-f67.google.com with SMTP id n129so6862716wmn.1
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 10:17:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_ip6 tunnel and session lookups were still using init_net, although
the l2tp core infrastructure already supports lookups keyed by 'net'.

As a result, l2tp_ip6_recv discarded packets for tunnels/sessions
created in namespaces other than the init_net.

Fix, by using dev_net(skb->dev) or sock_net(sk) where appropriate.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/l2tp/l2tp_ip6.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index c6f5df1bed..6c54e03fe9 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -128,6 +128,7 @@ static inline struct sock *l2tp_ip6_bind_lookup(struct net *net,
  */
 static int l2tp_ip6_recv(struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb->dev);
 	struct sock *sk;
 	u32 session_id;
 	u32 tunnel_id;
@@ -154,7 +155,7 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 	}
 
 	/* Ok, this is a data packet. Lookup the session. */
-	session = l2tp_session_find(&init_net, NULL, session_id);
+	session = l2tp_session_find(net, NULL, session_id);
 	if (session == NULL)
 		goto discard;
 
@@ -188,14 +189,14 @@ pass_up:
 		goto discard;
 
 	tunnel_id = ntohl(*(__be32 *) &skb->data[4]);
-	tunnel = l2tp_tunnel_find(&init_net, tunnel_id);
+	tunnel = l2tp_tunnel_find(net, tunnel_id);
 	if (tunnel != NULL)
 		sk = tunnel->sock;
 	else {
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		read_lock_bh(&l2tp_ip6_lock);
-		sk = __l2tp_ip6_bind_lookup(&init_net, &iph->daddr,
+		sk = __l2tp_ip6_bind_lookup(net, &iph->daddr,
 					    0, tunnel_id);
 		read_unlock_bh(&l2tp_ip6_lock);
 	}
@@ -263,6 +264,7 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_l2tpip6 *addr = (struct sockaddr_l2tpip6 *) uaddr;
+	struct net *net = sock_net(sk);
 	__be32 v4addr = 0;
 	int addr_type;
 	int err;
@@ -286,7 +288,7 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	err = -EADDRINUSE;
 	read_lock_bh(&l2tp_ip6_lock);
-	if (__l2tp_ip6_bind_lookup(&init_net, &addr->l2tp_addr,
+	if (__l2tp_ip6_bind_lookup(net, &addr->l2tp_addr,
 				   sk->sk_bound_dev_if, addr->l2tp_conn_id))
 		goto out_in_use;
 	read_unlock_bh(&l2tp_ip6_lock);
@@ -456,7 +458,7 @@ static int l2tp_ip6_backlog_recv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 
 drop:
-	IP_INC_STATS(&init_net, IPSTATS_MIB_INDISCARDS);
+	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_INDISCARDS);
 	kfree_skb(skb);
 	return -1;
 }
-- 
2.7.4
