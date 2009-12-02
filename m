From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 1/3] Keep the old tc/ipt/xt module for compatibility.
Date: Wed, 2 Dec 2009 16:11:21 +0100
Message-ID: <e8b91d464456eb9601b40595ebbb0a501d28eb12.1259765732.git.andreas@fatal.se>
References: <cover.1259765732.git.andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy1.bredband.net ([195.54.101.71]:35956 "EHLO
	proxy1.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322AbZLBPKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 10:10:33 -0500
Received: from ipb2.telenor.se (195.54.127.165) by proxy1.bredband.net (7.3.140.3)
        id 4AD3E1C001662A09 for netdev@vger.kernel.org; Wed, 2 Dec 2009 16:10:38 +0100
Content-Disposition: inline
In-Reply-To: <cover.1259765732.git.andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the file and rename the configure flags.
The file is being kept around for iptables < 1.4.5 compatibility.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 configure     |    4 +-
 tc/Makefile   |   13 ++-
 tc/m_xt.c     |  433 ---------------------------------------------------------
 tc/m_xt_old.c |  433 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 444 insertions(+), 439 deletions(-)
 delete mode 100644 tc/m_xt.c
 create mode 100644 tc/m_xt_old.c

diff --git a/configure b/configure
index df40370..f3b79b2 100755
--- a/configure
+++ b/configure
@@ -53,7 +53,7 @@ gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
 
 if [ $? -eq 0 ]
 then
-	echo "TC_CONFIG_XT:=y" >>Config
+	echo "TC_CONFIG_XT_OLD:=y" >>Config
 	echo "using xtables seems no need for internal.h"
 else
 	echo "failed test 2"
@@ -86,7 +86,7 @@ gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
 if [ $? -eq 0 ]
 then
 	echo "using xtables instead of iptables (need for internal.h)"
-	echo "TC_CONFIG_XT_H:=y" >>Config
+	echo "TC_CONFIG_XT_OLD_H:=y" >>Config
 
 else
 	echo "failed test 3 using iptables"
diff --git a/tc/Makefile b/tc/Makefile
index 027055c..f3dd2b7 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -48,12 +48,17 @@ ifeq ($(TC_CONFIG_XT),y)
   TCMODULES += m_xt.o
   LDLIBS += -lxtables
 else
-  ifeq ($(TC_CONFIG_XT_H),y)
+  ifeq ($(TC_CONFIG_XT_OLD),y)
+    TCMODULES += m_xt_old.o
+    LDLIBS += -lxtables
+  else
+    ifeq ($(TC_CONFIG_XT_OLD_H),y)
 	CFLAGS += -DTC_CONFIG_XT_H
-	TCMODULES += m_xt.o
+	TCMODULES += m_xt_old.o
 	LDLIBS += -lxtables
-  else
-  TCMODULES += m_ipt.o
+    else
+      TCMODULES += m_ipt.o
+    endif
   endif
 endif
 
diff --git a/tc/m_xt.c b/tc/m_xt.c
deleted file mode 100644
index 0c7ec60..0000000
--- a/tc/m_xt.c
+++ /dev/null
@@ -1,433 +0,0 @@
-/*
- * m_xt.c	xtables based targets
- * 		utilities mostly ripped from iptables <duh, its the linux way>
- *
- *		This program is free software; you can distribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
- *
- * Authors:  J Hadi Salim (hadi@cyberus.ca)
- */
-
-/*XXX: in the future (xtables 1.4.3?) get rid of everything tagged
- * as TC_CONFIG_XT_H */
-
-#include <syslog.h>
-#include <sys/socket.h>
-#include <netinet/in.h>
-#include <arpa/inet.h>
-#include <net/if.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <xtables.h>
-#include "utils.h"
-#include "tc_util.h"
-#include <linux/tc_act/tc_ipt.h>
-#include <stdio.h>
-#include <getopt.h>
-#include <errno.h>
-#include <string.h>
-#include <netdb.h>
-#include <stdlib.h>
-#include <ctype.h>
-#include <stdarg.h>
-#include <limits.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <sys/wait.h>
-#ifdef TC_CONFIG_XT_H
-#include "xt-internal.h"
-#endif
-
-static const char *pname = "tc-ipt";
-static const char *tname = "mangle";
-static const char *pversion = "0.2";
-
-static const char *ipthooks[] = {
-	"NF_IP_PRE_ROUTING",
-	"NF_IP_LOCAL_IN",
-	"NF_IP_FORWARD",
-	"NF_IP_LOCAL_OUT",
-	"NF_IP_POST_ROUTING",
-};
-
-static struct option original_opts[] = {
-	{"jump", 1, 0, 'j'},
-	{0, 0, 0, 0}
-};
-
-static struct option *opts = original_opts;
-static unsigned int global_option_offset = 0;
-char *lib_dir;
-const char *program_version = XTABLES_VERSION;
-const char *program_name = "tc-ipt";
-struct afinfo afinfo = {
-	.family         = AF_INET,
-	.libprefix      = "libxt_",
-	.ipproto        = IPPROTO_IP,
-	.kmod           = "ip_tables",
-	.so_rev_target  = IPT_SO_GET_REVISION_TARGET,
-};
-
-
-#define OPTION_OFFSET 256
-
-/*XXX: TC_CONFIG_XT_H */
-static void free_opts(struct option *local_opts)
-{
-	if (local_opts != original_opts) {
-		free(local_opts);
-		opts = original_opts;
-		global_option_offset = 0;
-	}
-}
-
-/*XXX: TC_CONFIG_XT_H */
-static struct option *
-merge_options(struct option *oldopts, const struct option *newopts,
-	      unsigned int *option_offset)
-{
-	struct option *merge;
-	unsigned int num_old, num_new, i;
-
-	for (num_old = 0; oldopts[num_old].name; num_old++) ;
-	for (num_new = 0; newopts[num_new].name; num_new++) ;
-
-	*option_offset = global_option_offset + OPTION_OFFSET;
-
-	merge = malloc(sizeof (struct option) * (num_new + num_old + 1));
-	memcpy(merge, oldopts, num_old * sizeof (struct option));
-	for (i = 0; i < num_new; i++) {
-		merge[num_old + i] = newopts[i];
-		merge[num_old + i].val += *option_offset;
-	}
-	memset(merge + num_old + num_new, 0, sizeof (struct option));
-
-	return merge;
-}
-
-
-/*XXX: TC_CONFIG_XT_H */
-#ifndef TRUE
-#define TRUE 1
-#endif
-#ifndef FALSE
-#define FALSE 0
-#endif
-
-/*XXX: TC_CONFIG_XT_H */
-int
-check_inverse(const char option[], int *invert, int *my_optind, int argc)
-{
-        if (option && strcmp(option, "!") == 0) {
-                if (*invert)
-                        exit_error(PARAMETER_PROBLEM,
-                                   "Multiple `!' flags not allowed");
-                *invert = TRUE;
-                if (my_optind != NULL) {
-                        ++*my_optind;
-                        if (argc && *my_optind > argc)
-                                exit_error(PARAMETER_PROBLEM,
-                                           "no argument following `!'");
-                }
-
-                return TRUE;
-        }
-        return FALSE;
-}
-
-/*XXX: TC_CONFIG_XT_H */
-void exit_error(enum exittype status, const char *msg, ...)
-{
-        va_list args;
-
-        va_start(args, msg);
-        fprintf(stderr, "%s v%s: ", pname, pversion);
-        vfprintf(stderr, msg, args);
-        va_end(args);
-        fprintf(stderr, "\n");
-        /* On error paths, make sure that we don't leak memory */
-        exit(status);
-}
-
-/*XXX: TC_CONFIG_XT_H */
-static void set_revision(char *name, u_int8_t revision)
-{
-	/* Old kernel sources don't have ".revision" field,
-	*  but we stole a byte from name. */
-	name[IPT_FUNCTION_MAXNAMELEN - 2] = '\0';
-	name[IPT_FUNCTION_MAXNAMELEN - 1] = revision;
-}
-
-/*
- * we may need to check for version mismatch
-*/
-int
-build_st(struct xtables_target *target, struct xt_entry_target *t)
-{
-
-	size_t size =
-		    XT_ALIGN(sizeof (struct xt_entry_target)) + target->size;
-
-	if (NULL == t) {
-		target->t = fw_calloc(1, size);
-		target->t->u.target_size = size;
-		strcpy(target->t->u.user.name, target->name);
-		set_revision(target->t->u.user.name, target->revision);
-
-		if (target->init != NULL)
-			target->init(target->t);
-	} else {
-		target->t = t;
-	}
-	return 0;
-
-}
-
-inline void set_lib_dir(void)
-{
-
-	lib_dir = getenv("XTABLES_LIBDIR");
-	if (!lib_dir) {
-		lib_dir = getenv("IPTABLES_LIB_DIR");
-		if (lib_dir)
-			fprintf(stderr, "using deprecated IPTABLES_LIB_DIR \n");
-	}
-	if (lib_dir == NULL)
-		lib_dir = XT_LIB_DIR;
-
-}
-
-static int parse_ipt(struct action_util *a,int *argc_p,
-		     char ***argv_p, int tca_id, struct nlmsghdr *n)
-{
-	struct xtables_target *m = NULL;
-	struct ipt_entry fw;
-	struct rtattr *tail;
-	int c;
-	int rargc = *argc_p;
-	char **argv = *argv_p;
-	int argc = 0, iargc = 0;
-	char k[16];
-	int res = -1;
-	int size = 0;
-	int iok = 0, ok = 0;
-	__u32 hook = 0, index = 0;
-	res = 0;
-
-	set_lib_dir();
-
-	{
-		int i;
-		for (i = 0; i < rargc; i++) {
-			if (NULL == argv[i] || 0 == strcmp(argv[i], "action")) {
-				break;
-			}
-		}
-		iargc = argc = i;
-	}
-
-	if (argc <= 2) {
-		fprintf(stderr,"bad arguements to ipt %d vs %d \n", argc, rargc);
-		return -1;
-	}
-
-	while (1) {
-		c = getopt_long(argc, argv, "j:", opts, NULL);
-		if (c == -1)
-			break;
-		switch (c) {
-		case 'j':
-			m = find_target(optarg, TRY_LOAD);
-			if (NULL != m) {
-
-				if (0 > build_st(m, NULL)) {
-					printf(" %s error \n", m->name);
-					return -1;
-				}
-				opts =
-				    merge_options(opts, m->extra_opts,
-						  &m->option_offset);
-			} else {
-				fprintf(stderr," failed to find target %s\n\n", optarg);
-				return -1;
-			}
-			ok++;
-			break;
-
-		default:
-			memset(&fw, 0, sizeof (fw));
-			if (m) {
-				m->parse(c - m->option_offset, argv, 0,
-					 &m->tflags, NULL, &m->t);
-			} else {
-				fprintf(stderr," failed to find target %s\n\n", optarg);
-				return -1;
-
-			}
-			ok++;
-			break;
-
-		}
-	}
-
-	if (iargc > optind) {
-		if (matches(argv[optind], "index") == 0) {
-			if (get_u32(&index, argv[optind + 1], 10)) {
-				fprintf(stderr, "Illegal \"index\"\n");
-				free_opts(opts);
-				return -1;
-			}
-			iok++;
-
-			optind += 2;
-		}
-	}
-
-	if (!ok && !iok) {
-		fprintf(stderr," ipt Parser BAD!! (%s)\n", *argv);
-		return -1;
-	}
-
-	/* check that we passed the correct parameters to the target */
-	if (m)
-		m->final_check(m->tflags);
-
-	{
-		struct tcmsg *t = NLMSG_DATA(n);
-		if (t->tcm_parent != TC_H_ROOT
-		    && t->tcm_parent == TC_H_MAJ(TC_H_INGRESS)) {
-			hook = NF_IP_PRE_ROUTING;
-		} else {
-			hook = NF_IP_POST_ROUTING;
-		}
-	}
-
-	tail = NLMSG_TAIL(n);
-	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
-	fprintf(stdout, "tablename: %s hook: %s\n ", tname, ipthooks[hook]);
-	fprintf(stdout, "\ttarget: ");
-
-	if (m)
-		m->print(NULL, m->t, 0);
-	fprintf(stdout, " index %d\n", index);
-
-	if (strlen(tname) > 16) {
-		size = 16;
-		k[15] = 0;
-	} else {
-		size = 1 + strlen(tname);
-	}
-	strncpy(k, tname, size);
-
-	addattr_l(n, MAX_MSG, TCA_IPT_TABLE, k, size);
-	addattr_l(n, MAX_MSG, TCA_IPT_HOOK, &hook, 4);
-	addattr_l(n, MAX_MSG, TCA_IPT_INDEX, &index, 4);
-	if (m)
-		addattr_l(n, MAX_MSG, TCA_IPT_TARG, m->t, m->t->u.target_size);
-	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
-
-	argc -= optind;
-	argv += optind;
-	*argc_p = rargc - iargc;
-	*argv_p = argv;
-
-	optind = 0;
-	free_opts(opts);
-	/* Clear flags if target will be used again */
-        m->tflags=0;
-        m->used=0;
-	/* Free allocated memory */
-        if (m->t)
-            free(m->t);
-
-
-	return 0;
-
-}
-
-static int
-print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
-{
-	struct rtattr *tb[TCA_IPT_MAX + 1];
-	struct xt_entry_target *t = NULL;
-
-	if (arg == NULL)
-		return -1;
-
-	set_lib_dir();
-
-	parse_rtattr_nested(tb, TCA_IPT_MAX, arg);
-
-	if (tb[TCA_IPT_TABLE] == NULL) {
-		fprintf(f, "[NULL ipt table name ] assuming mangle ");
-	} else {
-		fprintf(f, "tablename: %s ",
-			(char *) RTA_DATA(tb[TCA_IPT_TABLE]));
-	}
-
-	if (tb[TCA_IPT_HOOK] == NULL) {
-		fprintf(f, "[NULL ipt hook name ]\n ");
-		return -1;
-	} else {
-		__u32 hook;
-		hook = *(__u32 *) RTA_DATA(tb[TCA_IPT_HOOK]);
-		fprintf(f, " hook: %s \n", ipthooks[hook]);
-	}
-
-	if (tb[TCA_IPT_TARG] == NULL) {
-		fprintf(f, "\t[NULL ipt target parameters ] \n");
-		return -1;
-	} else {
-		struct xtables_target *m = NULL;
-		t = RTA_DATA(tb[TCA_IPT_TARG]);
-		m = find_target(t->u.user.name, TRY_LOAD);
-		if (NULL != m) {
-			if (0 > build_st(m, t)) {
-				fprintf(stderr, " %s error \n", m->name);
-				return -1;
-			}
-
-			opts =
-			    merge_options(opts, m->extra_opts,
-					  &m->option_offset);
-		} else {
-			fprintf(stderr, " failed to find target %s\n\n",
-				t->u.user.name);
-			return -1;
-		}
-		fprintf(f, "\ttarget ");
-		m->print(NULL, m->t, 0);
-		if (tb[TCA_IPT_INDEX] == NULL) {
-			fprintf(f, " [NULL ipt target index ]\n");
-		} else {
-			__u32 index;
-			index = *(__u32 *) RTA_DATA(tb[TCA_IPT_INDEX]);
-			fprintf(f, " \n\tindex %d", index);
-		}
-
-		if (tb[TCA_IPT_CNT]) {
-			struct tc_cnt *c  = RTA_DATA(tb[TCA_IPT_CNT]);;
-			fprintf(f, " ref %d bind %d", c->refcnt, c->bindcnt);
-		}
-		if (show_stats) {
-			if (tb[TCA_IPT_TM]) {
-				struct tcf_t *tm = RTA_DATA(tb[TCA_IPT_TM]);
-				print_tm(f,tm);
-			}
-		}
-		fprintf(f, " \n");
-
-	}
-	free_opts(opts);
-
-	return 0;
-}
-
-struct action_util ipt_action_util = {
-        .id = "ipt",
-        .parse_aopt = parse_ipt,
-        .print_aopt = print_ipt,
-};
-
diff --git a/tc/m_xt_old.c b/tc/m_xt_old.c
new file mode 100644
index 0000000..0c7ec60
--- /dev/null
+++ b/tc/m_xt_old.c
@@ -0,0 +1,433 @@
+/*
+ * m_xt.c	xtables based targets
+ * 		utilities mostly ripped from iptables <duh, its the linux way>
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca)
+ */
+
+/*XXX: in the future (xtables 1.4.3?) get rid of everything tagged
+ * as TC_CONFIG_XT_H */
+
+#include <syslog.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <net/if.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <xtables.h>
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_ipt.h>
+#include <stdio.h>
+#include <getopt.h>
+#include <errno.h>
+#include <string.h>
+#include <netdb.h>
+#include <stdlib.h>
+#include <ctype.h>
+#include <stdarg.h>
+#include <limits.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <sys/wait.h>
+#ifdef TC_CONFIG_XT_H
+#include "xt-internal.h"
+#endif
+
+static const char *pname = "tc-ipt";
+static const char *tname = "mangle";
+static const char *pversion = "0.2";
+
+static const char *ipthooks[] = {
+	"NF_IP_PRE_ROUTING",
+	"NF_IP_LOCAL_IN",
+	"NF_IP_FORWARD",
+	"NF_IP_LOCAL_OUT",
+	"NF_IP_POST_ROUTING",
+};
+
+static struct option original_opts[] = {
+	{"jump", 1, 0, 'j'},
+	{0, 0, 0, 0}
+};
+
+static struct option *opts = original_opts;
+static unsigned int global_option_offset = 0;
+char *lib_dir;
+const char *program_version = XTABLES_VERSION;
+const char *program_name = "tc-ipt";
+struct afinfo afinfo = {
+	.family         = AF_INET,
+	.libprefix      = "libxt_",
+	.ipproto        = IPPROTO_IP,
+	.kmod           = "ip_tables",
+	.so_rev_target  = IPT_SO_GET_REVISION_TARGET,
+};
+
+
+#define OPTION_OFFSET 256
+
+/*XXX: TC_CONFIG_XT_H */
+static void free_opts(struct option *local_opts)
+{
+	if (local_opts != original_opts) {
+		free(local_opts);
+		opts = original_opts;
+		global_option_offset = 0;
+	}
+}
+
+/*XXX: TC_CONFIG_XT_H */
+static struct option *
+merge_options(struct option *oldopts, const struct option *newopts,
+	      unsigned int *option_offset)
+{
+	struct option *merge;
+	unsigned int num_old, num_new, i;
+
+	for (num_old = 0; oldopts[num_old].name; num_old++) ;
+	for (num_new = 0; newopts[num_new].name; num_new++) ;
+
+	*option_offset = global_option_offset + OPTION_OFFSET;
+
+	merge = malloc(sizeof (struct option) * (num_new + num_old + 1));
+	memcpy(merge, oldopts, num_old * sizeof (struct option));
+	for (i = 0; i < num_new; i++) {
+		merge[num_old + i] = newopts[i];
+		merge[num_old + i].val += *option_offset;
+	}
+	memset(merge + num_old + num_new, 0, sizeof (struct option));
+
+	return merge;
+}
+
+
+/*XXX: TC_CONFIG_XT_H */
+#ifndef TRUE
+#define TRUE 1
+#endif
+#ifndef FALSE
+#define FALSE 0
+#endif
+
+/*XXX: TC_CONFIG_XT_H */
+int
+check_inverse(const char option[], int *invert, int *my_optind, int argc)
+{
+        if (option && strcmp(option, "!") == 0) {
+                if (*invert)
+                        exit_error(PARAMETER_PROBLEM,
+                                   "Multiple `!' flags not allowed");
+                *invert = TRUE;
+                if (my_optind != NULL) {
+                        ++*my_optind;
+                        if (argc && *my_optind > argc)
+                                exit_error(PARAMETER_PROBLEM,
+                                           "no argument following `!'");
+                }
+
+                return TRUE;
+        }
+        return FALSE;
+}
+
+/*XXX: TC_CONFIG_XT_H */
+void exit_error(enum exittype status, const char *msg, ...)
+{
+        va_list args;
+
+        va_start(args, msg);
+        fprintf(stderr, "%s v%s: ", pname, pversion);
+        vfprintf(stderr, msg, args);
+        va_end(args);
+        fprintf(stderr, "\n");
+        /* On error paths, make sure that we don't leak memory */
+        exit(status);
+}
+
+/*XXX: TC_CONFIG_XT_H */
+static void set_revision(char *name, u_int8_t revision)
+{
+	/* Old kernel sources don't have ".revision" field,
+	*  but we stole a byte from name. */
+	name[IPT_FUNCTION_MAXNAMELEN - 2] = '\0';
+	name[IPT_FUNCTION_MAXNAMELEN - 1] = revision;
+}
+
+/*
+ * we may need to check for version mismatch
+*/
+int
+build_st(struct xtables_target *target, struct xt_entry_target *t)
+{
+
+	size_t size =
+		    XT_ALIGN(sizeof (struct xt_entry_target)) + target->size;
+
+	if (NULL == t) {
+		target->t = fw_calloc(1, size);
+		target->t->u.target_size = size;
+		strcpy(target->t->u.user.name, target->name);
+		set_revision(target->t->u.user.name, target->revision);
+
+		if (target->init != NULL)
+			target->init(target->t);
+	} else {
+		target->t = t;
+	}
+	return 0;
+
+}
+
+inline void set_lib_dir(void)
+{
+
+	lib_dir = getenv("XTABLES_LIBDIR");
+	if (!lib_dir) {
+		lib_dir = getenv("IPTABLES_LIB_DIR");
+		if (lib_dir)
+			fprintf(stderr, "using deprecated IPTABLES_LIB_DIR \n");
+	}
+	if (lib_dir == NULL)
+		lib_dir = XT_LIB_DIR;
+
+}
+
+static int parse_ipt(struct action_util *a,int *argc_p,
+		     char ***argv_p, int tca_id, struct nlmsghdr *n)
+{
+	struct xtables_target *m = NULL;
+	struct ipt_entry fw;
+	struct rtattr *tail;
+	int c;
+	int rargc = *argc_p;
+	char **argv = *argv_p;
+	int argc = 0, iargc = 0;
+	char k[16];
+	int res = -1;
+	int size = 0;
+	int iok = 0, ok = 0;
+	__u32 hook = 0, index = 0;
+	res = 0;
+
+	set_lib_dir();
+
+	{
+		int i;
+		for (i = 0; i < rargc; i++) {
+			if (NULL == argv[i] || 0 == strcmp(argv[i], "action")) {
+				break;
+			}
+		}
+		iargc = argc = i;
+	}
+
+	if (argc <= 2) {
+		fprintf(stderr,"bad arguements to ipt %d vs %d \n", argc, rargc);
+		return -1;
+	}
+
+	while (1) {
+		c = getopt_long(argc, argv, "j:", opts, NULL);
+		if (c == -1)
+			break;
+		switch (c) {
+		case 'j':
+			m = find_target(optarg, TRY_LOAD);
+			if (NULL != m) {
+
+				if (0 > build_st(m, NULL)) {
+					printf(" %s error \n", m->name);
+					return -1;
+				}
+				opts =
+				    merge_options(opts, m->extra_opts,
+						  &m->option_offset);
+			} else {
+				fprintf(stderr," failed to find target %s\n\n", optarg);
+				return -1;
+			}
+			ok++;
+			break;
+
+		default:
+			memset(&fw, 0, sizeof (fw));
+			if (m) {
+				m->parse(c - m->option_offset, argv, 0,
+					 &m->tflags, NULL, &m->t);
+			} else {
+				fprintf(stderr," failed to find target %s\n\n", optarg);
+				return -1;
+
+			}
+			ok++;
+			break;
+
+		}
+	}
+
+	if (iargc > optind) {
+		if (matches(argv[optind], "index") == 0) {
+			if (get_u32(&index, argv[optind + 1], 10)) {
+				fprintf(stderr, "Illegal \"index\"\n");
+				free_opts(opts);
+				return -1;
+			}
+			iok++;
+
+			optind += 2;
+		}
+	}
+
+	if (!ok && !iok) {
+		fprintf(stderr," ipt Parser BAD!! (%s)\n", *argv);
+		return -1;
+	}
+
+	/* check that we passed the correct parameters to the target */
+	if (m)
+		m->final_check(m->tflags);
+
+	{
+		struct tcmsg *t = NLMSG_DATA(n);
+		if (t->tcm_parent != TC_H_ROOT
+		    && t->tcm_parent == TC_H_MAJ(TC_H_INGRESS)) {
+			hook = NF_IP_PRE_ROUTING;
+		} else {
+			hook = NF_IP_POST_ROUTING;
+		}
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	fprintf(stdout, "tablename: %s hook: %s\n ", tname, ipthooks[hook]);
+	fprintf(stdout, "\ttarget: ");
+
+	if (m)
+		m->print(NULL, m->t, 0);
+	fprintf(stdout, " index %d\n", index);
+
+	if (strlen(tname) > 16) {
+		size = 16;
+		k[15] = 0;
+	} else {
+		size = 1 + strlen(tname);
+	}
+	strncpy(k, tname, size);
+
+	addattr_l(n, MAX_MSG, TCA_IPT_TABLE, k, size);
+	addattr_l(n, MAX_MSG, TCA_IPT_HOOK, &hook, 4);
+	addattr_l(n, MAX_MSG, TCA_IPT_INDEX, &index, 4);
+	if (m)
+		addattr_l(n, MAX_MSG, TCA_IPT_TARG, m->t, m->t->u.target_size);
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+
+	argc -= optind;
+	argv += optind;
+	*argc_p = rargc - iargc;
+	*argv_p = argv;
+
+	optind = 0;
+	free_opts(opts);
+	/* Clear flags if target will be used again */
+        m->tflags=0;
+        m->used=0;
+	/* Free allocated memory */
+        if (m->t)
+            free(m->t);
+
+
+	return 0;
+
+}
+
+static int
+print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
+{
+	struct rtattr *tb[TCA_IPT_MAX + 1];
+	struct xt_entry_target *t = NULL;
+
+	if (arg == NULL)
+		return -1;
+
+	set_lib_dir();
+
+	parse_rtattr_nested(tb, TCA_IPT_MAX, arg);
+
+	if (tb[TCA_IPT_TABLE] == NULL) {
+		fprintf(f, "[NULL ipt table name ] assuming mangle ");
+	} else {
+		fprintf(f, "tablename: %s ",
+			(char *) RTA_DATA(tb[TCA_IPT_TABLE]));
+	}
+
+	if (tb[TCA_IPT_HOOK] == NULL) {
+		fprintf(f, "[NULL ipt hook name ]\n ");
+		return -1;
+	} else {
+		__u32 hook;
+		hook = *(__u32 *) RTA_DATA(tb[TCA_IPT_HOOK]);
+		fprintf(f, " hook: %s \n", ipthooks[hook]);
+	}
+
+	if (tb[TCA_IPT_TARG] == NULL) {
+		fprintf(f, "\t[NULL ipt target parameters ] \n");
+		return -1;
+	} else {
+		struct xtables_target *m = NULL;
+		t = RTA_DATA(tb[TCA_IPT_TARG]);
+		m = find_target(t->u.user.name, TRY_LOAD);
+		if (NULL != m) {
+			if (0 > build_st(m, t)) {
+				fprintf(stderr, " %s error \n", m->name);
+				return -1;
+			}
+
+			opts =
+			    merge_options(opts, m->extra_opts,
+					  &m->option_offset);
+		} else {
+			fprintf(stderr, " failed to find target %s\n\n",
+				t->u.user.name);
+			return -1;
+		}
+		fprintf(f, "\ttarget ");
+		m->print(NULL, m->t, 0);
+		if (tb[TCA_IPT_INDEX] == NULL) {
+			fprintf(f, " [NULL ipt target index ]\n");
+		} else {
+			__u32 index;
+			index = *(__u32 *) RTA_DATA(tb[TCA_IPT_INDEX]);
+			fprintf(f, " \n\tindex %d", index);
+		}
+
+		if (tb[TCA_IPT_CNT]) {
+			struct tc_cnt *c  = RTA_DATA(tb[TCA_IPT_CNT]);;
+			fprintf(f, " ref %d bind %d", c->refcnt, c->bindcnt);
+		}
+		if (show_stats) {
+			if (tb[TCA_IPT_TM]) {
+				struct tcf_t *tm = RTA_DATA(tb[TCA_IPT_TM]);
+				print_tm(f,tm);
+			}
+		}
+		fprintf(f, " \n");
+
+	}
+	free_opts(opts);
+
+	return 0;
+}
+
+struct action_util ipt_action_util = {
+        .id = "ipt",
+        .parse_aopt = parse_ipt,
+        .print_aopt = print_ipt,
+};
+
-- 
1.6.5.3

