From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 8/8 v3] iptables: string extension case insensitive matching
Date: Sun,  6 Jul 2008 17:14:35 -0700
Message-ID: <1215389675-19925-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jan Engelhardt <jengelh@medozas.de>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The string extension can search patterns case insensitively with --icase
option.
A new revision 1 was added, in the meantime invert of xt_string_info was
moved into flags as a flag.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 extensions/libxt_string.c           |   70 ++++++++++++++++++++++++++++++-----
 include/linux/netfilter/xt_string.h |   15 +++++++-
 2 files changed, 74 insertions(+), 11 deletions(-)

diff --git a/extensions/libxt_string.c b/extensions/libxt_string.c
index 5eec44b..f9e8881 100644
--- a/extensions/libxt_string.c
+++ b/extensions/libxt_string.c
@@ -37,7 +37,8 @@ static void string_help(void)
 "string match options:\n"
 "--from                       Offset to start searching from\n"
 "--to                         Offset to stop searching\n"
-"--algo	                      Algorithm\n"
+"--algo                       Algorithm\n"
+"--icase                      Ignore case (default: 0)\n"
 "[!] --string string          Match a string in a packet\n"
 "[!] --hex-string string      Match a hex string in a packet\n");
 }
@@ -48,6 +49,7 @@ static const struct option string_opts[] = {
 	{ "algo", 1, NULL, '3' },
 	{ "string", 1, NULL, '4' },
 	{ "hex-string", 1, NULL, '5' },
+	{ "icase", 0, NULL, '6' },
 	{ .name = NULL }
 };
 
@@ -162,6 +164,7 @@ parse_hex_string(const char *s, struct xt_string_info *info)
 #define ALGO   0x2
 #define FROM   0x4
 #define TO     0x8
+#define ICASE  0x10
 
 /* Function which parses command options; returns true if it
    ate an option */
