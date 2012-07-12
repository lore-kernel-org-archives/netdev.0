From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 09:33:01 -0400
Message-ID: <CABrhC0=Ls7G-noW1cjsyiF+G5v9f9R=bi6JvrOoT5ZDQB=gSXg@mail.gmail.com>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, ycheng@google.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, therbert@google.com,
	mattmathis@google.com, nanditad@google.com, ncardwell@google.com,
	andrewmcgr@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:37039 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504Ab2GLNdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 09:33:02 -0400
Received: by ghrr11 with SMTP id r11so2386095ghr.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 06:33:02 -0700 (PDT)
In-Reply-To: <1341933215.3265.5476.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One general question: why a per-connection limit?  I haven't been
following the bufferbloat conversation closely so I may have missed
some of the conversation.  But it seems that multiple connections will
still cause longer queue times.

Thanks,
  -John


On Tue, Jul 10, 2012 at 11:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> This introduce TSQ (TCP Small Queues)
>
> TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &
> device queues), to reduce RTT and cwnd bias, part of the bufferbloat
> problem.
>
> sk->sk_wmem_alloc not allowed to grow above a given limit,
> allowing no more than ~128KB [1] per tcp socket in qdisc/dev layers at a
> given time.
>
> TSO packets are sized/capped to half the limit, so that we have two
> TSO packets in flight, allowing better bandwidth use.
>
> As a side effect, setting the limit to 40000 automatically reduces the
> standard gso max limit (65536) to 40000/2 : It can help to reduce
> latencies of high prio packets, having smaller TSO packets.
>
> This means we divert sock_wfree() to a tcp_wfree() handler, to
> queue/send following frames when skb_orphan() [2] is called for the
> already queued skbs.
>
> Results on my dev machine (tg3 nic) are really impressive, using
> standard pfifo_fast, and with or without TSO/GSO. Without reduction of
> nominal bandwidth.
>
> I no longer have 3MBytes backlogged in qdisc by a single netperf
> session, and both side socket autotuning no longer use 4 Mbytes.
>
> As skb destructor cannot restart xmit itself ( as qdisc lock might be
> taken at this point ), we delegate the work to a tasklet. We use one
> tasklest per cpu for performance reasons.
>
>
>
> [1] New /proc/sys/net/ipv4/tcp_limit_output_bytes tunable
> [2] skb_orphan() is usually called at TX completion time,
>   but some drivers call it in their start_xmit() handler.
>   These drivers should at least use BQL, or else a single TCP
>   session can still fill the whole NIC TX ring, since TSQ will
>   have no effect.
>
> Not-Yet-Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/tcp.h        |    9 ++
>  include/net/tcp.h          |    3
>  net/ipv4/sysctl_net_ipv4.c |    7 +
>  net/ipv4/tcp.c             |   14 ++-
>  net/ipv4/tcp_minisocks.c   |    1
>  net/ipv4/tcp_output.c      |  132 ++++++++++++++++++++++++++++++++++-
>  6 files changed, 160 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7d3bced..55b8cf9 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -339,6 +339,9 @@ struct tcp_sock {
>         u32     rcv_tstamp;     /* timestamp of last received ACK (for keepalives) */
>         u32     lsndtime;       /* timestamp of last sent data packet (for restart window) */
>
> +       struct list_head tsq_node; /* anchor in tsq_tasklet.head list */
> +       unsigned long   tsq_flags;
> +
>         /* Data for direct copy to user */
>         struct {
>                 struct sk_buff_head     prequeue;
> @@ -494,6 +497,12 @@ struct tcp_sock {
>         struct tcp_cookie_values  *cookie_values;
>  };
>
> +enum tsq_flags {
> +       TSQ_THROTTLED,
> +       TSQ_QUEUED,
> +       TSQ_OWNED, /* tcp_tasklet_func() found socket was locked */
> +};
> +
>  static inline struct tcp_sock *tcp_sk(const struct sock *sk)
>  {
>         return (struct tcp_sock *)sk;
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 53fb7d8..3a6ed09 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -253,6 +253,7 @@ extern int sysctl_tcp_cookie_size;
>  extern int sysctl_tcp_thin_linear_timeouts;
>  extern int sysctl_tcp_thin_dupack;
>  extern int sysctl_tcp_early_retrans;
> +extern int sysctl_tcp_limit_output_bytes;
>
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> @@ -321,6 +322,8 @@ extern struct proto tcp_prot;
>
>  extern void tcp_init_mem(struct net *net);
>
> +extern void tcp_tasklet_init(void);
> +
>  extern void tcp_v4_err(struct sk_buff *skb, u32);
>
>  extern void tcp_shutdown (struct sock *sk, int how);
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 12aa0c5..70730f7 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -598,6 +598,13 @@ static struct ctl_table ipv4_table[] = {
>                 .mode           = 0644,
>                 .proc_handler   = proc_dointvec
>         },
> +       {
> +               .procname       = "tcp_limit_output_bytes",
> +               .data           = &sysctl_tcp_limit_output_bytes,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_dointvec
> +       },
>  #ifdef CONFIG_NET_DMA
>         {
>                 .procname       = "tcp_dma_copybreak",
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3ba605f..8838bd2 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -376,6 +376,7 @@ void tcp_init_sock(struct sock *sk)
>         skb_queue_head_init(&tp->out_of_order_queue);
>         tcp_init_xmit_timers(sk);
>         tcp_prequeue_init(tp);
> +       INIT_LIST_HEAD(&tp->tsq_node);
>
>         icsk->icsk_rto = TCP_TIMEOUT_INIT;
>         tp->mdev = TCP_TIMEOUT_INIT;
> @@ -786,15 +787,17 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
>                                        int large_allowed)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
> -       u32 xmit_size_goal, old_size_goal;
> +       u32 xmit_size_goal, old_size_goal, gso_max_size;
>
>         xmit_size_goal = mss_now;
>
>         if (large_allowed && sk_can_gso(sk)) {
> -               xmit_size_goal = ((sk->sk_gso_max_size - 1) -
> -                                 inet_csk(sk)->icsk_af_ops->net_header_len -
> -                                 inet_csk(sk)->icsk_ext_hdr_len -
> -                                 tp->tcp_header_len);
> +               gso_max_size = min_t(u32, sk->sk_gso_max_size,
> +                                    sysctl_tcp_limit_output_bytes >> 1);
> +               xmit_size_goal = (gso_max_size - 1) -
> +                                inet_csk(sk)->icsk_af_ops->net_header_len -
> +                                inet_csk(sk)->icsk_ext_hdr_len -
> +                                tp->tcp_header_len;
>
>                 xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
>
> @@ -3573,4 +3576,5 @@ void __init tcp_init(void)
>         tcp_secret_primary = &tcp_secret_one;
>         tcp_secret_retiring = &tcp_secret_two;
>         tcp_secret_secondary = &tcp_secret_two;
> +       tcp_tasklet_init();
>  }
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 72b7c63..83b358f 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -482,6 +482,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
>                         treq->snt_isn + 1 + tcp_s_data_size(oldtp);
>
>                 tcp_prequeue_init(newtp);
> +               INIT_LIST_HEAD(&newtp->tsq_node);
>
>                 tcp_init_wl(newtp, treq->rcv_isn);
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index c465d3e..991ae45 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -50,6 +50,9 @@ int sysctl_tcp_retrans_collapse __read_mostly = 1;
>   */
>  int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
>
> +/* Default TSQ limit of two TSO segments */
> +int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
> +
>  /* This limits the percentage of the congestion window which we
>   * will allow a single TSO frame to consume.  Building TSO frames
>   * which are too large can cause TCP streams to be bursty.
> @@ -65,6 +68,8 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
>  int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
>  EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
>
> +static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
> +                          int push_one, gfp_t gfp);
>
>  /* Account for new data that has been sent to the network. */
>  static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
> @@ -783,6 +788,118 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
>         return size;
>  }
>
> +
> +/* TCP SMALL QUEUES (TSQ)
> + *
> + * TSQ goal is to keep small amount of skbs per tcp flow in tx queues (qdisc+dev)
> + * to reduce RTT and bufferbloat.
> + * We do this using a special skb destructor (tcp_wfree).
> + *
> + * Its important tcp_wfree() can be replaced by sock_wfree() in the event skb
> + * needs to be reallocated in a driver.
> + * The invariant being skb->truesize substracted from sk->sk_wmem_alloc
> + *
> + * Since transmit from skb destructor is forbidden, we use a tasklet
> + * to process all sockets that eventually need to send more skbs.
> + * We use one tasklet per cpu, with its own queue of sockets.
> + */
> +struct tsq_tasklet {
> +       struct tasklet_struct   tasklet;
> +       struct list_head        head; /* queue of tcp sockets */
> +};
> +static DEFINE_PER_CPU(struct tsq_tasklet, tsq_tasklet);
> +
> +/*
> + * One tasklest per cpu tries to send more skbs.
> + * We run in tasklet context but need to disable irqs when
> + * transfering tsq->head because tcp_wfree() might
> + * interrupt us (non NAPI drivers)
> + */
> +static void tcp_tasklet_func(unsigned long data)
> +{
> +       struct tsq_tasklet *tsq = (struct tsq_tasklet *)data;
> +       LIST_HEAD(list);
> +       unsigned long flags;
> +       struct list_head *q, *n;
> +       struct tcp_sock *tp;
> +       struct sock *sk;
> +
> +       local_irq_save(flags);
> +       list_splice_init(&tsq->head, &list);
> +       local_irq_restore(flags);
> +
> +       list_for_each_safe(q, n, &list) {
> +               tp = list_entry(q, struct tcp_sock, tsq_node);
> +               list_del(&tp->tsq_node);
> +
> +               sk = (struct sock *)tp;
> +               bh_lock_sock(sk);
> +
> +               if (!sock_owned_by_user(sk)) {
> +                       if ((1 << sk->sk_state) &
> +                           (TCPF_CLOSE_WAIT | TCPF_ESTABLISHED))
> +                               tcp_write_xmit(sk,
> +                                              tcp_current_mss(sk),
> +                                              0, 0,
> +                                              GFP_ATOMIC);
> +               } else {
> +                       /* TODO:
> +                        * setup a timer, or check TSQ_OWNED in release_sock()
> +                        */
> +                       set_bit(TSQ_OWNED, &tp->tsq_flags);
> +               }
> +               bh_unlock_sock(sk);
> +
> +               clear_bit(TSQ_QUEUED, &tp->tsq_flags);
> +               sk_free(sk);
> +       }
> +}
> +
> +void __init tcp_tasklet_init(void)
> +{
> +       int i;
> +
> +       for_each_possible_cpu(i) {
> +               struct tsq_tasklet *tsq = &per_cpu(tsq_tasklet, i);
> +
> +               INIT_LIST_HEAD(&tsq->head);
> +               tasklet_init(&tsq->tasklet,
> +                            tcp_tasklet_func,
> +                            (unsigned long)tsq);
> +       }
> +}
> +
> +/*
> + * Write buffer destructor automatically called from kfree_skb.
> + * We cant xmit new skbs from this context, as we might already
> + * hold qdisc lock.
> + */
> +void tcp_wfree(struct sk_buff *skb)
> +{
> +       struct sock *sk = skb->sk;
> +       struct tcp_sock *tp = tcp_sk(sk);
> +
> +       if (test_and_clear_bit(TSQ_THROTTLED, &tp->tsq_flags) &&
> +           !test_and_set_bit(TSQ_QUEUED, &tp->tsq_flags)) {
> +               unsigned long flags;
> +               struct tsq_tasklet *tsq;
> +
> +               /* Keep a ref on socket.
> +                * This last ref will be released in tcp_tasklet_func()
> +                */
> +               atomic_sub(skb->truesize - 1, &sk->sk_wmem_alloc);
> +
> +               /* queue this socket to tasklet queue */
> +               local_irq_save(flags);
> +               tsq = &__get_cpu_var(tsq_tasklet);
> +               list_add(&tp->tsq_node, &tsq->head);
> +               tasklet_schedule(&tsq->tasklet);
> +               local_irq_restore(flags);
> +       } else {
> +               sock_wfree(skb);
> +       }
> +}
> +
>  /* This routine actually transmits TCP packets queued in by
>   * tcp_do_sendmsg().  This is used by both the initial
>   * transmission and possible later retransmissions.
> @@ -844,7 +961,12 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>
>         skb_push(skb, tcp_header_size);
>         skb_reset_transport_header(skb);
> -       skb_set_owner_w(skb, sk);
> +
> +       skb_orphan(skb);
> +       skb->sk = sk;
> +       skb->destructor = (sysctl_tcp_limit_output_bytes > 0) ?
> +                         tcp_wfree : sock_wfree;
> +       atomic_add(skb->truesize, &sk->sk_wmem_alloc);
>
>         /* Build TCP header and checksum it. */
>         th = tcp_hdr(skb);
> @@ -1780,6 +1902,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>         while ((skb = tcp_send_head(sk))) {
>                 unsigned int limit;
>
> +
>                 tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
>                 BUG_ON(!tso_segs);
>
> @@ -1800,6 +1923,13 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>                                 break;
>                 }
>
> +               /* TSQ : sk_wmem_alloc accounts skb truesize,
> +                * including skb overhead. But thats OK.
> +                */
> +               if (atomic_read(&sk->sk_wmem_alloc) >= sysctl_tcp_limit_output_bytes) {
> +                       set_bit(TSQ_THROTTLED, &tp->tsq_flags);
> +                       break;
> +               }
>                 limit = mss_now;
>                 if (tso_segs > 1 && !tcp_urg_mode(tp))
>                         limit = tcp_mss_split_point(sk, skb, mss_now,
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
