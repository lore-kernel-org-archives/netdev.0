From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/14] netfilter: nf_tables: fix type mismatch with error return from nft_parse_u32_check
Date: Thu, 10 Nov 2016 01:23:38 +0100
Message-ID: <1478737427-1574-6-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37752 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754756AbcKJAYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E5D679662B
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D5E17DA804
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 75975DA804
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:01 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>

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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 2 +-
 net/netfilter/nf_tables_api.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 741dcded5b4f..d79d1e9b9546 100644
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
index 86e48aeb20be..365d31b86816 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4422,7 +4422,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
  *	Otherwise a 0 is returned and the attribute value is stored in the
  *	destination variable.
  */
-unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
+int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
 {
 	u32 val;
 
-- 
2.1.4
