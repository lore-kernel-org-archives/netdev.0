From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH -next 3/6] netfilter: Simply the tests for enabling and disabling the ingress queue hook
Date: Fri, 10 Jul 2015 18:13:58 -0500
Message-ID: <87r3ofr4g9.fsf_-_@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<87r3pae5hn.fsf@x220.int.ebiederm.org>
	<878uansj4d.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <878uansj4d.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 10 Jul 2015 18:11:46 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replace an overcomplicated switch statement with a simple if statement.

This also removes the ingress queue enable outside of nf_hook_mutex as
the protection provided by the mutex is not necessary and the code is
clearer having both of the static key increments together.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/core.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a0e54974e2c9..7e3bc12f1c62 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -74,7 +74,6 @@ int nf_register_hook(struct nf_hook_ops *reg)
 		if (reg->hooknum == NF_NETDEV_INGRESS) {
 			BUG_ON(reg->dev == NULL);
 			nf_hook_list = &reg->dev->nf_hooks_ingress;
-			net_inc_ingress_queue();
 			break;
 		}
 #endif
@@ -90,6 +89,10 @@ int nf_register_hook(struct nf_hook_ops *reg)
 	}
 	list_add_rcu(&reg->list, elem->list.prev);
 	mutex_unlock(&nf_hook_mutex);
+#ifdef CONFIG_NETFILTER_INGRESS
+	if ((reg->pf == NFPROTO_NETDEV) && (reg->hooknum == NF_NETDEV_INGRESS))
+		net_inc_ingress_queue();
+#endif
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
@@ -102,18 +105,10 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
 	mutex_unlock(&nf_hook_mutex);
-	switch (reg->pf) {
-	case NFPROTO_NETDEV:
 #ifdef CONFIG_NETFILTER_INGRESS
-		if (reg->hooknum == NF_NETDEV_INGRESS) {
-			net_dec_ingress_queue();
-			break;
-		}
-		break;
+	if ((reg->pf == NFPROTO_NETDEV) && (reg->hooknum == NF_NETDEV_INGRESS))
+		net_dec_ingress_queue();
 #endif
-	default:
-		break;
-	}
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
-- 
2.2.1

