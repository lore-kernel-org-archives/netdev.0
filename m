From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net] netfilter: nftables: Do not run chains in the wrong network namespace
Date: Fri, 19 Jun 2015 10:41:21 -0500
Message-ID: <87oakbg0ym.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currenlty nf_tables chains added in one network namespace are being
run in all network namespace.  The issues are myriad with the simplest
being an unprivileged user can cause any network packets to be dropped.

Address this by simply not running nf_tables chains in the wrong
network namespace.

Cc: stable@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/nf_tables_core.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index f153b07073af..f77bad46ac68 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -114,7 +114,8 @@ unsigned int
 nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
 	const struct nft_chain *chain = ops->priv, *basechain = chain;
-	const struct net *net = read_pnet(&nft_base_chain(basechain)->pnet);
+	const struct net *chain_net = read_pnet(&nft_base_chain(basechain)->pnet);
+	const struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
 	struct nft_regs regs;
@@ -124,6 +125,10 @@ nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	int rulenum;
 	unsigned int gencursor = nft_genmask_cur(net);
 
+	/* Ignore chains that are not for the current network namespace */
+	if (!net_eq(net, chain_net))
+		return NF_ACCEPT;
+
 do_chain:
 	rulenum = 0;
 	rule = list_entry(&chain->rules, struct nft_rule, list);
-- 
2.2.1

--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
