From: Xiubo Li <lixiubo@cmss.chinamobile.com>
Subject: [PATCH v2] netfilter: fix possible ZERO_SIZE_PTR pointer dereferencing error.
Date: Thu,  2 Jun 2016 10:59:56 +0800
Message-ID: <1464836396-15671-1-git-send-email-lixiubo@cmss.chinamobile.com>
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	Xiubo Li <lixiubo@cmss.chinamobile.com>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---

Changes in V2:
- Using the nf.git tree instead.


 net/netfilter/x_tables.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 582c9cf..e117fd0 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1221,6 +1221,9 @@ xt_hook_ops_alloc(const struct xt_table *table, nf_hookfn *fn)
 	uint8_t hooknum;
 	struct nf_hook_ops *ops;
 
+	if (!num_hooks)
+		return ERR_PTR(-EINVAL);
+
 	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
 	if (ops == NULL)
 		return ERR_PTR(-ENOMEM);
-- 
1.8.3.1



