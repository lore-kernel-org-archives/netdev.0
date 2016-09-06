From: fgao@ikuai8.com
Subject: [PATCH v5 nf] netfilter: seqadj: Drop the packet directly when fail to add seqadj extension to avoid dereference NULL pointer later
Date: Tue,  6 Sep 2016 22:43:55 +0800
Message-ID: <1473173035-2175-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org, fw@strlen.de,
        coreteam@netfilter.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
extension. But the function nf_ct_seqadj_init doesn't check if get valid
seqadj pointer by the nfct_seqadj.

Now drop the packet directly when fail to add seqadj extension to avoid
dereference NULL pointer in nf_ct_seqadj_init.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v5: Return NF_ACCEPT instead of NF_DROP when nfct_seqadj_ext_add failed in nf_nat_setup_info
 v4: Drop the packet directly when fail to add seqadj extension;
 v3: Remove the warning log when seqadj is null;
 v2: Remove the unnessary seqadj check in nf_ct_seq_adjust
 v1: Initial patch

 net/netfilter/nf_conntrack_core.c | 6 +++++-
 net/netfilter/nf_nat_core.c       | 3 ++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index dd2c43a..dfa76ce 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1036,7 +1036,11 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		return (struct nf_conntrack_tuple_hash *)ct;
 
 	if (tmpl && nfct_synproxy(tmpl)) {
-		nfct_seqadj_ext_add(ct);
+		if (!nfct_seqadj_ext_add(ct)) {
+			nf_conntrack_free(ct);
+			pr_debug("Can't add seqadj extension\n");
+			return NULL;
+		}
 		nfct_synproxy_ext_add(ct);
 	}
 
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index de31818..f8b916a 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -441,7 +441,8 @@ nf_nat_setup_info(struct nf_conn *ct,
 			ct->status |= IPS_DST_NAT;
 
 		if (nfct_help(ct))
-			nfct_seqadj_ext_add(ct);
+			if (!nfct_seqadj_ext_add(ct))
+				return NF_ACCEPT;
 	}
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-- 
1.9.1


