From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v3 06/10] ss: replaced old output mechanisms with fmt handlers interfaces
Date: Thu, 20 Aug 2015 22:40:17 +0200
Message-ID: <1440103221-21854-7-git-send-email-matthias.tafelmeier@gmx.net>
References: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:57525 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbbHTUkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 16:40:51 -0400
In-Reply-To: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, since the fmt (json, hr) handlers are in place, all can be output via these
newly deviced code parts.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c | 330 +++++++++++++++++++++++++++++---------------------------------
 1 file changed, 152 insertions(+), 178 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 1bc2546..2fbdd7f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -105,6 +105,7 @@ int show_sock_ctx = 0;
 int user_ent_hash_build_init = 0;
 int follow_events = 0;
 int json_output = 0;
+int json_first_elem = 1;
 
 int netid_width;
 int state_width;
@@ -113,6 +114,8 @@ int addr_width;
 int serv_width;
 int screen_width;
 
+enum out_fmt_type fmt_type = FMT_HR;
+
 static const char *TCP_PROTO = "tcp";
 static const char *UDP_PROTO = "udp";
 static const char *RAW_PROTO = "raw";
@@ -346,6 +349,16 @@ static FILE *ephemeral_ports_open(void)
 #define USER_ENT_HASH_SIZE	256
 struct user_ent *user_ent_hash[USER_ENT_HASH_SIZE];
 
+static void json_print_opening(void)
+{
+	if (json_output && json_first_elem) {
+		json_first_elem = 0;
+		printf("{\n");
+	} else if (json_output) {
+		printf(",\n{\n");
+	}
+}
+
 static int user_ent_hashfn(unsigned int ino)
 {
 	int val = (ino >> 24) ^ (ino >> 16) ^ (ino >> 8) ^ ino;
@@ -793,7 +806,8 @@ do_numeric:
 	return buf;
 }
 
-static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex)
+static void inet_addr_print(const inet_prefix *a, int port,
+			unsigned int ifindex, char *peer_kind)
 {
 	char buf[1024];
 	const char *ap = buf;
@@ -821,8 +835,8 @@ static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex
 		est_len -= strlen(ifname) + 1;  /* +1 for percent char */
 	}
 
-	sock_addr_print_width(est_len, ap, ":", serv_width, resolve_service(port),
-			ifname);
+	sock_addr_fmt(ap, est_len, ":", serv_width, resolve_service(port),
+			ifname, peer_kind);
 }
 
 static int inet2_addr_match(const inet_prefix *a, const inet_prefix *p,
@@ -1354,21 +1368,27 @@ static void inet_stats_print(struct sockstat *s, int protocol)
 {
 	char *buf = NULL;
 
-	sock_state_print(s, proto_name(protocol));
+	sock_state_fmt(s, sstate_name, proto_name(protocol),
+				netid_width, state_width);
 
-	inet_addr_print(&s->local, s->lport, s->iface);
-	inet_addr_print(&s->remote, s->rport, 0);
+	if (json_output)
+		printf("\t,\"peers\": {\n");
+
+	inet_addr_print(&s->local, s->lport, s->iface, "local");
+	inet_addr_print(&s->remote, s->rport, 0, "remote");
+	if (json_output)
+		printf("}");
 
 	if (show_proc_ctx || show_sock_ctx) {
 		if (find_entry(s->ino, &buf,
-				(show_proc_ctx & show_sock_ctx) ?
-				PROC_SOCK_CTX : PROC_CTX) > 0) {
-			printf(" users:(%s)", buf);
+			       (show_proc_ctx & show_sock_ctx) ?
+			       PROC_SOCK_CTX : PROC_CTX) > 0) {
+			sock_users_fmt(buf);
 			free(buf);
 		}
 	} else if (show_users) {
 		if (find_entry(s->ino, &buf, USERS) > 0) {
-			printf(" users:(%s)", buf);
+			sock_users_fmt(buf);
 			free(buf);
 		}
 	}
@@ -1472,16 +1492,16 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 	inet_stats_print(&s.ss, IPPROTO_TCP);
 
 	if (show_options)
-		tcp_timer_print(&s);
+		tcp_timer_fmt(&s);
 
 	if (show_details) {
-		sock_details_print(&s.ss);
+		sock_details_fmt(&s.ss, GENERIC_DETAIL, 0, 0);
 		if (opt[0])
-			printf(" opt:\"%s\"", opt);
+			opt_fmt(opt);
 	}
 
 	if (show_tcpinfo)
-		tcp_stats_print(&s);
+		tcp_stats_fmt(&s);
 
 	printf("\n");
 	return 0;
@@ -1525,31 +1545,14 @@ static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 			const struct inet_diag_meminfo *minfo =
 				RTA_DATA(tb[INET_DIAG_MEMINFO]);
 
-			printf(" mem:(r%u,w%u,f%u,t%u)",
-					minfo->idiag_rmem,
-					minfo->idiag_wmem,
-					minfo->idiag_fmem,
-					minfo->idiag_tmem);
+			mem_fmt(minfo);
 		}
 		return;
 	}
 
 	skmeminfo = RTA_DATA(tb[attrtype]);
 
