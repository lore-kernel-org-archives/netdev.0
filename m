From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Mon, 12 Oct 2009 17:52:43 -0400
Message-ID: <4AD3A52B.6050101@librato.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com> <1254932945-12578-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	John Dykstra <jdykstra72@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.iad.emailsrvr.com ([207.97.245.191]:37026 "EHLO
	smtp191.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932560AbZJLVxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 17:53:23 -0400
In-Reply-To: <1254932945-12578-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> This patch adds basic support for C/R of open INET sockets.  I think that
> all the important bits of the TCP and ICSK socket structures is saved,
> but I think there is still some additional IPv6 stuff that needs to be
> handled.
> 
> With this patch applied, the following script can be used to demonstrate
> the functionality:
> 
>   https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html
> 
> It shows that this enables migration of a sendmail process with open
> connections from one machine to another without dropping.
> 
> Now that listening socket support is in the c/r tree, I think it is
> a good time to start fielding comments and suggestions on the
> connected part, as I think lots of folks have input on how to make it
> better, safer, etc.

Nice !

> 
> Cc: netdev@vger.kernel.org
> Cc: Oren Laadan <orenl@librato.com>
> Cc: John Dykstra <jdykstra72@gmail.com>
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> ---

A few comments/questions before the review:

* Did you test this with UDP too ?

* What happens if the the clock on the target machine differs from the
clock on the origin machine ?   (TCP timestamps)

* How confident are we that "bad" input in one or more fields, that
you don't currently sanitize, cannot create "bad" behavior ?  (bad can
be kernel crash, unauthorized behavior, DoS etc)

* How much does TCP rely on the validity of the info in the protocol
control block, and what sorts of bads can happen if it isn't ?  Would
TCP be still happy if the URG point is bogus, would it allow the user
to sent packets otherwise disallowed (to that user?), or maybe it
could crash the kernel ?

* In other words, how much input-sanity-logic is missing (if any) ?

* Can you please document (brief description) how the restart logic
works (listening parent socket etc) ?

* Do you intend to checkpoint (and collect) lingering sockets, that
is they are closed by the application so not references by any task,
but still sending data from their buffers ?

* I'd like to also preserve the "older" behavior - so the user can
choose to restart and reset all previous connections, keep listening
sockets (e.g. RESTART_DISCONNET).

Also, a couple nits inside below.

>  checkpoint/sys.c                 |    4 +
>  include/linux/checkpoint_hdr.h   |   97 +++++++++++++++++++
>  include/linux/checkpoint_types.h |    2 +
>  net/checkpoint.c                 |   25 ++----
>  net/ipv4/checkpoint.c            |  192 ++++++++++++++++++++++++++++++++++++++
>  5 files changed, 303 insertions(+), 17 deletions(-)
> 

[...]

