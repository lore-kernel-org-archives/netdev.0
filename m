From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Tue, 27 Oct 2015 13:21:03 +0100
Message-ID: <20151027122103.GC26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39097 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202AbbJ0MVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 08:21:05 -0400
Content-Disposition: inline
In-Reply-To: <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 09:35:00PM +0200, Matthias Tafelmeier wrote:
> This patch creates a central formatter module that acts as a kind of
> switch. From there, more specific handler modules for the certain output
> formats are called. Up to now, humand readable and json do exist.
> 
> That prepares ss for potential output format extensions in the future.
> With the help of such an apparatus, extensions should get done
> conveniently as well.
> 
> For a completely new output format, a new handler module must be created
> and should be constructed like its relatives (for ex.: ss_json_fmt.c).
> Moreover, its functions need to get registered with the central output
> distributor. The latter can be done in that the according fmt_op_hub of
> the new handler module is registered in the fmt_op_hub array.
> 
> Solely extending tcp_stats output shall boil down to extending the
> according handler function with the new predicate and its value. The
> context of the output subparts are important. With JSON, for instance,
> you have to ensure, that the comas are set at the right places.
> 
> Further, an interim solution for all tcp_stats extensions is to check
> that all those muddle through to all fmt handlers by STATICAL_ASSERTING
> that.  Interim is the solution, since a central structure would be much
> more worthwile for maintainability and this method does not ensure
> correct output fmt extension in a foolproof manner.
> 
> Extension Examples:
> See according sub patches in these series.
> 
> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>  misc/Makefile      |   2 +-
>  misc/ss_hr_fmt.c   | 258 +++++++++++++++++++++++++++++++++
>  misc/ss_hr_fmt.h   |   9 ++
>  misc/ss_json_fmt.c | 408 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  misc/ss_json_fmt.h |  26 ++++
>  misc/ss_out_fmt.c  | 127 +++++++++++++++++
>  misc/ss_out_fmt.h  |  83 +++++++++++
>  7 files changed, 912 insertions(+), 1 deletion(-)
>  create mode 100644 misc/ss_hr_fmt.c
>  create mode 100644 misc/ss_hr_fmt.h
>  create mode 100644 misc/ss_json_fmt.c
>  create mode 100644 misc/ss_json_fmt.h
>  create mode 100644 misc/ss_out_fmt.c
>  create mode 100644 misc/ss_out_fmt.h
> 
> diff --git a/misc/Makefile b/misc/Makefile
> index 6185217..2fe3555 100644
> --- a/misc/Makefile
> +++ b/misc/Makefile
> @@ -1,4 +1,4 @@
> -SSOBJ=ss.o ssfilter.o
> +SSOBJ=ss.o ssfilter.o ss_hr_fmt.o ss_json_fmt.o ss_out_fmt.o
>  LNSTATOBJ=lnstat.o lnstat_util.o
>  
>  TARGETS=ss nstat ifstat rtacct arpd lnstat
> diff --git a/misc/ss_hr_fmt.c b/misc/ss_hr_fmt.c
> new file mode 100644
> index 0000000..2f09838
> --- /dev/null
> +++ b/misc/ss_hr_fmt.c
> @@ -0,0 +1,258 @@
> +#include <linux/sock_diag.h>
> +#include <linux/rtnetlink.h>
> +#include "ss_out_fmt.h"
> +#include "ss_types.h"
> +#include "ss_hr_fmt.h"
> +
> +static void tcp_stats_hr_fmt(struct tcpstat *s)
> +{
> +	char b1[64];
> +
> +	if (s->has_ts_opt)
> +		printf(" ts");
> +	if (s->has_sack_opt)
> +		printf(" sack");
> +	if (s->has_ecn_opt)
> +		printf(" ecn");
> +	if (s->has_ecnseen_opt)
> +		printf(" ecnseen");
> +	if (s->has_fastopen_opt)
> +		printf(" fastopen");
> +	if (s->cong_alg)
> +		printf(" %s", s->cong_alg);
> +	if (s->has_wscale_opt)
> +		printf(" wscale:%d,%d", s->snd_wscale, s->rcv_wscale);
> +	if (s->rto)
> +		printf(" rto:%g", s->rto);
> +	if (s->backoff)
> +		printf(" backoff:%u", s->backoff);
> +	if (s->rtt)
> +		printf(" rtt:%g/%g", s->rtt, s->rttvar);
> +	if (s->ato)
> +		printf(" ato:%g", s->ato);
> +
> +	if (s->qack)
> +		printf(" qack:%d", s->qack);
> +	if (s->qack & 1)
> +		printf(" bidir");
> +
> +	if (s->mss)
> +		printf(" mss:%d", s->mss);
> +	if (s->cwnd)
> +		printf(" cwnd:%d", s->cwnd);
> +	if (s->ssthresh)
> +		printf(" ssthresh:%d", s->ssthresh);
> +
> +	if (s->dctcp && s->dctcp->enabled) {
> +		struct dctcpstat *dctcp = s->dctcp;
> +
> +		printf(" dctcp:(ce_state:%u,alpha:%u,ab_ecn:%u,ab_tot:%u)",
> +		dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
> +		dctcp->ab_tot);
> +	} else if (s->dctcp) {
> +		printf(" dctcp:fallback_mode");
> +	}
> +
> +	if (s->send_bps)
> +		printf(" send %sbps", sprint_bw(b1, s->send_bps));
> +	if (s->lastsnd)
> +		printf(" lastsnd:%u", s->lastsnd);
> +	if (s->lastrcv)
> +		printf(" lastrcv:%u", s->lastrcv);
> +	if (s->lastack)
> +		printf(" lastack:%u", s->lastack);
> +
> +	if (s->pacing_rate) {
> +		printf(" pacing_rate %sbps", sprint_bw(b1, s->pacing_rate));
> +		if (s->pacing_rate_max)
> +			printf("/%sbps", sprint_bw(b1, s->pacing_rate_max));
> +	}
> +
> +	if (s->unacked)
> +		printf(" unacked:%u", s->unacked);
> +	if (s->retrans || s->retrans_total)
> +		printf(" retrans:%u/%u", s->retrans, s->retrans_total);
> +	if (s->lost)
> +		printf(" lost:%u", s->lost);
> +	if (s->sacked && s->ss.state != SS_LISTEN)
> +		printf(" sacked:%u", s->sacked);
> +	if (s->fackets)
> +		printf(" fackets:%u", s->fackets);
> +	if (s->reordering != 3)
> +		printf(" reordering:%d", s->reordering);
> +	if (s->rcv_rtt)
> +		printf(" rcv_rtt:%g", s->rcv_rtt);
> +
> +	CHECK_FMT_ADAPT(s->rcv_space, s,
> +	hr_handler_must_be_adapted_accordingly_when_json_fmt_is_extended);
> +}
> +
> +static void tcp_timer_hr_fmt(struct tcpstat *s)
> +{
> +	if (s->timer) {
> +		if (s->timer > 4)
> +			s->timer = 5;
> +		printf(" timer:(%s,%s,%d)",
> +		ss_timer_name[s->timer],
> +		print_ms_timer(s->timeout), s->retrans);
> +	}
> +}
> +
> +static void sock_state_hr_fmt(struct sockstat *s, const char **sstate_name,
> +		const char *sock_name, int netid_width, int state_width)
> +{
> +	if (netid_width)
> +		printf("%-*s ", netid_width, sock_name);
> +	if (state_width)
> +		printf("%-*s ", state_width, sstate_name[s->state]);
> +
> +	printf("%-6d %-6d ", s->rq, s->wq);
> +}
> +
> +static void sock_details_hr_fmt(struct sockstat *s, int type, unsigned groups,
> +			unsigned long long cb)
> +{
> +	if (type == GENERIC_DETAIL && s->uid)
> +		printf(" uid:%u", s->uid);
> +
> +	if (type == GENERIC_DETAIL) {
> +		printf(" ino:%u", s->ino);
> +		printf(" sk:%llx", s->sk);
> +	}
> +
> +	if (type == NETLINK_DETAIL)
> +		printf(" sk=%llx cb=%llx groups=0x%08x", s->sk, cb, groups);
> +
> +}
> +
> +static void sock_addr_hr_fmt(const char *addr, int addr_len,
> +		char *delim, int port_len,
> +		const char *port, const char *ifname,
> +		const char *peer_kind)
> +{
> +	if (ifname) {
> +		printf("%*s%%%s%s%-*s ", addr_len, addr, ifname, delim,
> +		port_len, port);
> +	} else {
> +		printf("%*s%s%-*s ", addr_len, addr, delim, port_len, port);
> +	}
> +}
> +
> +static void sock_users_hr_fmt(char *out)
> +{
> +	printf(" users:(%s)", out);
> +}
> +
> +static void sock_summary_hr_fmt(struct ssummary *s, struct snmpstat *sn,
> +			struct slabstat *slabstat)
> +{
> +	printf("Total: %d (kernel %d)\n", s->socks, slabstat->socks);
> +
> +	printf("TCP:   %d (estab %d, closed %d, orphaned %d,"
> +		"synrecv %d, timewait %d/%d), ports %d\n",
> +	s->tcp_total + slabstat->tcp_syns + s->tcp_tws, sn->tcp_estab,
> +	s->tcp_total - (s->tcp4_hashed + s->tcp6_hashed - s->tcp_tws),
> +	s->tcp_orphans, slabstat->tcp_syns, s->tcp_tws, slabstat->tcp_tws,
> +	slabstat->tcp_ports);
> +
> +	printf("\n");
> +	printf("Transport Total     IP        IPv6\n");
> +	printf("*	%-9d %-9s %-9s\n", slabstat->socks, "-", "-");
> +	printf("RAW	%-9d %-9d %-9d\n", s->raw4 + s->raw6, s->raw4,
> +	s->raw6);
> +	printf("UDP	%-9d %-9d %-9d\n", s->udp4 + s->udp6, s->udp4,
> +	s->udp6);
> +	printf("TCP	%-9d %-9d %-9d\n", s->tcp4_hashed + s->tcp6_hashed,
> +	s->tcp4_hashed, s->tcp6_hashed);
> +	printf("INET	%-9d %-9d %-9d\n",
> +	s->raw4 + s->udp4 + s->tcp4_hashed + s->raw6 + s->udp6 +
> +	s->tcp6_hashed, s->raw4 + s->udp4 + s->tcp4_hashed,
> +	s->raw6 + s->udp6 + s->tcp6_hashed);
> +	printf("FRAG	%-9d %-9d %-9d\n", s->frag4 + s->frag6, s->frag4,
> +	s->frag6);
> +
> +	printf("\n");
> +}
> +
> +static void sock_conn_hr_fmt(unsigned char mask)
> +{
> +	printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
> +}
> +
> +static void mem_hr_fmt(const struct inet_diag_meminfo *minfo)
> +{
> +	printf(" mem:(r%u,w%u,f%u,t%u)",
> +	minfo->idiag_rmem,
> +	minfo->idiag_wmem, minfo->idiag_fmem, minfo->idiag_tmem);
> +}
> +
> +static void skmem_hr_fmt(const __u32 *skmeminfo,
> +		struct rtattr **tb, int attrtype)
> +{
> +	printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
> +	skmeminfo[SK_MEMINFO_RMEM_ALLOC],
> +	skmeminfo[SK_MEMINFO_RCVBUF],
> +	skmeminfo[SK_MEMINFO_WMEM_ALLOC],
> +	skmeminfo[SK_MEMINFO_SNDBUF],
> +	skmeminfo[SK_MEMINFO_FWD_ALLOC],
> +	skmeminfo[SK_MEMINFO_WMEM_QUEUED], skmeminfo[SK_MEMINFO_OPTMEM]);
> +
> +	if (RTA_PAYLOAD(tb[attrtype]) >=
> +	(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
> +		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
> +
> +	printf(")");
> +}
> +
> +static void bpf_filter_hr_fmt(struct sock_filter *fil, int num)
> +{
> +	printf("\n\tbpf filter (%d): ", num);
> +	while (num) {
> +		printf(" 0x%02x %u %u %u,",
> +		fil->code, fil->jt, fil->jf, fil->k);
> +		num--;
> +		fil++;
> +	}
> +}
> +
> +static void opt_hr_fmt(char *opt)
> +{
> +	printf(" opt:\"%s\"", opt);
> +}
> +
> +static void proc_hr_fmt(int serv_width, char *pid_ctx)
> +{
> +	if (pid_ctx != NULL) {
> +		printf("proc_ctx=%-*s ", serv_width, pid_ctx);
> +		free(pid_ctx);
> +	} else {
> +		printf("proc_ctx=%-*s ", serv_width, "unavailable");
> +	}
> +}
> +
> +static void packet_show_ring_hr_fmt(struct packet_diag_ring *ring)
> +{
> +	printf("blk_size:%d", ring->pdr_block_size);
> +	printf(",blk_nr:%d", ring->pdr_block_nr);
> +	printf(",frm_size:%d", ring->pdr_frame_size);
> +	printf(",frm_nr:%d", ring->pdr_frame_nr);
> +	printf(",tmo:%d", ring->pdr_retire_tmo);
> +	printf(",features:0x%x", ring->pdr_features);
> +}
> +
> +const struct fmt_op_hub hr_output_op = {
> +	.tcp_stats_fmt = tcp_stats_hr_fmt,
> +	.tcp_timer_fmt = tcp_timer_hr_fmt,
> +	.sock_state_fmt = sock_state_hr_fmt,
> +	.sock_details_fmt = sock_details_hr_fmt,
> +	.sock_addr_fmt = sock_addr_hr_fmt,
> +	.sock_users_fmt = sock_users_hr_fmt,
> +	.sock_summary_fmt = sock_summary_hr_fmt,
> +	.sock_conn_fmt = sock_conn_hr_fmt,
> +	.mem_fmt = mem_hr_fmt,
> +	.skmem_fmt = skmem_hr_fmt,
> +	.bpf_filter_fmt = bpf_filter_hr_fmt,
> +	.opt_fmt = opt_hr_fmt,
> +	.proc_fmt = proc_hr_fmt,
> +	.packet_show_ring_fmt = packet_show_ring_hr_fmt,
> +};
> diff --git a/misc/ss_hr_fmt.h b/misc/ss_hr_fmt.h
> new file mode 100644
> index 0000000..969fb17
> --- /dev/null
> +++ b/misc/ss_hr_fmt.h
> @@ -0,0 +1,9 @@
> +#ifndef SS_HR_FMT_H
> +#define SS_HR_FMT_H
> +
> +#include <linux/inet_diag.h>
> +#include <linux/pkt_sched.h>
> +#include <linux/filter.h>
> +#include "ss_types.h"
> +
> +#endif				/* SS_HR_FMT_H */

Is it necessary to include these headers here? I usually try to avoid
including headers from other headers if not too inconvenient.

OTOH this file seems to be the counterpart to ss_json_fmt.h, but without
real content it's of little use. Not sure if following patches populate
it further, but if it stays like this I'd rather drop it and include the
above headers directly where they are needed instead.

> diff --git a/misc/ss_json_fmt.c b/misc/ss_json_fmt.c
> new file mode 100644
> index 0000000..a927952
> --- /dev/null
> +++ b/misc/ss_json_fmt.c
> @@ -0,0 +1,408 @@
> +#include <linux/sock_diag.h>
> +#include <inttypes.h>
> +#include <linux/rtnetlink.h>
> +#include <json_writer.h>
> +#include <stdio.h>
> +#include "ss_out_fmt.h"
> +#include "ss_types.h"
> +#include "ss_json_fmt.h"
> +
> +#define SHOW_TCP_INFO	(show_tcpinfo && \
> +			(ss_current_filter.dbs & (1<<TCP_DB) || \
> +			ss_current_filter.dbs & (1<<DCCP_DB)))
> +#define SHOW_MEM	(show_mem && \
> +			ss_current_filter.dbs & (1<<UDP_DB) || \
> +			ss_current_filter.dbs & (1<<TCP_DB))
> +
> +/* generic auxiliary mechanism for json related dangling delimiter issues*/
> +void res_json_fmt_branch(int pred, char bound)
> +{
> +	if (pred) {
> +		if (bound == ' ') {
> +			printf(",");
> +			goto newl;
> +		}
> +		printf("%c,", bound);
> +	} else {
> +		if (bound == ' ')
> +			goto newl;
> +		printf("%c", bound);
> +	}
> + newl:
> +	printf("\n");
> +}
> +
> +static void make_userout_valid(char *out)
> +{
> +	/*replace quote (") by space */
> +	char *tmp;
> +
> +	while ((tmp = strstr(out, "\"")) != NULL)
> +		*tmp = ' ';
> +}
> +
> +static void print_serv_or_port(char *serv_o_port)
> +{
> +	char buf[8];
> +
> +	if (resolve_services == 0)
> +		strcpy(buf, "port");
> +	else
> +		strcpy(buf, "service");
> +
> +	jsonw_string_field(json_wr, buf, serv_o_port);
> +}

