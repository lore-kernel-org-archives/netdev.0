From: jamal <hadi@cyberus.ca>
Subject: [PATCH] iproute2 : fix to catchup with xtables/iptables >= 1.4.2
Date: Sun, 25 Jan 2009 13:32:32 -0500
Message-ID: <1232908352.13279.33.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ziq6xvALGk13+mbH658D"
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>,
	Yevgeny Kosarzhevsky <yevg@pisem.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f10.google.com ([209.85.219.10]:40992 "EHLO
	mail-ew0-f10.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbZAYSep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 13:34:45 -0500
Received: by ewy3 with SMTP id 3so552543ewy.13
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2009 10:34:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ziq6xvALGk13+mbH658D
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Sorry for the long CC (copying all stakeholders)

Against latest iproute2 git - fixes breakage found with debian and
certainly with any distro using iptables 1.4.2.

A small depart from the old ipt - to keep in sync with iptable/xtables
changes. The old ipt should continue to work for iptables <1.4.1. And
with this change, no old scripts will break.
 
[Breakage will happen again (probably by the time we hit iptables 1.4.3)
because xtables is still a moving target. There are quiet a few
functions which really should be part of xtables but are currently not -
I have labelled them in tc/m_xt.c].

cheers,
jamal


--=-ziq6xvALGk13+mbH658D
Content-Disposition: attachment; filename=pf0
Content-Type: text/plain; name=pf0; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit 63ffd93046f1351c68a3276ecb274d52a2af86a8
Author: jamal <hadi@cyberus.ca>
Date:   Sun Jan 25 13:14:40 2009 -0500

    Breakage noticed when debian upgraded to xtables (iptables > 1.4.1)
    
    Many thanks to Yevgeny Kosarzhevsky <yevg@pisem.net> for reporting
    and a lot of testing
    
    Thanks to Jan Engelhardt <jengelh@medozas.de> for a lot of advice
    Thanks to Denys Fedoryschenko <denys@visp.net.lb> for some sample
    code that he tried and thanks to Andreas Henriksson <andreas@fatal.se>
    (who maintains iproute2 on debian) for the persistent followup.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/configure b/configure
index dc14e54..df40370 100755
--- a/configure
+++ b/configure
@@ -25,3 +25,70 @@ else
     echo no
 fi
 rm -f /tmp/atmtest.c /tmp/atmtest
+
+echo -n " IPT	"
+
+#check if we need dont our internal header ..
+cat >/tmp/ipttest.c <<EOF
+#include <xtables.h>
+char *lib_dir;
+unsigned int global_option_offset = 0;
+const char *program_version = XTABLES_VERSION;
+const char *program_name = "tc-ipt";
+struct afinfo afinfo = {
+	.libprefix      = "libxt_",
+};
+
+void exit_error(enum exittype status, const char *msg, ...)
+{
+}
+
+int main(int argc, char **argv) {
+
+	return 0;
+}
+
+EOF
+gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
+
+if [ $? -eq 0 ]
+then
+	echo "TC_CONFIG_XT:=y" >>Config
+	echo "using xtables seems no need for internal.h"
+else
+	echo "failed test 2"
+fi
+
+#check if we need our own internal.h
+cat >/tmp/ipttest.c <<EOF
+#include <xtables.h>
+#include "xt-internal.h"
+char *lib_dir;
+unsigned int global_option_offset = 0;
+const char *program_version = XTABLES_VERSION;
+const char *program_name = "tc-ipt";
+struct afinfo afinfo = {
+	.libprefix      = "libxt_",
+};
+
+void exit_error(enum exittype status, const char *msg, ...)
+{
+}
+
+int main(int argc, char **argv) {
+
+	return 0;
+}
+
+EOF
+gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
+
+if [ $? -eq 0 ]
+then
+	echo "using xtables instead of iptables (need for internal.h)"
+	echo "TC_CONFIG_XT_H:=y" >>Config
+
+else
+	echo "failed test 3 using iptables"
+fi
+rm -f /tmp/ipttest.c /tmp/ipttest
diff --git a/include/xt-internal.h b/include/xt-internal.h
new file mode 100644
index 0000000..b8ea67d
--- /dev/null
+++ b/include/xt-internal.h
@@ -0,0 +1,66 @@
+#ifndef _XTABLES_INTERNAL_H
+#define _XTABLES_INTERNAL_H 1
+
+#ifndef XT_LIB_DIR
+#	define XT_LIB_DIR "/lib/xtables"
+#endif
+
+/* protocol family dependent informations */
+struct afinfo {
+	/* protocol family */
+	int family;
+
+	/* prefix of library name (ex "libipt_" */
+	char *libprefix;
+
+	/* used by setsockopt (ex IPPROTO_IP */
+	int ipproto;
+
+	/* kernel module (ex "ip_tables" */
+	char *kmod;
+
+	/* optname to check revision support of match */
+	int so_rev_match;
+
+	/* optname to check revision support of match */
+	int so_rev_target;
+};
+
+enum xt_tryload {
+	DONT_LOAD,
+	DURING_LOAD,
+	TRY_LOAD,
+	LOAD_MUST_SUCCEED
+};
+
+struct xtables_rule_match {
+	struct xtables_rule_match *next;
+	struct xtables_match *match;
+	/* Multiple matches of the same type: the ones before
+	   the current one are completed from parsing point of view */
+	unsigned int completed;
+};
+
+extern char *lib_dir;
+
+extern void *fw_calloc(size_t count, size_t size);
+extern void *fw_malloc(size_t size);
+
+extern const char *modprobe_program;
+extern int xtables_insmod(const char *modname, const char *modprobe, int quiet);
+extern int load_xtables_ko(const char *modprobe, int quiet);
+
+/* This is decleared in ip[6]tables.c */
+extern struct afinfo afinfo;
+
+/* Keeping track of external matches and targets: linked lists.  */
+extern struct xtables_match *xtables_matches;
+extern struct xtables_target *xtables_targets;
+
+extern struct xtables_match *find_match(const char *name, enum xt_tryload,
+					struct xtables_rule_match **match);
+extern struct xtables_target *find_target(const char *name, enum xt_tryload);
+
+extern void _init(void);
+
+#endif /* _XTABLES_INTERNAL_H */
diff --git a/tc/Makefile b/tc/Makefile
index bd9b833..855fcf6 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -28,7 +28,6 @@ TCMODULES += q_hfsc.o
 TCMODULES += q_htb.o
 TCMODULES += m_gact.o
 TCMODULES += m_mirred.o
-TCMODULES += m_ipt.o
 TCMODULES += m_nat.o
 TCMODULES += m_pedit.o
 TCMODULES += m_skbedit.o
@@ -41,7 +40,22 @@ TCMODULES += em_cmp.o
 TCMODULES += em_u32.o
 TCMODULES += em_meta.o
 
+
+ifeq ($(TC_CONFIG_XT),y)
+  TCMODULES += m_xt.o
+  LDLIBS += -lxtables
+else
+  ifeq ($(TC_CONFIG_XT_H),y)
+	CFLAGS += -DTC_CONFIG_XT_H
+	TCMODULES += m_xt.o
+	LDLIBS += -lxtables
+  else
+  TCMODULES += m_ipt.o
+  endif
+endif
+
 TCOBJ += $(TCMODULES)
+LDLIBS += -L. -ltc -lm -ldl
 
 TCLIB := tc_core.o
 TCLIB += tc_red.o
@@ -56,7 +70,6 @@ ifeq ($(TC_CONFIG_ATM),y)
   TCSO += q_atm.so
 endif
 
-LDLIBS += -L. -ltc -lm -ldl
 
 LDFLAGS += -Wl,-export-dynamic
 
diff --git a/tc/m_xt.c b/tc/m_xt.c
new file mode 100644
index 0000000..7dbe670
--- /dev/null
+++ b/tc/m_xt.c
@@ -0,0 +1,435 @@
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
+#include <linux/if.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <xtables.h>
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_ipt.h>
+#include <stdio.h>
+#include <dlfcn.h>
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
+
+/*XXX: TC_CONFIG_XT_H */
+static void free_opts(struct option *opts)
+{
+	if (opts != original_opts) {
+		free(opts);
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

--=-ziq6xvALGk13+mbH658D--

