From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 04/18] ss: Use sockstat->type in all socket types
Date: Fri, 11 Nov 2016 14:10:00 +0100
Message-ID: <20161111131014.21865-5-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44352 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755639AbcKKNK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:10:26 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unix sockets used that field already to hold info about the socket type.
By replicating this approach in all other socket types, we can get rid
of protocol parameter in inet_stats_print() and have sock_state_print()
figure things out by itself.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 124 +++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 70 insertions(+), 54 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index d0b4f879c4d9f..e6053467aaf82 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -793,8 +793,57 @@ struct tcpstat {
 	struct tcp_bbr_info *bbr_info;
 };
 
-static void sock_state_print(struct sockstat *s, const char *sock_name)
+static const char *unix_netid_name(int type)
+{
+	switch (type) {
+	case SOCK_STREAM:
+		return "u_str";
+	case SOCK_SEQPACKET:
+		return "u_seq";
+	case SOCK_DGRAM:
+	default:
+		return "u_dgr";
+	}
+}
+
+static char *proto_name(int protocol)
 {
+	switch (protocol) {
+	case 0:
+		return "raw";
+	case IPPROTO_UDP:
+		return "udp";
+	case IPPROTO_TCP:
+		return "tcp";
+	case IPPROTO_DCCP:
+		return "dccp";
+	}
+
+	return "???";
+}
+
+static void sock_state_print(struct sockstat *s)
+{
+	const char *sock_name;
+
+	switch (s->local.family) {
+	case AF_UNIX:
+		sock_name = unix_netid_name(s->type);
+		break;
+	case AF_INET:
+	case AF_INET6:
+		sock_name = proto_name(s->type);
+		break;
+	case AF_PACKET:
+		sock_name = s->type == SOCK_RAW ? "p_raw" : "p_dgr";
+		break;
+	case AF_NETLINK:
+		sock_name = "nl";
+		break;
+	default:
+		sock_name = "unknown";
+	}
+
 	if (netid_width)
 		printf("%-*s ", netid_width, sock_name);
 	if (state_width)
@@ -1670,27 +1719,11 @@ void *parse_markmask(const char *markmask)
 	return res;
 }
 
-static char *proto_name(int protocol)
-{
-	switch (protocol) {
-	case 0:
-		return "raw";
-	case IPPROTO_UDP:
-		return "udp";
-	case IPPROTO_TCP:
-		return "tcp";
-	case IPPROTO_DCCP:
-		return "dccp";
-	}
-
-	return "???";
-}
-
-static void inet_stats_print(struct sockstat *s, int protocol)
+static void inet_stats_print(struct sockstat *s)
 {
 	char *buf = NULL;
 
-	sock_state_print(s, proto_name(protocol));
+	sock_state_print(s);
 
 	inet_addr_print(&s->local, s->lport, s->iface);
 	inet_addr_print(&s->remote, s->rport, 0);
@@ -1948,8 +1981,9 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 	s.rto	    = (double)rto;
 	s.ssthresh  = s.ssthresh == -1 ? 0 : s.ssthresh;
 	s.rto	    = s.rto != 3 * hz  ? s.rto / hz : 0;
+	s.ss.type   = IPPROTO_TCP;
 
-	inet_stats_print(&s.ss, IPPROTO_TCP);
+	inet_stats_print(&s.ss);
 
 	if (show_options)
 		tcp_timer_print(&s);
@@ -2201,8 +2235,7 @@ static void parse_diag_msg(struct nlmsghdr *nlh, struct sockstat *s)
 }
 
 static int inet_show_sock(struct nlmsghdr *nlh,
-			  struct sockstat *s,
-			  int protocol)
+			  struct sockstat *s)
 {
 	struct rtattr *tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
@@ -2211,9 +2244,9 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (tb[INET_DIAG_PROTOCOL])
-		protocol = *(__u8 *)RTA_DATA(tb[INET_DIAG_PROTOCOL]);
+		s->type = *(__u8 *)RTA_DATA(tb[INET_DIAG_PROTOCOL]);
 
-	inet_stats_print(s, protocol);
+	inet_stats_print(s);
 
 	if (show_options) {
 		struct tcpstat t = {};
@@ -2240,7 +2273,7 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 		}
 	}
 
