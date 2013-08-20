From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/19] netfilter: nf_nat: use per-conntrack locking for sequence number adjustments
Date: Tue, 20 Aug 2013 12:54:43 +0200
Message-ID: <1376996091-3964-12-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60096 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab3HTKzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:13 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Get rid of the global lock and use per-conntrack locks for protecting the
sequencen number adjustment data. Additionally saves one lock/unlock
operation for every TCP packet.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_helper.c |   19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
index ff4a589..46b9baa 100644
--- a/net/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -30,8 +30,6 @@
 	pr_debug("offset_before=%d, offset_after=%d, correction_pos=%u\n", \
 		 x->offset_before, x->offset_after, x->correction_pos);
 
-static DEFINE_SPINLOCK(nf_nat_seqofs_lock);
-
 /* Setup TCP sequence correction given this change at this sequence */
 static inline void
 adjust_tcp_sequence(u32 seq,
@@ -49,7 +47,7 @@ adjust_tcp_sequence(u32 seq,
 	pr_debug("adjust_tcp_sequence: Seq_offset before: ");
 	DUMP_OFFSET(this_way);
 
-	spin_lock_bh(&nf_nat_seqofs_lock);
+	spin_lock_bh(&ct->lock);
 
 	/* SYN adjust. If it's uninitialized, or this is after last
 	 * correction, record it: we don't handle more than one
@@ -61,31 +59,26 @@ adjust_tcp_sequence(u32 seq,
 		this_way->offset_before = this_way->offset_after;
 		this_way->offset_after += sizediff;
 	}
-	spin_unlock_bh(&nf_nat_seqofs_lock);
+	spin_unlock_bh(&ct->lock);
 
 	pr_debug("adjust_tcp_sequence: Seq_offset after: ");
 	DUMP_OFFSET(this_way);
 }
 
-/* Get the offset value, for conntrack */
+/* Get the offset value, for conntrack. Caller must have the conntrack locked */
 s32 nf_nat_get_offset(const struct nf_conn *ct,
 		      enum ip_conntrack_dir dir,
 		      u32 seq)
 {
 	struct nf_conn_nat *nat = nfct_nat(ct);
 	struct nf_nat_seq *this_way;
-	s32 offset;
 
 	if (!nat)
 		return 0;
 
 	this_way = &nat->seq[dir];
-	spin_lock_bh(&nf_nat_seqofs_lock);
-	offset = after(seq, this_way->correction_pos)
+	return after(seq, this_way->correction_pos)
 		 ? this_way->offset_after : this_way->offset_before;
-	spin_unlock_bh(&nf_nat_seqofs_lock);
-
-	return offset;
 }
 
 /* Frobs data inside this packet, which is linear. */
@@ -384,7 +377,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 		return 0;
 
 	tcph = (void *)skb->data + protoff;
-	spin_lock_bh(&nf_nat_seqofs_lock);
+	spin_lock_bh(&ct->lock);
 	if (after(ntohl(tcph->seq), this_way->correction_pos))
 		seqoff = this_way->offset_after;
 	else
@@ -410,7 +403,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	tcph->ack_seq = newack;
 
 	res = nf_nat_sack_adjust(skb, protoff, tcph, ct, ctinfo);
-	spin_unlock_bh(&nf_nat_seqofs_lock);
+	spin_unlock_bh(&ct->lock);
 
 	return res;
 }
-- 
1.7.10.4
