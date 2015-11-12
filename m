From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] {f,m}_bpf: allow for sharing maps
Date: Fri, 13 Nov 2015 00:39:29 +0100
Message-ID: <fb36dba8b867c3fce59560e2a8b295c0ae13a24c.1447323729.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57865 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511AbbKLXje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 18:39:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This larger work addresses one of the bigger remaining issues on
tc's eBPF frontend, that is, to allow for persistent file descriptors.
Whenever tc parses the ELF object, extracts and loads maps into the
kernel, these file descriptors will be out of reach after the tc
instance exits.

Meaning, for simple (unnested) programs which contain one or
multiple maps, the kernel holds a reference, and they will live
on inside the kernel until the program holding them is unloaded,
but they will be out of reach for user space, even worse with
(also multiple nested) tail calls.

For this issue, we introduced the concept of an agent that can
receive the set of file descriptors from the tc instance creating
them, in order to be able to further inspect/update map data for
a specific use case. However, while that is more tied towards
specific applications, it still doesn't easily allow for sharing
maps accross multiple tc instances and would require a daemon to
be running in the background. F.e. when a map should be shared by
two eBPF programs, one attached to ingress, one to egress, this
currently doesn't work with the tc frontend.

This work solves exactly that, i.e. if requested, maps can now be
_arbitrarily_ shared between object files (PIN_GLOBAL_NS) or within
a single object (but various program sections, PIN_OBJECT_NS) without
"loosing" the file descriptor set. To make that happen, we use eBPF
object pinning introduced in kernel commit b2197755b263 ("bpf: add
support for persistent maps/progs") for exactly this purpose.

The shipped examples/bpf/bpf_shared.c code from this patch can be
easily applied, for instance, as:

 - classifier-classifier shared:

  tc filter add dev foo parent 1: bpf obj shared.o sec egress
  tc filter add dev foo parent ffff: bpf obj shared.o sec ingress

 - classifier-action shared (here: late binding to a dummy classifier):

  tc actions add action bpf obj shared.o sec egress pass index 42
  tc filter add dev foo parent ffff: bpf obj shared.o sec ingress
  tc filter add dev foo parent 1: bpf bytecode '1,6 0 0 4294967295,' \
     action bpf index 42

The toy example increments a shared counter on egress and dumps its
value on ingress (if no sharing (PIN_NONE) would have been chosen,
map value is 0, of course, due to the two map instances being created):

  [...]
          <idle>-0     [002] ..s. 38264.788234: : map val: 4
          <idle>-0     [002] ..s. 38264.788919: : map val: 4
          <idle>-0     [002] ..s. 38264.789599: : map val: 5
  [...]

... thus if both sections reference the pinned map(s) in question,
tc will take care of fetching the appropriate file descriptor.

The patch has been tested extensively on both, classifier and
action sides.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 Hi Stephen,

 this requires a header rebase to get BPF_OBJ_PIN/BPF_OBJ_GET related
 things included. I've not included it here as you have your scripts
 for that anyway. The patch is targeted at the -next branch, so we have
 a good amount of linger time. I'll follow-up later with a refresh of
 the man-page to document all recently introduced features for {f,m}_bpf
 from this and previous patches.

 Thanks!

 examples/bpf/bpf_funcs.h  |    7 +
 examples/bpf/bpf_shared.c |   54 ++
 examples/bpf/bpf_shared.h |    4 -
 include/bpf_elf.h         |    6 +
 include/utils.h           |    3 +
 tc/e_bpf.c                |   18 +-
 tc/f_bpf.c                |  131 +----
 tc/m_bpf.c                |  158 ++----
 tc/tc_bpf.c               | 1259 +++++++++++++++++++++++++++++++++------------
 tc/tc_bpf.h               |   73 ++-
 10 files changed, 1105 insertions(+), 608 deletions(-)
 create mode 100644 examples/bpf/bpf_shared.c

diff --git a/examples/bpf/bpf_funcs.h b/examples/bpf/bpf_funcs.h
index 1545fa9..1369401 100644
--- a/examples/bpf/bpf_funcs.h
+++ b/examples/bpf/bpf_funcs.h
@@ -1,6 +1,10 @@
 #ifndef __BPF_FUNCS__
 #define __BPF_FUNCS__
 
+#include <stdint.h>
+
+#include "../../include/bpf_elf.h"
+
 /* Misc macros. */
 #ifndef __maybe_unused
 # define __maybe_unused		__attribute__ ((__unused__))
@@ -43,6 +47,9 @@ static unsigned int (*get_smp_processor_id)(void) __maybe_unused =
 static unsigned int (*get_prandom_u32)(void) __maybe_unused =
 	(void *) BPF_FUNC_get_prandom_u32;
 
+static int (*bpf_printk)(const char *fmt, int fmt_size, ...) __maybe_unused =
+	(void *) BPF_FUNC_trace_printk;
+
 /* LLVM built-in functions that an eBPF C program may use to emit
  * BPF_LD_ABS and BPF_LD_IND instructions.
  */
diff --git a/examples/bpf/bpf_shared.c b/examples/bpf/bpf_shared.c
new file mode 100644
index 0000000..a8dc39c
--- /dev/null
+++ b/examples/bpf/bpf_shared.c
@@ -0,0 +1,54 @@
+#include <linux/bpf.h>
+
+#include "bpf_funcs.h"
+
+/* Minimal, stand-alone toy map pinning example:
+ *
+ * clang -target bpf -O2 [...] -o bpf_shared.o -c bpf_shared.c
+ * tc filter add dev foo parent 1: bpf obj bpf_shared.o sec egress
+ * tc filter add dev foo parent ffff: bpf obj bpf_shared.o sec ingress
+ *
+ * Both classifier will share the very same map instance in this example,
+ * so map content can be accessed from ingress *and* egress side!
+ *
+ * This example has a pinning of PIN_OBJECT_NS, so it's private and
+ * thus shared among various program sections within the object.
+ *
+ * A setting of PIN_GLOBAL_NS would place it into a global namespace,
+ * so that it can be shared among different object files. A setting
+ * of PIN_NONE (= 0) means no sharing, so each tc invocation a new map
+ * instance is being created.
+ */
+
+struct bpf_elf_map __section("maps") map_sh = {
+	.type		= BPF_MAP_TYPE_ARRAY,
+	.size_key	= sizeof(int),
+	.size_value	= sizeof(int),
+	.pinning	= PIN_OBJECT_NS, /* or PIN_GLOBAL_NS, or PIN_NONE */
+	.max_elem	= 1,
+};
+
+__section("egress") int emain(struct __sk_buff *skb)
+{
+	int key = 0, *val;
+
+	val = bpf_map_lookup_elem(&map_sh, &key);
+	if (val)
+		__sync_fetch_and_add(val, 1);
+
+	return -1;
+}
+
+__section("ingress") int imain(struct __sk_buff *skb)
+{
+	char fmt[] = "map val: %d\n";
+	int key = 0, *val;
+
+	val = bpf_map_lookup_elem(&map_sh, &key);
+	if (val)
+		bpf_printk(fmt, sizeof(fmt), *val);
+
+	return -1;
+}
+
+char __license[] __section("license") = "GPL";
diff --git a/examples/bpf/bpf_shared.h b/examples/bpf/bpf_shared.h
index 46423ec..ea8f014 100644
--- a/examples/bpf/bpf_shared.h
+++ b/examples/bpf/bpf_shared.h
@@ -1,10 +1,6 @@
 #ifndef __BPF_SHARED__
 #define __BPF_SHARED__
 
-#include <stdint.h>
-
-#include "../../include/bpf_elf.h"
-
 enum {
 	BPF_MAP_ID_PROTO,
 	BPF_MAP_ID_QUEUE,
diff --git a/include/bpf_elf.h b/include/bpf_elf.h
index 4bd6bb0..0690dd6 100644
--- a/include/bpf_elf.h
+++ b/include/bpf_elf.h
@@ -21,6 +21,11 @@
 #define ELF_MAX_MAPS		64
 #define ELF_MAX_LICENSE_LEN	128
 
+/* Object pinning settings */
+#define PIN_NONE		0
+#define PIN_OBJECT_NS		1
+#define PIN_GLOBAL_NS		2
+
 /* ELF map definition */
 struct bpf_elf_map {
 	__u32 type;
@@ -28,6 +33,7 @@ struct bpf_elf_map {
 	__u32 size_value;
 	__u32 max_elem;
 	__u32 id;
+	__u8  pinning;
 };
 
 #endif /* __BPF_ELF__ */
diff --git a/include/utils.h b/include/utils.h
index 1d35149..5902a98 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -192,6 +192,9 @@ void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
 	__attribute__ ((format (printf, (pos_str), (pos_args))))
 #endif
 
+#define _textify(x)	#x
+#define textify(x)	_textify(x)
+
 #define htonll(x) ((1==htonl(1)) ? (x) : ((uint64_t)htonl((x) & 0xFFFFFFFF) << 32) | htonl((x) >> 32))
 #define ntohll(x) ((1==ntohl(1)) ? (x) : ((uint64_t)ntohl((x) & 0xFFFFFFFF) << 32) | ntohl((x) >> 32))
 
diff --git a/tc/e_bpf.c b/tc/e_bpf.c
index 218ba40..1f386c3 100644
--- a/tc/e_bpf.c
+++ b/tc/e_bpf.c
@@ -26,7 +26,7 @@ static char *argv_default[] = { BPF_DEFAULT_CMD, NULL };
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... bpf [ import UDS_FILE ] [ run CMD ]\n\n");
+	fprintf(stderr, "Usage: ... bpf [ import UDS_FILE ] [ run CMD ] [ debug ]\n\n");
 	fprintf(stderr, "Where UDS_FILE provides the name of a unix domain socket file\n");
 	fprintf(stderr, "to import eBPF maps and the optional CMD denotes the command\n");
 	fprintf(stderr, "to be executed (default: \'%s\').\n", BPF_DEFAULT_CMD);
@@ -58,17 +58,21 @@ static int parse_bpf(struct exec_util *eu, int argc, char **argv)
 			NEXT_ARG();
 			argv_run = argv;
 			break;
-		} else if (matches(*argv, "import") == 0 ||
-			   matches(*argv, "imp") == 0) {
+		} else if (matches(*argv, "import") == 0) {
 			NEXT_ARG();
 			bpf_uds_name = *argv;
+		} else if (matches(*argv, "debug") == 0 ||
+			   matches(*argv, "dbg") == 0) {
+			if (bpf_trace_pipe())
+				fprintf(stderr,
+					"No trace pipe, tracefs not mounted?\n");
+			return -1;
 		} else {
 			explain();
 			return -1;
 		}
 
-		argc--;
-		argv++;
+		NEXT_ARG_FWD();
 	}
 
 	if (!bpf_uds_name) {
@@ -142,6 +146,6 @@ err:
 }
 
 struct exec_util bpf_exec_util = {
-	.id = "bpf",
-	.parse_eopt = parse_bpf,
+	.id		= "bpf",
+	.parse_eopt	= parse_bpf,
 };
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index ac77af5..afc2e58 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -11,19 +11,8 @@
 
 #include <stdio.h>
 #include <stdlib.h>
-#include <unistd.h>
-#include <syslog.h>
-#include <fcntl.h>
-#include <libgen.h>
-#include <sys/socket.h>
-#include <netinet/in.h>
-#include <arpa/inet.h>
-#include <string.h>
-#include <stdbool.h>
-#include <errno.h>
-#include <limits.h>
-#include <linux/filter.h>
-#include <linux/if.h>
+
+#include <linux/bpf.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -31,6 +20,13 @@
 
 static const enum bpf_prog_type bpf_type = BPF_PROG_TYPE_SCHED_CLS;
 
+static const int nla_tbl[BPF_NLA_MAX] = {
+	[BPF_NLA_OPS_LEN]	= TCA_BPF_OPS_LEN,
+	[BPF_NLA_OPS]		= TCA_BPF_OPS,
+	[BPF_NLA_FD]		= TCA_BPF_FD,
+	[BPF_NLA_NAME]		= TCA_BPF_NAME,
+};
+
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... bpf ...\n");
@@ -42,6 +38,7 @@ static void explain(void)
 	fprintf(stderr, "eBPF use case:\n");
 	fprintf(stderr, " object-file FILE [ section CLS_NAME ] [ export UDS_FILE ]");
 	fprintf(stderr, " [ verbose ] [ direct-action ]\n");
+	fprintf(stderr, " object-pinned FILE [ direct-action ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Common remaining options:\n");
 	fprintf(stderr, " [ action ACTION_SPEC ]\n");
@@ -51,7 +48,8 @@ static void explain(void)
 	fprintf(stderr, "c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string,\n");
-	fprintf(stderr, "an ELF file containing eBPF map definitions and bytecode.\n");
+	fprintf(stderr, "an ELF file containing eBPF map definitions and bytecode, or a\n");
+	fprintf(stderr, "pinned eBPF program.\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where CLS_NAME refers to the section name containing the\n");
 	fprintf(stderr, "classifier (default \'%s\').\n", bpf_default_section(bpf_type));
@@ -66,119 +64,38 @@ static void explain(void)
 static int bpf_parse_opt(struct filter_util *qu, char *handle,
 			 int argc, char **argv, struct nlmsghdr *n)
 {
+	const char *bpf_obj = NULL, *bpf_uds_name = NULL;
 	struct tcmsg *t = NLMSG_DATA(n);
-	const char *bpf_uds_name = NULL;
-	const char *bpf_sec_name = NULL;
 	unsigned int bpf_flags = 0;
-	char *bpf_obj = NULL;
-	struct rtattr *tail;
 	bool seen_run = false;
-	long h = 0;
+	struct rtattr *tail;
 	int ret = 0;
 
 	if (argc == 0)
 		return 0;
 
 	if (handle) {
-		h = strtol(handle, NULL, 0);
-		if (h == LONG_MIN || h == LONG_MAX) {
-			fprintf(stderr, "Illegal handle \"%s\", must be "
-				"numeric.\n", handle);
+		if (get_u32(&t->tcm_handle, handle, 0)) {
+			fprintf(stderr, "Illegal \"handle\"\n");
 			return -1;
 		}
 	}
 
-	t->tcm_handle = h;
-
 	tail = (struct rtattr *)(((void *)n) + NLMSG_ALIGN(n->nlmsg_len));
 	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
 
 	while (argc > 0) {
 		if (matches(*argv, "run") == 0) {
-			struct sock_filter bpf_ops[BPF_MAXINSNS];
-			bool from_file, ebpf, bpf_verbose;
-			int ret;
-
 			NEXT_ARG();
 opt_bpf:
-			bpf_sec_name = bpf_default_section(bpf_type);
-			bpf_verbose = false;
-			ebpf = false;
 			seen_run = true;
-
-			if (strcmp(*argv, "bytecode-file") == 0 ||
-			    strcmp(*argv, "bcf") == 0) {
-				from_file = true;
-			} else if (strcmp(*argv, "bytecode") == 0 ||
-				   strcmp(*argv, "bc") == 0) {
-				from_file = false;
-			} else if (strcmp(*argv, "object-file") == 0 ||
-				   strcmp(*argv, "obj") == 0) {
-				ebpf = true;
-			} else {
-				fprintf(stderr, "What is \"%s\"?\n", *argv);
-				explain();
-				return -1;
-			}
-
-			NEXT_ARG();
-			if (ebpf) {
-				bpf_uds_name = getenv(BPF_ENV_UDS);
-				bpf_obj = *argv;
-
-				NEXT_ARG_FWD();
-
-				if (argc > 0 &&
-				    (strcmp(*argv, "section") == 0 ||
-				     strcmp(*argv, "sec") == 0)) {
-					NEXT_ARG();
-					bpf_sec_name = *argv;
-					NEXT_ARG_FWD();
-				}
-				if (argc > 0 && !bpf_uds_name &&
-				    (strcmp(*argv, "export") == 0 ||
-				     strcmp(*argv, "exp") == 0)) {
-					NEXT_ARG();
-					bpf_uds_name = *argv;
-					NEXT_ARG_FWD();
-				}
-				if (argc > 0 &&
-				    (strcmp(*argv, "verbose") == 0 ||
-				     strcmp(*argv, "verb") == 0)) {
-					bpf_verbose = true;
-					NEXT_ARG_FWD();
-				}
-
-				PREV_ARG();
-			}
-
-			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name,
-						     bpf_verbose) :
-				     bpf_parse_ops(argc, argv, bpf_ops, from_file);
-			if (ret < 0) {
-				fprintf(stderr, "%s\n", ebpf ?
-					"Could not load object" :
-					"Illegal \"bytecode\"");
+			if (bpf_parse_common(&argc, &argv, nla_tbl, bpf_type,
+					     &bpf_obj, &bpf_uds_name, n)) {
+				fprintf(stderr, "Failed to retrieve (e)BPF data!\n");
 				return -1;
 			}
-
-			if (ebpf) {
-				char bpf_name[256];
-
-				bpf_obj = basename(bpf_obj);
-
-				snprintf(bpf_name, sizeof(bpf_name), "%s:[%s]",
-					 bpf_obj, bpf_sec_name);
-
-				addattr32(n, MAX_MSG, TCA_BPF_FD, ret);
-				addattrstrz(n, MAX_MSG, TCA_BPF_NAME, bpf_name);
-			} else {
-				addattr16(n, MAX_MSG, TCA_BPF_OPS_LEN, ret);
-				addattr_l(n, MAX_MSG, TCA_BPF_OPS, &bpf_ops,
-					  ret * sizeof(struct sock_filter));
-			}
 		} else if (matches(*argv, "classid") == 0 ||
-			   strcmp(*argv, "flowid") == 0) {
+			   matches(*argv, "flowid") == 0) {
 			unsigned int handle;
 
 			NEXT_ARG();
@@ -204,7 +121,7 @@ opt_bpf:
 				return -1;
 			}
 			continue;
-		} else if (strcmp(*argv, "help") == 0) {
+		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
 		} else {
@@ -280,7 +197,7 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 }
 
 struct filter_util bpf_filter_util = {
-	.id = "bpf",
-	.parse_fopt = bpf_parse_opt,
-	.print_fopt = bpf_print_opt,
+	.id		= "bpf",
+	.parse_fopt	= bpf_parse_opt,
+	.print_fopt	= bpf_print_opt,
 };
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index fb4c3c7..c5e2fa5 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -12,20 +12,23 @@
 
 #include <stdio.h>
 #include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-#include <stdbool.h>
-#include <libgen.h>
+
 #include <linux/bpf.h>
 #include <linux/tc_act/tc_bpf.h>
 
 #include "utils.h"
-#include "rt_names.h"
 #include "tc_util.h"
 #include "tc_bpf.h"
 
 static const enum bpf_prog_type bpf_type = BPF_PROG_TYPE_SCHED_ACT;
 
+static const int nla_tbl[BPF_NLA_MAX] = {
+	[BPF_NLA_OPS_LEN]	= TCA_ACT_BPF_OPS_LEN,
+	[BPF_NLA_OPS]		= TCA_ACT_BPF_OPS,
+	[BPF_NLA_FD]		= TCA_ACT_BPF_FD,
+	[BPF_NLA_NAME]		= TCA_ACT_BPF_NAME,
+};
+
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... bpf ... [ index INDEX ]\n");
@@ -37,12 +40,14 @@ static void explain(void)
 	fprintf(stderr, "eBPF use case:\n");
 	fprintf(stderr, " object-file FILE [ section ACT_NAME ] [ export UDS_FILE ]");
 	fprintf(stderr, " [ verbose ]\n");
+	fprintf(stderr, " object-pinned FILE\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
 	fprintf(stderr, "c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string,\n");
-	fprintf(stderr, "an ELF file containing eBPF map definitions and bytecode.\n");
+	fprintf(stderr, "an ELF file containing eBPF map definitions and bytecode, or a\n");
+	fprintf(stderr, "pinned eBPF program.\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where ACT_NAME refers to the section name containing the\n");
 	fprintf(stderr, "action (default \'%s\').\n", bpf_default_section(bpf_type));
@@ -54,114 +59,40 @@ static void explain(void)
 	fprintf(stderr, "explicitly specifies an action index upon creation.\n");
 }
 
-static void usage(void)
+static int bpf_parse_opt(struct action_util *a, int *ptr_argc, char ***ptr_argv,
+			 int tca_id, struct nlmsghdr *n)
 {
-	explain();
-	exit(-1);
-}
-
-static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
-		     int tca_id, struct nlmsghdr *n)
-{
-	char **argv = *argv_p, bpf_name[256];
+	const char *bpf_obj = NULL, *bpf_uds_name = NULL;
+	struct tc_act_bpf parm;
+	bool seen_run = false;
 	struct rtattr *tail;
-	struct tc_act_bpf parm = { 0 };
-	struct sock_filter bpf_ops[BPF_MAXINSNS];
-	bool ebpf_fill = false, bpf_fill = false;
-	bool ebpf = false, seen_run = false;
-	const char *bpf_uds_name = NULL;
-	const char *bpf_sec_name = NULL;
-	char *bpf_obj = NULL;
-	int argc = *argc_p, ret = 0;
-	__u16 bpf_len = 0;
-	__u32 bpf_fd = 0;
+	int argc, ret = 0;
+	char **argv;
+
+	argv = *ptr_argv;
+	argc = *ptr_argc;
 
 	if (matches(*argv, "bpf") != 0)
 		return -1;
 
 	NEXT_ARG();
 
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+
 	while (argc > 0) {
 		if (matches(*argv, "run") == 0) {
-			bool from_file, bpf_verbose;
-			int ret;
-
 			NEXT_ARG();
 opt_bpf:
-			bpf_sec_name = bpf_default_section(bpf_type);
-			bpf_verbose = false;
 			seen_run = true;
-
-			if (strcmp(*argv, "bytecode-file") == 0 ||
-			    strcmp(*argv, "bcf") == 0) {
-				from_file = true;
-			} else if (strcmp(*argv, "bytecode") == 0 ||
-				   strcmp(*argv, "bc") == 0) {
-				from_file = false;
-			} else if (strcmp(*argv, "object-file") == 0 ||
-				   strcmp(*argv, "obj") == 0) {
-				ebpf = true;
-			} else {
-				fprintf(stderr, "unexpected \"%s\"\n", *argv);
-				explain();
+			if (bpf_parse_common(&argc, &argv, nla_tbl, bpf_type,
+					     &bpf_obj, &bpf_uds_name, n)) {
+				fprintf(stderr, "Failed to retrieve (e)BPF data!\n");
 				return -1;
 			}
-
-			NEXT_ARG();
-			if (ebpf) {
-				bpf_uds_name = getenv(BPF_ENV_UDS);
-				bpf_obj = *argv;
-
-				NEXT_ARG_FWD();
-
-				if (argc > 0 &&
-				    (strcmp(*argv, "section") == 0 ||
-				     strcmp(*argv, "sec") == 0)) {
-					NEXT_ARG();
-					bpf_sec_name = *argv;
-					NEXT_ARG_FWD();
-				}
-				if (argc > 0 && !bpf_uds_name &&
-				    (strcmp(*argv, "export") == 0 ||
-				     strcmp(*argv, "exp") == 0)) {
-					NEXT_ARG();
-					bpf_uds_name = *argv;
-					NEXT_ARG_FWD();
-				}
-				if (argc > 0 &&
-				    (strcmp(*argv, "verbose") == 0 ||
-				     strcmp(*argv, "verb") == 0)) {
-					bpf_verbose = true;
-					NEXT_ARG_FWD();
-				}
-
-				PREV_ARG();
-			}
-
-			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name,
-						     bpf_verbose) :
-				     bpf_parse_ops(argc, argv, bpf_ops, from_file);
-			if (ret < 0) {
-				fprintf(stderr, "%s\n", ebpf ?
-					"Could not load object" :
-					"Illegal \"bytecode\"");
-				return -1;
-			}
-
-			if (ebpf) {
-				bpf_obj = basename(bpf_obj);
-
-				snprintf(bpf_name, sizeof(bpf_name), "%s:[%s]",
-					 bpf_obj, bpf_sec_name);
-
-				bpf_fd = ret;
-				ebpf_fill = true;
-			} else {
-				bpf_len = ret;
-				bpf_fill = true;
-			}
 		} else if (matches(*argv, "help") == 0) {
-			usage();
+			explain();
+			return -1;
 		} else if (matches(*argv, "index") == 0) {
 			break;
 		} else {
@@ -173,7 +104,9 @@ opt_bpf:
 		NEXT_ARG_FWD();
 	}
 
+	memset(&parm, 0, sizeof(parm));
 	parm.action = TC_ACT_PIPE;
+
 	if (argc) {
 		if (matches(*argv, "reclassify") == 0) {
 			parm.action = TC_ACT_RECLASSIFY;
@@ -207,32 +140,19 @@ opt_bpf:
 		}
 	}
 
-	tail = NLMSG_TAIL(n);
-
-	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
 	addattr_l(n, MAX_MSG, TCA_ACT_BPF_PARMS, &parm, sizeof(parm));
-
-	if (ebpf_fill) {
-		addattr32(n, MAX_MSG, TCA_ACT_BPF_FD, bpf_fd);
-		addattrstrz(n, MAX_MSG, TCA_ACT_BPF_NAME, bpf_name);
-	} else if (bpf_fill) {
-		addattr16(n, MAX_MSG, TCA_ACT_BPF_OPS_LEN, bpf_len);
-		addattr_l(n, MAX_MSG, TCA_ACT_BPF_OPS, &bpf_ops,
-			  bpf_len * sizeof(struct sock_filter));
-	}
-
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
-	*argc_p = argc;
-	*argv_p = argv;
-
 	if (bpf_uds_name)
 		ret = bpf_send_map_fds(bpf_uds_name, bpf_obj);
 
+	*ptr_argc = argc;
+	*ptr_argv = argv;
+
 	return ret;
 }
 
-static int print_bpf(struct action_util *au, FILE *f, struct rtattr *arg)
+static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 {
 	struct rtattr *tb[TCA_ACT_BPF_MAX + 1];
 	struct tc_act_bpf *parm;
@@ -249,7 +169,6 @@ static int print_bpf(struct action_util *au, FILE *f, struct rtattr *arg)
 	}
 
 	parm = RTA_DATA(tb[TCA_ACT_BPF_PARMS]);
-
 	fprintf(f, "bpf ");
 
 	if (tb[TCA_ACT_BPF_NAME])
@@ -276,12 +195,11 @@ static int print_bpf(struct action_util *au, FILE *f, struct rtattr *arg)
 	}
 
 	fprintf(f, "\n ");
-
 	return 0;
 }
 
 struct action_util bpf_action_util = {
-	.id = "bpf",
-	.parse_aopt = parse_bpf,
-	.print_aopt = print_bpf,
+	.id		= "bpf",
+	.parse_aopt	= bpf_parse_opt,
+	.print_aopt	= bpf_print_opt,
 };
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 276871a..bc7bc9f 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -20,18 +20,25 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <stdarg.h>
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <sys/un.h>
-#include <linux/filter.h>
-#include <linux/netlink.h>
-#include <linux/rtnetlink.h>
 
 #ifdef HAVE_ELF
 #include <libelf.h>
 #include <gelf.h>
 #endif
 
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/un.h>
+#include <sys/vfs.h>
+#include <sys/mount.h>
+#include <sys/syscall.h>
+#include <sys/sendfile.h>
+#include <sys/resource.h>
+
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <linux/if_alg.h>
+
 #include "utils.h"
 
 #include "bpf_elf.h"
@@ -40,9 +47,47 @@
 #include "tc_util.h"
 #include "tc_bpf.h"
 
-int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
-		     char **bpf_string, bool *need_release,
-		     const char separator)
+#ifdef HAVE_ELF
+static int bpf_obj_open(const char *path, enum bpf_prog_type type,
+			const char *sec, bool verbose);
+#else
+static int bpf_obj_open(const char *path, enum bpf_prog_type type,
+			const char *sec, bool verbose)
+{
+	fprintf(stderr, "No ELF library support compiled in.\n");
+	errno = ENOSYS;
+	return -1;
+}
+#endif
+
+static inline __u64 bpf_ptr_to_u64(const void *ptr)
+{
+	return (__u64)(unsigned long)ptr;
+}
+
+static int bpf(int cmd, union bpf_attr *attr, unsigned int size)
+{
+#ifdef __NR_bpf
+	return syscall(__NR_bpf, cmd, attr, size);
+#else
+	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
+	errno = ENOSYS;
+	return -1;
+#endif
+}
+
+static int bpf_obj_get(const char *pathname)
+{
+	union bpf_attr attr = {
+		.pathname	= bpf_ptr_to_u64(pathname),
+	};
+
+	return bpf(BPF_OBJ_GET, &attr, sizeof(attr));
+}
+
+static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
+			    char **bpf_string, bool *need_release,
+			    const char separator)
 {
 	char sp;
 
@@ -90,8 +135,8 @@ int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 	return 0;
 }
 