> @@ -475,6 +476,102 @@ struct ckpt_hdr_socket_unix {
>  
>  struct ckpt_hdr_socket_inet {
>  	struct ckpt_hdr h;
> +	__u32 daddr;
> +	__u32 rcv_saddr;
> +	__u32 saddr;
> +	__u16 dport;
> +	__u16 num;
> +	__u16 sport;
> +	__s16 uc_ttl;
> +	__u16 cmsg_flags;
> +

Alignment ?

> +	struct {
> +		__u64 timeout;
> +		__u32 ato;
> +		__u32 lrcvtime;
> +		__u16 last_seg_size;
> +		__u16 rcv_mss;
> +		__u8 pending;
> +		__u8 quick;
> +		__u8 pingpong;
> +		__u8 blocked;
> +	} icsk_ack __attribute__ ((aligned(8)));
> +

[...]


> @@ -710,15 +710,6 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
>  	if (ret < 0)
>  		goto err;
>  
> -	if ((h->sock_common.family == AF_INET) &&
> -	    (h->sock.state != TCP_LISTEN)) {
> -		/* Temporary hack to enable restore of TCP_LISTEN sockets
> -		 * while forcing anything else to a closed state
> -		 */
> -		sock->sk->sk_state = TCP_CLOSE;
> -		sock->state = SS_UNCONNECTED;
> -	}
> -
>  	ckpt_hdr_put(ctx, h);
>  	return sock->sk;
>   err:

How about leaving this inside if the user explicitly requests so,
e.g. using a RESTART_DISCONNECT or something ?

> diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
> index 9cbbf5e..0edfa3e 100644
> --- a/net/ipv4/checkpoint.c
> +++ b/net/ipv4/checkpoint.c
> @@ -17,6 +17,7 @@
>  #include <linux/deferqueue.h>
>  #include <net/tcp_states.h>
>  #include <net/tcp.h>
> +#include <net/ipv6.h>
>  
>  struct dq_sock {
>  	struct ckpt_ctx *ctx;
> @@ -28,6 +29,176 @@ struct dq_buffers {
>  	struct sock *sk;
>  };
>  
> +static int sock_is_parent(struct sock *sk, struct sock *parent)
> +{
> +	return inet_sk(sk)->sport == inet_sk(parent)->sport;
> +}
> +
> +static struct sock *sock_get_parent(struct ckpt_ctx *ctx, struct sock *sk)
> +{
> +	return sock_list_find(&ctx->listen_sockets, sk, sock_is_parent);
> +}
> +
> +static int sock_hash_parent(void *data)
> +{
> +	struct dq_sock *dq = (struct dq_sock *)data;
> +	struct sock *parent;
> +
> +	printk("Doing post-restart hash\n");
> +
> +	dq->sk->sk_prot->hash(dq->sk);
> +
> +	parent = sock_get_parent(dq->ctx, dq->sk);
> +	if (parent) {
> +		inet_sk(dq->sk)->num = ntohs(inet_sk(dq->sk)->sport);
> +		local_bh_disable();
> +		__inet_inherit_port(parent, dq->sk);
> +		local_bh_enable();
> +	} else {
> +		inet_sk(dq->sk)->num = 0;
> +		inet_hash_connect(&tcp_death_row, dq->sk);
> +		inet_sk(dq->sk)->num = ntohs(inet_sk(dq->sk)->sport);
> +	}
> +
> +	return 0;
> +}

I wonder if a user can use this to convince TCP to send some nasty
packets to some arbitrary destination, with specific seq-number or
what not ?

> +
> +static int sock_defer_hash(struct ckpt_ctx *ctx, struct sock *sock)
> +{
> +	struct dq_sock dq;
> +
> +	dq.sk = sock;
> +	dq.ctx = ctx;
> +
> +	return deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
> +			      sock_hash_parent, NULL);
> +}
> +
> +static int sock_inet_tcp_cptrst(struct ckpt_ctx *ctx,
> +				struct tcp_sock *sk,
> +				struct ckpt_hdr_socket_inet *hh,
> +				int op)
> +{

Which of the following list is safe to restore *as is*, and which
requires sanitation tests ?

> +	CKPT_COPY(op, hh->tcp.rcv_nxt, sk->rcv_nxt);
> +	CKPT_COPY(op, hh->tcp.copied_seq, sk->copied_seq);
> +	CKPT_COPY(op, hh->tcp.rcv_wup, sk->rcv_wup);
> +	CKPT_COPY(op, hh->tcp.snd_nxt, sk->snd_nxt);
> +	CKPT_COPY(op, hh->tcp.snd_una, sk->snd_una);
> +	CKPT_COPY(op, hh->tcp.snd_sml, sk->snd_sml);
> +	CKPT_COPY(op, hh->tcp.rcv_tstamp, sk->rcv_tstamp);
> +	CKPT_COPY(op, hh->tcp.lsndtime, sk->lsndtime);
> +
> +	CKPT_COPY(op, hh->tcp.snd_wl1, sk->snd_wl1);
> +	CKPT_COPY(op, hh->tcp.snd_wnd, sk->snd_wnd);
> +	CKPT_COPY(op, hh->tcp.max_window, sk->max_window);
> +	CKPT_COPY(op, hh->tcp.mss_cache, sk->mss_cache);
> +	CKPT_COPY(op, hh->tcp.window_clamp, sk->window_clamp);
> +	CKPT_COPY(op, hh->tcp.rcv_ssthresh, sk->rcv_ssthresh);
> +	CKPT_COPY(op, hh->tcp.frto_highmark, sk->frto_highmark);
> +	CKPT_COPY(op, hh->tcp.advmss, sk->advmss);
> +	CKPT_COPY(op, hh->tcp.frto_counter, sk->frto_counter);
> +	CKPT_COPY(op, hh->tcp.nonagle, sk->nonagle);
> +
> +	CKPT_COPY(op, hh->tcp.srtt, sk->srtt);
> +	CKPT_COPY(op, hh->tcp.mdev, sk->mdev);
> +	CKPT_COPY(op, hh->tcp.mdev_max, sk->mdev_max);
> +	CKPT_COPY(op, hh->tcp.rttvar, sk->rttvar);
> +	CKPT_COPY(op, hh->tcp.rtt_seq, sk->rtt_seq);
> +
> +	CKPT_COPY(op, hh->tcp.packets_out, sk->packets_out);
> +	CKPT_COPY(op, hh->tcp.retrans_out, sk->retrans_out);
> +
> +	CKPT_COPY(op, hh->tcp.urg_data, sk->urg_data);
> +	CKPT_COPY(op, hh->tcp.ecn_flags, sk->ecn_flags);
> +	CKPT_COPY(op, hh->tcp.reordering, sk->reordering);
> +	CKPT_COPY(op, hh->tcp.snd_up, sk->snd_up);
> +
> +	CKPT_COPY(op, hh->tcp.keepalive_probes, sk->keepalive_probes);
> +
> +	CKPT_COPY(op, hh->tcp.rcv_wnd, sk->rcv_wnd);
> +	CKPT_COPY(op, hh->tcp.write_seq, sk->write_seq);
> +	CKPT_COPY(op, hh->tcp.pushed_seq, sk->pushed_seq);
> +	CKPT_COPY(op, hh->tcp.lost_out, sk->lost_out);
> +	CKPT_COPY(op, hh->tcp.sacked_out, sk->sacked_out);
> +	CKPT_COPY(op, hh->tcp.fackets_out, sk->fackets_out);
> +	CKPT_COPY(op, hh->tcp.tso_deferred, sk->tso_deferred);
> +	CKPT_COPY(op, hh->tcp.bytes_acked, sk->bytes_acked);
> +
> +	CKPT_COPY(op, hh->tcp.lost_cnt_hint, sk->lost_cnt_hint);
> +	CKPT_COPY(op, hh->tcp.retransmit_high, sk->retransmit_high);
> +
> +	CKPT_COPY(op, hh->tcp.lost_retrans_low, sk->lost_retrans_low);
> +
> +	CKPT_COPY(op, hh->tcp.prior_ssthresh, sk->prior_ssthresh);
> +	CKPT_COPY(op, hh->tcp.high_seq, sk->high_seq);
> +
> +	CKPT_COPY(op, hh->tcp.retrans_stamp, sk->retrans_stamp);
> +	CKPT_COPY(op, hh->tcp.undo_marker, sk->undo_marker);
> +	CKPT_COPY(op, hh->tcp.undo_retrans, sk->undo_retrans);
> +	CKPT_COPY(op, hh->tcp.total_retrans, sk->total_retrans);
> +
> +	CKPT_COPY(op, hh->tcp.urg_seq, sk->urg_seq);
> +	CKPT_COPY(op, hh->tcp.keepalive_time, sk->keepalive_time);
> +	CKPT_COPY(op, hh->tcp.keepalive_intvl, sk->keepalive_intvl);
> +
> +	return 0;
> +}
> +
> +static int sock_inet_cptrst(struct ckpt_ctx *ctx,
> +			    struct sock *sock,
> +			    struct ckpt_hdr_socket_inet *hh,
> +			    int op)
> +{
> +	struct inet_sock *sk = inet_sk(sock);
> +	struct inet_connection_sock *icsk = inet_csk(sock);
> +	int ret;
> +
> +	CKPT_COPY(op, hh->daddr, sk->daddr);
> +	CKPT_COPY(op, hh->rcv_saddr, sk->rcv_saddr);
> +	CKPT_COPY(op, hh->dport, sk->dport);
> +	CKPT_COPY(op, hh->num, sk->num);
> +	CKPT_COPY(op, hh->saddr, sk->saddr);
> +	CKPT_COPY(op, hh->sport, sk->sport);
> +	CKPT_COPY(op, hh->uc_ttl, sk->uc_ttl);
> +	CKPT_COPY(op, hh->cmsg_flags, sk->cmsg_flags);
> +
> +	CKPT_COPY(op, hh->icsk_ack.pending, icsk->icsk_ack.pending);
> +	CKPT_COPY(op, hh->icsk_ack.quick, icsk->icsk_ack.quick);
> +	CKPT_COPY(op, hh->icsk_ack.pingpong, icsk->icsk_ack.pingpong);
> +	CKPT_COPY(op, hh->icsk_ack.blocked, icsk->icsk_ack.blocked);
> +	CKPT_COPY(op, hh->icsk_ack.ato, icsk->icsk_ack.ato);
> +	CKPT_COPY(op, hh->icsk_ack.timeout, icsk->icsk_ack.timeout);
> +	CKPT_COPY(op, hh->icsk_ack.lrcvtime, icsk->icsk_ack.lrcvtime);
> +	CKPT_COPY(op,
> +		  hh->icsk_ack.last_seg_size, icsk->icsk_ack.last_seg_size);
> +	CKPT_COPY(op, hh->icsk_ack.rcv_mss, icsk->icsk_ack.rcv_mss);
> +
> +	if (sock->sk_protocol == IPPROTO_TCP)
> +		ret = sock_inet_tcp_cptrst(ctx, tcp_sk(sock), hh, op);
> +	else if (sock->sk_protocol == IPPROTO_UDP)
> +		ret = 0;
> +	else {
> +		ckpt_write_err(ctx, "T", "unknown socket protocol %d",
> +			       sock->sk_protocol);
> +		ret = -EINVAL;
> +	}
> +
> +	if (sock->sk_family == AF_INET6) {
> +		struct ipv6_pinfo *inet6 = inet6_sk(sock);
> +		if (op == CKPT_CPT) {
> +			ipv6_addr_copy(&hh->inet6.saddr, &inet6->saddr);
> +			ipv6_addr_copy(&hh->inet6.rcv_saddr, &inet6->rcv_saddr);
> +			ipv6_addr_copy(&hh->inet6.daddr, &inet6->daddr);
> +		} else {
> +			ipv6_addr_copy(&inet6->saddr, &hh->inet6.saddr);
> +			ipv6_addr_copy(&inet6->rcv_saddr, &hh->inet6.rcv_saddr);
> +			ipv6_addr_copy(&inet6->daddr, &hh->inet6.daddr);
> +		}
> +	}
> +
> +	return ret;
> +}
> +

[...]

Oren.


