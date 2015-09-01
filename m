From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v5 01/10] ss: rooted out ss type declarations for output formatters
Date: Tue,  1 Sep 2015 19:57:14 +0200
Message-ID: <1441130243-20303-2-git-send-email-matthias.tafelmeier@gmx.net>
References: <1441130243-20303-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:58283 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754538AbbIAR5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 13:57:46 -0400
In-Reply-To: <1441130243-20303-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The prospected output formatters and ss do share type declarations like
slabstat or tcpstat so that the decision has been made to centralize
those declarations in ss_types.h.  Potential future declarations shall
be placed there. The latter should help amend the extent of ss.c as
well.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c       | 186 +-------------------------------------------------------
 misc/ss_types.h | 186 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 187 insertions(+), 185 deletions(-)
 create mode 100644 misc/ss_types.h

diff --git a/misc/ss.c b/misc/ss.c
index 2f34962..83775d1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -27,6 +27,7 @@
 #include <getopt.h>
 #include <stdbool.h>
 
+#include "ss_types.h"
 #include "utils.h"
 #include "rt_names.h"
 #include "ll_map.h"
@@ -113,55 +114,17 @@ static const char *UDP_PROTO = "udp";
 static const char *RAW_PROTO = "raw";
 static const char *dg_proto = NULL;
 
-enum
-{
-	TCP_DB,
-	DCCP_DB,
-	UDP_DB,
-	RAW_DB,
-	UNIX_DG_DB,
-	UNIX_ST_DB,
-	UNIX_SQ_DB,
-	PACKET_DG_DB,
-	PACKET_R_DB,
-	NETLINK_DB,
-	MAX_DB
-};
 
 #define PACKET_DBM ((1<<PACKET_DG_DB)|(1<<PACKET_R_DB))
 #define UNIX_DBM ((1<<UNIX_DG_DB)|(1<<UNIX_ST_DB)|(1<<UNIX_SQ_DB))
 #define ALL_DB ((1<<MAX_DB)-1)
 #define INET_DBM ((1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB)|(1<<RAW_DB))
 
-enum {
-	SS_UNKNOWN,
-	SS_ESTABLISHED,
-	SS_SYN_SENT,
-	SS_SYN_RECV,
-	SS_FIN_WAIT1,
-	SS_FIN_WAIT2,
-	SS_TIME_WAIT,
-	SS_CLOSE,
-	SS_CLOSE_WAIT,
-	SS_LAST_ACK,
-	SS_LISTEN,
-	SS_CLOSING,
-	SS_MAX
-};
-
 #define SS_ALL ((1 << SS_MAX) - 1)
 #define SS_CONN (SS_ALL & ~((1<<SS_LISTEN)|(1<<SS_CLOSE)|(1<<SS_TIME_WAIT)|(1<<SS_SYN_RECV)))
 
 #include "ssfilter.h"
 
-struct filter
-{
-	int dbs;
-	int states;
-	int families;
-	struct ssfilter *f;
-};
-
 static const struct filter default_dbs[MAX_DB] = {
 	[TCP_DB] = {
 		.states   = SS_CONN,
@@ -376,16 +339,6 @@ static FILE *ephemeral_ports_open(void)
 	return generic_proc_open("PROC_IP_LOCAL_PORT_RANGE", "sys/net/ipv4/ip_local_port_range");
 }
 
-struct user_ent {
-	struct user_ent	*next;
-	unsigned int	ino;
-	int		pid;
-	int		fd;
-	char		*process;
-	char		*process_ctx;
-	char		*socket_ctx;
-};
-
 #define USER_ENT_HASH_SIZE	256
 struct user_ent *user_ent_hash[USER_ENT_HASH_SIZE];
 
@@ -540,12 +493,6 @@ static void user_ent_hash_build(void)
 	closedir(dir);
 }
 
-enum entry_types {
-	USERS,
-	PROC_CTX,
-	PROC_SOCK_CTX
-};
-
 #define ENTRY_BUF_SIZE 512
 static int find_entry(unsigned ino, char **buf, int type)
 {
@@ -618,17 +565,6 @@ next:
 	return cnt;
 }
 
-/* Get stats from slab */
-
-struct slabstat
-{
-	int socks;
-	int tcp_ports;
-	int tcp_tws;
-	int tcp_syns;
-	int skbs;
-};
-
 static struct slabstat slabstat;
 
 static const char *slabstat_ids[] =
@@ -713,75 +649,6 @@ static const char *sstate_namel[] = {
 	[SS_CLOSING] = "closing",
 };
 
