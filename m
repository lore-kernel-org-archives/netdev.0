From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 8/8] Introduce ip vrf command
Date: Sun, 11 Dec 2016 16:53:15 -0800
Message-ID: <1481503995-24825-9-git-send-email-dsa@cumulusnetworks.com>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36247 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932094AbcLLAx3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 19:53:29 -0500
Received: by mail-pf0-f173.google.com with SMTP id 189so9798366pfz.3
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 16:53:28 -0800 (PST)
In-Reply-To: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'ip vrf' follows the user semnatics established by 'ip netns'.

The 'ip vrf' subcommand supports 3 usages:

1. Run a command against a given vrf:
       ip vrf exec NAME CMD

   Uses the recently committed cgroup/sock BPF option. vrf directory
   is added to cgroup2 mount. Individual vrfs are created under it. BPF
   filter attached to vrf/NAME cgroup2 to set sk_bound_dev_if to the VRF
   device index. From there the current process (ip's pid) is addded to
   the cgroups.proc file and the given command is exected. In doing so
   all AF_INET/AF_INET6 (ipv4/ipv6) sockets are automatically bound to
   the VRF domain.

   The association is inherited parent to child allowing the command to
   be a shell from which other commands are run relative to the VRF.

2. Show the VRF a process is bound to:
       ip vrf id
   This command essentially looks at /proc/pid/cgroup for a "::/vrf/"
   entry with the VRF name following.

3. Show process ids bound to a VRF
       ip vrf pids NAME
   This command dumps the file MNT/vrf/NAME/cgroup.procs since that file
   shows the process ids in the particular vrf cgroup.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/Makefile       |   3 +-
 ip/ip.c           |   4 +-
 ip/ip_common.h    |   2 +
 ip/ipvrf.c        | 289 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-vrf.8 |  88 +++++++++++++++++
 5 files changed, 384 insertions(+), 2 deletions(-)
 create mode 100644 ip/ipvrf.c
 create mode 100644 man/man8/ip-vrf.8

diff --git a/ip/Makefile b/ip/Makefile
index c8e6c6172741..1928489e7f90 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,7 +7,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
-    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o ipila.o
+    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o ipila.o \
+    ipvrf.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index cb3adcb3f57d..07050b07592a 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -51,7 +51,8 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila }\n"
+"                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila |\n"
+"                   vrf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
@@ -99,6 +100,7 @@ static const struct cmd {
 	{ "mrule",	do_multirule },
 	{ "netns",	do_netns },
 	{ "netconf",	do_ipnetconf },
+	{ "vrf",	do_ipvrf},
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 3162f1ca5b2c..28763e81e4a4 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -57,6 +57,8 @@ extern int do_ipila(int argc, char **argv);
 int do_tcp_metrics(int argc, char **argv);
 int do_ipnetconf(int argc, char **argv);
 int do_iptoken(int argc, char **argv);
+int do_ipvrf(int argc, char **argv);
+
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
diff --git a/ip/ipvrf.c b/ip/ipvrf.c
new file mode 100644
index 000000000000..d49af774438e
--- /dev/null
+++ b/ip/ipvrf.c
@@ -0,0 +1,289 @@
+/*
+ * ipvrf.c	"ip vrf"
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	David Ahern <dsa@cumulusnetworks.com>
+ *
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/socket.h>
+#include <sys/mount.h>
+#include <linux/bpf.h>
+#include <linux/if.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include <limits.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+#include "bpf_util.h"
+
+#define CGRP_PROC_FILE  "/cgroup.procs"
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip vrf exec [NAME] cmd ...\n");
+	fprintf(stderr, "       ip vrf identify [PID]\n");
+	fprintf(stderr, "       ip vrf pids [NAME]\n");
+
+	exit(-1);
+}
+
+static int ipvrf_identify(int argc, char **argv)
+{
+	char path[PATH_MAX];
+	char buf[4096];
+	char *vrf, *end;
+	int fd, rc = -1;
+	unsigned int pid;
+	ssize_t n;
+
+	if (argc < 1)
+		pid = getpid();
+	else if (argc > 1)
+		invarg("Extra arguments specified\n", argv[1]);
+	else if (get_unsigned(&pid, argv[0], 10))
+		invarg("Invalid pid\n", argv[0]);
+
+	snprintf(path, sizeof(path), "/proc/%d/cgroup", pid);
+	fd = open(path, O_RDONLY);
+	if (fd < 0) {
+		fprintf(stderr,
+			"Failed to open cgroups file: %s\n", strerror(errno));
+		return -1;
+	}
+
+	n = read(fd, buf, sizeof(buf) - 1);
+	if (n < 0) {
+		fprintf(stderr,
+			"Failed to read cgroups file: %s\n", strerror(errno));
+		goto out;
+	}
+	buf[n] = '\0';
+	vrf = strstr(buf, "::/vrf/");
+	if (vrf) {
+		vrf += 7;  /* skip past "::/vrf/" */
+		end = strchr(vrf, '\n');
+		if (end)
+			*end = '\0';
+
+		printf("%s\n", vrf);
+	}
+
+	rc = 0;
+out:
+	close(fd);
+
+	return rc;
+}
+
+static int ipvrf_pids(int argc, char **argv)
+{
+	char path[PATH_MAX];
+	char buf[4096];
+	char *mnt, *vrf;
+	int fd, rc = -1;
+	ssize_t n;
+
+	if (argc != 1) {
+		fprintf(stderr, "Invalid arguments\n");
+		return -1;
+	}
+
+	vrf = argv[0];
+
+	mnt = find_cgroup2_mount();
+	if (!mnt)
+		return -1;
+
+	snprintf(path, sizeof(path), "%s/vrf/%s%s", mnt, vrf, CGRP_PROC_FILE);
+	free(mnt);
+	fd = open(path, O_RDONLY);
+	if (fd < 0)
+		return 0; /* no cgroup file, nothing to show */
+
+	while (1) {
+		n = read(fd, buf, sizeof(buf) - 1);
+		if (n < 0) {
+			fprintf(stderr,
+				"Failed to read cgroups file: %s\n", strerror(errno));
+			break;
+		} else if (n == 0) {
+			rc = 0;
+			break;
+		}
+		printf("%s", buf);
+	}
+
+	close(fd);
+
+	return rc;
+}
+
+/* load BPF program to set sk_bound_dev_if for sockets */
+static char bpf_log_buf[256*1024];
+
+static int prog_load(int idx)
+{
+	struct bpf_insn prog[] = {
+		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+		BPF_MOV64_IMM(BPF_REG_3, idx),
+		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, bound_dev_if)),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, bound_dev_if)),
+		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
+		BPF_EXIT_INSN(),
+	};
+
+	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
+			     "GPL", bpf_log_buf, sizeof(bpf_log_buf));
+}
+
+static int vrf_configure_cgroup(const char *path, int ifindex)
+{
+	int rc = -1, cg_fd, prog_fd = -1;
+
+	cg_fd = open(path, O_DIRECTORY | O_RDONLY);
+	if (cg_fd < 0) {
+		fprintf(stderr, "Failed to open cgroup path: '%s'\n", strerror(errno));
+		goto out;
+	}
+
+	/*
+	 * Load bpf program into kernel and attach to cgroup to affect
+	 * socket creates
+	 */
+	prog_fd = prog_load(ifindex);
+	if (prog_fd < 0) {
+		printf("Failed to load BPF prog: '%s'\n", strerror(errno));
+		goto out;
+	}
+
+	if (bpf_prog_attach_fd(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK_CREATE)) {
+		fprintf(stderr, "Failed to attach prog to cgroup: '%s'\n",
+			strerror(errno));
+			fprintf(stderr, "Kernel compiled with CGROUP_BPF enabled?\n");
+		goto out;
+	}
+
+	rc = 0;
+out:
+	close(cg_fd);
+	close(prog_fd);
+
+	return rc;
+}
+
+static int vrf_switch(const char *name)
+{
+	char path[PATH_MAX], *mnt, pid[16];
+	int ifindex = name_is_vrf(name);
+	bool default_vrf = false;
+	int rc = -1, len, fd = -1;
+
+	if (!ifindex) {
+		if (strcmp(name, "default")) {
+			fprintf(stderr, "Invalid VRF name\n");
+			return -1;
+		}
+		default_vrf = true;
+	}
+
+	mnt = find_cgroup2_mount();
+	if (!mnt)
+		return -1;
+
+	/* path to cgroup; make sure buffer has room to cat "/cgroup.procs"
+	 * to the end of the path
+	 */
+	len = snprintf(path, sizeof(path) - sizeof(CGRP_PROC_FILE), "%s%s/%s",
+		       mnt, default_vrf ? "" : "/vrf", name);
+	if (len > sizeof(path) - sizeof(CGRP_PROC_FILE)) {
+		fprintf(stderr, "Invalid path to cgroup2 mount\n");
+		goto out;
+	}
+
+	if (make_path(path, 0755)) {
+		fprintf(stderr, "Failed to setup vrf cgroup2 directory\n");
+		goto out;
+	}
+
+	if (!default_vrf && vrf_configure_cgroup(path, ifindex))
+		goto out;
+
+	/*
+	 * write pid to cgroup.procs making process part of cgroup
+	 */
+	strcat(path, CGRP_PROC_FILE);
+	fd = open(path, O_RDWR | O_APPEND);
+	if (fd < 0) {
+		fprintf(stderr, "Failed to open cgroups.procs file: %s.\n",
+			strerror(errno));
+		goto out;
+	}
+
+	snprintf(pid, sizeof(pid), "%d", getpid());
+	if (write(fd, pid, strlen(pid)) < 0) {
+		fprintf(stderr, "Failed to join cgroup\n");
+		goto out;
+	}
+
+	rc = 0;
+out:
+	free(mnt);
+	close(fd);
+
+	return rc;
+}
+
+static int ipvrf_exec(int argc, char **argv)
+{
+	if (argc < 1) {
+		fprintf(stderr, "No VRF name specified\n");
+		return -1;
+	}
+	if (argc < 2) {
+		fprintf(stderr, "No command specified\n");
+		return -1;
+	}
+
+	if (vrf_switch(argv[0]))
+		return -1;
+
+	return -cmd_exec(argv[1], argv + 1, !!batch_mode);
+}
+
+int do_ipvrf(int argc, char **argv)
+{
+	if (argc == 0) {
+		fprintf(stderr, "No command given. Try \"ip vrf help\".\n");
+		exit(-1);
+	}
+
+	if (matches(*argv, "identify") == 0)
+		return ipvrf_identify(argc-1, argv+1);
+
+	if (matches(*argv, "pids") == 0)
+		return ipvrf_pids(argc-1, argv+1);
+
+	if (matches(*argv, "exec") == 0)
+		return ipvrf_exec(argc-1, argv+1);
+
+	if (matches(*argv, "help") == 0)
+		usage();
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip vrf help\".\n",
+		*argv);
+
+	exit(-1);
+}
diff --git a/man/man8/ip-vrf.8 b/man/man8/ip-vrf.8
new file mode 100644
index 000000000000..57a7c7692ce8
--- /dev/null
+++ b/man/man8/ip-vrf.8
@@ -0,0 +1,88 @@
+.TH IP\-VRF 8 "7 Dec 2016" "iproute2" "Linux"
+.SH NAME
+ip-vrf \- run a command against a vrf
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip
+.B vrf
+.RI  " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.BR "ip vrf identify"
+.RI "[ " PID " ]"
+
+.ti -8
+.BR "ip vrf pids"
+.I NAME
+
+.ti -8
+.BR "ip vrf exec "
+.RI "[ " NAME " ] " command ...
+
+.SH DESCRIPTION
+A VRF provides traffic isolation at layer 3 for routing, similar to how a
+VLAN is used to isolate traffic at layer 2. Fundamentally, a VRF is a separate
+routing table. Network devices are associated with a VRF by enslaving the
+device to the VRF. At that point network addresses assigned to the device are
+local to the VRF with host and connected routes moved to the table associated
+with the VRF.
+
+A process can specify a VRF using several APIs -- binding the socket to the
+VRF device using SO_BINDTODEVICE, setting the VRF association using
+IP_UNICAST_IF or IPV6_UNICAST_IF, or specifying the VRF for a specific message
+using IP_PKTINFO or IPV6_PKTINFO.
+
+By default a process is not bound to any VRF. An association can be set
+explicitly by making the program use one of the APIs mentioned above or
+implicitly using a helper to set SO_BINDTODEVICE for all IPv4 and IPv6
+sockets (AF_INET and AF_INET6) when the socket is created. This ip-vrf command
+is a helper to run a command against a specific VRF with the VRF association
+inherited parent to child.
+
+.TP
+.B ip vrf exec [ NAME ] cmd ... - Run cmd against the named VRF
+.sp
+This command allows applications that are VRF unaware to be run against
+a VRF other than the default VRF (main table). A command can be run against
+the default VRF by passing the "default" as the VRF name. This is useful if
+the current shell is associated with another VRF (e.g, Management VRF).
+
+.TP
+.B ip vrf identify [PID] - Report VRF association for process
+.sp
+This command shows the VRF association of the specified process. If PID is
+not specified then the id of the current process is used.
+
+.TP
+.B ip vrf pids NAME - Report processes associated with the named VRF
+.sp
+This command shows all process ids that are associated with the given
+VRF.
+
+.SH CAVEATS
+This command requires a kernel compiled with CGROUPS and CGROUP_BPF enabled.
+
+The VRF helper *only* affects network layer sockets.
+
+.SH EXAMPLES
+.PP
+ip vrf exec red ssh 10.100.1.254
+.RS
+Executes ssh to 10.100.1.254 against the VRF red table.
+.RE
+
+.SH SEE ALSO
+.br
+.BR ip (8),
+.BR ip-link (8),
+.BR ip-address (8),
+.BR ip-route (8),
+.BR ip-neighbor (8)
+
+.SH AUTHOR
+Original Manpage by David Ahern
-- 
2.1.4