-	printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
-	       skmeminfo[SK_MEMINFO_RMEM_ALLOC],
-	       skmeminfo[SK_MEMINFO_RCVBUF],
-	       skmeminfo[SK_MEMINFO_WMEM_ALLOC],
-	       skmeminfo[SK_MEMINFO_SNDBUF],
-	       skmeminfo[SK_MEMINFO_FWD_ALLOC],
-	       skmeminfo[SK_MEMINFO_WMEM_QUEUED],
-	       skmeminfo[SK_MEMINFO_OPTMEM]);
-
-	if (RTA_PAYLOAD(tb[attrtype]) >=
-		(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
-		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
-
-	printf(")");
+	skmem_fmt(skmeminfo, tb, attrtype);
 }
 
 #define TCPI_HAS_OPT(info, opt) !!(info->tcpi_options & (opt))
@@ -1662,8 +1665,11 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.bytes_received = info->tcpi_bytes_received;
 		s.segs_out = info->tcpi_segs_out;
 		s.segs_in = info->tcpi_segs_in;
-		tcp_stats_print(&s);
-		free(s.dctcp);
+		tcp_stats_fmt(&s);
+		if (s.dctcp)
+			free(s.dctcp);
+		if (s.cong_alg)
+			free(s.cong_alg);
 	}
 }
 
@@ -1687,6 +1693,8 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	s.iface		= r->id.idiag_if;
 	s.sk		= cookie_sk_get(&r->id.idiag_cookie[0]);
 
+	json_print_opening();
+
 	if (s.local.family == AF_INET) {
 		s.local.bytelen = s.remote.bytelen = 4;
 	} else {
@@ -1710,29 +1718,29 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 		t.timer = r->idiag_timer;
 		t.timeout = r->idiag_expires;
 		t.retrans = r->idiag_retrans;
-		tcp_timer_print(&t);
+		tcp_timer_fmt(&t);
 	}
 
 	if (show_details) {
-		sock_details_print(&s);
-		if (s.local.family == AF_INET6 && tb[INET_DIAG_SKV6ONLY]) {
-			unsigned char v6only;
-			v6only = *(__u8 *)RTA_DATA(tb[INET_DIAG_SKV6ONLY]);
-			printf(" v6only:%u", v6only);
-		}
+		sock_details_fmt(&s, GENERIC_DETAIL, 0, 0);
 		if (tb[INET_DIAG_SHUTDOWN]) {
 			unsigned char mask;
 			mask = *(__u8 *)RTA_DATA(tb[INET_DIAG_SHUTDOWN]);
-			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
+			sock_conn_fmt(mask);
 		}
 	}
 
 	if (show_mem || show_tcpinfo) {
-		printf("\n\t");
+		if (!json_output)
+			printf("\n\t");
 		tcp_show_info(nlh, r, tb);
 	}
 
-	printf("\n");
+	if (json_output)
+		printf("}\n");
+	else
+		printf("\n");
+
 	return 0;
 }
 
@@ -2083,7 +2091,10 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 	inet_stats_print(&s, dg_proto == UDP_PROTO ? IPPROTO_UDP : 0);
 
 	if (show_details && opt[0])
-		printf(" opt:\"%s\"", opt);
+		opt_fmt(opt);
+
+	if (json_output)
+		printf("}");
 
 	printf("\n");
 	return 0;
@@ -2260,27 +2271,37 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 				continue;
 		}
 
-		sock_state_print(s, unix_netid_name(s->type));
+		sock_state_fmt(s, sstate_name,
+			unix_netid_name(s->type), netid_width, state_width);
 
