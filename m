From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v4 1/2] netfilter: Fix potential null pointer dereference
Date: Wed, 28 Sep 2016 11:35:14 -0400
Message-ID: <1475076915-5920-2-git-send-email-aconole@bytheb.org>
References: <1475076915-5920-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1475076915-5920-1-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's possible for nf_hook_entry_head to return NULL.  If two
nf_unregister_net_hook calls happen simultaneously with a single hook
entry in the list, both will enter the nf_hook_mutex critical section.
The first will successfully delete the head, but the second will see
this NULL pointer and attempt to dereference.

This fix ensures that no null pointer dereference could occur when such
a condition happens.

Fixes: e3b37f11e6e4 ("netfilter: replace list_head with single linked list")
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

