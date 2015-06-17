From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 36/43] netfilter: nf_conntract: Register netfilter hooks in all network namespaces
Date: Wed, 17 Jun 2015 10:28:45 -0500
Message-ID: <1434554932-4552-36-git-send-email-ebiederm@xmission.com>
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
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 22 +++++++++++-----------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 24 ++++++++++++------------
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index abf6f60e80fe..735a32dace73 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -424,7 +424,15 @@ static int ipv4_net_init(struct net *net)
 		pr_err("nf_conntrack_ipv4: pernet registration failed\n");
 		goto out_ipv4;
 	}
+	ret = nf_register_hooks(net, ipv4_conntrack_ops,
+				ARRAY_SIZE(ipv4_conntrack_ops));
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
+		goto out_hooks;
+	}
 	return 0;
+out_hooks:
+	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv4);
 out_ipv4:
 	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmp);
 out_icmp:
@@ -437,6 +445,8 @@ out_tcp:
 
 static void ipv4_net_exit(struct net *net)
 {
+	nf_unregister_hooks(net, ipv4_conntrack_ops,
+			    ARRAY_SIZE(ipv4_conntrack_ops));
 	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv4);
 	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmp);
 	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udp4);
@@ -467,17 +477,10 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		goto cleanup_sockopt;
 	}
 
-	ret = nf_register_hooks(&init_net, ipv4_conntrack_ops,
-				ARRAY_SIZE(ipv4_conntrack_ops));
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
-		goto cleanup_pernet;
-	}
-
 	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_tcp4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register tcp4 proto.\n");
-		goto cleanup_hooks;
+		goto cleanup_pernet;
 	}
 
 	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_udp4);
@@ -514,8 +517,6 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp4);
  cleanup_tcp4:
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
- cleanup_hooks:
-	nf_unregister_hooks(&init_net, ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
  cleanup_pernet:
 	unregister_pernet_subsys(&ipv4_net_ops);
  cleanup_sockopt:
@@ -533,7 +534,6 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmp);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp4);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
-	nf_unregister_hooks(&init_net, ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 710ed6607e66..5823956fa130 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -366,7 +366,16 @@ static int ipv6_net_init(struct net *net)
 		pr_err("nf_conntrack_ipv6: pernet registration failed.\n");
 		goto cleanup_icmpv6;
 	}
+	ret = nf_register_hooks(net, ipv6_conntrack_ops,
+				ARRAY_SIZE(ipv6_conntrack_ops));
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv6: can't register pre-routing defrag "
+		       "hook.\n");
+		goto cleanup_hooks;
+	}
 	return 0;
+cleanup_hooks:
+	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv6);
  cleanup_icmpv6:
 	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmpv6);
  cleanup_udp6:
@@ -379,6 +388,8 @@ static int ipv6_net_init(struct net *net)
 
 static void ipv6_net_exit(struct net *net)
 {
+	nf_unregister_hooks(net, ipv6_conntrack_ops,
+			    ARRAY_SIZE(ipv6_conntrack_ops));
 	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv6);
 	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmpv6);
 	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udp6);
@@ -407,18 +418,10 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	if (ret < 0)
 		goto cleanup_sockopt;
 
-	ret = nf_register_hooks(&init_net, ipv6_conntrack_ops,
-				ARRAY_SIZE(ipv6_conntrack_ops));
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register pre-routing defrag "
-		       "hook.\n");
-		goto cleanup_pernet;
-	}
-
 	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register tcp6 proto.\n");
-		goto cleanup_hooks;
+		goto cleanup_pernet;
 	}
 
 	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_udp6);
@@ -446,8 +449,6 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp6);
  cleanup_tcp6:
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
- cleanup_hooks:
-	nf_unregister_hooks(&init_net, ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
  cleanup_pernet:
 	unregister_pernet_subsys(&ipv6_net_ops);
  cleanup_sockopt:
@@ -462,7 +463,6 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp6);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
-	nf_unregister_hooks(&init_net, ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	unregister_pernet_subsys(&ipv6_net_ops);
 	nf_unregister_sockopt(&so_getorigdst6);
 }
-- 
2.2.1

