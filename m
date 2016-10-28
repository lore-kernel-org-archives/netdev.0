From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [rfc, netfilter-next] netfilter: nf_tables: fib warnings
Date: Fri, 28 Oct 2016 17:31:12 +0200
Message-ID: <20161028153124.3773180-1-arnd@arndb.de>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added nft fib code produces two warnings:

net/ipv4/netfilter/nft_fib_ipv4.c: In function 'nft_fib4_eval':
net/ipv4/netfilter/nft_fib_ipv4.c:80:6: error: unused variable 'i' [-Werror=unused-variable]
net/ipv4/netfilter/nft_fib_ipv4.c: In function ‘nft_fib4_eval’:
net/ipv4/netfilter/nft_fib_ipv4.c:137:6: error: ‘oif’ may be used uninitialized in this function [-Werror=maybe-uninitialized]

The first one is obvious as the only user of that variable is
inside of an #ifdef, but the second one is a bit trickier.
It is clear that 'oif' is uninitialized here if neither
NFTA_FIB_F_OIF nor NFTA_FIB_F_IIF are set.

I have no idea how that should be handled, this patch just
returns without doing anything, which may or may not be
the right thing to do.

Fixes: 84f5eedb983e ("netfilter: nf_tables: add fib expression")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/netfilter/nft_fib_ipv4.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index 6787c563cfc9..b29f70593e8b 100644
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
+		return;
 
 	if (pkt->hook == NF_INET_PRE_ROUTING && fib4_is_local(pkt->skb)) {
 		nft_fib_store_result(dest, priv->result, pkt, LOOPBACK_IFINDEX);
-- 
2.9.0
