From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/26] netfilter: x_tables: fix possible ZERO_SIZE_PTR pointer dereferencing error.
Date: Wed,  6 Jul 2016 16:23:45 +0200
Message-ID: <1467815048-2240-4-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiubo Li <lixiubo@cmss.chinamobile.com>

Since we cannot make sure that the 'hook_mask' will always be none
zero here. If it equals to zero, the num_hooks will be zero too,
and then kmalloc() will return ZERO_SIZE_PTR, which is (void *)16.

Then the following error check will fails:
  ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
  if (ops == NULL)
          return ERR_PTR(-ENOMEM);

So this patch will fix this with just doing the zero check before
kmalloc() is called.

Maybe the case above will never happen here, but in theory.

Signed-off-by: Xiubo Li <lixiubo@cmss.chinamobile.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index c69c892..8aff34e 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1460,6 +1460,9 @@ xt_hook_ops_alloc(const struct xt_table *table, nf_hookfn *fn)
 	uint8_t hooknum;
 	struct nf_hook_ops *ops;
 
+	if (!num_hooks)
+		return ERR_PTR(-EINVAL);
+
 	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
 	if (ops == NULL)
 		return ERR_PTR(-ENOMEM);
-- 
2.1.4

