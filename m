From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 9/9] netfilter: nf_tables: check for unset NFTA_SET_ELEM_LIST_ELEMENTS attribute
Date: Thu, 31 Jul 2014 21:27:08 +0200
Message-ID: <1406834828-8500-10-git-send-email-pablo@netfilter.org>
References: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35684 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040AbaGaT1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 15:27:20 -0400
In-Reply-To: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, the kernel oopses in nla_for_each_nested when iterating over
the unset attribute NFTA_SET_ELEM_LIST_ELEMENTS in the
nf_tables_{new,del}setelem() path.

netlink: 65524 bytes leftover after parsing attributes in process `nft'.
[...]
Oops: 0000 [#1] SMP
[...]
CPU: 2 PID: 6287 Comm: nft Not tainted 3.16.0-rc2+ #169
RIP: 0010:[<ffffffffa0526e61>]  [<ffffffffa0526e61>] nf_tables_newsetelem+0x82/0xec [nf_tables]
[...]
Call Trace:
 [<ffffffffa05178c4>] nfnetlink_rcv+0x2e7/0x3d7 [nfnetlink]
 [<ffffffffa0517939>] ? nfnetlink_rcv+0x35c/0x3d7 [nfnetlink]
 [<ffffffff8137d300>] netlink_unicast+0xf8/0x17a
 [<ffffffff8137d6a5>] netlink_sendmsg+0x323/0x351
[...]

Fix this by returning -EINVAL if this attribute is not set, which
doesn't make sense at all since those commands are there to add and to
delete elements from the set.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ecffb26..93692d6 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3073,6 +3073,9 @@ static int nf_tables_newsetelem(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_ctx ctx;
 	int rem, err = 0;
 
+	if (nla[NFTA_SET_ELEM_LIST_ELEMENTS] == NULL)
+		return -EINVAL;
+
 	err = nft_ctx_init_from_elemattr(&ctx, skb, nlh, nla, true);
 	if (err < 0)
 		return err;
@@ -3156,6 +3159,9 @@ static int nf_tables_delsetelem(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_ctx ctx;
 	int rem, err = 0;
 
+	if (nla[NFTA_SET_ELEM_LIST_ELEMENTS] == NULL)
+		return -EINVAL;
+
 	err = nft_ctx_init_from_elemattr(&ctx, skb, nlh, nla, false);
 	if (err < 0)
 		return err;
-- 
1.7.10.4
