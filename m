From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 net-next] ip: add MACsec support
Date: Mon,  7 Mar 2016 18:12:41 +0100
Message-ID: <e448dc09765ed22e9bd8353acbe85e7f692aa2f6.1457369326.git.sd@queasysnail.net>
References: <cover.1456937772.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196AbcCGRM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 12:12:56 -0500
In-Reply-To: <cover.1456937772.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend ip-link to create MACsec devices

  ip link add link <master> <macsec> type macsec [options]

Add `ip macsec` command to configure receive-side secure channels and
secure associations within a macsec netdevice.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
This needs the MACsec UAPI headers.

 ip/Makefile           |    2 +-
 ip/ip.c               |    3 +-
 ip/ip_common.h        |    1 +
 ip/ipmacsec.c         | 1140 +++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/Makefile     |    2 +-
 man/man8/ip-link.8.in |  134 ++++++
 man/man8/ip-macsec.8  |  110 +++++
 7 files changed, 1389 insertions(+), 3 deletions(-)
 create mode 100644 ip/ipmacsec.c
 create mode 100644 man/man8/ip-macsec.8

diff --git a/ip/Makefile b/ip/Makefile
index f3d298739cac..fe59ea8bdc76 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,7 +7,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
-    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o
+    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index eea00b822088..b7000d34382f 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -51,7 +51,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | address | addrlabel | route | rule | neighbor | ntable |\n"
 "                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | fou | tcp_metrics | token | netconf }\n"