-		sock_addr_print(s->name ?: "*", " ",
-				int_to_str(s->lport, port_name), NULL);
-		sock_addr_print(peer, " ", int_to_str(s->rport, port_name),
-				NULL);
+		if (json_output)
+			printf("\t,\"peers\": {\n");
+
+		sock_addr_fmt(s->name ?: "*", addr_width,
+			" ", serv_width,
+			int_to_str(s->lport, port_name),
+				NULL, "local");
+		sock_addr_fmt(peer, addr_width, " ", serv_width,
+				int_to_str(s->rport, port_name),
+				NULL, "remote");
+		if (json_output)
+			printf("}\n");
 
 		if (show_proc_ctx || show_sock_ctx) {
 			if (find_entry(s->ino, &ctx_buf,
-					(show_proc_ctx & show_sock_ctx) ?
-					PROC_SOCK_CTX : PROC_CTX) > 0) {
-				printf(" users:(%s)", ctx_buf);
+				       (show_proc_ctx & show_sock_ctx) ?
+				       PROC_SOCK_CTX : PROC_CTX) > 0) {
+				sock_users_fmt(ctx_buf);
 				free(ctx_buf);
 			}
 		} else if (show_users) {
 			if (find_entry(s->ino, &ctx_buf, USERS) > 0) {
-				printf(" users:(%s)", ctx_buf);
+				sock_users_fmt(ctx_buf);
 				free(ctx_buf);
 			}
 		}
-		printf("\n");
+		if (!json_output)
+			printf("\n");
 	}
 }
 
@@ -2293,7 +2314,9 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	char name[128];
 	struct sockstat stat = { .name = "*", .peer_name = "*" };
 
-	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
+	json_print_opening();
+
+	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr *)(r + 1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	stat.type  = r->udiag_type;
@@ -2326,21 +2349,27 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 		return 0;
 
 	unix_stats_print(&stat, f);
-
-	if (show_mem) {
-		printf("\t");
+if (show_mem) {
+		if (!json_output)
+			printf("\t");
 		print_skmeminfo(tb, UNIX_DIAG_MEMINFO);
 	}
 	if (show_details) {
 		if (tb[UNIX_DIAG_SHUTDOWN]) {
 			unsigned char mask;
 			mask = *(__u8 *)RTA_DATA(tb[UNIX_DIAG_SHUTDOWN]);
-			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
+			sock_conn_fmt(mask);
 		}
 	}
 	if (show_mem || show_details)
-		printf("\n");
+		if (!json_output)
+			printf("\n");
+
+	if (json_output)
+		printf("}\n");
 
+	if (name)
+		free(name);
 	return 0;
 }
 
@@ -2482,7 +2511,8 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 			return 1;
 	}
 
-	sock_state_print(s, s->type == SOCK_RAW ? "p_raw" : "p_dgr");
+	sock_state_fmt(s, sstate_name, s->type == SOCK_RAW ? "p_raw" : "p_dgr",
+					netid_width, state_width);
 
 	if (s->prot == 3)
 		addr = "*";
@@ -2494,25 +2524,35 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 	else
 		port = xll_index_to_name(s->iface);
 
-	sock_addr_print(addr, ":", port, NULL);
-	sock_addr_print("", "*", "", NULL);
+	if (json_output)
+		printf("\t,\"peers\": {\n");
+
+	sock_addr_fmt(addr, addr_width, ":",
+			serv_width, port,
+			NULL, "local");
+	sock_addr_fmt("", addr_width, "*",
+			serv_width, "",
+			NULL, "remote");
+
+	if (json_output)
+		printf("}\n");
 
 	if (show_proc_ctx || show_sock_ctx) {
 		if (find_entry(s->ino, &buf,
-					(show_proc_ctx & show_sock_ctx) ?
-					PROC_SOCK_CTX : PROC_CTX) > 0) {
-			printf(" users:(%s)", buf);
+			       (show_proc_ctx & show_sock_ctx) ?
+			       PROC_SOCK_CTX : PROC_CTX) > 0) {
+			sock_users_fmt(buf);
 			free(buf);
 		}
 	} else if (show_users) {
 		if (find_entry(s->ino, &buf, USERS) > 0) {
-			printf(" users:(%s)", buf);
+			sock_users_fmt(buf);
 			free(buf);
 		}
 	}
 
 	if (show_details)
-		sock_details_print(s);
+		sock_details_fmt(s, GENERIC_DETAIL, 0, 0);
 
 	return 0;
 }
@@ -2529,7 +2569,9 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 	uint32_t fanout = 0;
 	bool has_fanout = false;
 
