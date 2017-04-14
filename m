From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next 1/3] ip: add ip sr command to control SR-IPv6 internal structures
Date: Fri, 14 Apr 2017 14:36:21 +0200
Message-ID: <20170414123623.28190-2-david.lebrun@uclouvain.be>
References: <20170414123623.28190-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:48833 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751698AbdDNMg2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 08:36:28 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp3.sgsi.ucl.ac.be (Postfix) with ESMTPS id F397667DFB3
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 14:36:15 +0200 (CEST)
In-Reply-To: <20170414123623.28190-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds commands to support the tunnel source properties
("ip sr tunsrc") and the HMAC key -> secret, algorithm binding
("ip sr hmac").

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 ip/Makefile    |   2 +-
 ip/ip.c        |   3 +-
 ip/ip_common.h |   1 +
 ip/ipseg6.c    | 238 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 242 insertions(+), 2 deletions(-)
 create mode 100644 ip/ipseg6.c

diff --git a/ip/Makefile b/ip/Makefile
index 035d42c..e08c170 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -9,7 +9,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
     iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o ipila.o \
-    ipvrf.o iplink_xstats.o
+    ipvrf.o iplink_xstats.o ipseg6.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index 07050b0..7c14a8e 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -52,7 +52,7 @@ static void usage(void)
 "where  OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |\n"
 "                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila |\n"
