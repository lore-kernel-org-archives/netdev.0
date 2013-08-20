From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/19] netfilter: nf_nat: fix locking in nf_nat_seq_adjust()
Date: Tue, 20 Aug 2013 12:54:41 +0200
Message-ID: <1376996091-3964-10-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

nf_nat_seq_adjust() needs to grab nf_nat_seqofs_lock to protect against
concurrent changes to the sequence adjustment data.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_helper.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
index 85e20a9..a7262ed 100644
--- a/net/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -373,6 +373,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	s16 seqoff, ackoff;
 	struct nf_conn_nat *nat = nfct_nat(ct);
 	struct nf_nat_seq *this_way, *other_way;
+	int res;
 
 	dir = CTINFO2DIR(ctinfo);
 
@@ -383,6 +384,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 		return 0;
 
 	tcph = (void *)skb->data + protoff;
+	spin_lock_bh(&nf_nat_seqofs_lock);
 	if (after(ntohl(tcph->seq), this_way->correction_pos))
 		seqoff = this_way->offset_after;
 	else
@@ -407,7 +409,10 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	tcph->seq = newseq;
 	tcph->ack_seq = newack;
 
-	return nf_nat_sack_adjust(skb, protoff, tcph, ct, ctinfo);
+	res = nf_nat_sack_adjust(skb, protoff, tcph, ct, ctinfo);
+	spin_unlock_bh(&nf_nat_seqofs_lock);
+
+	return res;
 }
 
 /* Setup NAT on this expected conntrack so it follows master. */
-- 
1.7.10.4

