From: kaber@trash.net
Subject: [PATCH 79/79] netfilter: nf_conntrack: fix lifetime display for disabled connections
Date: Wed, 19 Jan 2011 20:15:19 +0100
Message-ID: <1295464519-21763-80-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

When no tstamp extension exists, ct_delta_time() returns -1, which is
then assigned to an u64 and tested for negative values to decide
whether to display the lifetime. This obviously doesn't work, use
a s64 and merge the two minor functions into one.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_standalone.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 69107fd..0ae1428 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -141,29 +141,24 @@ static inline int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
 #endif
 
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
-static u_int64_t ct_delta_time(u_int64_t time_now, const struct nf_conn *ct)
+static int ct_show_delta_time(struct seq_file *s, const struct nf_conn *ct)
 {
+	struct ct_iter_state *st = s->private;
 	struct nf_conn_tstamp *tstamp;
+	s64 delta_time;
 
 	tstamp = nf_conn_tstamp_find(ct);
 	if (tstamp) {
-		u_int64_t delta_time = time_now - tstamp->start;
-		return delta_time > 0 ? div_s64(delta_time, NSEC_PER_SEC) : 0;
+		delta_time = st->time_now - tstamp->start;
+		if (delta_time > 0)
+			delta_time = div_s64(delta_time, NSEC_PER_SEC);
+		else
+			delta_time = 0;
+
+		return seq_printf(s, "delta-time=%llu ",
+				  (unsigned long long)delta_time);
 	}
-	return -1;
-}
-
-static int ct_show_delta_time(struct seq_file *s, const struct nf_conn *ct)
-{
-	struct ct_iter_state *st = s->private;
-	u_int64_t delta_time;
-
-	delta_time = ct_delta_time(st->time_now, ct);
-	if (delta_time < 0)
-		return 0;
-
-	return seq_printf(s, "delta-time=%llu ",
-			  (unsigned long long)delta_time);
+	return 0;
 }
 #else
 static inline int
-- 
1.7.2.3

