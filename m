From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/14] netfilter: nf_tables: fix oops when inserting an element into a verdict map
Date: Thu, 10 Nov 2016 01:23:47 +0100
Message-ID: <1478737427-1574-15-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37752 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932278AbcKJAYM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id A1A379B7F7
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 923E2DA809
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A9E76DA817
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:09 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Dalegaard says:
 The following ruleset, when loaded with 'nft -f bad.txt'
 ----snip----
 flush ruleset
 table ip inlinenat {
   map sourcemap {
     type ipv4_addr : verdict;
   }

   chain postrouting {
     ip saddr vmap @sourcemap accept
   }
 }
 add chain inlinenat test
 add element inlinenat sourcemap { 100.123.10.2 : jump test }
 ----snip----

 results in a kernel oops:
 BUG: unable to handle kernel paging request at 0000000000001344
 IP: [<ffffffffa07bf704>] nf_tables_check_loops+0x114/0x1f0 [nf_tables]
 [...]
 Call Trace:
  [<ffffffffa07c2aae>] ? nft_data_init+0x13e/0x1a0 [nf_tables]
  [<ffffffffa07c1950>] nft_validate_register_store+0x60/0xb0 [nf_tables]
  [<ffffffffa07c74b5>] nft_add_set_elem+0x545/0x5e0 [nf_tables]
  [<ffffffffa07bfdd0>] ? nft_table_lookup+0x30/0x60 [nf_tables]
  [<ffffffff8132c630>] ? nla_strcmp+0x40/0x50
  [<ffffffffa07c766e>] nf_tables_newsetelem+0x11e/0x210 [nf_tables]
  [<ffffffff8132c400>] ? nla_validate+0x60/0x80
  [<ffffffffa030d9b4>] nfnetlink_rcv+0x354/0x5a7 [nfnetlink]

Because we forget to fill the net pointer in bind_ctx, so dereferencing
it may cause kernel crash.

Reported-by: Dalegaard <dalegaard@gmail.com>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7d6a626b08f1..026581b04ea8 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3568,6 +3568,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		dreg = nft_type_to_reg(set->dtype);
 		list_for_each_entry(binding, &set->bindings, list) {
 			struct nft_ctx bind_ctx = {
+				.net	= ctx->net,
 				.afi	= ctx->afi,
 				.table	= ctx->table,
 				.chain	= (struct nft_chain *)binding->chain,
-- 
2.1.4
