From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH 02/10] ss: created formatters for json and hr
Date: Mon, 10 Aug 2015 01:13:18 +0200
Message-ID: <1439162006-11421-3-git-send-email-matthias.tafelmeier@gmx.net>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:62227 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472AbbHIXNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2015 19:13:38 -0400
In-Reply-To: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a central formatter module that acts as a kind of
switch. From there, more specific handler modules for the certain output
formats are called. Up to now, humand readable and json do exist.

That prepares ss for potential output format extensions in the future.
With the help of such an apparatus, extensions should get done
conveniently as well.

For a completely new output format, a new handler module must be created
and should be constructed like its relatives (for ex.: ss_json_fmt.c).
Moreover, its functions need to get registered with the central output
distributor. The latter can be done in that the according fmt_op_hub of
the new handler module is registered in the fmt_op_hub array.

Solely extending tcp_stats output shall boil down to extending the
according handler function with the new predicate and its value. The
context of the output subparts are important. With JSON, for instance,
you have to ensure, that the comas are set at the right places.

Further, an interim solution for all tcp_stats extensions is to check
that all those muddle through to all fmt handlers by STATICAL_ASSERTING
that.  Interim is the solution, since a central structure would be much
more worthwile for maintainability and this method does not ensure
correct output fmt extension in a foolproof manner.

Examples for tcp_stats out extension:

ss_json_fmt.c:

To add a new foo_param in tcp_stats for output (Pseudocode):
	[...]
	if (s->has_ts_opt) {
		printf(",\n%s\"ts\": \"true\"", indent1);
	}
	if (s->has_sack_opt) {
		printf(",\n%s\"sack\": \"true\"", indent1);
	}
	if (s->has_ecn_opt) {
		printf(",\n%s\"ecn\": \"true\"", indent1);
	}
	[...]

	-> macro to ensure statically no new tcp_stats info will be forgotten in
	-> any of the fmt handlers
	CHECK_FMT_ADAPT(s->new_foo_pred, s, error_msg_adapation_issue);

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/Makefile      |   2 +-
 misc/ss_hr_fmt.c   | 258 ++++++++++++++++++++++++++++++++++
 misc/ss_hr_fmt.h   |   9 ++
 misc/ss_json_fmt.c | 399 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 misc/ss_json_fmt.h |  24 ++++
 misc/ss_out_fmt.c  | 127 +++++++++++++++++
 misc/ss_out_fmt.h  |  82 +++++++++++
 7 files changed, 900 insertions(+), 1 deletion(-)
 create mode 100644 misc/ss_hr_fmt.c
 create mode 100644 misc/ss_hr_fmt.h
 create mode 100644 misc/ss_json_fmt.c
 create mode 100644 misc/ss_json_fmt.h
 create mode 100644 misc/ss_out_fmt.c
 create mode 100644 misc/ss_out_fmt.h

diff --git a/misc/Makefile b/misc/Makefile
index b7ecba9..fb67ead 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -1,4 +1,4 @@
-SSOBJ=ss.o ssfilter.o
+SSOBJ=ss.o ssfilter.o ss_hr_fmt.o ss_json_fmt.o ss_out_fmt.o
 LNSTATOBJ=lnstat.o lnstat_util.o
 
 TARGETS=ss nstat ifstat rtacct arpd lnstat
