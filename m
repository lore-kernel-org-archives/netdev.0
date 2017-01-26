From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/14] netfilter: nf_tables: fix possible oops when dumping stateful objects
Date: Thu, 26 Jan 2017 17:37:58 +0100
Message-ID: <1485448687-6072-6-git-send-email-pablo@netfilter.org>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48634 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753616AbdAZQjX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 11:39:23 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 889CD765A
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 79FE84EA92
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 45715A7BF1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:27 +0100 (CET)
In-Reply-To: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

When dumping nft stateful objects, if NFTA_OBJ_TABLE and NFTA_OBJ_TYPE
attributes are not specified either, filter will become NULL, so oops
will happen(actually nft utility will always set NFTA_OBJ_TABLE attr,
so I write a test program to make this happen):

  BUG: unable to handle kernel NULL pointer dereference at (null)
  IP: nf_tables_dump_obj+0x17c/0x330 [nf_tables]
  [...]
  Call Trace:
  ? nf_tables_dump_obj+0x5/0x330 [nf_tables]
  ? __kmalloc_reserve.isra.35+0x31/0x90
  ? __alloc_skb+0x5b/0x1e0
  netlink_dump+0x124/0x2a0
  __netlink_dump_start+0x161/0x190
  nf_tables_getobj+0xe8/0x280 [nf_tables]

Fixes: a9fea2a3c3cf ("netfilter: nf_tables: allow to filter stateful object dumps by type")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0db5f9782265..091d2dcc63b2 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4262,10 +4262,11 @@ static int nf_tables_dump_obj(struct sk_buff *skb, struct netlink_callback *cb)
 				if (idx > s_idx)
 					memset(&cb->args[1], 0,
 					       sizeof(cb->args) - sizeof(cb->args[0]));
-				if (filter->table[0] &&
+				if (filter && filter->table[0] &&
 				    strcmp(filter->table, table->name))
 					goto cont;
-				if (filter->type != NFT_OBJECT_UNSPEC &&
+				if (filter &&
+				    filter->type != NFT_OBJECT_UNSPEC &&
 				    obj->type->type != filter->type)
 					goto cont;
 
-- 
2.1.4
