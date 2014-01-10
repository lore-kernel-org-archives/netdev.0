From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/23] netfilter: nf_tables: perform flags validation before table allocation
Date: Fri, 10 Jan 2014 01:35:38 +0100
Message-ID: <1389314142-17969-20-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Simplifies error handling. Additionally use the correct type u32 for the
host byte order flags value.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index c8ca3b8..88f9c94 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -366,7 +366,7 @@ static int nf_tables_updtable(struct sock *nlsk, struct sk_buff *skb,
 	int family = nfmsg->nfgen_family, ret = 0;
 
 	if (nla[NFTA_TABLE_FLAGS]) {
-		__be32 flags;
+		u32 flags;
 
 		flags = ntohl(nla_get_be32(nla[NFTA_TABLE_FLAGS]));
 		if (flags & ~NFT_TABLE_F_DORMANT)
@@ -402,6 +402,7 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_table *table;
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
+	u32 flags = 0;
 
 	afi = nf_tables_afinfo_lookup(net, family, true);
 	if (IS_ERR(afi))
@@ -423,6 +424,12 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 		return nf_tables_updtable(nlsk, skb, nlh, nla, afi, table);
 	}
 
+	if (nla[NFTA_TABLE_FLAGS]) {
+		flags = ntohl(nla_get_be32(nla[NFTA_TABLE_FLAGS]));
+		if (flags & ~NFT_TABLE_F_DORMANT)
+			return -EINVAL;
+	}
+
 	table = kzalloc(sizeof(*table) + nla_len(name), GFP_KERNEL);
 	if (table == NULL)
 		return -ENOMEM;
@@ -430,18 +437,7 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	nla_strlcpy(table->name, name, nla_len(name));
 	INIT_LIST_HEAD(&table->chains);
 	INIT_LIST_HEAD(&table->sets);
-
-	if (nla[NFTA_TABLE_FLAGS]) {
-		__be32 flags;
-
-		flags = ntohl(nla_get_be32(nla[NFTA_TABLE_FLAGS]));
-		if (flags & ~NFT_TABLE_F_DORMANT) {
-			kfree(table);
-			return -EINVAL;
-		}
-
-		table->flags |= flags;
-	}
+	table->flags = flags;
 
 	list_add_tail(&table->list, &afi->tables);
 	nf_tables_table_notify(skb, nlh, table, NFT_MSG_NEWTABLE, family);
-- 
1.7.10.4

