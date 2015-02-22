From: Bojan Prtvar <prtvar.b@gmail.com>
Subject: [PATCH v2] net: Remove state argument from skb_find_text()
Date: Sun, 22 Feb 2015 11:46:35 +0100
Message-ID: <1424601995-17318-1-git-send-email-prtvar.b@gmail.com>
Cc: tgraf@suug.ch, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, dan.carpenter@oracle.com,
	davem@davemloft.net, Bojan Prtvar <prtvar.b@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:55363 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbbBVKqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 05:46:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although it is clear that textsearch state is intentionally passed to
skb_find_text() as uninitialized argument, it was never used by the
callers. Therefore, we can simplify skb_find_text() by making it
local variable.

Signed-off-by: Bojan Prtvar <prtvar.b@gmail.com>
---
v2: Rebased against current linux-next

 include/linux/skbuff.h              |    3 +--
 net/core/skbuff.c                   |    9 ++++-----
 net/netfilter/nf_conntrack_amanda.c |   10 +++-------
 net/netfilter/xt_string.c           |    3 +--
 net/sched/em_text.c                 |    3 +--
 5 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 30007af..d898b32 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -870,8 +870,7 @@ unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
 void skb_abort_seq_read(struct skb_seq_state *st);
 
 unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
-			   unsigned int to, struct ts_config *config,
-			   struct ts_state *state);
+			   unsigned int to, struct ts_config *config);
 
 /*
  * Packet hash types specify the type of hash in skb_set_hash.
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 88c613e..374e43b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2865,7 +2865,6 @@ static void skb_ts_finish(struct ts_config *conf, struct ts_state *state)
  * @from: search offset
  * @to: search limit
  * @config: textsearch configuration
- * @state: uninitialized textsearch state variable
  *
  * Finds a pattern in the skb data according to the specified
  * textsearch configuration. Use textsearch_next() to retrieve
@@ -2873,17 +2872,17 @@ static void skb_ts_finish(struct ts_config *conf, struct ts_state *state)
  * to the first occurrence or UINT_MAX if no match was found.
  */
 unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
-			   unsigned int to, struct ts_config *config,
-			   struct ts_state *state)
+			   unsigned int to, struct ts_config *config)
 {
+	struct ts_state state;
 	unsigned int ret;
 
 	config->get_next_block = skb_ts_get_next_block;
 	config->finish = skb_ts_finish;
 
-	skb_prepare_seq_read(skb, from, to, TS_SKB_CB(state));
+	skb_prepare_seq_read(skb, from, to, TS_SKB_CB(&state));
 
-	ret = textsearch_find(config, state);
+	ret = textsearch_find(config, &state);
 	return (ret <= to - from ? ret : UINT_MAX);
 }
 EXPORT_SYMBOL(skb_find_text);
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index b8b95f4..57a26cc 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -88,7 +88,6 @@ static int amanda_help(struct sk_buff *skb,
 		       struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo)
 {
-	struct ts_state ts;
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple *tuple;
 	unsigned int dataoff, start, stop, off, i;
@@ -113,23 +112,20 @@ static int amanda_help(struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
 
-	memset(&ts, 0, sizeof(ts));
 	start = skb_find_text(skb, dataoff, skb->len,
-			      search[SEARCH_CONNECT].ts, &ts);
+			      search[SEARCH_CONNECT].ts);
 	if (start == UINT_MAX)
 		goto out;
 	start += dataoff + search[SEARCH_CONNECT].len;
 
-	memset(&ts, 0, sizeof(ts));
 	stop = skb_find_text(skb, start, skb->len,
-			     search[SEARCH_NEWLINE].ts, &ts);
+			     search[SEARCH_NEWLINE].ts);
 	if (stop == UINT_MAX)
 		goto out;
 	stop += start;
 
 	for (i = SEARCH_DATA; i <= SEARCH_INDEX; i++) {
-		memset(&ts, 0, sizeof(ts));
-		off = skb_find_text(skb, start, stop, search[i].ts, &ts);
+		off = skb_find_text(skb, start, stop, search[i].ts);
 		if (off == UINT_MAX)
 			continue;
 		off += start + search[i].len;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index 5699adb..0bc3460 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -26,13 +26,12 @@ static bool
 string_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_string_info *conf = par->matchinfo;
-	struct ts_state state;
 	bool invert;
 
 	invert = conf->u.v1.flags & XT_STRING_FLAG_INVERT;
 
 	return (skb_find_text((struct sk_buff *)skb, conf->from_offset,
-			     conf->to_offset, conf->config, &state)
+			     conf->to_offset, conf->config)
 			     != UINT_MAX) ^ invert;
 }
 
diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index f03c3de..73e2ed5 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -34,7 +34,6 @@ static int em_text_match(struct sk_buff *skb, struct tcf_ematch *m,
 {
 	struct text_match *tm = EM_TEXT_PRIV(m);
 	int from, to;
-	struct ts_state state;
 
 	from = tcf_get_base_ptr(skb, tm->from_layer) - skb->data;
 	from += tm->from_offset;
@@ -42,7 +41,7 @@ static int em_text_match(struct sk_buff *skb, struct tcf_ematch *m,
 	to = tcf_get_base_ptr(skb, tm->to_layer) - skb->data;
 	to += tm->to_offset;
 
-	return skb_find_text(skb, from, to, tm->config, &state) != UINT_MAX;
+	return skb_find_text(skb, from, to, tm->config) != UINT_MAX;
 }
 
 static int em_text_change(struct net *net, void *data, int len,
-- 
1.7.9.5
