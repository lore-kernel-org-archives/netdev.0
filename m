From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 30/43] x_tables: Update ip?table_nat to register their hooks in all network namespaces
Date: Wed, 17 Jun 2015 10:28:39 -0500
Message-ID: <1434554932-4552-30-git-send-email-ebiederm@xmission.com>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:39966 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757492AbbFQPib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:31 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

Unlike the rest of x_tables iptables_nat and ip6tables_nat call
nf_register_hooks to register their x_tables hooks as they need to use
different priorities for different hooks.  Which resulted in
these being the last two x_tables modules that have not been
udpated to register in all network namespaces.

Therefore move the nf_register_hooks and nf_unregister_hooks calls
into the per network namespace initialization functions so the
hooks will be registered everywhere for everyone.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/netfilter/iptable_nat.c  | 30 ++++++++++++------------------
 net/ipv6/netfilter/ip6table_nat.c | 30 ++++++++++++------------------
 2 files changed, 24 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 5a1c7f2cdcbb..b97f2efcb3e3 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -102,17 +102,27 @@ static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
 static int __net_init iptable_nat_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
+	int err;
 
 	repl = ipt_alloc_initial_table(&nf_nat_ipv4_table);
 	if (repl == NULL)
 		return -ENOMEM;
 	net->ipv4.nat_table = ipt_register_table(net, &nf_nat_ipv4_table, repl);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv4.nat_table);
+	if (IS_ERR(net->ipv4.nat_table))
+		return PTR_ERR(net->ipv4.nat_table);
+
+	err = nf_register_hooks(net, nf_nat_ipv4_ops,
+				ARRAY_SIZE(nf_nat_ipv4_ops));
+	if (err)
+		ipt_unregister_table(net, net->ipv4.nat_table);
+
+	return err;
 }
 
 static void __net_exit iptable_nat_net_exit(struct net *net)
 {
+	nf_unregister_hooks(net, nf_nat_ipv4_ops, ARRAY_SIZE(nf_nat_ipv4_ops));
 	ipt_unregister_table(net, net->ipv4.nat_table);
 }
 
@@ -123,27 +133,11 @@ static struct pernet_operations iptable_nat_net_ops = {
 
 static int __init iptable_nat_init(void)
 {
-	int err;
-
-	err = register_pernet_subsys(&iptable_nat_net_ops);
-	if (err < 0)
-		goto err1;
-
-	err = nf_register_hooks(&init_net, nf_nat_ipv4_ops,
-				ARRAY_SIZE(nf_nat_ipv4_ops));
-	if (err < 0)
-		goto err2;
-	return 0;
-
-err2:
-	unregister_pernet_subsys(&iptable_nat_net_ops);
-err1:
-	return err;
+	return register_pernet_subsys(&iptable_nat_net_ops);
 }
 
 static void __exit iptable_nat_exit(void)
 {
-	nf_unregister_hooks(&init_net, nf_nat_ipv4_ops, ARRAY_SIZE(nf_nat_ipv4_ops));
 	unregister_pernet_subsys(&iptable_nat_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index ce7e99c4fd38..4066230a3a4a 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -104,17 +104,27 @@ static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
 static int __net_init ip6table_nat_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
+	int err;
 
 	repl = ip6t_alloc_initial_table(&nf_nat_ipv6_table);
 	if (repl == NULL)
 		return -ENOMEM;
 	net->ipv6.ip6table_nat = ip6t_register_table(net, &nf_nat_ipv6_table, repl);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_nat);
+	if (IS_ERR(net->ipv6.ip6table_nat))
+		return PTR_ERR(net->ipv6.ip6table_nat);
+
+	err = nf_register_hooks(net, nf_nat_ipv6_ops,
+				ARRAY_SIZE(nf_nat_ipv6_ops));
+	if (err)
+		ip6t_unregister_table(net, net->ipv6.ip6table_nat);
+
+	return err;
 }
 
 static void __net_exit ip6table_nat_net_exit(struct net *net)
 {
+	nf_unregister_hooks(net, nf_nat_ipv6_ops, ARRAY_SIZE(nf_nat_ipv6_ops));
 	ip6t_unregister_table(net, net->ipv6.ip6table_nat);
 }
 
@@ -125,27 +135,11 @@ static struct pernet_operations ip6table_nat_net_ops = {
 
 static int __init ip6table_nat_init(void)
 {
-	int err;
-
-	err = register_pernet_subsys(&ip6table_nat_net_ops);
-	if (err < 0)
-		goto err1;
-
-	err = nf_register_hooks(&init_net, nf_nat_ipv6_ops,
-				ARRAY_SIZE(nf_nat_ipv6_ops));
-	if (err < 0)
-		goto err2;
-	return 0;
-
-err2:
-	unregister_pernet_subsys(&ip6table_nat_net_ops);
-err1:
-	return err;
+	return register_pernet_subsys(&ip6table_nat_net_ops);
 }
 
 static void __exit ip6table_nat_exit(void)
 {
-	nf_unregister_hooks(&init_net, nf_nat_ipv6_ops, ARRAY_SIZE(nf_nat_ipv6_ops));
 	unregister_pernet_subsys(&ip6table_nat_net_ops);
 }
 
-- 
2.2.1
