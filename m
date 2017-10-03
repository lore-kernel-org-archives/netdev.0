From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH iproute2 3/3] ss: add AF_VSOCK support
Date: Tue,  3 Oct 2017 13:57:44 -0400
Message-ID: <20171003175744.24987-4-stefanha@redhat.com>
References: <20171003175744.24987-1-stefanha@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56848 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751172AbdJCR6N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 13:58:13 -0400
In-Reply-To: <20171003175744.24987-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AF_VSOCK address family is a host<->guest communications channel
supported by VMware, KVM, and Hyper-V.  Initial VMware support was
released in Linux 3.9 in 2013 and transports for other hypervisors were
added later.

AF_VSOCK addresses are <u32 cid, u32 port> tuples.  The 32-bit cid
integer is comparable to an IP address.  AF_VSOCK ports work like
TCP/UDP ports.

Both SOCK_STREAM and SOCK_DGRAM socket types are available.

This patch adds AF_VSOCK support to ss(8) so that sockets can be
observed.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 misc/ss.c     | 184 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 man/man8/ss.8 |   8 ++-
 2 files changed, 188 insertions(+), 4 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 12a31c90..164356a0 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -44,6 +44,7 @@
 #include <linux/packet_diag.h>
 #include <linux/netlink_diag.h>
 #include <linux/sctp.h>
+#include <linux/vm_sockets_diag.h>
 
 #define MAGIC_SEQ 123456
 
@@ -126,6 +127,8 @@ enum {
 	PACKET_R_DB,
 	NETLINK_DB,
 	SCTP_DB,
+	VSOCK_ST_DB,
+	VSOCK_DG_DB,
 	MAX_DB
 };
 
@@ -134,6 +137,7 @@ enum {
 #define ALL_DB ((1<<MAX_DB)-1)
 #define INET_L4_DBM ((1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB)|(1<<SCTP_DB))
 #define INET_DBM (INET_L4_DBM | (1<<RAW_DB))
+#define VSOCK_DBM ((1<<VSOCK_ST_DB)|(1<<VSOCK_DG_DB))
 
 enum {
 	SS_UNKNOWN,
@@ -222,6 +226,14 @@ static const struct filter default_dbs[MAX_DB] = {
 		.states   = SS_CONN,
 		.families = FAMILY_MASK(AF_INET) | FAMILY_MASK(AF_INET6),
 	},
+	[VSOCK_ST_DB] = {
+		.states   = SS_CONN,
+		.families = FAMILY_MASK(AF_VSOCK),
+	},
+	[VSOCK_DG_DB] = {
+		.states   = SS_CONN,
+		.families = FAMILY_MASK(AF_VSOCK),
+	},
 };
 
 static const struct filter default_afs[AF_MAX] = {
@@ -245,6 +257,10 @@ static const struct filter default_afs[AF_MAX] = {
 		.dbs    = (1 << NETLINK_DB),
 		.states = (1 << SS_CLOSE),
 	},
+	[AF_VSOCK] = {
+		.dbs    = VSOCK_DBM,
+		.states = SS_CONN,
+	},
 };
 
 static int do_default = 1;
@@ -283,6 +299,8 @@ static void filter_default_dbs(struct filter *f)
 	filter_db_set(f, PACKET_DG_DB);
 	filter_db_set(f, NETLINK_DB);
 	filter_db_set(f, SCTP_DB);
+	filter_db_set(f, VSOCK_ST_DB);
+	filter_db_set(f, VSOCK_DG_DB);
 }
 
 static void filter_states_set(struct filter *f, int states)
@@ -791,6 +809,18 @@ static const char *proto_name(int protocol)
 	return "???";
 }
 
+static const char *vsock_netid_name(int type)
+{
+	switch (type) {
+	case SOCK_STREAM:
+		return "v_str";
+	case SOCK_DGRAM:
+		return "v_dgr";
+	default:
+		return "???";
+	}
+}
+
 static void sock_state_print(struct sockstat *s)
 {
 	const char *sock_name;
@@ -823,6 +853,9 @@ static void sock_state_print(struct sockstat *s)
 	case AF_NETLINK:
 		sock_name = "nl";
 		break;
+	case AF_VSOCK:
+		sock_name = vsock_netid_name(s->type);
+		break;
 	default:
 		sock_name = "unknown";
 	}
@@ -1149,6 +1182,8 @@ static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
 			return s->lport == 0 && s->local.data[0] == 0;
 		if (s->local.family == AF_NETLINK)
 			return s->lport < 0;
+		if (s->local.family == AF_VSOCK)
+			return s->lport > 1023;
 
 		return is_ephemeral(s->lport);
 	}
@@ -1524,6 +1559,15 @@ void *parse_devcond(char *name)
 	return res;
 }
 
