From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v3 2/3] ss: Unify packet stats output from netlink and proc
Date: Sun,  4 Jan 2015 22:18:39 +0200
Message-ID: <1420402720-28767-3-git-send-email-vadim4j@gmail.com>
References: <1420402720-28767-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:61134 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbbADU3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 15:29:06 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so16976719lbv.0
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 12:29:03 -0800 (PST)
In-Reply-To: <1420402720-28767-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Refactored to use one func for output packet stats info
from both /proc and netlink.

Added possibility to get packet stats info from /proc
by setting environment variable PROC_ROOT or PROC_NET_PACKET.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 223 ++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 108 insertions(+), 115 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 4dde080..5058224 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2536,70 +2536,103 @@ static int unix_show(struct filter *f)
 	return 0;
 }
 
-static int packet_show_sock(const struct sockaddr_nl *addr,
-		struct nlmsghdr *nlh, void *arg)
-{
-	struct packet_diag_msg *r = NLMSG_DATA(nlh);
-	struct rtattr *tb[PACKET_DIAG_MAX+1];
-	__u32 rq;
+struct pktstat {
+	uint8_t  type;
+	uint16_t prot;
+	uint32_t iface;
+	int state;
+	uint32_t rq;
+	uid_t uid;
+	ino_t ino;
+};
 
-	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr*)(r+1),
-		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+static int packet_stats_print(struct pktstat *s, const struct filter *f)
+{
+	char *buf = NULL;
 
-	/* use /proc/net/packet if all info are not available */
-	if (!tb[PACKET_DIAG_MEMINFO])
-		return -1;
+	if (f->f) {
+		struct tcpstat tst;
+		tst.local.family = AF_PACKET;
+		tst.remote.family = AF_PACKET;
+		tst.rport = 0;
+		tst.lport = s->iface;
+		tst.local.data[0] = s->prot;
+		tst.remote.data[0] = 0;
+		if (run_ssfilter(f->f, &tst) == 0)
+			return 1;
+	}
 
 	if (netid_width)
 		printf("%-*s ", netid_width,
-				r->pdiag_type == SOCK_RAW ? "p_raw" : "p_dgr");
+				s->type == SOCK_RAW ? "p_raw" : "p_dgr");
 	if (state_width)
 		printf("%-*s ", state_width, "UNCONN");
 
-	if (tb[PACKET_DIAG_MEMINFO]) {
-		__u32 *skmeminfo = RTA_DATA(tb[PACKET_DIAG_MEMINFO]);
-
-		rq = skmeminfo[SK_MEMINFO_RMEM_ALLOC];
-	} else
-		rq = 0;
-	printf("%-6d %-6d ", rq, 0);
-
-	if (r->pdiag_num == 3) {
+	printf("%-6d %-6d ", s->rq, 0);
+	if (s->prot == 3) {
 		printf("%*s:", addr_width, "*");
 	} else {
-		char tb2[16];
+		char tb[16];
 		printf("%*s:", addr_width,
-		       ll_proto_n2a(htons(r->pdiag_num), tb2, sizeof(tb2)));
+				ll_proto_n2a(htons(s->prot), tb, sizeof(tb)));
 	}
-	if (tb[PACKET_DIAG_INFO]) {
-		struct packet_diag_info *pinfo = RTA_DATA(tb[PACKET_DIAG_INFO]);
-
-		if (pinfo->pdi_index == 0)
-			printf("%-*s ", serv_width, "*");
-		else
-			printf("%-*s ", serv_width, xll_index_to_name(pinfo->pdi_index));
-	} else
+	if (s->iface == 0) {
 		printf("%-*s ", serv_width, "*");
+	} else {
+		printf("%-*s ", serv_width, xll_index_to_name(s->iface));
+	}
 
