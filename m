From: fgao@ikuai8.com
Subject: [PATCH nf] netfilter: seqadj: Fix the wrong ack adjust for the RST packet without ack
Date: Tue,  6 Sep 2016 10:06:07 +0800
Message-ID: <1473127567-10419-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org, fw@strlen.de,
        coreteam@netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG252.QQ.COM ([183.60.52.105]:35614 "EHLO smtpbg252.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753180AbcIFCJM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 22:09:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

It is valid that the TCP RST packet which does not set ack flag, and bytes
of ack number are zero. For these RST packets, seqadj could not adjust the
ack number.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Regenerate because the first patch is removed
 v1: Initial patch

 net/netfilter/nf_conntrack_seqadj.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index dff0f0c..3bd9c7e 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -179,30 +179,34 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
 
 	tcph = (void *)skb->data + protoff;
 	spin_lock_bh(&ct->lock);
+
 	if (after(ntohl(tcph->seq), this_way->correction_pos))
 		seqoff = this_way->offset_after;
 	else
 		seqoff = this_way->offset_before;
 
-	if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
-		  other_way->correction_pos))
-		ackoff = other_way->offset_after;
-	else
-		ackoff = other_way->offset_before;
-
 	newseq = htonl(ntohl(tcph->seq) + seqoff);
-	newack = htonl(ntohl(tcph->ack_seq) - ackoff);
-
 	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, false);
-	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack,
-				 false);
-
-	pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
-		 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
-		 ntohl(newack));
 
+	pr_debug("Adjusting sequence number from %u->%u\n",
+		 ntohl(tcph->seq), ntohl(newseq));
 	tcph->seq = newseq;
-	tcph->ack_seq = newack;
+
+	if (likely(tcph->ack)) {
+		if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
+			  other_way->correction_pos))
+			ackoff = other_way->offset_after;
+		else
+			ackoff = other_way->offset_before;
+
+		newack = htonl(ntohl(tcph->ack_seq) - ackoff);
+		inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq,
+					 newack, false);
+
+		pr_debug("Adjusting ack number from %u->%u\n",
+			 ntohl(tcph->ack_seq), ntohl(newack));
+		tcph->ack_seq = newack;
+	}
 
 	res = nf_ct_sack_adjust(skb, protoff, tcph, ct, ctinfo);
 	spin_unlock_bh(&ct->lock);
-- 
1.9.1
