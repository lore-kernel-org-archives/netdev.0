From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/4] geneve: implement geneve_get_sk_family helper
Date: Thu, 18 Feb 2016 11:22:49 +0100
Message-ID: <4d1533364167a04892cb7ec573b3b19dc01c682b.1455790645.git.jbenc@redhat.com>
References: <cover.1455790645.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426137AbcBRKXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:23:43 -0500
In-Reply-To: <cover.1455790645.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to the existing vxlan_get_sk_family.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/geneve.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 6f208132a574..f09de1e30955 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -110,6 +110,11 @@ static __be64 vni_to_tunnel_id(const __u8 *vni)
 #endif
 }
 
+static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
+{
+	return gs->sock->sk->sk_family;
+}
+
 static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 					__be32 addr, u8 vni[])
 {
@@ -165,16 +170,13 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	static u8 zero_vni[3];
 	u8 *vni;
 	int err = 0;
-	sa_family_t sa_family;
 #if IS_ENABLED(CONFIG_IPV6)
 	struct ipv6hdr *ip6h = NULL;
 	struct in6_addr addr6;
 	static struct in6_addr zero_addr6;
 #endif
 
-	sa_family = gs->sock->sk->sk_family;
-
-	if (sa_family == AF_INET) {
+	if (geneve_get_sk_family(gs) == AF_INET) {
 		iph = ip_hdr(skb); /* outer IP header... */
 
 		if (gs->collect_md) {
@@ -188,7 +190,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 
 		geneve = geneve_lookup(gs, addr, vni);
 #if IS_ENABLED(CONFIG_IPV6)
-	} else if (sa_family == AF_INET6) {
+	} else if (geneve_get_sk_family(gs) == AF_INET6) {
 		ip6h = ipv6_hdr(skb); /* outer IPv6 header... */
 
 		if (gs->collect_md) {
@@ -213,7 +215,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 			(gnvh->oam ? TUNNEL_OAM : 0) |
 			(gnvh->critical ? TUNNEL_CRIT_OPT : 0);
 
-		tun_dst = udp_tun_rx_dst(skb, sa_family, flags,
+		tun_dst = udp_tun_rx_dst(skb, geneve_get_sk_family(gs), flags,
 					 vni_to_tunnel_id(gnvh->vni),
 					 gnvh->opt_len * 4);
 		if (!tun_dst)
@@ -392,7 +394,7 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 	struct net_device *dev;
 	struct sock *sk = gs->sock->sk;
 	struct net *net = sock_net(sk);
-	sa_family_t sa_family = sk->sk_family;
+	sa_family_t sa_family = geneve_get_sk_family(gs);
 	__be16 port = inet_sk(sk)->inet_sport;
 	int err;
 
@@ -553,7 +555,7 @@ static void geneve_notify_del_rx_port(struct geneve_sock *gs)
 	struct net_device *dev;
 	struct sock *sk = gs->sock->sk;
 	struct net *net = sock_net(sk);
-	sa_family_t sa_family = sk->sk_family;
+	sa_family_t sa_family = geneve_get_sk_family(gs);
 	__be16 port = inet_sk(sk)->inet_sport;
 
 	rcu_read_lock();
@@ -596,7 +598,7 @@ static struct geneve_sock *geneve_find_sock(struct geneve_net *gn,
 
 	list_for_each_entry(gs, &gn->sock_list, list) {
 		if (inet_sk(gs->sock->sk)->inet_sport == dst_port &&
-		    inet_sk(gs->sock->sk)->sk.sk_family == family) {
+		    geneve_get_sk_family(gs) == family) {
 			return gs;
 		}
 	}
-- 
1.8.3.1
