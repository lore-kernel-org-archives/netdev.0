From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Sat, 25 Jul 2009 16:02:34 -0500
Message-ID: <1248555754.16746.55.camel@merlyn>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	 <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:30196 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbZGYVCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 17:02:41 -0400
Received: by an-out-0708.google.com with SMTP id d40so3149122and.1
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 14:02:41 -0700 (PDT)
In-Reply-To: <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some comments on the patch.  My apologies that these are late, and keep
in mind that I'm new to your c/r implementation.  

There's a lot more to think about, especially re socket state, but I
wanted to get these comments out to you without more delay.

On Tue, 2009-07-07 at 12:26 -0700, Dan Smith wrote:
> This patch adds AF_INET c/r support based on the framework established in
> my AF_UNIX patch.  I've tested it by checkpointing a single app with a
> pair of sockets connected over loopback.
> 
> A couple points about the operation:
> 
>  1. In order to properly hook up the established sockets with the matching
>     listening parent socket, I added a new list to the ckpt_ctx and run the
>     parent attachment in the deferqueue at the end of the restart process.
>  2. I don't do anything to redirect or freeze traffic flowing to or from the
>     remote system (to prevent a RST from breaking things).  I expect that
>     userspace will bring down a veth device or freeze traffic to the remote
>     system to handle this case.
> 
> Changes in v3:
>  - Add AF_INET6 support
> 
> Changes in v2:
>  - Check for data in the TCP out-of-order queue and fail if present
>  - Fix a logic issue in sock_add_parent()
>  - Add comment about holding a reference to sock for parent list
>  - Write error messages to checkpoint stream where appropriate
>  - Fix up checking of some return values in restart phase
>  - Fix up restart logic to restore socket info for all states
>  - Avoid running sk_proto->hash() for non-TCP sockets
>  - Fix calling bind() for unconnected (i.e. DGRAM) sockets
>  - Change 'in' to 'inet' in structure and function names
> 
> Cc: Oren Laaden <orenl@cs.columbia.edu>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> ---
>  checkpoint/sys.c                 |    2 +
>  include/linux/checkpoint_hdr.h   |    1 +
>  include/linux/checkpoint_types.h |    2 +
>  include/linux/socket.h           |  102 ++++++++++++
>  net/checkpoint.c                 |  337 +++++++++++++++++++++++++++++++++++++-
>  5 files changed, 439 insertions(+), 5 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 38a5299..b6f18ea 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -242,6 +242,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
>  	INIT_LIST_HEAD(&ctx->pgarr_pool);
>  	init_waitqueue_head(&ctx->waitq);
>  
> +	INIT_LIST_HEAD(&ctx->listen_sockets);
> +
>  	err = -EBADF;
>  	ctx->file = fget(fd);
>  	if (!ctx->file)
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index f59b071..16e21ee 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -93,6 +93,7 @@ enum {
>  	CKPT_HDR_SOCKET_BUFFERS,
>  	CKPT_HDR_SOCKET_BUFFER,
>  	CKPT_HDR_SOCKET_UNIX,
> +	CKPT_HDR_SOCKET_INET,
>  
>  	CKPT_HDR_TAIL = 9001,
>  
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index 27fbe26..d7db190 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -60,6 +60,8 @@ struct ckpt_ctx {
>  	struct list_head pgarr_list;	/* page array to dump VMA contents */
>  	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
>  
> +	struct list_head listen_sockets;/* listening parent sockets */
> +
>  	/* [multi-process checkpoint] */
>  	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
>  	int nr_tasks;                   /* size of tasks array */
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index e7d64eb..c723d96 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -334,6 +334,108 @@ struct ckpt_hdr_socket_unix {
>  	__u32 flags;
>  } __attribute__ ((aligned(8)));
>  
> +struct ckpt_hdr_socket_inet {
> +	struct ckpt_hdr h;

I don't know whether this would affect palatibility (sic) for the
mainline, but it bothers me...  socket.h (and sock.h) are included all
over the place in the kernel, and this definition is only needed in very
limited locations.  Can it be placed in a .h used only by checkpoint
code?

> +
> +	__u32 daddr;
> +	__u32 rcv_saddr;
> +	__u32 saddr;
> +	__u16 dport;
> +	__u16 num;
> +	__u16 sport;
> +	__s16 uc_ttl;
> +	__u16 cmsg_flags;
> +	__u16 __pad;
> +
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
> +	/* FIXME: Skipped opt, tos, multicast, cork settings */
> +
> +	struct {
> +		__u64 last_synq_overflow;
> +
> +		__u32 rcv_nxt;
> +		__u32 copied_seq;
> +		__u32 rcv_wup;
> +		__u32 snd_nxt;
> +		__u32 snd_una;
> +		__u32 snd_sml;
> +		__u32 rcv_tstamp;
> +		__u32 lsndtime;
> +
> +		__u32 snd_wl1;
> +		__u32 snd_wnd;
> +		__u32 max_window;
> +		__u32 mss_cache;
> +		__u32 window_clamp;
> +		__u32 rcv_ssthresh;
> +		__u32 frto_highmark;
> +
> +		__u32 srtt;
> +		__u32 mdev;
> +		__u32 mdev_max;
> +		__u32 rttvar;
> +		__u32 rtt_seq;
> +
> +		__u32 packets_out;
> +		__u32 retrans_out;
> +
> +		__u32 snd_up;
> +		__u32 rcv_wnd;
> +		__u32 write_seq;
> +		__u32 pushed_seq;
> +		__u32 lost_out;
> +		__u32 sacked_out;
> +		__u32 fackets_out;
> +		__u32 tso_deferred;
> +		__u32 bytes_acked;
> +
> +		__s32 lost_cnt_hint;
> +		__u32 retransmit_high;
> +
> +		__u32 lost_retrans_low;
> +
> +		__u32 prior_ssthresh;
> +		__u32 high_seq;
> +
> +		__u32 retrans_stamp;
> +		__u32 undo_marker;
> +		__s32 undo_retrans;
> +		__u32 total_retrans;
> +
> +		__u32 urg_seq;
> +		__u32 keepalive_time;
> +		__u32 keepalive_intvl;
> +
> +		__u16 urg_data;
> +		__u16 advmss;
> +		__u8 frto_counter;
> +		__u8 nonagle;
> +
> +		__u8 ecn_flags;
> +		__u8 reordering;
> +
> +		__u8 keepalive_probes;
> +	} tcp __attribute__ ((aligned(8)));
> +
> +	struct {
> +		char saddr[16];
> +		char rcv_saddr[16];
> +		char daddr[16];
> +	} inet6 __attribute__ ((aligned(8)));
> +
> +} __attribute__ ((aligned(8)));
> +
>  struct ckpt_hdr_socket {
>  	struct ckpt_hdr h;
>  
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index 0ff1656..ee069fa 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -16,16 +16,69 @@
>  #include <linux/syscalls.h>
>  #include <linux/sched.h>
>  #include <linux/fs_struct.h>
> +#include <linux/tcp.h>
> +#include <linux/in.h>
>  
>  #include <net/af_unix.h>
>  #include <net/tcp_states.h>
> +#include <net/tcp.h>
>  
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/deferqueue.h>
>  
>  /* Size of an empty struct sockaddr_un */
>  #define UNIX_LEN_EMPTY 2
>  
> +struct ckpt_parent_sock {
> +	struct sock *sock;
> +	__u32 oref;
> +	struct list_head list;
> +};
> +
> +static int sock_add_parent(struct ckpt_ctx *ctx, struct sock *sock)
> +{
> +	struct ckpt_parent_sock *parent;
> +	__u32 objref;
> +	int new;
> +
> +	objref = ckpt_obj_lookup_add(ctx, sock, CKPT_OBJ_SOCK, &new);
> +	if (objref < 0)
> +		return objref;
> +	else if (!new)
> +		return 0;
> +
> +	parent = kmalloc(sizeof(*parent), GFP_KERNEL);
> +	if (!parent)
> +		return -ENOMEM;
> +
> +	/* The deferqueue is processed before the objhash is free()'d,
> +	 * thus the objhash holds a reference to sock for us
> +	 */
> +	parent->sock = sock;
> +	parent->oref = objref;
> +	INIT_LIST_HEAD(&parent->list);
> +
> +	list_add(&parent->list, &ctx->listen_sockets);
> +
> +	return 0;
> +}
> +
> +static struct sock *sock_get_parent(struct ckpt_ctx *ctx, struct sock *sock)
> +{
> +	struct ckpt_parent_sock *parent;
> +	struct inet_sock *c = inet_sk(sock);
> +
> +	list_for_each_entry(parent, &ctx->listen_sockets, list) {
> +		struct inet_sock *p = inet_sk(parent->sock);
> +
> +		if (c->sport == p->sport)
> +			return parent->sock;
> +	}
> +
> +	return NULL;
> +}
> +
>  static inline int sock_unix_need_cwd(struct sockaddr_un *a)
>  {
>  	return (a->sun_path[0] != '/');
> @@ -55,17 +108,23 @@ static int sock_copy_buffers(struct sk_buff_head *from, struct sk_buff_head *to)
>  }
>  
>  static int __sock_write_buffers(struct ckpt_ctx *ctx,
> +				uint16_t family,
>  				struct sk_buff_head *queue)
>  {
>  	struct sk_buff *skb;
>  	int ret = 0;
>  
>  	skb_queue_walk(queue, skb) {
> -		if (UNIXCB(skb).fp) {
> +		if ((family == AF_UNIX) && UNIXCB(skb).fp) {
>  			ckpt_write_err(ctx, "fd-passing is not supported");
>  			return -EBUSY;
>  		}
>  
> +		if (skb_shinfo(skb)->nr_frags) {
> +			ckpt_write_err(ctx, "socket has fragments in-flight");
> +			return -EBUSY;
> +		}
> +
>  		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
>  					  CKPT_HDR_SOCKET_BUFFER);
>  		if (ret)
> @@ -75,7 +134,9 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  	return 0;
>  }
>  
> -static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
> +static int sock_write_buffers(struct ckpt_ctx *ctx,
> +			      uint16_t family,
> +			      struct sk_buff_head *queue)
>  {
>  	struct ckpt_hdr_socket_buffer *h;
>  	struct sk_buff_head tmpq;
> @@ -95,7 +156,7 @@ static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
>  
>  	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
>  	if (!ret)
> -		ret = __sock_write_buffers(ctx, &tmpq);
> +		ret = __sock_write_buffers(ctx, family, &tmpq);
>  
>   out:
>  	ckpt_hdr_put(ctx, h);
> @@ -309,6 +370,166 @@ static int sock_cptrst(struct ckpt_ctx *ctx,
>  		return 0;
>  }
>  
> +static int sock_inet_tcp_cptrst(struct ckpt_ctx *ctx,
> +				struct tcp_sock *sk,
> +				struct ckpt_hdr_socket_inet *hh,
> +				int op)
> +{
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

I doubt the RTT metrics should be migrated.
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

You need to either save the SACK state or reset it.

> +	CKPT_COPY(op, hh->tcp.fackets_out, sk->fackets_out);
> +	CKPT_COPY(op, hh->tcp.tso_deferred, sk->tso_deferred);

Don't need to migrate this.

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
> +	CKPT_COPY(op, hh->tcp.last_synq_overflow, sk->last_synq_overflow);
> +
> +	return 0;
> +}
> +
> +static int sock_inet_cptrst(struct ckpt_ctx *ctx,
> +			    struct sock *sock,
> +			    struct ckpt_hdr_socket_inet *hh,
> +			  int op)
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
> +		hh->icsk_ack.last_seg_size, icsk->icsk_ack.last_seg_size);
> +	CKPT_COPY(op, hh->icsk_ack.rcv_mss, icsk->icsk_ack.rcv_mss);
> +
> +	if (sock->sk_protocol == IPPROTO_TCP)
> +		ret = sock_inet_tcp_cptrst(ctx, tcp_sk(sock), hh, op);
> +	else if (sock->sk_protocol == IPPROTO_UDP)
> +		ret = 0;
> +	else {
> +		ckpt_write_err(ctx, "unknown socket protocol %d",
> +			       sock->sk_protocol);
> +		ret = -EINVAL;
> +	}
> +
> +	if (sock->sk_family == AF_INET6) {
> +		struct ipv6_pinfo *inet6 = inet6_sk(sock);
> +		unsigned alen = sizeof(struct in6_addr);
> +		if (op == CKPT_CPT) {
> +			memcpy(hh->inet6.saddr, &inet6->saddr, alen);
> +			memcpy(hh->inet6.rcv_saddr, &inet6->rcv_saddr, alen);
> +			memcpy(hh->inet6.daddr, &inet6->daddr, alen);
> +		} else {
> +			memcpy(&inet6->saddr, hh->inet6.saddr, alen);
> +			memcpy(&inet6->rcv_saddr, hh->inet6.rcv_saddr, alen);
> +			memcpy(&inet6->daddr, hh->inet6.daddr, alen);
> +		}
> +	}
> +
> +	return ret;
> +}

For your to-do someday list--the router alert lists.  Lots of stuff more
important than this.

> +
> +static int sock_inet_checkpoint(struct ckpt_ctx *ctx,
> +				struct sock *sock,
> +				struct ckpt_hdr_socket *h)
> +{
> +	int ret = -EINVAL;
> +	struct ckpt_hdr_socket_inet *in;
> +
> +	if (sock->sk_protocol == IPPROTO_TCP) {
> +		struct tcp_sock *tsock = tcp_sk(sock);
> +		if (!skb_queue_empty(&tsock->out_of_order_queue)) {
> +			ckpt_write_err(ctx, "TCP socket has out-of-order data");
> +			return -EBUSY;
> +		}
> +	}
> +
> +	in = ckpt_hdr_get_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
> +	if (!in)
> +		goto out;
> +
> +	ret = sock_inet_cptrst(ctx, sock, in, CKPT_CPT);
> +	if (ret < 0)
> +		goto out;
> +

There's an interesting design choice re TIME_WAIT and similar states.
In a migration scenario, do those sks migrate?  If the tree isn't going
to be restored for a while., you want the original host to continue to
respond to those four-tuples  If the IP address of the original is
immediately migrated to another machine, you want the TIME_WAIT sks to
migrate too.

> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) in);
> + out:
> +	return ret;
> +}
> +
>  int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  {
>  	struct socket *socket = file->private_data;
> @@ -349,6 +570,11 @@ int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  		ret = sock_unix_checkpoint(ctx, sock, h);
>  		if (ret)
>  			goto out;
> +	} else if ((sock->sk_family == AF_INET) ||
> +		   (sock->sk_family == AF_INET6)) {
> +		ret = sock_inet_checkpoint(ctx, sock, h);
> +		if (ret)
> +			goto out;
>  	} else {
>  		ckpt_write_err(ctx, "unsupported socket family %i",
>  			       sock->sk_family);
> @@ -357,11 +583,13 @@ int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  	}
>  
>  	if (sock->sk_state != TCP_LISTEN) {
> -		ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
> +		uint16_t family = sock->sk_family;
> +
> +		ret = sock_write_buffers(ctx, family, &sock->sk_receive_queue);
>  		if (ret)
>  			goto out;
>  
> -		ret = sock_write_buffers(ctx, &sock->sk_write_queue);
> +		ret = sock_write_buffers(ctx, family, &sock->sk_write_queue);
>  		if (ret)
>  			goto out;
>  	}
> @@ -677,6 +905,101 @@ static int sock_unix_restart(struct ckpt_ctx *ctx,
>  	return ret;
>  }
>  
> +struct dq_sock {
> +	struct sock *sock;
> +	struct ckpt_ctx *ctx;
> +};
> +
> +static int __sock_hash_parent(void *data)
> +{
> +	struct dq_sock *dq = (struct dq_sock *)data;
> +	struct sock *parent;
> +
> +	dq->sock->sk_prot->hash(dq->sock);
> +
> +	parent = sock_get_parent(dq->ctx, dq->sock);
> +	if (parent) {
> +		inet_sk(dq->sock)->num = ntohs(inet_sk(dq->sock)->sport);
> +		local_bh_disable();
> +		__inet_inherit_port(parent, dq->sock);
> +		local_bh_enable();
> +	} else {
> +		inet_sk(dq->sock)->num = 0;
> +		inet_hash_connect(&tcp_death_row, dq->sock);
> +		inet_sk(dq->sock)->num = ntohs(inet_sk(dq->sock)->sport);
> +	}
> +
> +	return 0;
> +}
> +
> +static int sock_defer_hash(struct ckpt_ctx *ctx, struct sock *sock)
> +{
> +	struct dq_sock dq;
> +
> +	dq.sock = sock;
> +	dq.ctx = ctx;
> +
> +	return deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
> +			      __sock_hash_parent, __sock_hash_parent);
> +}
> +
> +static int sock_inet_restart(struct ckpt_ctx *ctx,
> +			     struct ckpt_hdr_socket *h,
> +			     struct socket *socket)
> +{
> +	int ret;
> +	struct ckpt_hdr_socket_inet *in;
> +	struct sockaddr_in *l = (struct sockaddr_in *)&h->laddr;
> +
> +	in = ckpt_read_obj_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
> +	if (IS_ERR(in))
> +		return PTR_ERR(in);
> +
> +	/* Listening sockets and those that are closed but have a local
> +	 * address need to call bind()
> +	 */
> +	if ((h->sock.state == TCP_LISTEN) ||
> +	    ((h->sock.state == TCP_CLOSE) && (h->laddr_len > 0))) {
> +		socket->sk->sk_reuse = 2;
> +		inet_sk(socket->sk)->freebind = 1;
> +		ret = socket->ops->bind(socket,
> +					(struct sockaddr *)l,
> +					h->laddr_len);
> +		ckpt_debug("inet bind: %i", ret);
> +		if (ret < 0)
> +			goto out;
> +
> +		if (h->sock.state == TCP_LISTEN) {
> +			ret = socket->ops->listen(socket, h->sock.backlog);
> +			ckpt_debug("inet listen: %i", ret);
> +			if (ret < 0)
> +				goto out;
> +
> +			ret = sock_add_parent(ctx, socket->sk);
> +			if (ret < 0)
> +				goto out;

So this is just dummied off as a proof-of-concept for LISTEN?

> +		}
> +	} else {
> +		ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
> +		if (ret)
> +			goto out;
> +
> +		ret = sock_inet_cptrst(ctx, socket->sk, in, CKPT_RST);
> +		if (ret)
> +			goto out;

At a minimum, you'll want to start the TCP retransmit timer if there is
unacknowledged data outstanding.  And other timers for other states, as
they're supported.

And you probably do want to do slow-start again--disregard my babbling
from yesterday. 

> +
> +		if ((h->sock.state == TCP_ESTABLISHED) &&
> +		    (h->sock.protocol == IPPROTO_TCP))
> +			/* Delay hashing this sock until the end so we can
> +			 * hook it up with its parent (if appropriate)
> +			 */
> +			ret = sock_defer_hash(ctx, socket->sk);
> +	}
> +
> +  out:
> +	return ret;
> + }
> +
>  struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
>  				    struct ckpt_hdr_socket *h)
>  {
> @@ -690,6 +1013,10 @@ struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
>  	if (h->sock_common.family == AF_UNIX) {
>  		ret = sock_unix_restart(ctx, h, socket);
>  		ckpt_debug("sock_unix_restart: %i\n", ret);
> +	} else if ((h->sock_common.family == AF_INET) ||
> +		   (h->sock_common.family == AF_INET6)) {
> +		ret = sock_inet_restart(ctx, h, socket);
> +		ckpt_debug("sock_inet_restart: %i\n", ret);
>  	} else {
>  		ckpt_write_err(ctx, "unsupported family %i\n",
>  			       h->sock_common.family);

This is part of your AF_UNIX patch:

        struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
        				    struct ckpt_hdr_socket *h)
        {
        	struct socket *socket;
        	int ret;
        
        	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
        	if (ret < 0)
        		return ERR_PTR(ret);
        

You _really_ want to pass the actual protocol number to sock_create().
The size of the sk it creates depends on this.  You'll quickly be in
memory corruption hell without it.

Also from the AF_UNIX patch:
        
        static int obj_sock_users(void *ptr)
        {
        	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
        }
        
Network sockets also use sk->sk_wmem_alloc to track references to the
sock from egress skb's

And:

        static int sock_copy_buffers(struct sk_buff_head *from, struct
        sk_buff_head *to)
        {
        	int count = 0;
        	struct sk_buff *skb;
        
        	skb_queue_walk(from, skb) {
        		struct sk_buff *tmp;
        
        		tmp = dev_alloc_skb(skb->len);
        		if (!tmp)
        			return -ENOMEM;
        
        		spin_lock(&from->lock);
        		skb_morph(tmp, skb);
        		spin_unlock(&from->lock);

Why not just clone the skb?

  --  John

