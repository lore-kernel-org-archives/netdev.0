From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: [PATCH] iptables: xt_recent: Add optional mask option for xt_recent
Date: Thu, 17 May 2012 23:08:57 +0300
Message-ID: <1337285337-13619-1-git-send-email-denys@visp.net.lb>
Cc: Linux netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Denys Fedoryshchenko <denys@visp.net.lb>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use case for this feature:
1)In some occasions if you need to allow,block,match specific subnet.
2)I can use recent as a trigger when netfilter rule matches, with mask 0.0.0.0

Tested for backward compatibility:
)old (userspace) iptables, new kernel
)old kernel, new iptables
)new kernel, new iptables

Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>
---
 extensions/libxt_recent.c           |  152 ++++++++++++++++++++++++++++++----
 include/linux/netfilter/xt_recent.h |   11 +++-
 2 files changed, 144 insertions(+), 19 deletions(-)

diff --git a/extensions/libxt_recent.c b/extensions/libxt_recent.c
index c7dce4e..930da29 100644
--- a/extensions/libxt_recent.c
+++ b/extensions/libxt_recent.c
@@ -16,6 +16,7 @@ enum {
 	O_NAME,
 	O_RSOURCE,
 	O_RDEST,
+	O_MASK,
 	F_SET    = 1 << O_SET,
 	F_RCHECK = 1 << O_RCHECK,
 	F_UPDATE = 1 << O_UPDATE,
@@ -25,7 +26,7 @@ enum {
 };
 
 #define s struct xt_recent_mtinfo
-static const struct xt_option_entry recent_opts[] = {
+static const struct xt_option_entry recent_opts_v0[] = {
 	{.name = "set", .id = O_SET, .type = XTTYPE_NONE,
 	 .excl = F_ANY_OP, .flags = XTOPT_INVERT},
 	{.name = "rcheck", .id = O_RCHECK, .type = XTTYPE_NONE,
@@ -50,6 +51,33 @@ static const struct xt_option_entry recent_opts[] = {
 };
 #undef s
 
+#define s struct xt_recent_mtinfo_v1
+static const struct xt_option_entry recent_opts_v1[] = {
+	{.name = "set", .id = O_SET, .type = XTTYPE_NONE,
+	 .excl = F_ANY_OP, .flags = XTOPT_INVERT},
+	{.name = "rcheck", .id = O_RCHECK, .type = XTTYPE_NONE,
+	 .excl = F_ANY_OP, .flags = XTOPT_INVERT},
+	{.name = "update", .id = O_UPDATE, .type = XTTYPE_NONE,
+	 .excl = F_ANY_OP, .flags = XTOPT_INVERT},
+	{.name = "remove", .id = O_REMOVE, .type = XTTYPE_NONE,
+	 .excl = F_ANY_OP, .flags = XTOPT_INVERT},
+	{.name = "seconds", .id = O_SECONDS, .type = XTTYPE_UINT32,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, seconds)},
+	{.name = "hitcount", .id = O_HITCOUNT, .type = XTTYPE_UINT32,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, hit_count)},
+	{.name = "rttl", .id = O_RTTL, .type = XTTYPE_NONE,
+	 .excl = F_SET | F_REMOVE},
+	{.name = "name", .id = O_NAME, .type = XTTYPE_STRING,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, name)},
+	{.name = "rsource", .id = O_RSOURCE, .type = XTTYPE_NONE},
+	{.name = "rdest", .id = O_RDEST, .type = XTTYPE_NONE},
+	{.name = "mask", .id = O_MASK, .type = XTTYPE_HOST,
+	 .flags = XTOPT_PUT, XTOPT_POINTER(s, mask)},
+	XTOPT_TABLEEND,
+};
+#undef s
+
+
 static void recent_help(void)
 {
 	printf(
@@ -74,24 +102,27 @@ static void recent_help(void)
 "    --name name                 Name of the recent list to be used.  DEFAULT used if none given.\n"
 "    --rsource                   Match/Save the source address of each packet in the recent list table (default).\n"
 "    --rdest                     Match/Save the destination address of each packet in the recent list table.\n"
+"    --mask netmask              Netmask that will be applied to this recent list.\n"
 "xt_recent by: Stephen Frost <sfrost@snowman.net>.  http://snowman.net/projects/ipt_recent/\n");
 }
 
-static void recent_init(struct xt_entry_match *match)
+static void recent_init(struct xt_entry_match *match,unsigned int family)
 {
-	struct xt_recent_mtinfo *info = (void *)(match)->data;
+	struct xt_recent_mtinfo    *info_v0 = (void *)(match)->data;
+	struct xt_recent_mtinfo_v1 *info_v1 = (void *)(match)->data;
 
-	strncpy(info->name,"DEFAULT", XT_RECENT_NAME_LEN);
+	strncpy(info_v0->name,"DEFAULT", XT_RECENT_NAME_LEN);
 	/* even though XT_RECENT_NAME_LEN is currently defined as 200,
 	 * better be safe, than sorry */
-	info->name[XT_RECENT_NAME_LEN-1] = '\0';
-	info->side = XT_RECENT_SOURCE;
+	info_v0->name[XT_RECENT_NAME_LEN-1] = '\0';
+	info_v0->side = XT_RECENT_SOURCE;
+	if (family == NFPROTO_IPV6)
+	    memset(&info_v1->mask,0xFF,sizeof(info_v1->mask));
 }
 
 static void recent_parse(struct xt_option_call *cb)
 {
 	struct xt_recent_mtinfo *info = cb->data;
-
 	xtables_option_parse(cb);
 	switch (cb->entry->id) {
 	case O_SET:
@@ -140,9 +171,9 @@ static void recent_check(struct xt_fcheck_call *cb)
 }
 
 static void recent_print(const void *ip, const struct xt_entry_match *match,
-                         int numeric)
+                         unsigned int family)
 {
-	const struct xt_recent_mtinfo *info = (const void *)match->data;
+	const struct xt_recent_mtinfo_v1 *info = (const void *)match->data;
 
 	if (info->invert)
 		printf(" !");
@@ -167,11 +198,17 @@ static void recent_print(const void *ip, const struct xt_entry_match *match,
 		printf(" side: source");
 	if (info->side == XT_RECENT_DEST)
 		printf(" side: dest");
+	if (family == NFPROTO_IPV4)
+	    printf(" mask: %s",
+		xtables_ipaddr_to_numeric(&info->mask.in));
+	if (family == NFPROTO_IPV6)
+	    printf(" mask: %s",
+		xtables_ip6addr_to_numeric(&info->mask.in6));
 }
 
-static void recent_save(const void *ip, const struct xt_entry_match *match)
+static void recent_save(const void *ip, const struct xt_entry_match *match,unsigned int family)
 {
-	const struct xt_recent_mtinfo *info = (const void *)match->data;
+	const struct xt_recent_mtinfo_v1 *info = (const void *)match->data;
 
 	if (info->invert)
 		printf(" !");
@@ -191,28 +228,107 @@ static void recent_save(const void *ip, const struct xt_entry_match *match)
 	if (info->check_set & XT_RECENT_TTL)
 		printf(" --rttl");
 	if(info->name) printf(" --name %s",info->name);
+	if (family == NFPROTO_IPV4)
+	    printf(" --mask %s",
+		xtables_ipaddr_to_numeric(&info->mask.in));
+	if (family == NFPROTO_IPV6)
+	    printf(" --mask %s",
+		xtables_ip6addr_to_numeric(&info->mask.in6));
+		
 	if (info->side == XT_RECENT_SOURCE)
 		printf(" --rsource");
 	if (info->side == XT_RECENT_DEST)
 		printf(" --rdest");
 }
 
-static struct xtables_match recent_mt_reg = {
-	.name          = "recent",
+static void recent_init_v0(struct xt_entry_match *match) {
+	recent_init(match,NFPROTO_UNSPEC);
+}
+
+static void recent_init_v1(struct xt_entry_match *match) {
+	recent_init(match,NFPROTO_IPV6);
+}
+
+static void recent_save_v0(const void *ip, const struct xt_entry_match *match)
+{
+	recent_save(ip,match,NFPROTO_UNSPEC);
+}
+
+static void recent_save_v4(const void *ip, const struct xt_entry_match *match)
+{
+	recent_save(ip,match,NFPROTO_IPV4);
+}
+
+static void recent_save_v6(const void *ip, const struct xt_entry_match *match)
+{
+	recent_save(ip,match,NFPROTO_IPV6);
+}
+
+static void recent_print_v0(const void *ip, const struct xt_entry_match *match,
+                         int numeric)
+{
+	recent_print(ip,match,NFPROTO_UNSPEC);
+}
+
+static void recent_print_v4(const void *ip, const struct xt_entry_match *match,
+                         int numeric)
+{
+	recent_print(ip,match,NFPROTO_IPV4);
+}
+
+static void recent_print_v6(const void *ip, const struct xt_entry_match *match,
+                         int numeric)
+{
+	recent_print(ip,match,NFPROTO_IPV6);
+}
+
+static struct xtables_match recent_mt_reg[] = {
+    {	.name          = "recent",
 	.version       = XTABLES_VERSION,
+	.revision      = 0,
 	.family        = NFPROTO_UNSPEC,
 	.size          = XT_ALIGN(sizeof(struct xt_recent_mtinfo)),
 	.userspacesize = XT_ALIGN(sizeof(struct xt_recent_mtinfo)),
 	.help          = recent_help,
-	.init          = recent_init,
+	.init          = recent_init_v0,
+	.x6_parse      = recent_parse,
+	.x6_fcheck     = recent_check,
+	.print         = recent_print_v0,
+	.save          = recent_save_v0,
+	.x6_options    = recent_opts_v0,
+    },
+    {	.name          = "recent",
+	.version       = XTABLES_VERSION,
+	.revision      = 1,
+	.family        = NFPROTO_IPV4,
+	.size          = XT_ALIGN(sizeof(struct xt_recent_mtinfo_v1)),
+	.userspacesize = XT_ALIGN(sizeof(struct xt_recent_mtinfo_v1)),
+	.help          = recent_help,
+	.init          = recent_init_v1,
+	.x6_parse      = recent_parse,
+	.x6_fcheck     = recent_check,
+	.print         = recent_print_v4,
+	.save          = recent_save_v4,
+	.x6_options    = recent_opts_v1,
+    },
+    {	.name          = "recent",
+	.version       = XTABLES_VERSION,
+	.revision      = 1,
+	.family        = NFPROTO_IPV6,
+	.size          = XT_ALIGN(sizeof(struct xt_recent_mtinfo_v1)),
+	.userspacesize = XT_ALIGN(sizeof(struct xt_recent_mtinfo_v1)),
+	.help          = recent_help,
+	.init          = recent_init_v1,
 	.x6_parse      = recent_parse,
 	.x6_fcheck     = recent_check,
-	.print         = recent_print,
-	.save          = recent_save,
-	.x6_options    = recent_opts,
+	.print         = recent_print_v6,
+	.save          = recent_save_v6,
+	.x6_options    = recent_opts_v1,
+    }
 };
 
 void _init(void)
 {
-	xtables_register_match(&recent_mt_reg);
+	xtables_register_matches(recent_mt_reg,
+				 ARRAY_SIZE(recent_mt_reg));
 }
diff --git a/include/linux/netfilter/xt_recent.h b/include/linux/netfilter/xt_recent.h
index 83318e0..b8d58c6 100644
--- a/include/linux/netfilter/xt_recent.h
+++ b/include/linux/netfilter/xt_recent.h
@@ -22,7 +22,6 @@ enum {
 
 #define XT_RECENT_VALID_FLAGS (XT_RECENT_CHECK|XT_RECENT_SET|XT_RECENT_UPDATE|\
 			       XT_RECENT_REMOVE|XT_RECENT_TTL|XT_RECENT_REAP)
-
 struct xt_recent_mtinfo {
 	__u32 seconds;
 	__u32 hit_count;
@@ -32,4 +31,14 @@ struct xt_recent_mtinfo {
 	__u8 side;
 };
 
+struct xt_recent_mtinfo_v1 {
+	__u32 seconds;
+	__u32 hit_count;
+	__u8 check_set;
+	__u8 invert;
+	char name[XT_RECENT_NAME_LEN];
+	__u8 side;
+	union nf_inet_addr mask;
+};
+
 #endif /* _LINUX_NETFILTER_XT_RECENT_H */
-- 
1.7.3.4

