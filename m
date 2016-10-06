From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: nft_limit: fix divided by zero panic
Date: Thu,  6 Oct 2016 02:07:49 +0200
Message-ID: <1475712469-17000-6-git-send-email-pablo@netfilter.org>
References: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

After I input the following nftables rule, a panic happened on my system:
  # nft add rule filter OUTPUT limit rate 0xf00000000 bytes/second

  divide error: 0000 [#1] SMP
  [ ... ]
  RIP: 0010:[<ffffffffa059035e>]  [<ffffffffa059035e>]
  nft_limit_pkt_bytes_eval+0x2e/0xa0 [nft_limit]
  Call Trace:
  [<ffffffffa05721bb>] nft_do_chain+0xfb/0x4e0 [nf_tables]
  [<ffffffffa044f236>] ? nf_nat_setup_info+0x96/0x480 [nf_nat]
  [<ffffffff81753767>] ? ipt_do_table+0x327/0x610
  [<ffffffffa044f677>] ? __nf_nat_alloc_null_binding+0x57/0x80 [nf_nat]
  [<ffffffffa058b21f>] nft_ipv4_output+0xaf/0xd0 [nf_tables_ipv4]
  [<ffffffff816f4aa2>] nf_iterate+0x62/0x80
  [<ffffffff816f4b33>] nf_hook_slow+0x73/0xd0
  [<ffffffff81703d0d>] __ip_local_out+0xcd/0xe0
  [<ffffffff81701d90>] ? ip_forward_options+0x1b0/0x1b0
  [<ffffffff81703d3c>] ip_local_out+0x1c/0x40

This is because divisor is 64-bit, but we treat it as a 32-bit integer,
then 0xf00000000 becomes zero, i.e. divisor becomes 0.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 070b98938e02..c6baf412236d 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -145,7 +145,7 @@ static int nft_limit_pkts_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	priv->cost = div_u64(priv->limit.nsecs, priv->limit.rate);
+	priv->cost = div64_u64(priv->limit.nsecs, priv->limit.rate);
 	return 0;
 }
 
@@ -170,7 +170,7 @@ static void nft_limit_pkt_bytes_eval(const struct nft_expr *expr,
 				     const struct nft_pktinfo *pkt)
 {
 	struct nft_limit *priv = nft_expr_priv(expr);
-	u64 cost = div_u64(priv->nsecs * pkt->skb->len, priv->rate);
+	u64 cost = div64_u64(priv->nsecs * pkt->skb->len, priv->rate);
 
 	if (nft_limit_eval(priv, cost))
 		regs->verdict.code = NFT_BREAK;
-- 
2.1.4

