From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v2] netfilter: fix type mismatch with error return from nft_parse_u32_check
Date: Tue, 25 Oct 2016 15:56:39 -0400
Message-ID: <1477425399-28480-1-git-send-email-linville@tuxdriver.com>
References: <1477422484-27030-1-git-send-email-linville@tuxdriver.com>
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Laura Garcia Liebana <nevola@gmail.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Dan Carpenter <dan.carpenter@oracle.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33285 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759345AbcJYUAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 16:00:23 -0400
In-Reply-To: <1477422484-27030-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 36b701fae12ac ("netfilter: nf_tables: validate maximum value of
u32 netlink attributes") introduced nft_parse_u32_check with a return
value of "unsigned int", yet on error it returns "-ERANGE".

This patch corrects the mismatch by changing the return value to "int",
which happens to match the actual users of nft_parse_u32_check already.

Found by Coverity, CID 1373930.

Note that commit 21a9e0f1568ea ("netfilter: nft_exthdr: fix error
handling in nft_exthdr_init()) attempted to address the issue, but
did not address the return type of nft_parse_u32_check.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Cc: Laura Garcia Liebana <nevola@gmail.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 36b701fae12ac ("netfilter: nf_tables: validate maximum value...")
---
 include/net/netfilter/nf_tables.h | 2 +-
 net/netfilter/nf_tables_api.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 5031e072567b..da43f50b39c6 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -145,7 +145,7 @@ static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
 	return type == NFT_DATA_VERDICT ? NFT_REG_VERDICT : NFT_REG_1 * NFT_REG_SIZE / NFT_REG32_SIZE;
 }
 
-unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest);
+int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest);
 unsigned int nft_parse_register(const struct nlattr *attr);
 int nft_dump_register(struct sk_buff *skb, unsigned int attr, unsigned int reg);
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 24db22257586..32fa4f08444a 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4421,7 +4421,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
  *	Otherwise a 0 is returned and the attribute value is stored in the
  *	destination variable.
  */
-unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
+int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
 {
 	u32 val;
 
-- 
2.7.4
