From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH v3] netfilter/nflog: nflog-range does not truncate packets
 (userspace)
Date: Fri, 24 Jun 2016 16:42:31 -0400
Message-ID: <20160624204231.GA3062@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, johunt@akamai.com,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pai.vishwain@gmail.com,
	ilubashe@akamai.com, jdollard@akamai.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:52310 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbcFXUmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 16:42:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added tests to libxt_NFLOG.t for the new option --nflog-size

--

netfilter/nflog: nflog-range does not truncate packets

The option --nflog-range has never worked, but we cannot just fix this
because users might be using this feature option and their behavior would
change. Instead add a new option --nflog-size. This option works the same
way nflog-range should have, and both of them are mutually exclusive. When
someone uses --nflog-range we print a warning message informing them that
this feature has no effect.

To indicate the kernel that the user has set --nflog-size we have to pass a
new flag XT_NFLOG_F_COPY_LEN.

Also updated the man page to reflect the new option and added tests to
extensions/libxt_NFLOG.t

Reported-by: Joe Dollard <jdollard@akamai.com>
Reviewed-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>

diff --git a/extensions/libxt_NFLOG.c b/extensions/libxt_NFLOG.c
index f611631..8c67066 100644
--- a/extensions/libxt_NFLOG.c
+++ b/extensions/libxt_NFLOG.c
@@ -12,7 +12,10 @@ enum {
 	O_GROUP = 0,
 	O_PREFIX,
 	O_RANGE,
+	O_SIZE,
 	O_THRESHOLD,
+	F_RANGE = 1 << O_RANGE,
+	F_SIZE = 1 << O_SIZE,
 };
 
 #define s struct xt_nflog_info
@@ -22,7 +25,9 @@ static const struct xt_option_entry NFLOG_opts[] = {
 	{.name = "nflog-prefix", .id = O_PREFIX, .type = XTTYPE_STRING,
 	 .min = 1, .flags = XTOPT_PUT, XTOPT_POINTER(s, prefix)},
 	{.name = "nflog-range", .id = O_RANGE, .type = XTTYPE_UINT32,
-	 .flags = XTOPT_PUT, XTOPT_POINTER(s, len)},
+	 .excl = F_SIZE, .flags = XTOPT_PUT, XTOPT_POINTER(s, len)},
+	{.name = "nflog-size", .id = O_SIZE, .type = XTTYPE_UINT32,
+	 .excl = F_RANGE, .flags = XTOPT_PUT, XTOPT_POINTER(s, len)},
 	{.name = "nflog-threshold", .id = O_THRESHOLD, .type = XTTYPE_UINT16,
 	 .flags = XTOPT_PUT, XTOPT_POINTER(s, threshold)},
 	XTOPT_TABLEEND,
@@ -33,7 +38,8 @@ static void NFLOG_help(void)
 {
 	printf("NFLOG target options:\n"
 	       " --nflog-group NUM		NETLINK group used for logging\n"
-	       " --nflog-range NUM		Number of byte to copy\n"
+	       " --nflog-range NUM		This option has no effect, use --nflog-size\n"
+	       " --nflog-size NUM		Number of bytes to copy\n"
 	       " --nflog-threshold NUM		Message threshold of in-kernel queue\n"
 	       " --nflog-prefix STRING		Prefix string for log messages\n");
 }
@@ -57,6 +63,18 @@ static void NFLOG_parse(struct xt_option_call *cb)
 	}
 }
 
+static void NFLOG_check(struct xt_fcheck_call *cb)
+{
+	struct xt_nflog_info *info = cb->data;
+
+	if (cb->xflags & F_RANGE)
+		fprintf(stderr, "warn: --nflog-range has never worked and is no"
+			" longer supported, please use --nflog-size insted\n");
+
+	if (cb->xflags & F_SIZE)
+		info->flags |= XT_NFLOG_F_COPY_LEN;
+}
+
 static void nflog_print(const struct xt_nflog_info *info, char *prefix)
 {
 	if (info->prefix[0] != '\0') {
@@ -65,7 +83,9 @@ static void nflog_print(const struct xt_nflog_info *info, char *prefix)
 	}
 	if (info->group)
 		printf(" %snflog-group %u", prefix, info->group);
-	if (info->len)
+	if (info->len && info->flags & XT_NFLOG_F_COPY_LEN)
+		printf(" %snflog-size %u", prefix, info->len);
+	else if (info->len)
 		printf(" %snflog-range %u", prefix, info->len);
 	if (info->threshold != XT_NFLOG_DEFAULT_THRESHOLD)
 		printf(" %snflog-threshold %u", prefix, info->threshold);
@@ -117,6 +137,7 @@ static struct xtables_target nflog_target = {
 	.userspacesize	= XT_ALIGN(sizeof(struct xt_nflog_info)),
 	.help		= NFLOG_help,
 	.init		= NFLOG_init,
+	.x6_fcheck	= NFLOG_check,
 	.x6_parse	= NFLOG_parse,
 	.print		= NFLOG_print,
 	.save		= NFLOG_save,
diff --git a/extensions/libxt_NFLOG.man b/extensions/libxt_NFLOG.man
index 1b6dbf1..318e630 100644
--- a/extensions/libxt_NFLOG.man
+++ b/extensions/libxt_NFLOG.man
@@ -17,6 +17,9 @@ A prefix string to include in the log message, up to 64 characters
 long, useful for distinguishing messages in the logs.
 .TP
 \fB\-\-nflog\-range\fP \fIsize\fP
+This option has never worked, use --nflog-size instead
+.TP
+\fB\-\-nflog\-size\fP \fIsize\fP
 The number of bytes to be copied to userspace (only applicable for
 nfnetlink_log). nfnetlink_log instances may specify their own
 range, this option overrides it.
diff --git a/extensions/libxt_NFLOG.t b/extensions/libxt_NFLOG.t
index f9768aa..78076b5 100644
--- a/extensions/libxt_NFLOG.t
+++ b/extensions/libxt_NFLOG.t
@@ -7,6 +7,10 @@
 -j NFLOG --nflog-range 4294967295;=;OK
 -j NFLOG --nflog-range 4294967296;;FAIL
 -j NFLOG --nflog-range -1;;FAIL
+-j NFLOG --nflog-size 1;=;OK
+-j NFLOG --nflog-size 4294967295;=;OK
+-j NFLOG --nflog-size 4294967296;;FAIL
+-j NFLOG --nflog-size -1;;FAIL
 # ERROR: cannot find: iptables -I INPUT -j NFLOG --nflog-prefix  xxxxxx [...]
 # -j NFLOG --nflog-prefix xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;=;OK
 # ERROR: should fail: iptables -A INPUT -j NFLOG --nflog-prefix  xxxxxxx [...]
diff --git a/include/linux/netfilter/xt_NFLOG.h b/include/linux/netfilter/xt_NFLOG.h
index 87b5831..f330707 100644
--- a/include/linux/netfilter/xt_NFLOG.h
+++ b/include/linux/netfilter/xt_NFLOG.h
@@ -6,9 +6,13 @@
 #define XT_NFLOG_DEFAULT_GROUP		0x1
 #define XT_NFLOG_DEFAULT_THRESHOLD	0
 
-#define XT_NFLOG_MASK			0x0
+#define XT_NFLOG_MASK			0x1
+
+/* This flag indicates that 'len' field in xt_nflog_info is set*/
+#define XT_NFLOG_F_COPY_LEN		0x1
 
 struct xt_nflog_info {
+	/* 'len' will be used iff you set XT_NFLOG_F_COPY_LEN in flags */
 	__u32	len;
 	__u16	group;
 	__u16	threshold;
