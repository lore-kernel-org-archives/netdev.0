From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: synproxy: Check oom when adding synproxy and seqadj ct extensions
Date: Tue, 13 Sep 2016 11:05:17 +0200
Message-ID: <1473757517-3764-5-git-send-email-pablo@netfilter.org>
References: <1473757517-3764-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473757517-3764-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

When memory is exhausted, nfct_seqadj_ext_add may fail to add the
synproxy and seqadj extensions. The function nf_ct_seqadj_init doesn't
check if get valid seqadj pointer by the nfct_seqadj.

Now drop the packet directly when fail to add seqadj extension to
avoid dereference NULL pointer in nf_ct_seqadj_init from
init_conntrack().

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_synproxy.h | 14 ++++++++++++++
 net/netfilter/nf_conntrack_core.c             |  6 +++---
 net/netfilter/nf_nat_core.c                   |  3 ++-
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_synproxy.h b/include/net/netfilter/nf_conntrack_synproxy.h
index 6793614..e693731 100644
--- a/include/net/netfilter/nf_conntrack_synproxy.h
+++ b/include/net/netfilter/nf_conntrack_synproxy.h
@@ -27,6 +27,20 @@ static inline struct nf_conn_synproxy *nfct_synproxy_ext_add(struct nf_conn *ct)
 #endif
 }
 
+static inline bool nf_ct_add_synproxy(struct nf_conn *ct,
+				      const struct nf_conn *tmpl)
+{
+	if (tmpl && nfct_synproxy(tmpl)) {
+		if (!nfct_seqadj_ext_add(ct))
+			return false;
+
+		if (!nfct_synproxy_ext_add(ct))
+			return false;
+	}
+
+	return true;
+}
+
 struct synproxy_stats {
 	unsigned int			syn_received;
 	unsigned int			cookie_invalid;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index dd2c43a..9934b0c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1035,9 +1035,9 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	if (IS_ERR(ct))
 		return (struct nf_conntrack_tuple_hash *)ct;
 
-	if (tmpl && nfct_synproxy(tmpl)) {
-		nfct_seqadj_ext_add(ct);
-		nfct_synproxy_ext_add(ct);
+	if (!nf_ct_add_synproxy(ct, tmpl)) {
+		nf_conntrack_free(ct);
+		return ERR_PTR(-ENOMEM);
 	}
 
 	timeout_ext = tmpl ? nf_ct_timeout_find(tmpl) : NULL;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 19c081e..ecee105 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -441,7 +441,8 @@ nf_nat_setup_info(struct nf_conn *ct,
 			ct->status |= IPS_DST_NAT;
 
 		if (nfct_help(ct))
-			nfct_seqadj_ext_add(ct);
+			if (!nfct_seqadj_ext_add(ct))
+				return NF_DROP;
 	}
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-- 
2.1.4