-	printf("%*s*%-*s",
-	       addr_width, "", serv_width, "");
-
-	char *buf = NULL;
+	printf("%*s*%-*s", addr_width, "", serv_width, "");
 
 	if (show_proc_ctx || show_sock_ctx) {
-		if (find_entry(r->pdiag_ino, &buf,
-				(show_proc_ctx & show_sock_ctx) ?
-				PROC_SOCK_CTX : PROC_CTX) > 0) {
+		if (find_entry(s->ino, &buf,
+					(show_proc_ctx & show_sock_ctx) ?
+					PROC_SOCK_CTX : PROC_CTX) > 0) {
 			printf(" users:(%s)", buf);
 			free(buf);
 		}
 	} else if (show_users) {
-		if (find_entry(r->pdiag_ino, &buf, USERS) > 0) {
+		if (find_entry(s->ino, &buf, USERS) > 0) {
 			printf(" users:(%s)", buf);
 			free(buf);
 		}
 	}
 
+	return 0;
+}
+
+static int packet_show_sock(const struct sockaddr_nl *addr,
+		struct nlmsghdr *nlh, void *arg)
+{
+	const struct filter *f = arg;
+	struct packet_diag_msg *r = NLMSG_DATA(nlh);
+	struct rtattr *tb[PACKET_DIAG_MAX+1];
+	struct pktstat stat = {};
+
+	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr*)(r+1),
+		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+
+	/* use /proc/net/packet if all info are not available */
+	if (!tb[PACKET_DIAG_MEMINFO])
+		return -1;
+
+	stat.type = r->pdiag_type;
+	stat.prot = r->pdiag_num;
+	stat.ino = r->pdiag_ino;
+
+	if (tb[PACKET_DIAG_MEMINFO]) {
+		__u32 *skmeminfo = RTA_DATA(tb[PACKET_DIAG_MEMINFO]);
+		stat.rq = skmeminfo[SK_MEMINFO_RMEM_ALLOC];
+	}
+
+	if (tb[PACKET_DIAG_INFO]) {
+		struct packet_diag_info *pinfo = RTA_DATA(tb[PACKET_DIAG_INFO]);
+		stat.iface = pinfo->pdi_index;
+	}
+
+	if (packet_stats_print(&stat, f))
+		return 0;
+
 	if (show_details) {
 		__u32 uid = 0;
 
@@ -2640,94 +2673,54 @@ static int packet_show_netlink(struct filter *f)
 	return handle_netlink_request(f, &req.nlh, sizeof(req), packet_show_sock);
 }
 
+static int packet_show_line(char *buf, const struct filter *f, int fam)
+{
+	unsigned long long sk;
+	struct pktstat stat = {};
+	int type, prot, iface, state, rq, uid, ino;
+
+	sscanf(buf, "%llx %*d %d %x %d %d %u %u %u",
+			&sk,
+			&type, &prot, &iface, &state,
+			&rq, &uid, &ino);
+
+	if (stat.type == SOCK_RAW && !(f->dbs&(1<<PACKET_R_DB)))
+		return 0;
+	if (stat.type == SOCK_DGRAM && !(f->dbs&(1<<PACKET_DG_DB)))
+		return 0;
+
+	stat.type  = type;
+	stat.prot  = prot;
+	stat.iface = iface;
+	stat.state = state;
+	stat.rq    = rq;
+	stat.uid   = uid;
+	stat.ino   = ino;
+	if (packet_stats_print(&stat, f))
+		return 0;
+
+	if (show_details) {
+		printf(" ino=%u uid=%u sk=%llx", ino, uid, sk);
+	}
+	printf("\n");
+	return 0;
+}
 
 static int packet_show(struct filter *f)
 {
 	FILE *fp;
-	char buf[256];
-	int type;
-	int prot;
-	int iface;
-	int state;
-	int rq;
-	int uid;
-	int ino;
-	unsigned long long sk;
 
 	if (preferred_family != AF_PACKET && !(f->states & (1 << SS_CLOSE)))
 		return 0;
 
-	if (packet_show_netlink(f) == 0)
+	if (!getenv("PROC_NET_PACKET") && !getenv("PROC_ROOT") &&
+			packet_show_netlink(f) == 0)
 		return 0;
 
 	if ((fp = net_packet_open()) == NULL)
 		return -1;
-	fgets(buf, sizeof(buf)-1, fp);
-
-	while (fgets(buf, sizeof(buf)-1, fp)) {
-		sscanf(buf, "%llx %*d %d %x %d %d %u %u %u",
-		       &sk,
-		       &type, &prot, &iface, &state,
-		       &rq, &uid, &ino);
-
-		if (type == SOCK_RAW && !(f->dbs&(1<<PACKET_R_DB)))
-			continue;
-		if (type == SOCK_DGRAM && !(f->dbs&(1<<PACKET_DG_DB)))
-			continue;
-		if (f->f) {
-			struct tcpstat tst;
-			tst.local.family = AF_PACKET;
-			tst.remote.family = AF_PACKET;
-			tst.rport = 0;
-			tst.lport = iface;
-			tst.local.data[0] = prot;
-			tst.remote.data[0] = 0;
-			if (run_ssfilter(f->f, &tst) == 0)
-				continue;
-		}
-
-		if (netid_width)
-			printf("%-*s ", netid_width,
-			       type == SOCK_RAW ? "p_raw" : "p_dgr");
-		if (state_width)
-			printf("%-*s ", state_width, "UNCONN");
-		printf("%-6d %-6d ", rq, 0);
-		if (prot == 3) {
-			printf("%*s:", addr_width, "*");
-		} else {
-			char tb[16];
-			printf("%*s:", addr_width,
-			       ll_proto_n2a(htons(prot), tb, sizeof(tb)));
-		}
-		if (iface == 0) {
-			printf("%-*s ", serv_width, "*");
-		} else {
-			printf("%-*s ", serv_width, xll_index_to_name(iface));
-		}
-		printf("%*s*%-*s",
-		       addr_width, "", serv_width, "");
-
-		char *buf = NULL;
-
-		if (show_proc_ctx || show_sock_ctx) {
-			if (find_entry(ino, &buf,
-					(show_proc_ctx & show_sock_ctx) ?
-					PROC_SOCK_CTX : PROC_CTX) > 0) {
-				printf(" users:(%s)", buf);
-				free(buf);
-			}
-		} else if (show_users) {
-			if (find_entry(ino, &buf, USERS) > 0) {
-				printf(" users:(%s)", buf);
-				free(buf);
-			}
-		}
-
-		if (show_details) {
-			printf(" ino=%u uid=%u sk=%llx", ino, uid, sk);
-		}
-		printf("\n");
-	}
+	if (generic_record_read(fp, packet_show_line, f, AF_PACKET))
+		return -1;
 
 	return 0;
 }
-- 
2.1.3