-"                   vrf }\n"
+"                   vrf | sr }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
@@ -101,6 +101,7 @@ static const struct cmd {
 	{ "netns",	do_netns },
 	{ "netconf",	do_ipnetconf },
 	{ "vrf",	do_ipvrf},
+	{ "sr",		do_seg6 },
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 5a39623..202fc39 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -60,6 +60,7 @@ int do_iptoken(int argc, char **argv);
 int do_ipvrf(int argc, char **argv);
 void vrf_reset(void);
 int netns_identify_pid(const char *pidstr, char *name, int len);
+int do_seg6(int argc, char **argv);
 
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
 int iplink_ifla_xstats(int argc, char **argv);
diff --git a/ip/ipseg6.c b/ip/ipseg6.c
new file mode 100644
index 0000000..0d4130e
--- /dev/null
+++ b/ip/ipseg6.c
@@ -0,0 +1,238 @@
+/*
+ * seg6.c "ip sr/seg6"
+ *
+ *	  This program is free software; you can redistribute it and/or
+ *	  modify it under the terms of the GNU General Public License
+ *	  version 2 as published by the Free Software Foundation;
+ *
+ * Author: David Lebrun <david.lebrun@uclouvain.be>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+#include <sys/ioctl.h>
+#include <linux/if.h>
+
+#include <linux/genetlink.h>
+#include <linux/seg6_genl.h>
+#include <linux/seg6_hmac.h>
+
+#include "utils.h"
+#include "ip_common.h"
+#include "libgenl.h"
+
+#define HMAC_KEY_PROMPT "Enter secret for HMAC key ID (blank to delete): "
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip sr { COMMAND | help }\n");
+	fprintf(stderr, "	   ip sr hmac show\n");
+	fprintf(stderr, "	   ip sr hmac set KEYID ALGO\n");
+	fprintf(stderr, "	   ip sr tunsrc show\n");
+	fprintf(stderr, "	   ip sr tunsrc set ADDRESS\n");
+	fprintf(stderr, "where  ALGO := { sha1 | sha256 }\n");
+	exit(-1);
+}
+
+static struct rtnl_handle grth = { .fd = -1 };
+static int genl_family = -1;
+
+#define SEG6_REQUEST(_req, _bufsiz, _cmd, _flags) \
+	GENL_REQUEST(_req, _bufsiz, genl_family, 0, \
+				SEG6_GENL_VERSION, _cmd, _flags)
+
+static struct {
+	int cmd;
+	struct in6_addr addr;
+	__u32 keyid;
+	char *pass;
+	__u8 alg_id;
+} opts;
+
+static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		       void *arg)
+{
+	struct rtattr *attrs[SEG6_ATTR_MAX + 1];
+	struct genlmsghdr *ghdr;
+	FILE *fp = (FILE *)arg;
+	int len = n->nlmsg_len;
+
+	if (n->nlmsg_type != genl_family)
+		return -1;
+
+	len -= NLMSG_LENGTH(GENL_HDRLEN);
+	if (len < 0)
+		return -1;
+
+	ghdr = NLMSG_DATA(n);
+
+	parse_rtattr(attrs, SEG6_ATTR_MAX, (void *)ghdr + GENL_HDRLEN, len);
+
+	switch (ghdr->cmd) {
+	case SEG6_CMD_DUMPHMAC:
+	{
+		char secret[64];
+		char *algstr;
+		__u8 slen = rta_getattr_u8(attrs[SEG6_ATTR_SECRETLEN]);
+		__u8 alg_id = rta_getattr_u8(attrs[SEG6_ATTR_ALGID]);
+
+		memset(secret, 0, 64);
+
+		if (slen > 63) {
+			fprintf(stderr, "HMAC secret length %d > 63, "
+					"truncated\n", slen);
+			slen = 63;
+		}
+		memcpy(secret, RTA_DATA(attrs[SEG6_ATTR_SECRET]), slen);
+
+		switch (alg_id) {
+		case SEG6_HMAC_ALGO_SHA1:
+			algstr = "sha1";
+			break;
+		case SEG6_HMAC_ALGO_SHA256:
+			algstr = "sha256";
+			break;
+		default:
+			algstr = "<unknown>";
+		}
+
+		fprintf(fp, "hmac %u ",
+			rta_getattr_u32(attrs[SEG6_ATTR_HMACKEYID]));
+		fprintf(fp, "algo %s ", algstr);
+		fprintf(fp, "secret \"%s\" ", secret);
+
+		fprintf(fp, "\n");
+		break;
+	}
+	case SEG6_CMD_GET_TUNSRC:
+	{
+		fprintf(fp, "tunsrc addr %s\n",
+			rt_addr_n2a(AF_INET6, 16,
+				    RTA_DATA(attrs[SEG6_ATTR_DST])));
+		break;
+	}
+	}
+
+	return 0;
+}
+
+static int seg6_do_cmd(void)
+{
+	SEG6_REQUEST(req, 1024, opts.cmd, NLM_F_REQUEST);
+	int repl = 0, dump = 0;
+
+	if (genl_family < 0) {
+		if (rtnl_open_byproto(&grth, 0, NETLINK_GENERIC) < 0) {
+			fprintf(stderr, "Cannot open generic netlink socket\n");
+			exit(1);
+		}
+		genl_family = genl_resolve_family(&grth, SEG6_GENL_NAME);
+		if (genl_family < 0)
+			exit(1);
+		req.n.nlmsg_type = genl_family;
+	}
+
+	switch (opts.cmd) {
+	case SEG6_CMD_SETHMAC:
+	{
+		addattr32(&req.n, sizeof(req), SEG6_ATTR_HMACKEYID, opts.keyid);
+		addattr8(&req.n, sizeof(req), SEG6_ATTR_SECRETLEN,
+			 strlen(opts.pass));
+		addattr8(&req.n, sizeof(req), SEG6_ATTR_ALGID, opts.alg_id);
+		if (strlen(opts.pass))
+			addattr_l(&req.n, sizeof(req), SEG6_ATTR_SECRET,
+				  opts.pass, strlen(opts.pass));
+		break;
+	}
+	case SEG6_CMD_SET_TUNSRC:
+		addattr_l(&req.n, sizeof(req), SEG6_ATTR_DST, &opts.addr,
+			  sizeof(struct in6_addr));
+		break;
+	case SEG6_CMD_DUMPHMAC:
+		dump = 1;
+		break;
+	case SEG6_CMD_GET_TUNSRC:
+		repl = 1;
+		break;
+	}
+
+	if (!repl && !dump) {
+		if (rtnl_talk(&grth, &req.n, NULL, 0) < 0)
+			return -1;
+	} else if (repl) {
+		if (rtnl_talk(&grth, &req.n, &req.n, sizeof(req)) < 0)
+			return -2;
+		if (process_msg(NULL, &req.n, stdout) < 0) {
+			fprintf(stderr, "Error parsing reply\n");
+			exit(1);
+		}
+	} else {
+		req.n.nlmsg_flags |= NLM_F_DUMP;
+		req.n.nlmsg_seq = grth.dump = ++grth.seq;
+		if (rtnl_send(&grth, &req, req.n.nlmsg_len) < 0) {
+			perror("Failed to send dump request");
+			exit(1);
+		}
+
+		if (rtnl_dump_filter(&grth, process_msg, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
+	}
+
+	return 0;
+}
+
+int do_seg6(int argc, char **argv)
+{
+	if (argc < 1 || matches(*argv, "help") == 0)
+		usage();
+
+	memset(&opts, 0, sizeof(opts));
+
+	if (matches(*argv, "hmac") == 0) {
+		NEXT_ARG();
+		if (matches(*argv, "show") == 0) {
+			opts.cmd = SEG6_CMD_DUMPHMAC;
+		} else if (matches(*argv, "set") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opts.keyid, *argv, 0) || opts.keyid == 0)
+				invarg("hmac KEYID value is invalid", *argv);
+			NEXT_ARG();
+			if (strcmp(*argv, "sha1") == 0) {
+				opts.alg_id = SEG6_HMAC_ALGO_SHA1;
+			} else if (strcmp(*argv, "sha256") == 0) {
+				opts.alg_id = SEG6_HMAC_ALGO_SHA256;
+			} else {
+				invarg("hmac ALGO value is invalid", *argv);
+			}
+			opts.cmd = SEG6_CMD_SETHMAC;
+			opts.pass = getpass(HMAC_KEY_PROMPT);
+		} else {
+			invarg("unknown", *argv);
+		}
+	} else if (matches(*argv, "tunsrc") == 0) {
+		NEXT_ARG();
+		if (matches(*argv, "show") == 0) {
+			opts.cmd = SEG6_CMD_GET_TUNSRC;
+		} else if (matches(*argv, "set") == 0) {
+			NEXT_ARG();
+			opts.cmd = SEG6_CMD_SET_TUNSRC;
+			if (!inet_get_addr(*argv, NULL, &opts.addr))
+				invarg("tunsrc ADDRESS value is invalid",
+				       *argv);
+		} else {
+			invarg("unknown", *argv);
+		}
+	} else {
+		invarg("unknown", *argv);
+	}
+
+	return seg6_do_cmd();
+}
-- 
2.10.2