-	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr*)(r+1),
+	json_print_opening();
+
+	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr *)(r + 1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	/* use /proc/net/packet if all info are not available */
@@ -2569,60 +2611,9 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 	if (packet_stats_print(&stat, f))
 		return 0;
 
-	if (show_details) {
-		if (pinfo) {
-			printf("\n\tver:%d", pinfo->pdi_version);
-			printf(" cpy_thresh:%d", pinfo->pdi_copy_thresh);
-			printf(" flags( ");
-			if (pinfo->pdi_flags & PDI_RUNNING)
-				printf("running");
-			if (pinfo->pdi_flags & PDI_AUXDATA)
-				printf(" auxdata");
-			if (pinfo->pdi_flags & PDI_ORIGDEV)
-				printf(" origdev");
-			if (pinfo->pdi_flags & PDI_VNETHDR)
-				printf(" vnethdr");
-			if (pinfo->pdi_flags & PDI_LOSS)
-				printf(" loss");
-			if (!pinfo->pdi_flags)
-				printf("0");
-			printf(" )");
-		}
-		if (ring_rx) {
-			printf("\n\tring_rx(");
-			packet_show_ring(ring_rx);
-			printf(")");
-		}
-		if (ring_tx) {
-			printf("\n\tring_tx(");
-			packet_show_ring(ring_tx);
-			printf(")");
-		}
-		if (has_fanout) {
-			uint16_t type = (fanout >> 16) & 0xffff;
-
-			printf("\n\tfanout(");
-			printf("id:%d,", fanout & 0xffff);
-			printf("type:");
-
-			if (type == 0)
-				printf("hash");
-			else if (type == 1)
-				printf("lb");
-			else if (type == 2)
-				printf("cpu");
-			else if (type == 3)
-				printf("roll");
-			else if (type == 4)
-				printf("random");
-			else if (type == 5)
-				printf("qm");
-			else
-				printf("0x%x", type);
-
-			printf(")");
-		}
-	}
+	if (show_details)
+		packet_details_fmt(pinfo,
+				ring_rx, ring_tx, fanout, has_fanout);
 
 	if (show_bpf && tb[PACKET_DIAG_FILTER]) {
 		struct sock_filter *fil =
@@ -2630,15 +2621,15 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 		int num = RTA_PAYLOAD(tb[PACKET_DIAG_FILTER]) /
 			  sizeof(struct sock_filter);
 
-		printf("\n\tbpf filter (%d): ", num);
-		while (num) {
-			printf(" 0x%02x %u %u %u,",
-			      fil->code, fil->jt, fil->jf, fil->k);
-			num--;
-			fil++;
-		}
+		bpf_filter_fmt(fil, num);
 	}
-	printf("\n");
+
+	if (json_output)
+		printf("}\n");
+	else
+		printf("\n");
+
+
 	return 0;
 }
 
