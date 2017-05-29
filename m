From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: nat: use atomic bit op to clear the _SRC_NAT_DONE_BIT
Date: Mon, 29 May 2017 13:34:31 +0200
Message-ID: <1496057672-6751-4-git-send-email-pablo@netfilter.org>
References: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

We need to clear the IPS_SRC_NAT_DONE_BIT to indicate that the ct has
been removed from nat_bysource table. But unfortunately, we use the
non-atomic bit operation: "ct->status &= ~IPS_NAT_DONE_MASK". So
there's a race condition that we may clear the _DYING_BIT set by
another CPU unexpectedly.

Since we don't care about the IPS_DST_NAT_DONE_BIT, so just using
clear_bit to clear the IPS_SRC_NAT_DONE_BIT is enough.

Also note, this is the last user which use the non-atomic bit operation
to update the confirmed ct->status.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index ef0be325a0c6..6c72922d20ca 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -566,7 +566,7 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 	 * Else, when the conntrack is destoyed, nf_nat_cleanup_conntrack()
 	 * will delete entry from already-freed table.
 	 */
-	ct->status &= ~IPS_NAT_DONE_MASK;
+	clear_bit(IPS_SRC_NAT_DONE_BIT, &ct->status);
 	rhltable_remove(&nf_nat_bysource_table, &ct->nat_bysource,
 			nf_nat_bysource_params);
 
-- 
2.1.4

