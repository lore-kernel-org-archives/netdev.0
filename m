From: fgao@ikuai8.com
Subject: [PATCH v2 1/2 nf] netfilter: seqadj: Fix one possible panic in seqadj when mem is exhausted
Date: Fri,  2 Sep 2016 13:08:52 +0800
Message-ID: <1472792932-26187-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
extension. But the function nf_ct_seqadj_init doesn't check if get valid
seqadj pointer by the nfct_seqadj, while other functions perform the
sanity check.

So the system would be panic when nfct_seqadj_ext_add failed.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Remove the unnessary seqadj check in nf_ct_seq_adjust
 v1: Inital patch

 net/netfilter/nf_conntrack_seqadj.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index dff0f0c..2c8e201 100644
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
-- 
1.9.1


