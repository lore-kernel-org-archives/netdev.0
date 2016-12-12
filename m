From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -net-next] lwt: BPF support for LWT
Date: Mon, 12 Dec 2016 01:14:35 +0100
Message-ID: <43d8d9ddc604f83e9abff9f998b9581210529c30.1481501217.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55582 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751471AbcLLAOl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 19:14:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

Adds support to configure BPF programs as nexthop actions via the LWT
framework.

Example:
   ip route add 192.168.253.2/32 \
     encap bpf out obj lwt_len_hist_kern.o section len_hist \
     dev veth0

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/bpf_api.h      |   5 ++
 ip/iproute_lwtunnel.c  | 186 +++++++++++++++++++++++++++++++++++++++++++++----
 lib/bpf.c              |  18 +++++
 man/man8/ip-route.8.in |  41 ++++++++++-
 4 files changed, 235 insertions(+), 15 deletions(-)

diff --git a/include/bpf_api.h b/include/bpf_api.h
index 72578c9..d132471 100644
--- a/include/bpf_api.h
+++ b/include/bpf_api.h
@@ -87,6 +87,11 @@
 	__section(ELF_SECTION_ACTION)
 #endif
 
+#ifndef __section_lwt_entry
+# define __section_lwt_entry						\
+	__section(ELF_SECTION_PROG)
+#endif
+
 #ifndef __section_license
 # define __section_license						\
 	__section(ELF_SECTION_LICENSE)
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index b656143..6c1f8fb 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -24,20 +24,7 @@
 #include "rt_names.h"
 #include "utils.h"
 #include "iproute_lwtunnel.h"
-
-static int read_encap_type(const char *name)
-{
-	if (strcmp(name, "mpls") == 0)
-		return LWTUNNEL_ENCAP_MPLS;
-	else if (strcmp(name, "ip") == 0)
-		return LWTUNNEL_ENCAP_IP;
-	else if (strcmp(name, "ip6") == 0)
-		return LWTUNNEL_ENCAP_IP6;
-	else if (strcmp(name, "ila") == 0)
-		return LWTUNNEL_ENCAP_ILA;
-	else
-		return LWTUNNEL_ENCAP_NONE;
-}
+#include "bpf_util.h"
 
 static const char *format_encap_type(int type)
 {
@@ -50,11 +37,44 @@ static const char *format_encap_type(int type)
 		return "ip6";
 	case LWTUNNEL_ENCAP_ILA:
 		return "ila";
+	case LWTUNNEL_ENCAP_BPF:
+		return "bpf";
 	default:
 		return "unknown";
 	}
 }
 
+static void encap_type_usage(void)
+{
+	int i;
+
+	fprintf(stderr, "Usage: ip route ... encap TYPE [ OPTIONS ] [...]\n");
+
+	for (i = 1; i <= LWTUNNEL_ENCAP_MAX; i++)
+		fprintf(stderr, "%s %s\n", format_encap_type(i),
+			i == 1 ? "TYPE := " : "      ");
+
+	exit(-1);
+}
+
+static int read_encap_type(const char *name)
+{
+	if (strcmp(name, "mpls") == 0)
+		return LWTUNNEL_ENCAP_MPLS;
+	else if (strcmp(name, "ip") == 0)
+		return LWTUNNEL_ENCAP_IP;
+	else if (strcmp(name, "ip6") == 0)
+		return LWTUNNEL_ENCAP_IP6;
+	else if (strcmp(name, "ila") == 0)
+		return LWTUNNEL_ENCAP_ILA;
+	else if (strcmp(name, "bpf") == 0)
+		return LWTUNNEL_ENCAP_BPF;
+	else if (strcmp(name, "help") == 0)
+		encap_type_usage();
+
+	return LWTUNNEL_ENCAP_NONE;
+}
+
 static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[MPLS_IPTUNNEL_MAX+1];
@@ -159,6 +179,34 @@ static void print_encap_ip6(FILE *fp, struct rtattr *encap)
 		fprintf(fp, "tc %d ", rta_getattr_u8(tb[LWTUNNEL_IP6_TC]));
 }
 
