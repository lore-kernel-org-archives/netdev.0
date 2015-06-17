From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 38/43] netfilter: synproxy: Register netfilter hooks in all network namespaces
Date: Wed, 17 Jun 2015 10:28:47 -0500
Message-ID: <1434554932-4552-38-git-send-email-ebiederm@xmission.com>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:41017 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757416AbbFQPi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:27 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

Inspired-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  | 24 ++++++++++++++++++++----
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 24 ++++++++++++++++++++----
 2 files changed, 40 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 301bb886a289..cb84e4e24175 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -446,12 +446,28 @@ static struct nf_hook_ops ipv4_synproxy_ops[] __read_mostly = {
 	},
 };
 
+static int synproxy_tg4_net_init(struct net *net)
+{
+	return nf_register_hooks(net, ipv4_synproxy_ops,
+				 ARRAY_SIZE(ipv4_synproxy_ops));
+}
+
+static void synproxy_tg4_net_exit(struct net *net)
+{
+	nf_unregister_hooks(net, ipv4_synproxy_ops,
+			    ARRAY_SIZE(ipv4_synproxy_ops));
+}
+
+static struct pernet_operations synproxy_tg4_net_ops = {
+	.init = synproxy_tg4_net_init,
+	.exit = synproxy_tg4_net_exit,
+};
+
 static int __init synproxy_tg4_init(void)
 {
 	int err;
 
-	err = nf_register_hooks(&init_net, ipv4_synproxy_ops,
-				ARRAY_SIZE(ipv4_synproxy_ops));
+	err = register_pernet_subsys(&synproxy_tg4_net_ops);
 	if (err < 0)
 		goto err1;
 
@@ -462,7 +478,7 @@ static int __init synproxy_tg4_init(void)
 	return 0;
 
 err2:
-	nf_unregister_hooks(&init_net, ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
+	unregister_pernet_subsys(&synproxy_tg4_net_ops);
 err1:
 	return err;
 }
@@ -470,7 +486,7 @@ err1:
 static void __exit synproxy_tg4_exit(void)
 {
 	xt_unregister_target(&synproxy_tg4_reg);
-	nf_unregister_hooks(&init_net, ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
+	unregister_pernet_subsys(&synproxy_tg4_net_ops);
 }
 
 module_init(synproxy_tg4_init);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 320521086b5c..0acc786fd3f0 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -469,12 +469,28 @@ static struct nf_hook_ops ipv6_synproxy_ops[] __read_mostly = {
 	},
 };
 
+static int synproxy_tg6_net_init(struct net *net)
+{
+	return nf_register_hooks(net, ipv6_synproxy_ops,
+				 ARRAY_SIZE(ipv6_synproxy_ops));
+}
+
+static void synproxy_tg6_net_exit(struct net *net)
+{
+	nf_unregister_hooks(net, ipv6_synproxy_ops,
+			    ARRAY_SIZE(ipv6_synproxy_ops));
+}
+
+static struct pernet_operations synproxy_tg6_net_ops = {
+	.init = synproxy_tg6_net_init,
+	.exit = synproxy_tg6_net_exit,
+};
+
 static int __init synproxy_tg6_init(void)
 {
 	int err;
 
-	err = nf_register_hooks(&init_net, ipv6_synproxy_ops,
-				ARRAY_SIZE(ipv6_synproxy_ops));
+	err = register_pernet_subsys(&synproxy_tg6_net_ops);
 	if (err < 0)
 		goto err1;
 
@@ -485,7 +501,7 @@ static int __init synproxy_tg6_init(void)
 	return 0;
 
 err2:
-	nf_unregister_hooks(&init_net, ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
+	unregister_pernet_subsys(&synproxy_tg6_net_ops);
 err1:
 	return err;
 }
@@ -493,7 +509,7 @@ err1:
 static void __exit synproxy_tg6_exit(void)
 {
 	xt_unregister_target(&synproxy_tg6_reg);
-	nf_unregister_hooks(&init_net, ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
+	unregister_pernet_subsys(&synproxy_tg6_net_ops);
 }
 
 module_init(synproxy_tg6_init);
-- 
2.2.1
