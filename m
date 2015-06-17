From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 32/43] netfilter: ipt_CLUSTERIP: adapt it to support pernet hooks
Date: Wed, 17 Jun 2015 10:28:41 -0500
Message-ID: <1434554932-4552-32-git-send-email-ebiederm@xmission.com>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:45822 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757410AbbFQPi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:26 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This target is deprecated, but let's adapt this so it doesn't break existing
users.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index abbf0c0052af..d0d2f2b00f2d 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -724,6 +724,7 @@ static const struct file_operations clusterip_proc_fops = {
 static int clusterip_net_init(struct net *net)
 {
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
+	int ret;
 
 	INIT_LIST_HEAD(&cn->configs);
 
@@ -737,6 +738,11 @@ static int clusterip_net_init(struct net *net)
 	}
 #endif /* CONFIG_PROC_FS */
 
+	ret = nf_register_hook(net, &cip_arp_ops);
+	if (ret < 0) {
+		proc_remove(cn->procdir);
+		return ret;
+	}
 	return 0;
 }
 
@@ -746,6 +752,7 @@ static void clusterip_net_exit(struct net *net)
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 	proc_remove(cn->procdir);
 #endif
+	nf_unregister_hook(net, &cip_arp_ops);
 }
 
 static struct pernet_operations clusterip_net_ops = {
@@ -767,17 +774,11 @@ static int __init clusterip_tg_init(void)
 	if (ret < 0)
 		goto cleanup_subsys;
 
-	ret = nf_register_hook(&init_net, &cip_arp_ops);
-	if (ret < 0)
-		goto cleanup_target;
-
 	pr_info("ClusterIP Version %s loaded successfully\n",
 		CLUSTERIP_VERSION);
 
 	return 0;
 
-cleanup_target:
-	xt_unregister_target(&clusterip_tg_reg);
 cleanup_subsys:
 	unregister_pernet_subsys(&clusterip_net_ops);
 	return ret;
@@ -787,7 +788,6 @@ static void __exit clusterip_tg_exit(void)
 {
 	pr_info("ClusterIP Version %s unloading\n", CLUSTERIP_VERSION);
 
-	nf_unregister_hook(&init_net, &cip_arp_ops);
 	xt_unregister_target(&clusterip_tg_reg);
 	unregister_pernet_subsys(&clusterip_net_ops);
 
-- 
2.2.1