-int bpf_parse_ops(int argc, char **argv, struct sock_filter *bpf_ops,
-		  bool from_file)
+static int bpf_ops_parse(int argc, char **argv, struct sock_filter *bpf_ops,
+			 bool from_file)
 {
 	char *bpf_string, *token, separator = ',';
 	int ret = 0, i = 0;
@@ -135,7 +180,6 @@ int bpf_parse_ops(int argc, char **argv, struct sock_filter *bpf_ops,
 		goto out;
 	}
 	ret = bpf_len;
-
 out:
 	if (need_release)
 		free(bpf_string);
@@ -161,6 +205,97 @@ void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
 		ops[i].jf, ops[i].k);
 }
 
+static int bpf_valid_mntpt(const char *mnt, unsigned long magic)
+{
+	struct statfs st_fs;
+
+	if (statfs(mnt, &st_fs) < 0)
+		return -ENOENT;
+	if ((unsigned long)st_fs.f_type != magic)
+		return -ENOENT;
+
+	return 0;
+}
+
+static const char *bpf_find_mntpt(const char *fstype, unsigned long magic,
+				  char *mnt, int len,
+				  const char * const *known_mnts)
+{
+	const char * const *ptr;
+	char type[100];
+	FILE *fp;
+
+	if (known_mnts) {
+		ptr = known_mnts;
+		while (*ptr) {
+			if (bpf_valid_mntpt(*ptr, magic) == 0) {
+				strncpy(mnt, *ptr, len - 1);
+				mnt[len - 1] = 0;
+				return mnt;
+			}
+			ptr++;
+		}
+	}
+
+	fp = fopen("/proc/mounts", "r");
+	if (fp == NULL || len != PATH_MAX)
+		return NULL;
+
+	while (fscanf(fp, "%*s %" textify(PATH_MAX) "s %99s %*s %*d %*d\n",
+		      mnt, type) == 2) {
+		if (strcmp(type, fstype) == 0)
+			break;
+	}
+
+	fclose(fp);
+	if (strcmp(type, fstype) != 0)
+		return NULL;
+
+	return mnt;
+}
+
+int bpf_trace_pipe(void)
+{
+	char tracefs_mnt[PATH_MAX] = TRACE_DIR_MNT;
+	static const char * const tracefs_known_mnts[] = {
+		TRACE_DIR_MNT,
+		"/sys/kernel/debug/tracing",
+		"/tracing",
+		"/trace",
+		0,
+	};
+	char tpipe[PATH_MAX];
+	const char *mnt;
+	int fd;
+
+	mnt = bpf_find_mntpt("tracefs", TRACEFS_MAGIC, tracefs_mnt,
+			     sizeof(tracefs_mnt), tracefs_known_mnts);
+	if (!mnt) {
+		fprintf(stderr, "tracefs not mounted?\n");
+		return -1;
+	}
+
+	snprintf(tpipe, sizeof(tpipe), "%s/trace_pipe", mnt);
+
+	fd = open(tpipe, O_RDONLY);
+	if (fd < 0)
+		return -1;
+
+	fprintf(stderr, "Running! Hang up with ^C!\n\n");
+	while (1) {
+		static char buff[4096];
+		ssize_t ret;
+
+		ret = read(fd, buff, sizeof(buff) - 1);
+		if (ret > 0) {
+			write(2, buff, ret);
+			fflush(stderr);
+		}
+	}
+
+	return 0;
+}
+
 const char *bpf_default_section(const enum bpf_prog_type type)
 {
 	switch (type) {
@@ -173,18 +308,139 @@ const char *bpf_default_section(const enum bpf_prog_type type)
 	}
 }
 