+static void vsock_set_inet_prefix(inet_prefix *a, __u32 cid)
+{
+	*a = (inet_prefix){
+		.bytelen = sizeof(cid),
+		.family = AF_VSOCK,
+	};
+	memcpy(a->data, &cid, sizeof(cid));
+}
+
 void *parse_hostcond(char *addr, bool is_port)
 {
 	char *port = NULL;
@@ -1598,6 +1642,37 @@ void *parse_hostcond(char *addr, bool is_port)
 		goto out;
 	}
 
+	if (fam == AF_VSOCK || strncmp(addr, "vsock:", 6) == 0) {
+		__u32 cid = ~(__u32)0;
+
+		a.addr.family = AF_VSOCK;
+		if (strncmp(addr, "vsock:", 6) == 0)
+			addr += 6;
+
+		if (is_port)
+			port = addr;
+		else {
+			port = strchr(addr, ':');
+			if (port) {
+				*port = '\0';
+				port++;
+			}
+		}
+
+		if (port && strcmp(port, "*") &&
+		    get_u32((__u32 *)&a.port, port, 0))
+			return NULL;
+
+		if (addr[0] && strcmp(addr, "*")) {
+			a.addr.bitlen = 32;
+			if (get_u32(&cid, addr, 0))
+				return NULL;
+		}
+		vsock_set_inet_prefix(&a.addr, cid);
+		fam = AF_VSOCK;
+		goto out;
+	}
+
 	if (fam == AF_INET || !strncmp(addr, "inet:", 5)) {
 		fam = AF_INET;
 		if (!strncmp(addr, "inet:", 5))
@@ -3674,6 +3749,88 @@ static int netlink_show(struct filter *f)
 	return 0;
 }
 
+static bool vsock_type_skip(struct sockstat *s, struct filter *f)
+{
+	if (s->type == SOCK_STREAM && !(f->dbs & (1 << VSOCK_ST_DB)))
+		return true;
+	if (s->type == SOCK_DGRAM && !(f->dbs & (1 << VSOCK_DG_DB)))
+		return true;
+	return false;
+}
+
+static void vsock_addr_print(inet_prefix *a, __u32 port)
+{
+	char cid_str[sizeof("4294967295")];
+	char port_str[sizeof("4294967295")];
+	__u32 cid;
+
+	memcpy(&cid, a->data, sizeof(cid));
+
+	if (cid == ~(__u32)0)
+		snprintf(cid_str, sizeof(cid_str), "*");
+	else
+		snprintf(cid_str, sizeof(cid_str), "%u", cid);
+
+	if (port == ~(__u32)0)
+		snprintf(port_str, sizeof(port_str), "*");
+	else
+		snprintf(port_str, sizeof(port_str), "%u", port);
+
+	sock_addr_print(cid_str, ":", port_str, NULL);
+}
+
+static void vsock_stats_print(struct sockstat *s, struct filter *f)
+{
+	sock_state_print(s);
+
+	vsock_addr_print(&s->local, s->lport);
+	vsock_addr_print(&s->remote, s->rport);
+
+	proc_ctx_print(s);
+
+	printf("\n");
+}
+
+static int vsock_show_sock(const struct sockaddr_nl *addr,
+			   struct nlmsghdr *nlh, void *arg)
+{
+	struct filter *f = (struct filter *)arg;
+	struct vsock_diag_msg *r = NLMSG_DATA(nlh);
+	struct sockstat stat = {
+		.type = r->vdiag_type,
+		.lport = r->vdiag_src_port,
+		.rport = r->vdiag_dst_port,
+		.state = r->vdiag_state,
+		.ino = r->vdiag_ino,
+	};
+
+	vsock_set_inet_prefix(&stat.local, r->vdiag_src_cid);
+	vsock_set_inet_prefix(&stat.remote, r->vdiag_dst_cid);
+
+	if (vsock_type_skip(&stat, f))
+		return 0;
+
+	if (f->f && run_ssfilter(f->f, &stat) == 0)
+		return 0;
+
+	vsock_stats_print(&stat, f);
+
+	return 0;
+}
+
+static int vsock_show(struct filter *f)
+{
+	DIAG_REQUEST(req, struct vsock_diag_req r);
+
+	if (!filter_af_get(f, AF_VSOCK))
+		return 0;
+
+	req.r.sdiag_family = AF_VSOCK;
+	req.r.vdiag_states = f->states;
+
+	return handle_netlink_request(f, &req.nlh, sizeof(req), vsock_show_sock);
+}
+
 struct sock_diag_msg {
 	__u8 sdiag_family;
 };
@@ -3694,6 +3851,8 @@ static int generic_show_sock(const struct sockaddr_nl *addr,
 		return packet_show_sock(addr, nlh, arg);
 	case AF_NETLINK:
 		return netlink_show_sock(addr, nlh, arg);
+	case AF_VSOCK:
+		return vsock_show_sock(addr, nlh, arg);
 	default:
 		return -1;
 	}
@@ -3921,14 +4080,15 @@ static void _usage(FILE *dest)
 "   -d, --dccp          display only DCCP sockets\n"
 "   -w, --raw           display only RAW sockets\n"
 "   -x, --unix          display only Unix domain sockets\n"
