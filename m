From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 35/43] ipvs: Register netfilter hooks in all network namespaces
Date: Wed, 17 Jun 2015 10:28:44 -0500
Message-ID: <1434554932-4552-35-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1ab42bfe6020..2ea140c9a81c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2005,6 +2005,9 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_sync_net_init(net) < 0)
 		goto sync_fail;
 
+	if (nf_register_hooks(net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops)))
+		goto hooks_fail;
+
 	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
 			 sizeof(struct netns_ipvs), ipvs->gen);
 	return 0;
@@ -2012,6 +2015,9 @@ static int __net_init __ip_vs_init(struct net *net)
  * Error handling
  */
 
+hooks_fail:
+	pr_err("can't register hooks.\n");
+	ip_vs_sync_net_cleanup(net);
 sync_fail:
 	ip_vs_conn_net_cleanup(net);
 conn_fail:
@@ -2029,6 +2035,7 @@ estimator_fail:
 
 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
+	nf_unregister_hooks(net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	ip_vs_service_net_cleanup(net);	/* ip_vs_flush() with locks */
 	ip_vs_conn_net_cleanup(net);
 	ip_vs_app_net_cleanup(net);
@@ -2088,24 +2095,16 @@ static int __init ip_vs_init(void)
 	if (ret < 0)
 		goto cleanup_sub;
 
-	ret = nf_register_hooks(&init_net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
-	if (ret < 0) {
-		pr_err("can't register hooks.\n");
-		goto cleanup_dev;
-	}
-
 	ret = ip_vs_register_nl_ioctl();
 	if (ret < 0) {
 		pr_err("can't register netlink/ioctl.\n");
-		goto cleanup_hooks;
+		goto cleanup_dev;
 	}
 
 	pr_info("ipvs loaded.\n");
 
 	return ret;
 
-cleanup_hooks:
-	nf_unregister_hooks(&init_net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 cleanup_dev:
 	unregister_pernet_device(&ipvs_core_dev_ops);
 cleanup_sub:
@@ -2122,7 +2121,6 @@ exit:
 static void __exit ip_vs_cleanup(void)
 {
 	ip_vs_unregister_nl_ioctl();
-	nf_unregister_hooks(&init_net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	unregister_pernet_device(&ipvs_core_dev_ops);
 	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	ip_vs_conn_cleanup();
-- 
2.2.1

