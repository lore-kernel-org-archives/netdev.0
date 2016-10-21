From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/13] netfilter: nf_tables: avoid uninitialized variable warning
Date: Fri, 21 Oct 2016 12:12:20 +0200
Message-ID: <1477044743-18948-11-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The newly added nft_range_eval() function handles the two possible
nft range operations, but as the compiler warning points out,
any unexpected value would lead to the 'mismatch' variable being
used without being initialized:

net/netfilter/nft_range.c: In function 'nft_range_eval':
net/netfilter/nft_range.c:45:5: error: 'mismatch' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This removes the variable in question and instead moves the
condition into the switch itself, which is potentially more
efficient than adding a bogus 'default' clause as in my
first approach, and is nicer than using the 'uninitialized_var'
macro.

Fixes: 0f3cd9b36977 ("netfilter: nf_tables: add range expression")
Link: http://patchwork.ozlabs.org/patch/677114/
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_range.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nft_range.c b/net/netfilter/nft_range.c
index 9bc4586c3006..fbc88009ca2e 100644
--- a/net/netfilter/nft_range.c
+++ b/net/netfilter/nft_range.c
@@ -28,22 +28,20 @@ static void nft_range_eval(const struct nft_expr *expr,
 			 const struct nft_pktinfo *pkt)
 {
 	const struct nft_range_expr *priv = nft_expr_priv(expr);
-	bool mismatch;
 	int d1, d2;
 
 	d1 = memcmp(&regs->data[priv->sreg], &priv->data_from, priv->len);
 	d2 = memcmp(&regs->data[priv->sreg], &priv->data_to, priv->len);
 	switch (priv->op) {
 	case NFT_RANGE_EQ:
-		mismatch = (d1 < 0 || d2 > 0);
+		if (d1 < 0 || d2 > 0)
+			regs->verdict.code = NFT_BREAK;
 		break;
 	case NFT_RANGE_NEQ:
-		mismatch = (d1 >= 0 && d2 <= 0);
+		if (d1 >= 0 && d2 <= 0)
+			regs->verdict.code = NFT_BREAK;
 		break;
 	}
-
-	if (mismatch)
-		regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_range_policy[NFTA_RANGE_MAX + 1] = {
-- 
2.1.4

