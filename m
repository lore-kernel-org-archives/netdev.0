From: kaber@trash.net
Subject: [PATCH 1/9] netfilter: nf_nat: support user-specified SNAT rules in LOCAL_IN
Date: Fri,  2 Jul 2010 11:52:14 +0200
Message-ID: <1278064342-19059-2-git-send-email-kaber@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278064342-19059-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

2.6.34 introduced 'conntrack zones' to deal with cases where packets
from multiple identical networks are handled by conntrack/NAT. Packets
are looped through veth devices, during which they are NATed to private
addresses, after which they can continue normally through the stack
and possibly have NAT rules applied a second time.

This works well, but is needlessly complicated for cases where only
a single SNAT/DNAT mapping needs to be applied to these packets. In that
case, all that needs to be done is to assign each network to a seperate
zone and perform NAT as usual. However this doesn't work for packets
destined for the machine performing NAT itself since its corrently not
possible to configure SNAT mappings for the LOCAL_IN chain.

This patch adds a new INPUT chain to the NAT table and changes the
targets performing SNAT to be usable in that chain.

Example usage with two identical networks (192.168.0.0/24) on eth0/eth1:

iptables -t raw -A PREROUTING -i eth0 -j CT --zone 1
iptables -t raw -A PREROUTING -i eth0 -j MARK --set-mark 1
iptables -t raw -A PREROUTING -i eth1 -j CT --zone 2
iptabels -t raw -A PREROUTING -i eth1 -j MARK --set-mark 2

iptables -t nat -A INPUT       -m mark --mark 1 -j NETMAP --to 10.0.0.0/24
iptables -t nat -A POSTROUTING -m mark --mark 1 -j NETMAP --to 10.0.0.0/24
iptables -t nat -A INPUT       -m mark --mark 2 -j NETMAP --to 10.0.1.0/24
iptables -t nat -A POSTROUTING -m mark --mark 2 -j NETMAP --to 10.0.1.0/24

iptables -t raw -A PREROUTING -d 10.0.0.0/24 -j CT --zone 1
iptables -t raw -A OUTPUT     -d 10.0.0.0/24 -j CT --zone 1
iptables -t raw -A PREROUTING -d 10.0.1.0/24 -j CT --zone 2
iptables -t raw -A OUTPUT     -d 10.0.1.0/24 -j CT --zone 2

iptables -t nat -A PREROUTING -d 10.0.0.0/24 -j NETMAP --to 192.168.0.0/24
iptables -t nat -A OUTPUT     -d 10.0.0.0/24 -j NETMAP --to 192.168.0.0/24
iptables -t nat -A PREROUTING -d 10.0.1.0/24 -j NETMAP --to 192.168.0.0/24
iptables -t nat -A OUTPUT     -d 10.0.1.0/24 -j NETMAP --to 192.168.0.0/24

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_nat_rule.h    |    2 --
 net/ipv4/netfilter/ipt_NETMAP.c        |    6 ++++--
 net/ipv4/netfilter/nf_nat_rule.c       |   10 ++++++----
 net/ipv4/netfilter/nf_nat_standalone.c |    8 +-------
 4 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/net/netfilter/nf_nat_rule.h b/include/net/netfilter/nf_nat_rule.h
index e4a18ae..2890bdc 100644
--- a/include/net/netfilter/nf_nat_rule.h
+++ b/include/net/netfilter/nf_nat_rule.h
@@ -12,6 +12,4 @@ extern int nf_nat_rule_find(struct sk_buff *skb,
 			    const struct net_device *out,
 			    struct nf_conn *ct);
 
-extern unsigned int
-alloc_null_binding(struct nf_conn *ct, unsigned int hooknum);
 #endif /* _NF_NAT_RULE_H */
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index f43867d..6cdb298 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -48,7 +48,8 @@ netmap_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
 		     par->hooknum == NF_INET_POST_ROUTING ||
-		     par->hooknum == NF_INET_LOCAL_OUT);
+		     par->hooknum == NF_INET_LOCAL_OUT ||
+		     par->hooknum == NF_INET_LOCAL_IN);
 	ct = nf_ct_get(skb, &ctinfo);
 
 	netmask = ~(mr->range[0].min_ip ^ mr->range[0].max_ip);
@@ -77,7 +78,8 @@ static struct xt_target netmap_tg_reg __read_mostly = {
 	.table		= "nat",
 	.hooks		= (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING) |
-			  (1 << NF_INET_LOCAL_OUT),
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_LOCAL_IN),
 	.checkentry 	= netmap_tg_check,
 	.me 		= THIS_MODULE
 };
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 98ed782..ebbd319 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -28,7 +28,8 @@
 
 #define NAT_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | \
 			 (1 << NF_INET_POST_ROUTING) | \
-			 (1 << NF_INET_LOCAL_OUT))
+			 (1 << NF_INET_LOCAL_OUT) | \
+			 (1 << NF_INET_LOCAL_IN))
 
 static const struct xt_table nat_table = {
 	.name		= "nat",
@@ -45,7 +46,8 @@ ipt_snat_target(struct sk_buff *skb, const struct xt_action_param *par)
 	enum ip_conntrack_info ctinfo;
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
-	NF_CT_ASSERT(par->hooknum == NF_INET_POST_ROUTING);
+	NF_CT_ASSERT(par->hooknum == NF_INET_POST_ROUTING ||
+		     par->hooknum == NF_INET_LOCAL_IN);
 
 	ct = nf_ct_get(skb, &ctinfo);
 
@@ -99,7 +101,7 @@ static int ipt_dnat_checkentry(const struct xt_tgchk_param *par)
 	return 0;
 }
 
-unsigned int
+static unsigned int
 alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
 {
 	/* Force range to this IP; let proto decide mapping for
@@ -141,7 +143,7 @@ static struct xt_target ipt_snat_reg __read_mostly = {
 	.target		= ipt_snat_target,
 	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= 1 << NF_INET_POST_ROUTING,
+	.hooks		= (1 << NF_INET_POST_ROUTING) | (1 << NF_INET_LOCAL_IN),
 	.checkentry	= ipt_snat_checkentry,
 	.family		= AF_INET,
 };
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 6723c68..95481fe 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -131,13 +131,7 @@ nf_nat_fn(unsigned int hooknum,
 		if (!nf_nat_initialized(ct, maniptype)) {
 			unsigned int ret;
 
-			if (hooknum == NF_INET_LOCAL_IN)
-				/* LOCAL_IN hook doesn't have a chain!  */
-				ret = alloc_null_binding(ct, hooknum);
-			else
-				ret = nf_nat_rule_find(skb, hooknum, in, out,
-						       ct);
-
+			ret = nf_nat_rule_find(skb, hooknum, in, out, ct);
 			if (ret != NF_ACCEPT)
 				return ret;
 		} else
-- 
1.7.0.4

