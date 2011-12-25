From: pablo@netfilter.org
Subject: [PATCH 13/19] netfilter: nat: remove module reference counting from NAT protocols
Date: Sun, 25 Dec 2011 02:57:29 +0100
Message-ID: <1324778255-2830-14-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The only remaining user of NAT protocol module reference counting is NAT
ctnetlink support. Since this is a fairly short sequence of code, convert
over to use RCU and remove module reference counting.

Module unregistration is already protected by RCU using synchronize_rcu(),
so no further changes are necessary.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat_protocol.h   |    2 --
 net/ipv4/netfilter/nf_nat_core.c          |   25 +++----------------------
 net/ipv4/netfilter/nf_nat_proto_dccp.c    |    1 -
 net/ipv4/netfilter/nf_nat_proto_gre.c     |    1 -
 net/ipv4/netfilter/nf_nat_proto_icmp.c    |    1 -
 net/ipv4/netfilter/nf_nat_proto_sctp.c    |    1 -
 net/ipv4/netfilter/nf_nat_proto_tcp.c     |    1 -
 net/ipv4/netfilter/nf_nat_proto_udp.c     |    1 -
 net/ipv4/netfilter/nf_nat_proto_udplite.c |    1 -
 net/ipv4/netfilter/nf_nat_proto_unknown.c |    1 -
 10 files changed, 3 insertions(+), 32 deletions(-)

diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netfilter/nf_nat_protocol.h
index 7156c00..eaad0ac 100644
--- a/include/net/netfilter/nf_nat_protocol.h
+++ b/include/net/netfilter/nf_nat_protocol.h
@@ -10,8 +10,6 @@ struct nf_nat_protocol {
 	/* Protocol number. */
 	unsigned int protonum;
 
-	struct module *me;
-
 	/* Translate a packet to the target according to manip type.
 	   Return true if succeeded. */
 	bool (*manip_pkt)(struct sk_buff *skb,
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 610eb44..5e1bd85 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -575,26 +575,6 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
 
-static const struct nf_nat_protocol *
-nf_nat_proto_find_get(u_int8_t protonum)
-{
-	const struct nf_nat_protocol *p;
-
-	rcu_read_lock();
-	p = __nf_nat_proto_find(protonum);
-	if (!try_module_get(p->me))
-		p = &nf_nat_unknown_protocol;
-	rcu_read_unlock();
-
-	return p;
-}
-
-static void
-nf_nat_proto_put(const struct nf_nat_protocol *p)
-{
-	module_put(p->me);
-}
-
 static const struct nla_policy protonat_nla_policy[CTA_PROTONAT_MAX+1] = {
 	[CTA_PROTONAT_PORT_MIN]	= { .type = NLA_U16 },
 	[CTA_PROTONAT_PORT_MAX]	= { .type = NLA_U16 },
@@ -612,10 +592,11 @@ static int nfnetlink_parse_nat_proto(struct nlattr *attr,
 	if (err < 0)
 		return err;
 
-	npt = nf_nat_proto_find_get(nf_ct_protonum(ct));
+	rcu_read_lock();
+	npt = __nf_nat_proto_find(nf_ct_protonum(ct));
 	if (npt->nlattr_to_range)
 		err = npt->nlattr_to_range(tb, range);
-	nf_nat_proto_put(npt);
+	rcu_read_unlock();
 	return err;
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_proto_dccp.c b/net/ipv4/netfilter/nf_nat_proto_dccp.c
index c43d5b3..466d63d 100644
--- a/net/ipv4/netfilter/nf_nat_proto_dccp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_dccp.c
@@ -80,7 +80,6 @@ dccp_manip_pkt(struct sk_buff *skb,
 
 static const struct nf_nat_protocol nf_nat_protocol_dccp = {
 	.protonum		= IPPROTO_DCCP,
-	.me			= THIS_MODULE,
 	.manip_pkt		= dccp_manip_pkt,
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= dccp_unique_tuple,
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index 9b1c629..35cd158 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -119,7 +119,6 @@ gre_manip_pkt(struct sk_buff *skb, unsigned int iphdroff,
 
 static const struct nf_nat_protocol gre = {
 	.protonum		= IPPROTO_GRE,
-	.me			= THIS_MODULE,
 	.manip_pkt		= gre_manip_pkt,
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= gre_unique_tuple,
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 8f87b4b..036c009 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -74,7 +74,6 @@ icmp_manip_pkt(struct sk_buff *skb,
 
 const struct nf_nat_protocol nf_nat_protocol_icmp = {
 	.protonum		= IPPROTO_ICMP,
-	.me			= THIS_MODULE,
 	.manip_pkt		= icmp_manip_pkt,
 	.in_range		= icmp_in_range,
 	.unique_tuple		= icmp_unique_tuple,
diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/ipv4/netfilter/nf_nat_proto_sctp.c
index 4e70dc6..50283ab 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
@@ -70,7 +70,6 @@ sctp_manip_pkt(struct sk_buff *skb,
 
 static const struct nf_nat_protocol nf_nat_protocol_sctp = {
 	.protonum		= IPPROTO_SCTP,
-	.me			= THIS_MODULE,
 	.manip_pkt		= sctp_manip_pkt,
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= sctp_unique_tuple,
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/ipv4/netfilter/nf_nat_proto_tcp.c
index 6fcc865..e0e2ba8 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_tcp.c
@@ -82,7 +82,6 @@ tcp_manip_pkt(struct sk_buff *skb,
 
 const struct nf_nat_protocol nf_nat_protocol_tcp = {
 	.protonum		= IPPROTO_TCP,
-	.me			= THIS_MODULE,
 	.manip_pkt		= tcp_manip_pkt,
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= tcp_unique_tuple,
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/ipv4/netfilter/nf_nat_proto_udp.c
index 18ea44e..bde94cd 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udp.c
@@ -73,7 +73,6 @@ udp_manip_pkt(struct sk_buff *skb,
 
 const struct nf_nat_protocol nf_nat_protocol_udp = {
 	.protonum		= IPPROTO_UDP,
-	.me			= THIS_MODULE,
 	.manip_pkt		= udp_manip_pkt,
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= udp_unique_tuple,
diff --git a/net/ipv4/netfilter/nf_nat_proto_udplite.c b/net/ipv4/netfilter/nf_nat_proto_udplite.c
index a17b75b..58e9a3a 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udplite.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udplite.c
@@ -72,7 +72,6 @@ udplite_manip_pkt(struct sk_buff *skb,
 
 static const struct nf_nat_protocol nf_nat_protocol_udplite = {
 	.protonum		= IPPROTO_UDPLITE,
-	.me			= THIS_MODULE,
 	.manip_pkt		= udplite_manip_pkt,
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= udplite_unique_tuple,
diff --git a/net/ipv4/netfilter/nf_nat_proto_unknown.c b/net/ipv4/netfilter/nf_nat_proto_unknown.c
index ab8e8c1..e0afe81 100644
--- a/net/ipv4/netfilter/nf_nat_proto_unknown.c
+++ b/net/ipv4/netfilter/nf_nat_proto_unknown.c
@@ -46,7 +46,6 @@ unknown_manip_pkt(struct sk_buff *skb,
 }
 
 const struct nf_nat_protocol nf_nat_unknown_protocol = {
-	/* .me isn't set: getting a ref to this cannot fail. */
 	.manip_pkt		= unknown_manip_pkt,
 	.in_range		= unknown_in_range,
 	.unique_tuple		= unknown_unique_tuple,
-- 
1.7.2.5

