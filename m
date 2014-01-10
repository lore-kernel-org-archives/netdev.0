From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/23] netfilter: nf_tables: make chain types override the default AF functions
Date: Fri, 10 Jan 2014 01:35:21 +0100
Message-ID: <1389314142-17969-3-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51505 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756834AbaAJAgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:02 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Currently the AF-specific hook functions override the chain-type specific
hook functions. That doesn't make too much sense since the chain types
are a special case of the AF-specific hooks.

Make the AF-specific hook functions the default and make the optional
chain type hooks override them.

As a side effect, the necessary code restructuring reduces the code size,
f.i. in case of nf_tables_ipv4.o:

  nf_tables_ipv4_init_net   |  -24
  nft_do_chain_ipv4         | -113
 2 functions changed, 137 bytes removed, diff: -137

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nf_tables_bridge.c |   38 ++++++++++++------------
 net/ipv4/netfilter/nf_tables_arp.c      |   38 ++++++++++++------------
 net/ipv4/netfilter/nf_tables_ipv4.c     |   43 ++++++++++++---------------
 net/ipv6/netfilter/nf_tables_ipv6.c     |   48 +++++++++++++------------------
 net/netfilter/nf_tables_api.c           |   10 +++----
 5 files changed, 81 insertions(+), 96 deletions(-)

diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index cf54b22..c5fdd9a 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -14,10 +14,29 @@
 #include <linux/netfilter_bridge.h>
 #include <net/netfilter/nf_tables.h>
 
+static unsigned int
+nft_do_chain_bridge(const struct nf_hook_ops *ops,
+		    struct sk_buff *skb,
+		    const struct net_device *in,
+		    const struct net_device *out,
+		    int (*okfn)(struct sk_buff *))
+{
+	struct nft_pktinfo pkt;
+
+	nft_set_pktinfo(&pkt, ops, skb, in, out);
+
+	return nft_do_chain_pktinfo(&pkt, ops);
+}
+
 static struct nft_af_info nft_af_bridge __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.nhooks		= NF_BR_NUMHOOKS,
 	.owner		= THIS_MODULE,
+	.hooks		= {
+		[NF_BR_LOCAL_IN]	= nft_do_chain_bridge,
+		[NF_BR_FORWARD]		= nft_do_chain_bridge,
+		[NF_BR_LOCAL_OUT]	= nft_do_chain_bridge,
+	},
 };
 
 static int nf_tables_bridge_init_net(struct net *net)
@@ -48,20 +67,6 @@ static struct pernet_operations nf_tables_bridge_net_ops = {
 	.exit	= nf_tables_bridge_exit_net,
 };
 
-static unsigned int
-nft_do_chain_bridge(const struct nf_hook_ops *ops,
-		    struct sk_buff *skb,
-		    const struct net_device *in,
-		    const struct net_device *out,
-		    int (*okfn)(struct sk_buff *))
-{
-	struct nft_pktinfo pkt;
-
-	nft_set_pktinfo(&pkt, ops, skb, in, out);
-
-	return nft_do_chain_pktinfo(&pkt, ops);
-}
-
 static struct nf_chain_type filter_bridge = {
 	.family		= NFPROTO_BRIDGE,
 	.name		= "filter",
@@ -69,11 +74,6 @@ static struct nf_chain_type filter_bridge = {
 	.hook_mask	= (1 << NF_BR_LOCAL_IN) |
 			  (1 << NF_BR_FORWARD) |
 			  (1 << NF_BR_LOCAL_OUT),
-	.fn		= {
-		[NF_BR_LOCAL_IN]	= nft_do_chain_bridge,
-		[NF_BR_FORWARD]		= nft_do_chain_bridge,
-		[NF_BR_LOCAL_OUT]	= nft_do_chain_bridge,
-	},
 };
 
 static int __init nf_tables_bridge_init(void)
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 3e67ef1..31bb778 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -14,10 +14,29 @@
 #include <linux/netfilter_arp.h>
 #include <net/netfilter/nf_tables.h>
 
+static unsigned int
+nft_do_chain_arp(const struct nf_hook_ops *ops,
+		  struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sk_buff *))
+{
+	struct nft_pktinfo pkt;
+
+	nft_set_pktinfo(&pkt, ops, skb, in, out);
+
+	return nft_do_chain_pktinfo(&pkt, ops);
+}
+
 static struct nft_af_info nft_af_arp __read_mostly = {
 	.family		= NFPROTO_ARP,
 	.nhooks		= NF_ARP_NUMHOOKS,
 	.owner		= THIS_MODULE,
+	.hooks		= {
+		[NF_ARP_IN]		= nft_do_chain_arp,
+		[NF_ARP_OUT]		= nft_do_chain_arp,
+		[NF_ARP_FORWARD]	= nft_do_chain_arp,
+	},
 };
 
 static int nf_tables_arp_init_net(struct net *net)
