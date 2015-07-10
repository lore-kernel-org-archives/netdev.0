From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH -next 6/6] netfilter: nftables: Only run the nftables chains in the proper netns
Date: Fri, 10 Jul 2015 18:15:44 -0500
Message-ID: <87a8v3r4db.fsf_-_@x220.int.ebiederm.org>
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


- Register the nftables chains in the network namespace that they need
  to run in.

- Remove the hacks that stopped chains running in the wrong network
  namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/nf_tables_api.c  | 6 ++++--
 net/netfilter/nf_tables_core.c | 5 -----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index cfe636808541..12e65ec46bd4 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -130,20 +130,22 @@ static void nft_trans_destroy(struct nft_trans *trans)
 int nft_register_basechain(struct nft_base_chain *basechain,
 			   unsigned int hook_nops)
 {
+	struct net *net = read_pnet(&basechain->pnet);
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return 0;
 
-	return nf_register_hooks(basechain->ops, hook_nops);
+	return nf_register_net_hooks(net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_register_basechain);
 
 void nft_unregister_basechain(struct nft_base_chain *basechain,
 			      unsigned int hook_nops)
 {
+	struct net *net = read_pnet(&basechain->pnet);
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return;
 
-	nf_unregister_hooks(basechain->ops, hook_nops);
+	nf_unregister_net_hooks(net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_unregister_basechain);
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index f77bad46ac68..05d0b03530f6 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -114,7 +114,6 @@ unsigned int
 nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
 	const struct nft_chain *chain = ops->priv, *basechain = chain;
-	const struct net *chain_net = read_pnet(&nft_base_chain(basechain)->pnet);
 	const struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
@@ -125,10 +124,6 @@ nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	int rulenum;
 	unsigned int gencursor = nft_genmask_cur(net);
 
-	/* Ignore chains that are not for the current network namespace */
-	if (!net_eq(net, chain_net))
-		return NF_ACCEPT;
-
 do_chain:
 	rulenum = 0;
 	rule = list_entry(&chain->rules, struct nft_rule, list);
-- 
2.2.1

