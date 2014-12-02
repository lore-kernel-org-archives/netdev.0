From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] tcp: Add TCP tracer
Date: Tue, 2 Dec 2014 12:40:20 -0800
Message-ID: <20141202204020.GA6443@devbig242.prn2.facebook.com>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
 <1417552662-16398-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57141 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754007AbaLBUk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:40:29 -0500
Content-Disposition: inline
In-Reply-To: <1417552662-16398-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore this patch which is not completely ready. It is sent out by
mistake.

On Tue, Dec 02, 2014 at 12:37:42PM -0800, Martin KaFai Lau wrote:
> Define probes and register them to the TCP tracepoints.  The probes
> collect the data defined in struct tcp_sk_trace and record them to
> the tracing's ring_buffer.
> ---
>  include/uapi/linux/tcp_trace.h |   9 +-
>  kernel/trace/tcp_trace.c       | 448 +++++++++++++++++++++++++++++++++++++++++
>  kernel/trace/trace.h           |   1 +
>  3 files changed, 451 insertions(+), 7 deletions(-)
> 
> diff --git a/include/uapi/linux/tcp_trace.h b/include/uapi/linux/tcp_trace.h
> index 2644f7f..d913a3c 100644
> --- a/include/uapi/linux/tcp_trace.h
> +++ b/include/uapi/linux/tcp_trace.h
> @@ -22,11 +22,11 @@ struct tcp_stats {
>  	__u32	other_segs_retrans;
>  	__u32	other_octets_retrans;
>  	__u32	loss_segs_retrans;
> -	__u32	loss_octects_retrans;
> +	__u32	loss_octets_retrans;
>  	__u32	segs_in;
>  	__u32	data_segs_in;
> -	__u64	rtt_sample_us;
>  	__u64	data_octets_in;
> +	__u64	rtt_sample_us;
>  	__u64	max_rtt_us;
>  	__u64	min_rtt_us;
>  	__u64   sum_rtt_us;
> @@ -64,9 +64,4 @@ struct tcp_trace_stats {
>          struct tcp_stats stats;
>  } __packed;
>  
> -typedef struct tcp_trace_basic tcp_trace_establish;
> -typedef struct tcp_trace_basic tcp_trace_retrans;
> -typedef struct tcp_trace_stats tcp_trace_periodic;
> -typedef struct tcp_trace_stats tcp_trace_close;
> -
>  #endif /* UAPI_TCP_TRACE_H */
> diff --git a/kernel/trace/tcp_trace.c b/kernel/trace/tcp_trace.c
> index 9d09fd0..376580b 100644
> --- a/kernel/trace/tcp_trace.c
> +++ b/kernel/trace/tcp_trace.c
> @@ -1,9 +1,27 @@
>  #include <net/tcp_trace.h>
> +#include <net/tcp.h>
> +#include <trace/events/tcp.h>
>  #include <linux/tcp.h>
> +#include <linux/ipv6.h>
> +#include <linux/ftrace_event.h>
> +#include <linux/jiffies.h>
>  #include <uapi/linux/tcp_trace.h>
>  
> +#include "trace_output.h"
> +
> +#define REPORT_INTERVAL_MS 2000
> +
> +static struct trace_array *tcp_tr;
>  static bool tcp_trace_enabled __read_mostly;
>  
> +static struct trace_print_flags tcp_trace_event_names[] = {
> +	{ TCP_TRACE_EVENT_ESTABLISHED, "established" },
> +	{ TCP_TRACE_EVENT_PERIODIC, "periodic" },
> +	{ TCP_TRACE_EVENT_RETRANS, "retrans" },
> +	{ TCP_TRACE_EVENT_RETRANS_LOSS, "retrans_loss" },
> +	{ TCP_TRACE_EVENT_CLOSE, "close" }
> +};
> +
>  struct tcp_sk_trace {
>  	struct tcp_stats stats;
>  	unsigned long start_ts;
> @@ -35,3 +53,433 @@ void tcp_sk_trace_destruct(struct sock *sk)
>  {
>  	kfree(tcp_sk(sk)->trace);
>  }
> +
> +static void tcp_trace_init(struct tcp_trace *tr,
> +			   enum tcp_trace_events trev,
> +			   struct sock *sk)
> +{
> +	tr->event = trev;
> +	if (sk->sk_family == AF_INET) {
> +		tr->ipv6 = 0;
> +		tr->local_addr[0] = inet_sk(sk)->inet_saddr;
> +		tr->remote_addr[0] = inet_sk(sk)->inet_daddr;
> +	} else {
> +		BUG_ON(sk->sk_family != AF_INET6);
> +		tr->ipv6 = 1;
> +		memcpy(tr->local_addr, inet6_sk(sk)->saddr.s6_addr32,
> +		       sizeof(tr->local_addr));
> +		memcpy(tr->remote_addr, sk->sk_v6_daddr.s6_addr32,
> +		       sizeof(tr->remote_addr));
> +	}
> +	tr->local_port = inet_sk(sk)->inet_sport;
> +	tr->remote_port = inet_sk(sk)->inet_dport;
> +}
> +
> +static void tcp_trace_basic_init(struct tcp_trace_basic *trb,
> +				 enum tcp_trace_events trev,
> +				 struct sock *sk)
> +{
> +	struct tcp_sk_trace *sktr = tcp_sk(sk)->trace;
> +	tcp_trace_init((struct tcp_trace *)trb, trev, sk);
> +	trb->snd_cwnd = tcp_sk(sk)->snd_cwnd * tcp_sk(sk)->mss_cache;
> +	trb->mss = tcp_sk(sk)->mss_cache;
> +	trb->ssthresh = tcp_current_ssthresh(sk);
> +	trb->srtt_us = tcp_sk(sk)->srtt_us >> 3;
> +	trb->rto_ms = jiffies_to_msecs(inet_csk(sk)->icsk_rto);
> +	trb->life_ms = jiffies_to_msecs(jiffies - sktr->start_ts);
> +}
> +
> +static void tcp_trace_basic_add(enum tcp_trace_events trev, struct sock *sk)
> +{
> +	struct ring_buffer *buffer;
> +	int pc;
> +	struct ring_buffer_event *event;
> +	struct tcp_trace_basic *trb;
> +	struct tcp_sk_trace *sktr = tcp_sk(sk)->trace;
> +
> +	if (!sktr)
> +		return;
> +
> +	tracing_record_cmdline(current);
> +	buffer = tcp_tr->trace_buffer.buffer;
> +	pc = preempt_count();
> +	event = trace_buffer_lock_reserve(buffer, TRACE_TCP,
> +					  sizeof(*trb), 0, pc);
> +	if (!event)
> +		return;
> +	trb = ring_buffer_event_data(event);
> +	tcp_trace_basic_init(trb, trev, sk);
> +	trace_buffer_unlock_commit(buffer, event, 0, pc);
> +}
> +
> +static void tcp_trace_stats_init(struct tcp_trace_stats *trs,
> +				 enum tcp_trace_events trev,
> +				 struct sock *sk)
> +{
> +	struct tcp_sk_trace *sktr = tcp_sk(sk)->trace;
> +
> +	tcp_trace_basic_init((struct tcp_trace_basic *)trs, trev, sk);
> +	memcpy(&trs->stats, &sktr->stats, sizeof(sktr->stats));
> +}
> +
> +static void tcp_trace_stats_add(enum tcp_trace_events trev, struct sock *sk)
> +{
> +	struct ring_buffer *buffer;
> +	int pc;
> +	struct ring_buffer_event *event;
> +	struct tcp_trace_stats *trs;
> +	struct tcp_sk_trace *sktr = tcp_sk(sk)->trace;
> +
> +	if (!sktr)
> +		return;
> +
> +	tracing_record_cmdline(current);
> +	buffer = tcp_tr->trace_buffer.buffer;
> +	pc = preempt_count();
> +	event = trace_buffer_lock_reserve(buffer, TRACE_TCP,
> +					  sizeof(*trs), 0, pc);
> +	if (!event)
> +		return;
> +	trs = ring_buffer_event_data(event);
> +
> +	tcp_trace_stats_init(trs, trev, sk);
> +
> +	trace_buffer_unlock_commit(buffer, event, 0, pc);
> +}
> +
> +static void tcp_trace_established(void *ignore, struct sock *sk)
> +{
> +	tcp_trace_basic_add(TCP_TRACE_EVENT_ESTABLISHED, sk);
> +}
> +
> +static void tcp_trace_transmit_skb(void *ignore, struct sock *sk,
> +				   struct sk_buff *skb)
> +{
> +	int pcount;
> +	struct tcp_sk_trace *sktr;
> +	struct tcp_skb_cb *tcb;
> +	unsigned int data_len;
> +	bool retrans = false;
> +
> +	sktr = tcp_sk(sk)->trace;
> +	if (!sktr)
> +		return;
> +
> +	tcb = TCP_SKB_CB(skb);
> +	pcount = tcp_skb_pcount(skb);
> +	data_len = tcb->end_seq - tcb->seq;
> +
> +	sktr->stats.segs_out += pcount;
> +
> +	if (!data_len)
> +		goto out;
> +
> +	sktr->stats.data_segs_out += pcount;
> +	sktr->stats.data_octets_out += data_len;
> +
> +	if (before(tcb->seq, tcp_sk(sk)->snd_nxt)) {
> +		enum tcp_trace_events trev;
> +		retrans = true;
> +		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Loss) {
> +			sktr->stats.loss_segs_retrans += pcount;
> +			sktr->stats.loss_octets_retrans += data_len;
> +			trev = TCP_TRACE_EVENT_RETRANS_LOSS;
> +		} else {
> +			sktr->stats.other_segs_retrans += pcount;
> +			sktr->stats.other_octets_retrans += data_len;
> +			trev = TCP_TRACE_EVENT_RETRANS;
> +		}
> +		tcp_trace_stats_add(trev, sk);
> +		return;
> +	}
> +
> +out:
> +	if (jiffies_to_msecs(jiffies - sktr->last_ts) >=
> +	    REPORT_INTERVAL_MS) {
> +		sktr->last_ts = jiffies;
> +		tcp_trace_stats_add(TCP_TRACE_EVENT_PERIODIC, sk);
> +	}
> +}
> +
> +static void tcp_trace_rcv_established(void *ignore, struct sock *sk,
> +				      struct sk_buff *skb)
> +{
> +	struct tcp_sk_trace *sktr;
> +	unsigned int data_len;
> +	struct tcphdr *th;
> +
> +	sktr = tcp_sk(sk)->trace;
> +	if (!sktr)
> +		return;
> +
> +	th = tcp_hdr(skb);
> +	WARN_ON_ONCE(skb->len < th->doff << 2);
> +
> +	sktr->stats.segs_in++;
> +	data_len = skb->len - (th->doff << 2);
> +	if (data_len) {
> +		if (TCP_SKB_CB(skb)->ack_seq == tcp_sk(sk)->snd_una)
> +			sktr->stats.dup_acks_in++;
> +	} else {
> +		sktr->stats.data_segs_in++;
> +		sktr->stats.data_segs_in += data_len;
> +	}
> +
> +	if (jiffies_to_msecs(jiffies - sktr->last_ts) >=
> +	    REPORT_INTERVAL_MS) {
> +		sktr->last_ts = jiffies;
> +		tcp_trace_stats_add(TCP_TRACE_EVENT_PERIODIC, sk);
> +	}
> +}
> +
> +static void tcp_trace_close(void *ignore, struct sock *sk)
> +{
> +	struct tcp_sk_trace *sktr;
> +	sktr = tcp_sk(sk)->trace;
> +	if (!sktr)
> +		return;
> +
> +	tcp_trace_stats_add(TCP_TRACE_EVENT_CLOSE, sk);
> +}
> +
> +static void tcp_trace_ooo_rcv(void *ignore, struct sock *sk)
> +{
> +	struct tcp_sk_trace *sktr;
> +
> +	sktr = tcp_sk(sk)->trace;
> +	if (!sktr)
> +		return;
> +
> +	sktr->stats.ooo_in++;
> +}
> +
> +static void tcp_trace_sacks_rcv(void *ignore, struct sock *sk, int num_sacks)
> +{
> +	struct tcp_sk_trace *sktr;
> +
> +	sktr = tcp_sk(sk)->trace;
> +	if (!sktr)
> +		return;
> +
> +	sktr->stats.sacks_in++;
> +	sktr->stats.sack_blks_in += num_sacks;
> +}
> +
> +void tcp_trace_rtt_sample(void *ignore, struct sock *sk,
> +			  long rtt_sample_us)
> +{
> +	struct tcp_sk_trace *sktr;
> +        u32 rto_ms;
> +
> +	sktr = tcp_sk(sk)->trace;
> +	if (!sktr)
> +		return;
> +
> +	rto_ms = jiffies_to_msecs(inet_csk(sk)->icsk_rto);
> +
> +	sktr->stats.rtt_sample_us = rtt_sample_us;
> +	sktr->stats.max_rtt_us = max_t(u64, sktr->stats.max_rtt_us, rtt_sample_us);
> +	sktr->stats.min_rtt_us = min_t(u64, sktr->stats.min_rtt_us, rtt_sample_us);
> +
> +	sktr->stats.count_rtt++;
> +	sktr->stats.sum_rtt_us += rtt_sample_us;
> +
> +	sktr->stats.max_rto_ms = max_t(u32, sktr->stats.max_rto_ms, rto_ms);
> +	sktr->stats.min_rto_ms = min_t(u32, sktr->stats.min_rto_ms, rto_ms);
> +}
> +
> +static enum print_line_t
> +tcp_trace_print(struct trace_iterator *iter)
> +{
> +	struct trace_seq *s = &iter->seq;
> +	struct tcp_trace *tr = (struct tcp_trace *)iter->ent;
> +	struct tcp_trace_basic *trb;
> +	struct tcp_stats *stats;
> +	const char *last_seq_bptr, *cur_seq_bptr;
> +	int ret = 0;
> +
> +	union {
> +		struct sockaddr_in v4;
> +		struct sockaddr_in6 v6;
> +	} local_sa, remote_sa;
> +
> +	local_sa.v4.sin_port = tr->local_port;
> +	remote_sa.v4.sin_port = tr->remote_port;
> +	if (tr->ipv6) {
> +		local_sa.v6.sin6_family = AF_INET6;
> +		remote_sa.v6.sin6_family = AF_INET6;
> +		memcpy(local_sa.v6.sin6_addr.s6_addr, tr->local_addr, 4);
> +		memcpy(remote_sa.v6.sin6_addr.s6_addr, tr->remote_addr, 4);
> +	} else {
> +		local_sa.v4.sin_family = AF_INET;
> +		remote_sa.v4.sin_family =AF_INET;
> +		local_sa.v4.sin_addr.s_addr =  tr->local_addr[0];
> +		remote_sa.v4.sin_addr.s_addr = tr->remote_addr[0];
> +	}
> +
> +	last_seq_bptr = ftrace_print_symbols_seq(s, tr->event,
> +						tcp_trace_event_names);
> +	cur_seq_bptr = trace_seq_buffer_ptr(s);
> +	if (last_seq_bptr == cur_seq_bptr)
> +		goto out;
> +
> +	trb = (struct tcp_trace_basic *)tr;
> +	ret = trace_seq_printf(s,
> +			       " %pISpc %pISpc snd_cwnd=%u mss=%u ssthresh=%u"
> +			       " srtt_us=%llu rto_ms=%u life_ms=%u",
> +			       &local_sa, &remote_sa,
> +			       trb->snd_cwnd, trb->mss, trb->ssthresh,
> +			       trb->srtt_us, trb->rto_ms, trb->life_ms);
> +
> +	if (tr->event == TCP_TRACE_EVENT_ESTABLISHED || ret == 0)
> +		goto out;
> +
> +	stats = &(((struct tcp_trace_stats *)tr)->stats);
> +	ret = trace_seq_printf(s,
> +		" segs_out=%u data_segs_out=%u data_octets_out=%llu"
> +		" other_segs_retrans=%u other_octets_retrans=%u"
> +		" loss_segs_retrans=%u loss_octets_retrans=%u"
> +		" segs_in=%u data_segs_in=%u data_octets_in=%llu"
> +		" max_rtt_us=%llu min_rtt_us=%llu"
> +		" count_rtt=%u sum_rtt_us=%llu"
> +		" rtt_sample_us=%llu"
> +		" max_rto_ms=%u min_rto_ms=%u"
> +		" dup_acks_in=%u sacks_in=%u"
> +		" sack_blks_in=%u ooo_in=%u",
> +		stats->segs_out, stats->data_segs_out, stats->data_octets_out,
> +		stats->other_segs_retrans, stats->other_octets_retrans,
> +		stats->loss_segs_retrans, stats->loss_octets_retrans,
> +		stats->segs_in, stats->data_segs_in, stats->data_octets_in,
> +		stats->max_rtt_us, stats->min_rtt_us,
> +		stats->count_rtt, stats->sum_rtt_us,
> +		stats->rtt_sample_us,
> +		stats->max_rto_ms, stats->min_rto_ms,
> +		stats->dup_acks_in, stats->sacks_in,
> +		stats->sack_blks_in, stats->ooo_in);
> +
> +out:
> +	if (ret)
> +		ret = trace_seq_putc(s, '\n');
> +
> +	return ret ? TRACE_TYPE_HANDLED : TRACE_TYPE_PARTIAL_LINE;
> +}
> +
> +static enum print_line_t
> +tcp_trace_print_binary(struct trace_iterator *iter)
> +{
> +	int ret;
> +	struct trace_seq *s = &iter->seq;
> +	struct tcp_trace *tr = (struct tcp_trace *)iter->ent;
> +	u32 magic = TCP_TRACE_MAGIC_VERSION;
> +
> +	ret = trace_seq_putmem(s, &magic, sizeof(magic));
> +	if (!ret)
> +		goto out;
> +
> +	if (tr->event == TCP_TRACE_EVENT_ESTABLISHED)
> +		ret = trace_seq_putmem(s, tr + sizeof(magic),
> +					sizeof(struct tcp_trace_basic));
> +	else
> +		ret = trace_seq_putmem(s, tr + sizeof(magic),
> +				       sizeof(struct tcp_trace_stats));
> +
> +out:
> +	return ret ? TRACE_TYPE_HANDLED : TRACE_TYPE_PARTIAL_LINE;
> +}
> +
> +static enum print_line_t
> +tcp_tracer_print_line(struct trace_iterator *iter)
> +{
> +	return (trace_flags & TRACE_ITER_BIN) ?
> +		tcp_trace_print_binary(iter) :
> +		tcp_trace_print(iter);
> +}
> +
> +static void tcp_register_tracepoints(void)
> +{
> +	int ret;
> +
> +	ret = register_trace_tcp_established(tcp_trace_established, NULL);
> +	WARN_ON(ret);
> +	ret = register_trace_tcp_close(tcp_trace_close, NULL);
> +	WARN_ON(ret);
> +	ret = register_trace_tcp_rcv_established(tcp_trace_rcv_established, NULL);
> +	WARN_ON(ret);
> +	ret = register_trace_tcp_transmit_skb(tcp_trace_transmit_skb, NULL);
> +	WARN_ON(ret);
> +	ret = register_trace_tcp_ooo_rcv(tcp_trace_ooo_rcv, NULL);
> +	WARN_ON(ret);
> +	ret = register_trace_tcp_sacks_rcv(tcp_trace_sacks_rcv, NULL);
> +	WARN_ON(ret);
> +	ret = register_trace_tcp_rtt_sample(tcp_trace_rtt_sample, NULL);
> +	WARN_ON(ret);
> +}
> +
> +static void tcp_unregister_tracepoints(void)
> +{
> +	unregister_trace_tcp_established(tcp_trace_established, NULL);
> +	unregister_trace_tcp_rcv_established(tcp_trace_rcv_established, NULL);
> +	unregister_trace_tcp_transmit_skb(tcp_trace_transmit_skb, NULL);
> +	unregister_trace_tcp_ooo_rcv(tcp_trace_ooo_rcv, NULL);
> +	unregister_trace_tcp_sacks_rcv(tcp_trace_sacks_rcv, NULL);
> +	unregister_trace_tcp_rtt_sample(tcp_trace_rtt_sample, NULL);
> +
> +	tracepoint_synchronize_unregister();
> +}
> +
> +static void tcp_tracer_start(struct trace_array *tr)
> +{
> +	tcp_register_tracepoints();
> +	tcp_trace_enabled = true;
> +}
> +
> +static void tcp_tracer_stop(struct trace_array *tr)
> +{
> +	tcp_unregister_tracepoints();
> +	tcp_trace_enabled = false;
> +}
> +
> +static void tcp_tracer_reset(struct trace_array *tr)
> +{
> +	tcp_tracer_stop(tr);
> +}
> +
> +static int tcp_tracer_init(struct trace_array *tr)
> +{
> +	tcp_tr = tr;
> +	tcp_tracer_start(tr);
> +	return 0;
> +}
> +
> +static struct tracer tcp_tracer __read_mostly = {
> +        .name           = "tcp",
> +        .init           = tcp_tracer_init,
> +        .reset          = tcp_tracer_reset,
> +        .start          = tcp_tracer_start,
> +        .stop           = tcp_tracer_stop,
> +	.print_line	= tcp_tracer_print_line,
> +};
> +
> +static struct trace_event_functions tcp_trace_event_funcs;
> +
> +static struct trace_event tcp_trace_event = {
> +        .type           = TRACE_TCP,
> +        .funcs          = &tcp_trace_event_funcs,
> +};
> +
> +static int __init init_tcp_tracer(void)
> +{
> +        if (!register_ftrace_event(&tcp_trace_event)) {
> +                pr_warning("Cannot register TCP trace event\n");
> +                return 1;
> +        }
> +
> +        if (register_tracer(&tcp_tracer) != 0) {
> +                pr_warning("Cannot register TCP tracer\n");
> +                unregister_ftrace_event(&tcp_trace_event);
> +                return 1;
> +        }
> +        return 0;
> +}
> +
> +device_initcall(init_tcp_tracer);
> diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
> index 385391f..5dc5962 100644
> --- a/kernel/trace/trace.h
> +++ b/kernel/trace/trace.h
> @@ -37,6 +37,7 @@ enum trace_type {
>  	TRACE_USER_STACK,
>  	TRACE_BLK,
>  	TRACE_BPUTS,
> +	TRACE_TCP,
>  
>  	__TRACE_LAST_TYPE,
>  };
> -- 
> 1.8.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  https://urldefense.proofpoint.com/v1/url?u=http://vger.kernel.org/majordomo-info.html&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=%2Faj1ZOQObwbmtLwlDw3XzQ%3D%3D%0A&m=CW4scPRBfOgsdn0GCbMgedOQVytKe3ZEBV2fC4xJFOA%3D%0A&s=d8b63403525c4df85b423582337b753283978aef9d9be19238adeb1042270caf