@@ -48,20 +67,6 @@ static struct pernet_operations nf_tables_arp_net_ops = {
 	.exit   = nf_tables_arp_exit_net,
 };
 
-static unsigned int
-nft_do_chain_arp(const struct nf_hook_ops *ops,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
-{
-	struct nft_pktinfo pkt;
-
-	nft_set_pktinfo(&pkt, ops, skb, in, out);
-
-	return nft_do_chain_pktinfo(&pkt, ops);
-}
-
 static struct nf_chain_type filter_arp = {
 	.family		= NFPROTO_ARP,
 	.name		= "filter",
@@ -69,11 +74,6 @@ static struct nf_chain_type filter_arp = {
 	.hook_mask	= (1 << NF_ARP_IN) |
 			  (1 << NF_ARP_OUT) |
 			  (1 << NF_ARP_FORWARD),
-	.fn		= {
-		[NF_ARP_IN]		= nft_do_chain_arp,
-		[NF_ARP_OUT]		= nft_do_chain_arp,
-		[NF_ARP_FORWARD]	= nft_do_chain_arp,
-	},
 };
 
 static int __init nf_tables_arp_init(void)
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 0f4cbfe..ed7e15a 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -18,14 +18,25 @@
 #include <net/ip.h>
 #include <net/netfilter/nf_tables_ipv4.h>
 
+static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
+				      struct sk_buff *skb,
+				      const struct net_device *in,
+				      const struct net_device *out,
+				      int (*okfn)(struct sk_buff *))
+{
+	struct nft_pktinfo pkt;
+
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+
+	return nft_do_chain_pktinfo(&pkt, ops);
+}
+
 static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct net_device *in,
 				    const struct net_device *out,
 				    int (*okfn)(struct sk_buff *))
 {
-	struct nft_pktinfo pkt;
-
 	if (unlikely(skb->len < sizeof(struct iphdr) ||
 		     ip_hdr(skb)->ihl < sizeof(struct iphdr) / 4)) {
 		if (net_ratelimit())
@@ -33,9 +44,8 @@ static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 				"packet\n");
 		return NF_ACCEPT;
 	}
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
 
