From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -net-next] bpf: add initial support for attaching xdp progs
Date: Tue,  6 Dec 2016 02:21:57 +0100
Message-ID: <5749edb1f01927a149910acb3ad8d106329a82fc.1480986807.git.daniel@iogearbox.net>
References: <96d911b76235bec7fc7551eb227eb750ff8c5de1.1480986807.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47957 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbcLFBWO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 20:22:14 -0500
In-Reply-To: <96d911b76235bec7fc7551eb227eb750ff8c5de1.1480986807.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we made the BPF loader generic as a library, reuse it
for loading XDP programs as well. This basically adds a minimal
start of a facility for iproute2 to load XDP programs. There
currently only exists the xdp1_user.c sample code in the kernel
tree that sets up netlink directly and an iovisor/bcc front-end.

Since we have all the necessary infrastructure in place already
from tc side, we can just reuse its loader back-end and thus
facilitate migration and usability among the two for people
familiar with tc/bpf already. Sharing maps, performing tail calls,
etc works the same way as with tc. Naturally, once kernel
configuration API evolves, we will extend new features for XDP
here as well, resp. extend dumping of related netlink attributes.

Minimal example:

  clang -target bpf -O2 -Wall -c prog.c -o prog.o
  ip [-force] link set dev em1 xdp obj prog.o       # attaching
  ip [-d] link                                      # dumping
  ip link set dev em1 xdp off                       # detaching

For the dump, intention is that in the first line for each ip
link entry, we'll see "xdp" to indicate that this device has an
XDP program attached. Once we dump some more useful information
via netlink (digest, etc), idea is that 'ip -d link' will then
display additional relevant program information below the "link/
ether [...]" output line for such devices, for example.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/bpf_api.h     |  5 +++
 include/bpf_elf.h     |  1 +
 include/utils.h       |  7 +++-
 ip/Makefile           |  2 +-
 ip/ipaddress.c        |  3 ++
 ip/iplink.c           | 22 +++++++-----
 ip/iplink_xdp.c       | 75 ++++++++++++++++++++++++++++++++++++++++
 ip/xdp.h              |  9 +++++
 lib/bpf.c             |  6 ++++
 man/man8/ip-link.8.in | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 10 files changed, 213 insertions(+), 12 deletions(-)
 create mode 100644 ip/iplink_xdp.c
 create mode 100644 ip/xdp.h

diff --git a/include/bpf_api.h b/include/bpf_api.h
index 7642623..72578c9 100644
--- a/include/bpf_api.h
+++ b/include/bpf_api.h
@@ -72,6 +72,11 @@
 	__section(__stringify(ID) "/" __stringify(KEY))
 #endif
 
+#ifndef __section_xdp_entry
+# define __section_xdp_entry						\
+	__section(ELF_SECTION_PROG)
+#endif
+
 #ifndef __section_cls_entry
 # define __section_cls_entry						\
 	__section(ELF_SECTION_CLASSIFIER)
diff --git a/include/bpf_elf.h b/include/bpf_elf.h
index 36cc988..239a0f3 100644
--- a/include/bpf_elf.h
+++ b/include/bpf_elf.h
@@ -15,6 +15,7 @@
 /* ELF section names, etc */
 #define ELF_SECTION_LICENSE	"license"
 #define ELF_SECTION_MAPS	"maps"
+#define ELF_SECTION_PROG	"prog"
 #define ELF_SECTION_CLASSIFIER	"classifier"
 #define ELF_SECTION_ACTION	"action"
 
diff --git a/include/utils.h b/include/utils.h
index 1b4f939..26c970d 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -239,7 +239,12 @@ ssize_t getcmdline(char **line, size_t *len, FILE *in);
 int makeargs(char *line, char *argv[], int maxargs);
 int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6);
 
-struct iplink_req;
+struct iplink_req {
+	struct nlmsghdr		n;
+	struct ifinfomsg	i;
+	char			buf[1024];
+};
+
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
 		int *group, int *index);
