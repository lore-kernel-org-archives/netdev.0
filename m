From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v3 2/2] nf_set_hooks_head: accommodate different kconfig
Date: Wed, 28 Sep 2016 09:12:48 -0400
Message-ID: <1475068368-3109-3-git-send-email-aconole@bytheb.org>
References: <1475068368-3109-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1475068368-3109-1-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_NETFILTER_INGRESS is unset (or no), we need to handle
the request for registration properly by dropping the hook.  This
releases the entry during the set.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/netfilter/core.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e58e420..61e8a9d 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -90,10 +90,12 @@ static void nf_set_hooks_head(struct net *net, const struct nf_hook_ops *reg,
 {
 	switch (reg->pf) {
 	case NFPROTO_NETDEV:
+#ifdef CONFIG_NETFILTER_INGRESS
 		/* We already checked in nf_register_net_hook() that this is
 		 * used from ingress.
 		 */
 		rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
+#endif
 		break;
 	default:
 		rcu_assign_pointer(net->nf.hooks[reg->pf][reg->hooknum],
@@ -107,10 +109,15 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	struct nf_hook_entry *hooks_entry;
 	struct nf_hook_entry *entry;
 
-	if (reg->pf == NFPROTO_NETDEV &&
-	    (reg->hooknum != NF_NETDEV_INGRESS ||
-	     !reg->dev || dev_net(reg->dev) != net))
-		return -EINVAL;
+	if (reg->pf == NFPROTO_NETDEV) {
+#ifndef CONFIG_NETFILTER_INGRESS
+		if (reg->hooknum == NF_NETDEV_INGRESS)
+			return -EOPNOTSUPP;
+#endif
+		if (reg->hooknum != NF_NETDEV_INGRESS ||
+		    !reg->dev || dev_net(reg->dev) != net)
+			return -EINVAL;
+	}
 
 	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
-- 
2.7.4

