From: kaber@trash.net
Subject: [PATCH 6/8] netfilter: af_info: add 'strict' parameter to limit lookup to .oif
Date: Tue,  5 Apr 2011 15:04:17 +0200
Message-ID: <1302008659-21141-7-git-send-email-kaber@trash.net>
References: <1302008659-21141-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1302008659-21141-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

ipv6 fib lookup can set RT6_LOOKUP_F_IFACE flag to restrict search
to an interface, but this flag cannot be set via struct flowi.

Also, it cannot be set via ip6_route_output: this function uses the
passed sock struct to determine if this flag is required
(by testing for nonzero sk_bound_dev_if).

Work around this by passing in an artificial struct sk in case
'strict' argument is true.

This is required to replace the rt6_lookup call in xt_addrtype.c with
nf_afinfo->route().

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter.h              |    2 +-
 net/ipv4/netfilter.c                   |    2 +-
 net/ipv6/netfilter.c                   |   12 ++++++++++--
 net/netfilter/nf_conntrack_h323_main.c |    8 ++++----
 net/netfilter/xt_TCPMSS.c              |    2 +-
 5 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 20ed452..7fa95df 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -271,7 +271,7 @@ struct nf_afinfo {
 					    unsigned int len,
 					    u_int8_t protocol);
 	int		(*route)(struct net *net, struct dst_entry **dst,
-				 struct flowi *fl);
+				 struct flowi *fl, bool strict);
 	void		(*saveroute)(const struct sk_buff *skb,
 				     struct nf_queue_entry *entry);
 	int		(*reroute)(struct sk_buff *skb,
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index f1035f0..4614bab 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -222,7 +222,7 @@ static __sum16 nf_ip_checksum_partial(struct sk_buff *skb, unsigned int hook,
 }
 
 static int nf_ip_route(struct net *net, struct dst_entry **dst,
-		       struct flowi *fl)
+		       struct flowi *fl, bool strict __always_unused)
 {
 	struct rtable *rt = ip_route_output_key(net, &fl->u.ip4);
 	if (IS_ERR(rt))
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index e008b9b..28bc1f6 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -91,9 +91,17 @@ static int nf_ip6_reroute(struct sk_buff *skb,
 }
 
 static int nf_ip6_route(struct net *net, struct dst_entry **dst,
-			struct flowi *fl)
+			struct flowi *fl, bool strict)
 {
-	*dst = ip6_route_output(net, NULL, &fl->u.ip6);
+	static const struct ipv6_pinfo fake_pinfo;
+	static const struct inet_sock fake_sk = {
+		/* makes ip6_route_output set RT6_LOOKUP_F_IFACE: */
+		.sk.sk_bound_dev_if = 1,
+		.pinet6 = (struct ipv6_pinfo *) &fake_pinfo,
+	};
+	const void *sk = strict ? &fake_sk : NULL;
+
+	*dst = ip6_route_output(net, sk, &fl->u.ip6);
 	return (*dst)->error;
 }
 
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 39a4538..18b2ce5 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -732,9 +732,9 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 		memset(&fl2, 0, sizeof(fl2));
 		fl2.daddr = dst->ip;
 		if (!afinfo->route(&init_net, (struct dst_entry **)&rt1,
-				   flowi4_to_flowi(&fl1))) {
+				   flowi4_to_flowi(&fl1), false)) {
 			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
-					   flowi4_to_flowi(&fl2))) {
+					   flowi4_to_flowi(&fl2), false)) {
 				if (rt1->rt_gateway == rt2->rt_gateway &&
 				    rt1->dst.dev  == rt2->dst.dev)
 					ret = 1;
@@ -756,9 +756,9 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 		memset(&fl2, 0, sizeof(fl2));
 		ipv6_addr_copy(&fl2.daddr, &dst->in6);
 		if (!afinfo->route(&init_net, (struct dst_entry **)&rt1,
-				   flowi6_to_flowi(&fl1))) {
+				   flowi6_to_flowi(&fl1), false)) {
 			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
-					   flowi6_to_flowi(&fl2))) {
+					   flowi6_to_flowi(&fl2), false)) {
 				if (!memcmp(&rt1->rt6i_gateway, &rt2->rt6i_gateway,
 					    sizeof(rt1->rt6i_gateway)) &&
 				    rt1->dst.dev == rt2->dst.dev)
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 8690125..9e63b43 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -166,7 +166,7 @@ static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
 	rcu_read_lock();
 	ai = nf_get_afinfo(family);
 	if (ai != NULL)
-		ai->route(&init_net, (struct dst_entry **)&rt, &fl);
+		ai->route(&init_net, (struct dst_entry **)&rt, &fl, false);
 	rcu_read_unlock();
 
 	if (rt != NULL) {
-- 
1.7.2.3