@@ -169,7 +172,9 @@ static int
 string_parse(int c, char **argv, int invert, unsigned int *flags,
              const void *entry, struct xt_entry_match **match)
 {
-	struct xt_string_info *stringinfo = (struct xt_string_info *)(*match)->data;
+	struct xt_string_info *stringinfo =
+	    (struct xt_string_info *)(*match)->data;
+	const int revision = (*match)->u.user.revision;
 
 	switch (c) {
 	case '1':
@@ -199,8 +204,12 @@ string_parse(int c, char **argv, int invert, unsigned int *flags,
 				   "Can't specify multiple --string");
 		check_inverse(optarg, &invert, &optind, 0);
 		parse_string(argv[optind-1], stringinfo);
-		if (invert)
-			stringinfo->invert = 1;
+		if (invert) {
+			if (revision == 0)
+				stringinfo->u.v0.invert = 1;
+			else
+				stringinfo->u.v1.flags |= XT_STRING_FLAG_INVERT;
+		}
 		stringinfo->patlen=strlen((char *)&stringinfo->pattern);
 		*flags |= STRING;
 		break;
@@ -212,11 +221,24 @@ string_parse(int c, char **argv, int invert, unsigned int *flags,
 
 		check_inverse(optarg, &invert, &optind, 0);
 		parse_hex_string(argv[optind-1], stringinfo);  /* sets length */
-		if (invert)
-			stringinfo->invert = 1;
+		if (invert) {
+			if (revision == 0)
+				stringinfo->u.v0.invert = 1;
+			else
+				stringinfo->u.v1.flags |= XT_STRING_FLAG_INVERT;
+		}
 		*flags |= STRING;
 		break;
 
+	case '6':
+		if (revision == 0)
+			exit_error(VERSION_PROBLEM,
+				   "Kernel doesn't support --icase");
+
+		stringinfo->u.v1.flags |= XT_STRING_FLAG_IGNORECASE;
+		*flags |= ICASE;
+		break;
+
 	default:
 		return 0;
 	}
@@ -287,12 +309,15 @@ string_print(const void *ip, const struct xt_entry_match *match, int numeric)
 {
 	const struct xt_string_info *info =
 	    (const struct xt_string_info*) match->data;
+	const int revision = match->u.user.revision;
+	int invert = (revision == 0 ? info->u.v0.invert :
+				    info->u.v1.flags & XT_STRING_FLAG_INVERT);
 
 	if (is_hex_string(info->pattern, info->patlen)) {
-		printf("STRING match %s", (info->invert) ? "!" : "");
+		printf("STRING match %s", invert ? "!" : "");
 		print_hex_string(info->pattern, info->patlen);
 	} else {
-		printf("STRING match %s", (info->invert) ? "!" : "");
+		printf("STRING match %s", invert ? "!" : "");
 		print_string(info->pattern, info->patlen);
 	}
 	printf("ALGO name %s ", info->algo);
@@ -300,6 +325,8 @@ string_print(const void *ip, const struct xt_entry_match *match, int numeric)
 		printf("FROM %u ", info->from_offset);
 	if (info->to_offset != 0)
 		printf("TO %u ", info->to_offset);
+	if (revision > 0 && info->u.v1.flags & XT_STRING_FLAG_IGNORECASE)
+		printf("ICASE ");
 }
 
 
@@ -308,12 +335,15 @@ static void string_save(const void *ip, const struct xt_entry_match *match)
 {
 	const struct xt_string_info *info =
 	    (const struct xt_string_info*) match->data;
+	const int revision = match->u.user.revision;
+	int invert = (revision == 0 ? info->u.v0.invert :
+				    info->u.v1.flags & XT_STRING_FLAG_INVERT);
 
 	if (is_hex_string(info->pattern, info->patlen)) {
-		printf("--hex-string %s", (info->invert) ? "! ": "");
+		printf("--hex-string %s", (invert) ? "! ": "");
 		print_hex_string(info->pattern, info->patlen);
 	} else {
-		printf("--string %s", (info->invert) ? "! ": "");
+		printf("--string %s", (invert) ? "! ": "");
 		print_string(info->pattern, info->patlen);
 	}
 	printf("--algo %s ", info->algo);
@@ -321,11 +351,30 @@ static void string_save(const void *ip, const struct xt_entry_match *match)
 		printf("--from %u ", info->from_offset);
 	if (info->to_offset != 0)
 		printf("--to %u ", info->to_offset);
+	if (revision > 0 && info->u.v1.flags & XT_STRING_FLAG_IGNORECASE)
+		printf("--icase ");
 }
 
 
 static struct xtables_match string_match = {
     .name		= "string",
+    .revision		= 0,
+    .family		= AF_UNSPEC,
+    .version		= XTABLES_VERSION,
+    .size		= XT_ALIGN(sizeof(struct xt_string_info)),
+    .userspacesize	= offsetof(struct xt_string_info, config),
+    .help		= string_help,
+    .init		= string_init,
+    .parse		= string_parse,
+    .final_check	= string_check,
+    .print		= string_print,
+    .save		= string_save,
+    .extra_opts		= string_opts,
+};
+
+static struct xtables_match string_match_v1 = {
+    .name		= "string",
+    .revision		= 1,
     .family		= AF_UNSPEC,
     .version		= XTABLES_VERSION,
     .size		= XT_ALIGN(sizeof(struct xt_string_info)),
@@ -342,4 +391,5 @@ static struct xtables_match string_match = {
 void _init(void)
 {
 	xtables_register_match(&string_match);
+	xtables_register_match(&string_match_v1);
 }
diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
index bb21dd1..f1c182f 100644
--- a/include/linux/netfilter/xt_string.h
+++ b/include/linux/netfilter/xt_string.h
@@ -4,6 +4,11 @@
 #define XT_STRING_MAX_PATTERN_SIZE 128
 #define XT_STRING_MAX_ALGO_NAME_SIZE 16
 
+enum {
+	XT_STRING_FLAG_INVERT		= 0x01,
+	XT_STRING_FLAG_IGNORECASE 	= 0x02
+};
+
 struct xt_string_info
 {
 	u_int16_t from_offset;
@@ -11,7 +16,15 @@ struct xt_string_info
 	char	  algo[XT_STRING_MAX_ALGO_NAME_SIZE];
 	char 	  pattern[XT_STRING_MAX_PATTERN_SIZE];
 	u_int8_t  patlen;
-	u_int8_t  invert;
+	union {
+		struct {
+			u_int8_t invert;
+		} v0;
+
+		struct {
+			u_int8_t flags;
+		} v1;
+	} u;
 
 	/* Used internally by the kernel */
 	struct ts_config __attribute__((aligned(8))) *config;
-- 
1.5.4.3

