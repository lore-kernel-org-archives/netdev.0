From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [v2 netfilter-next] netfilter: nf_tables: fib warnings
Date: Fri, 28 Oct 2016 22:17:54 +0200
Message-ID: <20161028201810.1076559-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:56818 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754833AbcJ1USo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 16:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newly added nft fib code produces two warnings:

net/ipv4/netfilter/nft_fib_ipv4.c: In function 'nft_fib4_eval':
net/ipv4/netfilter/nft_fib_ipv4.c:80:6: error: unused variable 'i' [-Werror=unused-variable]
net/ipv4/netfilter/nft_fib_ipv4.c: In function ‘nft_fib4_eval’:
net/ipv4/netfilter/nft_fib_ipv4.c:137:6: error: ‘oif’ may be used uninitialized in this function [-Werror=maybe-uninitialized]

The first one is obvious as the only user of that variable is
inside of an #ifdef

The second one is a bit trickier. It's clear that oif is in fact
uninitialized when it gets used when neither NFTA_FIB_F_IIF nor
NFTA_FIB_F_OIF are set, and just setting it to NULL won't work
as it may later get dereferenced.

However, there is no need to search the result list if it is
NULL, as Florian pointed out. This integrates his (untested)
change to do so. I have confirmed that the combined patch
solves both warnings, but as I don't fully understand Florian's
change, I can't tell if it's correct.

Suggested-by: Florian Westphal <fw@strlen.de>
Fixes: 84f5eedb983e ("netfilter: nf_tables: add fib expression")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
v2: integrate changes that Florian suggested
---
 net/ipv4/netfilter/nft_fib_ipv4.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index 6787c563cfc9..db91fd42db67 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -77,7 +77,9 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 	};
 	const struct net_device *oif;
 	struct net_device *found;
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int i;
+#endif
 
 	/*
 	 * Do not set flowi4_oif, it restricts results (for example, asking
@@ -90,6 +92,8 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		oif = pkt->out;
 	else if (priv->flags & NFTA_FIB_F_IIF)
 		oif = pkt->in;
+	else
+		oif = NULL;
 
 	if (pkt->hook == NF_INET_PRE_ROUTING && fib4_is_local(pkt->skb)) {
 		nft_fib_store_result(dest, priv->result, pkt, LOOPBACK_IFINDEX);
@@ -130,6 +134,11 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		break;
 	}
 
+       if (!oif) {
+               found = FIB_RES_DEV(res);
+               goto ok;
+       }
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	for (i = 0; i < res.fi->fib_nhs; i++) {
 		struct fib_nh *nh = &res.fi->fib_nh[i];
@@ -139,16 +148,12 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 			goto ok;
 		}
 	}
-#endif
-	if (priv->flags & NFTA_FIB_F_OIF) {
-		found = FIB_RES_DEV(res);
-		if (found == oif)
-			goto ok;
-		return;
-	}
-
-	*dest = FIB_RES_DEV(res)->ifindex;
 	return;
+#else
+	found = FIB_RES_DEV(res);
+	if (found != oif)
+		return;
+#endif
 ok:
 	switch (priv->result) {
 	case NFT_FIB_RESULT_OIF:
-- 
2.9.0
