From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] ss: Add support for SCTP protocol
Date: Sat, 30 Jul 2016 00:27:20 +0200
Message-ID: <1469831240-30322-3-git-send-email-phil@nwl.cc>
References: <1469831240-30322-1-git-send-email-phil@nwl.cc>
Cc: Xin Long <lucien.xin@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60649 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389AbcG2W1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 18:27:40 -0400
In-Reply-To: <1469831240-30322-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes use of the sctp_diag interface recently added to the kernel.

Joint work with Xin Long who provided the PoC implementation which I
merely polished up a bit.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 212 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 204 insertions(+), 8 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index e758f5720a452..6a8f65af259f9 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -42,6 +42,7 @@
 #include <linux/filter.h>
 #include <linux/packet_diag.h>
 #include <linux/netlink_diag.h>
+#include <linux/sctp.h>
 
 #define MAGIC_SEQ 123456
 
@@ -101,6 +102,7 @@ int show_header = 1;
 /* If show_users & show_proc_ctx only do user_ent_hash_build() once */
 int user_ent_hash_build_init;
 int follow_events;
+int sctp_ino;
 
 int netid_width;
 int state_width;
@@ -110,6 +112,7 @@ int serv_width;
 int screen_width;
 
 static const char *TCP_PROTO = "tcp";
+static const char *SCTP_PROTO = "sctp";
 static const char *UDP_PROTO = "udp";
 static const char *RAW_PROTO = "raw";
 static const char *dg_proto;
@@ -125,13 +128,14 @@ enum {
 	PACKET_DG_DB,
 	PACKET_R_DB,
 	NETLINK_DB,
+	SCTP_DB,
 	MAX_DB
 };
 
 #define PACKET_DBM ((1<<PACKET_DG_DB)|(1<<PACKET_R_DB))
 #define UNIX_DBM ((1<<UNIX_DG_DB)|(1<<UNIX_ST_DB)|(1<<UNIX_SQ_DB))
 #define ALL_DB ((1<<MAX_DB)-1)
-#define INET_DBM ((1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB)|(1<<RAW_DB))
+#define INET_DBM ((1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB)|(1<<RAW_DB)|(1<<SCTP_DB))
 
 enum {
 	SS_UNKNOWN,
@@ -149,6 +153,17 @@ enum {
 	SS_MAX
 };
 
+enum {
+	SCTP_STATE_CLOSED		= 0,
+	SCTP_STATE_COOKIE_WAIT		= 1,
+	SCTP_STATE_COOKIE_ECHOED	= 2,
+	SCTP_STATE_ESTABLISHED		= 3,
+	SCTP_STATE_SHUTDOWN_PENDING	= 4,
+	SCTP_STATE_SHUTDOWN_SENT	= 5,
+	SCTP_STATE_SHUTDOWN_RECEIVED	= 6,
+	SCTP_STATE_SHUTDOWN_ACK_SENT	= 7,
+};
+
 #define SS_ALL ((1 << SS_MAX) - 1)
 #define SS_CONN (SS_ALL & ~((1<<SS_LISTEN)|(1<<SS_CLOSE)|(1<<SS_TIME_WAIT)|(1<<SS_SYN_RECV)))
 
@@ -203,6 +218,10 @@ static const struct filter default_dbs[MAX_DB] = {
 		.states   = (1 << SS_CLOSE),
 		.families = (1 << AF_NETLINK),
 	},
+	[SCTP_DB] = {
+		.states   = SS_CONN,
+		.families = (1 << AF_INET) | (1 << AF_INET6),
+	},
 };
 
 static const struct filter default_afs[AF_MAX] = {
@@ -263,6 +282,7 @@ static void filter_default_dbs(struct filter *f)
 	filter_db_set(f, PACKET_R_DB);
 	filter_db_set(f, PACKET_DG_DB);
 	filter_db_set(f, NETLINK_DB);
+	filter_db_set(f, SCTP_DB);
 }
 
 static void filter_states_set(struct filter *f, int states)
@@ -704,6 +724,17 @@ static const char *sstate_name[] = {
 	[SS_CLOSING] = "CLOSING",
 };
 
