From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 34/43] netfilter: bridge: adapt it to pernet hooks
Date: Wed, 17 Jun 2015 10:28:43 -0500
Message-ID: <1434554932-4552-34-git-send-email-ebiederm@xmission.com>
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

From: Eric W Biederman <ebiederm@xmission.com>

Since pernet hooks, we need to register the hook for each netnamespace space.

Based on a patch by Pablo Neira Ayuso <pablo@netfilter.org> that was
buggy and did a lot more.

Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 net/bridge/br_netfilter.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 15d0f3b78145..c6acff3a94ec 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1246,11 +1246,26 @@ static struct ctl_table brnf_table[] = {
 };
 #endif
 
+static int __net_init br_nf_net_init(struct net *net)
+{
+	return nf_register_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+}
+
+static void __net_exit br_nf_net_exit(struct net *net)
+{
+	nf_unregister_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+}
+
+static struct pernet_operations br_nf_net_ops = {
+	.init = br_nf_net_init,
+	.exit = br_nf_net_exit,
+};
+
 static int __init br_netfilter_init(void)
 {
 	int ret;
 
-	ret = nf_register_hooks(&init_net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	ret = register_pernet_subsys(&br_nf_net_ops);
 	if (ret < 0)
 		return ret;
 
@@ -1271,7 +1286,6 @@ static int __init br_netfilter_init(void)
 static void __exit br_netfilter_fini(void)
 {
 	RCU_INIT_POINTER(nf_br_ops, NULL);
-	nf_unregister_hooks(&init_net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
-- 
2.2.1

