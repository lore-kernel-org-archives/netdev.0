From: Igor Pylypiv <igor.pylypiv@gmail.com>
Subject: [PATCH] Revert "net: Remove state argument from skb_find_text()"
Date: Sat,  4 Feb 2017 21:48:30 -0800
Message-ID: <1486273710-18457-1-git-send-email-igor.pylypiv@gmail.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
To: "David S . Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35109 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbdBEFug (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 00:50:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 059a2440fd3cf4ec57735db2c0a90401cde84fca.

Textsearch state parameter should be passed by pointer because
its resulting value is needed for call to textsearch_next().

Signed-off-by: Igor Pylypiv <igor.pylypiv@gmail.com>
---
 include/linux/skbuff.h              |  3 ++-
 net/core/skbuff.c                   |  9 +++++----
 net/netfilter/nf_conntrack_amanda.c | 10 +++++++---
 net/netfilter/xt_string.c           |  3 ++-
 net/sched/em_text.c                 |  3 ++-
 5 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 11b60b6..70110ca 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1028,7 +1028,8 @@ unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
 void skb_abort_seq_read(struct skb_seq_state *st);
 
 unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
-			   unsigned int to, struct ts_config *config);
+			   unsigned int to, struct ts_config *config,
+			   struct ts_state *state);
 
 /*
  * Packet hash types specify the type of hash in skb_set_hash.
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index daa6058..3041763 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2918,6 +2918,7 @@ static void skb_ts_finish(struct ts_config *conf, struct ts_state *state)
  * @from: search offset
  * @to: search limit
  * @config: textsearch configuration
+ * @state: uninitialized textsearch state variable
  *
  * Finds a pattern in the skb data according to the specified
  * textsearch configuration. Use textsearch_next() to retrieve
@@ -2925,17 +2926,17 @@ static void skb_ts_finish(struct ts_config *conf, struct ts_state *state)
  * to the first occurrence or UINT_MAX if no match was found.
  */
 unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
-			   unsigned int to, struct ts_config *config)
+			   unsigned int to, struct ts_config *config,
+			   struct ts_state *state)
 {
-	struct ts_state state;
 	unsigned int ret;
 
 	config->get_next_block = skb_ts_get_next_block;
 	config->finish = skb_ts_finish;
 
-	skb_prepare_seq_read(skb, from, to, TS_SKB_CB(&state));
+	skb_prepare_seq_read(skb, from, to, TS_SKB_CB(state));
 
-	ret = textsearch_find(config, &state);
+	ret = textsearch_find(config, state);
 	return (ret <= to - from ? ret : UINT_MAX);
 }
 EXPORT_SYMBOL(skb_find_text);
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 57a26cc..b8b95f4 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -88,6 +88,7 @@ static int amanda_help(struct sk_buff *skb,
 		       struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo)
 {
+	struct ts_state ts;
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple *tuple;
 	unsigned int dataoff, start, stop, off, i;
@@ -112,20 +113,23 @@ static int amanda_help(struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
 
+	memset(&ts, 0, sizeof(ts));
 	start = skb_find_text(skb, dataoff, skb->len,
-			      search[SEARCH_CONNECT].ts);
+			      search[SEARCH_CONNECT].ts, &ts);
 	if (start == UINT_MAX)
 		goto out;
 	start += dataoff + search[SEARCH_CONNECT].len;
 
+	memset(&ts, 0, sizeof(ts));
 	stop = skb_find_text(skb, start, skb->len,
-			     search[SEARCH_NEWLINE].ts);
+			     search[SEARCH_NEWLINE].ts, &ts);
 	if (stop == UINT_MAX)
 		goto out;
 	stop += start;
 
 	for (i = SEARCH_DATA; i <= SEARCH_INDEX; i++) {
-		off = skb_find_text(skb, start, stop, search[i].ts);
+		memset(&ts, 0, sizeof(ts));
+		off = skb_find_text(skb, start, stop, search[i].ts, &ts);
 		if (off == UINT_MAX)
 			continue;
 		off += start + search[i].len;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index 423293e..055a6aa 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -26,12 +26,13 @@ static bool
 string_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_string_info *conf = par->matchinfo;
+	struct ts_state state;
 	bool invert;
 
 	invert = conf->u.v1.flags & XT_STRING_FLAG_INVERT;
 
 	return (skb_find_text((struct sk_buff *)skb, conf->from_offset,
-			     conf->to_offset, conf->config)
+			     conf->to_offset, conf->config, &state)
 			     != UINT_MAX) ^ invert;
 }
 
diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index 73e2ed5..f03c3de 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -34,6 +34,7 @@ static int em_text_match(struct sk_buff *skb, struct tcf_ematch *m,
 {
 	struct text_match *tm = EM_TEXT_PRIV(m);
 	int from, to;
+	struct ts_state state;
 
 	from = tcf_get_base_ptr(skb, tm->from_layer) - skb->data;
 	from += tm->from_offset;
@@ -41,7 +42,7 @@ static int em_text_match(struct sk_buff *skb, struct tcf_ematch *m,
 	to = tcf_get_base_ptr(skb, tm->to_layer) - skb->data;
 	to += tm->to_offset;
 
-	return skb_find_text(skb, from, to, tm->config) != UINT_MAX;
+	return skb_find_text(skb, from, to, tm->config, &state) != UINT_MAX;
 }
 
 static int em_text_change(struct net *net, void *data, int len,
-- 
2.7.4