+static const char *sctp_sstate_name[] = {
+	[SCTP_STATE_CLOSED] = "CLOSED",
+	[SCTP_STATE_COOKIE_WAIT] = "COOKIE_WAIT",
+	[SCTP_STATE_COOKIE_ECHOED] = "COOKIE_ECHOED",
+	[SCTP_STATE_ESTABLISHED] = "ESTAB",
+	[SCTP_STATE_SHUTDOWN_PENDING] = "SHUTDOWN_PENDING",
+	[SCTP_STATE_SHUTDOWN_SENT] = "SHUTDOWN_SENT",
+	[SCTP_STATE_SHUTDOWN_RECEIVED] = "SHUTDOWN_RECEIVED",
+	[SCTP_STATE_SHUTDOWN_ACK_SENT] = "ACK_SENT",
+};
+
 static const char *sstate_namel[] = {
 	"UNKNOWN",
 	[SS_ESTABLISHED] = "established",
@@ -789,12 +820,30 @@ struct tcpstat {
 	struct dctcpstat    *dctcp;
 };
 
+/* SCTP assocs share the same inode number with their parent endpoint. So if we
+ * have seen the inode number before, it must be an assoc instead of the next
+ * endpoint. */
+static bool is_sctp_assoc(struct sockstat *s, const char *sock_name)
+{
+	if (strcmp(sock_name, "sctp"))
+		return false;
+	if (!sctp_ino || sctp_ino != s->ino)
+		return false;
+	return true;
+}
+
 static void sock_state_print(struct sockstat *s, const char *sock_name)
 {
 	if (netid_width)
-		printf("%-*s ", netid_width, sock_name);
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[s->state]);
+		printf("%-*s ", netid_width,
+		       is_sctp_assoc(s, sock_name) ? "" : sock_name);
+	if (state_width) {
+		if (is_sctp_assoc(s, sock_name))
+			printf("`- %-*s ", state_width - 3,
+			       sctp_sstate_name[s->state]);
+		else
+			printf("%-*s ", state_width, sstate_name[s->state]);
+	}
 
 	printf("%-6d %-6d ", s->rq, s->wq);
 }
@@ -901,6 +950,8 @@ static void init_service_resolver(void)
 			c->proto = TCP_PROTO;
 		else if (strcmp(proto, UDP_PROTO) == 0)
 			c->proto = UDP_PROTO;
+		else if (strcmp(proto, SCTP_PROTO) == 0)
+			c->proto = SCTP_PROTO;
 		else
 			c->proto = NULL;
 		c->next = rlist;
@@ -1628,6 +1679,8 @@ static char *proto_name(int protocol)
 		return "udp";
 	case IPPROTO_TCP:
 		return "tcp";
+	case IPPROTO_SCTP:
+		return "sctp";
 	case IPPROTO_DCCP:
 		return "dccp";
 	}
@@ -1720,6 +1773,56 @@ static char *sprint_bw(char *buf, double bw)
 	return buf;
 }
 
+static void sctp_stats_print(struct sctp_info *s)
+{
+	if (s->sctpi_tag)
+		printf(" tag:%x", s->sctpi_tag);
+	if (s->sctpi_state)
+		printf(" state:%s", sctp_sstate_name[s->sctpi_state]);
+	if (s->sctpi_rwnd)
+		printf(" rwnd:%d", s->sctpi_rwnd);
+	if (s->sctpi_unackdata)
+		printf(" unackdata:%d", s->sctpi_unackdata);
+	if (s->sctpi_penddata)
+		printf(" penddata:%d", s->sctpi_penddata);
+	if (s->sctpi_instrms)
+		printf(" instrms:%d", s->sctpi_instrms);
+	if (s->sctpi_outstrms)
+		printf(" outstrms:%d", s->sctpi_outstrms);
+	if (s->sctpi_inqueue)
+		printf(" inqueue:%d", s->sctpi_inqueue);
+	if (s->sctpi_outqueue)
+		printf(" outqueue:%d", s->sctpi_outqueue);
+	if (s->sctpi_overall_error)
+		printf(" overerr:%d", s->sctpi_overall_error);
+	if (s->sctpi_max_burst)
+		printf(" maxburst:%d", s->sctpi_max_burst);
+	if (s->sctpi_maxseg)
+		printf(" maxseg:%d", s->sctpi_maxseg);
+	if (s->sctpi_peer_rwnd)
+		printf(" prwnd:%d", s->sctpi_peer_rwnd);
+	if (s->sctpi_peer_tag)
+		printf(" ptag:%x", s->sctpi_peer_tag);
+	if (s->sctpi_peer_capable)
+		printf(" pcapable:%d", s->sctpi_peer_capable);
+	if (s->sctpi_peer_sack)
+		printf(" psack:%d", s->sctpi_peer_sack);
+	if (s->sctpi_s_autoclose)
+		printf(" autoclose:%d", s->sctpi_s_autoclose);
+	if (s->sctpi_s_adaptation_ind)
+		printf(" adapind:%d", s->sctpi_s_adaptation_ind);
+	if (s->sctpi_s_pd_point)
+		printf(" pdpoint:%d", s->sctpi_s_pd_point);
+	if (s->sctpi_s_nodelay)
+		printf(" nodealy:%d", s->sctpi_s_nodelay);
+	if (s->sctpi_s_disable_fragments)
+		printf(" nofrag:%d", s->sctpi_s_disable_fragments);
+	if (s->sctpi_s_v4mapped)
+		printf(" v4mapped:%d", s->sctpi_s_v4mapped);
+	if (s->sctpi_s_frag_interleave)
+		printf(" fraginl:%d", s->sctpi_s_frag_interleave);
+}
+
 static void tcp_stats_print(struct tcpstat *s)
 {
 	char b1[64];
@@ -1832,6 +1935,13 @@ static void tcp_timer_print(struct tcpstat *s)
 	}
 }
 
