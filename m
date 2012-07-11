From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH v3 net-next] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 12:29:21 -0700
Message-ID: <CAB_+Fg496FgQZkJE8uf_4RX_wW+fz1p5Rq8rY=BuA=c6KPakpA@mail.gmail.com>
References: <1342021831.3265.8174.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4649581658320573006=="
Cc: netdev@vger.kernel.org, codel@lists.bufferbloat.net, ncardwell@google.com,
	David Miller <davem@davemloft.net>, mattmathis@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1342021831.3265.8174.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

--===============4649581658320573006==
Content-Type: multipart/alternative; boundary=f46d0447963124892604c492dd09

--f46d0447963124892604c492dd09
Content-Type: text/plain; charset=ISO-8859-1

I have a couple of high level questions on the two solutions for maintain
small queues at qdisc: 1) using codel's feedback versus 2) the approach in
TSQ to explicitly limit bytes per-flow to tcp_limit_output_bytes.

1. multiple flows case: codel feedback (be it drop/ECN or direct feedback
like in your patch with fq_codel: report congestion notification at enqueue
time) seems to work in maintaining small queues regardless of the number of
connections. TSQ probably won't achieve this goal when number of flows is
large. Is this correct?

2. cwnd adjustment: codel feedback directly and explicitly controls
snd_cwnd which in turn will also adjust the send buffer size to appropriate
value. That's a nice property, which TSQ probably won't have because it
doesn't explicitly adjust snd_cwnd.

Considering these two points, why TSQ over the Codel feedback approach?