+"       --vsock         display only vsock sockets\n"
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
-"       FAMILY := {inet|inet6|link|unix|netlink|help}\n"
+"       FAMILY := {inet|inet6|link|unix|netlink|vsock|help}\n"
 "\n"
 "   -K, --kill          forcibly close sockets, display what was closed\n"
 "   -H, --no-header     Suppress header line\n"
 "\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
-"       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink}[,QUERY]\n"
+"       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink|vsock_stream|vsock_dgram}[,QUERY]\n"
 "\n"
 "   -D, --diag=FILE     Dump raw information about TCP sockets to FILE\n"
 "   -F, --filter=FILE   read filter information from FILE\n"
@@ -4001,6 +4161,9 @@ static int scan_state(const char *state)
 	exit(-1);
 }
 
+/* Values 'v' and 'V' are already used so a non-character is used */
+#define OPT_VSOCK 256
+
 static const struct option long_opts[] = {
 	{ "numeric", 0, 0, 'n' },
 	{ "resolve", 0, 0, 'r' },
@@ -4017,6 +4180,7 @@ static const struct option long_opts[] = {
 	{ "udp", 0, 0, 'u' },
 	{ "raw", 0, 0, 'w' },
 	{ "unix", 0, 0, 'x' },
+	{ "vsock", 0, 0, OPT_VSOCK },
 	{ "all", 0, 0, 'a' },
 	{ "listening", 0, 0, 'l' },
 	{ "ipv4", 0, 0, '4' },
@@ -4102,6 +4266,9 @@ int main(int argc, char *argv[])
 		case 'x':
 			filter_af_set(&current_filter, AF_UNIX);
 			break;
+		case OPT_VSOCK:
+			filter_af_set(&current_filter, AF_VSOCK);
+			break;
 		case 'a':
 			state_filter = SS_ALL;
 			break;
@@ -4128,6 +4295,8 @@ int main(int argc, char *argv[])
 				filter_af_set(&current_filter, AF_UNIX);
 			else if (strcmp(optarg, "netlink") == 0)
 				filter_af_set(&current_filter, AF_NETLINK);
+			else if (strcmp(optarg, "vsock") == 0)
+				filter_af_set(&current_filter, AF_VSOCK);
 			else if (strcmp(optarg, "help") == 0)
 				help();
 			else {
@@ -4193,6 +4362,15 @@ int main(int argc, char *argv[])
 					filter_db_set(&current_filter, PACKET_DG_DB);
 				} else if (strcmp(p, "netlink") == 0) {
 					filter_db_set(&current_filter, NETLINK_DB);
+				} else if (strcmp(p, "vsock") == 0) {
+					filter_db_set(&current_filter, VSOCK_ST_DB);
+					filter_db_set(&current_filter, VSOCK_DG_DB);
+				} else if (strcmp(p, "vsock_stream") == 0 ||
+					   strcmp(p, "v_str") == 0) {
+					filter_db_set(&current_filter, VSOCK_ST_DB);
+				} else if (strcmp(p, "vsock_dgram") == 0 ||
+					   strcmp(p, "v_dgr") == 0) {
+					filter_db_set(&current_filter, VSOCK_DG_DB);
 				} else {
 					fprintf(stderr, "ss: \"%s\" is illegal socket table id\n", p);
 					usage();
@@ -4408,6 +4586,8 @@ int main(int argc, char *argv[])
 		dccp_show(&current_filter);
 	if (current_filter.dbs & (1<<SCTP_DB))
 		sctp_show(&current_filter);
+	if (current_filter.dbs & VSOCK_DBM)
+		vsock_show(&current_filter);
 
 	if (show_users || show_proc_ctx || show_sock_ctx)
 		user_ent_destroy();
diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 3bec97f0..3af509e9 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -125,14 +125,18 @@ Display Unix domain sockets (alias for -f unix).
 .B \-S, \-\-sctp
 Display SCTP sockets.
 .TP
+.B \-\-vsock
+Display vsock sockets (alias for -f vsock).
+.TP
 .B \-f FAMILY, \-\-family=FAMILY
 Display sockets of type FAMILY.
-Currently the following families are supported: unix, inet, inet6, link, netlink.
+Currently the following families are supported: unix, inet, inet6, link, netlink, vsock.
 .TP
 .B \-A QUERY, \-\-query=QUERY, \-\-socket=QUERY
 List of socket tables to dump, separated by commas. The following identifiers
 are understood: all, inet, tcp, udp, raw, unix, packet, netlink, unix_dgram,
-unix_stream, unix_seqpacket, packet_raw, packet_dgram, dccp, sctp.
+unix_stream, unix_seqpacket, packet_raw, packet_dgram, dccp, sctp,
+vsock_stream, vsock_dgram.
 .TP
 .B \-D FILE, \-\-diag=FILE
 Do not display anything, just dump raw information about TCP sockets to FILE after applying filters. If FILE is - stdout is used.
-- 
2.13.6
