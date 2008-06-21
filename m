From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 1/8] textsearch: fix textsearch for case insensitive searching
Date: Sat, 21 Jun 2008 00:53:58 -0700
Message-ID: <1214034838-1270-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function textsearch_prepare has new parameter to support case
insensitive searching.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/textsearch.h          |    6 ++++--
 lib/textsearch.c                    |    6 ++++--
 net/netfilter/nf_conntrack_amanda.c |    2 +-
 net/netfilter/xt_string.c           |    2 +-
 net/sched/em_text.c                 |    2 +-
 5 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/linux/textsearch.h b/include/linux/textsearch.h
index 6f371f2..b6897f3 100644
--- a/include/linux/textsearch.h
+++ b/include/linux/textsearch.h
@@ -39,7 +39,7 @@ struct ts_state
 struct ts_ops
 {
 	const char		*name;
-	struct ts_config *	(*init)(const void *, unsigned int, gfp_t);
+	struct ts_config *	(*init)(const void *, unsigned int, u8, gfp_t);
 	unsigned int		(*find)(struct ts_config *,
 					struct ts_state *);
 	void			(*destroy)(struct ts_config *);
@@ -52,12 +52,14 @@ struct ts_ops
 /**
  * struct ts_config - search configuration
  * @ops: operations of chosen algorithm
+ * @icase: ignore case
  * @get_next_block: callback to fetch the next block to search in
  * @finish: callback to finalize a search
  */
 struct ts_config
 {
 	struct ts_ops		*ops;
+	u8 			icase;
 
 	/**
 	 * get_next_block - fetch next block of data
@@ -147,7 +149,7 @@ static inline unsigned int textsearch_get_pattern_len(struct ts_config *conf)
 extern int textsearch_register(struct ts_ops *);
 extern int textsearch_unregister(struct ts_ops *);
 extern struct ts_config *textsearch_prepare(const char *, const void *,
-					    unsigned int, gfp_t, int);
+					    unsigned int, u8, gfp_t, int);
 extern void textsearch_destroy(struct ts_config *conf);
 extern unsigned int textsearch_find_continuous(struct ts_config *,
 					       struct ts_state *,
diff --git a/lib/textsearch.c b/lib/textsearch.c
index be8bda3..0832f76 100644
--- a/lib/textsearch.c
+++ b/lib/textsearch.c
@@ -238,6 +238,7 @@ unsigned int textsearch_find_continuous(struct ts_config *conf,
  * @algo: name of search algorithm
  * @pattern: pattern data
  * @len: length of pattern
+ * @icase: ignore case
  * @gfp_mask: allocation mask
  * @flags: search flags
  *
@@ -254,7 +255,8 @@ unsigned int textsearch_find_continuous(struct ts_config *conf,
  * function returns EINVAL.
  */
 struct ts_config *textsearch_prepare(const char *algo, const void *pattern,
-				     unsigned int len, gfp_t gfp_mask, int flags)
+				     unsigned int len, u8 icase,
+				     gfp_t gfp_mask, int flags)
 {
 	int err = -ENOENT;
 	struct ts_config *conf;
@@ -279,7 +281,7 @@ struct ts_config *textsearch_prepare(const char *algo, const void *pattern,
 	if (ops == NULL)
 		goto errout;
 
-	conf = ops->init(pattern, len, gfp_mask);
+	conf = ops->init(pattern, len, icase, gfp_mask);
 	if (IS_ERR(conf)) {
 		err = PTR_ERR(conf);
 		goto errout;
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 38aedee..3e77165 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -207,7 +207,7 @@ static int __init nf_conntrack_amanda_init(void)
 
 	for (i = 0; i < ARRAY_SIZE(search); i++) {
 		search[i].ts = textsearch_prepare(ts_algo, search[i].string,
-						  search[i].len,
+						  search[i].len, 0,
 						  GFP_KERNEL, TS_AUTOLOAD);
 		if (IS_ERR(search[i].ts)) {
 			ret = PTR_ERR(search[i].ts);
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index 72f694d..9508484 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -55,7 +55,7 @@ string_mt_check(const char *tablename, const void *ip,
 	if (conf->patlen > XT_STRING_MAX_PATTERN_SIZE)
 		return false;
 	ts_conf = textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
-				     GFP_KERNEL, TS_AUTOLOAD);
+				     0, GFP_KERNEL, TS_AUTOLOAD);
 	if (IS_ERR(ts_conf))
 		return false;
 
diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index 853c5ea..40c8a23 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -65,7 +65,7 @@ static int em_text_change(struct tcf_proto *tp, void *data, int len,
 
 retry:
 	ts_conf = textsearch_prepare(conf->algo, (u8 *) conf + sizeof(*conf),
-				     conf->pattern_len, GFP_KERNEL, flags);
+				     conf->pattern_len, 0, GFP_KERNEL, flags);
 
 	if (flags & TS_AUTOLOAD)
 		rtnl_lock();
-- 
1.5.4.3