diff --git a/misc/ss_hr_fmt.c b/misc/ss_hr_fmt.c
new file mode 100644
index 0000000..6955ea5
--- /dev/null
+++ b/misc/ss_hr_fmt.c
@@ -0,0 +1,258 @@
+#include <linux/sock_diag.h>
+#include <linux/rtnetlink.h>
+#include "ss_out_fmt.h"
+#include "ss_types.h"
+#include "ss_hr_fmt.h"
+
+static void tcp_stats_hr_fmt(struct tcpstat *s)
+{
+	char b1[64];
+
+	if (s->has_ts_opt)
+		printf(" ts");
+	if (s->has_sack_opt)
+		printf(" sack");
+	if (s->has_ecn_opt)
+		printf(" ecn");
+	if (s->has_ecnseen_opt)
+		printf(" ecnseen");
+	if (s->has_fastopen_opt)
+		printf(" fastopen");
+	if (s->cong_alg)
+		printf(" %s", s->cong_alg);
+	if (s->has_wscale_opt)
+		printf(" wscale:%d,%d", s->snd_wscale, s->rcv_wscale);
+	if (s->rto)
+		printf(" rto:%g", s->rto);
+	if (s->backoff)
+		printf(" backoff:%u", s->backoff);
+	if (s->rtt)
+		printf(" rtt:%g/%g", s->rtt, s->rttvar);
+	if (s->ato)
+		printf(" ato:%g", s->ato);
+
+	if (s->qack)
+		printf(" qack:%d", s->qack);
+	if (s->qack & 1)
+		printf(" bidir");
+
+	if (s->mss)
+		printf(" mss:%d", s->mss);
+	if (s->cwnd)
+		printf(" cwnd:%d", s->cwnd);
+	if (s->ssthresh)
+		printf(" ssthresh:%d", s->ssthresh);
+
+	if (s->dctcp && s->dctcp->enabled) {
+		struct dctcpstat *dctcp = s->dctcp;
+
+		printf(" dctcp:(ce_state:%u,alpha:%u,ab_ecn:%u,ab_tot:%u)",
+		dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
+		dctcp->ab_tot);
+	} else if (s->dctcp) {
+		printf(" dctcp:fallback_mode");
+	}
+
+	if (s->send_bps)
+		printf(" send %sbps", sprint_bw(b1, s->send_bps));
+	if (s->lastsnd)
+		printf(" lastsnd:%u", s->lastsnd);
+	if (s->lastrcv)
+		printf(" lastrcv:%u", s->lastrcv);
+	if (s->lastack)
+		printf(" lastack:%u", s->lastack);
+
+	if (s->pacing_rate) {
+		printf(" pacing_rate %sbps", sprint_bw(b1, s->pacing_rate));
+		if (s->pacing_rate_max)
+			printf("/%sbps", sprint_bw(b1, s->pacing_rate_max));
+	}
+
+	if (s->unacked)
+		printf(" unacked:%u", s->unacked);
+	if (s->retrans || s->retrans_total)
+		printf(" retrans:%u/%u", s->retrans, s->retrans_total);
+	if (s->lost)
+		printf(" lost:%u", s->lost);
+	if (s->sacked && s->ss.state != SS_LISTEN)
+		printf(" sacked:%u", s->sacked);
+	if (s->fackets)
+		printf(" fackets:%u", s->fackets);
+	if (s->reordering != 3)
+		printf(" reordering:%d", s->reordering);
+	if (s->rcv_rtt)
+		printf(" rcv_rtt:%g", s->rcv_rtt);
+
+	CHECK_FMT_ADAPT(s->rcv_space, s,
+	hr_handler_must_be_adapted_accordingly_when_json_fmt_is_extended);
+}
+
+static void tcp_timer_hr_fmt(struct tcpstat *s)
+{
+	if (s->timer) {
+		if (s->timer > 4)
+			s->timer = 5;
+		printf(" timer:(%s,%s,%d)",
+		ss_timer_name[s->timer],
+		print_ms_timer(s->timeout), s->retrans);
+	}
+}
+
+static void sock_state_hr_fmt(struct sockstat *s, const char **sstate_name,
+		const char *sock_name, int netid_width, int state_width)
+{
+	if (netid_width)
+		printf("%-*s ", netid_width, sock_name);
+	if (state_width)
+		printf("%-*s ", state_width, sstate_name[s->state]);
+
+	printf("%-6d %-6d ", s->rq, s->wq);
+}
+
+static void sock_details_hr_fmt(struct sockstat *s, int type, unsigned groups,
+			unsigned long long cb)
+{
+	if (type == GENERIC_DETAIL && s->uid)
+		printf(" uid:%u", s->uid);
+
+	if (type == GENERIC_DETAIL) {
+		printf(" ino:%u", s->ino);
+		printf(" sk:%llx", s->sk);
+	}
+
+	if (type == NETLINK_DETAIL)
+		printf(" sk=%llx cb=%llx groups=0x%08x", s->sk, cb, groups);
+
+}
+
+static void sock_addr_hr_fmt(const char *addr, int addr_len,
+		char *delim, int port_len,
+		const char *port, const char *ifname,
+		const char *peer_kind)
+{
+	if (ifname) {
+		printf("%*s%%%s%s%-*s ", addr_len, addr, ifname, delim,
+		port_len, port);
+	} else {
+		printf("%*s%s%-*s ", addr_len, addr, delim, port_len, port);
+	}
+}
+
+static void sock_users_hr_fmt(char *out)
+{
+	printf(" users:(%s)", out);
+}
+
+static void sock_summary_hr_fmt(struct ssummary *s, struct snmpstat *sn,
+			struct slabstat *slabstat, int has_succ)
+{
+	printf("Total: %d (kernel %d)\n", s->socks, slabstat->socks);
+
+	printf("TCP:   %d (estab %d, closed %d, orphaned %d,"
+		"synrecv %d, timewait %d/%d), ports %d\n",
+	s->tcp_total + slabstat->tcp_syns + s->tcp_tws, sn->tcp_estab,
+	s->tcp_total - (s->tcp4_hashed + s->tcp6_hashed - s->tcp_tws),
+	s->tcp_orphans, slabstat->tcp_syns, s->tcp_tws, slabstat->tcp_tws,
+	slabstat->tcp_ports);
+
+	printf("\n");
+	printf("Transport Total     IP        IPv6\n");
+	printf("*	%-9d %-9s %-9s\n", slabstat->socks, "-", "-");
+	printf("RAW	%-9d %-9d %-9d\n", s->raw4 + s->raw6, s->raw4,
+	s->raw6);
+	printf("UDP	%-9d %-9d %-9d\n", s->udp4 + s->udp6, s->udp4,
+	s->udp6);
+	printf("TCP	%-9d %-9d %-9d\n", s->tcp4_hashed + s->tcp6_hashed,
+	s->tcp4_hashed, s->tcp6_hashed);
+	printf("INET	%-9d %-9d %-9d\n",
+	s->raw4 + s->udp4 + s->tcp4_hashed + s->raw6 + s->udp6 +
+	s->tcp6_hashed, s->raw4 + s->udp4 + s->tcp4_hashed,
+	s->raw6 + s->udp6 + s->tcp6_hashed);
+	printf("FRAG	%-9d %-9d %-9d\n", s->frag4 + s->frag6, s->frag4,
+	s->frag6);
+
+	printf("\n");
+}
+
+static void sock_conn_hr_fmt(unsigned char mask)
+{
+	printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
+}
+
+static void mem_hr_fmt(const struct inet_diag_meminfo *minfo)
+{
+	printf(" mem:(r%u,w%u,f%u,t%u)",
+	minfo->idiag_rmem,
+	minfo->idiag_wmem, minfo->idiag_fmem, minfo->idiag_tmem);
+}
+
+static void skmem_hr_fmt(const __u32 *skmeminfo,
+		struct rtattr **tb, int attrtype)
+{
+	printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
+	skmeminfo[SK_MEMINFO_RMEM_ALLOC],
+	skmeminfo[SK_MEMINFO_RCVBUF],
+	skmeminfo[SK_MEMINFO_WMEM_ALLOC],
+	skmeminfo[SK_MEMINFO_SNDBUF],
+	skmeminfo[SK_MEMINFO_FWD_ALLOC],
+	skmeminfo[SK_MEMINFO_WMEM_QUEUED], skmeminfo[SK_MEMINFO_OPTMEM]);
+
+	if (RTA_PAYLOAD(tb[attrtype]) >=
+	(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
+		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
+
+	printf(")");
+}
+
+static void bpf_filter_hr_fmt(struct sock_filter *fil, int num)
+{
+	printf("\n\tbpf filter (%d): ", num);
+	while (num) {
+		printf(" 0x%02x %u %u %u,",
+		fil->code, fil->jt, fil->jf, fil->k);
+		num--;
+		fil++;
+	}
+}
+
+static void opt_hr_fmt(char *opt)
+{
+	printf(" opt:\"%s\"", opt);
+}
+
+static void proc_hr_fmt(int serv_width, char *pid_ctx)
+{
+	if (pid_ctx != NULL) {
+		printf("proc_ctx=%-*s ", serv_width, pid_ctx);
+		free(pid_ctx);
+	} else {
+		printf("proc_ctx=%-*s ", serv_width, "unavailable");
+	}
+}
+
+static void packet_show_ring_hr_fmt(struct packet_diag_ring *ring)
+{
+	printf("blk_size:%d", ring->pdr_block_size);
+	printf(",blk_nr:%d", ring->pdr_block_nr);
+	printf(",frm_size:%d", ring->pdr_frame_size);
+	printf(",frm_nr:%d", ring->pdr_frame_nr);
+	printf(",tmo:%d", ring->pdr_retire_tmo);
+	printf(",features:0x%x", ring->pdr_features);
+}
+
+const struct fmt_op_hub hr_output_op = {
+	.tcp_stats_fmt = tcp_stats_hr_fmt,
+	.tcp_timer_fmt = tcp_timer_hr_fmt,
+	.sock_state_fmt = sock_state_hr_fmt,
+	.sock_details_fmt = sock_details_hr_fmt,
+	.sock_addr_fmt = sock_addr_hr_fmt,
+	.sock_users_fmt = sock_users_hr_fmt,
+	.sock_summary_fmt = sock_summary_hr_fmt,
+	.sock_conn_fmt = sock_conn_hr_fmt,
+	.mem_fmt = mem_hr_fmt,
+	.skmem_fmt = skmem_hr_fmt,
+	.bpf_filter_fmt = bpf_filter_hr_fmt,
+	.opt_fmt = opt_hr_fmt,
+	.proc_fmt = proc_hr_fmt,
+	.packet_show_ring_fmt = packet_show_ring_hr_fmt,
+};
diff --git a/misc/ss_hr_fmt.h b/misc/ss_hr_fmt.h
new file mode 100644
index 0000000..969fb17
--- /dev/null
+++ b/misc/ss_hr_fmt.h
@@ -0,0 +1,9 @@
+#ifndef SS_HR_FMT_H
+#define SS_HR_FMT_H
+
+#include <linux/inet_diag.h>
+#include <linux/pkt_sched.h>
+#include <linux/filter.h>
+#include "ss_types.h"
+
+#endif				/* SS_HR_FMT_H */
diff --git a/misc/ss_json_fmt.c b/misc/ss_json_fmt.c
new file mode 100644
index 0000000..f1a53cd
--- /dev/null
+++ b/misc/ss_json_fmt.c
@@ -0,0 +1,399 @@
+#include <linux/sock_diag.h>
+#include <linux/rtnetlink.h>
+#include "ss_out_fmt.h"
+#include "ss_types.h"
+#include "ss_json_fmt.h"
+
+#define SHOW_TCP_INFO	(show_tcpinfo && \
+			(ss_current_filter.dbs & (1<<TCP_DB) || \
+			ss_current_filter.dbs & (1<<DCCP_DB)))
+#define SHOW_MEM	(show_mem && \
+			ss_current_filter.dbs & (1<<UDP_DB) || \
+			ss_current_filter.dbs & (1<<TCP_DB))
+
+/* generic auxiliary mechanism for json related dangling delimiter issues*/
+void res_json_fmt_branch(int pred, char bound)
+{
+	if (pred) {
+		if (bound == ' ') {
+			printf(",");
+			goto newl;
+		}
+		printf("%c,", bound);
+	} else {
+		if (bound == ' ')
+			goto newl;
+		printf("%c", bound);
+	}
+ newl:
+	printf("\n");
+}
+
+static void make_userout_valid(char *out)
+{
+	/*replace quote (") by space */
+	char *tmp;
+
+	while ((tmp = strstr(out, "\"")) != NULL)
+		*tmp = ' ';
+}
+
+static void print_serv_or_port(char *indent, char *serv_o_port)
+{
+	char buf[8];
+
+	printf(",\n");
+	if (resolve_services == 0)
+		strcpy(buf, "port");
+	else
+		strcpy(buf, "service");
+
+	printf("%s\"%s\": \"%s\"\n", indent, buf, serv_o_port);
+
+}
+
+static void tcp_stats_json_fmt(struct tcpstat *s)
+{
+	char b1[64];
+
+	char indent1[] = "\t";
+	char indent2[] = "\t\t";
+	if (s->has_ts_opt) {
+		printf(",\n%s\"ts\": \"true\"", indent1);
+	}
+	if (s->has_sack_opt) {
+		printf(",\n%s\"sack\": \"true\"", indent1);
+	}
+	if (s->has_ecn_opt) {
+		printf(",\n%s\"ecn\": \"true\"", indent1);
+	}
+	if (s->has_ecnseen_opt) {
+		printf(",\n%s\"ecnseen\": \"true\"", indent1);
+	}
+	if (s->has_fastopen_opt) {
+		printf(",\n%s\"fastopen\": \"true\"", indent1);
+	}
+	if (s->cong_alg) {
+		printf(",\n%s\"cong_alg\": \"%s\"", indent1, s->cong_alg);
+	}
+	if (s->has_wscale_opt) {
+		printf(",\n%s\"wscale\": \"%d,%d\"", indent1, s->snd_wscale,
+		s->rcv_wscale);
+	}
+	if (s->rto) {
+		printf(",\n%s\"rto\": %g", indent1, s->rto);
+	}
+	if (s->backoff) {
+		printf(",\n%s\"backoff\": %u", indent1, s->backoff);
+	}
+	if (s->rtt) {
+		printf(",\n%s\"rtt\": \"%g/%g\"", indent1, s->rtt, s->rttvar);
+	}
+	if (s->ato) {
+		printf(",\n%s\"ato\": %g", indent1, s->ato);
+	}
+	if (s->qack) {
+		printf(",\n%s\"quack\": %d", indent1, s->qack);
+	}
+	if (s->qack & 1) {
+		printf(",\n%s\"bidir\": \"true\"", indent1);
+	}
+	if (s->mss) {
+		printf(",\n%s\"mss\": %d", indent1, s->mss);
+	}
+	if (s->cwnd && s->cwnd != 2) {
+		printf("\t,\n\"cwnd\": %d", s->cwnd);
+	}
+	if (s->ssthresh) {
+		printf("\t,\n\"ssthresh\": %d", s->ssthresh);
+	}
+	if (s->dctcp && s->dctcp->enabled) {
+		struct dctcpstat *dctcp = s->dctcp;
+
+		printf(",\n\"dctcpinfo\": {\n");
+		printf(" ce_state %u,\n alpha %u,\n ab_ecn %u,\n ab_tot %u",
+		dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
+		dctcp->ab_tot);
+		printf("\n}");
+	} else if (s->dctcp) {
+		printf(",\n%s\"fallback_mode\": \"true\"", indent2);
+	}
+	if (s->send_bps) {
+		printf(",\n%s\"send\": \"%sbps\"", indent1,
+		sprint_bw(b1, s->send_bps));
+	}
+	if (s->lastsnd) {
+		printf(",\n%s\"lastsnd\": %u", indent1, s->lastsnd);
+	}
+	if (s->lastrcv) {
+		printf(",\n%s\"lastrcv\": %u", indent1, s->lastrcv);
+	}
+	if (s->lastack) {
+		printf(",\n%s\"lastack\": %u", indent1, s->lastack);
+	}
+	if (s->pacing_rate) {
+		printf(",\n%s\"pacing_rate\": \"%sbps", indent1,
+		sprint_bw(b1, s->pacing_rate));
+		if (s->pacing_rate_max)
+			printf("/%sbps\"\n", sprint_bw(b1, s->pacing_rate_max));
+		else 
+			printf("\"\n");
+	}
+	if (s->unacked) {
+		printf(",\n%s\"unacked\": %u", indent1, s->unacked);
+	}
+	if (s->retrans || s->retrans_total) {
+		printf(",\n%s\"retrans\": \"%u/%u\"", indent1, s->retrans,
+		s->retrans_total);
+	}
+	if (s->lost) {
+		printf(",\n%s\"lost\": %u", indent1, s->lost);
+	}
+	if (s->sacked && (s->ss.state != SS_LISTEN)) {
+		printf(",\n%s\"sacked\": %u", indent1, s->sacked);
+	}
+	if (s->fackets) {
+		printf(",\n%s\"fackets\": %u", indent1, s->fackets);
+	}
+	if (s->reordering != 3) {
+		printf(",\n%s\"reordering\": %d", indent1, s->reordering);
+	}
+	if (s->rcv_rtt) {
+		printf(",\n%s\"rcv_rtt\": %g", indent1, s->rcv_rtt);
+	}
+
+	/*deal with special case */
+	res_json_fmt_branch(s->ss.state == SS_LISTEN, ' ');
+
+	CHECK_FMT_ADAPT(s->rcv_space, s,
+	json_handler_must_be_adapted_accordingly_when_hr_fmt_is_extended);
+}
+
+static void tcp_timer_json_fmt(struct tcpstat *s)
+{
+	
+	if (s->timer)
+		if (s->timer > 4)
+			s->timer = 5;
+	printf(",\n\t\"timer\": \"(%s,%s,%d)\"",
+	ss_timer_name[s->timer], print_ms_timer(s->timeout), s->retrans);
+}
+
+static void sock_state_json_fmt(struct sockstat *s, const char **sstate_name,
+			const char *sock_name, int netid_width,
+			int state_width)
+{
+	char eol[] = ",\n";
+
+	if (netid_width)
+		printf("\n\t\"Netid\": \"%s\"%s", sock_name, eol);
+
+	if (state_width) {
+		printf("\n\t\"State\": ");
+		printf("\"%s\"", sstate_name[s->state]);
+		printf("%s", eol);
+	}
+
+	printf("\n\t\"Recv-Q\": %d%s", s->rq, eol);
+	printf("\n\t\"Send-Q\": %d", s->wq);
+}
+
+static void sock_details_json_fmt(struct sockstat *s, int type, unsigned groups,
+			unsigned long long cb)
+{
+	if (type == GENERIC_DETAIL && s->uid)
+		printf(",\n\t\"uid\": %u", s->uid);
+	if (type == GENERIC_DETAIL)
+		printf(",\n\t\"ino\": %u", s->ino);
+	printf(",\n\t\"sk\": \"%llx\"", s->sk);
+
+	if (type == NETLINK_DETAIL) {
+		printf(",\n\t\"cb\": \"%llx\"", cb);
+		printf(",\n\t\"groups=0x\": \"%08x\"", groups);
+	}
+}
+
+static void sock_addr_json_fmt(const char *addr, int addr_len, char *delim,
+			int port_len, const char *port, const char *ifname,
+			const char *peer_kind)
+{
+	char indent2[] = "\t\t";
+
+	printf("\n%s\"%s\": {\n", indent2, peer_kind);
+
+	char *indent3 = "\t\t\t";
+
+	printf("%s\"addr\": \"%s\",\n", indent3, addr);
+	printf("%s\"interface\": \"%s\"", indent3, ifname);
+	
+
+	print_serv_or_port(indent3, (char *)port);
+
+	printf("%s}", indent2);
+	if (strcmp(peer_kind, "remote") == 0)
+		printf("\n\t");
+	else
+		printf(",\n");
+}
+
+static void sock_users_json_fmt(char *out)
+{
+	make_userout_valid(out);
+
+	printf(",\n\t\"users\": \"%s\"", out);
+}
+
+static void sock_summary_json_fmt(struct ssummary *s, struct snmpstat *sn,
+			struct slabstat *slabstat, int has_succ)
+{
+
+	char eol[] = ",\n";
+	char eol2[] = "\n";
+	char indent3[] = "\t\t\t";
+
+	printf("\"summary\": {\n");
+	printf("\t\"total\": %d%s", s->socks, eol);
+	printf("\t\"kernel\": %d%s", slabstat->socks, eol);
+
+	printf("\t\"TCP\": {%s", eol2);
+	printf("\t\t\"total\": %d%s",
+	s->tcp_total + slabstat->tcp_syns + s->tcp_tws, eol);
+	printf("\t\t\"estab\": %d%s", sn->tcp_estab, eol);
+	printf("\t\t\"closed\": %d%s",
+	s->tcp_total - (s->tcp4_hashed + s->tcp6_hashed - s->tcp_tws),
+	eol);
+	printf("\t\t\"orphaned\": %d%s", s->tcp_orphans, eol);
+	printf("\t\t\"synrecv\": %d%s", slabstat->tcp_syns, eol);
+	printf("\t\t\"timewait\": \"%d/%d\"%s",
+	s->tcp_tws, slabstat->tcp_tws, eol);
+	printf("\t\t\"ports\": %d%s", slabstat->tcp_ports, eol2);
+	printf("\t}%s", eol);
+
+	printf("\t\"trans_over_net_prop\": {%s", eol2);
+	printf("\t\t\"*\": {%s", eol2);
+	printf("%s\"Total\": %d%s", indent3, slabstat->socks, eol);
+	printf("%s\"IP\": \"%s\"%s", indent3, "-", eol);
+	printf("%s\"IPv6\": \"%s\"%s", indent3, "-", eol2);
+	printf("\t\t}%s", eol);
+
+	printf("\t\t\"RAW\": {%s", eol2);
+	printf("%s\"Total\": %d%s", indent3, s->raw4 + s->raw6, eol);
+	printf("%s\"IP\": %d%s", indent3, s->raw4, eol);
+	printf("%s\"IPv6\": %d%s", indent3, s->raw6, eol2);
+	printf("\t\t}%s", eol);
+
+	printf("\t\t\"UDP\": {%s", eol2);
+	printf("%s\"Total\": %d%s", indent3, s->udp4 + s->udp6, eol);
+	printf("%s\"IP\": %d%s", indent3, s->udp4, eol);
+	printf("%s\"IPv6\": %d%s", indent3, s->udp6, eol2);
+	printf("\t\t}%s", eol);
+
+	printf("\t\t\"TCP\": {%s", eol2);
+	printf("%s\"Total\": %d%s",
+	indent3, s->tcp4_hashed + s->tcp6_hashed, eol);
+	printf("%s\"IP\": %d%s", indent3, s->tcp4_hashed, eol);
+	printf("%s\"IPv6\": %d%s", indent3, s->tcp6_hashed, eol2);
+	printf("\t\t}%s", eol);
+
+	printf("\t\t\"INET\": {%s", eol2);
+	printf("%s\"Total\": %d%s", indent3,
+	s->raw4 + s->udp4 + s->tcp4_hashed + s->raw6 + s->udp6 +
+	s->tcp6_hashed, eol);
+	printf("%s\"IP\": %d%s", indent3, s->raw4 + s->udp4 + s->tcp4_hashed,
+	eol);
+	printf("%s\"IPv6\": %d%s", indent3, s->raw6 + s->udp6 + s->tcp6_hashed,
+	eol2);
+	printf("\t\t}%s", eol);
+
+	printf("\t\t\"FRAG\": {%s", eol2);
+	printf("%s\"Total\": %d%s", indent3, s->frag4 + s->frag6, eol);
+	printf("%s\"IP\": %d%s", indent3, s->frag4, eol);
+	printf("%s\"IPv6\": %d%s", indent3, s->frag6, eol2);
+	printf("\t\t}%s", eol2);
+	printf("\t}%s", "\n");
+
+	printf("}\n");
+}
+
+static void sock_conn_json_fmt(unsigned char mask)
+{
+	printf(",\n\t\"shutdown\": \"%c-%c\"", mask & 1 ? '-' : '<',
+	mask & 2 ? '-' : '>');
+}
+
+static void mem_json_fmt(const struct inet_diag_meminfo *minfo)
+{
+	printf(",\n\t\"mem\": \"(r%u,w%u,f%u,t%u)\",\n",
+	minfo->idiag_rmem,
+	minfo->idiag_wmem, minfo->idiag_fmem, minfo->idiag_tmem);
+}
+
+static void skmem_json_fmt(const __u32 *skmeminfo, struct rtattr **tb,
+		int attrtype)
+{
+	printf(",\n\t\"skmem\": \"(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
+	skmeminfo[SK_MEMINFO_RMEM_ALLOC],
+	skmeminfo[SK_MEMINFO_RCVBUF],
+	skmeminfo[SK_MEMINFO_WMEM_ALLOC],
+	skmeminfo[SK_MEMINFO_SNDBUF],
+	skmeminfo[SK_MEMINFO_FWD_ALLOC],
+	skmeminfo[SK_MEMINFO_WMEM_QUEUED], skmeminfo[SK_MEMINFO_OPTMEM]);
+	if (RTA_PAYLOAD(tb[attrtype]) >=
+	(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
+		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
+	printf(")\"");
+}
+
+static void bpf_filter_json_fmt(struct sock_filter *fil, int num)
+{
+	printf(",\n\t\"bpf filter\": \"(%d):", num);
+	while (num) {
+		printf("0x%02x %u %u %u,", fil->code, fil->jt, fil->jf, fil->k);
+		num--;
+		fil++;
+	}
+	printf("\"\n");
+}
+
+static void opt_json_fmt(char *opt)
+{
+	printf(",\n\t\t\"opt\": \"%s\",\n", opt);
+}
+
+static void proc_json_fmt(int serv_width, char *pid_ctx)
+{
+	printf(",\n");
+	if (pid_ctx != NULL) {
+		printf("\t\"proc_ctx\": \"%-s\" ", pid_ctx);
+		free(pid_ctx);
+	} else {
+		printf("\t\"proc_ctx\": \"%-s\" ", "unavailable");
+	}
+}
+
+static void packet_show_ring_json_fmt(struct packet_diag_ring *ring)
+{
+	printf("\n\"blk_size\": \"%d\",\n", ring->pdr_block_size);
+	printf("\"blk_nr\" : \"%d\",\n", ring->pdr_block_nr);
+	printf("\"frm_size\" : \"%d\",\n", ring->pdr_frame_size);
+	printf("\"frm_nr\" : \"%d\",\n", ring->pdr_frame_nr);
+	printf("\"tmo\" : \"%d\",\n", ring->pdr_retire_tmo);
+	printf("\"features_0x\" : \"%x\"\n", ring->pdr_features);
+}
+
+const struct fmt_op_hub json_output_op = {
+	.tcp_stats_fmt = tcp_stats_json_fmt,
+	.tcp_timer_fmt = tcp_timer_json_fmt,
+	.sock_state_fmt = sock_state_json_fmt,
+	.sock_details_fmt = sock_details_json_fmt,
+	.sock_addr_fmt = sock_addr_json_fmt,
+	.sock_users_fmt = sock_users_json_fmt,
+	.sock_summary_fmt = sock_summary_json_fmt,
+	.sock_conn_fmt = sock_conn_json_fmt,
+	.mem_fmt = mem_json_fmt,
+	.skmem_fmt = skmem_json_fmt,
+	.bpf_filter_fmt = bpf_filter_json_fmt,
+	.opt_fmt = opt_json_fmt,
+	.proc_fmt = proc_json_fmt,
+	.packet_show_ring_fmt = packet_show_ring_json_fmt,
+};
diff --git a/misc/ss_json_fmt.h b/misc/ss_json_fmt.h
new file mode 100644
index 0000000..cbd26f1
--- /dev/null
+++ b/misc/ss_json_fmt.h
@@ -0,0 +1,24 @@
+#ifndef SS_JSON_FMT_H
+#define SS_JSON_FMT_H
+
+#include <linux/inet_diag.h>
+#include <linux/pkt_sched.h>
+#include <linux/filter.h>
+#include "ss_types.h"
+
+extern int json_output;
+extern int resolve_services;
+extern int show_options;
+extern int show_details;
+extern int show_users;
+extern int show_mem;
+extern int show_tcpinfo;
+extern int show_bpf;
+extern int show_proc_ctx;
+extern int show_sock_ctx;
+extern struct filter ss_current_filter;
+
+/*generic auxiliary mechanism for json related dangling delimiter issues*/
+void res_json_fmt_branch(int pred, char bound);
+
+#endif				/* SS_JSON_FMT_H */
diff --git a/misc/ss_out_fmt.c b/misc/ss_out_fmt.c
new file mode 100644
index 0000000..e17d898
--- /dev/null
+++ b/misc/ss_out_fmt.c
@@ -0,0 +1,127 @@
+#include <stdio.h>
+#include "ss_out_fmt.h"
+const struct fmt_op_hub *fmt_op_hub[] = {
+	/*human readble */
+	&hr_output_op,
+	/*json */
+	&json_output_op
+};
+
+
+
+char *sprint_bw(char *buf, double bw)
+{
+	if (bw > 1000000.)
+		sprintf(buf, "%.1fM", bw / 1000000.);
+	else if (bw > 1000.)
+		sprintf(buf, "%.1fK", bw / 1000.);
+	else
+		sprintf(buf, "%g", bw);
+
+	return buf;
+}
+
+char *print_ms_timer(int timeout)
+{
+	static char buf[64];
+	int secs, msecs, minutes;
+
+	if (timeout < 0)
+		timeout = 0;
+	secs = timeout / 1000;
+	minutes = secs / 60;
+	secs = secs % 60;
+	msecs = timeout % 1000;
+	buf[0] = 0;
+	if (minutes) {
+		msecs = 0;
+		snprintf(buf, sizeof(buf) - 16, "%dmin", minutes);
+		if (minutes > 9)
+			secs = 0;
+	}
+	if (secs) {
+		if (secs > 9)
+			msecs = 0;
+		sprintf(buf + strlen(buf), "%d%s", secs, msecs ? "." : "sec");
+	}
+	if (msecs)
+		sprintf(buf + strlen(buf), "%03dms", msecs);
+	return buf;
+}
+
+void tcp_stats_fmt(struct tcpstat *s)
+{
+	fmt_op_hub[fmt_type]->tcp_stats_fmt(s);
+}
+
+void tcp_timer_fmt(struct tcpstat *s)
+{
+	fmt_op_hub[fmt_type]->tcp_timer_fmt(s);
+}
+
+void sock_state_fmt(struct sockstat *s, const char **sstate_name,
+		const char *sock_name, int netid_width, int state_width)
+{
+	fmt_op_hub[fmt_type]->sock_state_fmt(s, sstate_name, sock_name,
+					netid_width, state_width);
+}
+
+void sock_details_fmt(struct sockstat *s, int type,
+		unsigned groups, unsigned long long cb)
+{
+	fmt_op_hub[fmt_type]->sock_details_fmt(s, type, groups, cb);
+}
+
+void sock_addr_fmt(const char *addr, int addr_len, char *delim,
+		int port_len, const char *port, const char *ifname,
+		const char *peer_kind)
+{
+	fmt_op_hub[fmt_type]->sock_addr_fmt(addr, addr_len,
+					delim, port_len, port, ifname,
+					peer_kind);
+}
+
+void sock_users_fmt(char *out)
+{
+	fmt_op_hub[fmt_type]->sock_users_fmt(out);
+}
+
+void sock_summary_fmt(struct ssummary *s, struct snmpstat *sn,
+		struct slabstat *slabstat, int has_succ)
+{
+	fmt_op_hub[fmt_type]->sock_summary_fmt(s, sn, slabstat, has_succ);
+}
+
+void sock_conn_fmt(unsigned char mask)
+{
+	fmt_op_hub[fmt_type]->sock_conn_fmt(mask);
+}
+
+void mem_fmt(const struct inet_diag_meminfo *minfo)
+{
+	fmt_op_hub[fmt_type]->mem_fmt(minfo);
+}
+
+void skmem_fmt(const __u32 *skmeminfo, struct rtattr **tb, int attrtype)
+{
+	fmt_op_hub[fmt_type]->skmem_fmt(skmeminfo, tb, attrtype);
+}
+
+void bpf_filter_fmt(struct sock_filter *f, int num)
+{
+	fmt_op_hub[fmt_type]->bpf_filter_fmt(f, num);
+}
+
+void opt_fmt(char *opt)
+{
+	fmt_op_hub[fmt_type]->opt_fmt(opt);
+}
+
+void proc_fmt(int serv_width, char *pid_ctx)
+{
+	fmt_op_hub[fmt_type]->proc_fmt(serv_width, pid_ctx);
+}
+void packet_show_ring_fmt(struct packet_diag_ring *ring)
+{
+	fmt_op_hub[fmt_type]->packet_show_ring_fmt(ring);
+}
diff --git a/misc/ss_out_fmt.h b/misc/ss_out_fmt.h
new file mode 100644
index 0000000..b74f668
--- /dev/null
+++ b/misc/ss_out_fmt.h
@@ -0,0 +1,82 @@
+#ifndef SS_OUT_FMT_H
+#define SS_OUT_FMT_H
+
+#include "ss_hr_fmt.h"
+#include "ss_json_fmt.h"
+#include "ss_types.h"
+#include <linux/inet_diag.h>
+#include <linux/pkt_sched.h>
+#include <linux/filter.h>
+#include <linux/netdevice.h>
+#include <linux/packet_diag.h>
+
+#define GENERIC_DETAIL 0
+#define NETLINK_DETAIL 1
+
+#define STATIC_ASSERT(COND, MSG) char STATIC_ASSERT##MSG[(COND) ? 1 : -1]
+/*when extending the tcp fmt handler,
+ *you have to pass the last cond of the tcp_stats
+ *struct as sentinel to this macro to ensure compilability
+ * of ss: this enforces a symmetrical extension of the individual
+ * formatting handlers */
+#define CHECK_FMT_ADAPT(SENTINEL, BEGIN, MSG) \
+	STATIC_ASSERT((((void *)&SENTINEL - (void *)BEGIN) + sizeof(SENTINEL)) \
+	/ sizeof(*BEGIN), MSG)
+
+
+extern int json_output;
+extern enum out_fmt_type fmt_type;
+extern const struct fmt_op_hub hr_output_op;
+extern const struct fmt_op_hub json_output_op;
+extern const char *ss_timer_name[];
+
+enum out_fmt_type { FMT_HR, FMT_JSON };
+
+struct fmt_op_hub {
+	void (*tcp_stats_fmt)(struct tcpstat *s);
+	void (*tcp_timer_fmt)(struct tcpstat *s);
+	void (*sock_state_fmt)(struct sockstat *s, const char **sstate_name,
+				const char *sock_name, int netid_width,
+				int state_width);
+	void (*sock_details_fmt)(struct sockstat *s, int type,
+				unsigned groups, unsigned long long cb);
+	void (*sock_addr_fmt)(const char *addr, int addr_len, char *delim,
+			int port_len, const char *port,
+			const char *ifname, const char *peer_kind);
+	void (*sock_users_fmt)(char *out);
+	void (*sock_summary_fmt)(struct ssummary *s, struct snmpstat *sn,
+				struct slabstat *slabstat, int has_succ);
+	void (*sock_conn_fmt)(unsigned char mask);
+	void (*mem_fmt)(const struct inet_diag_meminfo *minfo);
+	void (*skmem_fmt)(const __u32 *skmeminfo, struct rtattr **tb,
+			int attrtype);
+	void (*bpf_filter_fmt)(struct sock_filter *f, int num);
+	void (*opt_fmt)(char *opt);
+	void (*proc_fmt)(int serv_width, char *pid_ctx);
+	void (*packet_show_ring_fmt)(struct packet_diag_ring *ring);
+};
+
+void tcp_stats_fmt(struct tcpstat *s);
+void tcp_timer_fmt(struct tcpstat *s);
+void sock_state_fmt(struct sockstat *s, const char **sstate_name,
+		const char *sock_name, int netid_width, int state_width);
+void sock_details_fmt(struct sockstat *s, int type,
+		unsigned groups, unsigned long long cb);
+void sock_addr_fmt(const char *addr, int addr_len, char *delim, int port_len,
+		const char *port, const char *ifname, const char *peer_kind);
+void sock_users_fmt(char *out);
+void sock_summary_fmt(struct ssummary *s, struct snmpstat *sn,
+		struct slabstat *slabstat, int has_succ);
+void sock_conn_fmt(unsigned char mask);
+void mem_fmt(const struct inet_diag_meminfo *minfo);
+void skmem_fmt(const __u32 *skmeminfo, struct rtattr **tb, int attrtype);
+void bpf_filter_fmt(struct sock_filter *f, int num);
+void opt_fmt(char *opt);
+void proc_fmt(int serv_width, char *pid_ctx);
+void packet_show_ring_fmt(struct packet_diag_ring *ring);
+
+/*unisonly utilized formatting parts*/
+char *sprint_bw(char *buf, double bw);
+char *print_ms_timer(int timeout);
+
+#endif				/* SS_OUT_FMT_H */
-- 
1.9.1
