From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 39/43] selinux: adapt it to pernet hooks
Date: Wed, 17 Jun 2015 10:28:48 -0500
Message-ID: <1434554932-4552-39-git-send-email-ebiederm@xmission.com>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:45864 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757478AbbFQPia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:30 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Since pernet hooks, we need to register the hook for each netnamespace space.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 security/selinux/hooks.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 21a5e07b6834..f8db1d2ce9c2 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6147,6 +6147,22 @@ static struct nf_hook_ops selinux_nf_ops[] = {
 #endif	/* IPV6 */
 };
 
+static int selinux_net_init(struct net *net)
+{
+	return nf_register_hooks(net, selinux_nf_ops,
+				 ARRAY_SIZE(selinux_nf_ops));
+}
+
+static void selinux_net_exit(struct net *net)
+{
+	nf_unregister_hooks(net, selinux_nf_ops, ARRAY_SIZE(selinux_nf_ops));
+}
+
+static struct pernet_operations selinux_net_ops = {
+	.init = selinux_net_init,
+	.exit = selinux_net_exit,
+};
+
 static int __init selinux_nf_ip_init(void)
 {
 	int err;
@@ -6156,8 +6172,7 @@ static int __init selinux_nf_ip_init(void)
 
 	printk(KERN_DEBUG "SELinux:  Registering netfilter hooks\n");
 
-	err = nf_register_hooks(&init_net, selinux_nf_ops,
-				ARRAY_SIZE(selinux_nf_ops));
+	err = register_pernet_subsys(&selinux_net_ops);
 	if (err)
 		panic("SELinux: nf_register_hooks: error %d\n", err);
 
@@ -6171,7 +6186,7 @@ static void selinux_nf_ip_exit(void)
 {
 	printk(KERN_DEBUG "SELinux:  Unregistering netfilter hooks\n");
 
-	nf_unregister_hooks(&init_net, selinux_nf_ops, ARRAY_SIZE(selinux_nf_ops));
+	unregister_pernet_subsys(&selinux_net_ops);
 }
 #endif
 
-- 
2.2.1
