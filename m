From: fgao@ikuai8.com
Subject: [PATCH 1/2 nf] netfilter: seqadj: Fix some possible panics of seqadj when mem is exhausted
Date: Fri,  2 Sep 2016 09:48:25 +0800
Message-ID: <1472780905-13094-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg342.qq.com ([14.17.44.37]:57071 "EHLO smtpbg342.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750742AbcIBBs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 21:48:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
extension. But these interface functions nf_ct_seqadj_init and
nf_ct_seq_adjust don't check if they get the valid seqadj pointer by the
nfct_seqadj, while nf_ct_seqadj_set and nf_ct_seq_offset perform that
check. So the system would be panic when nfct_seqadj_ext_add failed.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/netfilter/nf_conntrack_seqadj.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index dff0f0c..2a2fd0e 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -16,9 +16,14 @@ int nf_ct_seqadj_init(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 	if (off == 0)
 		return 0;
 
+	seqadj = nfct_seqadj(ct);
+	if (unlikely(!seqadj)) {
+		WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
+		return 0;
+	}
+
 	set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
 
-	seqadj = nfct_seqadj(ct);
 	this_way = &seqadj->seq[dir];
 	this_way->offset_before	 = off;
 	this_way->offset_after	 = off;
@@ -171,6 +176,11 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
 	struct nf_ct_seqadj *this_way, *other_way;
 	int res;
 
+	if (unlikely(!seqadj)) {
+		WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
+		return 0;
+	}
+
 	this_way  = &seqadj->seq[dir];
 	other_way = &seqadj->seq[!dir];
 
@@ -218,8 +228,10 @@ s32 nf_ct_seq_offset(const struct nf_conn *ct,
 	struct nf_conn_seqadj *seqadj = nfct_seqadj(ct);
 	struct nf_ct_seqadj *this_way;
 
-	if (!seqadj)
+	if (unlikely(!seqadj)) {
+		WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
 		return 0;
+	}
 
 	this_way = &seqadj->seq[dir];
 	return after(seq, this_way->correction_pos) ?
-- 
1.9.1
