From: Xiubo Li <lixiubo@cmss.chinamobile.com>
Subject: [PATCH] netfilter: fix possible ZERO_SIZE_PTR pointer dereferencing error.
Date: Wed,  1 Jun 2016 16:34:28 +0800
Message-ID: <1464770068-7508-1-git-send-email-lixiubo@cmss.chinamobile.com>
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	Xiubo Li <lixiubo@cmss.chinamobile.com>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we cannot make sure the 'hook_mask' will always be none zero
here. If it equals to zero, the num_hooks will be zero too, and then
kmalloc() will return ZERO_SIZE_PTR, which is (void *)16.

Then the following error check will fails:
  ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
  if (ops == NULL)
          return ERR_PTR(-ENOMEM);

So this patch fix this with just doing the zero check before calling
kmalloc() is called.

Maybe the case above will never happen here, but in theory.

Signed-off-by: Xiubo Li <lixiubo@cmss.chinamobile.com>
---
 net/netfilter/x_tables.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index c8a0b7d..4df8e38 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1185,6 +1185,9 @@ struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)
 	struct nf_hook_ops *ops;
 	int ret;
 
+	if (!num_hooks)
+		return ERR_PTR(-EINVAL);
+
 	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
 	if (ops == NULL)
 		return ERR_PTR(-ENOMEM);
-- 
1.8.3.1



