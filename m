From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/13] netfilter: nf_tables: fix type in parsing in nf_tables_set_alloc_name()
Date: Mon,  6 Jan 2014 14:46:40 +0100
Message-ID: <1389016002-9116-12-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>

In nf_tables_set_alloc_name(), we are trying to find a new, unused
name for our new set and interate through the list of present sets.
As far as I can see, we're using format string %d to parse already
present names in order to mark their presence in a bitmap, so that
we can later on find the first 0 in that map to assign the new set
name to. We should rather use a temporary variable of type int to
store the result of sscanf() to, and for making sanity checks on.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 604512d..aa4df58 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1954,11 +1954,14 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 			return -ENOMEM;
 
 		list_for_each_entry(i, &ctx->table->sets, list) {
-			if (!sscanf(i->name, name, &n))
+			int tmp;
+
+			if (!sscanf(i->name, name, &tmp))
 				continue;
-			if (n < 0 || n > BITS_PER_LONG * PAGE_SIZE)
+			if (tmp < 0 || tmp > BITS_PER_LONG * PAGE_SIZE)
 				continue;
-			set_bit(n, inuse);
+
+			set_bit(tmp, inuse);
 		}
 
 		n = find_first_zero_bit(inuse, BITS_PER_LONG * PAGE_SIZE);
-- 
1.7.10.4

