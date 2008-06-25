From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 6/8 v2] netfilter: fix string extension for case insensitive pattern matching
Date: Wed, 25 Jun 2008 03:25:05 -0700
Message-ID: <1214389505-21405-1-git-send-email-joonwpark81@gmail.com>
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

The flag XT_STRING_FLAG_IGNORECASE indicates case insensitive string
matching.
netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/netfilter/xt_string.h |    3 +++
 net/netfilter/xt_string.c           |    5 ++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
index bb21dd1..2de02e9 100644
--- a/include/linux/netfilter/xt_string.h
+++ b/include/linux/netfilter/xt_string.h
@@ -4,6 +4,8 @@
 #define XT_STRING_MAX_PATTERN_SIZE 128
 #define XT_STRING_MAX_ALGO_NAME_SIZE 16
 
+#define XT_STRING_FLAG_IGNORECASE 0x01
+
 struct xt_string_info
 {
 	u_int16_t from_offset;
@@ -12,6 +14,7 @@ struct xt_string_info
 	char 	  pattern[XT_STRING_MAX_PATTERN_SIZE];
 	u_int8_t  patlen;
 	u_int8_t  invert;
+	u_int8_t  flags;
 
 	/* Used internally by the kernel */
 	struct ts_config __attribute__((aligned(8))) *config;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index 72f694d..853ca35 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -46,6 +46,7 @@ string_mt_check(const char *tablename, const void *ip,
 {
 	struct xt_string_info *conf = matchinfo;
 	struct ts_config *ts_conf;
+	int flags = TS_AUTOLOAD;
 
 	/* Damn, can't handle this case properly with iptables... */
 	if (conf->from_offset > conf->to_offset)
@@ -54,8 +55,10 @@ string_mt_check(const char *tablename, const void *ip,
 		return false;
 	if (conf->patlen > XT_STRING_MAX_PATTERN_SIZE)
 		return false;
+	if (conf->flags & XT_STRING_FLAG_IGNORECASE)
+		flags |= TS_IGNORECASE;
 	ts_conf = textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
-				     GFP_KERNEL, TS_AUTOLOAD);
+				     GFP_KERNEL, flags);
 	if (IS_ERR(ts_conf))
 		return false;
 
-- 
1.5.4.3

