From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 1/8 v2] textsearch: fix textsearch for case insensitive searching
Date: Wed, 25 Jun 2008 03:24:53 -0700
Message-ID: <1214389493-21305-1-git-send-email-joonwpark81@gmail.com>
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

The function textsearch_prepare has a new flag to support case
insensitive searching.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/textsearch.h |   10 +++++-----
 lib/textsearch.c           |   14 ++++++++------
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/linux/textsearch.h b/include/linux/textsearch.h
index 6f371f2..6c34cf2 100644
--- a/include/linux/textsearch.h
+++ b/include/linux/textsearch.h
@@ -10,10 +10,8 @@
 
 struct ts_config;
 
-/**
- * TS_AUTOLOAD - Automatically load textsearch modules when needed
- */
-#define TS_AUTOLOAD	1
+#define TS_AUTOLOAD	1 /* Automatically load textsearch modules when needed */
+#define TS_IGNORECASE	2 /* Searches string case insensitively */
 
 /**
  * struct ts_state - search state
@@ -39,7 +37,7 @@ struct ts_state
 struct ts_ops
 {
 	const char		*name;
-	struct ts_config *	(*init)(const void *, unsigned int, gfp_t);
+	struct ts_config *	(*init)(const void *, unsigned int, gfp_t, int);
 	unsigned int		(*find)(struct ts_config *,
 					struct ts_state *);
 	void			(*destroy)(struct ts_config *);
@@ -52,12 +50,14 @@ struct ts_ops
 /**
  * struct ts_config - search configuration
  * @ops: operations of chosen algorithm
+ * @flags: flags
  * @get_next_block: callback to fetch the next block to search in
  * @finish: callback to finalize a search
  */
 struct ts_config
 {
 	struct ts_ops		*ops;
+	int 			flags;
 
 	/**
 	 * get_next_block - fetch next block of data
diff --git a/lib/textsearch.c b/lib/textsearch.c
index be8bda3..b451fcc 100644
--- a/lib/textsearch.c
+++ b/lib/textsearch.c
@@ -54,10 +54,13 @@
  * USAGE
  *
  *   Before a search can be performed, a configuration must be created
- *   by calling textsearch_prepare() specyfing the searching algorithm and
- *   the pattern to look for. The returned configuration may then be used
- *   for an arbitary amount of times and even in parallel as long as a
- *   separate struct ts_state variable is provided to every instance.
+ *   by calling textsearch_prepare() specifying the searching algorithm,
+ *   the pattern to look for and flags. As a flag, you can set TS_IGNORECASE
+ *   to perform case insensitive matching. But it might slow down
+ *   performance of algorithm, so you should use it at own your risk.
+ *   The returned configuration may then be used for an arbitary
+ *   amount of times and even in parallel as long as a separate struct
+ *   ts_state variable is provided to every instance.
  *
  *   The actual search is performed by either calling textsearch_find_-
  *   continuous() for linear data or by providing an own get_next_block()
@@ -89,7 +92,6 @@
  *       panic("Oh my god, dancing chickens at %d\n", pos);
  *
  *   textsearch_destroy(conf);
- *
  * ==========================================================================
  */
 
@@ -279,7 +281,7 @@ struct ts_config *textsearch_prepare(const char *algo, const void *pattern,
 	if (ops == NULL)
 		goto errout;
 
-	conf = ops->init(pattern, len, gfp_mask);
+	conf = ops->init(pattern, len, gfp_mask, flags);
 	if (IS_ERR(conf)) {
 		err = PTR_ERR(conf);
 		goto errout;
-- 
1.5.4.3