How about:
#define SVCNAME (resolve_services ? "service" : "port")

> +
> +/* hex conversion helper */
> +static void jsonw_hex_as_str_outp(json_writer_t *self, uint64_t num)
> +{
> +	char tmp[17];
> +
> +	sprintf(tmp, "%"PRIx64, num);
> +	jsonw_string(self, tmp);
> +}
> +
> +static void jsonw_hex_field_outp(json_writer_t *self, const char *prop, uint64_t num)
> +{
> +	jsonw_name(self, prop);
> +	jsonw_hex_as_str_outp(self, num);
> +}
> +
> +static void tcp_stats_json_fmt(struct tcpstat *s)
> +{
> +	char b1[64];
> +
> +	if (s->has_ts_opt)
> +		jsonw_bool_field(json_wr, "ts", true);

Human readable output tries to limit the output by printing those flags
only if present. While this makes parsing the output harder, it is
convenient for humans. In case of json output, I don't see the benefit
here. So I'd rather:

	json_bool_field(json_wr, "ts", s->has_ts_opt);

This simplifies the code here and probably parsing as well.

> +	if (s->has_sack_opt)
> +		jsonw_bool_field(json_wr, "sack", true);
> +	if (s->has_ecn_opt)
> +		jsonw_bool_field(json_wr, "ecn", true);
> +	if (s->has_ecnseen_opt)
> +		jsonw_bool_field(json_wr, "ecnseen", true);
> +	if (s->has_fastopen_opt)
> +		jsonw_bool_field(json_wr, "fastopen", true);
> +	if (s->cong_alg)
> +		jsonw_bool_field(json_wr, "cong_alg", true);
> +	if (s->has_wscale_opt) {
> +		jsonw_name(json_wr, "wscale");
> +		jsonw_start_object(json_wr);

How about a wrapper:

		jsonw_start_object-name(json_wr, "wscale");


> +		jsonw_int_field(json_wr, "snd", s->snd_wscale);
> +		jsonw_int_field(json_wr, "rcv", s->rcv_wscale);
> +		jsonw_end_object(json_wr);
> +	}
> +	if (s->rto)
> +		jsonw_float_field(json_wr, "rto", s->rto);
> +	if (s->backoff)
> +		jsonw_uint_field(json_wr, "backoff", s->backoff);
> +	if (s->rtt)
> +		jsonw_float_field(json_wr, "rtt", s->rtt/s->rttvar);
> +	if (s->ato)
> +		jsonw_float_field(json_wr, "ato", s->ato);
> +	if (s->qack)
> +		jsonw_int_field(json_wr, "quack", s->qack);
> +	if (s->qack & 1)
> +		jsonw_bool_field(json_wr, "bidir", true);
> +	if (s->mss)
> +		jsonw_int_field(json_wr, "mss", s->mss);
> +	if (s->cwnd && s->cwnd != 2)
> +		jsonw_int_field(json_wr, "cwnd", s->cwnd);
> +	if (s->ssthresh)
> +		jsonw_int_field(json_wr, "ssthresh", s->ssthresh);
> +	if (s->dctcp && s->dctcp->enabled) {
> +		struct dctcpstat *dctcp = s->dctcp;
> +
> +		jsonw_name(json_wr, "dctcpinfo");
> +		jsonw_start_object(json_wr);
> +		jsonw_uint_field(json_wr, "ce_state", dctcp->ce_state);
> +		jsonw_uint_field(json_wr, "alpha", dctcp->alpha);
> +		jsonw_uint_field(json_wr, "ab_ecn", dctcp->ab_ecn);
> +		jsonw_uint_field(json_wr, "ab_tot", dctcp->ab_tot);
> +		jsonw_end_object(json_wr);
> +	} else if (s->dctcp) {
> +		jsonw_bool_field(json_wr, "fallback_mode", true);
> +	}
> +	if (s->send_bps)
> +		jsonw_string_field(json_wr, "send_bps",
> +			      sprint_bw(b1, s->send_bps));
> +	if (s->lastsnd)
> +		jsonw_uint_field(json_wr, "lastsnd", s->lastsnd);
> +	if (s->lastrcv)
> +		jsonw_uint_field(json_wr, "lastrcv", s->lastsnd);
> +	if (s->lastack)
> +		jsonw_uint_field(json_wr, "lastack", s->lastsnd);

More or less same as above: Json parsers will know what it means if
these fields are zero. So I don't see why they should not be
unconditionally included into the output?

> +	if (s->pacing_rate) {
> +		jsonw_name(json_wr, "pacing_rate");
> +		jsonw_start_object(json_wr);
> +		jsonw_string_field(json_wr, "pacing_rate_bps",
> +		sprint_bw(b1, s->pacing_rate));
> +		if (s->pacing_rate_max)
> +			jsonw_string_field(json_wr, "pacing_rate_max_bps",
> +				  sprint_bw(b1, s->pacing_rate_max));
> +		jsonw_end_object(json_wr);
> +	}
> +	if (s->unacked)
> +		jsonw_uint_field(json_wr, "unacked", s->unacked);
> +	if (s->retrans || s->retrans_total) {
> +		jsonw_name(json_wr, "retrans_obj");
> +		jsonw_start_object(json_wr);
> +		jsonw_uint_field(json_wr, "retrans", s->retrans);
> +		jsonw_uint_field(json_wr, "retrans_total", s->retrans_total);
> +		jsonw_end_object(json_wr);
> +	}
> +	if (s->lost)
> +		jsonw_uint_field(json_wr, "lost", s->lost);
> +	if (s->sacked && (s->ss.state != SS_LISTEN))
> +		jsonw_uint_field(json_wr, "sacked", s->sacked);
> +	if (s->fackets)
> +		jsonw_uint_field(json_wr, "fackets", s->fackets);
> +	if (s->reordering != 3)
> +		jsonw_int_field(json_wr, "reordering", s->reordering);
> +	if (s->rcv_rtt)
> +		jsonw_float_field(json_wr, "rcv_rtt", s->rcv_rtt);
> +
> +	/*deal with special case */
> +	res_json_fmt_branch(s->ss.state == SS_LISTEN, ' ');
> +
> +	CHECK_FMT_ADAPT(s->rcv_space, s,
> +	json_handler_must_be_adapted_accordingly_when_hr_fmt_is_extended);
> +}
> +
> +static void tcp_timer_json_fmt(struct tcpstat *s)
> +{
> +
> +	if (s->timer)
> +		if (s->timer > 4)
> +			s->timer = 5;
> +	jsonw_name(json_wr, "timer");
> +	jsonw_start_object(json_wr);
> +	jsonw_string_field(json_wr, "ss_timer_name",
> +			ss_timer_name[s->timer]);
> +	jsonw_string_field(json_wr, "print_ms_timer",
> +			print_ms_timer(s->timeout));
> +	jsonw_int_field(json_wr, "retrans", s->retrans);
> +	jsonw_end_object(json_wr);
> +}
> +
> +static void sock_state_json_fmt(struct sockstat *s, const char **sstate_name,
> +			const char *sock_name, int netid_width,
> +			int state_width)
> +{
> +
> +	if (netid_width)
> +		jsonw_string_field(json_wr, "Netid", sock_name);
> +
> +	if (state_width)
> +		jsonw_string_field(json_wr, "State", sstate_name[s->state]);

This raises the question if json output should be limited at all.
Assuming that it will be parsed and formatted before presented to humans
anyway, the only reason to allow for filters and the like to be applied
if json output is active to limit the amount of data generated. OTOH it
makes code handling the data less flexible, e.g. if you wanted to
present the data on a web page you might have to repeat the call to ss
with different options if I decided to show the Netid column of given
output as well. And maybe that's not desireable at all, since the output
might change and I'm interested in the open sockets at the time I opened
the page instead of at the time I changed the display. I'm not a big fan
of MVC either, but disconnecting the view from the data collecting is
IMHO a useful thing to do.

> +
> +	jsonw_int_field(json_wr, "Recv-Q", s->rq);
> +	jsonw_int_field(json_wr, "Send-Q", s->wq);
> +}
> +
> +static void sock_details_json_fmt(struct sockstat *s, int type, unsigned groups,
> +			unsigned long long cb)
> +{
> +	if (type == GENERIC_DETAIL && s->uid)
> +		jsonw_uint_field(json_wr, "uid", s->uid);
> +	if (type == GENERIC_DETAIL)
> +		jsonw_uint_field(json_wr, "ino", s->sk);
> +	jsonw_hex_field_outp(json_wr, "sk", s->sk);
> +
> +	if (type == NETLINK_DETAIL) {
> +		jsonw_hex_field_outp(json_wr, "cb", cb);
> +		jsonw_hex_field_outp(json_wr, "groups=0x", groups);
> +	}
> +}
> +
> +static void sock_addr_json_fmt(const char *addr, int addr_len, char *delim,
> +			int port_len, const char *port, const char *ifname,
> +			const char *peer_kind)
> +{
> +	jsonw_name(json_wr, peer_kind);
> +	jsonw_start_object(json_wr);
> +	jsonw_string_field(json_wr, "addr", addr);
> +	if (NULL != ifname)
> +		jsonw_string_field(json_wr, "interface", ifname);
> +	print_serv_or_port((char *)port);
> +	jsonw_end_object(json_wr);
> +}
> +
> +static void sock_users_json_fmt(char *out)
> +{
> +	make_userout_valid(out);
> +
> +	jsonw_string_field(json_wr, "users", out);
> +}
> +
> +static void sock_summary_json_fmt(struct ssummary *s, struct snmpstat *sn,
> +			struct slabstat *slabstat)
> +{
> +	jsonw_name(json_wr, "summary");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "total", s->socks);
> +	jsonw_int_field(json_wr, "kernel", slabstat->socks);
> +
> +	jsonw_name(json_wr, "TCP");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "total",
> +			s->tcp_total + slabstat->tcp_syns + s->tcp_tws);
> +	jsonw_int_field(json_wr, "estab", sn->tcp_estab);
> +	jsonw_int_field(json_wr, "closed",
> +			s->tcp_total - (s->tcp4_hashed + s->tcp6_hashed - s->tcp_tws));
> +	jsonw_int_field(json_wr, "orphaned", s->tcp_orphans);
> +	jsonw_int_field(json_wr, "synrecv", slabstat->tcp_syns);
> +	jsonw_name(json_wr, "timewait");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "ssummary_tcp_tws", s->tcp_tws);
> +	jsonw_int_field(json_wr, "slabstat_tcp_tws", slabstat->tcp_tws);
> +	jsonw_end_object(json_wr);
> +	jsonw_int_field(json_wr, "ports", slabstat->tcp_ports);
> +	jsonw_end_object(json_wr);
> +
> +	jsonw_name(json_wr, "trans_over_net_prop");
> +	jsonw_start_object(json_wr);
> +	jsonw_name(json_wr, "*");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "Total", slabstat->socks);
> +	jsonw_string_field(json_wr, "IP", "-");
> +	jsonw_string_field(json_wr, "IPv6", "-");
> +	jsonw_end_object(json_wr);
> +	jsonw_end_object(json_wr);
> +
> +	jsonw_name(json_wr, "RAW");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "Total", s->raw4 + s->raw6);
> +	jsonw_int_field(json_wr, "IP", s->raw4);
> +	jsonw_int_field(json_wr, "IPv6", s->raw6);
> +	jsonw_end_object(json_wr);
> +
> +	jsonw_name(json_wr, "UDP");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "Total", s->udp4 + s->udp6);
> +	jsonw_int_field(json_wr, "IP", s->udp4);
> +	jsonw_int_field(json_wr, "IPv6", s->udp6);
> +	jsonw_end_object(json_wr);
> +
> +	jsonw_name(json_wr, "TCP");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "Total", s->tcp4_hashed + s->tcp6_hashed);
> +	jsonw_int_field(json_wr, "IP", s->tcp4_hashed);
> +	jsonw_int_field(json_wr, "IPv6", s->tcp6_hashed);
> +	jsonw_end_object(json_wr);
> +
> +	jsonw_name(json_wr, "INET");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "Total",
> +			s->raw4 + s->udp4 + s->tcp4_hashed +
> +			s->raw6 + s->udp6 + s->tcp6_hashed);
> +	jsonw_int_field(json_wr, "IP", s->raw4 + s->udp4 + s->tcp4_hashed);
> +	jsonw_int_field(json_wr, "IPv6", s->raw6 + s->udp6 + s->tcp6_hashed);
> +	jsonw_end_object(json_wr);
> +
> +	jsonw_name(json_wr, "FRAG");
> +	jsonw_start_object(json_wr);
> +	jsonw_int_field(json_wr, "Total", s->frag4 + s->frag6);
> +	jsonw_int_field(json_wr, "IP", s->frag4);
> +	jsonw_int_field(json_wr, "IPv6", s->frag6);
> +	jsonw_end_object(json_wr);
> +
> +	jsonw_end_object(json_wr);
> +}
> +
> +static void sock_conn_json_fmt(unsigned char mask)
> +{
> +	char tmp[4];
> +
> +	sprintf(tmp, "%c-%c",  mask & 1 ? '-' : '<',
> +	mask & 2 ? '-' : '>');
> +	jsonw_string_field(json_wr, "shutdown", tmp);
> +}
> +
> +static void mem_json_fmt(const struct inet_diag_meminfo *minfo)
> +{
> +	jsonw_name(json_wr, "mem");
> +	jsonw_start_object(json_wr);
> +	jsonw_uint_field(json_wr, "r", minfo->idiag_rmem);
> +	jsonw_uint_field(json_wr, "w", minfo->idiag_wmem);
> +	jsonw_uint_field(json_wr, "f", minfo->idiag_fmem);
> +	jsonw_uint_field(json_wr, "t", minfo->idiag_fmem);
> +	jsonw_end_object(json_wr);
> +}
> +
> +static void skmem_json_fmt(const __u32 *skmeminfo, struct rtattr **tb,
> +		int attrtype)
> +{
> +	jsonw_name(json_wr, "skmem");
> +	jsonw_start_object(json_wr);
> +	jsonw_uint_field(json_wr, "r", skmeminfo[SK_MEMINFO_RMEM_ALLOC]);
> +	jsonw_uint_field(json_wr, "rb", skmeminfo[SK_MEMINFO_RCVBUF]);
> +	jsonw_uint_field(json_wr, "t", skmeminfo[SK_MEMINFO_WMEM_ALLOC]);
> +	jsonw_uint_field(json_wr, "tb", skmeminfo[SK_MEMINFO_SNDBUF]);
> +	jsonw_uint_field(json_wr, "f", skmeminfo[SK_MEMINFO_FWD_ALLOC]);
> +	jsonw_uint_field(json_wr, "w", skmeminfo[SK_MEMINFO_WMEM_QUEUED]);
> +	jsonw_uint_field(json_wr, "o", skmeminfo[SK_MEMINFO_OPTMEM]);
> +	if (RTA_PAYLOAD(tb[attrtype]) >=
> +	(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
> +		jsonw_uint_field(json_wr, "bl", skmeminfo[SK_MEMINFO_BACKLOG]);
> +	jsonw_end_object(json_wr);
> +}
> +
> +static void bpf_filter_json_fmt(struct sock_filter *fil, int num)
> +{
> +	jsonw_name(json_wr, "bpf_filter");
> +	jsonw_start_array(json_wr);
> +	jsonw_int(json_wr, num);
> +	while (num) {
> +		jsonw_start_object(json_wr);
> +		jsonw_hex_as_str_outp(json_wr, fil->code);
> +		jsonw_uint(json_wr, fil->jt);
> +		jsonw_uint(json_wr, fil->jf);
> +		jsonw_uint(json_wr, fil->k);
> +		jsonw_int(json_wr, num--);
> +		fil++;
> +		jsonw_end_object(json_wr);
> +	}
> +	jsonw_end_array(json_wr);
> +}
> +
> +static void opt_json_fmt(char *opt)
> +{
> +	jsonw_string_field(json_wr, "opt", opt);
> +}
> +
> +static void proc_json_fmt(int serv_width, char *pid_ctx)
> +{
> +	if (pid_ctx != NULL) {
> +		jsonw_string_field(json_wr, "proc_ctx", pid_ctx);
> +		free(pid_ctx);
> +	} else {
> +		jsonw_string_field(json_wr, "proc_ctx", "unavailable");
> +	}
> +}
> +
> +static void packet_show_ring_json_fmt(struct packet_diag_ring *ring)
> +{
> +	jsonw_int_field(json_wr, "blk_size", ring->pdr_block_size);
> +	jsonw_int_field(json_wr, "blk_nr", ring->pdr_block_nr);
> +	jsonw_int_field(json_wr, "frm_size", ring->pdr_frame_size);
> +	jsonw_int_field(json_wr, "frm_nr", ring->pdr_frame_nr);
> +	jsonw_int_field(json_wr, "tmo", ring->pdr_retire_tmo);
> +	jsonw_hex_field_outp(json_wr, "features_0x", ring->pdr_features);
> +}
> +
> +const struct fmt_op_hub json_output_op = {
> +	.tcp_stats_fmt = tcp_stats_json_fmt,
> +	.tcp_timer_fmt = tcp_timer_json_fmt,
> +	.sock_state_fmt = sock_state_json_fmt,
> +	.sock_details_fmt = sock_details_json_fmt,
> +	.sock_addr_fmt = sock_addr_json_fmt,
> +	.sock_users_fmt = sock_users_json_fmt,
> +	.sock_summary_fmt = sock_summary_json_fmt,
> +	.sock_conn_fmt = sock_conn_json_fmt,
> +	.mem_fmt = mem_json_fmt,
> +	.skmem_fmt = skmem_json_fmt,
> +	.bpf_filter_fmt = bpf_filter_json_fmt,
> +	.opt_fmt = opt_json_fmt,
> +	.proc_fmt = proc_json_fmt,
> +	.packet_show_ring_fmt = packet_show_ring_json_fmt,
> +};
> diff --git a/misc/ss_json_fmt.h b/misc/ss_json_fmt.h
> new file mode 100644
> index 0000000..13a6f1d
> --- /dev/null
> +++ b/misc/ss_json_fmt.h
> @@ -0,0 +1,26 @@
> +#ifndef SS_JSON_FMT_H
> +#define SS_JSON_FMT_H
> +
> +#include <linux/inet_diag.h>
> +#include <linux/pkt_sched.h>
> +#include <linux/filter.h>
> +#include <json_writer.h>
> +#include "ss_types.h"
> +
> +extern int json_output;
> +extern json_writer_t *json_wr;
> +extern int resolve_services;
> +extern int show_options;
> +extern int show_details;
> +extern int show_users;
> +extern int show_mem;
> +extern int show_tcpinfo;
> +extern int show_bpf;
> +extern int show_proc_ctx;
> +extern int show_sock_ctx;
> +extern struct filter ss_current_filter;
> +
> +/*generic auxiliary mechanism for json related dangling delimiter issues*/
> +void res_json_fmt_branch(int pred, char bound);
> +
> +#endif				/* SS_JSON_FMT_H */
> diff --git a/misc/ss_out_fmt.c b/misc/ss_out_fmt.c
> new file mode 100644
> index 0000000..57bc24e
> --- /dev/null
> +++ b/misc/ss_out_fmt.c
> @@ -0,0 +1,127 @@
> +#include <stdio.h>
> +#include "ss_out_fmt.h"
> +const struct fmt_op_hub *fmt_op_hub[] = {
> +	/*human readble */
> +	&hr_output_op,
> +	/*json */
> +	&json_output_op
> +};
> +
> +
> +
> +char *sprint_bw(char *buf, double bw)
> +{
> +	if (bw > 1000000.)
> +		sprintf(buf, "%.1fM", bw / 1000000.);
> +	else if (bw > 1000.)
> +		sprintf(buf, "%.1fK", bw / 1000.);
> +	else
> +		sprintf(buf, "%g", bw);
> +
> +	return buf;
> +}
> +
> +char *print_ms_timer(int timeout)
> +{
> +	static char buf[64];
> +	int secs, msecs, minutes;
> +
> +	if (timeout < 0)
> +		timeout = 0;
> +	secs = timeout / 1000;
> +	minutes = secs / 60;
> +	secs = secs % 60;
> +	msecs = timeout % 1000;
> +	buf[0] = 0;
> +	if (minutes) {
> +		msecs = 0;
> +		snprintf(buf, sizeof(buf) - 16, "%dmin", minutes);
> +		if (minutes > 9)
> +			secs = 0;
> +	}
> +	if (secs) {
> +		if (secs > 9)
> +			msecs = 0;
> +		sprintf(buf + strlen(buf), "%d%s", secs, msecs ? "." : "sec");
> +	}
> +	if (msecs)
> +		sprintf(buf + strlen(buf), "%03dms", msecs);
> +	return buf;
> +}
> +
> +void tcp_stats_fmt(struct tcpstat *s)
> +{
> +	fmt_op_hub[fmt_type]->tcp_stats_fmt(s);
> +}
> +
> +void tcp_timer_fmt(struct tcpstat *s)
> +{
> +	fmt_op_hub[fmt_type]->tcp_timer_fmt(s);
> +}
> +
> +void sock_state_fmt(struct sockstat *s, const char **sstate_name,
> +		const char *sock_name, int netid_width, int state_width)
> +{
> +	fmt_op_hub[fmt_type]->sock_state_fmt(s, sstate_name, sock_name,
> +					netid_width, state_width);
> +}
> +
> +void sock_details_fmt(struct sockstat *s, int type,
> +		unsigned groups, unsigned long long cb)
> +{
> +	fmt_op_hub[fmt_type]->sock_details_fmt(s, type, groups, cb);
> +}
> +
> +void sock_addr_fmt(const char *addr, int addr_len, char *delim,
> +		int port_len, const char *port, const char *ifname,
> +		const char *peer_kind)
> +{
> +	fmt_op_hub[fmt_type]->sock_addr_fmt(addr, addr_len,
> +					delim, port_len, port, ifname,
> +					peer_kind);
> +}
> +
> +void sock_users_fmt(char *out)
> +{
> +	fmt_op_hub[fmt_type]->sock_users_fmt(out);
> +}
> +
> +void sock_summary_fmt(struct ssummary *s, struct snmpstat *sn,
> +		struct slabstat *slabstat)
> +{
> +	fmt_op_hub[fmt_type]->sock_summary_fmt(s, sn, slabstat);
> +}
> +
> +void sock_conn_fmt(unsigned char mask)
> +{
> +	fmt_op_hub[fmt_type]->sock_conn_fmt(mask);
> +}
> +
> +void mem_fmt(const struct inet_diag_meminfo *minfo)
> +{
> +	fmt_op_hub[fmt_type]->mem_fmt(minfo);
> +}
> +
> +void skmem_fmt(const __u32 *skmeminfo, struct rtattr **tb, int attrtype)
> +{
> +	fmt_op_hub[fmt_type]->skmem_fmt(skmeminfo, tb, attrtype);
> +}
> +
> +void bpf_filter_fmt(struct sock_filter *f, int num)
> +{
> +	fmt_op_hub[fmt_type]->bpf_filter_fmt(f, num);
> +}
> +
> +void opt_fmt(char *opt)
> +{
> +	fmt_op_hub[fmt_type]->opt_fmt(opt);
> +}
> +
> +void proc_fmt(int serv_width, char *pid_ctx)
> +{
> +	fmt_op_hub[fmt_type]->proc_fmt(serv_width, pid_ctx);
> +}
> +void packet_show_ring_fmt(struct packet_diag_ring *ring)
> +{
> +	fmt_op_hub[fmt_type]->packet_show_ring_fmt(ring);
> +}
> diff --git a/misc/ss_out_fmt.h b/misc/ss_out_fmt.h
> new file mode 100644
> index 0000000..8608cde
> --- /dev/null
> +++ b/misc/ss_out_fmt.h
> @@ -0,0 +1,83 @@
> +#ifndef SS_OUT_FMT_H
> +#define SS_OUT_FMT_H
> +
> +#include "ss_hr_fmt.h"
> +#include "ss_json_fmt.h"
> +#include "ss_types.h"
> +#include <utils.h>
> +#include <linux/inet_diag.h>
> +#include <linux/pkt_sched.h>
> +#include <linux/filter.h>
> +#include <linux/netdevice.h>
> +#include <linux/packet_diag.h>
> +
> +#define GENERIC_DETAIL 0
> +#define NETLINK_DETAIL 1
> +
> +/* when extending the tcp fmt handler,
> + * you have to pass the last cond of the tcp_stats
> + * struct as sentinel to this macro to ensure compilability
> + * of ss: this enforces a symmetrical extension of the
> + * individual formatting handlers (json, human readable)
> + */
> +#define CHECK_FMT_ADAPT(SENTINEL, BEGIN) \
> +	BUILD_BUG_ON(!((((void *)&SENTINEL - (void *)BEGIN) + sizeof(SENTINEL)) \
> +	/ sizeof(*BEGIN)))
> +
> +
> +extern int json_output;
> +extern enum out_fmt_type fmt_type;
> +extern const struct fmt_op_hub hr_output_op;
> +extern const struct fmt_op_hub json_output_op;
> +extern const char *ss_timer_name[];
> +
> +enum out_fmt_type { FMT_HR, FMT_JSON };
> +
> +struct fmt_op_hub {
> +	void (*tcp_stats_fmt)(struct tcpstat *s);
> +	void (*tcp_timer_fmt)(struct tcpstat *s);
> +	void (*sock_state_fmt)(struct sockstat *s, const char **sstate_name,
> +				const char *sock_name, int netid_width,
> +				int state_width);
> +	void (*sock_details_fmt)(struct sockstat *s, int type,
> +				unsigned groups, unsigned long long cb);
> +	void (*sock_addr_fmt)(const char *addr, int addr_len, char *delim,
> +			int port_len, const char *port,
> +			const char *ifname, const char *peer_kind);
> +	void (*sock_users_fmt)(char *out);
> +	void (*sock_summary_fmt)(struct ssummary *s, struct snmpstat *sn,
> +				struct slabstat *slabstat);
> +	void (*sock_conn_fmt)(unsigned char mask);
> +	void (*mem_fmt)(const struct inet_diag_meminfo *minfo);
> +	void (*skmem_fmt)(const __u32 *skmeminfo, struct rtattr **tb,
> +			int attrtype);
> +	void (*bpf_filter_fmt)(struct sock_filter *f, int num);
> +	void (*opt_fmt)(char *opt);
> +	void (*proc_fmt)(int serv_width, char *pid_ctx);
> +	void (*packet_show_ring_fmt)(struct packet_diag_ring *ring);
> +};
> +
> +void tcp_stats_fmt(struct tcpstat *s);
> +void tcp_timer_fmt(struct tcpstat *s);
> +void sock_state_fmt(struct sockstat *s, const char **sstate_name,
> +		const char *sock_name, int netid_width, int state_width);
> +void sock_details_fmt(struct sockstat *s, int type,
> +		unsigned groups, unsigned long long cb);
> +void sock_addr_fmt(const char *addr, int addr_len, char *delim, int port_len,
> +		const char *port, const char *ifname, const char *peer_kind);
> +void sock_users_fmt(char *out);
> +void sock_summary_fmt(struct ssummary *s, struct snmpstat *sn,
> +		struct slabstat *slabstat);
> +void sock_conn_fmt(unsigned char mask);
> +void mem_fmt(const struct inet_diag_meminfo *minfo);
> +void skmem_fmt(const __u32 *skmeminfo, struct rtattr **tb, int attrtype);
> +void bpf_filter_fmt(struct sock_filter *f, int num);
> +void opt_fmt(char *opt);
> +void proc_fmt(int serv_width, char *pid_ctx);
> +void packet_show_ring_fmt(struct packet_diag_ring *ring);
> +
> +/*unisonly utilized formatting parts*/
> +char *sprint_bw(char *buf, double bw);
> +char *print_ms_timer(int timeout);
> +
> +#endif				/* SS_OUT_FMT_H */
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