-	return nft_do_chain_pktinfo(&pkt, ops);
+	return nft_do_chain_ipv4(ops, skb, in, out, okfn);
 }
 
 static struct nft_af_info nft_af_ipv4 __read_mostly = {
@@ -43,7 +53,11 @@ static struct nft_af_info nft_af_ipv4 __read_mostly = {
 	.nhooks		= NF_INET_NUMHOOKS,
 	.owner		= THIS_MODULE,
 	.hooks		= {
+		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv4,
 		[NF_INET_LOCAL_OUT]	= nft_ipv4_output,
+		[NF_INET_FORWARD]	= nft_do_chain_ipv4,
+		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv4,
+		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv4,
 	},
 };
 
@@ -75,20 +89,6 @@ static struct pernet_operations nf_tables_ipv4_net_ops = {
 	.exit	= nf_tables_ipv4_exit_net,
 };
 
-static unsigned int
-nft_do_chain_ipv4(const struct nf_hook_ops *ops,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
-{
-	struct nft_pktinfo pkt;
-
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
-
-	return nft_do_chain_pktinfo(&pkt, ops);
-}
-
 static struct nf_chain_type filter_ipv4 = {
 	.family		= NFPROTO_IPV4,
 	.name		= "filter",
@@ -98,13 +98,6 @@ static struct nf_chain_type filter_ipv4 = {
 			  (1 << NF_INET_FORWARD) |
 			  (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING),
-	.fn		= {
-		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv4,
-		[NF_INET_LOCAL_OUT]	= nft_ipv4_output,
-		[NF_INET_FORWARD]	= nft_do_chain_ipv4,
-		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv4,
-		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv4,
-	},
 };
 
 static int __init nf_tables_ipv4_init(void)
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index d77db8a..54a2bcd 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -16,24 +16,35 @@
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables_ipv6.h>
 
+static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
+				      struct sk_buff *skb,
+				      const struct net_device *in,
+				      const struct net_device *out,
+				      int (*okfn)(struct sk_buff *))
+{
+	struct nft_pktinfo pkt;
+
+	/* malformed packet, drop it */
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
+		return NF_DROP;
+
+	return nft_do_chain_pktinfo(&pkt, ops);
+}
+
 static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct net_device *in,
 				    const struct net_device *out,
 				    int (*okfn)(struct sk_buff *))
 {
-	struct nft_pktinfo pkt;
-
 	if (unlikely(skb->len < sizeof(struct ipv6hdr))) {
 		if (net_ratelimit())
 			pr_info("nf_tables_ipv6: ignoring short SOCK_RAW "
 				"packet\n");
 		return NF_ACCEPT;
 	}
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
-		return NF_DROP;
 
-	return nft_do_chain_pktinfo(&pkt, ops);
+	return nft_do_chain_ipv6(ops, skb, in, out, okfn);
 }
 
 static struct nft_af_info nft_af_ipv6 __read_mostly = {
@@ -41,7 +52,11 @@ static struct nft_af_info nft_af_ipv6 __read_mostly = {
 	.nhooks		= NF_INET_NUMHOOKS,
 	.owner		= THIS_MODULE,
 	.hooks		= {
+		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv6,
 		[NF_INET_LOCAL_OUT]	= nft_ipv6_output,
+		[NF_INET_FORWARD]	= nft_do_chain_ipv6,
+		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv6,
+		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv6,
 	},
 };
 
@@ -73,22 +88,6 @@ static struct pernet_operations nf_tables_ipv6_net_ops = {
 	.exit	= nf_tables_ipv6_exit_net,
 };
 
-static unsigned int
-nft_do_chain_ipv6(const struct nf_hook_ops *ops,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
-{
-	struct nft_pktinfo pkt;
-
-	/* malformed packet, drop it */
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
-		return NF_DROP;
-
-	return nft_do_chain_pktinfo(&pkt, ops);
-}
-
 static struct nf_chain_type filter_ipv6 = {
 	.family		= NFPROTO_IPV6,
 	.name		= "filter",
@@ -98,13 +97,6 @@ static struct nf_chain_type filter_ipv6 = {
 			  (1 << NF_INET_FORWARD) |
 			  (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING),
-	.fn		= {
-		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv6,
-		[NF_INET_LOCAL_OUT]	= nft_ipv6_output,
-		[NF_INET_FORWARD]	= nft_do_chain_ipv6,
-		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv6,
-		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv6,
-	},
 };
 
 static int __init nf_tables_ipv6_init(void)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 1fcef1e..d568626 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -927,9 +927,9 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		if (hooknum >= afi->nhooks)
 			return -EINVAL;
 
-		hookfn = chain_type[family][type]->fn[hooknum];
-		if (hookfn == NULL)
+		if (!(chain_type[family][type]->hook_mask & (1 << hooknum)))
 			return -EOPNOTSUPP;
+		hookfn = chain_type[family][type]->fn[hooknum];
 
 		basechain = kzalloc(sizeof(*basechain), GFP_KERNEL);
 		if (basechain == NULL)
@@ -944,9 +944,9 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		ops->hooknum	= ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM]));
 		ops->priority	= ntohl(nla_get_be32(ha[NFTA_HOOK_PRIORITY]));
 		ops->priv	= chain;
-		ops->hook       = hookfn;
-		if (afi->hooks[ops->hooknum])
-			ops->hook = afi->hooks[ops->hooknum];
+		ops->hook	= afi->hooks[ops->hooknum];
+		if (hookfn)
+			ops->hook = hookfn;
 
 		chain->flags |= NFT_BASE_CHAIN;
 
-- 
1.7.10.4
