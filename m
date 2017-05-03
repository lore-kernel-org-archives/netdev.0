From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/16] netfilter: nft_dynset: continue to next expr if _OP_ADD succeeded
Date: Wed,  3 May 2017 11:32:06 +0200
Message-ID: <1493803931-2837-12-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Currently, after adding the following nft rules:
  # nft add set x target1 { type ipv4_addr \; flags timeout \;}
  # nft add rule x y set add ip daddr timeout 1d @target1 counter

the counters will always be zero despite of the elements are added
to the dynamic set "target1" or not, as we will break the nft expr
traversal unconditionally:
  # nft list ruleset
  ...
  set target1 {
      ...
      elements = { 8.8.8.8 expires 23h59m53s}
  }
  chain output {
      ...
      set add ip daddr timeout 1d @target1 counter packets 0 bytes 0
                                                           ^       ^
      ...
  }

Since we add the elements to the set successfully, we should continue
to the next expression.

Additionally, if elements are added to "flow table" successfully, we
will _always_ continue to the next expr, even if the operation is
_OP_ADD. So it's better to keep them to be consistent.

Fixes: 22fe54d5fefc ("netfilter: nf_tables: add support for dynamic set updates")
Reported-by: Robert White <rwhite@pobox.com>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_dynset.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 049ad2d9ee66..fafbeea3ed04 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -82,8 +82,7 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 		    nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION)) {
 			timeout = priv->timeout ? : set->timeout;
 			*nft_set_ext_expiration(ext) = jiffies + timeout;
-		} else if (sexpr == NULL)
-			goto out;
+		}
 
 		if (sexpr != NULL)
 			sexpr->ops->eval(sexpr, regs, pkt);
@@ -92,7 +91,7 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 			regs->verdict.code = NFT_BREAK;
 		return;
 	}
-out:
+
 	if (!priv->invert)
 		regs->verdict.code = NFT_BREAK;
 }
-- 
2.1.4

