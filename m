From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/25] netfilter: nf_tables: handle more than 8 * PAGE_SIZE set name allocations
Date: Wed, 21 May 2014 11:43:05 +0200
Message-ID: <1400665402-5835-8-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

We currently have a limit of 8 * PAGE_SIZE anonymous sets. Lift that limit
by continuing the scan if the entire page is exhausted.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 60feca9..1c5e633 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2049,7 +2049,7 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 	const struct nft_set *i;
 	const char *p;
 	unsigned long *inuse;
-	unsigned int n = 0;
+	unsigned int n = 0, min = 0;
 
 	p = strnchr(name, IFNAMSIZ, '%');
 	if (p != NULL) {
@@ -2059,23 +2059,28 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 		inuse = (unsigned long *)get_zeroed_page(GFP_KERNEL);
 		if (inuse == NULL)
 			return -ENOMEM;
-
+cont:
 		list_for_each_entry(i, &ctx->table->sets, list) {
 			int tmp;
 
 			if (!sscanf(i->name, name, &tmp))
 				continue;
-			if (tmp < 0 || tmp >= BITS_PER_BYTE * PAGE_SIZE)
+			if (tmp < min || tmp >= min + BITS_PER_BYTE * PAGE_SIZE)
 				continue;
 
-			set_bit(tmp, inuse);
+			set_bit(tmp - min, inuse);
 		}
 
 		n = find_first_zero_bit(inuse, BITS_PER_BYTE * PAGE_SIZE);
+		if (n >= BITS_PER_BYTE * PAGE_SIZE) {
+			min += BITS_PER_BYTE * PAGE_SIZE;
+			memset(inuse, 0, PAGE_SIZE);
+			goto cont;
+		}
 		free_page((unsigned long)inuse);
 	}
 
-	snprintf(set->name, sizeof(set->name), name, n);
+	snprintf(set->name, sizeof(set->name), name, min + n);
 	list_for_each_entry(i, &ctx->table->sets, list) {
 		if (!strcmp(set->name, i->name))
 			return -ENFILE;
-- 
1.7.10.4