On Wed, Jul 11, 2012 at 8:50 AM, Eric Dumazet <eric.dumazet@gmail.com>wrote:

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
> Results on my dev machines (tg3/ixgbe nics) are really impressive,
> using standard pfifo_fast, and with or without TSO/GSO.
>
> Without reduction of nominal bandwidth, we have reduction of buffering
> per bulk sender :
> < 1ms on Gbit (instead of 50ms with TSO)
> < 8ms on 100Mbit (instead of 132 ms)
>
> I no longer have 4 MBytes backlogged in qdisc by a single netperf
> session, and both side socket autotuning no longer use 4 Mbytes.
>
> As skb destructor cannot restart xmit itself ( as qdisc lock might be
> taken at this point ), we delegate the work to a tasklet. We use one
> tasklest per cpu for performance reasons.
>
> If tasklet finds a socket owned by the user, it sets TSQ_OWNED flag.
> This flag is tested in a new protocol method called from release_sock(),
> to eventually send new segments.
>
> [1] New /proc/sys/net/ipv4/tcp_limit_output_bytes tunable
> [2] skb_orphan() is usually called at TX completion time,
>   but some drivers call it in their start_xmit() handler.
>   These drivers should at least use BQL, or else a single TCP
>   session can still fill the whole NIC TX ring, since TSQ will
>   have no effect.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Dave Taht <dave.taht@bufferbloat.net>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Matt Mathis <mattmathis@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> ---
>  Documentation/networking/ip-sysctl.txt |   14 ++
>  include/linux/tcp.h                    |    9 +
>  include/net/sock.h                     |    2
>  include/net/tcp.h                      |    4
>  net/core/sock.c                        |    4
>  net/ipv4/sysctl_net_ipv4.c             |    7 +
>  net/ipv4/tcp.c                         |    6
>  net/ipv4/tcp_ipv4.c                    |    1
>  net/ipv4/tcp_minisocks.c               |    1
>  net/ipv4/tcp_output.c                  |  154 ++++++++++++++++++++++-
>  net/ipv6/tcp_ipv6.c                    |    1
>  11 files changed, 202 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt
> b/Documentation/networking/ip-sysctl.txt
> index 47b6c79..e20c17a 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -551,6 +551,20 @@ tcp_thin_dupack - BOOLEAN
>         Documentation/networking/tcp-thin.txt
>         Default: 0
>
> +tcp_limit_output_bytes - INTEGER
> +       Controls TCP Small Queue limit per tcp socket.
> +       TCP bulk sender tends to increase packets in flight until it
> +       gets losses notifications. With SNDBUF autotuning, this can
> +       result in a large amount of packets queued in qdisc/device
> +       on the local machine, hurting latency of other flows, for
> +       typical pfifo_fast qdiscs.
> +       tcp_limit_output_bytes limits the number of bytes on qdisc
> +       or device to reduce artificial RTT/cwnd and reduce bufferbloat.
> +       Note: For GSO/TSO enabled flows, we try to have at least two
> +       packets in flight. Reducing tcp_limit_output_bytes might also
> +       reduce the size of individual GSO packet (64KB being the max)
> +       Default: 131072
> +
>  UDP variables:
>
>  udp_mem - vector of 3 INTEGERs: min, pressure, max
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 2de9cf4..1888169 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -339,6 +339,9 @@ struct tcp_sock {
>         u32     rcv_tstamp;     /* timestamp of last received ACK (for
> keepalives) */
>         u32     lsndtime;       /* timestamp of last sent data packet (for
> restart window) */
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
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 640432a..eefce84 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -858,6 +858,8 @@ struct proto {
>         int                     (*backlog_rcv) (struct sock *sk,
>                                                 struct sk_buff *skb);
>
> +       void            (*release_cb)(struct sock *sk);
> +
>         /* Keeping track of sk's, looking them up, and port selection
> methods. */
>         void                    (*hash)(struct sock *sk);
>         void                    (*unhash)(struct sock *sk);
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 3618fef..439984b 100644
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
> @@ -334,6 +337,7 @@ extern int tcp_sendmsg(struct kiocb *iocb, struct sock
> *sk, struct msghdr *msg,
>                        size_t size);
>  extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
>                         size_t size, int flags);
> +extern void tcp_release_cb(struct sock *sk);
>  extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
>  extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
>                                  const struct tcphdr *th, unsigned int
> len);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 929bdcc..24039ac 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2159,6 +2159,10 @@ void release_sock(struct sock *sk)
>         spin_lock_bh(&sk->sk_lock.slock);
>         if (sk->sk_backlog.tail)
>                 __release_sock(sk);
> +
> +       if (sk->sk_prot->release_cb)
> +               sk->sk_prot->release_cb(sk);
> +
>         sk->sk_lock.owned = 0;
>         if (waitqueue_active(&sk->sk_lock.wq))
>                 wake_up(&sk->sk_lock.wq);
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
> index d902da9..4252cd8 100644
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
> @@ -796,6 +797,10 @@ static unsigned int tcp_xmit_size_goal(struct sock
> *sk, u32 mss_now,
>                                   inet_csk(sk)->icsk_ext_hdr_len -
>                                   tp->tcp_header_len);
>
> +               /* TSQ : try to have two TSO segments in flight */
> +               xmit_size_goal = min_t(u32, xmit_size_goal,
> +                                      sysctl_tcp_limit_output_bytes >> 1);
> +
>                 xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
>
>                 /* We try hard to avoid divides here */
> @@ -3574,4 +3579,5 @@ void __init tcp_init(void)
>         tcp_secret_primary = &tcp_secret_one;
>         tcp_secret_retiring = &tcp_secret_two;
>         tcp_secret_secondary = &tcp_secret_two;
> +       tcp_tasklet_init();
>  }
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index ddefd39..01545a3 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2588,6 +2588,7 @@ struct proto tcp_prot = {
>         .sendmsg                = tcp_sendmsg,
>         .sendpage               = tcp_sendpage,
>         .backlog_rcv            = tcp_v4_do_rcv,
> +       .release_cb             = tcp_release_cb,
>         .hash                   = inet_hash,
>         .unhash                 = inet_unhash,
>         .get_port               = inet_csk_get_port,
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 6560886..c66f2ed 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -424,6 +424,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk,
> struct request_sock *req,
>                         treq->snt_isn + 1 + tcp_s_data_size(oldtp);
>
>                 tcp_prequeue_init(newtp);
> +               INIT_LIST_HEAD(&newtp->tsq_node);
>
>                 tcp_init_wl(newtp, treq->rcv_isn);
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index c465d3e..03854ab 100644
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
> +static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int
> nonagle,
> +                          int push_one, gfp_t gfp);
>
>  /* Account for new data that has been sent to the network. */
>  static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff
> *skb)
> @@ -783,6 +788,140 @@ static unsigned int tcp_established_options(struct
> sock *sk, struct sk_buff *skb
>         return size;
>  }
>
> +
> +/* TCP SMALL QUEUES (TSQ)
> + *
> + * TSQ goal is to keep small amount of skbs per tcp flow in tx queues
> (qdisc+dev)
> + * to reduce RTT and bufferbloat.
> + * We do this using a special skb destructor (tcp_wfree).
> + *
> + * Its important tcp_wfree() can be replaced by sock_wfree() in the event
> skb
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
> +                           (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
> +                            TCPF_CLOSING | TCPF_CLOSE_WAIT))
> +                               tcp_write_xmit(sk,
> +                                              tcp_current_mss(sk),
> +                                              0, 0,
> +                                              GFP_ATOMIC);
> +               } else {
> +                       /* defer the work to tcp_release_cb() */
> +                       set_bit(TSQ_OWNED, &tp->tsq_flags);
> +               }
> +               bh_unlock_sock(sk);
> +
> +               clear_bit(TSQ_QUEUED, &tp->tsq_flags);
> +               sk_free(sk);
> +       }
> +}
> +
> +/**
> + * tcp_release_cb - tcp release_sock() callback
> + * @sk: socket
> + *
> + * called from release_sock() to perform protocol dependent
> + * actions before socket release.
> + */
> +void tcp_release_cb(struct sock *sk)
> +{
> +       struct tcp_sock *tp = tcp_sk(sk);
> +
> +       if (test_and_clear_bit(TSQ_OWNED, &tp->tsq_flags)) {
> +               if ((1 << sk->sk_state) &
> +                   (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
> +                    TCPF_CLOSING | TCPF_CLOSE_WAIT))
> +                       tcp_write_xmit(sk,
> +                                      tcp_current_mss(sk),
> +                                      0, 0,
> +                                      GFP_ATOMIC);
> +       }
> +}
> +EXPORT_SYMBOL(tcp_release_cb);
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
> @@ -844,7 +983,12 @@ static int tcp_transmit_skb(struct sock *sk, struct
> sk_buff *skb, int clone_it,
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
> @@ -1780,6 +1924,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned
> int mss_now, int nonagle,
>         while ((skb = tcp_send_head(sk))) {
>                 unsigned int limit;
>
> +
>                 tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
>                 BUG_ON(!tso_segs);
>
> @@ -1800,6 +1945,13 @@ static bool tcp_write_xmit(struct sock *sk,
> unsigned int mss_now, int nonagle,
>                                 break;
>                 }
>
> +               /* TSQ : sk_wmem_alloc accounts skb truesize,
> +                * including skb overhead. But thats OK.
> +                */
> +               if (atomic_read(&sk->sk_wmem_alloc) >=
> sysctl_tcp_limit_output_bytes) {
> +                       set_bit(TSQ_THROTTLED, &tp->tsq_flags);
> +                       break;
> +               }
>                 limit = mss_now;
>                 if (tso_segs > 1 && !tcp_urg_mode(tp))
>                         limit = tcp_mss_split_point(sk, skb, mss_now,
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 61175cb..70458a9 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1970,6 +1970,7 @@ struct proto tcpv6_prot = {
>         .sendmsg                = tcp_sendmsg,
>         .sendpage               = tcp_sendpage,
>         .backlog_rcv            = tcp_v6_do_rcv,
> +       .release_cb             = tcp_release_cb,
>         .hash                   = tcp_v6_hash,
>         .unhash                 = inet_unhash,
>         .get_port               = inet_csk_get_port,
>
>
>

--f46d0447963124892604c492dd09
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I have a couple of high level questions on the two solutions for maintain s=
mall queues at qdisc: 1) using codel&#39;s feedback versus 2) the approach =
in TSQ to explicitly limit bytes per-flow to=A0tcp_limit_output_bytes.<div>
<br></div><div>1. multiple flows case: codel feedback (be it drop/ECN or di=
rect feedback like in your patch with fq_codel: report congestion notificat=
ion at enqueue time) seems to work in maintaining small queues regardless o=
f the number of connections. TSQ probably won&#39;t achieve this goal when =
number of flows is large. Is this correct?</div>
<div><br></div><div>2. cwnd adjustment: codel feedback directly and explici=
tly controls snd_cwnd which in turn will also adjust the send buffer size t=
o appropriate value. That&#39;s a nice property, which TSQ probably won&#39=
;t have because it doesn&#39;t explicitly adjust snd_cwnd.=A0</div>
<div><br><div class=3D"gmail_extra">Considering these two points, why TSQ o=
ver the Codel feedback approach?<br><br><div class=3D"gmail_quote">On Wed, =
Jul 11, 2012 at 8:50 AM, Eric Dumazet <span dir=3D"ltr">&lt;<a href=3D"mail=
to:eric.dumazet@gmail.com" target=3D"_blank">eric.dumazet@gmail.com</a>&gt;=
</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">This introduce TSQ (TCP Small Queues)<br>
<br>
TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &amp;<br>
device queues), to reduce RTT and cwnd bias, part of the bufferbloat<br>
problem.<br>
<br>
sk-&gt;sk_wmem_alloc not allowed to grow above a given limit,<br>
allowing no more than ~128KB [1] per tcp socket in qdisc/dev layers at a<br=
>
given time.<br>
<br>
TSO packets are sized/capped to half the limit, so that we have two<br>
TSO packets in flight, allowing better bandwidth use.<br>
<br>
As a side effect, setting the limit to 40000 automatically reduces the<br>
standard gso max limit (65536) to 40000/2 : It can help to reduce<br>
latencies of high prio packets, having smaller TSO packets.<br>
<br>
This means we divert sock_wfree() to a tcp_wfree() handler, to<br>
queue/send following frames when skb_orphan() [2] is called for the<br>
already queued skbs.<br>
<br>
Results on my dev machines (tg3/ixgbe nics) are really impressive,<br>
using standard pfifo_fast, and with or without TSO/GSO.<br>
<br>
Without reduction of nominal bandwidth, we have reduction of buffering<br>
per bulk sender :<br>
&lt; 1ms on Gbit (instead of 50ms with TSO)<br>
&lt; 8ms on 100Mbit (instead of 132 ms)<br>
<br>
I no longer have 4 MBytes backlogged in qdisc by a single netperf<br>
session, and both side socket autotuning no longer use 4 Mbytes.<br>
<br>
As skb destructor cannot restart xmit itself ( as qdisc lock might be<br>
taken at this point ), we delegate the work to a tasklet. We use one<br>
tasklest per cpu for performance reasons.<br>
<br>
If tasklet finds a socket owned by the user, it sets TSQ_OWNED flag.<br>
This flag is tested in a new protocol method called from release_sock(),<br=
>
to eventually send new segments.<br>
<br>
[1] New /proc/sys/net/ipv4/tcp_limit_output_bytes tunable<br>
[2] skb_orphan() is usually called at TX completion time,<br>
=A0 but some drivers call it in their start_xmit() handler.<br>
=A0 These drivers should at least use BQL, or else a single TCP<br>
=A0 session can still fill the whole NIC TX ring, since TSQ will<br>
=A0 have no effect.<br>
<br>
Signed-off-by: Eric Dumazet &lt;<a href=3D"mailto:edumazet@google.com">edum=
azet@google.com</a>&gt;<br>
Cc: Dave Taht &lt;<a href=3D"mailto:dave.taht@bufferbloat.net">dave.taht@bu=
fferbloat.net</a>&gt;<br>
Cc: Tom Herbert &lt;<a href=3D"mailto:therbert@google.com">therbert@google.=
com</a>&gt;<br>
Cc: Matt Mathis &lt;<a href=3D"mailto:mattmathis@google.com">mattmathis@goo=
gle.com</a>&gt;<br>
Cc: Yuchung Cheng &lt;<a href=3D"mailto:ycheng@google.com">ycheng@google.co=
m</a>&gt;<br>
Cc: Nandita Dukkipati &lt;<a href=3D"mailto:nanditad@google.com">nanditad@g=
oogle.com</a>&gt;<br>
---<br>
=A0Documentation/networking/ip-sysctl.txt | =A0 14 ++<br>
=A0include/linux/tcp.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 +<=
br>
=A0include/net/sock.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02<br=
>
=A0include/net/tcp.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04<=
br>
=A0net/core/sock.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
4<br>
=A0net/ipv4/sysctl_net_ipv4.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A07 +<br>
=A0net/ipv4/tcp.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
6<br>
=A0net/ipv4/tcp_ipv4.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01<br=
>
=A0net/ipv4/tcp_minisocks.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01<br>
=A0net/ipv4/tcp_output.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0154 ++++++=
++++++++++++++++-<br>
=A0net/ipv6/tcp_ipv6.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01<br=
>
=A011 files changed, 202 insertions(+), 1 deletion(-)<br>
<br>
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/network=
ing/ip-sysctl.txt<br>
index 47b6c79..e20c17a 100644<br>
--- a/Documentation/networking/ip-sysctl.txt<br>
+++ b/Documentation/networking/ip-sysctl.txt<br>
@@ -551,6 +551,20 @@ tcp_thin_dupack - BOOLEAN<br>
=A0 =A0 =A0 =A0 Documentation/networking/tcp-thin.txt<br>
=A0 =A0 =A0 =A0 Default: 0<br>
<br>
+tcp_limit_output_bytes - INTEGER<br>
+ =A0 =A0 =A0 Controls TCP Small Queue limit per tcp socket.<br>
+ =A0 =A0 =A0 TCP bulk sender tends to increase packets in flight until it<=
br>
+ =A0 =A0 =A0 gets losses notifications. With SNDBUF autotuning, this can<b=
r>
+ =A0 =A0 =A0 result in a large amount of packets queued in qdisc/device<br=
>
+ =A0 =A0 =A0 on the local machine, hurting latency of other flows, for<br>
+ =A0 =A0 =A0 typical pfifo_fast qdiscs.<br>
+ =A0 =A0 =A0 tcp_limit_output_bytes limits the number of bytes on qdisc<br=
>
+ =A0 =A0 =A0 or device to reduce artificial RTT/cwnd and reduce bufferbloa=
t.<br>
+ =A0 =A0 =A0 Note: For GSO/TSO enabled flows, we try to have at least two<=
br>
+ =A0 =A0 =A0 packets in flight. Reducing tcp_limit_output_bytes might also=
<br>
+ =A0 =A0 =A0 reduce the size of individual GSO packet (64KB being the max)=
<br>
+ =A0 =A0 =A0 Default: 131072<br>
+<br>
=A0UDP variables:<br>
<br>
=A0udp_mem - vector of 3 INTEGERs: min, pressure, max<br>
diff --git a/include/linux/tcp.h b/include/linux/tcp.h<br>
index 2de9cf4..1888169 100644<br>
--- a/include/linux/tcp.h<br>
+++ b/include/linux/tcp.h<br>
@@ -339,6 +339,9 @@ struct tcp_sock {<br>
=A0 =A0 =A0 =A0 u32 =A0 =A0 rcv_tstamp; =A0 =A0 /* timestamp of last receiv=
ed ACK (for keepalives) */<br>
=A0 =A0 =A0 =A0 u32 =A0 =A0 lsndtime; =A0 =A0 =A0 /* timestamp of last sent=
 data packet (for restart window) */<br>
<br>
+ =A0 =A0 =A0 struct list_head tsq_node; /* anchor in tsq_tasklet.head list=
 */<br>
+ =A0 =A0 =A0 unsigned long =A0 tsq_flags;<br>
+<br>
=A0 =A0 =A0 =A0 /* Data for direct copy to user */<br>
=A0 =A0 =A0 =A0 struct {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff_head =A0 =A0 prequeue;<br>
@@ -494,6 +497,12 @@ struct tcp_sock {<br>
=A0 =A0 =A0 =A0 struct tcp_cookie_values =A0*cookie_values;<br>
=A0};<br>
<br>
+enum tsq_flags {<br>
+ =A0 =A0 =A0 TSQ_THROTTLED,<br>
+ =A0 =A0 =A0 TSQ_QUEUED,<br>
+ =A0 =A0 =A0 TSQ_OWNED, /* tcp_tasklet_func() found socket was locked */<b=
r>
+};<br>
+<br>
=A0static inline struct tcp_sock *tcp_sk(const struct sock *sk)<br>
=A0{<br>
=A0 =A0 =A0 =A0 return (struct tcp_sock *)sk;<br>
diff --git a/include/net/sock.h b/include/net/sock.h<br>
index 640432a..eefce84 100644<br>
--- a/include/net/sock.h<br>
+++ b/include/net/sock.h<br>
@@ -858,6 +858,8 @@ struct proto {<br>
=A0 =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (*backlog_rcv) =
(struct sock *sk,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb);<br>
<br>
+ =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0(*release_cb)(struct sock *sk);<b=
r>
+<br>
=A0 =A0 =A0 =A0 /* Keeping track of sk&#39;s, looking them up, and port sel=
ection methods. */<br>
=A0 =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*hash)(struct =
sock *sk);<br>
=A0 =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*unhash)(struc=
t sock *sk);<br>
diff --git a/include/net/tcp.h b/include/net/tcp.h<br>
index 3618fef..439984b 100644<br>
--- a/include/net/tcp.h<br>
+++ b/include/net/tcp.h<br>
@@ -253,6 +253,7 @@ extern int sysctl_tcp_cookie_size;<br>
=A0extern int sysctl_tcp_thin_linear_timeouts;<br>
=A0extern int sysctl_tcp_thin_dupack;<br>
=A0extern int sysctl_tcp_early_retrans;<br>
+extern int sysctl_tcp_limit_output_bytes;<br>
<br>
=A0extern atomic_long_t tcp_memory_allocated;<br>
=A0extern struct percpu_counter tcp_sockets_allocated;<br>
@@ -321,6 +322,8 @@ extern struct proto tcp_prot;<br>
<br>
=A0extern void tcp_init_mem(struct net *net);<br>
<br>
+extern void tcp_tasklet_init(void);<br>
+<br>
=A0extern void tcp_v4_err(struct sk_buff *skb, u32);<br>
<br>
=A0extern void tcp_shutdown (struct sock *sk, int how);<br>
@@ -334,6 +337,7 @@ extern int tcp_sendmsg(struct kiocb *iocb, struct sock =
*sk, struct msghdr *msg,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t size);<br>
=A0extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,<=
br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, int flags);<br=
>
+extern void tcp_release_cb(struct sock *sk);<br>
=A0extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);<br>
=A0extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,<b=
r>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const st=
ruct tcphdr *th, unsigned int len);<br>
diff --git a/net/core/sock.c b/net/core/sock.c<br>
index 929bdcc..24039ac 100644<br>
--- a/net/core/sock.c<br>
+++ b/net/core/sock.c<br>
@@ -2159,6 +2159,10 @@ void release_sock(struct sock *sk)<br>
=A0 =A0 =A0 =A0 spin_lock_bh(&amp;sk-&gt;sk_lock.slock);<br>
=A0 =A0 =A0 =A0 if (sk-&gt;sk_backlog.tail)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __release_sock(sk);<br>
+<br>
+ =A0 =A0 =A0 if (sk-&gt;sk_prot-&gt;release_cb)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk-&gt;sk_prot-&gt;release_cb(sk);<br>
+<br>
=A0 =A0 =A0 =A0 sk-&gt;sk_lock.owned =3D 0;<br>
=A0 =A0 =A0 =A0 if (waitqueue_active(&amp;sk-&gt;sk_lock.wq))<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up(&amp;sk-&gt;sk_lock.wq);<br>
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c<br>
index 12aa0c5..70730f7 100644<br>
--- a/net/ipv4/sysctl_net_ipv4.c<br>
+++ b/net/ipv4/sysctl_net_ipv4.c<br>
@@ -598,6 +598,13 @@ static struct ctl_table ipv4_table[] =3D {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_dointvec<br>
=A0 =A0 =A0 =A0 },<br>
+ =A0 =A0 =A0 {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D &quot;tcp_limit_out=
put_bytes&quot;,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &amp;sysctl_tcp=
_limit_output_bytes,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(int),<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_dointvec<br>
+ =A0 =A0 =A0 },<br>
=A0#ifdef CONFIG_NET_DMA<br>
=A0 =A0 =A0 =A0 {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D &quot;tcp_dma_cop=
ybreak&quot;,<br>
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c<br>
index d902da9..4252cd8 100644<br>
--- a/net/ipv4/tcp.c<br>
+++ b/net/ipv4/tcp.c<br>
@@ -376,6 +376,7 @@ void tcp_init_sock(struct sock *sk)<br>
=A0 =A0 =A0 =A0 skb_queue_head_init(&amp;tp-&gt;out_of_order_queue);<br>
=A0 =A0 =A0 =A0 tcp_init_xmit_timers(sk);<br>
=A0 =A0 =A0 =A0 tcp_prequeue_init(tp);<br>
+ =A0 =A0 =A0 INIT_LIST_HEAD(&amp;tp-&gt;tsq_node);<br>
<br>
=A0 =A0 =A0 =A0 icsk-&gt;icsk_rto =3D TCP_TIMEOUT_INIT;<br>
=A0 =A0 =A0 =A0 tp-&gt;mdev =3D TCP_TIMEOUT_INIT;<br>
@@ -796,6 +797,10 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk=
, u32 mss_now,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_cs=
k(sk)-&gt;icsk_ext_hdr_len -<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp-&gt;=
tcp_header_len);<br>
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TSQ : try to have two TSO segments in flig=
ht */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 xmit_size_goal =3D min_t(u32, xmit_size_goal,=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0sysctl_tcp_limit_output_bytes &gt;&gt; 1);<br>
+<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xmit_size_goal =3D tcp_bound_to_half_wnd(tp=
, xmit_size_goal);<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We try hard to avoid divides here */<br>
@@ -3574,4 +3579,5 @@ void __init tcp_init(void)<br>
=A0 =A0 =A0 =A0 tcp_secret_primary =3D &amp;tcp_secret_one;<br>
=A0 =A0 =A0 =A0 tcp_secret_retiring =3D &amp;tcp_secret_two;<br>
=A0 =A0 =A0 =A0 tcp_secret_secondary =3D &amp;tcp_secret_two;<br>
+ =A0 =A0 =A0 tcp_tasklet_init();<br>
=A0}<br>
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c<br>
index ddefd39..01545a3 100644<br>
--- a/net/ipv4/tcp_ipv4.c<br>
+++ b/net/ipv4/tcp_ipv4.c<br>
@@ -2588,6 +2588,7 @@ struct proto tcp_prot =3D {<br>
=A0 =A0 =A0 =A0 .sendmsg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D tcp_sendmsg,<br=
>
=A0 =A0 =A0 =A0 .sendpage =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D tcp_sendpage,<br>
=A0 =A0 =A0 =A0 .backlog_rcv =A0 =A0 =A0 =A0 =A0 =A0=3D tcp_v4_do_rcv,<br>
+ =A0 =A0 =A0 .release_cb =A0 =A0 =A0 =A0 =A0 =A0 =3D tcp_release_cb,<br>
=A0 =A0 =A0 =A0 .hash =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_hash,<br=
>
=A0 =A0 =A0 =A0 .unhash =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_unhash,<br=
>
=A0 =A0 =A0 =A0 .get_port =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_csk_get_port=
,<br>
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c<br>
index 6560886..c66f2ed 100644<br>
--- a/net/ipv4/tcp_minisocks.c<br>
+++ b/net/ipv4/tcp_minisocks.c<br>
@@ -424,6 +424,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, =
struct request_sock *req,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 treq-&gt;snt_isn + 1 + tcp_=
s_data_size(oldtp);<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_prequeue_init(newtp);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&amp;newtp-&gt;tsq_node);<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_init_wl(newtp, treq-&gt;rcv_isn);<br>
<br>
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c<br>
index c465d3e..03854ab 100644<br>
--- a/net/ipv4/tcp_output.c<br>
+++ b/net/ipv4/tcp_output.c<br>
@@ -50,6 +50,9 @@ int sysctl_tcp_retrans_collapse __read_mostly =3D 1;<br>
=A0 */<br>
=A0int sysctl_tcp_workaround_signed_windows __read_mostly =3D 0;<br>
<br>
+/* Default TSQ limit of two TSO segments */<br>
+int sysctl_tcp_limit_output_bytes __read_mostly =3D 131072;<br>
+<br>
=A0/* This limits the percentage of the congestion window which we<br>
=A0 * will allow a single TSO frame to consume. =A0Building TSO frames<br>
=A0 * which are too large can cause TCP streams to be bursty.<br>
@@ -65,6 +68,8 @@ int sysctl_tcp_slow_start_after_idle __read_mostly =3D 1;=
<br>
=A0int sysctl_tcp_cookie_size __read_mostly =3D 0; /* TCP_COOKIE_MAX */<br>
=A0EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);<br>
<br>
+static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nona=
gle,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int push_one, gfp_t gf=
p);<br>
<br>
=A0/* Account for new data that has been sent to the network. */<br>
=A0static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buf=
f *skb)<br>
@@ -783,6 +788,140 @@ static unsigned int tcp_established_options(struct so=
ck *sk, struct sk_buff *skb<br>
=A0 =A0 =A0 =A0 return size;<br>
=A0}<br>
<br>
+<br>
+/* TCP SMALL QUEUES (TSQ)<br>
+ *<br>
+ * TSQ goal is to keep small amount of skbs per tcp flow in tx queues (qdi=
sc+dev)<br>
+ * to reduce RTT and bufferbloat.<br>
+ * We do this using a special skb destructor (tcp_wfree).<br>
+ *<br>
+ * Its important tcp_wfree() can be replaced by sock_wfree() in the event =
skb<br>
+ * needs to be reallocated in a driver.<br>
+ * The invariant being skb-&gt;truesize substracted from sk-&gt;sk_wmem_al=
loc<br>
+ *<br>
+ * Since transmit from skb destructor is forbidden, we use a tasklet<br>
+ * to process all sockets that eventually need to send more skbs.<br>
+ * We use one tasklet per cpu, with its own queue of sockets.<br>
+ */<br>
+struct tsq_tasklet {<br>
+ =A0 =A0 =A0 struct tasklet_struct =A0 tasklet;<br>
+ =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0head; /* queue of tcp sockets=
 */<br>
+};<br>
+static DEFINE_PER_CPU(struct tsq_tasklet, tsq_tasklet);<br>
+<br>
+/*<br>
+ * One tasklest per cpu tries to send more skbs.<br>
+ * We run in tasklet context but need to disable irqs when<br>
+ * transfering tsq-&gt;head because tcp_wfree() might<br>
+ * interrupt us (non NAPI drivers)<br>
+ */<br>
+static void tcp_tasklet_func(unsigned long data)<br>
+{<br>
+ =A0 =A0 =A0 struct tsq_tasklet *tsq =3D (struct tsq_tasklet *)data;<br>
+ =A0 =A0 =A0 LIST_HEAD(list);<br>
+ =A0 =A0 =A0 unsigned long flags;<br>
+ =A0 =A0 =A0 struct list_head *q, *n;<br>
+ =A0 =A0 =A0 struct tcp_sock *tp;<br>
+ =A0 =A0 =A0 struct sock *sk;<br>
+<br>
+ =A0 =A0 =A0 local_irq_save(flags);<br>
+ =A0 =A0 =A0 list_splice_init(&amp;tsq-&gt;head, &amp;list);<br>
+ =A0 =A0 =A0 local_irq_restore(flags);<br>
+<br>
+ =A0 =A0 =A0 list_for_each_safe(q, n, &amp;list) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D list_entry(q, struct tcp_sock, tsq_nod=
e);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;tp-&gt;tsq_node);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk =3D (struct sock *)tp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh_lock_sock(sk);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sock_owned_by_user(sk)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((1 &lt;&lt; sk-&gt;sk_sta=
te) &amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (TCPF_ESTABLISHED | T=
CPF_FIN_WAIT1 |<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TCPF_CLOSING | TCP=
F_CLOSE_WAIT))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_write_xmi=
t(sk,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0tcp_current_mss(sk),<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A00, 0,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0GFP_ATOMIC);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* defer the work to tcp_rele=
ase_cb() */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(TSQ_OWNED, &amp;tp-&g=
t;tsq_flags);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh_unlock_sock(sk);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(TSQ_QUEUED, &amp;tp-&gt;tsq_flags);=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_free(sk);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+<br>
+/**<br>
+ * tcp_release_cb - tcp release_sock() callback<br>
+ * @sk: socket<br>
+ *<br>
+ * called from release_sock() to perform protocol dependent<br>
+ * actions before socket release.<br>
+ */<br>
+void tcp_release_cb(struct sock *sk)<br>
+{<br>
+ =A0 =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);<br>
+<br>
+ =A0 =A0 =A0 if (test_and_clear_bit(TSQ_OWNED, &amp;tp-&gt;tsq_flags)) {<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((1 &lt;&lt; sk-&gt;sk_state) &amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TCPF_CLOSING | TCPF_CLOSE_WAIT))<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_write_xmit(sk,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0tcp_current_mss(sk),<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A00, 0,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0GFP_ATOMIC);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+EXPORT_SYMBOL(tcp_release_cb);<br>
+<br>
+void __init tcp_tasklet_init(void)<br>
+{<br>
+ =A0 =A0 =A0 int i;<br>
+<br>
+ =A0 =A0 =A0 for_each_possible_cpu(i) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct tsq_tasklet *tsq =3D &amp;per_cpu(tsq_=
tasklet, i);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&amp;tsq-&gt;head);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tasklet_init(&amp;tsq-&gt;tasklet,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_tasklet_func,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long)tsq=
);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+<br>
+/*<br>
+ * Write buffer destructor automatically called from kfree_skb.<br>
+ * We cant xmit new skbs from this context, as we might already<br>
+ * hold qdisc lock.<br>
+ */<br>
+void tcp_wfree(struct sk_buff *skb)<br>
+{<br>
+ =A0 =A0 =A0 struct sock *sk =3D skb-&gt;sk;<br>
+ =A0 =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);<br>
+<br>
+ =A0 =A0 =A0 if (test_and_clear_bit(TSQ_THROTTLED, &amp;tp-&gt;tsq_flags) =
&amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 !test_and_set_bit(TSQ_QUEUED, &amp;tp-&gt;tsq_flags))=
 {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct tsq_tasklet *tsq;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Keep a ref on socket.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This last ref will be released in tcp_ta=
sklet_func()<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_sub(skb-&gt;truesize - 1, &amp;sk-&gt;=
sk_wmem_alloc);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* queue this socket to tasklet queue */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_save(flags);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsq =3D &amp;__get_cpu_var(tsq_tasklet);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&amp;tp-&gt;tsq_node, &amp;tsq-&gt;h=
ead);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule(&amp;tsq-&gt;tasklet);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_restore(flags);<br>
+ =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_wfree(skb);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+<br>
=A0/* This routine actually transmits TCP packets queued in by<br>
=A0 * tcp_do_sendmsg(). =A0This is used by both the initial<br>
=A0 * transmission and possible later retransmissions.<br>
@@ -844,7 +983,12 @@ static int tcp_transmit_skb(struct sock *sk, struct sk=
_buff *skb, int clone_it,<br>
<br>
=A0 =A0 =A0 =A0 skb_push(skb, tcp_header_size);<br>
=A0 =A0 =A0 =A0 skb_reset_transport_header(skb);<br>
- =A0 =A0 =A0 skb_set_owner_w(skb, sk);<br>
+<br>
+ =A0 =A0 =A0 skb_orphan(skb);<br>
+ =A0 =A0 =A0 skb-&gt;sk =3D sk;<br>
+ =A0 =A0 =A0 skb-&gt;destructor =3D (sysctl_tcp_limit_output_bytes &gt; 0)=
 ?<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_wfree : sock_wfree;<b=
r>
+ =A0 =A0 =A0 atomic_add(skb-&gt;truesize, &amp;sk-&gt;sk_wmem_alloc);<br>
<br>
=A0 =A0 =A0 =A0 /* Build TCP header and checksum it. */<br>
=A0 =A0 =A0 =A0 th =3D tcp_hdr(skb);<br>
@@ -1780,6 +1924,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned =
int mss_now, int nonagle,<br>
=A0 =A0 =A0 =A0 while ((skb =3D tcp_send_head(sk))) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int limit;<br>
<br>
+<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tso_segs =3D tcp_init_tso_segs(sk, skb, mss=
_now);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!tso_segs);<br>
<br>
@@ -1800,6 +1945,13 @@ static bool tcp_write_xmit(struct sock *sk, unsigned=
 int mss_now, int nonagle,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TSQ : sk_wmem_alloc accounts skb truesize,=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* including skb overhead. But thats OK.<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_read(&amp;sk-&gt;sk_wmem_alloc) &g=
t;=3D sysctl_tcp_limit_output_bytes) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(TSQ_THROTTLED, &amp;t=
p-&gt;tsq_flags);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 limit =3D mss_now;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tso_segs &gt; 1 &amp;&amp; !tcp_urg_mod=
e(tp))<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 limit =3D tcp_mss_split_poi=
nt(sk, skb, mss_now,<br>
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c<br>
index 61175cb..70458a9 100644<br>
--- a/net/ipv6/tcp_ipv6.c<br>
+++ b/net/ipv6/tcp_ipv6.c<br>
@@ -1970,6 +1970,7 @@ struct proto tcpv6_prot =3D {<br>
=A0 =A0 =A0 =A0 .sendmsg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D tcp_sendmsg,<br=
>
=A0 =A0 =A0 =A0 .sendpage =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D tcp_sendpage,<br>
=A0 =A0 =A0 =A0 .backlog_rcv =A0 =A0 =A0 =A0 =A0 =A0=3D tcp_v6_do_rcv,<br>
+ =A0 =A0 =A0 .release_cb =A0 =A0 =A0 =A0 =A0 =A0 =3D tcp_release_cb,<br>
=A0 =A0 =A0 =A0 .hash =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D tcp_v6_hash,<=
br>
=A0 =A0 =A0 =A0 .unhash =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_unhash,<br=
>
=A0 =A0 =A0 =A0 .get_port =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_csk_get_port=
,<br>
<br>
<br>
</blockquote></div><br></div></div>

--f46d0447963124892604c492dd09--

--===============4649581658320573006==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Codel mailing list
Codel@lists.bufferbloat.net
https://lists.bufferbloat.net/listinfo/codel

--===============4649581658320573006==--
