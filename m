From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: TCP_NOTSENT_LOWAT socket option
Date: Mon, 20 Jan 2014 17:45:49 +0100
Message-ID: <CAKgNAkhTSs-GXPjenoPWx2ndZAZOcq0k-q+V5WHqiJLNba=0NA@mail.gmail.com>
References: <1374521803.4990.38.camel@edumazet-glaptop>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:54735 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973AbaATQqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 11:46:10 -0500
Received: by mail-pb0-f53.google.com with SMTP id md12so2197695pbc.12
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 08:46:09 -0800 (PST)
In-Reply-To: <1374521803.4990.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, Jul 22, 2013 at 9:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Idea of this patch is to add optional limitation of number of
> unsent bytes in TCP sockets, to reduce usage of kernel memory.
>
> TCP receiver might announce a big window, and TCP sender autotuning
> might allow a large amount of bytes in write queue, but this has little
> performance impact if a large part of this buffering is wasted :
>
> Write queue needs to be large only to deal with large BDP, not
> necessarily to cope with scheduling delays (incoming ACKS make room
> for the application to queue more bytes)
>
> For most workloads, using a value of 128 KB or less is OK to give
> applications enough time to react to POLLOUT events in time
> (or being awaken in a blocking sendmsg())
>
> This patch adds two ways to set the limit :
> 1) Per socket option TCP_NOTSENT_LOWAT
>
> 2) A sysctl (/proc/sys/net/ipv4/tcp_notsent_lowat) for sockets
> not using TCP_NOTSENT_LOWAT socket option (or setting a zero value)
> Default value being UINT_MAX (0xFFFFFFFF), meaning this has no effect.
>
>
> This changes poll()/select()/epoll() to report POLLOUT
> only if number of unsent bytes is below tp->nosent_lowat
>
> Note this might increase number of sendmsg() calls when using non
> blocking sockets, and increase number of context switches for
> blocking sockets.

Would you be willing to write a patch to the tcp(7) man page [1] that
describes the user-space API aspects of TCP_NOTSENT_LOWAT /
/proc/sys/net/ipv4/tcp_notsent_lowat and their effect on
poll()/select()? If the *roff markup is too much of a hassle, I'd be
happy enough to get some plain text that I'll then integrate into the
man page.

Cheers,

Michael




[1] https://www.kernel.org/doc/man-pages/download.html