-struct sockstat
-{
-	struct sockstat	   *next;
-	unsigned int	    type;
-	uint16_t	    prot;
-	inet_prefix	    local;
-	inet_prefix	    remote;
-	int		    lport;
-	int		    rport;
-	int		    state;
-	int		    rq, wq;
-	unsigned	    ino;
-	unsigned	    uid;
-	int		    refcnt;
-	unsigned int	    iface;
-	unsigned long long  sk;
-	char *name;
-	char *peer_name;
-};
-
-struct dctcpstat
-{
-	unsigned int	ce_state;
-	unsigned int	alpha;
-	unsigned int	ab_ecn;
-	unsigned int	ab_tot;
-	bool		enabled;
-};
-
-struct tcpstat
-{
-	struct sockstat	    ss;
-	int		    timer;
-	int		    timeout;
-	int		    probes;
-	char		    cong_alg[16];
-	double		    rto, ato, rtt, rttvar;
-	int		    qack, cwnd, ssthresh, backoff;
-	double		    send_bps;
-	int		    snd_wscale;
-	int		    rcv_wscale;
-	int		    mss;
-	unsigned int	    lastsnd;
-	unsigned int	    lastrcv;
-	unsigned int	    lastack;
-	double		    pacing_rate;
-	double		    pacing_rate_max;
-	unsigned long long  bytes_acked;
-	unsigned long long  bytes_received;
-	unsigned int	    segs_out;
-	unsigned int	    segs_in;
-	unsigned int	    unacked;
-	unsigned int	    retrans;
-	unsigned int	    retrans_total;
-	unsigned int	    lost;
-	unsigned int	    sacked;
-	unsigned int	    fackets;
-	unsigned int	    reordering;
-	double		    rcv_rtt;
-	int		    rcv_space;
-	bool		    has_ts_opt;
-	bool		    has_sack_opt;
-	bool		    has_ecn_opt;
-	bool		    has_ecnseen_opt;
-	bool		    has_fastopen_opt;
-	bool		    has_wscale_opt;
-	struct dctcpstat    *dctcp;
-};
-
 static void sock_state_print(struct sockstat *s, const char *sock_name)
 {
 	if (netid_width)
@@ -855,13 +722,6 @@ static const char *print_ms_timer(int timeout)
 	return buf;
 }
 
-struct scache {
-	struct scache *next;
-	int port;
-	char *name;
-	const char *proto;
-};
-
 struct scache *rlist;
 
 static void init_service_resolver(void)
@@ -1026,13 +886,6 @@ static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex
 			ifname);
 }
 
-struct aafilter
-{
-	inet_prefix	addr;
-	int		port;
-	struct aafilter *next;
-};
-
 static int inet2_addr_match(const inet_prefix *a, const inet_prefix *p,
 			    int plen)
 {
@@ -2188,11 +2041,6 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 	return 0;
 }
 
-struct inet_diag_arg {
-	struct filter *f;
-	int protocol;
-};
-
 static int show_one_inet_sock(const struct sockaddr_nl *addr,
 		struct nlmsghdr *h, void *arg)
 {
@@ -3223,10 +3071,6 @@ static int netlink_show(struct filter *f)
 	return 0;
 }
 
-struct sock_diag_msg {
-	__u8 sdiag_family;
-};
-
 static int generic_show_sock(const struct sockaddr_nl *addr,
 		struct nlmsghdr *nlh, void *arg)
 {
@@ -3281,11 +3125,6 @@ Exit:
 	return ret;
 }
 
-struct snmpstat
-{
-	int tcp_estab;
-};
-
 static int get_snmp_int(char *proto, char *key, int *result)
 {
 	char buf[1024];
@@ -3330,28 +3169,6 @@ static int get_snmp_int(char *proto, char *key, int *result)
 	return -1;
 }
 
