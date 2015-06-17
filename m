From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 40/43] smack: adapt it to pernet hooks
Date: Wed, 17 Jun 2015 10:28:49 -0500
Message-ID: <1434554932-4552-40-git-send-email-ebiederm@xmission.com>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:39870 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757437AbbFQPi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:28 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

Since pernet hooks, we need to register the hook for each netnamespace space.

Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 security/smack/smack_netfilter.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/security/smack/smack_netfilter.c b/security/smack/smack_netfilter.c
index 0646fe5eda77..fcb3172adb75 100644
--- a/security/smack/smack_netfilter.c
+++ b/security/smack/smack_netfilter.c
@@ -73,6 +73,21 @@ static struct nf_hook_ops smack_nf_ops[] = {
 #endif	/* IPV6 */
 };
 
+static int smack_net_init(struct net *net)
+{
+	return nf_register_hooks(net, smack_nf_ops, ARRAY_SIZE(smack_nf_ops));
+}
+
+static void smack_net_exit(struct net *net)
+{
+	nf_unregister_hooks(net, smack_nf_ops, ARRAY_SIZE(smack_nf_ops));
+}
+
+static struct pernet_operations smack_net_ops = {
+	.init = smack_net_init,
+	.exit = smack_net_exit,
+};
+
 static int __init smack_nf_ip_init(void)
 {
 	int err;
@@ -82,8 +97,7 @@ static int __init smack_nf_ip_init(void)
 
 	printk(KERN_DEBUG "Smack: Registering netfilter hooks\n");
 
-	err = nf_register_hooks(&init_net, smack_nf_ops,
-				ARRAY_SIZE(smack_nf_ops));
+	err = register_pernet_subsys(&smack_net_ops);
 	if (err)
 		pr_info("Smack: nf_register_hooks: error %d\n", err);
 
-- 
2.2.1
