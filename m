From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/12] netfilter: nf_tables: consolidate tracing invocations
Date: Mon,  9 Mar 2015 18:14:28 +0100
Message-ID: <1425921275-9171-6-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

* JUMP and GOTO are equivalent except for JUMP pushing the current
  context to the stack

* RETURN and implicit RETURN (CONTINUE) are equivalent except that
  the logged rule number differs

Result:

  nft_do_chain              | -112
 1 function changed, 112 bytes removed, diff: -112

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 074067d..77165bf 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -170,26 +170,23 @@ next_rule:
 
 	switch (data[NFT_REG_VERDICT].verdict) {
 	case NFT_JUMP:
-		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
-
 		BUG_ON(stackptr >= NFT_JUMP_STACK_SIZE);
 		jumpstack[stackptr].chain = chain;
 		jumpstack[stackptr].rule  = rule;
 		jumpstack[stackptr].rulenum = rulenum;
 		stackptr++;
-		chain = data[NFT_REG_VERDICT].chain;
-		goto do_chain;
+		/* fall through */
 	case NFT_GOTO:
 		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
 
 		chain = data[NFT_REG_VERDICT].chain;
 		goto do_chain;
+	case NFT_CONTINUE:
+		rulenum++;
+		/* fall through */
 	case NFT_RETURN:
 		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RETURN);
 		break;
-	case NFT_CONTINUE:
-		nft_trace_packet(pkt, chain, ++rulenum, NFT_TRACE_RETURN);
-		break;
 	default:
 		WARN_ON(1);
 	}
-- 
1.7.10.4