+static void sctp_timer_print(struct tcpstat *s)
+{
+	if (s->timer)
+		printf(" timer:(T3_RTX,%s,%d)",
+		       print_ms_timer(s->timeout), s->retrans);
+}
+
 static int tcp_show_line(char *line, const struct filter *f, int family)
 {
 	int rto = 0, ato = 0;
@@ -2087,6 +2197,64 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 	}
 }
 
+static const char *format_host_sa(struct sockaddr_storage *sa)
+{
+	union {
+		struct sockaddr_in sin;
+		struct sockaddr_in6 sin6;
+	} *saddr = (void *)sa;
+
+	switch (sa->ss_family) {
+	case AF_INET:
+		return format_host(AF_INET, 4, &saddr->sin.sin_addr);
+	case AF_INET6:
+		return format_host(AF_INET6, 16, &saddr->sin6.sin6_addr);
+	default:
+		return "";
+	}
+}
+
+static void sctp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
+		struct rtattr *tb[])
+{
+	struct sockaddr_storage *sa;
+	int len;
+
+	print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
+
+	if (tb[INET_DIAG_LOCALS]) {
+		len = RTA_PAYLOAD(tb[INET_DIAG_LOCALS]);
+		sa = RTA_DATA(tb[INET_DIAG_LOCALS]);
+
+		printf("locals:%s", format_host_sa(sa));
+		for (sa++, len -= sizeof(*sa); len > 0; sa++, len -= sizeof(*sa))
+			printf(",%s", format_host_sa(sa));
+
+	}
+	if (tb[INET_DIAG_PEERS]) {
+		len = RTA_PAYLOAD(tb[INET_DIAG_PEERS]);
+		sa = RTA_DATA(tb[INET_DIAG_PEERS]);
+
+		printf(" peers:%s", format_host_sa(sa));
+		for (sa++, len -= sizeof(*sa); len > 0; sa++, len -= sizeof(*sa))
+			printf(",%s", format_host_sa(sa));
+	}
+	if (tb[INET_DIAG_INFO]) {
+		struct sctp_info *info;
+		len = RTA_PAYLOAD(tb[INET_DIAG_INFO]);
+
+		/* workaround for older kernels with less fields */
+		if (len < sizeof(*info)) {
+			info = alloca(sizeof(*info));
+			memcpy(info, RTA_DATA(tb[INET_DIAG_INFO]), len);
+			memset((char *)info + len, 0, sizeof(*info) - len);
+		} else
+			info = RTA_DATA(tb[INET_DIAG_INFO]);
+
+		sctp_stats_print(info);
+	}
+}
+
 static void parse_diag_msg(struct nlmsghdr *nlh, struct sockstat *s)
 {
 	struct rtattr *tb[INET_DIAG_MAX+1];
@@ -2136,7 +2304,10 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 		t.timer = r->idiag_timer;
 		t.timeout = r->idiag_expires;
 		t.retrans = r->idiag_retrans;
-		tcp_timer_print(&t);
+		if (protocol == IPPROTO_SCTP)
+			sctp_timer_print(&t);
+		else
+			tcp_timer_print(&t);
 	}
 
 	if (show_details) {
@@ -2157,8 +2328,12 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 
 	if (show_mem || show_tcpinfo) {
 		printf("\n\t");
-		tcp_show_info(nlh, r, tb);
+		if (protocol == IPPROTO_SCTP)
+			sctp_show_info(nlh, r, tb);
+		else
+			tcp_show_info(nlh, r, tb);
 	}
+	sctp_ino = s->ino;
 
 	printf("\n");
 	return 0;
@@ -2542,6 +2717,17 @@ outerr:
 	} while (0);
 }
 
