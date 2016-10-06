From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: Fix potential null pointer dereference
Date: Thu,  6 Oct 2016 02:07:45 +0200
Message-ID: <1475712469-17000-2-git-send-email-pablo@netfilter.org>
References: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34422 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755413AbcJFAIH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 20:08:07 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C3D6CC8830
        for <netdev@vger.kernel.org>; Thu,  6 Oct 2016 02:08:04 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B0F92DA844
        for <netdev@vger.kernel.org>; Thu,  6 Oct 2016 02:08:04 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 92F70DA84A
        for <netdev@vger.kernel.org>; Thu,  6 Oct 2016 02:08:02 +0200 (CEST)
In-Reply-To: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

It's possible for nf_hook_entry_head to return NULL.  If two
nf_unregister_net_hook calls happen simultaneously with a single hook
entry in the list, both will enter the nf_hook_mutex critical section.
The first will successfully delete the head, but the second will see
this NULL pointer and attempt to dereference.

This fix ensures that no null pointer dereference could occur when such
a condition happens.

Fixes: e3b37f11e6e4 ("netfilter: replace list_head with single linked list")
Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index fa6715db4581..e3f68a786afe 100644
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
2.1.4
