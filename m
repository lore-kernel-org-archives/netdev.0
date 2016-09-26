From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next 1/2] netfilter: Fix potential null pointer dereference
Date: Mon, 26 Sep 2016 12:24:30 -0400
Message-ID: <1474907071-13591-2-git-send-email-aconole@bytheb.org>
References: <1474907071-13591-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33684 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422874AbcIZQYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 12:24:43 -0400
Received: by mail-yw0-f196.google.com with SMTP id g192so9196515ywh.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 09:24:43 -0700 (PDT)
In-Reply-To: <1474907071-13591-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
2.5.5