-	if (show_mem || (show_tcpinfo && protocol != IPPROTO_UDP)) {
+	if (show_mem || (show_tcpinfo && s->type != IPPROTO_UDP)) {
 		printf("\n\t");
 		tcp_show_info(nlh, r, tb);
 	}
@@ -2414,6 +2447,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 		return 0;
 
 	parse_diag_msg(h, &s);
+	s.type = diag_arg->protocol;
 
 	if (diag_arg->f->f && run_ssfilter(diag_arg->f->f, &s) == 0)
 		return 0;
@@ -2428,7 +2462,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 		}
 	}
 
-	err = inet_show_sock(h, &s, diag_arg->protocol);
+	err = inet_show_sock(h, &s);
 	if (err < 0)
 		return err;
 
@@ -2534,11 +2568,12 @@ static int tcp_show_netlink_file(struct filter *f)
 		}
 
 		parse_diag_msg(h, &s);
+		s.type = IPPROTO_TCP;
 
 		if (f && f->f && run_ssfilter(f->f, &s) == 0)
 			continue;
 
-		err = inet_show_sock(h, &s, IPPROTO_TCP);
+		err = inet_show_sock(h, &s);
 		if (err < 0)
 			return err;
 	}
@@ -2657,7 +2692,8 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 	if (n < 9)
 		opt[0] = 0;
 
-	inet_stats_print(&s, dg_proto == UDP_PROTO ? IPPROTO_UDP : 0);
+	s.type = dg_proto == UDP_PROTO ? IPPROTO_UDP : 0;
+	inet_stats_print(&s);
 
 	if (show_details && opt[0])
 		printf(" opt:\"%s\"", opt);
@@ -2758,25 +2794,6 @@ static void unix_list_free(struct sockstat *list)
 	}
 }
 
-static const char *unix_netid_name(int type)
-{
-	const char *netid;
-
-	switch (type) {
-	case SOCK_STREAM:
-		netid = "u_str";
-		break;
-	case SOCK_SEQPACKET:
-		netid = "u_seq";
-		break;
-	case SOCK_DGRAM:
-	default:
-		netid = "u_dgr";
-		break;
-	}
-	return netid;
-}
-
 static bool unix_type_skip(struct sockstat *s, struct filter *f)
 {
 	if (s->type == SOCK_STREAM && !(f->dbs&(1<<UNIX_ST_DB)))
@@ -2839,7 +2856,7 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 				continue;
 		}
 
-		sock_state_print(s, unix_netid_name(s->type));
+		sock_state_print(s);
 
 		sock_addr_print(s->name ?: "*", " ",
 				int_to_str(s->lport, port_name), NULL);
@@ -3058,15 +3075,15 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 	const char *addr, *port;
 	char ll_name[16];
 
+	s->local.family = s->remote.family = AF_PACKET;
+
 	if (f->f) {
-		s->local.family = AF_PACKET;
-		s->remote.family = AF_PACKET;
 		s->local.data[0] = s->prot;
 		if (run_ssfilter(f->f, s) == 0)
 			return 1;
 	}
 
-	sock_state_print(s, s->type == SOCK_RAW ? "p_raw" : "p_dgr");
+	sock_state_print(s);
 
 	if (s->prot == 3)
 		addr = "*";
@@ -3316,10 +3333,9 @@ static int netlink_show_one(struct filter *f,
 	st.state = SS_CLOSE;
 	st.rq	 = rq;
 	st.wq	 = wq;
+	st.local.family = st.remote.family = AF_NETLINK;
 
 	if (f->f) {
-		st.local.family = AF_NETLINK;
-		st.remote.family = AF_NETLINK;
 		st.rport = -1;
 		st.lport = pid;
 		st.local.data[0] = prot;
@@ -3327,7 +3343,7 @@ static int netlink_show_one(struct filter *f,
 			return 1;
 	}
 
-	sock_state_print(&st, "nl");
+	sock_state_print(&st);
 
 	if (resolve_services)
 		prot_name = nl_proto_n2a(prot, prot_buf, sizeof(prot_buf));
-- 
2.10.0