+int bpf_parse_common(int *ptr_argc, char ***ptr_argv, const int *nla_tbl,
+		     enum bpf_prog_type type, const char **ptr_object,
+		     const char **ptr_uds_name, struct nlmsghdr *n)
+{
+	struct sock_filter opcodes[BPF_MAXINSNS];
+	const char *file, *section, *uds_name;
+	char **argv = *ptr_argv;
+	int argc = *ptr_argc;
+	char annotation[256];
+	bool verbose = false;
+	int ret;
+	enum bpf_mode {
+		CBPF_BYTECODE,
+		CBPF_FILE,
+		EBPF_OBJECT,
+		EBPF_PINNED,
+	} mode;
+
+	if (matches(*argv, "bytecode") == 0 ||
+	    strcmp(*argv, "bc") == 0) {
+		mode = CBPF_BYTECODE;
+	} else if (matches(*argv, "bytecode-file") == 0 ||
+		   strcmp(*argv, "bcf") == 0) {
+		mode = CBPF_FILE;
+	} else if (matches(*argv, "object-file") == 0 ||
+		   strcmp(*argv, "obj") == 0) {
+		mode = EBPF_OBJECT;
+	} else if (matches(*argv, "object-pinned") == 0 ||
+		   matches(*argv, "pinned") == 0 ||
+		   matches(*argv, "fd") == 0) {
+		mode = EBPF_PINNED;
+	} else {
+		fprintf(stderr, "What mode is \"%s\"?\n", *argv);
+		return -1;
+	}
+
+	NEXT_ARG();
+	file = section = uds_name = NULL;
+	if (mode == EBPF_OBJECT || mode == EBPF_PINNED) {
+		file = *argv;
+		NEXT_ARG_FWD();
+
+		section = bpf_default_section(type);
+		if (argc > 0 && matches(*argv, "section") == 0) {
+			NEXT_ARG();
+			section = *argv;
+			NEXT_ARG_FWD();
+		}
+
+		uds_name = getenv(BPF_ENV_UDS);
+		if (argc > 0 && !uds_name &&
+		    matches(*argv, "export") == 0) {
+			NEXT_ARG();
+			uds_name = *argv;
+			NEXT_ARG_FWD();
+		}
+
+		if (argc > 0 && matches(*argv, "verbose") == 0) {
+			verbose = true;
+			NEXT_ARG_FWD();
+		}
+
+		PREV_ARG();
+	}
+
+	if (mode == CBPF_BYTECODE || mode == CBPF_FILE)
+		ret = bpf_ops_parse(argc, argv, opcodes, mode == CBPF_FILE);
+	else if (mode == EBPF_OBJECT)
+		ret = bpf_obj_open(file, type, section, verbose);
+	else if (mode == EBPF_PINNED)
+		ret = bpf_obj_get(file);
+	if (ret < 0)
+		return -1;
+
+	if (mode == CBPF_BYTECODE || mode == CBPF_FILE) {
+		addattr16(n, MAX_MSG, nla_tbl[BPF_NLA_OPS_LEN], ret);
+		addattr_l(n, MAX_MSG, nla_tbl[BPF_NLA_OPS], opcodes,
+			  ret * sizeof(struct sock_filter));
+	} else if (mode == EBPF_OBJECT || mode == EBPF_PINNED) {
+		snprintf(annotation, sizeof(annotation), "%s:[%s]",
+			 basename(file), mode == EBPF_PINNED ? "*fsobj" :
+			 section);
+
+		addattr32(n, MAX_MSG, nla_tbl[BPF_NLA_FD], ret);
+		addattrstrz(n, MAX_MSG, nla_tbl[BPF_NLA_NAME], annotation);
+	}
+
+	*ptr_object = file;
+	*ptr_uds_name = uds_name;
+
+	*ptr_argc = argc;
+	*ptr_argv = argv;
+
+	return 0;
+}
+
 #ifdef HAVE_ELF