-
-/* Get stats from sockstat */
-
-struct ssummary
-{
-	int socks;
-	int tcp_mem;
-	int tcp_total;
-	int tcp_orphans;
-	int tcp_tws;
-	int tcp4_hashed;
-	int udp4;
-	int raw4;
-	int frag4;
-	int frag4_mem;
-	int tcp6_hashed;
-	int udp6;
-	int raw6;
-	int frag6;
-	int frag6_mem;
-};
-
 static void get_sockstat_line(char *line, struct ssummary *s)
 {
 	char id[256], rem[256];
@@ -3818,7 +3635,6 @@ int main(int argc, char *argv[])
 	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
 		init_service_resolver();
 
-
 	if (current_filter.dbs == 0) {
 		fprintf(stderr, "ss: no socket tables to show with such filter.\n");
 		exit(0);
diff --git a/misc/ss_types.h b/misc/ss_types.h
new file mode 100644
index 0000000..b4dfdc1
--- /dev/null
+++ b/misc/ss_types.h
@@ -0,0 +1,186 @@
+#ifndef SS_STRUCTS_H
+#define SS_STRUCTS_H
+
+#include <stdbool.h>
+#include <stdint.h>
+#include "utils.h"
+
+enum {
+	TCP_DB,
+	DCCP_DB,
+	UDP_DB,
+	RAW_DB,
+	UNIX_DG_DB,
+	UNIX_ST_DB,
+	UNIX_SQ_DB,
+	PACKET_DG_DB,
+	PACKET_R_DB,
+	NETLINK_DB,
+	MAX_DB
+};
+
+enum {
+	SS_UNKNOWN,
+	SS_ESTABLISHED,
+	SS_SYN_SENT,
+	SS_SYN_RECV,
+	SS_FIN_WAIT1,
+	SS_FIN_WAIT2,
+	SS_TIME_WAIT,
+	SS_CLOSE,
+	SS_CLOSE_WAIT,
+	SS_LAST_ACK,
+	SS_LISTEN,
+	SS_CLOSING,
+	SS_MAX
+};
+
+struct filter {
+	int dbs;
+	int states;
+	int families;
+	struct ssfilter *f;
+};
+
+struct user_ent {
+	struct user_ent *next;
+	unsigned int ino;
+	int pid;
+	int fd;
+	char *process;
+	char *process_ctx;
+	char *socket_ctx;
+};
+
+/* Get stats from slab */
+
+struct slabstat {
+	int socks;
+	int tcp_ports;
+	int tcp_tws;
+	int tcp_syns;
+	int skbs;
+};
+
+struct sockstat {
+	struct sockstat    *next;
+	unsigned int        type;
+	uint16_t            prot;
+	inet_prefix         local;
+	inet_prefix         remote;
+	int                 lport;
+	int                 rport;
+	int                 state;
+	int                 rq, wq;
+	unsigned            ino;
+	unsigned            uid;
+	int                 refcnt;
+	unsigned int        iface;
+	unsigned long long  sk;
+	char *name;
+	char *peer_name;
+};
+
+struct dctcpstat {
+	unsigned int ce_state;
+	unsigned int alpha;
+	unsigned int ab_ecn;
+	unsigned int ab_tot;
+	bool enabled;
+};
+
+#pragma pack(push, 1)
+
+struct tcpstat {
+	struct sockstat     ss;
+	int                 timer;
+	int                 timeout;
+	int                 probes;
+	char                cong_alg[16];
+	double              rto, ato, rtt, rttvar;
+	int                 qack, cwnd, ssthresh, backoff;
+	double              send_bps;
+	int                 snd_wscale;
+	int                 rcv_wscale;
+	int                 mss;
+	unsigned int        lastsnd;
+	unsigned int        lastrcv;
+	unsigned int        lastack;
+	double              pacing_rate;
+	double              pacing_rate_max;
+	unsigned long long  bytes_acked;
+	unsigned long long  bytes_received;
+	unsigned int        segs_out;
+	unsigned int        segs_in;
+	unsigned int        unacked;
+	unsigned int        retrans;
+	unsigned int        retrans_total;
+	unsigned int        lost;
+	unsigned int        sacked;
+	unsigned int        fackets;
+	unsigned int        reordering;
+	bool                has_ts_opt;
+	bool                has_sack_opt;
+	bool                has_ecn_opt;
+	bool                has_ecnseen_opt;
+	bool                has_fastopen_opt;
+	bool                has_wscale_opt;
+	struct dctcpstat    *dctcp;
+	double              rcv_rtt;
+	int                 rcv_space;
+};
+
+#pragma pack(pop)
+
+struct scache {
+	struct scache *next;
+	int port;
+	char *name;
+	const char *proto;
+};
+
+struct aafilter {
+	inet_prefix addr;
+	int port;
+	struct aafilter *next;
+};
+
+struct snmpstat {
+	int tcp_estab;
+};
+
+struct sock_diag_msg {
+	__u8 sdiag_family;
+};
+
+struct inet_diag_arg {
+	struct filter *f;
+	int protocol;
+};
+
+/* Get stats from sockstat */
+
+struct ssummary {
+	int socks;
+	int tcp_mem;
+	int tcp_total;
+	int tcp_orphans;
+	int tcp_tws;
+	int tcp4_hashed;
+	int udp4;
+	int raw4;
+	int frag4;
+	int frag4_mem;
+	int tcp6_hashed;
+	int udp6;
+	int raw6;
+	int frag6;
+	int frag6_mem;
+};
+
+enum entry_types {
+	USERS,
+	PROC_CTX,
+	PROC_SOCK_CTX
+};
+#endif				/* SS_STRUCTS_H */
-- 
1.9.1