@@ -2716,6 +2707,7 @@ static int netlink_show_one(struct filter *f,
 	SPRINT_BUF(prot_buf) = {};
 	const char *prot_name;
 	char procname[64] = {};
+	char *rem = "remote";
 
 	st.state = SS_CLOSE;
 	st.rq	 = rq;
@@ -2731,7 +2723,7 @@ static int netlink_show_one(struct filter *f,
 			return 1;
 	}
 
-	sock_state_print(&st, "nl");
+	sock_state_fmt(&st, sstate_name, "nl", netid_width, state_width);
 
 	if (resolve_services)
 		prot_name = nl_proto_n2a(prot, prot_buf, sizeof(prot_buf));
@@ -2763,17 +2755,25 @@ static int netlink_show_one(struct filter *f,
 		int_to_str(pid, procname);
 	}
 
-	sock_addr_print(prot_name, ":", procname, NULL);
+	if (json_output)
+		printf("\t,\"peers\": {\n");
+
+	sock_addr_fmt(prot_name, addr_width, ":", serv_width,
+			procname, NULL, "local");
 
 	if (state == NETLINK_CONNECTED) {
 		char dst_group_buf[30];
 		char dst_pid_buf[30];
-		sock_addr_print(int_to_str(dst_group, dst_group_buf), ":",
-				int_to_str(dst_pid, dst_pid_buf), NULL);
+		sock_addr_fmt(int_to_str(dst_group, dst_group_buf), addr_width,
+				":", serv_width, int_to_str(dst_pid, dst_pid_buf),
+				NULL, rem);
 	} else {
-		sock_addr_print("", "*", "", NULL);
+		sock_addr_fmt("", addr_width, "*", serv_width, "", NULL, rem);
 	}
 
+	if (json_output)
+		printf("}\n");
+
 	char *pid_context = NULL;
 	if (show_proc_ctx) {
 		/* The pid value will either be:
@@ -2787,16 +2787,11 @@ static int netlink_show_one(struct filter *f,
 		else if (pid > 0)
 			getpidcon(pid, &pid_context);
 
-		if (pid_context != NULL) {
-			printf("proc_ctx=%-*s ", serv_width, pid_context);
-			free(pid_context);
-		} else {
-			printf("proc_ctx=%-*s ", serv_width, "unavailable");
-		}
+		proc_fmt(serv_width, pid_context);
 	}
 
 	if (show_details) {
-		printf(" sk=%llx cb=%llx groups=0x%08x", sk, cb, groups);
+		sock_details_fmt(&st, NETLINK_DETAIL, groups, cb);
 	}
 	printf("\n");
 
@@ -2812,7 +2807,9 @@ static int netlink_show_sock(const struct sockaddr_nl *addr,
 	int rq = 0, wq = 0;
 	unsigned long groups = 0;
 
-	parse_rtattr(tb, NETLINK_DIAG_MAX, (struct rtattr*)(r+1),
+	json_print_opening();
+
+	parse_rtattr(tb, NETLINK_DIAG_MAX, (struct rtattr *)(r + 1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (tb[NETLINK_DIAG_GROUPS] && RTA_PAYLOAD(tb[NETLINK_DIAG_GROUPS]))
@@ -2838,6 +2835,9 @@ static int netlink_show_sock(const struct sockaddr_nl *addr,
 		printf("\n");
 	}
 
+	if (json_output)
+		printf("}\n");
+
 	return 0;
 }
 
@@ -3033,7 +3033,7 @@ static int get_sockstat(struct ssummary *s)
 	return 0;
 }
 
-static int print_summary(void)
+static int print_summary(bool has_successor)
 {
 	struct ssummary s;
 	struct snmpstat sn;
@@ -3045,32 +3045,7 @@ static int print_summary(void)
 
 	get_slabstat(&slabstat);
 
-	printf("Total: %d (kernel %d)\n", s.socks, slabstat.socks);
-
-	printf("TCP:   %d (estab %d, closed %d, orphaned %d, synrecv %d, timewait %d/%d), ports %d\n",
-	       s.tcp_total + slabstat.tcp_syns + s.tcp_tws,
-	       sn.tcp_estab,
-	       s.tcp_total - (s.tcp4_hashed+s.tcp6_hashed-s.tcp_tws),
-	       s.tcp_orphans,
-	       slabstat.tcp_syns,
-	       s.tcp_tws, slabstat.tcp_tws,
-	       slabstat.tcp_ports
-	       );
-
-	printf("\n");
-	printf("Transport Total     IP        IPv6\n");
-	printf("*	  %-9d %-9s %-9s\n", slabstat.socks, "-", "-");
-	printf("RAW	  %-9d %-9d %-9d\n", s.raw4+s.raw6, s.raw4, s.raw6);
-	printf("UDP	  %-9d %-9d %-9d\n", s.udp4+s.udp6, s.udp4, s.udp6);
-	printf("TCP	  %-9d %-9d %-9d\n", s.tcp4_hashed+s.tcp6_hashed, s.tcp4_hashed, s.tcp6_hashed);
-	printf("INET	  %-9d %-9d %-9d\n",
-	       s.raw4+s.udp4+s.tcp4_hashed+
-	       s.raw6+s.udp6+s.tcp6_hashed,
-	       s.raw4+s.udp4+s.tcp4_hashed,
-	       s.raw6+s.udp6+s.tcp6_hashed);
-	printf("FRAG	  %-9d %-9d %-9d\n", s.frag4+s.frag6, s.frag4, s.frag6);
-
-	printf("\n");
+	sock_summary_fmt(&s, &sn, &slabstat, has_successor);
 
 	if (json_output && has_successor)
 		printf(",\n");
@@ -3413,11 +3388,10 @@ int main(int argc, char *argv[])
 	argc -= optind;
 	argv += optind;
 
-	if (do_summary) {
-		print_summary();
-		if (do_default && argc == 0)
-			exit(0);
-	}
+	if (json_output)
+		printf("{\n");
+
+
 
 	/* Now parse filter... */
 	if (argc == 0 && filter_fp) {
-- 
1.9.1