diff --git a/ip/Makefile b/ip/Makefile
index 86c8cdc..c8e6c61 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -2,7 +2,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o iptoken.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
-    iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
+    iplink_vlan.o link_veth.o link_gre.o iplink_can.o iplink_xdp.o \
     iplink_macvlan.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 50897e6..de64877 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -35,6 +35,7 @@
 #include "utils.h"
 #include "ll_map.h"
 #include "ip_common.h"
+#include "xdp.h"
 #include "color.h"
 
 enum {
@@ -838,6 +839,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (tb[IFLA_MTU])
 		fprintf(fp, "mtu %u ", *(int *)RTA_DATA(tb[IFLA_MTU]));
+	if (tb[IFLA_XDP])
+		xdp_dump(fp, tb[IFLA_XDP]);
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", rta_getattr_str(tb[IFLA_QDISC]));
 	if (tb[IFLA_MASTER]) {
diff --git a/ip/iplink.c b/ip/iplink.c
index 1e603e7..2638408 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -32,6 +32,7 @@
 #include "rt_names.h"
 #include "utils.h"
 #include "ip_common.h"
+#include "xdp.h"
 #include "namespace.h"
 
 #define IPLINK_IOCTL_COMPAT	1
@@ -54,6 +55,7 @@ void iplink_usage(void)
 			"                   [ numtxqueues QUEUE_COUNT ]\n"
 			"                   [ numrxqueues QUEUE_COUNT ]\n"
 			"                   type TYPE [ ARGS ]\n"
+			"\n"
 			"       ip link delete { DEVICE | dev DEVICE | group DEVGROUP } type TYPE [ ARGS ]\n"
 			"\n"
 			"       ip link set { DEVICE | dev DEVICE | group DEVGROUP }\n"
@@ -79,24 +81,28 @@ void iplink_usage(void)
 		"			  [ alias NAME ]\n"
 		"	                  [ vf NUM [ mac LLADDR ]\n"
 		"				   [ vlan VLANID [ qos VLAN-QOS ] [ proto VLAN-PROTO ] ]\n"
-
 		"				   [ rate TXRATE ]\n"
 		"				   [ max_tx_rate TXRATE ]\n"
 		"				   [ min_tx_rate TXRATE ]\n"
-
 		"				   [ spoofchk { on | off} ]\n"
 		"				   [ query_rss { on | off} ]\n"
 		"				   [ state { auto | enable | disable} ] ]\n"
 		"				   [ trust { on | off} ] ]\n"
+		"			  [ xdp { off |\n"
+		"				  object FILE [ section NAME ] [ verbose ] |\n"
+		"				  pinned FILE } ]\n"
 		"			  [ master DEVICE ][ vrf NAME ]\n"
 		"			  [ nomaster ]\n"
 		"			  [ addrgenmode { eui64 | none | stable_secret | random } ]\n"
 		"	                  [ protodown { on | off } ]\n"
+		"\n"
 		"       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [vrf NAME] [type TYPE]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr,
-			"       ip link help [ TYPE ]\n\n"
+			"\n"
+			"       ip link help [ TYPE ]\n"
+			"\n"
 			"TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n"
 			"          bridge | bond | team | ipoib | ip6tnl | ipip | sit | vxlan |\n"
 			"          gre | gretap | ip6gre | ip6gretap | vti | nlmon | team_slave |\n"
@@ -221,12 +227,6 @@ static int iplink_have_newlink(void)
 }
 #endif /* ! IPLINK_IOCTL_COMPAT */
 
-struct iplink_req {
-	struct nlmsghdr		n;
-	struct ifinfomsg	i;
-	char			buf[1024];
-};
-
 static int nl_get_ll_addr_len(unsigned int dev_index)
 {
 	int len;
@@ -602,6 +602,10 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
+		} else if (strcmp(*argv, "xdp") == 0) {
+			NEXT_ARG();
+			if (xdp_parse(&argc, &argv, req))
+				exit(-1);
 		} else if (strcmp(*argv, "netns") == 0) {
 			NEXT_ARG();
 			if (netns != -1)
diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
new file mode 100644
index 0000000..a81ed97
--- /dev/null
+++ b/ip/iplink_xdp.c
@@ -0,0 +1,75 @@
+/*
+ * iplink_xdp.c XDP program loader
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Daniel Borkmann <daniel@iogearbox.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+
+#include <linux/bpf.h>
+
+#include "xdp.h"
+#include "bpf_util.h"
+
+extern int force;
+
+static void xdp_ebpf_cb(void *raw, int fd, const char *annotation)
+{
+	__u32 flags = !force ? XDP_FLAGS_UPDATE_IF_NOEXIST : 0;
+	struct iplink_req *req = raw;
+	struct rtattr *xdp;
+
+	xdp = addattr_nest(&req->n, sizeof(*req), IFLA_XDP);
+	addattr32(&req->n, sizeof(*req), IFLA_XDP_FD, fd);
+	addattr32(&req->n, sizeof(*req), IFLA_XDP_FLAGS, flags);
+	addattr_nest_end(&req->n, xdp);
+}
+
+static const struct bpf_cfg_ops bpf_cb_ops = {
+	.ebpf_cb = xdp_ebpf_cb,
+};
+
+static int xdp_delete(struct iplink_req *req)
+{
+	xdp_ebpf_cb(req, -1, NULL);
+	return 0;
+}
+
+int xdp_parse(int *argc, char ***argv, struct iplink_req *req)
+{
+	struct bpf_cfg_in cfg = {
+		.argc = *argc,
+		.argv = *argv,
+	};
+
+	if (*argc == 1) {
+		if (strcmp(**argv, "none") == 0 ||
+		    strcmp(**argv, "off") == 0)
+			return xdp_delete(req);
+	}
+	if (bpf_parse_common(BPF_PROG_TYPE_XDP, &cfg, &bpf_cb_ops, req))
+		return -1;
+
+	*argc = cfg.argc;
+	*argv = cfg.argv;
+	return 0;
+}
+
+void xdp_dump(FILE *fp, struct rtattr *xdp)
+{
+	struct rtattr *tb[IFLA_XDP_MAX + 1];
+
+	parse_rtattr_nested(tb, IFLA_XDP_MAX, xdp);
+	if (!tb[IFLA_XDP_ATTACHED] ||
+	    !rta_getattr_u8(tb[IFLA_XDP_ATTACHED]))
+		return;
+
+	fprintf(fp, "xdp ");
+	/* More to come here in future for 'ip -d link' (digest, etc) ... */
+}
diff --git a/ip/xdp.h b/ip/xdp.h
new file mode 100644
index 0000000..bc69645
--- /dev/null
+++ b/ip/xdp.h
@@ -0,0 +1,9 @@
+#ifndef __XDP__
+#define __XDP__
+
+#include "utils.h"
+
+int xdp_parse(int *argc, char ***argv, struct iplink_req *req);
+void xdp_dump(FILE *fp, struct rtattr *tb);
+
+#endif /* __XDP__ */
diff --git a/lib/bpf.c b/lib/bpf.c
index f714993..0d7e783 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -55,6 +55,7 @@ struct bpf_prog_meta {
 static const enum bpf_prog_type __bpf_types[] = {
 	BPF_PROG_TYPE_SCHED_CLS,
 	BPF_PROG_TYPE_SCHED_ACT,
+	BPF_PROG_TYPE_XDP,
 };
 
 static const struct bpf_prog_meta __bpf_prog_meta[] = {
@@ -70,6 +71,11 @@ static const struct bpf_prog_meta __bpf_prog_meta[] = {
 		.section	= ELF_SECTION_ACTION,
 		.may_uds_export	= true,
 	},
+	[BPF_PROG_TYPE_XDP] = {
+		.type		= "xdp",
+		.subdir		= "xdp",
+		.section	= ELF_SECTION_PROG,
+	},
 };
 
 static const char *bpf_prog_to_subdir(enum bpf_prog_type type)
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 18e9417..469bb43 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -126,6 +126,19 @@ ip-link \- network device configuration
 .RB "[ " port_guid " eui64 ] ]"
 .br
 .in -9
+.RB "[ " xdp  " { " off " | "
+.br
+.in +8
+.BR object
+.IR FILE
+.RB "[ " section
+.IR NAME " ]"
+.RB "[ " verbose " ] |"
+.br
+.BR pinned
+.IR FILE " } ]"
+.br
+.in -8
 .RB "[ " master
 .IR DEVICE " ]"
 .br
@@ -1319,6 +1332,60 @@ which may impact security and/or performance. (e.g. VF multicast promiscuous mod
 .in -8
 
 .TP
+.B xdp object "|" pinned "|" off
+set (or unset) a XDP ("express data path") BPF program to run on every
+packet at driver level.
+
+.B off
+(or
+.B none
+)
+- Detaches any currently attached XDP/BPF program from the given device.
+
+.BI object " FILE "
+- Attaches a XDP/BPF program to the given device. The
+.I FILE
+points to a BPF ELF file (f.e. generated by LLVM) that contains the BPF
+program code, map specifications, etc. If a XDP/BPF program is already
+attached to the given device, an error will be thrown. If no XDP/BPF
+program is currently attached, the device supports XDP and the program
+from the BPF ELF file passes the kernel verifier, then it will be attached
+to the device. If the option
+.I -force
+is passed to
+.B ip
+then any prior attached XDP/BPF program will be atomically overridden and
+no error will be thrown in this case. If no
+.B section
+option is passed, then the default section name ("prog") will be assumed,
+otherwise the provided section name will be used. If no
+.B verbose
+option is passed, then a verifier log will only be dumped on load error.
+See also
+.B EXAMPLES
+section for usage examples.
+
+.BI section " NAME "
+- Specifies a section name that contains the BPF program code. If no section
+name is specified, the default one ("prog") will be used. This option is
+to be passed with the
+.B object
+option.
+
+.BI verbose
+- Act in verbose mode. For example, even in case of success, this will
+print the verifier log in case a program was loaded from a BPF ELF file.
+
+.BI pinned " FILE "
+- Attaches a XDP/BPF program to the given device. The
+.I FILE
+points to an already pinned BPF program in the BPF file system. The option
+.B section
+doesn't apply here, but otherwise semantics are the same as with the option
+.B object
+described already.
+
+.TP
 .BI master " DEVICE"
 set master device of the device (enslave device).
 
@@ -1604,7 +1671,33 @@ encap-dport 5555 encap-csum encap-remcsum
 .RS 4
 Creates an IPIP that is encapsulated with Generic UDP Encapsulation,
 and the outer UDP checksum and remote checksum offload are enabled.
-
+.RE
+.PP
+ip link set dev eth0 xdp obj prog.o
+.RS 4
+Attaches a XDP/BPF program to device eth0, where the program is
+located in prog.o, section "prog" (default section). In case a
+XDP/BPF program is already attached, throw an error.
+.RE
+.PP
+ip -force link set dev eth0 xdp obj prog.o sec foo
+.RS 4
+Attaches a XDP/BPF program to device eth0, where the program is
+located in prog.o, section "foo". In case a XDP/BPF program is
+already attached, it will be overridden by the new one.
+.RE
+.PP
+ip -force link set dev eth0 xdp pinned /sys/fs/bpf/foo
+.RS 4
+Attaches a XDP/BPF program to device eth0, where the program was
+previously pinned as an object node into BPF file system under
+name foo.
+.RE
+.PP
+ip link set dev eth0 xdp off
+.RS 4
+If a XDP/BPF program is attached on device eth0, detach it and
+effectively turn off XDP for device eth0.
 .RE
 .PP
 ip link add link wpan0 lowpan0 type lowpan
-- 
1.9.3
