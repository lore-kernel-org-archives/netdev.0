From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/18] netfilter: nf_tables: fix oops when deleting a chain with references
Date: Fri,  7 Feb 2014 18:41:29 +0100
Message-ID: <1391794904-4017-4-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The following commands trigger an oops:

 # nft -i
 nft> add table filter
 nft> add chain filter input { type filter hook input priority 0; }
 nft> add chain filter test
 nft> add rule filter input jump test
 nft> delete chain filter test

We need to check the chain use counter before allowing destruction since
we might have references from sets or jump rules.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=69341
Reported-by: Matthew Ife <deleriux1@gmail.com>
Tested-by: Matthew Ife <deleriux1@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 117bbaa..9ce3053 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1045,7 +1045,7 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(chain))
 		return PTR_ERR(chain);
 
-	if (!list_empty(&chain->rules))
+	if (!list_empty(&chain->rules) || chain->use > 0)
 		return -EBUSY;
 
 	list_del(&chain->list);
-- 
1.7.10.4

