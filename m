From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH 1/2] netfilter: ipset: warn users of list:set that parameter 'size' is ignored
Date: Tue, 21 Mar 2017 22:06:21 -0400
Message-ID: <1490148382-2633-1-git-send-email-vpai@akamai.com>
Cc: johunt@akamai.com, vpai@akamai.com,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        coreteam@netfilter.org, pai.vishwain@gmail.com
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since kernel commit 00590fdd5be0 ("netfilter: ipset: Introduce RCU
locking in list type"), the parameter 'size' has not been in use and
is ignored by the kernel. This is not very apparent to the user. This
commit makes 'size' optional and also warns the user if they try to
specify it. We also don't print it out on 'ipset l'.

I created revision 4 to make this change, revision 3 should work with
older kernels just like before.

Reviewed-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 lib/ipset_list_set.c | 92 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)

diff --git a/lib/ipset_list_set.c b/lib/ipset_list_set.c
index 45934e7..2d8bc7a 100644
--- a/lib/ipset_list_set.c
+++ b/lib/ipset_list_set.c
@@ -322,6 +322,31 @@ static const struct ipset_arg list_set_create_args3[] = {
 	{ },
 };
 
+/* Parse commandline arguments */
+static const struct ipset_arg list_set_create_args4[] = {
+	{ .name = { "size", NULL },
+	  .has_arg = IPSET_OPTIONAL_ARG,	.opt = IPSET_OPT_SIZE,
+	  .parse = ipset_parse_ignored,
+	},
+	{ .name = { "timeout", NULL },
+	  .has_arg = IPSET_MANDATORY_ARG,	.opt = IPSET_OPT_TIMEOUT,
+	  .parse = ipset_parse_timeout,		.print = ipset_print_number,
+	},
+	{ .name = { "counters", NULL },
+	  .has_arg = IPSET_NO_ARG,		.opt = IPSET_OPT_COUNTERS,
+	  .parse = ipset_parse_flag,		.print = ipset_print_flag,
+	},
+	{ .name = { "comment", NULL },
+	  .has_arg = IPSET_NO_ARG,		.opt = IPSET_OPT_CREATE_COMMENT,
+	  .parse = ipset_parse_flag,		.print = ipset_print_flag,
+	},
+	{ .name = { "skbinfo", NULL },
+	  .has_arg = IPSET_NO_ARG,		.opt = IPSET_OPT_SKBINFO,
+	  .parse = ipset_parse_flag,		.print = ipset_print_flag,
+	},
+	{ },
+};
+
 static const struct ipset_arg list_set_adt_args3[] = {
 	{ .name = { "timeout", NULL },
 	  .has_arg = IPSET_MANDATORY_ARG,	.opt = IPSET_OPT_TIMEOUT,
@@ -426,6 +451,72 @@ static struct ipset_type ipset_list_set3 = {
 	.usage = list_set_usage3,
 	.description = "skbinfo support",
 };
+
+static const char list_set_usage4[] =
+"create SETNAME list:set\n"
+"               [timeout VALUE] [counters] [comment]\n"
+"		[skbinfo]\n"
+"add    SETNAME NAME [before|after NAME] [timeout VALUE]\n"
+"               [packets VALUE] [bytes VALUE] [comment STRING]\n"
+"		[skbmark VALUE] [skbprio VALUE] [skbqueue VALUE]\n"
+"del    SETNAME NAME [before|after NAME]\n"
+"test   SETNAME NAME [before|after NAME]\n\n"
+"where NAME are existing set names.\n";
+
+static struct ipset_type ipset_list_set4 = {
+	.name = "list:set",
+	.alias = { "setlist", NULL },
+	.revision = 4,
+	.family = NFPROTO_UNSPEC,
+	.dimension = IPSET_DIM_ONE,
+	.elem = {
+		[IPSET_DIM_ONE - 1] = {
+			.parse = ipset_parse_setname,
+			.print = ipset_print_name,
+			.opt = IPSET_OPT_NAME
+		},
+	},
+	.compat_parse_elem = ipset_parse_name_compat,
+	.args = {
+		[IPSET_CREATE] = list_set_create_args4,
+		[IPSET_ADD] = list_set_adt_args3,
+		[IPSET_DEL] = list_set_adt_args2,
+		[IPSET_TEST] = list_set_adt_args2,
+	},
+	.mandatory = {
+		[IPSET_CREATE] = 0,
+		[IPSET_ADD] = IPSET_FLAG(IPSET_OPT_NAME),
+		[IPSET_DEL] = IPSET_FLAG(IPSET_OPT_NAME),
+		[IPSET_TEST] = IPSET_FLAG(IPSET_OPT_NAME),
+	},
+	.full = {
+		[IPSET_CREATE] = IPSET_FLAG(IPSET_OPT_SIZE)
+			| IPSET_FLAG(IPSET_OPT_TIMEOUT)
+			| IPSET_FLAG(IPSET_OPT_COUNTERS)
+			| IPSET_FLAG(IPSET_OPT_CREATE_COMMENT)
+			| IPSET_FLAG(IPSET_OPT_SKBINFO),
+		[IPSET_ADD] = IPSET_FLAG(IPSET_OPT_NAME)
+			| IPSET_FLAG(IPSET_OPT_BEFORE)
+			| IPSET_FLAG(IPSET_OPT_NAMEREF)
+			| IPSET_FLAG(IPSET_OPT_TIMEOUT)
+			| IPSET_FLAG(IPSET_OPT_PACKETS)
+			| IPSET_FLAG(IPSET_OPT_BYTES)
+			| IPSET_FLAG(IPSET_OPT_ADT_COMMENT)
+			| IPSET_FLAG(IPSET_OPT_SKBMARK)
+			| IPSET_FLAG(IPSET_OPT_SKBPRIO)
+			| IPSET_FLAG(IPSET_OPT_SKBQUEUE),
+		[IPSET_DEL] = IPSET_FLAG(IPSET_OPT_NAME)
+			| IPSET_FLAG(IPSET_OPT_BEFORE)
+			| IPSET_FLAG(IPSET_OPT_NAMEREF),
+		[IPSET_TEST] = IPSET_FLAG(IPSET_OPT_NAME)
+			| IPSET_FLAG(IPSET_OPT_BEFORE)
+			| IPSET_FLAG(IPSET_OPT_NAMEREF),
+	},
+
+	.usage = list_set_usage4,
+	.description = "ignore and warn users about parameter 'size'",
+};
+
 void _init(void);
 void _init(void)
 {
@@ -433,4 +524,5 @@ void _init(void)
 	ipset_type_add(&ipset_list_set1);
 	ipset_type_add(&ipset_list_set2);
 	ipset_type_add(&ipset_list_set3);
+	ipset_type_add(&ipset_list_set4);
 }
-- 
1.9.1

