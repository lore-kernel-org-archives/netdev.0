From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v2 1/2] netfilter: Fix potential null pointer dereference
Date: Tue, 27 Sep 2016 09:38:34 -0400
Message-ID: <1474983515-4115-2-git-send-email-aconole@bytheb.org>
References: <1474983515-4115-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474983515-4115-1-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's possible for nf_hook_entry_head to return NULL if two
nf_unregister_net_hook calls happen simultaneously with a single hook
entry in the list.  This fix ensures that no null pointer dereference
could occur when such a race happens.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/netfilter/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 360c63d..e58e420 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -160,7 +160,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 
 	mutex_lock(&nf_hook_mutex);
 	hooks_entry = nf_hook_entry_head(net, reg);
-	if (hooks_entry->orig_ops == reg) {
+	if (hooks_entry && hooks_entry->orig_ops == reg) {
 		nf_set_hooks_head(net, reg,
 				  nf_entry_dereference(hooks_entry->next));
 		goto unlock;
-- 
2.7.4