+struct bpf_elf_prog {
+	enum bpf_prog_type	type;
+	const struct bpf_insn	*insns;
+	size_t			size;
+	const char		*license;
+};
+
+struct bpf_elf_ctx {
+	Elf			*elf_fd;
+	GElf_Ehdr		elf_hdr;
+	Elf_Data		*sym_tab;
+	Elf_Data		*str_tab;
+	int			obj_fd;
+	int			map_fds[ELF_MAX_MAPS];
+	struct bpf_elf_map	maps[ELF_MAX_MAPS];
+	int			sym_num;
+	int			map_num;
+	bool			*sec_done;
+	int			sec_maps;
+	char			license[ELF_MAX_LICENSE_LEN];
+	enum bpf_prog_type	type;
+	bool			verbose;
+	struct bpf_elf_st	stat;
+};
+
 struct bpf_elf_sec_data {
-	GElf_Shdr sec_hdr;
-	char *sec_name;
-	Elf_Data *sec_data;
+	GElf_Shdr		sec_hdr;
+	Elf_Data		*sec_data;
+	const char		*sec_name;
 };
 
 struct bpf_map_data {
-	int *fds;
-	const char *obj;
-	struct bpf_elf_st *st;
-	struct bpf_elf_map *ent;
+	int			*fds;
+	const char		*obj;
+	struct bpf_elf_st	*st;
+	struct bpf_elf_map	*ent;
 };
 
 /* If we provide a small buffer with log level enabled, the kernel
@@ -193,15 +449,8 @@ struct bpf_map_data {
  * verifier we still want to hand something descriptive to the user.
  */
 static char bpf_log_buf[65536];
-static bool bpf_verbose;
-
-static struct bpf_elf_st bpf_st;
 
-static int map_fds[ELF_MAX_MAPS];
-static struct bpf_elf_map map_ent[ELF_MAX_MAPS];
-
-static void bpf_dump_error(const char *format, ...)  __check_format_string(1, 2);
-static void bpf_dump_error(const char *format, ...)
+static __check_format_string(1, 2) void bpf_dump_error(const char *format, ...)
 {
 	va_list vl;
 
@@ -215,46 +464,7 @@ static void bpf_dump_error(const char *format, ...)
 	}
 }
 