+"                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
@@ -84,6 +84,7 @@ static const struct cmd {
 	{ "link",	do_iplink },
 	{ "l2tp",	do_ipl2tp },
 	{ "fou",	do_ipfou },
+	{ "macsec",	do_ipmacsec },
 	{ "tunnel",	do_iptunnel },
 	{ "tunl",	do_iptunnel },
 	{ "tuntap",	do_iptuntap },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 815487a07b8a..ee14b1f21b0e 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -43,6 +43,7 @@ int do_iptunnel(int argc, char **argv);
 int do_ip6tunnel(int argc, char **argv);
 int do_iptuntap(int argc, char **argv);
 int do_iplink(int argc, char **argv);
+int do_ipmacsec(int argc, char **argv);
 int do_ipmonitor(int argc, char **argv);
 int do_multiaddr(int argc, char **argv);
 int do_multiroute(int argc, char **argv);
diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
new file mode 100644
index 000000000000..8de4e65b45a9
--- /dev/null
+++ b/ip/ipmacsec.c
@@ -0,0 +1,1140 @@
+/*
+ * ipmacsec.c		"ip macsec".
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Sabrina Dubroca <sd@queasysnail.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <linux/genetlink.h>
+#include <linux/if_ether.h>
+#include <linux/if_macsec.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+#include "ll_map.h"
+#include "libgenl.h"
+
+static const char *values_on_off[] = { "on", "off" };
+
+static const char *VALIDATE_STR[] = {
+	[MACSEC_VALIDATE_DISABLED] = "disabled",
+	[MACSEC_VALIDATE_CHECK] = "check",
+	[MACSEC_VALIDATE_STRICT] = "strict",
+};
+
+struct sci {
+	__u64 sci;
+	__u16 port;
+	char abuf[6];
+};
+
+struct sa_desc {
+	__u8 an;
+	__u32 pn;
+	__u32 key_id;
+	__u32 key_len;
+	char key[MACSEC_MAX_KEY_LEN];
+	__u8 active;
+};
+
+struct cipher_args {
+	__u64 id;
+	__u8 icv_len;
+};
+
+struct txsc_desc {
+	int ifindex;
+	__u64 sci;
+	__be16 port;
+	struct cipher_args cipher;
+	__u32 flags;
+	__u32 flags_set;
+	__u32 window;
+	enum validation_type validate;
+	bool validate_set;
+	__u8 encoding_sa;
+};
+
+struct rxsc_desc {
+	int ifindex;
+	__u64 sci;
+	__u8 active;
+};
+
+#define MACSEC_BUFLEN 1024
+
+
+/* netlink socket */
+static struct rtnl_handle genl_rth;
+static int genl_family = -1;
+
+#define MACSEC_GENL_REQ(_req, _bufsiz, _cmd, _flags) \
+	GENL_REQUEST(_req, _bufsiz, genl_family, 0, MACSEC_GENL_VERSION, _cmd, _flags)
+
+
+static void init_genl(void)
+{
+	if (genl_family >= 0)
+		return;
+
+	if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
+		fprintf(stderr, "Cannot open generic netlink socket\n");
+		exit(1);
+	}
+
+	genl_family = genl_resolve_family(&genl_rth, MACSEC_GENL_NAME);
+	if (genl_family < 0)
+		exit(1);
+}
+
+static void ipmacsec_usage(void)
+{
+	fprintf(stderr, "Usage: ip macsec add DEV tx sa { 0..3 } [ OPTS ] key ID KEY\n");
+	fprintf(stderr, "       ip macsec set DEV tx sa { 0..3 } [ OPTS ]\n");
+	fprintf(stderr, "       ip macsec del DEV tx sa { 0..3 }\n");
+	fprintf(stderr, "       ip macsec add DEV rx SCI [ on | off ]\n");
+	fprintf(stderr, "       ip macsec set DEV rx SCI [ on | off ]\n");
+	fprintf(stderr, "       ip macsec del DEV rx SCI\n");
+	fprintf(stderr, "       ip macsec add DEV rx SCI [ sa { 0..3 } [ OPTS ] key ID KEY ]\n");
+	fprintf(stderr, "       ip macsec set DEV rx SCI sa { 0..3 } [ OPTS ]\n");
+	fprintf(stderr, "       ip macsec del DEV rx SCI sa { 0..3 }\n");
+	fprintf(stderr, "       ip macsec show\n");
+	fprintf(stderr, "       ip macsec show DEV\n");
+	fprintf(stderr, "where  OPTS := [ pn <u32> ] [ on | off ]\n");
+	fprintf(stderr, "       SCI  := { sci <u64> | port <u16> address <lladdr> }\n");
+
+	exit(-1);
+}
+
+static int one_of(const char *msg, const char *realval, const char **list,
+		  size_t len, int *index)
+{
+	int i;
+
+	for (i = 0; i < len; i++) {
+		if (matches(realval, list[i]) == 0) {
+			*index = i;
+			return 0;
+		}
+	}
+
+	fprintf(stderr, "Error: argument of \"%s\" must be one of ", msg);
+	for (i = 0; i < len; i++)
+		fprintf(stderr, "\"%s\", ", list[i]);
+	fprintf(stderr, "not \"%s\"\n", realval);
+	return -1;
+}
+
+static int get_an(__u8 *val, const char *arg)
+{
+	int ret = get_u8(val, arg, 0);
+
+	if (ret)
+		return ret;
+
+	if (*val > 3)
+		return -1;
+
+	return 0;
+}
+
+static int get_sci(__u64 *sci, const char *arg)
+{
+	return get_u64(sci, arg, 16);
+}
+
+static int get_port(__be16 *port, const char *arg)
+{
+	__u16 p;
+	int ret = get_u16(&p, arg, 10);
+
+	if (ret)
+		return ret;
+
+	*port = htons(p);
+	return 0;
+}
+
+static int from_hex(char c)
+{
+	if (c >= '0' && c <= '9')
+		return c - '0';
+	if (c >= 'a' && c <= 'f')
+		return c - 'a' + 10;
+	if (c >= 'A' && c <= 'F')
+		return c - 'A' + 10;
+
+	return -1;
+}
+
+static int parse_key(char *key, __u32 *key_len, char *arg)
+{
+	__u32 i = 0;
+	char *p = arg;
+
+	while (*p && *(p + 1)) {
+		int m = from_hex(*p);
+		int l = from_hex(*(p+1));
+
+		if (m < 0) {
+			fprintf(stderr, "expected hex digit, got %c\n", *p);
+			return -1;
+		}
+		if (l < 0) {
+			fprintf(stderr, "expected hex digit, got %c\n", *(p+1));
+			return -1;
+		}
+
+		key[i] = (m << 4) | l;
+		p += 2;
+		i++;
+	}
+
+	if (*p)
+		return -1;
+
+	*key_len = i;
+	return 0;
+}
+
+#define _STR(a) #a
+#define STR(a) _STR(a)
+
+static void get_icvlen(__u8 *icvlen, char *arg)
+{
+	int ret = get_u8(icvlen, arg, 10);
+
+	if (ret)
+		invarg("expected ICV length", arg);
+
+	if (*icvlen < MACSEC_MIN_ICV_LEN || *icvlen > MACSEC_MAX_ICV_LEN)
+		invarg("ICV length must be in the range {"
+		       STR(MACSEC_MIN_ICV_LEN) ".." STR(MACSEC_MAX_ICV_LEN)
+		       "}", arg);
+}
+
+static bool get_sa(int *argcp, char ***argvp, __u8 *an)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	int ret;
+
+	if (argc <= 0 || strcmp(*argv, "sa") != 0)
+		return false;
+
+	NEXT_ARG();
+	ret = get_an(an, *argv);
+	if (ret)
+		invarg("expected an { 0..3 }", *argv);
+	argc--; argv++;
+
+	*argvp = argv;
+	*argcp = argc;
+	return true;
+}
+
+static int parse_sa_args(int *argcp, char ***argvp, struct sa_desc *sa)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	int ret;
+	bool active_set = false;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "pn") == 0) {
+			if (sa->pn != 0)
+				duparg2("pn", "pn");
+			NEXT_ARG();
+			ret = get_u32(&sa->pn, *argv, 0);
+			if (ret)
+				invarg("expected pn", *argv);
+			if (sa->pn == 0)
+				invarg("expected pn != 0", *argv);
+		} else if (strcmp(*argv, "key") == 0) {
+			NEXT_ARG();
+			ret = get_u32(&sa->key_id, *argv, 0);
+			if (ret)
+				invarg("expected key id", *argv);
+			NEXT_ARG();
+			if (parse_key(sa->key, &sa->key_len, *argv))
+				invarg("expected key", *argv);
+		} else if (strcmp(*argv, "on") == 0) {
+			if (active_set)
+				duparg2("on/off", "on");
+			sa->active = true;
+			active_set = true;
+		} else if (strcmp(*argv, "off") == 0) {
+			if (active_set)
+				duparg2("on/off", "off");
+			sa->active = false;
+			active_set = true;
+		} else {
+			fprintf(stderr, "macsec: unknown command \"%s\"?\n",
+				*argv);
+			ipmacsec_usage();
+		}
+
+		argv++; argc--;
+	}
+
+	*argvp = argv;
+	*argcp = argc;
+	return 0;
+}
+
+static __u64 make_sci(char *addr, __be16 port)
+{
+	__u64 sci;
+
+	memcpy(&sci, addr, ETH_ALEN);
+	memcpy(((char *)&sci) + ETH_ALEN, &port, sizeof(port));
+
+	return sci;
+}
+
+static bool sci_complete(bool sci, bool port, bool addr, bool port_only)
+{
+	return sci || (port && (addr || port_only));
+}
+
+static int get_sci_portaddr(struct sci *sci, int *argcp, char ***argvp,
+			    bool port_only, bool optional)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	int ret;
+	bool p = false, a = false, s = false;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "sci") == 0) {
+			if (p)
+				invarg("expected address", *argv);
+			if (a)
+				invarg("expected port", *argv);
+			NEXT_ARG();
+			ret = get_sci(&sci->sci, *argv);
+			if (ret)
+				invarg("expected sci", *argv);
+			s = true;
+		} else if (strcmp(*argv, "port") == 0) {
+			NEXT_ARG();
+			ret = get_port(&sci->port, *argv);
+			if (ret)
+				invarg("expected port", *argv);
+			if (sci->port == 0)
+				invarg("expected port != 0", *argv);
+			p = true;
+		} else if (strcmp(*argv, "address") == 0) {
+			NEXT_ARG();
+			ret = ll_addr_a2n(sci->abuf, sizeof(sci->abuf), *argv);
+			if (ret < 0)
+				invarg("expected lladdr", *argv);
+			a = true;
+		} else if (optional) {
+			break;
+		} else {
+			invarg("expected sci, port, or address", *argv);
+		}
+
+		argv++; argc--;
+
+		if (sci_complete(s, p, a, port_only))
+			break;
+	}
+
+	if (!optional && !sci_complete(s, p, a, port_only))
+		return -1;
+
+	if (p && a)
+		sci->sci = make_sci(sci->abuf, sci->port);
+
+	*argvp = argv;
+	*argcp = argc;
+
+	return p || a || s;
+}
+
+static bool parse_rxsci(int *argcp, char ***argvp, struct rxsc_desc *rxsc,
+			struct sa_desc *rxsa)
+{
+	struct sci sci = { 0 };
+
+	if (*argcp == 0 ||
+	    get_sci_portaddr(&sci, argcp, argvp, false, false) < 0) {
+		fprintf(stderr, "expected sci\n");
+		ipmacsec_usage();
+	}
+
+	rxsc->sci = sci.sci;
+
+	return get_sa(argcp, argvp, &rxsa->an);
+}
+
+static int parse_rxsci_args(int *argcp, char ***argvp, struct rxsc_desc *rxsc)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	bool active_set = false;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "on") == 0) {
+			if (active_set)
+				duparg2("on/off", "on");
+			rxsc->active = true;
+			active_set = true;
+		} else if (strcmp(*argv, "off") == 0) {
+			if (active_set)
+				duparg2("on/off", "off");
+			rxsc->active = false;
+			active_set = true;
+		} else {
+			fprintf(stderr, "macsec: unknown command \"%s\"?\n",
+				*argv);
+			ipmacsec_usage();
+		}
+
+		argv++; argc--;
+	}
+
+	*argvp = argv;
+	*argcp = argc;
+	return 0;
+}
+
+enum cmd {
+	CMD_ADD,
+	CMD_DEL,
+	CMD_UPD,
+	__CMD_MAX
+};
+
+static const enum macsec_nl_commands macsec_commands[__CMD_MAX][2][2] = {
+	[CMD_ADD] = {
+		[0] = {-1, MACSEC_CMD_ADD_RXSC},
+		[1] = {MACSEC_CMD_ADD_TXSA, MACSEC_CMD_ADD_RXSA},
+	},
+	[CMD_UPD] = {
+		[0] = {-1, MACSEC_CMD_UPD_RXSC},
+		[1] = {MACSEC_CMD_UPD_TXSA, MACSEC_CMD_UPD_RXSA},
+	},
+	[CMD_DEL] = {
+		[0] = {-1, MACSEC_CMD_DEL_RXSC},
+		[1] = {MACSEC_CMD_DEL_TXSA, MACSEC_CMD_DEL_RXSA},
+	},
+};
+
+static int do_modify_nl(enum cmd c, enum macsec_nl_commands cmd, int ifindex,
+			struct rxsc_desc *rxsc, struct sa_desc *sa)
+{
+	MACSEC_GENL_REQ(req, MACSEC_BUFLEN, cmd, NLM_F_REQUEST);
+
+	addattr32(&req.n, MACSEC_BUFLEN, MACSEC_ATTR_IFINDEX, ifindex);
+	if (rxsc)
+		addattr64(&req.n, MACSEC_BUFLEN, MACSEC_ATTR_SCI, rxsc->sci);
+
+	if (sa->an != 0xff)
+		addattr8(&req.n, MACSEC_BUFLEN, MACSEC_ATTR_SA_AN, sa->an);
+
+	if (c != CMD_DEL) {
+		if (sa->pn)
+			addattr32(&req.n, MACSEC_BUFLEN, MACSEC_ATTR_SA_PN,
+				  sa->pn);
+
+		if (sa->key_len) {
+			addattr64(&req.n, MACSEC_BUFLEN, MACSEC_ATTR_SA_KEYID,
+				  sa->key_id);
+			addattr_l(&req.n, MACSEC_BUFLEN, MACSEC_ATTR_SA_KEY,
+				  sa->key, sa->key_len);
+		}
+
+		if (sa->an != 0xff) {
+			if (sa->active != 0xff)
+				addattr8(&req.n, MACSEC_BUFLEN,
+					 MACSEC_ATTR_SA_ACTIVE, sa->active);
+		} else {
+			if (rxsc && rxsc->active != 0xff)
+				addattr8(&req.n, MACSEC_BUFLEN,
+					 MACSEC_ATTR_SC_ACTIVE, rxsc->active);
+		}
+	}
+
+	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
+		return -2;
+
+	return 0;
+}
+
+static bool check_sa_args(enum cmd c, struct sa_desc *sa)
+{
+	if (c == CMD_ADD) {
+		if (!sa->key_len) {
+			fprintf(stderr, "cannot create SA without key\n");
+			return -1;
+		}
+	} else if (c == CMD_UPD) {
+		if (sa->key_len) {
+			fprintf(stderr, "cannot change key on SA\n");
+			return -1;
+		}
+	}
+
+	return 0;
+}
+
+static int do_modify_txsa(enum cmd c, int argc, char **argv, int ifindex)
+{
+	struct sa_desc txsa = {0};
+	enum macsec_nl_commands cmd;
+
+	txsa.an = 0xff;
+	txsa.active = 0xff;
+
+	if (argc == 0 || !get_sa(&argc, &argv, &txsa.an))
+		ipmacsec_usage();
+
+	if (c == CMD_DEL)
+		goto modify;
+
+	if (parse_sa_args(&argc, &argv, &txsa))
+		return -1;
+
+	if (check_sa_args(c, &txsa))
+		return -1;
+
+modify:
+	cmd = macsec_commands[c][1][0];
+	return do_modify_nl(c, cmd, ifindex, NULL, &txsa);
+}
+
+static int do_modify_rxsci(enum cmd c, int argc, char **argv, int ifindex)
+{
+	struct rxsc_desc rxsc = {0};
+	struct sa_desc rxsa = {0};
+	bool sa_set;
+	enum macsec_nl_commands cmd;
+
+	rxsc.ifindex = ifindex;
+	rxsc.active = 0xff;
+	rxsa.an = 0xff;
+	rxsa.active = 0xff;
+
+	sa_set = parse_rxsci(&argc, &argv, &rxsc, &rxsa);
+
+	if (c == CMD_DEL)
+		goto modify;
+
+	if (sa_set && (parse_sa_args(&argc, &argv, &rxsa) ||
+		       check_sa_args(c, &rxsa)))
+		return -1;
+	if (!sa_set && parse_rxsci_args(&argc, &argv, &rxsc))
+		return -1;
+
+modify:
+	cmd = macsec_commands[c][sa_set][1];
+	return do_modify_nl(c, cmd, rxsc.ifindex, &rxsc, &rxsa);
+}
+
+static int do_modify(enum cmd c, int argc, char **argv)
+{
+	int ifindex;
+
+	if (argc == 0)
+		ipmacsec_usage();
+
+	ifindex = ll_name_to_index(*argv);
+	if (!ifindex) {
+		fprintf(stderr, "Device \"%s\" does not exist.\n", *argv);
+		return -1;
+	}
+	argc--; argv++;
+
+	if (argc == 0)
+		ipmacsec_usage();
+
+	if (strcmp(*argv, "tx") == 0)
+		return do_modify_txsa(c, argc-1, argv+1, ifindex);
+	if (strcmp(*argv, "rx") == 0)
+		return do_modify_rxsci(c, argc-1, argv+1, ifindex);
+
+	ipmacsec_usage();
+	return -1;
+}
+
+/* dump/show */
+static struct {
+	int ifindex;
+	__u64 sci;
+} filter;
+
+static int validate_dump(struct rtattr **attrs)
+{
+	return attrs[MACSEC_ATTR_IFINDEX] && attrs[MACSEC_ATTR_SCI] &&
+	       attrs[MACSEC_ATTR_ENCODING_SA] &&
+	       attrs[MACSEC_ATTR_CIPHER_SUITE] && attrs[MACSEC_ATTR_ICV_LEN];
+}
+
+static void print_flag(FILE *f, struct rtattr *attrs[], const char *desc,
+		       int field)
+{
+	if (attrs[field])
+		fprintf(f, "%s %s ", desc,
+			rta_getattr_u8(attrs[field]) ? "on" : "off");
+}
+
+static const char *cs_id_to_name(__u64 cid)
+{
+	switch (cid) {
+	case DEFAULT_CIPHER_ID:
+	case DEFAULT_CIPHER_ALT:
+		return DEFAULT_CIPHER_NAME;
+	default:
+		return "(unknown)";
+	}
+}
+
+static void print_cipher_suite(const char *prefix, __u64 cid, __u8 icv_len)
+{
+	printf("%scipher suite: %s, using ICV length %d\n", prefix,
+	       cs_id_to_name(cid), icv_len);
+}
+
+static void print_attrs(const char *prefix, struct rtattr *attrs[])
+{
+	if (attrs[MACSEC_ATTR_SA_KEYID]) {
+		printf("key %llu ",
+		       rta_getattr_u64(attrs[MACSEC_ATTR_SA_KEYID]));
+	}
+
+	print_flag(stdout, attrs, "protect", MACSEC_ATTR_PROTECT);
+
+	if (attrs[MACSEC_ATTR_VALIDATE]) {
+		printf("validate %s ",
+		       VALIDATE_STR[rta_getattr_u8(attrs[MACSEC_ATTR_VALIDATE])]);
+	}
+
+	print_flag(stdout, attrs, "sc", MACSEC_ATTR_SC_ACTIVE);
+	print_flag(stdout, attrs, "sa", MACSEC_ATTR_SA_ACTIVE);
+	print_flag(stdout, attrs, "encrypt", MACSEC_ATTR_ENCRYPT);
+	print_flag(stdout, attrs, "send_sci", MACSEC_ATTR_INC_SCI);
+	print_flag(stdout, attrs, "end_station", MACSEC_ATTR_ES);
+	print_flag(stdout, attrs, "scb", MACSEC_ATTR_SCB);
+
+	print_flag(stdout, attrs, "replayprotect", MACSEC_ATTR_REPLAY);
+	if (attrs[MACSEC_ATTR_WINDOW]) {
+		printf("window %d ",
+		       rta_getattr_u32(attrs[MACSEC_ATTR_WINDOW]));
+	}
+
+	if (attrs[MACSEC_ATTR_CIPHER_SUITE] && attrs[MACSEC_ATTR_ICV_LEN]) {
+		printf("\n");
+		print_cipher_suite(prefix,
+			rta_getattr_u64(attrs[MACSEC_ATTR_CIPHER_SUITE]),
+			rta_getattr_u8(attrs[MACSEC_ATTR_ICV_LEN]));
+	}
+
+}
+
+static void print_txsc_stats(const char *prefix, struct rtattr *attr)
+{
+	struct macsec_tx_sc_stats *stats;
+
+	if (!attr || show_stats == 0)
+		return;
+
+	stats = RTA_DATA(attr);
+	printf("%sstats: OutOctetsProtected OutOctetsEncrypted OutPktsProtected OutPktsEncrypted\n", prefix);
+	printf("%s       %18llu %18llu %16llu %16llu\n", prefix,
+	       stats->OutOctetsProtected, stats->OutOctetsEncrypted,
+	       stats->OutPktsProtected, stats->OutPktsEncrypted);
+}
+
+static void print_secy_stats(const char *prefix, struct rtattr *attr)
+{
+	struct macsec_dev_stats *stats;
+
+	if (!attr || show_stats == 0)
+		return;
+
+	stats = RTA_DATA(attr);
+	printf("%sstats: OutPktsUntagged InPktsUntagged OutPktsTooLong InPktsNoTag InPktsBadTag InPktsUnknownSCI InPktsNoSCI InPktsOverrun\n", prefix);
+	printf("%s       %15llu %14llu %14llu %11llu %12llu %16llu %11llu %13llu\n", prefix,
+	       stats->OutPktsUntagged, stats->InPktsUntagged,
+	       stats->OutPktsTooLong, stats->InPktsNoTag,
+	       stats->InPktsBadTag, stats->InPktsUnknownSCI,
+	       stats->InPktsNoSCI, stats->InPktsOverrun);
+}
+
+static void print_tx_sc(const char *prefix, __u64 sci, __u8 encoding_sa,
+			struct rtattr *txsc_stats, struct rtattr *secy_stats,
+			struct rtattr *sa)
+{
+	struct rtattr *sa_attr[MACSEC_ATTR_SA_MAX + 1];
+	struct rtattr *a;
+	int rem;
+
+	printf("%sTXSC: %016llx on SA %d\n", prefix, sci, encoding_sa);
+	print_secy_stats(prefix, secy_stats);
+	print_txsc_stats(prefix, txsc_stats);
+
+	rem = RTA_PAYLOAD(sa);
+	for (a = RTA_DATA(sa); RTA_OK(a, rem); a = RTA_NEXT(a, rem)) {
+		parse_rtattr_nested(sa_attr, MACSEC_ATTR_SA_MAX + 1, a);
+		printf("%s%s%d: PN %u, state %s, key %llu\n", prefix, prefix,
+			rta_getattr_u8(sa_attr[MACSEC_ATTR_SA_AN]),
+			rta_getattr_u32(sa_attr[MACSEC_ATTR_SA_PN]),
+			rta_getattr_u8(sa_attr[MACSEC_ATTR_SA_ACTIVE]) ? "on" :
+									 "off",
+			rta_getattr_u64(sa_attr[MACSEC_ATTR_SA_KEYID]));
+		if (show_stats && sa_attr[MACSEC_SA_STATS]) {
+			struct macsec_tx_sa_stats *stats =
+				RTA_DATA(sa_attr[MACSEC_SA_STATS]);
+
+			printf("%s%s   OutPktsProtected OutPktsEncrypted\n",
+			       prefix, prefix);
+			printf("%s%s   %16u %16u\n", prefix, prefix,
+			       stats->OutPktsProtected,
+			       stats->OutPktsEncrypted);
+		}
+	}
+}
+
+static void print_rxsc_stats(const char *prefix, struct rtattr *attr)
+{
+	struct macsec_rx_sc_stats *stats;
+
+	if (!attr || show_stats == 0)
+		return;
+
+	stats = RTA_DATA(attr);
+	printf("%sstats: InOctetsValidated InOctetsDecrypted InPktsUnchecked InPktsDelayed InPktsOK InPktsInvalid InPktsLate InPktsNotValid InPktsNotUsingSA InPktsUnusedSA\n", prefix);
+	printf("%s       %17llu %17llu %15llu %13llu %8llu %13llu %10llu %14llu %16llu %14llu\n", prefix,
+	       stats->InOctetsValidated, stats->InOctetsDecrypted,
+	       stats->InPktsUnchecked, stats->InPktsDelayed, stats->InPktsOK,
+	       stats->InPktsInvalid, stats->InPktsLate, stats->InPktsNotValid,
+	       stats->InPktsNotUsingSA, stats->InPktsUnusedSA);
+}
+
+static void print_rx_sc(const char *prefix, __u64 sci, __u8 active, struct rtattr *rxsc_stats, struct rtattr *sa)
+{
+	struct rtattr *sa_attr[MACSEC_ATTR_SA_MAX + 1];
+	struct rtattr *a;
+	int rem;
+
+	printf("%sRXSC: %016llx, state %s\n", prefix, sci, active ? "on" :
+								    "off");
+	print_rxsc_stats(prefix, rxsc_stats);
+
+	rem = RTA_PAYLOAD(sa);
+	for (a = RTA_DATA(sa); RTA_OK(a, rem); a = RTA_NEXT(a, rem)) {
+		parse_rtattr_nested(sa_attr, MACSEC_ATTR_SA_MAX + 1, a);
+		printf("%s%s%d: PN %u, state %s, key %llu\n", prefix, prefix,
+			rta_getattr_u8(sa_attr[MACSEC_ATTR_SA_AN]),
+			rta_getattr_u32(sa_attr[MACSEC_ATTR_SA_PN]),
+			rta_getattr_u8(sa_attr[MACSEC_ATTR_SA_ACTIVE]) ? "on" :
+									 "off",
+			rta_getattr_u64(sa_attr[MACSEC_ATTR_SA_KEYID]));
+		if (show_stats && sa_attr[MACSEC_SA_STATS]) {
+			struct macsec_rx_sa_stats *stats = RTA_DATA(sa_attr[MACSEC_SA_STATS]);
+
+			printf("%s%s   InPktsOK InPktsInvalid InPktsNotValid InPktsNotUsingSA InPktsUnusedSA\n", prefix, prefix);
+			printf("%s%s   %8u %13u %14u %16u %14u\n",
+			       prefix, prefix, stats->InPktsOK,
+			       stats->InPktsInvalid, stats->InPktsNotValid,
+			       stats->InPktsNotUsingSA, stats->InPktsUnusedSA);
+		}
+	}
+}
+
+static int process(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		   void *arg)
+{
+	struct genlmsghdr *ghdr;
+	struct rtattr *attrs[MACSEC_ATTR_MAX + 1], *sc, *c;
+	int len = n->nlmsg_len;
+	int ifindex;
+	__u64 sci;
+	__u8 encoding_sa;
+	int rem;
+
+	if (n->nlmsg_type != genl_family)
+		return -1;
+
+	len -= NLMSG_LENGTH(GENL_HDRLEN);
+	if (len < 0)
+		return -1;
+
+	ghdr = NLMSG_DATA(n);
+	if (ghdr->cmd != MACSEC_CMD_GET_TXSC)
+		return 0;
+
+	parse_rtattr(attrs, MACSEC_ATTR_MAX, (void *) ghdr + GENL_HDRLEN, len);
+	if (!validate_dump(attrs)) {
+		printf("missing some attribute\n");
+		return -1;
+	}
+
+	ifindex = rta_getattr_u32(attrs[MACSEC_ATTR_IFINDEX]);
+	sci = rta_getattr_u64(attrs[MACSEC_ATTR_SCI]);
+	encoding_sa = rta_getattr_u8(attrs[MACSEC_ATTR_ENCODING_SA]);
+
+	if (filter.ifindex && ifindex != filter.ifindex)
+		return 0;
+
+	if (filter.sci && sci != filter.sci)
+		return 0;
+
+	printf("%d: %s: ", ifindex, ll_index_to_name(ifindex));
+	print_attrs("    ", attrs);
+
+	print_tx_sc("    ", sci, encoding_sa, attrs[MACSEC_TXSC_STATS],
+		    attrs[MACSEC_SECY_STATS], attrs[MACSEC_TXSA_LIST]);
+
+	if (!attrs[MACSEC_RXSC_LIST])
+		return 0;
+
+	sc = attrs[MACSEC_RXSC_LIST];
+	rem = RTA_PAYLOAD(sc);
+	for (c = RTA_DATA(sc); RTA_OK(c, rem); c = RTA_NEXT(c, rem)) {
+		struct rtattr *sc_attr[MACSEC_ATTR_SC_MAX + 1];
+
+		parse_rtattr_nested(sc_attr, MACSEC_ATTR_SC_MAX + 1, c);
+		print_rx_sc("    ",
+			    rta_getattr_u64(sc_attr[MACSEC_ATTR_SC_SCI]),
+			    rta_getattr_u32(sc_attr[MACSEC_ATTR_SC_ACTIVE]),
+			    sc_attr[MACSEC_RXSC_STATS],
+			    sc_attr[MACSEC_RXSA_LIST]);
+	}
+
+	return 0;
+}
+
+static int do_dump(int ifindex)
+{
+	MACSEC_GENL_REQ(req, MACSEC_BUFLEN, MACSEC_CMD_GET_TXSC,
+			NLM_F_REQUEST | NLM_F_DUMP);
+
+	memset(&filter, 0, sizeof(filter));
+	filter.ifindex = ifindex;
+
+	req.n.nlmsg_seq = genl_rth.dump = ++genl_rth.seq;
+	if (rtnl_send(&genl_rth, &req, req.n.nlmsg_len) < 0) {
+		perror("Failed to send dump request");
+		exit(1);
+	}
+
+	if (rtnl_dump_filter(&genl_rth, process, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+
+	return 0;
+}
+
+static int do_show(int argc, char **argv)
+{
+	int ifindex;
+
+	if (argc == 0)
+		return do_dump(0);
+
+	ifindex = ll_name_to_index(*argv);
+	if (ifindex == 0) {
+		fprintf(stderr, "Device \"%s\" does not exist.\n", *argv);
+		return -1;
+	}
+
+	argc--, argv++;
+	if (argc == 0)
+		return do_dump(ifindex);
+
+	ipmacsec_usage();
+	return -1;
+}
+
+int do_ipmacsec(int argc, char **argv)
+{
+	init_genl();
+
+	if (argc < 1)
+		ipmacsec_usage();
+
+	if (matches(*argv, "help") == 0)
+		ipmacsec_usage();
+
+	if (matches(*argv, "show") == 0)
+		return do_show(argc-1, argv+1);
+
+	if (matches(*argv, "add") == 0)
+		return do_modify(CMD_ADD, argc-1, argv+1);
+	if (matches(*argv, "set") == 0)
+		return do_modify(CMD_UPD, argc-1, argv+1);
+	if (matches(*argv, "delete") == 0)
+		return do_modify(CMD_DEL, argc-1, argv+1);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip macsec help\".\n",
+		*argv);
+	exit(-1);
+}
+
+/* device creation */
+static void macsec_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	if (!tb)
+		return;
+
+	if (tb[IFLA_MACSEC_SCI])
+		fprintf(f, "sci %016llx ", rta_getattr_u64(tb[IFLA_MACSEC_SCI]));
+
+	print_flag(f, tb, "protect", IFLA_MACSEC_PROTECT);
+
+	if (tb[IFLA_MACSEC_CIPHER_SUITE])
+		fprintf(f, "cipher %s ", cs_id_to_name(rta_getattr_u64(tb[IFLA_MACSEC_CIPHER_SUITE])));
+
+	if (tb[IFLA_MACSEC_ICV_LEN])
+		fprintf(f, "icvlen %d ", rta_getattr_u8(tb[IFLA_MACSEC_ICV_LEN]));
+
+	if (tb[IFLA_MACSEC_ENCODING_SA])
+		fprintf(f, "encodingsa %d ", rta_getattr_u8(tb[IFLA_MACSEC_ENCODING_SA]));
+
+	if (tb[IFLA_MACSEC_VALIDATION])
+		fprintf(f, "validate %s ", VALIDATE_STR[rta_getattr_u8(tb[IFLA_MACSEC_VALIDATION])]);
+
+	print_flag(f, tb, "encrypt", IFLA_MACSEC_ENCRYPT);
+	print_flag(f, tb, "send_sci", IFLA_MACSEC_INC_SCI);
+	print_flag(f, tb, "end_station", IFLA_MACSEC_ES);
+	print_flag(f, tb, "scb", IFLA_MACSEC_SCB);
+
+	print_flag(f, tb, "replayprotect", IFLA_MACSEC_REPLAY_PROTECT);
+	if (tb[IFLA_MACSEC_WINDOW])
+		fprintf(f, "window %d ", rta_getattr_u32(tb[IFLA_MACSEC_WINDOW]));
+}
+
+
+static int do_cipher_suite(struct cipher_args *cipher, int *argcp,
+			   char ***argvp)
+{
+	char **argv = *argvp;
+	int argc = *argcp;
+
+	if (argc == 0)
+		return -1;
+
+	if (strcmp(*argv, "default") == 0 ||
+	    strcmp(*argv, "gcm-aes-128") == 0)
+		cipher->id = DEFAULT_CIPHER_ID;
+	NEXT_ARG();
+
+	if (strcmp(*argv, "icvlen") == 0) {
+		NEXT_ARG();
+		if (cipher->icv_len != 0)
+			duparg2("icvlen", "icvlen");
+		get_icvlen(&cipher->icv_len, *argv);
+	}
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
+static bool check_txsc_flags(bool es, bool scb, bool sci)
+{
+	if (sci && (es || scb))
+		return false;
+	if (es && scb)
+		return false;
+	return true;
+}
+
+static void usage(FILE *f)
+{
+	fprintf(f,
+		"Usage: ... macsec [ port PORT | sci SCI ]\n"
+		"                  [ cipher CIPHER_SUITE ]\n"
+		"                  [ encrypt { on | off } ]\n"
+		"                  [ send_sci { on | off } ]\n"
+		"                  [ es { on | off } ]\n"
+		"                  [ scb { on | off } ]\n"
+		"                  [ protect { on | off } ]\n"
+		"                  [ replay { on | off} [ window { 0..2^32-1 } ]\n"
+		"                  [ validate { strict | check | disabled } ]\n"
+		"                  [ encoding { 0..3 } ]\n"
+		);
+	fprintf(f, "CIPHER_SUITE := [ default = gcm-aes-128 ] icvlen { 8..32 }\n");
+}
+
+static int macsec_parse_opt(struct link_util *lu, int argc, char **argv,
+			    struct nlmsghdr *hdr)
+{
+	int ret;
+	__u8 encoding_sa = 0xff;
+	__u32 window = -1;
+	struct cipher_args cipher = {0};
+	enum validation_type validate;
+	bool es = false, scb = false, send_sci = false;
+	int replay_protect = -1;
+	struct sci sci = { 0 };
+
+	ret = get_sci_portaddr(&sci, &argc, &argv, true, true);
+	if (ret < 0) {
+		fprintf(stderr, "expected sci\n");
+		return -1;
+	}
+
+	if (ret > 0) {
+		if (sci.sci)
+			addattr_l(hdr, MACSEC_BUFLEN, IFLA_MACSEC_SCI,
+				  &sci.sci, sizeof(sci.sci));
+		else
+			addattr_l(hdr, MACSEC_BUFLEN, IFLA_MACSEC_PORT,
+				  &sci.port, sizeof(sci.port));
+	}
+
+	while (argc > 0) {
+		if (strcmp(*argv, "cipher") == 0) {
+			if (cipher.id)
+				duparg2("cipher", "cipher");
+			NEXT_ARG();
+			if (do_cipher_suite(&cipher, &argc, &argv))
+				return -1;
+		} else if (strcmp(*argv, "encrypt") == 0) {
+			NEXT_ARG();
+			int i;
+
+			ret = one_of("encrypt", *argv, values_on_off,
+				     ARRAY_SIZE(values_on_off), &i);
+			if (ret != 0)
+				return ret;
+			addattr8(hdr, MACSEC_BUFLEN, IFLA_MACSEC_ENCRYPT, !i);
+		} else if (strcmp(*argv, "send_sci") == 0) {
+			NEXT_ARG();
+			int i;
+
+			ret = one_of("send_sci", *argv, values_on_off,
+				     ARRAY_SIZE(values_on_off), &i);
+			if (ret != 0)
+				return ret;
+			send_sci = !i;
+			addattr8(hdr, MACSEC_BUFLEN, IFLA_MACSEC_INC_SCI, send_sci);
+		} else if (strcmp(*argv, "es") == 0) {
+			NEXT_ARG();
+			int i;
+
+			ret = one_of("es", *argv, values_on_off,
+				     ARRAY_SIZE(values_on_off), &i);
+			if (ret != 0)
+				return ret;
+			es = !i;
+			addattr8(hdr, MACSEC_BUFLEN, IFLA_MACSEC_ES, es);
+		} else if (strcmp(*argv, "scb") == 0) {
+			NEXT_ARG();
+			int i;
+
+			ret = one_of("scb", *argv, values_on_off,
+				     ARRAY_SIZE(values_on_off), &i);
+			if (ret != 0)
+				return ret;
+			scb = !i;
+			addattr8(hdr, MACSEC_BUFLEN, IFLA_MACSEC_SCB, scb);
+		} else if (strcmp(*argv, "protect") == 0) {
+			NEXT_ARG();
+			int i;
+
+			ret = one_of("protect", *argv, values_on_off,
+				     ARRAY_SIZE(values_on_off), &i);
+			if (ret != 0)
+				return ret;
+			addattr8(hdr, MACSEC_BUFLEN, IFLA_MACSEC_PROTECT, !i);
+		} else if (strcmp(*argv, "replay") == 0) {
+			NEXT_ARG();
+			int i;
+
+			ret = one_of("replay", *argv, values_on_off,
+				     ARRAY_SIZE(values_on_off), &i);
+			if (ret != 0)
+				return ret;
+			replay_protect = !i;
+		} else if (strcmp(*argv, "window") == 0) {
+			NEXT_ARG();
+			ret = get_u32(&window, *argv, 0);
+			if (ret)
+				invarg("expected replay window size", *argv);
+		} else if (strcmp(*argv, "validate") == 0) {
+			NEXT_ARG();
+			ret = one_of("validate", *argv,
+				     VALIDATE_STR, ARRAY_SIZE(VALIDATE_STR),
+				     (int *)&validate);
+			if (ret != 0)
+				return ret;
+			addattr8(hdr, MACSEC_BUFLEN, IFLA_MACSEC_VALIDATION,
+				 validate);
+		} else if (strcmp(*argv, "encoding") == 0) {
+			if (encoding_sa != 0xff)
+				duparg2("encoding", "encoding");
+			NEXT_ARG();
+			ret = get_an(&encoding_sa, *argv);
+			if (ret)
+				invarg("expected an { 0..3 }", *argv);
+		} else {
+			fprintf(stderr, "macsec: unknown command \"%s\"?\n",
+				*argv);
+			usage(stderr);
+			return -1;
+		}
+
+		argv++; argc--;
+	}
+
+	if (!check_txsc_flags(es, scb, send_sci)) {
+		fprintf(stderr, "invalid combination of send_sci/es/scb\n");
+		return -1;
+	}
+
+	if (window != -1 && replay_protect == -1) {
+		fprintf(stderr, "replay window set, but replay protection not enabled. did you mean 'replay on window %u'?\n", window);
+		return -1;
+	}
+
+	if (cipher.id) {
+		addattr_l(hdr, MACSEC_BUFLEN, IFLA_MACSEC_CIPHER_SUITE,
+			  &cipher.id, sizeof(cipher.id));
+		addattr_l(hdr, MACSEC_BUFLEN, IFLA_MACSEC_ICV_LEN,
+			  &cipher.icv_len, sizeof(cipher.icv_len));
+	}
+
+	if (replay_protect != -1) {
+		addattr32(hdr, MACSEC_BUFLEN, IFLA_MACSEC_WINDOW, window);
+		addattr8(hdr, MACSEC_BUFLEN, IFLA_MACSEC_REPLAY_PROTECT,
+			 replay_protect);
+	}
+
+	if (encoding_sa != 0xff) {
+		addattr_l(hdr, MACSEC_BUFLEN, IFLA_MACSEC_ENCODING_SA,
+			  &encoding_sa, sizeof(encoding_sa));
+	}
+
+	return 0;
+}
+
+static void macsec_print_help(struct link_util *lu, int argc, char **argv,
+			      FILE *f)
+{
+	usage(f);
+}
+
+struct link_util macsec_link_util = {
+	.id = "macsec",
+	.maxattr = IFLA_MACSEC_MAX,
+	.parse_opt = macsec_parse_opt,
+	.print_help = macsec_print_help,
+	.print_opt = macsec_print_opt,
+	.slave = false,
+};
diff --git a/man/man8/Makefile b/man/man8/Makefile
index 2f77640676df..18602f96015a 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -7,7 +7,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-mqprio.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
 	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
-	ip-addrlabel.8 ip-fou.8 ip-gue.8 ip-l2tp.8 \
+	ip-addrlabel.8 ip-fou.8 ip-gue.8 ip-l2tp.8 ip-macsec.8 \
 	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
 	ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
 	ip-tcp_metrics.8 ip-netconf.8 ip-token.8 \
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 4d3234352004..cacb3a896d2f 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -260,6 +260,9 @@ Link types:
 .sp
 .BR geneve
 - GEneric NEtwork Virtualization Encapsulation
+.sp
+.BR macsec
+- Interface for IEEE 802.1AE MAC Security (MACsec)
 .in -8
 
 .TP
@@ -819,6 +822,137 @@ forces the underlying interface into promiscuous mode. Passing the
 using standard tools.
 .in -8
 
+.TP
+MACsec Type Support
+For a link of type
+.I MACsec
+the following additional arguments are supported:
+
+.BI "ip link add link " DEVICE " name " NAME
+.BI type " macsec "
+.R " [ "
+.BI port " PORT "
+.R " | "
+.BI sci " SCI "
+.R " ] [ "
+.BI cipher " CIPHER_SUITE "
+.R " ] ["
+.BI encrypt
+.R " { "
+.BI "on "
+.R " |"
+.BI "off "
+.R " } "
+.R " ] ["
+.BI send_sci
+.R " { "
+.BI "on "
+.R " |"
+.BI "off "
+.R " } "
+.R " ] ["
+.BI es
+.R " { "
+.BI "on "
+.R " |"
+.BI "off "
+.R " } "
+.R " ] ["
+.BI scb
+.R " { "
+.BI "on "
+.R " |"
+.BI "off "
+.R " } "
+.R " ] ["
+.BI protect
+.R " { "
+.BI "on "
+.R " |"
+.BI "off "
+.R " } "
+.R " ] ["
+.BI replay
+.R " { "
+.BI "on "
+.R " |"
+.BI "off "
+.R " } "
+.BI window
+.R " { "
+.BI "0..2^32-1 "
+.R " } "
+.R " ] ["
+.BI validate
+.R " { "
+.BI "strict "
+.R " |"
+.BI "check "
+.R " |"
+.BI "disabled "
+.R " } "
+.R " ] ["
+.BI encoding
+.R " {"
+.BI "0..3 "
+.R " } "
+.R " ]"
+
+.in +8
+.sp
+.BI  port " PORT "
+- sets the port number for this MACsec device.
+
+.sp
+.BI sci " SCI "
+- sets the SCI for this MACsec device.
+
+.sp
+.BI cipher " CIPHER_SUITE "
+- defines the cipher suite to use.
+
+.sp
+.BR "encrypt on " or " encrypt off"
+- switches between authenticated encryption, or authenticity mode only.
+
+.sp
+.BR "send_sci on " or " send_sci off"
+- specifies whether the SCI is included in every packet, or only when it is necessary.
+
+.sp
+.BR "es on " or " es off"
+- sets the End Station bit.
+
+.sp
+.BR "scb on " or " scb off"
+- sets the Single Copy Broadcast bit.
+
+.sp
+.BR "protect on " or " protect off"
+- enables MACsec protection on the device.
+
+.sp
+.BR "replay on " or " replay off"
+- enables replay protection on the device.
+
+.in +8
+
+.sp
+.BI window " SIZE "
+- sets the size of the replay window.
+
+.in -8
+
+.sp
+.BR "validate strict " or " validate check " or " validate disabled"
+- sets the validation mode on the device.
+
+.sp
+.BI encoding " AN "
+- sets the active secure association for transmission.
+
+.in -8
+
 .SS ip link delete - delete virtual link
 
 .TP
diff --git a/man/man8/ip-macsec.8 b/man/man8/ip-macsec.8
new file mode 100644
index 000000000000..1920878571a8
--- /dev/null
+++ b/man/man8/ip-macsec.8
@@ -0,0 +1,110 @@
+.TH IP\-MACSEC 8 "07 Mar 2016" "iproute" "Linux"
+.SH "NAME"
+ip-macsec \- MACsec device configuration
+.SH "SYNOPSIS"
+.BI "ip link add link " DEVICE " name " NAME
+.BR type " macsec "
+.R " [ "
+.R " [ "
+.B cipher " { " default " | " gcm-aes-128 " } "
+.R " ] "
+.B icvlen
+.I ICVLEN
+.R " ] [ "
+.B encrypt " { " on " | " off " } "
+.R " ] [ "
+.B send_sci " { " on " | " off " } "
+.R " ] [ "
+.B es " { " on " | " off " } "
+.R " ] [ "
+.B scb " { " on " | " off " } "
+.R " ] [ "
+.B protect " { " on " | " off " } "
+.R " ] [ "
+.B replay " { " on " | " off " } "
+.R " ] [ "
+.B window
+.I WINDOW
+.R " ] [ "
+.B encoding
+.I SA
+.R " ]"
+
+.BR "ip macsec add"
+.IR DEV
+.B "tx sa { 0..3 } [ OPTS ] key ID KEY"
+.br
+.BR "ip macsec set"
+.IR DEV
+.B "tx sa { 0..3 } [ OPTS ]"
+.br
+.BR "ip macsec del"
+.IR DEV
+.B "tx sa { 0..3 }"
+
+.BR "ip macsec add"
+.IR DEV
+.B "rx SCI [ on | off ]"
+.br
+.BR "ip macsec set"
+.IR DEV
+.B "rx SCI [ on | off ]"
+.br
+.BR "ip macsec del"
+.IR DEV
+.B "rx SCI"
+
+.BR "ip macsec add"
+.IR DEV
+.B "rx SCI [ sa { 0..3 } [ OPTS ] key ID KEY ]"
+.br
+.BR "ip macsec set"
+.IR DEV
+.B "rx SCI sa { 0..3 } [ OPTS ]"
+.br
+.BR "ip macsec del"
+.IR DEV
+.B "rx SCI sa { 0..3 }"
+
+.BR "ip macsec show [ DEV ]"
+
+.IR OPTS " := [ pn <u32> ] [ on | off ]"
+.br
+.IR SCI  " := { sci <u64> | port <u16> address <lladdr> }"
+
+
+.SH "DESCRIPTION"
+The
+.B ip macsec
+commands are used to configure transmit secure associations and receive secure channels and their secure associations on a MACsec device created with the
+.B ip link add
+command using the
+.I macsec
+type.
+
+.SH "EXAMPLES"
+.PP
+.SS Create a MACsec device on link eth0
+.nf
+# ip link add device eth0 macsec0 type macsec port 11 encrypt on
+.PP
+.SS Configure a secure association on that device
+.nf
+# ip macsec add macsec0 tx sa 0 pn 1024 on key 1 81818181818181818181818181818181
+.PP
+.SS Configure a receive channel
+.nf
+# ip macsec add macsec0 rx port 1234 address c6:19:52:8f:e6:a0
+.PP
+.SS Configure a receive association
+.nf
+# ip macsec add macsec0 rx port 1234 address c6:19:52:8f:e6:a0 sa 0 pn 1 on key 0 82828282828282828282828282828282
+.PP
+.SS Display MACsec configuration
+.nf
+# ip macsec show
+.SH "SEE ALSO"
+.br
+.BR ip-link (8)
+.SH "AUTHOR"
+Sabrina Dubroca <sd@queasysnail.net>
-- 
2.7.2
