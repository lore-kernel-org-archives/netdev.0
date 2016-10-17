From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 01/28] [v2] netfilter: nf_tables: avoid uninitialized variable warning
Date: Tue, 18 Oct 2016 00:05:30 +0200
Message-ID: <20161017220557.1688282-1-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 net/netfilter/nft_range.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Cc: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/net/netfilter/nft_range.c b/net/netfilter/nft_range.c
index c6d5358..2dd80f4 100644
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
2.9.0
