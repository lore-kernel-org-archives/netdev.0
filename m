From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Subject: [PATCH v3] tunnel: Clear IPCB(skb)->opt before dst_link_failure called
Date: Mon, 22 Feb 2016 12:24:58 +1300
Message-ID: <1456097098-23398-2-git-send-email-bernie.harris@alliedtelesis.co.nz>
References: <1455585016-7253-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
 <1456097098-23398-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, stable@vger.kernel.org,
	bernie.harris@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1456097098-23398-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPCB may contain data from previous layers (in the observed case the
qdisc layer). In the observed scenario, the data was misinterpreted as
ip header options, which later caused the ihl to be set to an invalid
value (<5). This resulted in an infinite loop in the mips implementation
of ip_fast_csum.

This patch clears IPCB(skb)->opt before dst_link_failure can be called for
various types of tunnels. This change only applies to encapsulated ipv4
packets.

The code introduced in 11c21a30 which clears all of IPCB has been removed
to be consistent with these changes, and instead the opt field is cleared
unconditionally in ip_tunnel_xmit. The change in ip_tunnel_xmit applies to
SIT, GRE, and IPIP tunnels.

The relevant vti, l2tp, and pptp functions already contain similar code for
clearing the IPCB.

Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
---
 net/ipv4/ip_tunnel.c  | 3 ++-
 net/ipv4/udp_tunnel.c | 2 ++
 net/ipv6/ip6_gre.c    | 2 ++
 net/ipv6/ip6_tunnel.c | 2 ++
 4 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 89e8861..336e689 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -661,6 +661,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
 	connected = (tunnel->parms.iph.daddr != 0);
 
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+
 	dst = tnl_params->daddr;
 	if (dst == 0) {
 		/* NBMA tunnel */
@@ -758,7 +760,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
 
-			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 			dst_link_failure(skb);
 		} else
 			tunnel->err_count = 0;
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 0ec0881..96599d1 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -89,6 +89,8 @@ void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb
 	uh->source = src_port;
 	uh->len = htons(skb->len);
 
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+
 	udp_set_csum(nocheck, skb, src, dst, skb->len);
 
 	iptunnel_xmit(sk, rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df, xnet);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f37f18b..c4123aa 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -777,6 +777,8 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 	__u32 mtu;
 	int err;
 
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 137fca4..6c5dfec 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1180,6 +1180,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 tproto;
 	int err;
 
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+
 	tproto = ACCESS_ONCE(t->parms.proto);
 	if (tproto != IPPROTO_IPIP && tproto != 0)
 		return -1;
-- 
2.7.1
