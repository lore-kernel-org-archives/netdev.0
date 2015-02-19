From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: nft_compat: fix module refcount underflow
Date: Thu, 19 Feb 2015 19:19:18 +0100
Message-ID: <1424369960-10988-3-git-send-email-pablo@netfilter.org>
References: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Feb 12 18:20:42 nfdev kernel: ------------[ cut here ]------------
Feb 12 18:20:42 nfdev kernel: WARNING: CPU: 4 PID: 4359 at kernel/module.c:963 module_put+0x9b/0xba()
Feb 12 18:20:42 nfdev kernel: CPU: 4 PID: 4359 Comm: ebtables-compat Tainted: G        W      3.19.0-rc6+ #43
[...]
Feb 12 18:20:42 nfdev kernel: Call Trace:
Feb 12 18:20:42 nfdev kernel: [<ffffffff815fd911>] dump_stack+0x4c/0x65
Feb 12 18:20:42 nfdev kernel: [<ffffffff8103e6f7>] warn_slowpath_common+0x9c/0xb6
Feb 12 18:20:42 nfdev kernel: [<ffffffff8109919f>] ? module_put+0x9b/0xba
Feb 12 18:20:42 nfdev kernel: [<ffffffff8103e726>] warn_slowpath_null+0x15/0x17
Feb 12 18:20:42 nfdev kernel: [<ffffffff8109919f>] module_put+0x9b/0xba
Feb 12 18:20:42 nfdev kernel: [<ffffffff813ecf7c>] nft_match_destroy+0x45/0x4c
Feb 12 18:20:42 nfdev kernel: [<ffffffff813e683f>] nf_tables_rule_destroy+0x28/0x70

Reported-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Tested-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
---
 net/netfilter/nft_compat.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 265e190..b636486 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -578,8 +578,12 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 		struct xt_match *match = nft_match->ops.data;
 
 		if (strcmp(match->name, mt_name) == 0 &&
-		    match->revision == rev && match->family == family)
+		    match->revision == rev && match->family == family) {
+			if (!try_module_get(match->me))
+				return ERR_PTR(-ENOENT);
+
 			return &nft_match->ops;
+		}
 	}
 
 	match = xt_request_find_match(family, mt_name, rev);
@@ -648,8 +652,12 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 		struct xt_target *target = nft_target->ops.data;
 
 		if (strcmp(target->name, tg_name) == 0 &&
-		    target->revision == rev && target->family == family)
+		    target->revision == rev && target->family == family) {
+			if (!try_module_get(target->me))
+				return ERR_PTR(-ENOENT);
+
 			return &nft_target->ops;
+		}
 	}
 
 	target = xt_request_find_target(family, tg_name, rev);
-- 
1.7.10.4