+static void print_encap_bpf_prog(FILE *fp, struct rtattr *encap,
+				 const char *str)
+{
+	struct rtattr *tb[LWT_BPF_PROG_MAX+1];
+
+	parse_rtattr_nested(tb, LWT_BPF_PROG_MAX, encap);
+	fprintf(fp, "%s ", str);
+
+	if (tb[LWT_BPF_PROG_NAME])
+		fprintf(fp, "%s ", rta_getattr_str(tb[LWT_BPF_PROG_NAME]));
+}
+
+static void print_encap_bpf(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[LWT_BPF_MAX+1];
+
+	parse_rtattr_nested(tb, LWT_BPF_MAX, encap);
+
+	if (tb[LWT_BPF_IN])
+		print_encap_bpf_prog(fp, tb[LWT_BPF_IN], "in");
+	if (tb[LWT_BPF_OUT])
+		print_encap_bpf_prog(fp, tb[LWT_BPF_OUT], "out");
+	if (tb[LWT_BPF_XMIT])
+		print_encap_bpf_prog(fp, tb[LWT_BPF_XMIT], "xmit");
+	if (tb[LWT_BPF_XMIT_HEADROOM])
+		fprintf(fp, "%d ", rta_getattr_u32(tb[LWT_BPF_XMIT_HEADROOM]));
+}
+
 void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 			  struct rtattr *encap)
 {
@@ -184,6 +232,9 @@ void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 	case LWTUNNEL_ENCAP_IP6:
 		print_encap_ip6(fp, encap);
 		break;
+	case LWTUNNEL_ENCAP_BPF:
+		print_encap_bpf(fp, encap);
+		break;
 	}
 }
 
@@ -365,6 +416,109 @@ static int parse_encap_ip6(struct rtattr *rta, size_t len, int *argcp, char ***a
 	return 0;
 }
 
