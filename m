From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 37/43] netfilter: nf_defrag: Register netfilter hooks in all network namespaces
Date: Wed, 17 Jun 2015 10:28:46 -0500
Message-ID: <1434554932-4552-37-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40969 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602AbbFQPi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:26 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c       | 21 ++++++++++++++++++---
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c | 21 ++++++++++++++++++---
 2 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index e9f4088d4759..8d5a45ddf9b5 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -109,15 +109,30 @@ static struct nf_hook_ops ipv4_defrag_ops[] = {
 	},
 };
 
-static int __init nf_defrag_init(void)
+static int __net_init nf_defrag_net_init(struct net *net)
 {
-	return nf_register_hooks(&init_net, ipv4_defrag_ops,
+	return nf_register_hooks(net, ipv4_defrag_ops,
 				 ARRAY_SIZE(ipv4_defrag_ops));
 }
 
+static void __net_exit nf_defrag_net_exit(struct net *net)
+{
+	nf_unregister_hooks(net, ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+}
+
+static struct pernet_operations nf_defrag_net_ops = {
+	.init = nf_defrag_net_init,
+	.exit = nf_defrag_net_exit,
+};
+
+static int __init nf_defrag_init(void)
+{
+	return register_pernet_subsys(&nf_defrag_net_ops);
+}
+
 static void __exit nf_defrag_fini(void)
 {
-	nf_unregister_hooks(&init_net, ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+	unregister_pernet_subsys(&nf_defrag_net_ops);
 }
 
 void nf_defrag_ipv4_enable(void)
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 2bd7aa696382..a20d461fbd89 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -100,6 +100,22 @@ static struct nf_hook_ops ipv6_defrag_ops[] = {
 	},
 };
 
+static int __net_init nf_defrag_net_init(struct net *net)
+{
+	return nf_register_hooks(net, ipv6_defrag_ops,
+				 ARRAY_SIZE(ipv6_defrag_ops));
+}
+
+static void __net_exit nf_defrag_net_exit(struct net *net)
+{
+	nf_unregister_hooks(net, ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+}
+
+static struct pernet_operations nf_defrag_net_ops = {
+	.init = nf_defrag_net_init,
+	.exit = nf_defrag_net_exit,
+};
+
 static int __init nf_defrag_init(void)
 {
 	int ret = 0;
@@ -109,8 +125,7 @@ static int __init nf_defrag_init(void)
 		pr_err("nf_defrag_ipv6: can't initialize frag6.\n");
 		return ret;
 	}
-	ret = nf_register_hooks(&init_net, ipv6_defrag_ops,
-				ARRAY_SIZE(ipv6_defrag_ops));
+	ret = register_pernet_subsys(&nf_defrag_net_ops);
 	if (ret < 0) {
 		pr_err("nf_defrag_ipv6: can't register hooks\n");
 		goto cleanup_frag6;
@@ -125,7 +140,7 @@ cleanup_frag6:
 
 static void __exit nf_defrag_fini(void)
 {
-	nf_unregister_hooks(&init_net, ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	unregister_pernet_subsys(&nf_defrag_net_ops);
 	nf_ct_frag6_cleanup();
 }
 
-- 
2.2.1