+static int sctp_show(struct filter *f)
+{
+	if (!filter_af_get(f, AF_INET) && !filter_af_get(f, AF_INET6))
+		return 0;
+
+	if (!getenv("PROC_NET_SCTP") && !getenv("PROC_ROOT")
+	    && inet_show_netlink(f, NULL, IPPROTO_SCTP) == 0)
+		return 0;
+
+	return 0;
+}
 
 static int dgram_show_line(char *line, const struct filter *f, int family)
 {
@@ -3653,6 +3839,7 @@ static void _usage(FILE *dest)
 "   -6, --ipv6          display only IP version 6 sockets\n"
 "   -0, --packet        display PACKET sockets\n"
 "   -t, --tcp           display only TCP sockets\n"
+"   -S, --sctp          display only SCTP sockets\n"
 "   -u, --udp           display only UDP sockets\n"
 "   -d, --dccp          display only DCCP sockets\n"
 "   -w, --raw           display only RAW sockets\n"
@@ -3735,6 +3922,7 @@ static const struct option long_opts[] = {
 	{ "events", 0, 0, 'E' },
 	{ "dccp", 0, 0, 'd' },
 	{ "tcp", 0, 0, 't' },
+	{ "sctp", 0, 0, 'S' },
 	{ "udp", 0, 0, 'u' },
 	{ "raw", 0, 0, 'w' },
 	{ "unix", 0, 0, 'x' },
@@ -3770,7 +3958,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:KH",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:KHS",
 				 long_opts, NULL)) != EOF) {
 		switch (ch) {
 		case 'n':
@@ -3809,6 +3997,9 @@ int main(int argc, char *argv[])
 		case 't':
 			filter_db_set(&current_filter, TCP_DB);
 			break;
+		case 'S':
+			filter_db_set(&current_filter, SCTP_DB);
+			break;
 		case 'u':
 			filter_db_set(&current_filter, UDP_DB);
 			break;
@@ -3873,6 +4064,7 @@ int main(int argc, char *argv[])
 					filter_db_set(&current_filter, UDP_DB);
 					filter_db_set(&current_filter, DCCP_DB);
 					filter_db_set(&current_filter, TCP_DB);
+					filter_db_set(&current_filter, SCTP_DB);
 					filter_db_set(&current_filter, RAW_DB);
 				} else if (strcmp(p, "udp") == 0) {
 					filter_db_set(&current_filter, UDP_DB);
@@ -3880,6 +4072,8 @@ int main(int argc, char *argv[])
 					filter_db_set(&current_filter, DCCP_DB);
 				} else if (strcmp(p, "tcp") == 0) {
 					filter_db_set(&current_filter, TCP_DB);
+				} else if (strcmp(p, "sctp") == 0) {
+					filter_db_set(&current_filter, SCTP_DB);
 				} else if (strcmp(p, "raw") == 0) {
 					filter_db_set(&current_filter, RAW_DB);
 				} else if (strcmp(p, "unix") == 0) {
@@ -4004,7 +4198,7 @@ int main(int argc, char *argv[])
 	filter_merge_defaults(&current_filter);
 
 	if (resolve_services && resolve_hosts &&
-	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
+	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB)|(1<<SCTP_DB))))
 		init_service_resolver();
 
 
@@ -4120,6 +4314,8 @@ int main(int argc, char *argv[])
 		tcp_show(&current_filter, IPPROTO_TCP);
 	if (current_filter.dbs & (1<<DCCP_DB))
 		tcp_show(&current_filter, IPPROTO_DCCP);
+	if (current_filter.dbs & (1<<SCTP_DB))
+		sctp_show(&current_filter);
 
 	if (show_users || show_proc_ctx || show_sock_ctx)
 		user_ent_destroy();
-- 
2.8.2