-static void bpf_save_finfo(int file_fd)
-{
-	struct stat st;
-	int ret;
-
-	memset(&bpf_st, 0, sizeof(bpf_st));
-
-	ret = fstat(file_fd, &st);
-	if (ret < 0) {
-		fprintf(stderr, "Stat of elf file failed: %s\n",
-			strerror(errno));
-		return;
-	}
-
-	bpf_st.st_dev = st.st_dev;
-	bpf_st.st_ino = st.st_ino;
-}
-
-static void bpf_clear_finfo(void)
-{
-	memset(&bpf_st, 0, sizeof(bpf_st));
-}
-
-static bool bpf_may_skip_map_creation(int file_fd)
-{
-	struct stat st;
-	int ret;
-
-	ret = fstat(file_fd, &st);
-	if (ret < 0) {
-		fprintf(stderr, "Stat of elf file failed: %s\n",
-			strerror(errno));
-		return false;
-	}
-
-	return (bpf_st.st_dev == st.st_dev) &&
-	       (bpf_st.st_ino == st.st_ino);
-}
-
-static int bpf_create_map(enum bpf_map_type type, unsigned int size_key,
+static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
 			  unsigned int size_value, unsigned int max_elem)
 {
 	union bpf_attr attr = {
@@ -267,7 +477,7 @@ static int bpf_create_map(enum bpf_map_type type, unsigned int size_key,
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-static int bpf_update_map(int fd, const void *key, const void *value,
+static int bpf_map_update(int fd, const void *key, const void *value,
 			  uint64_t flags)
 {
 	union bpf_attr attr = {
@@ -281,121 +491,429 @@ static int bpf_update_map(int fd, const void *key, const void *value,
 }
 
 static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
-			 unsigned int len, const char *license)
+			 size_t size, const char *license)
 {
 	union bpf_attr attr = {
 		.prog_type	= type,
 		.insns		= bpf_ptr_to_u64(insns),
-		.insn_cnt	= len / sizeof(struct bpf_insn),
+		.insn_cnt	= size / sizeof(struct bpf_insn),
 		.license	= bpf_ptr_to_u64(license),
 		.log_buf	= bpf_ptr_to_u64(bpf_log_buf),
 		.log_size	= sizeof(bpf_log_buf),
 		.log_level	= 1,
 	};
 
+	if (getenv(BPF_ENV_NOLOG)) {
+		attr.log_buf	= 0;
+		attr.log_size	= 0;
+		attr.log_level	= 0;
+	}
+
 	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
-static int bpf_prog_attach(enum bpf_prog_type type, const char *sec,
-			   const struct bpf_insn *insns, unsigned int size,
-			   const char *license)
+static int bpf_obj_pin(int fd, const char *pathname)
 {
-	int prog_fd = bpf_prog_load(type, insns, size, license);
+	union bpf_attr attr = {
+		.pathname	= bpf_ptr_to_u64(pathname),
+		.bpf_fd		= fd,
+	};
+
+	return bpf(BPF_OBJ_PIN, &attr, sizeof(attr));
+}
 
-	if (prog_fd < 0 || bpf_verbose) {
-		bpf_dump_error("%s (section \'%s\'): %s\n", prog_fd < 0 ?
-			       "BPF program rejected" :
-			       "BPF program verification",
-			       sec, strerror(errno));
+static int bpf_obj_hash(const char *object, uint8_t *out, size_t len)
+{
+	struct sockaddr_alg alg = {
+		.salg_family	= AF_ALG,
+		.salg_type	= "hash",
+		.salg_name	= "sha1",
+	};
+	int ret, cfd, ofd, ffd;
+	struct stat stbuff;
+	ssize_t size;
+
+	if (!object || len != 20)
+		return -EINVAL;
+
+	cfd = socket(AF_ALG, SOCK_SEQPACKET, 0);
+	if (cfd < 0) {
+		fprintf(stderr, "Cannot get AF_ALG socket: %s\n",
+			strerror(errno));
+		return cfd;
+	}
+
+	ret = bind(cfd, (struct sockaddr *)&alg, sizeof(alg));
+	if (ret < 0) {
+		fprintf(stderr, "Error binding socket: %s\n", strerror(errno));
+		goto out_cfd;
+	}
+
+	ofd = accept(cfd, NULL, 0);
+	if (ofd < 0) {
+		fprintf(stderr, "Error accepting socket: %s\n",
+			strerror(errno));
+		ret = ofd;
+		goto out_cfd;
+	}
+
+	ffd = open(object, O_RDONLY);
+	if (ffd < 0) {
+		fprintf(stderr, "Error opening object %s: %s\n",
+			object, strerror(errno));
+		ret = ffd;
+		goto out_ofd;
+	}
+
+        ret = fstat(ffd, &stbuff);
+	if (ret < 0) {
+		fprintf(stderr, "Error doing fstat: %s\n",
+			strerror(errno));
+		goto out_ffd;
 	}
 
-	return prog_fd;
+	size = sendfile(ofd, ffd, NULL, stbuff.st_size);
+	if (size != stbuff.st_size) {
+		fprintf(stderr, "Error from sendfile (%zd vs %zu bytes): %s\n",
+			size, stbuff.st_size, strerror(errno));
+		ret = -1;
+		goto out_ffd;
+	}
+
+	size = read(ofd, out, len);
+	if (size != len) {
+		fprintf(stderr, "Error from read (%zd vs %zu bytes): %s\n",
+			size, len, strerror(errno));
+		ret = -1;
+	} else {
+		ret = 0;
+	}
+out_ffd:
+	close(ffd);
+out_ofd:
+	close(ofd);
+out_cfd:
+	close(cfd);
+	return ret;
 }
 
-static int bpf_map_attach(enum bpf_map_type type, unsigned int size_key,
-			  unsigned int size_value, unsigned int max_elem)
+static const char *bpf_get_obj_uid(const char *pathname)
 {
-	int map_fd = bpf_create_map(type, size_key, size_value, max_elem);
+	static bool bpf_uid_cached = false;
+	static char bpf_uid[64];
+	uint8_t tmp[20];
+	int ret;
 
-	if (map_fd < 0)
-		bpf_dump_error("BPF map rejected: %s\n", strerror(errno));
+	if (bpf_uid_cached)
+		goto done;
 
-	return map_fd;
+	ret = bpf_obj_hash(pathname, tmp, sizeof(tmp));
+	if (ret) {
+		fprintf(stderr, "Object hashing failed!\n");
+		return NULL;
+	}
+
+	hexstring_n2a(tmp, sizeof(tmp), bpf_uid, sizeof(bpf_uid));
+	bpf_uid_cached = true;
+done:
+	return bpf_uid;
 }
 
-static void bpf_maps_init(void)
+static int bpf_mnt_fs(const char *target)
 {
-	int i;
+	bool bind_done = false;
+
+	while (mount("", target, "none", MS_PRIVATE | MS_REC, NULL)) {
+		if (errno != EINVAL || bind_done) {
+			fprintf(stderr, "mount --make-private %s failed: %s\n",
+				target,	strerror(errno));
+			return -1;
+		}
 
-	memset(map_ent, 0, sizeof(map_ent));
-	for (i = 0; i < ARRAY_SIZE(map_fds); i++)
-		map_fds[i] = -1;
+		if (mount(target, target, "none", MS_BIND, NULL)) {
+			fprintf(stderr, "mount --bind %s %s failed: %s\n",
+				target,	target, strerror(errno));
+			return -1;
+		}
+
+		bind_done = true;
+	}
+
+	if (mount("bpf", target, "bpf", 0, NULL)) {
+		fprintf(stderr, "mount -t bpf bpf %s failed: %s\n",
+			target,	strerror(errno));
+		return -1;
+	}
+
+	return 0;
 }
 
-static int bpf_maps_count(void)
+static const char *bpf_get_tc_dir(void)
 {
-	int i, count = 0;
+	static bool bpf_mnt_cached = false;
+	static char bpf_tc_dir[PATH_MAX];
+	static const char *mnt;
+	static const char * const bpf_known_mnts[] = {
+		BPF_DIR_MNT,
+		0,
+	};
+	char bpf_mnt[PATH_MAX] = BPF_DIR_MNT;
+	char bpf_glo_dir[PATH_MAX];
+	int ret;
 
-	for (i = 0; i < ARRAY_SIZE(map_fds); i++) {
-		if (map_fds[i] < 0)
-			break;
-		count++;
+	if (bpf_mnt_cached)
+		goto done;
+
+	mnt = bpf_find_mntpt("bpf", BPF_FS_MAGIC, bpf_mnt, sizeof(bpf_mnt),
+			     bpf_known_mnts);
+	if (!mnt) {
+		mnt = getenv(BPF_ENV_MNT);
+		if (!mnt)
+			mnt = BPF_DIR_MNT;
+		ret = bpf_mnt_fs(mnt);
+		if (ret) {
+			mnt = NULL;
+			goto out;
+		}
 	}
 
-	return count;
+	snprintf(bpf_tc_dir, sizeof(bpf_tc_dir), "%s/%s", mnt, BPF_DIR_TC);
+	ret = mkdir(bpf_tc_dir, S_IRWXU);
+	if (ret && errno != EEXIST) {
+		fprintf(stderr, "mkdir %s failed: %s\n", bpf_tc_dir,
+			strerror(errno));
+		mnt = NULL;
+		goto out;
+	}
+
+	snprintf(bpf_glo_dir, sizeof(bpf_glo_dir), "%s/%s",
+		 bpf_tc_dir, BPF_DIR_GLOBALS);
+	ret = mkdir(bpf_glo_dir, S_IRWXU);
+	if (ret && errno != EEXIST) {
+		fprintf(stderr, "mkdir %s failed: %s\n", bpf_glo_dir,
+			strerror(errno));
+		mnt = NULL;
+		goto out;
+	}
+
+	mnt = bpf_tc_dir;
+out:
+	bpf_mnt_cached = true;
+done:
+	return mnt;
+}
+
+static int bpf_init_env(const char *pathname)
+{
+	struct rlimit limit = {
+		.rlim_cur = RLIM_INFINITY,
+		.rlim_max = RLIM_INFINITY,
+	};
+
+	/* Don't bother in case we fail! */
+	setrlimit(RLIMIT_MEMLOCK, &limit);
+
+	if (!bpf_get_tc_dir()) {
+		fprintf(stderr, "Continuing without mounted eBPF fs. "
+			"Too old kernel?\n");
+		return 0;
+	}
+
+	if (!bpf_get_obj_uid(pathname))
+		return -1;
+
+	return 0;
 }
 
-static void bpf_maps_destroy(void)
+static bool bpf_no_pinning(int pinning)
 {
+	switch (pinning) {
+	case PIN_OBJECT_NS:
+	case PIN_GLOBAL_NS:
+		return false;
+	case PIN_NONE:
+	default:
+		return true;
+	}
+}
+
+static void bpf_make_pathname(char *pathname, size_t len, const char *name,
+			      int pinning)
+{
+	switch (pinning) {
+	case PIN_OBJECT_NS:
+		snprintf(pathname, len, "%s/%s/%s", bpf_get_tc_dir(),
+			 bpf_get_obj_uid(NULL), name);
+		break;
+	case PIN_GLOBAL_NS:
+		snprintf(pathname, len, "%s/%s/%s", bpf_get_tc_dir(),
+			 BPF_DIR_GLOBALS, name);
+		break;
+	}
+}
+
+static int bpf_probe_pinned(const char *name, int pinning)
+{
+	char pathname[PATH_MAX];
+
+	if (bpf_no_pinning(pinning) || !bpf_get_tc_dir())
+		return 0;
+
+	bpf_make_pathname(pathname, sizeof(pathname), name, pinning);
+	return bpf_obj_get(pathname);
+}
+
+static int bpf_place_pinned(int fd, const char *name, int pinning)
+{
+	char pathname[PATH_MAX];
+	int ret;
+
+	if (bpf_no_pinning(pinning) || !bpf_get_tc_dir())
+		return 0;
+
+	if (pinning == PIN_OBJECT_NS) {
+		snprintf(pathname, sizeof(pathname), "%s/%s",
+			 bpf_get_tc_dir(), bpf_get_obj_uid(NULL));
+
+		ret = mkdir(pathname, S_IRWXU);
+		if (ret && errno != EEXIST) {
+			fprintf(stderr, "mkdir %s failed: %s\n", pathname,
+				strerror(errno));
+			return ret;
+		}
+	}
+
+	bpf_make_pathname(pathname, sizeof(pathname), name, pinning);
+	return bpf_obj_pin(fd, pathname);
+}
+
+static int bpf_prog_attach(const char *section,
+			   const struct bpf_elf_prog *prog, bool verbose)
+{
+	int fd;
+
+	/* We can add pinning here later as well, same as bpf_map_attach(). */
+	errno = 0;
+	fd = bpf_prog_load(prog->type, prog->insns, prog->size,
+			   prog->license);
+	if (fd < 0 || verbose) {
+		bpf_dump_error("Prog section \'%s\' (type:%u insns:%zu "
+			       "license:\'%s\') %s%s (%d)!\n\n",
+			       section, prog->type,
+			       prog->size / sizeof(struct bpf_insn),
+			       prog->license, fd < 0 ? "rejected :" :
+			       "loaded", fd < 0 ? strerror(errno) : "",
+			       fd < 0 ? errno : fd);
+	}
+
+	return fd;
+}
+
+static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
+			  bool verbose)
+{
+	int fd, ret;
+
+	fd = bpf_probe_pinned(name, map->pinning);
+	if (fd > 0) {
+		if (verbose)
+			fprintf(stderr, "Map \'%s\' loaded as pinned!\n",
+				name);
+		return fd;
+	}
+
+	errno = 0;
+	fd = bpf_map_create(map->type, map->size_key, map->size_value,
+			    map->max_elem);
+	if (fd < 0 || verbose) {
+		bpf_dump_error("Map \'%s\' (type:%u id:%u pinning:%u "
+			       "ksize:%u vsize:%u max-elems:%u) %s%s (%d)!\n",
+			       name, map->type, map->id, map->pinning,
+			       map->size_key, map->size_value, map->max_elem,
+			       fd < 0 ? "rejected: " : "loaded", fd < 0 ?
+			       strerror(errno) : "", fd < 0 ? errno : fd);
+		if (fd < 0)
+			return fd;
+	}
+
+	ret = bpf_place_pinned(fd, name, map->pinning);
+	if (ret < 0 && errno != EEXIST) {
+		fprintf(stderr, "Could not pin %s map: %s\n", name,
+			strerror(errno));
+		close(fd);
+		return ret;
+	}
+
+	return fd;
+}
+
+#define __ELF_ST_BIND(x)	((x) >> 4)
+#define __ELF_ST_TYPE(x)	(((unsigned int) x) & 0xf)
+
+static const char *bpf_str_tab_name(const struct bpf_elf_ctx *ctx,
+				    const GElf_Sym *sym)
+{
+	return ctx->str_tab->d_buf + sym->st_name;
+}
+
+static const char *bpf_map_fetch_name(struct bpf_elf_ctx *ctx, int which)
+{
+	GElf_Sym sym;
 	int i;
 
-	memset(map_ent, 0, sizeof(map_ent));
-	for (i = 0; i < ARRAY_SIZE(map_fds); i++) {
-		if (map_fds[i] >= 0)
-			close(map_fds[i]);
+	for (i = 0; i < ctx->sym_num; i++) {
+		if (gelf_getsym(ctx->sym_tab, i, &sym) != &sym)
+			continue;
+
+		if (__ELF_ST_BIND(sym.st_info) != STB_GLOBAL ||
+		    __ELF_ST_TYPE(sym.st_info) != STT_NOTYPE ||
+		    sym.st_shndx != ctx->sec_maps ||
+		    sym.st_value / sizeof(struct bpf_elf_map) != which)
+			continue;
+
+		return bpf_str_tab_name(ctx, &sym);
 	}
+
+	return NULL;
 }
 
-static int bpf_maps_attach(struct bpf_elf_map *maps, unsigned int num_maps)
+static int bpf_maps_attach_all(struct bpf_elf_ctx *ctx)
 {
-	int i, ret;
+	const char *map_name;
+	int i, fd;
 
-	for (i = 0; (i < num_maps) && (num_maps <= ARRAY_SIZE(map_fds)); i++) {
-		struct bpf_elf_map *map = &maps[i];
+	for (i = 0; i < ctx->map_num; i++) {
+		map_name = bpf_map_fetch_name(ctx, i);
+		if (!map_name)
+			return -EIO;
 
-		ret = bpf_map_attach(map->type, map->size_key,
-				     map->size_value, map->max_elem);
-		if (ret < 0)
-			goto err_unwind;
+		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx->verbose);
+		if (fd < 0)
+			return fd;
 
-		map_fds[i] = ret;
+		ctx->map_fds[i] = fd;
 	}
 
 	return 0;
-
-err_unwind:
-	bpf_maps_destroy();
-	return ret;
 }
 
-static int bpf_fill_section_data(Elf *elf_fd, GElf_Ehdr *elf_hdr, int sec_index,
-				 struct bpf_elf_sec_data *sec_data)
+static int bpf_fill_section_data(struct bpf_elf_ctx *ctx, int section,
+				 struct bpf_elf_sec_data *data)
 {
+	Elf_Data *sec_edata;
 	GElf_Shdr sec_hdr;
 	Elf_Scn *sec_fd;
-	Elf_Data *sec_edata;
 	char *sec_name;
 
-	memset(sec_data, 0, sizeof(*sec_data));
+	memset(data, 0, sizeof(*data));
 
-	sec_fd = elf_getscn(elf_fd, sec_index);
+	sec_fd = elf_getscn(ctx->elf_fd, section);
 	if (!sec_fd)
 		return -EINVAL;
-
 	if (gelf_getshdr(sec_fd, &sec_hdr) != &sec_hdr)
 		return -EIO;
 
-	sec_name = elf_strptr(elf_fd, elf_hdr->e_shstrndx,
+	sec_name = elf_strptr(ctx->elf_fd, ctx->elf_hdr.e_shstrndx,
 			      sec_hdr.sh_name);
 	if (!sec_name || !sec_hdr.sh_size)
 		return -ENOENT;
@@ -404,317 +922,395 @@ static int bpf_fill_section_data(Elf *elf_fd, GElf_Ehdr *elf_hdr, int sec_index,
 	if (!sec_edata || elf_getdata(sec_fd, sec_edata))
 		return -EIO;
 
-	memcpy(&sec_data->sec_hdr, &sec_hdr, sizeof(sec_hdr));
-	sec_data->sec_name = sec_name;
-	sec_data->sec_data = sec_edata;
+	memcpy(&data->sec_hdr, &sec_hdr, sizeof(sec_hdr));
 
+	data->sec_name = sec_name;
+	data->sec_data = sec_edata;
 	return 0;
 }
 
-static int bpf_apply_relo_data(struct bpf_elf_sec_data *data_relo,
-			       struct bpf_elf_sec_data *data_insn,
-			       Elf_Data *sym_tab)
+static int bpf_fetch_maps(struct bpf_elf_ctx *ctx, int section,
+			  struct bpf_elf_sec_data *data)
 {
-	Elf_Data *idata = data_insn->sec_data;
-	GElf_Shdr *rhdr = &data_relo->sec_hdr;
-	int relo_ent, relo_num = rhdr->sh_size / rhdr->sh_entsize;
-	struct bpf_insn *insns = idata->d_buf;
-	unsigned int num_insns = idata->d_size / sizeof(*insns);
-
-	for (relo_ent = 0; relo_ent < relo_num; relo_ent++) {
-		unsigned int ioff, fnum;
-		GElf_Rel relo;
-		GElf_Sym sym;
+	if (data->sec_data->d_size % sizeof(struct bpf_elf_map) != 0)
+		return -EINVAL;
 
-		if (gelf_getrel(data_relo->sec_data, relo_ent, &relo) != &relo)
-			return -EIO;
+	ctx->map_num = data->sec_data->d_size / sizeof(struct bpf_elf_map);
+	ctx->sec_maps = section;
+	ctx->sec_done[section] = true;
 
-		ioff = relo.r_offset / sizeof(struct bpf_insn);
-		if (ioff >= num_insns)
-			return -EINVAL;
-		if (insns[ioff].code != (BPF_LD | BPF_IMM | BPF_DW))
-			return -EINVAL;
+	if (ctx->map_num > ARRAY_SIZE(ctx->map_fds)) {
+		fprintf(stderr, "Too many BPF maps in ELF section!\n");
+		return -ENOMEM;
+	}
 
-		if (gelf_getsym(sym_tab, GELF_R_SYM(relo.r_info), &sym) != &sym)
-			return -EIO;
+	memcpy(ctx->maps, data->sec_data->d_buf, data->sec_data->d_size);
+	return 0;
+}
 
-		fnum = sym.st_value / sizeof(struct bpf_elf_map);
-		if (fnum >= ARRAY_SIZE(map_fds))
-			return -EINVAL;
-		if (map_fds[fnum] < 0)
-			return -EINVAL;
+static int bpf_fetch_license(struct bpf_elf_ctx *ctx, int section,
+			     struct bpf_elf_sec_data *data)
+{
+	if (data->sec_data->d_size > sizeof(ctx->license))
+		return -ENOMEM;
 
-		insns[ioff].src_reg = BPF_PSEUDO_MAP_FD;
-		insns[ioff].imm = map_fds[fnum];
-	}
+	memcpy(ctx->license, data->sec_data->d_buf, data->sec_data->d_size);
+	ctx->sec_done[section] = true;
+	return 0;
+}
 
+static int bpf_fetch_symtab(struct bpf_elf_ctx *ctx, int section,
+			    struct bpf_elf_sec_data *data)
+{
+	ctx->sym_tab = data->sec_data;
+	ctx->sym_num = data->sec_hdr.sh_size / data->sec_hdr.sh_entsize;
+	ctx->sec_done[section] = true;
 	return 0;
 }
 
-static int bpf_fetch_ancillary(int file_fd, Elf *elf_fd, GElf_Ehdr *elf_hdr,
-			       bool *sec_done, char *license, unsigned int lic_len,
-			       Elf_Data **sym_tab)
+static int bpf_fetch_strtab(struct bpf_elf_ctx *ctx, int section,
+			    struct bpf_elf_sec_data *data)
 {
-	int sec_index, ret = -1;
+	ctx->str_tab = data->sec_data;
+	ctx->sec_done[section] = true;
+	return 0;
+}
 
-	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
-		struct bpf_elf_sec_data data_anc;
+static int bpf_fetch_ancillary(struct bpf_elf_ctx *ctx)
+{
+	struct bpf_elf_sec_data data;
+	int i, ret = -1;
 
-		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
-					    &data_anc);
+	for (i = 1; i < ctx->elf_hdr.e_shnum; i++) {
+		ret = bpf_fill_section_data(ctx, i, &data);
 		if (ret < 0)
 			continue;
 
-		/* Extract and load eBPF map fds. */
-		if (!strcmp(data_anc.sec_name, ELF_SECTION_MAPS) &&
-		    !bpf_may_skip_map_creation(file_fd)) {
-			struct bpf_elf_map *maps;
-			unsigned int maps_num;
-
-			if (data_anc.sec_data->d_size % sizeof(*maps) != 0)
-				return -EINVAL;
-
-			maps = data_anc.sec_data->d_buf;
-			maps_num = data_anc.sec_data->d_size / sizeof(*maps);
-			memcpy(map_ent, maps, data_anc.sec_data->d_size);
-
-			ret = bpf_maps_attach(maps, maps_num);
-			if (ret < 0)
-				return ret;
-
-			sec_done[sec_index] = true;
-		}
-		/* Extract eBPF license. */
-		else if (!strcmp(data_anc.sec_name, ELF_SECTION_LICENSE)) {
-			if (data_anc.sec_data->d_size > lic_len)
-				return -ENOMEM;
-
-			sec_done[sec_index] = true;
-			memcpy(license, data_anc.sec_data->d_buf,
-			       data_anc.sec_data->d_size);
+		if (!strcmp(data.sec_name, ELF_SECTION_MAPS))
+			ret = bpf_fetch_maps(ctx, i, &data);
+		else if (!strcmp(data.sec_name, ELF_SECTION_LICENSE))
+			ret = bpf_fetch_license(ctx, i, &data);
+		else if (data.sec_hdr.sh_type == SHT_SYMTAB)
+			ret = bpf_fetch_symtab(ctx, i, &data);
+		else if (data.sec_hdr.sh_type == SHT_STRTAB &&
+			 i != ctx->elf_hdr.e_shstrndx)
+			ret = bpf_fetch_strtab(ctx, i, &data);
+		if (ret < 0) {
+			fprintf(stderr, "Error parsing section %d! Perhaps"
+				"check with readelf -a?\n", i);
+			break;
 		}
-		/* Extract symbol table for relocations (map fd fixups). */
-		else if (data_anc.sec_hdr.sh_type == SHT_SYMTAB) {
-			sec_done[sec_index] = true;
-			*sym_tab = data_anc.sec_data;
+	}
+
+	if (ctx->sym_tab && ctx->str_tab && ctx->sec_maps) {
+		ret = bpf_maps_attach_all(ctx);
+		if (ret < 0) {
+			fprintf(stderr, "Error loading maps into kernel!\n");
+			return ret;
 		}
 	}
 
 	return ret;
 }
 
-static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
-			       enum bpf_prog_type type, const char *sec,
-			       const char *license, Elf_Data *sym_tab)
+static int bpf_fetch_prog(struct bpf_elf_ctx *ctx, const char *section)
 {
-	int sec_index, prog_fd = -1;
-
-	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
-		struct bpf_elf_sec_data data_relo, data_insn;
-		int ins_index, ret;
+	struct bpf_elf_sec_data data;
+	struct bpf_elf_prog prog;
+	int ret, i, fd = -1;
 
-		/* Attach eBPF programs with relocation data (maps). */
-		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
-					    &data_relo);
-		if (ret < 0 || data_relo.sec_hdr.sh_type != SHT_REL)
+	for (i = 1; i < ctx->elf_hdr.e_shnum; i++) {
+		if (ctx->sec_done[i])
 			continue;
 
-		ins_index = data_relo.sec_hdr.sh_info;
-
-		ret = bpf_fill_section_data(elf_fd, elf_hdr, ins_index,
-					    &data_insn);
-		if (ret < 0)
-			continue;
-		if (strcmp(data_insn.sec_name, sec))
+		ret = bpf_fill_section_data(ctx, i, &data);
+		if (ret < 0 || strcmp(data.sec_name, section))
 			continue;
 
-		ret = bpf_apply_relo_data(&data_relo, &data_insn, sym_tab);
-		if (ret < 0)
-			continue;
+		memset(&prog, 0, sizeof(prog));
+		prog.type    = ctx->type;
+		prog.insns   = data.sec_data->d_buf;
+		prog.size    = data.sec_data->d_size;
+		prog.license = ctx->license;
 
-		prog_fd = bpf_prog_attach(type, sec, data_insn.sec_data->d_buf,
-					  data_insn.sec_data->d_size, license);
-		if (prog_fd < 0)
+		fd = bpf_prog_attach(section, &prog, ctx->verbose);
+		if (fd < 0)
 			continue;
 
-		sec_done[sec_index] = true;
-		sec_done[ins_index] = true;
+		ctx->sec_done[i] = true;
 		break;
 	}
 
-	return prog_fd;
+	return fd;
 }
 
-static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
-			  enum bpf_prog_type type, const char *sec,
-			  const char *license)
+static int bpf_apply_relo_data(struct bpf_elf_ctx *ctx,
+			       struct bpf_elf_sec_data *data_relo,
+			       struct bpf_elf_sec_data *data_insn)
 {
-	int sec_index, prog_fd = -1;
+	Elf_Data *idata = data_insn->sec_data;
+	GElf_Shdr *rhdr = &data_relo->sec_hdr;
+	int relo_ent, relo_num = rhdr->sh_size / rhdr->sh_entsize;
+	struct bpf_insn *insns = idata->d_buf;
+	unsigned int num_insns = idata->d_size / sizeof(*insns);
 
-	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
-		struct bpf_elf_sec_data data_insn;
-		int ret;
+	for (relo_ent = 0; relo_ent < relo_num; relo_ent++) {
+		unsigned int ioff, rmap;
+		GElf_Rel relo;
+		GElf_Sym sym;
+
+		if (gelf_getrel(data_relo->sec_data, relo_ent, &relo) != &relo)
+			return -EIO;
+
+		ioff = relo.r_offset / sizeof(struct bpf_insn);
+		if (ioff >= num_insns ||
+		    insns[ioff].code != (BPF_LD | BPF_IMM | BPF_DW))
+			return -EINVAL;
+
+		if (gelf_getsym(ctx->sym_tab, GELF_R_SYM(relo.r_info), &sym) != &sym)
+			return -EIO;
+
+		rmap = sym.st_value / sizeof(struct bpf_elf_map);
+		if (rmap >= ARRAY_SIZE(ctx->map_fds))
+			return -EINVAL;
+		if (!ctx->map_fds[rmap])
+			return -EINVAL;
+
+		if (ctx->verbose)
+			fprintf(stderr, "Map \'%s\' (%d) injected into prog "
+				"section \'%s\' at offset %u!\n",
+				bpf_str_tab_name(ctx, &sym), ctx->map_fds[rmap],
+				data_insn->sec_name, ioff);
 
-		/* Attach eBPF programs without relocation data. */
-		if (sec_done[sec_index])
+		insns[ioff].src_reg = BPF_PSEUDO_MAP_FD;
+		insns[ioff].imm     = ctx->map_fds[rmap];
+	}
+
+	return 0;
+}
+
+static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section)
+{
+	struct bpf_elf_sec_data data_relo, data_insn;
+	struct bpf_elf_prog prog;
+	int ret, idx, i, fd = -1;
+
+	for (i = 1; i < ctx->elf_hdr.e_shnum; i++) {
+		ret = bpf_fill_section_data(ctx, i, &data_relo);
+		if (ret < 0 || data_relo.sec_hdr.sh_type != SHT_REL)
 			continue;
 
-		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
-					    &data_insn);
-		if (ret < 0)
+		idx = data_relo.sec_hdr.sh_info;
+		ret = bpf_fill_section_data(ctx, idx, &data_insn);
+		if (ret < 0 || strcmp(data_insn.sec_name, section))
 			continue;
-		if (strcmp(data_insn.sec_name, sec))
+
+		ret = bpf_apply_relo_data(ctx, &data_relo, &data_insn);
+		if (ret < 0)
 			continue;
 
-		prog_fd = bpf_prog_attach(type, sec, data_insn.sec_data->d_buf,
-					  data_insn.sec_data->d_size, license);
-		if (prog_fd < 0)
+		memset(&prog, 0, sizeof(prog));
+		prog.type    = ctx->type;
+		prog.insns   = data_insn.sec_data->d_buf;
+		prog.size    = data_insn.sec_data->d_size;
+		prog.license = ctx->license;
+
+		fd = bpf_prog_attach(section, &prog, ctx->verbose);
+		if (fd < 0)
 			continue;
 
-		sec_done[sec_index] = true;
+		ctx->sec_done[i]   = true;
+		ctx->sec_done[idx] = true;
 		break;
 	}
 
-	return prog_fd;
+	return fd;
 }
 
-static int bpf_fetch_prog_sec(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
-			      enum bpf_prog_type type, const char *sec,
-			      const char *license, Elf_Data *sym_tab)
+static int bpf_fetch_prog_sec(struct bpf_elf_ctx *ctx, const char *section)
 {
 	int ret = -1;
 
-	if (sym_tab)
-		ret = bpf_fetch_prog_relo(elf_fd, elf_hdr, sec_done, type,
-					  sec, license, sym_tab);
+	if (ctx->sym_tab)
+		ret = bpf_fetch_prog_relo(ctx, section);
 	if (ret < 0)
-		ret = bpf_fetch_prog(elf_fd, elf_hdr, sec_done, type, sec,
-				     license);
+		ret = bpf_fetch_prog(ctx, section);
+
 	return ret;
 }
 
-static int bpf_fill_prog_arrays(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
-				enum bpf_prog_type type, const char *license,
-				Elf_Data *sym_tab)
+static int bpf_fill_prog_arrays(struct bpf_elf_ctx *ctx)
 {
-	int sec_index;
+	struct bpf_elf_sec_data data;
+	uint32_t map_id, key_id;
+	int fd, i, ret;
 
-	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
-		struct bpf_elf_sec_data data_insn;
-		int ret, map_id, key_id, prog_fd;
-
-		if (sec_done[sec_index])
+	for (i = 1; i < ctx->elf_hdr.e_shnum; i++) {
+		if (ctx->sec_done[i])
 			continue;
 
-		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
-					    &data_insn);
+		ret = bpf_fill_section_data(ctx, i, &data);
 		if (ret < 0)
 			continue;
 
-		ret = sscanf(data_insn.sec_name, "%i/%i", &map_id, &key_id);
-		if (ret != 2)
+		ret = sscanf(data.sec_name, "%u/%u", &map_id, &key_id);
+		if (ret != 2 || map_id >= ARRAY_SIZE(ctx->map_fds) ||
+		    !ctx->map_fds[map_id])
+			continue;
+		if (ctx->maps[map_id].type != BPF_MAP_TYPE_PROG_ARRAY ||
+		    ctx->maps[map_id].max_elem <= key_id)
 			continue;
 
-		if (map_id >= ARRAY_SIZE(map_fds) || map_fds[map_id] < 0)
-			return -ENOENT;
-		if (map_ent[map_id].type != BPF_MAP_TYPE_PROG_ARRAY ||
-		    map_ent[map_id].max_elem <= key_id)
-			return -EINVAL;
-
-		prog_fd = bpf_fetch_prog_sec(elf_fd, elf_hdr, sec_done,
-					     type, data_insn.sec_name,
-					     license, sym_tab);
-		if (prog_fd < 0)
+		fd = bpf_fetch_prog_sec(ctx, data.sec_name);
+		if (fd < 0)
 			return -EIO;
 
-		ret = bpf_update_map(map_fds[map_id], &key_id, &prog_fd,
-				     BPF_ANY);
+		ret = bpf_map_update(ctx->map_fds[map_id], &key_id,
+				     &fd, BPF_NOEXIST);
 		if (ret < 0)
 			return -ENOENT;
 
-		sec_done[sec_index] = true;
+		ctx->sec_done[i] = true;
 	}
 
 	return 0;
 }
 
-int bpf_open_object(const char *path, enum bpf_prog_type type,
-		    const char *sec, bool verbose)
+static void bpf_save_finfo(struct bpf_elf_ctx *ctx)
 {
-	char license[ELF_MAX_LICENSE_LEN];
-	int file_fd, prog_fd = -1, ret;
-	Elf_Data *sym_tab = NULL;
-	GElf_Ehdr elf_hdr;
-	bool *sec_done;
-	Elf *elf_fd;
+	struct stat st;
+	int ret;
 
-	if (elf_version(EV_CURRENT) == EV_NONE)
-		return -EINVAL;
+	memset(&ctx->stat, 0, sizeof(ctx->stat));
 
-	file_fd = open(path, O_RDONLY, 0);
-	if (file_fd < 0)
-		return -errno;
+	ret = fstat(ctx->obj_fd, &st);
+	if (ret < 0) {
+		fprintf(stderr, "Stat of elf file failed: %s\n",
+			strerror(errno));
+		return;
+	}
 
-	elf_fd = elf_begin(file_fd, ELF_C_READ, NULL);
-	if (!elf_fd) {
+	ctx->stat.st_dev = st.st_dev;
+	ctx->stat.st_ino = st.st_ino;
+}
+
+static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
+			    enum bpf_prog_type type, bool verbose)
+{
+	int ret = -EINVAL;
+
+	if (elf_version(EV_CURRENT) == EV_NONE ||
+	    bpf_init_env(pathname))
+		return ret;
+
+	memset(ctx, 0, sizeof(*ctx));
+	ctx->verbose = verbose;
+	ctx->type    = type;
+
+	ctx->obj_fd = open(pathname, O_RDONLY);
+	if (ctx->obj_fd < 0)
+		return ctx->obj_fd;
+
+	ctx->elf_fd = elf_begin(ctx->obj_fd, ELF_C_READ, NULL);
+	if (!ctx->elf_fd) {
 		ret = -EINVAL;
-		goto out;
+		goto out_fd;
 	}
 
-	if (gelf_getehdr(elf_fd, &elf_hdr) != &elf_hdr) {
+	if (gelf_getehdr(ctx->elf_fd, &ctx->elf_hdr) !=
+	    &ctx->elf_hdr) {
 		ret = -EIO;
 		goto out_elf;
 	}
 
-	sec_done = calloc(elf_hdr.e_shnum, sizeof(*sec_done));
-	if (!sec_done) {
+	ctx->sec_done = calloc(ctx->elf_hdr.e_shnum,
+			       sizeof(*(ctx->sec_done)));
+	if (!ctx->sec_done) {
 		ret = -ENOMEM;
 		goto out_elf;
 	}
 
-	memset(license, 0, sizeof(license));
-	bpf_verbose = verbose;
+	bpf_save_finfo(ctx);
+	return 0;
+out_elf:
+	elf_end(ctx->elf_fd);
+out_fd:
+	close(ctx->obj_fd);
+	return ret;
+}
 
-	if (!bpf_may_skip_map_creation(file_fd))
-		bpf_maps_init();
+static int bpf_maps_count(struct bpf_elf_ctx *ctx)
+{
+	int i, count = 0;
 
-	ret = bpf_fetch_ancillary(file_fd, elf_fd, &elf_hdr, sec_done,
-				  license, sizeof(license), &sym_tab);
-	if (ret < 0)
-		goto out_maps;
+	for (i = 0; i < ARRAY_SIZE(ctx->map_fds); i++) {
+		if (!ctx->map_fds[i])
+			break;
+		count++;
+	}
 
-	prog_fd = bpf_fetch_prog_sec(elf_fd, &elf_hdr, sec_done, type,
-				     sec, license, sym_tab);
-	if (prog_fd < 0)
-		goto out_maps;
+	return count;
+}
 
-	if (!bpf_may_skip_map_creation(file_fd)) {
-		ret = bpf_fill_prog_arrays(elf_fd, &elf_hdr, sec_done,
-					   type, license, sym_tab);
-		if (ret < 0)
-			goto out_prog;
+static void bpf_maps_teardown(struct bpf_elf_ctx *ctx)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ctx->map_fds); i++) {
+		if (ctx->map_fds[i])
+			close(ctx->map_fds[i]);
 	}
+}
+
+static void bpf_elf_ctx_destroy(struct bpf_elf_ctx *ctx, bool failure)
+{
+	if (failure)
+		bpf_maps_teardown(ctx);
 
-	bpf_save_finfo(file_fd);
+	free(ctx->sec_done);
+	elf_end(ctx->elf_fd);
+	close(ctx->obj_fd);
+}
 
-	free(sec_done);
+static struct bpf_elf_ctx __ctx;
 
-	elf_end(elf_fd);
-	close(file_fd);
+static int bpf_obj_open(const char *pathname, enum bpf_prog_type type,
+			const char *section, bool verbose)
+{
+	struct bpf_elf_ctx *ctx = &__ctx;
+	int fd = 0, ret;
 
-	return prog_fd;
+	ret = bpf_elf_ctx_init(ctx, pathname, type, verbose);
+	if (ret < 0) {
+		fprintf(stderr, "Cannot initialize ELF context!\n");
+		return ret;
+	}
 
-out_prog:
-	close(prog_fd);
-out_maps:
-	bpf_maps_destroy();
-	free(sec_done);
-out_elf:
-	elf_end(elf_fd);
+	ret = bpf_fetch_ancillary(ctx);
+	if (ret < 0) {
+		fprintf(stderr, "Error fetching ELF ancillary data!\n");
+		goto out;
+	}
+
+	fd = bpf_fetch_prog_sec(ctx, section);
+	if (fd < 0) {
+		fprintf(stderr, "Error fetching program/map!\n");
+		ret = fd;
+		goto out;
+	}
+
+	ret = bpf_fill_prog_arrays(ctx);
+	if (ret < 0)
+		fprintf(stderr, "Error filling program arrays!\n");
 out:
-	close(file_fd);
-	bpf_clear_finfo();
-	return prog_fd;
+	bpf_elf_ctx_destroy(ctx, ret < 0);
+	if (ret < 0) {
+		if (fd)
+			close(fd);
+		return ret;
+	}
+
+	return fd;
 }
 
 static int
@@ -803,6 +1399,7 @@ bpf_map_set_recv(int fd, int *fds,  struct bpf_map_aux *aux,
 
 int bpf_send_map_fds(const char *path, const char *obj)
 {
+	struct bpf_elf_ctx *ctx = &__ctx;
 	struct sockaddr_un addr;
 	struct bpf_map_data bpf_aux;
 	int fd, ret;
@@ -827,18 +1424,18 @@ int bpf_send_map_fds(const char *path, const char *obj)
 
 	memset(&bpf_aux, 0, sizeof(bpf_aux));
 
-	bpf_aux.fds = map_fds;
-	bpf_aux.ent = map_ent;
-
+	bpf_aux.fds = ctx->map_fds;
+	bpf_aux.ent = ctx->maps;
+	bpf_aux.st  = &ctx->stat;
 	bpf_aux.obj = obj;
-	bpf_aux.st = &bpf_st;
 
 	ret = bpf_map_set_send(fd, &addr, sizeof(addr), &bpf_aux,
-			       bpf_maps_count());
+			       bpf_maps_count(ctx));
 	if (ret < 0)
 		fprintf(stderr, "Cannot send fds to %s: %s\n",
 			path, strerror(errno));
 
+	bpf_maps_teardown(ctx);
 	close(fd);
 	return ret;
 }
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 2ad8812..dea3c3b 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -13,61 +13,56 @@
 #ifndef _TC_BPF_H_
 #define _TC_BPF_H_ 1
 
-#include <linux/filter.h>
 #include <linux/netlink.h>
-#include <linux/rtnetlink.h>
 #include <linux/bpf.h>
-#include <sys/syscall.h>
-#include <errno.h>
-#include <stdio.h>
-#include <stdint.h>
+#include <linux/magic.h>
 
 #include "utils.h"
 #include "bpf_scm.h"
 
+enum {
+	BPF_NLA_OPS_LEN = 0,
+	BPF_NLA_OPS,
+	BPF_NLA_FD,
+	BPF_NLA_NAME,
+	__BPF_NLA_MAX,
+};
+
+#define BPF_NLA_MAX	__BPF_NLA_MAX
+
 #define BPF_ENV_UDS	"TC_BPF_UDS"
+#define BPF_ENV_MNT	"TC_BPF_MNT"
+#define BPF_ENV_NOLOG	"TC_BPF_NOLOG"
 
-int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
-		     char **bpf_string, bool *need_release,
-		     const char separator);
-int bpf_parse_ops(int argc, char **argv, struct sock_filter *bpf_ops,
-		  bool from_file);
-void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
+#ifndef BPF_FS_MAGIC
+# define BPF_FS_MAGIC	0xcafe4a11
+#endif
 
+#define BPF_DIR_MNT	"/sys/fs/bpf"
+
+#define BPF_DIR_TC	"tc"
+#define BPF_DIR_GLOBALS	"globals"
+
+#ifndef TRACEFS_MAGIC
+# define TRACEFS_MAGIC	0x74726163
+#endif
+
+#define TRACE_DIR_MNT	"/sys/kernel/tracing"
+
+int bpf_trace_pipe(void);
 const char *bpf_default_section(const enum bpf_prog_type type);
 
-#ifdef HAVE_ELF
-int bpf_open_object(const char *path, enum bpf_prog_type type,
-		    const char *sec, bool verbose);
+int bpf_parse_common(int *ptr_argc, char ***ptr_argv, const int *nla_tbl,
+		     enum bpf_prog_type type, const char **ptr_object,
+		     const char **ptr_uds_name, struct nlmsghdr *n);
 
+void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
+
+#ifdef HAVE_ELF
 int bpf_send_map_fds(const char *path, const char *obj);
 int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
 		     unsigned int entries);
-
-static inline __u64 bpf_ptr_to_u64(const void *ptr)
-{
-	return (__u64) (unsigned long) ptr;
-}
-
-static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
-{
-#ifdef __NR_bpf
-	return syscall(__NR_bpf, cmd, attr, size);
 #else
-	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
-	errno = ENOSYS;
-	return -1;
-#endif
-}
-#else
-static inline int bpf_open_object(const char *path, enum bpf_prog_type type,
-				  const char *sec, bool verbose)
-{
-	fprintf(stderr, "No ELF library support compiled in.\n");
-	errno = ENOSYS;
-	return -1;
-}
-
 static inline int bpf_send_map_fds(const char *path, const char *obj)
 {
 	return 0;
-- 
1.9.3
