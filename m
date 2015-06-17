From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 33/43] netfilter: ebtables: adapt the filter and nat table to pernet hooks
Date: Wed, 17 Jun 2015 10:28:42 -0500
Message-ID: <1434554932-4552-33-git-send-email-ebiederm@xmission.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This adapts the filter and nat tables to register the hooks for each
netnamespace.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 net/bridge/netfilter/ebtable_filter.c | 25 +++++++++++++------------
 net/bridge/netfilter/ebtable_nat.c    | 24 ++++++++++++------------
 2 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index a3dc249945ec..514273f949c0 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -96,12 +96,23 @@ static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 
 static int __net_init frame_filter_net_init(struct net *net)
 {
+	int ret;
+
 	net->xt.frame_filter = ebt_register_table(net, &frame_filter);
-	return PTR_ERR_OR_ZERO(net->xt.frame_filter);
+	if (IS_ERR(net->xt.frame_filter))
+		return PTR_ERR(net->xt.frame_filter);
+
+	ret = nf_register_hooks(net, ebt_ops_filter,
+				ARRAY_SIZE(ebt_ops_filter));
+	if (ret < 0)
+		ebt_unregister_table(net, net->xt.frame_filter);
+
+	return ret;
 }
 
 static void __net_exit frame_filter_net_exit(struct net *net)
 {
+	nf_unregister_hooks(net, ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	ebt_unregister_table(net, net->xt.frame_filter);
 }
 
@@ -112,21 +123,11 @@ static struct pernet_operations frame_filter_net_ops = {
 
 static int __init ebtable_filter_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&frame_filter_net_ops);
-	if (ret < 0)
-		return ret;
-	ret = nf_register_hooks(&init_net, ebt_ops_filter,
-				ARRAY_SIZE(ebt_ops_filter));
-	if (ret < 0)
-		unregister_pernet_subsys(&frame_filter_net_ops);
-	return ret;
+	return register_pernet_subsys(&frame_filter_net_ops);
 }
 
 static void __exit ebtable_filter_fini(void)
 {
-	nf_unregister_hooks(&init_net, ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	unregister_pernet_subsys(&frame_filter_net_ops);
 }
 
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 11bf447f8b46..2dcd19c7d078 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -96,12 +96,22 @@ static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 
 static int __net_init frame_nat_net_init(struct net *net)
 {
+	int ret;
+
 	net->xt.frame_nat = ebt_register_table(net, &frame_nat);
-	return PTR_ERR_OR_ZERO(net->xt.frame_nat);
+	if (IS_ERR(net->xt.frame_nat))
+		return PTR_ERR(net->xt.frame_nat);
+
+	ret = nf_register_hooks(net, ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
+	if (ret < 0)
+		ebt_unregister_table(net, net->xt.frame_nat);
+
+	return ret;
 }
 
 static void __net_exit frame_nat_net_exit(struct net *net)
 {
+	nf_unregister_hooks(net, ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
 	ebt_unregister_table(net, net->xt.frame_nat);
 }
 
@@ -112,21 +122,11 @@ static struct pernet_operations frame_nat_net_ops = {
 
 static int __init ebtable_nat_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&frame_nat_net_ops);
-	if (ret < 0)
-		return ret;
-	ret = nf_register_hooks(&init_net, ebt_ops_nat,
-				ARRAY_SIZE(ebt_ops_nat));
-	if (ret < 0)
-		unregister_pernet_subsys(&frame_nat_net_ops);
-	return ret;
+	return register_pernet_subsys(&frame_nat_net_ops);
 }
 
 static void __exit ebtable_nat_fini(void)
 {
-	nf_unregister_hooks(&init_net, ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
 	unregister_pernet_subsys(&frame_nat_net_ops);
 }
 
-- 
2.2.1

