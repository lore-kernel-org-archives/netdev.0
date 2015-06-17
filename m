From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 29/43] x_tables: Kill xt_[un]hook_link
Date: Wed, 17 Jun 2015 10:28:38 -0500
Message-ID: <1434554932-4552-29-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41099 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757378AbbFQPi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:29 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

These functions have no more users, kill them.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter/x_tables.h |  3 ---
 net/netfilter/x_tables.c           | 54 --------------------------------------
 2 files changed, 57 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 0803027b36a2..61fc19961592 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -409,9 +409,6 @@ xt_get_per_cpu_counter(struct xt_counters *cnt, unsigned int cpu)
 	return cnt;
 }
 
-struct nf_hook_ops *xt_hook_link(const struct xt_table *, nf_hookfn *);
-void xt_hook_unlink(const struct xt_table *, struct nf_hook_ops *);
-
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index f7ade70ef342..67b70a717c0a 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1227,60 +1227,6 @@ static const struct file_operations xt_target_ops = {
 
 #endif /* CONFIG_PROC_FS */
 
-/**
- * xt_hook_link - set up hooks for a new table
- * @table:	table with metadata needed to set up hooks
- * @fn:		Hook function
- *
- * This function will take care of creating and registering the necessary
- * Netfilter hooks for XT tables.
- */
-struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)
-{
-	unsigned int hook_mask = table->valid_hooks;
-	uint8_t i, num_hooks = hweight32(hook_mask);
-	uint8_t hooknum;
-	struct nf_hook_ops *ops;
-	int ret;
-
-	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
-	if (ops == NULL)
-		return ERR_PTR(-ENOMEM);
-
-	for (i = 0, hooknum = 0; i < num_hooks && hook_mask != 0;
-	     hook_mask >>= 1, ++hooknum) {
-		if (!(hook_mask & 1))
-			continue;
-		ops[i].hook     = fn;
-		ops[i].owner    = table->me;
-		ops[i].pf       = table->af;
-		ops[i].hooknum  = hooknum;
-		ops[i].priority = table->priority;
-		++i;
-	}
-
-	ret = nf_register_hooks(&init_net, ops, num_hooks);
-	if (ret < 0) {
-		kfree(ops);
-		return ERR_PTR(ret);
-	}
-
-	return ops;
-}
-EXPORT_SYMBOL_GPL(xt_hook_link);
-
-/**
- * xt_hook_unlink - remove hooks for a table
- * @ops:	nf_hook_ops array as returned by nf_hook_link
- * @hook_mask:	the very same mask that was passed to nf_hook_link
- */
-void xt_hook_unlink(const struct xt_table *table, struct nf_hook_ops *ops)
-{
-	nf_unregister_hooks(&init_net, ops, hweight32(table->valid_hooks));
-	kfree(ops);
-}
-EXPORT_SYMBOL_GPL(xt_hook_unlink);
-
 int xt_proto_init(struct net *net, u_int8_t af)
 {
 #ifdef CONFIG_PROC_FS
-- 
2.2.1