+struct lwt_x {
+	struct rtattr *rta;
+	size_t len;
+};
+
+static void bpf_lwt_cb(void *lwt_ptr, int fd, const char *annotation)
+{
+	struct lwt_x *x = lwt_ptr;
+
+	rta_addattr32(x->rta, x->len, LWT_BPF_PROG_FD, fd);
+	rta_addattr_l(x->rta, x->len, LWT_BPF_PROG_NAME, annotation,
+		      strlen(annotation) + 1);
+}
+
+static const struct bpf_cfg_ops bpf_cb_ops = {
+	.ebpf_cb = bpf_lwt_cb,
+};
+
+static int lwt_parse_bpf(struct rtattr *rta, size_t len, int *argcp, char ***argvp,
+			 int attr, const enum bpf_prog_type bpf_type)
+{
+	struct bpf_cfg_in cfg = {
+		.argc = *argcp,
+		.argv = *argvp,
+	};
+	struct lwt_x x = {
+		.rta = rta,
+		.len = len,
+	};
+	struct rtattr *nest;
+	int err;
+
+	nest = rta_nest(rta, len, attr);
+	err = bpf_parse_common(bpf_type, &cfg, &bpf_cb_ops, &x);
+	if (err < 0) {
+		fprintf(stderr, "Failed to parse eBPF program: %s\n", strerror(err));
+		return -1;
+	}
+	rta_nest_end(rta, nest);
+
+	*argcp = cfg.argc;
+	*argvp = cfg.argv;
+
+	return 0;
+}
+
+static void lwt_bpf_usage(void)
+{
+	fprintf(stderr, "Usage: ip route ... encap bpf [ in BPF ] [ out BPF ] [ xmit BPF ] [...]\n");
+	fprintf(stderr, "BPF := obj FILE [ section NAME ] [ verbose ]\n");
+	exit(-1);
+}
+
+static int parse_encap_bpf(struct rtattr *rta, size_t len, int *argcp,
+			   char ***argvp)
+{
+	char **argv = *argvp;
+	int argc = *argcp;
+	int headroom_set = 0;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "in") == 0) {
+			NEXT_ARG();
+			if (lwt_parse_bpf(rta, len, &argc, &argv, LWT_BPF_IN,
+					  BPF_PROG_TYPE_LWT_IN) < 0)
+				return -1;
+		} else if (strcmp(*argv, "out") == 0) {
+			NEXT_ARG();
+			if (lwt_parse_bpf(rta, len, &argc, &argv, LWT_BPF_OUT,
+					  BPF_PROG_TYPE_LWT_OUT) < 0)
+				return -1;
+		} else if (strcmp(*argv, "xmit") == 0) {
+			NEXT_ARG();
+			if (lwt_parse_bpf(rta, len, &argc, &argv, LWT_BPF_XMIT,
+					  BPF_PROG_TYPE_LWT_XMIT) < 0)
+				return -1;
+		} else if (strcmp(*argv, "headroom") == 0) {
+			unsigned int headroom;
+
+			NEXT_ARG();
+			if (get_unsigned(&headroom, *argv, 0) || headroom == 0)
+				invarg("headroom is invalid\n", *argv);
+			if (!headroom_set)
+				rta_addattr32(rta, 1024, LWT_BPF_XMIT_HEADROOM,
+					      headroom);
+			headroom_set = 1;
+		} else if (strcmp(*argv, "help") == 0) {
+			lwt_bpf_usage();
+		} else {
+			break;
+		}
+		NEXT_ARG_FWD();
+	}
+
+	/* argv is currently the first unparsed argument,
+	 * but the lwt_parse_encap() caller will move to the next,
+	 * so step back */
+	*argcp = argc + 1;
+	*argvp = argv - 1;
+
+	return 0;
+}
+
 int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 {
 	struct rtattr *nest;
@@ -397,6 +551,10 @@ int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 	case LWTUNNEL_ENCAP_IP6:
 		parse_encap_ip6(rta, len, &argc, &argv);
 		break;
+	case LWTUNNEL_ENCAP_BPF:
+		if (parse_encap_bpf(rta, len, &argc, &argv) < 0)
+			exit(-1);
+		break;
 	default:
 		fprintf(stderr, "Error: unsupported encap type\n");
 		break;
diff --git a/lib/bpf.c b/lib/bpf.c
index 2a8cd51..43ef63d 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -56,6 +56,9 @@ static const enum bpf_prog_type __bpf_types[] = {
 	BPF_PROG_TYPE_SCHED_CLS,
 	BPF_PROG_TYPE_SCHED_ACT,
 	BPF_PROG_TYPE_XDP,
+	BPF_PROG_TYPE_LWT_IN,
+	BPF_PROG_TYPE_LWT_OUT,
+	BPF_PROG_TYPE_LWT_XMIT,
 };
 
 static const struct bpf_prog_meta __bpf_prog_meta[] = {
@@ -76,6 +79,21 @@ static const struct bpf_prog_meta __bpf_prog_meta[] = {
 		.subdir		= "xdp",
 		.section	= ELF_SECTION_PROG,
 	},
+	[BPF_PROG_TYPE_LWT_IN] = {
+		.type		= "lwt_in",
+		.subdir		= "ip",
+		.section	= ELF_SECTION_PROG,
+	},
+	[BPF_PROG_TYPE_LWT_OUT] = {
+		.type		= "lwt_out",
+		.subdir		= "ip",
+		.section	= ELF_SECTION_PROG,
+	},
+	[BPF_PROG_TYPE_LWT_XMIT] = {
+		.type		= "lwt_xmit",
+		.subdir		= "ip",
+		.section	= ELF_SECTION_PROG,
+	},
 };
 
 static const char *bpf_prog_to_subdir(enum bpf_prog_type type)
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index c0acaa0..8519153 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -174,7 +174,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 
 .ti -8
 .IR ENCAP " := [ "
-.IR MPLS " | " IP " ]"
+.IR MPLS " | " IP | " BPF " ] "
 
 .ti -8
 .IR ENCAP_MPLS " := "
@@ -193,6 +193,19 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .B  ttl
 .IR TTL " ]"
 
+
+.ti -8
+.IR ENCAP_BPF " := "
+.BR bpf " [ "
+.B in
+.IR PROG " ] ["
+.B out
+.IR PROG " ] ["
+.B xmit
+.IR PROG " ] ["
+.B headroom
+.IR SIZE " ]"
+
 .SH DESCRIPTION
 .B ip route
 is used to manipulate entries in the kernel routing tables.
@@ -636,6 +649,9 @@ is a string specifying the supported encapsulation type. Namely:
 .BI ip
 - IP encapsulation (Geneve, GRE, VXLAN, ...)
 .sp
+.BI bpf
+- Execution of BPF program
+.sp
 
 .in -8
 .I ENCAPHDR
@@ -664,6 +680,29 @@ is a set of encapsulation attributes specific to the
 .in -2
 .sp
 
+.B bpf
+.in +2
+.B in
+.I PROG
+- BPF program to execute for incoming packets
+.sp
+
+.B out
+.I PROG
+- BPF program to execute for outgoing packets
+.sp
+
+.B xmit
+.I PROG
+- BPF program to execute for transmitted packets
+.sp
+
+.B headroom
+.I SIZE
+- Size of header BPF program will attach (xmit)
+.in -2
+.sp
+
 .in -8
 .RE
 
-- 
1.9.3
