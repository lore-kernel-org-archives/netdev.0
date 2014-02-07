From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/18] netfilter: nf_tables: fix potential oops when dumping sets
Date: Fri,  7 Feb 2014 18:41:34 +0100
Message-ID: <1391794904-4017-9-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41419 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800AbaBGRmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:05 -0500
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Commit c9c8e48597 (netfilter: nf_tables: dump sets in all existing families)
changed nft_ctx_init_from_setattr() to only look up the address family if it
is not NFPROTO_UNSPEC. However if it is NFPROTO_UNSPEC and a table attribute
is given, nftables_afinfo_lookup() will dereference the NULL afi pointer.

Fix by checking for non-NULL afi and also move a check added by that commit
to the proper position.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2a22a18..3c5a219 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1943,6 +1943,9 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx,
 	}
 
 	if (nla[NFTA_SET_TABLE] != NULL) {
+		if (afi == NULL)
+			return -EAFNOSUPPORT;
+
 		table = nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE]);
 		if (IS_ERR(table))
 			return PTR_ERR(table);
@@ -2428,6 +2431,8 @@ static int nf_tables_delset(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_ctx ctx;
 	int err;
 
+	if (nfmsg->nfgen_family == NFPROTO_UNSPEC)
+		return -EAFNOSUPPORT;
 	if (nla[NFTA_SET_TABLE] == NULL)
 		return -EINVAL;
 
@@ -2435,9 +2440,6 @@ static int nf_tables_delset(struct sock *nlsk, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	if (nfmsg->nfgen_family == NFPROTO_UNSPEC)
-		return -EAFNOSUPPORT;
-
 	set = nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME]);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
-- 
1.7.10.4