> Tested:
>
> netperf sessions, and watching /proc/net/protocols "memory" column for TCP
>
> Even in the absence of shallow queues, we get a benefit.
>
> With 200 concurrent netperf -t TCP_STREAM sessions, amount of kernel memory
> used by TCP buffers shrinks by ~55 % (20567 pages instead of 45458)
>
> lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# (super_netperf 200 -t TCP_STREAM -H remote -l 90 &); sleep 60 ; grep TCP /proc/net/protocols
> TCPv6     1880      2   45458   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1696    508   45458   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
>
> lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# (super_netperf 200 -t TCP_STREAM -H remote -l 90 &); sleep 60 ; grep TCP /proc/net/protocols
> TCPv6     1880      2   20567   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1696    508   20567   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
>
> Using 128KB has no bad effect on the throughput of a single flow, although
> there is an increase of cpu time as sendmsg() calls trigger more
> context switches. A bonus is that we hold socket lock for a shorter amount
> of time and should improve latencies.
>
> lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat -e context-switches ./netperf -H lpq84 -t omni -l 20 -Cc
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84 () port 0 AF_INET
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 2097152     6000000     16384  20.00   16509.68   10^6bits/s  3.05  S      4.50   S      0.363   0.536   usec/KB
>
>  Performance counter stats for './netperf -H lpq84 -t omni -l 20 -Cc':
>
>             30,141 context-switches
>
>       20.006308407 seconds time elapsed
>
> lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat -e context-switches ./netperf -H lpq84 -t omni -l 20 -Cc
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84 () port 0 AF_INET
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 1911888     6000000     16384  20.00   17412.51   10^6bits/s  3.94  S      4.39   S      0.444   0.496   usec/KB
>
>  Performance counter stats for './netperf -H lpq84 -t omni -l 20 -Cc':
>
>            284,669 context-switches
>
>       20.005294656 seconds time elapsed
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
> v2: title/changelog fix (TCP_NOSENT_LOWAT -> TCP_NOTSENT_LOWAT)
>
>  Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
>  include/linux/tcp.h                    |    1 +
>  include/net/sock.h                     |   15 ++++++++++-----
>  include/net/tcp.h                      |   14 ++++++++++++++
>  include/uapi/linux/tcp.h               |    1 +
>  net/ipv4/sysctl_net_ipv4.c             |    7 +++++++
>  net/ipv4/tcp.c                         |   12 ++++++++++--
>  net/ipv4/tcp_ipv4.c                    |    1 +
>  net/ipv4/tcp_output.c                  |    3 +++
>  net/ipv6/tcp_ipv6.c                    |    1 +
>  10 files changed, 61 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 1074290..53cea9b 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -516,6 +516,19 @@ tcp_wmem - vector of 3 INTEGERs: min, default, max
>         this value is ignored.
>         Default: between 64K and 4MB, depending on RAM size.
>
> +tcp_notsent_lowat - UNSIGNED INTEGER
> +       A TCP socket can control the amount of unsent bytes in its write queue,
> +       thanks to TCP_NOTSENT_LOWAT socket option. poll()/select()/epoll()
> +       reports POLLOUT events if the amount of unsent bytes is below a per
> +       socket value, and if the write queue is not full. sendmsg() will
> +       also not add new buffers if the limit is hit.
> +
> +       This global variable controls the amount of unsent data for
> +       sockets not using TCP_NOTSENT_LOWAT. For these sockets, a change
> +       to the global variable has immediate effect.
> +
> +       Default: UINT_MAX (0xFFFFFFFF)
> +
>  tcp_workaround_signed_windows - BOOLEAN
>         If set, assume no receipt of a window scaling option means the
>         remote TCP is broken and treats the window as a signed quantity.
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 472120b..9640803 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -238,6 +238,7 @@ struct tcp_sock {
>
>         u32     rcv_wnd;        /* Current receiver window              */
>         u32     write_seq;      /* Tail(+1) of data held in tcp send buffer */
> +       u32     notsent_lowat;  /* TCP_NOTSENT_LOWAT */
>         u32     pushed_seq;     /* Last pushed seq, required to talk to windows */
>         u32     lost_out;       /* Lost packets                 */
>         u32     sacked_out;     /* SACK'd packets                       */
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 95a5a2c..7be0b22 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -746,11 +746,6 @@ static inline int sk_stream_wspace(const struct sock *sk)
>
>  extern void sk_stream_write_space(struct sock *sk);
>
> -static inline bool sk_stream_memory_free(const struct sock *sk)
> -{
> -       return sk->sk_wmem_queued < sk->sk_sndbuf;
> -}
> -
>  /* OOB backlog add */
>  static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
>  {
> @@ -950,6 +945,7 @@ struct proto {
>         unsigned int            inuse_idx;
>  #endif
>
> +       bool                    (*stream_memory_free)(const struct sock *sk);
>         /* Memory pressure */
>         void                    (*enter_memory_pressure)(struct sock *sk);
>         atomic_long_t           *memory_allocated;      /* Current allocated memory. */
> @@ -1089,6 +1085,15 @@ static inline struct cg_proto *parent_cg_proto(struct proto *proto,
>  #endif
>
>
> +static inline bool sk_stream_memory_free(const struct sock *sk)
> +{
> +       if (sk->sk_wmem_queued >= sk->sk_sndbuf)
> +               return false;
> +
> +       return sk->sk_prot->stream_memory_free ?
> +               sk->sk_prot->stream_memory_free(sk) : true;
> +}
> +
>  static inline bool sk_has_memory_pressure(const struct sock *sk)
>  {
>         return sk->sk_prot->memory_pressure != NULL;
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index d198005..ff58714 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -284,6 +284,7 @@ extern int sysctl_tcp_thin_dupack;
>  extern int sysctl_tcp_early_retrans;
>  extern int sysctl_tcp_limit_output_bytes;
>  extern int sysctl_tcp_challenge_ack_limit;
> +extern unsigned int sysctl_tcp_notsent_lowat;
>
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> @@ -1549,6 +1550,19 @@ extern int tcp_gro_complete(struct sk_buff *skb);
>  extern void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr,
>                                 __be32 daddr);
>
> +static inline u32 tcp_notsent_lowat(const struct tcp_sock *tp)
> +{
> +       return tp->notsent_lowat ?: sysctl_tcp_notsent_lowat;
> +}
> +
> +static inline bool tcp_stream_memory_free(const struct sock *sk)
> +{
> +       const struct tcp_sock *tp = tcp_sk(sk);
> +       u32 notsent_bytes = tp->write_seq - tp->snd_nxt;
> +
> +       return notsent_bytes < tcp_notsent_lowat(tp);
> +}
> +
>  #ifdef CONFIG_PROC_FS
>  extern int tcp4_proc_init(void);
>  extern void tcp4_proc_exit(void);
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index 8d776eb..377f1e5 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -111,6 +111,7 @@ enum {
>  #define TCP_REPAIR_OPTIONS     22
>  #define TCP_FASTOPEN           23      /* Enable FastOpen on listeners */
>  #define TCP_TIMESTAMP          24
> +#define TCP_NOTSENT_LOWAT      25      /* limit number of unsent bytes in write queue */
>
>  struct tcp_repair_opt {
>         __u32   opt_code;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index b2c123c..69ed203 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -555,6 +555,13 @@ static struct ctl_table ipv4_table[] = {
>                 .extra1         = &one,
>         },
>         {
> +               .procname       = "tcp_notsent_lowat",
> +               .data           = &sysctl_tcp_notsent_lowat,
> +               .maxlen         = sizeof(sysctl_tcp_notsent_lowat),
> +               .mode           = 0644,
> +               .proc_handler   = proc_dointvec,
> +       },
> +       {
>                 .procname       = "tcp_rmem",
>                 .data           = &sysctl_tcp_rmem,
>                 .maxlen         = sizeof(sysctl_tcp_rmem),
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 5423223..5792302 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -499,7 +499,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>                         mask |= POLLIN | POLLRDNORM;
>
>                 if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
> -                       if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
> +                       if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk) &&
> +                           tcp_stream_memory_free(sk)) {
>                                 mask |= POLLOUT | POLLWRNORM;
>                         } else {  /* send SIGIO later */
>                                 set_bit(SOCK_ASYNC_NOSPACE,
> @@ -510,7 +511,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>                                  * wspace test but before the flags are set,
>                                  * IO signal will be lost.
>                                  */
> -                               if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
> +                               if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk) &&
> +                                   tcp_stream_memory_free(sk))
>                                         mask |= POLLOUT | POLLWRNORM;
>                         }
>                 } else
> @@ -2631,6 +2633,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>                 else
>                         tp->tsoffset = val - tcp_time_stamp;
>                 break;
> +       case TCP_NOTSENT_LOWAT:
> +               tp->notsent_lowat = val;
> +               break;
>         default:
>                 err = -ENOPROTOOPT;
>                 break;
> @@ -2847,6 +2852,9 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>         case TCP_TIMESTAMP:
>                 val = tcp_time_stamp + tp->tsoffset;
>                 break;
> +       case TCP_NOTSENT_LOWAT:
> +               val = tp->notsent_lowat;
> +               break;
>         default:
>                 return -ENOPROTOOPT;
>         }
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index b74628e..8390bff 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2806,6 +2806,7 @@ struct proto tcp_prot = {
>         .unhash                 = inet_unhash,
>         .get_port               = inet_csk_get_port,
>         .enter_memory_pressure  = tcp_enter_memory_pressure,
> +       .stream_memory_free     = tcp_stream_memory_free,
>         .sockets_allocated      = &tcp_sockets_allocated,
>         .orphan_count           = &tcp_orphan_count,
>         .memory_allocated       = &tcp_memory_allocated,
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 92fde8d..884efff 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -65,6 +65,9 @@ int sysctl_tcp_base_mss __read_mostly = TCP_BASE_MSS;
>  /* By default, RFC2861 behavior.  */
>  int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
>
> +unsigned int sysctl_tcp_notsent_lowat __read_mostly = UINT_MAX;
> +EXPORT_SYMBOL(sysctl_tcp_notsent_lowat);
> +
>  static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>                            int push_one, gfp_t gfp);
>
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index f0d6363..0030cfd 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1927,6 +1927,7 @@ struct proto tcpv6_prot = {
>         .unhash                 = inet_unhash,
>         .get_port               = inet_csk_get_port,
>         .enter_memory_pressure  = tcp_enter_memory_pressure,
> +       .stream_memory_free     = tcp_stream_memory_free,
>         .sockets_allocated      = &tcp_sockets_allocated,
>         .memory_allocated       = &tcp_memory_allocated,
>         .memory_pressure        = &tcp_memory_pressure,
>
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
