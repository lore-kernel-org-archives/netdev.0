From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/13] netfilter: x_tables: suppress kmemcheck warning
Date: Fri, 21 Oct 2016 12:12:21 +0200
Message-ID: <1477044743-18948-12-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36258 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754909AbcJUKMr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 06:12:47 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 76CC026E18
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 660C3DA849
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 61494DA849
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:43 +0200 (CEST)
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Markus Trippelsdorf reports:

WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff88001e605480)
4055601e0088ffff000000000000000090686d81ffffffff0000000000000000
 u u u u u u u u u u u u u u u u i i i i i i i i u u u u u u u u
 ^
|RIP: 0010:[<ffffffff8166e561>]  [<ffffffff8166e561>] nf_register_net_hook+0x51/0x160
[..]
 [<ffffffff8166e561>] nf_register_net_hook+0x51/0x160
 [<ffffffff8166eaaf>] nf_register_net_hooks+0x3f/0xa0
 [<ffffffff816d6715>] ipt_register_table+0xe5/0x110
[..]

This warning is harmless; we copy 'uninitialized' data from the hook ops
but it will not be used.
Long term the structures keeping run-time data should be disentangled
from those only containing config-time data (such as where in the list
to insert a hook), but thats -next material.

Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Suggested-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index e0aa7c1d0224..fc4977456c30 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1513,7 +1513,7 @@ xt_hook_ops_alloc(const struct xt_table *table, nf_hookfn *fn)
 	if (!num_hooks)
 		return ERR_PTR(-EINVAL);
 
-	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
+	ops = kcalloc(num_hooks, sizeof(*ops), GFP_KERNEL);
 	if (ops == NULL)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.1.4
