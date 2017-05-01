From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 49/53] netfilter: batch synchronize_net calls during hook unregister
Date: Mon,  1 May 2017 12:47:16 +0200
Message-ID: <1493635640-24325-50-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

synchronize_net is expensive and slows down netns cleanup a lot.

We have two APIs to unregister a hook:
nf_unregister_net_hook (which calls synchronize_net())
and
nf_unregister_net_hooks (calls nf_unregister_net_hook in a loop)

Make nf_unregister_net_hook a wapper around new helper
__nf_unregister_net_hook, which unlinks the hook but does not free it.

Then, we can call that helper in nf_unregister_net_hooks and then
call synchronize_net() only once.

Andrey Konovalov reports this change improves syzkaller fuzzing speed at
least twice.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 46 ++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 40 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a87a6f8a74d8..b5d908851cc8 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -126,14 +126,15 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 }
 EXPORT_SYMBOL(nf_register_net_hook);
 
-void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
+static struct nf_hook_entry *
+__nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
 	struct nf_hook_entry __rcu **pp;
 	struct nf_hook_entry *p;
 
 	pp = nf_hook_entry_head(net, reg);
 	if (WARN_ON_ONCE(!pp))
-		return;
+		return NULL;
 
 	mutex_lock(&nf_hook_mutex);
 	for (; (p = nf_entry_dereference(*pp)) != NULL; pp = &p->next) {
@@ -145,7 +146,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	mutex_unlock(&nf_hook_mutex);
 	if (!p) {
 		WARN(1, "nf_unregister_net_hook: hook not found!\n");
-		return;
+		return NULL;
 	}
 #ifdef CONFIG_NETFILTER_INGRESS
 	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
@@ -154,6 +155,17 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
+
+	return p;
+}
+
+void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
+{
+	struct nf_hook_entry *p = __nf_unregister_net_hook(net, reg);
+
+	if (!p)
+		return;
+
 	synchronize_net();
 	nf_queue_nf_hook_drop(net, p);
 	/* other cpu might still process nfqueue verdict that used reg */
@@ -183,10 +195,32 @@ int nf_register_net_hooks(struct net *net, const struct nf_hook_ops *reg,
 EXPORT_SYMBOL(nf_register_net_hooks);
 
 void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
-			     unsigned int n)
+			     unsigned int hookcount)
 {
-	while (n-- > 0)
-		nf_unregister_net_hook(net, &reg[n]);
+	struct nf_hook_entry *to_free[16];
+	unsigned int i, n;
+
+	do {
+		n = min_t(unsigned int, hookcount, ARRAY_SIZE(to_free));
+
+		for (i = 0; i < n; i++)
+			to_free[i] = __nf_unregister_net_hook(net, &reg[i]);
+
+		synchronize_net();
+
+		for (i = 0; i < n; i++) {
+			if (to_free[i])
+				nf_queue_nf_hook_drop(net, to_free[i]);
+		}
+
+		synchronize_net();
+
+		for (i = 0; i < n; i++)
+			kfree(to_free[i]);
+
+		reg += n;
+		hookcount -= n;
+	} while (hookcount > 0);
 }
 EXPORT_SYMBOL(nf_unregister_net_hooks);
 
-- 
2.1.4

