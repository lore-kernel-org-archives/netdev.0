From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 1/3] net/tcp_fastopen: Disable active side TFO in
 certain scenarios
Date: Thu, 20 Apr 2017 17:29:02 -0700
Message-ID: <CAK6E8=dXAT==Fxbmqmg8qvUESvRrvnQme2bMx6qmYmPTVjsoRA@mail.gmail.com>
References: <20170420214548.23666-1-tracywwnj@gmail.com> <20170420214548.23666-2-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36540 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948103AbdDUA3o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 20:29:44 -0400
Received: by mail-io0-f173.google.com with SMTP id o22so103294616iod.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 17:29:44 -0700 (PDT)
In-Reply-To: <20170420214548.23666-2-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 2:45 PM, Wei Wang <weiwan@google.com> wrote:
> From: Wei Wang <weiwan@google.com>
>
> Middlebox firewall issues can potentially cause server's data being
> blackholed after a successful 3WHS using TFO. Following are the related
> reports from Apple:
> https://www.nanog.org/sites/default/files/Paasch_Network_Support.pdf
> Slide 31 identifies an issue where the client ACK to the server's data
> sent during a TFO'd handshake is dropped.
> C ---> syn-data ---> S
> C <--- syn/ack ----- S
> C (accept & write)
> C <---- data ------- S
> C ----- ACK -> X     S
>                 [retry and timeout]
>
> https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf
> Slide 5 shows a similar situation that the server's data gets dropped
> after 3WHS.
> C ---- syn-data ---> S
> C <--- syn/ack ----- S
> C ---- ack --------> S
> S (accept & write)
> C?  X <- data ------ S
>                 [retry and timeout]
>
> This is the worst failure b/c the client can not detect such behavior to
> mitigate the situation (such as disabling TFO). Failing to proceed, the
> application (e.g., SSL library) may simply timeout and retry with TFO
> again, and the process repeats indefinitely.
>
> The proposed solution is to disable active TFO globally under the
> following circumstances:
> 1. client side TFO socket detects out of order FIN
> 2. client side TFO socket receives out of order RST
>
> We disable active side TFO globally for 1hr at first. Then if it
> happens again, we disable it for 2h, then 4h, 8h, ...
> And we reset the timeout to 1hr if a client side TFO sockets not opened
> on loopback has successfully received data segs from server.
> And we examine this condition during close().
>
> The rational behind it is that when such firewall issue happens,
> application running on the client should eventually close the socket as
> it is not able to get the data it is expecting. Or application running
> on the server should close the socket as it is not able to receive any
> response from client.
> In both cases, out of order FIN or RST will get received on the client
> given that the firewall will not block them as no data are in those
> frames.
> And we want to disable active TFO globally as it helps if the middle box
> is very close to the client and most of the connections are likely to
> fail.
>
> Also, add a debug sysctl:
>   tcp_fastopen_blackhole_detect_timeout_sec:
>     the initial timeout to use when firewall blackhole issue happens.
>     This can be set and read.
>     When setting it to 0, it means to disable the active disable logic.
>
> Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  Documentation/networking/ip-sysctl.txt |   8 +++
>  include/linux/tcp.h                    |   1 +
>  include/net/tcp.h                      |   6 ++
>  net/ipv4/sysctl_net_ipv4.c             |  21 +++++++
>  net/ipv4/tcp.c                         |   1 +
>  net/ipv4/tcp_fastopen.c                | 101 +++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_input.c                   |  23 ++++++--
>  net/ipv4/tcp_ipv4.c                    |   3 +
>  8 files changed, 160 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index b1c6500e7a8d..974ab47ae53a 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -602,6 +602,14 @@ tcp_fastopen - INTEGER
>         Note that that additional client or server features are only
>         effective if the basic support (0x1 and 0x2) are enabled respectively.
>
> +tcp_fastopen_blackhole_timeout_sec - INTEGER
> +       Initial time period in second to disable Fastopen on active TCP sockets
> +       when a TFO firewall blackhole issue happens.
> +       This time period will grow exponentially when more blackhole issues
> +       get detected right after Fastopen is re-enabled and will reset to
> +       initial value when the blackhole issue goes away.
> +       By default, it is set to 1hr.
> +
>  tcp_syn_retries - INTEGER
>         Number of times initial SYNs for an active TCP connection attempt
>         will be retransmitted. Should not be higher than 127. Default value
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index cfc2d9506ce8..cbe5b602a2d3 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -233,6 +233,7 @@ struct tcp_sock {
>         u8      syn_data:1,     /* SYN includes data */
>                 syn_fastopen:1, /* SYN includes Fast Open option */
>                 syn_fastopen_exp:1,/* SYN includes Fast Open exp. option */
> +               syn_fastopen_ch:1, /* Active TFO re-enabling probe */
>                 syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
>                 save_syn:1,     /* Save headers of SYN packet */
>                 is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index cc6ae0a95201..c1abc2abbdcb 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1506,6 +1506,12 @@ struct tcp_fastopen_context {
>         struct rcu_head         rcu;
>  };
>
> +extern unsigned int sysctl_tcp_fastopen_blackhole_timeout;
> +void tcp_fastopen_active_disable(void);
> +bool tcp_fastopen_active_should_disable(struct sock *sk);
> +void tcp_fastopen_active_disable_ofo_check(struct sock *sk);
> +void tcp_fastopen_active_timeout_reset(void);
> +
>  /* Latencies incurred by various limits for a sender. They are
>   * chronograph-like stats that are mutually exclusive.
>   */
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 6fb25693c00b..52fa0a6b78ff 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -347,6 +347,19 @@ static int proc_udp_early_demux(struct ctl_table *table, int write,
>         return ret;
>  }
>
> +static int proc_tfo_blackhole_detect_timeout(struct ctl_table *table,
> +                                            int write,
> +                                            void __user *buffer,
> +                                            size_t *lenp, loff_t *ppos)
> +{
> +       int ret;
> +
> +       ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
> +       if (write && ret == 0)
> +               tcp_fastopen_active_timeout_reset();
> +       return ret;
> +}
> +
>  static struct ctl_table ipv4_table[] = {
>         {
>                 .procname       = "tcp_timestamps",
> @@ -397,6 +410,14 @@ static struct ctl_table ipv4_table[] = {
>                 .proc_handler   = proc_tcp_fastopen_key,
>         },
>         {
> +               .procname       = "tcp_fastopen_blackhole_timeout_sec",
> +               .data           = &sysctl_tcp_fastopen_blackhole_timeout,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_tfo_blackhole_detect_timeout,
> +               .extra1         = &zero,
> +       },
> +       {
>                 .procname       = "tcp_abort_on_overflow",
>                 .data           = &sysctl_tcp_abort_on_overflow,
>                 .maxlen         = sizeof(int),
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 04843ae77b9e..efc976ae66ae 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2296,6 +2296,7 @@ int tcp_disconnect(struct sock *sk, int flags)
>         tcp_clear_xmit_timers(sk);
>         __skb_queue_purge(&sk->sk_receive_queue);
>         tcp_write_queue_purge(sk);
> +       tcp_fastopen_active_disable_ofo_check(sk);
>         skb_rbtree_purge(&tp->out_of_order_queue);
>
>         inet->inet_dport = 0;
> diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> index 8ea4e9787f82..ff2d30ffc6f3 100644
> --- a/net/ipv4/tcp_fastopen.c
> +++ b/net/ipv4/tcp_fastopen.c
> @@ -341,6 +341,13 @@ bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
>                 cookie->len = -1;
>                 return false;
>         }
> +
> +       /* Firewall blackhole issue check */
> +       if (tcp_fastopen_active_should_disable(sk)) {
> +               cookie->len = -1;
> +               return false;
> +       }
> +
>         if (sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) {
>                 cookie->len = -1;
>                 return true;
> @@ -380,3 +387,97 @@ bool tcp_fastopen_defer_connect(struct sock *sk, int *err)
>         return false;
>  }
>  EXPORT_SYMBOL(tcp_fastopen_defer_connect);
> +
> +/*
> + * The following code block is to deal with middle box issues with TFO:
> + * Middlebox firewall issues can potentially cause server's data being
> + * blackholed after a successful 3WHS using TFO.
> + * The proposed solution is to disable active TFO globally under the
> + * following circumstances:
> + *   1. client side TFO socket receives out of order FIN
> + *   2. client side TFO socket receives out of order RST
> + * We disable active side TFO globally for 1hr at first. Then if it
> + * happens again, we disable it for 2h, then 4h, 8h, ...
> + * And we reset the timeout back to 1hr when we see a successful active
> + * TFO connection with data exchanges.
> + */
> +
> +/* Default to 1hr */
> +unsigned int sysctl_tcp_fastopen_blackhole_timeout __read_mostly = 60 * 60;
> +static atomic_t tfo_active_disable_times __read_mostly = ATOMIC_INIT(0);
> +static unsigned long tfo_active_disable_stamp __read_mostly;
> +
> +/* Disable active TFO and record current jiffies and
> + * tfo_active_disable_times
> + */
> +void tcp_fastopen_active_disable(void)
> +{
> +       atomic_inc(&tfo_active_disable_times);
> +       tfo_active_disable_stamp = jiffies;
> +}
> +
> +/* Reset tfo_active_disable_times to 0 */
> +void tcp_fastopen_active_timeout_reset(void)
> +{
> +       atomic_set(&tfo_active_disable_times, 0);
> +}
> +
> +/* Calculate timeout for tfo active disable
> + * Return true if we are still in the active TFO disable period
> + * Return false if timeout already expired and we should use active TFO
> + */
> +bool tcp_fastopen_active_should_disable(struct sock *sk)
> +{
> +       int tfo_da_times = atomic_read(&tfo_active_disable_times);
> +       int multiplier;
> +       unsigned long timeout;
> +
> +       if (!tfo_da_times)
> +               return false;
> +
> +       /* Limit timout to max: 2^6 * initial timeout */
> +       multiplier = 1 << min(tfo_da_times - 1, 6);
> +       timeout = multiplier * sysctl_tcp_fastopen_blackhole_timeout * HZ;
> +       if (time_before(jiffies, tfo_active_disable_stamp + timeout))
> +               return true;
> +
> +       /* Mark check bit so we can check for successful active TFO
> +        * condition and reset tfo_active_disable_times
> +        */
> +       tcp_sk(sk)->syn_fastopen_ch = 1;
> +       return false;
> +}
> +
> +/* Disable active TFO if FIN is the only packet in the ofo queue
> + * and no data is received.
> + * Also check if we can reset tfo_active_disable_times if data is
> + * received successfully on a marked active TFO sockets opened on
> + * a non-loopback interface
> + */
> +void tcp_fastopen_active_disable_ofo_check(struct sock *sk)
> +{
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       struct rb_node *p;
> +       struct sk_buff *skb;
> +       struct dst_entry *dst;
> +
> +       if (!tp->syn_fastopen)
> +               return;
> +
> +       if (!tp->data_segs_in) {
> +               p = rb_first(&tp->out_of_order_queue);
> +               if (p && !rb_next(p)) {
> +                       skb = rb_entry(p, struct sk_buff, rbnode);
> +                       if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) {
> +                               tcp_fastopen_active_disable();
> +                               return;
> +                       }
> +               }
> +       } else if (tp->syn_fastopen_ch &&
> +                  atomic_read(&tfo_active_disable_times)) {
> +               dst = sk_dst_get(sk);
> +               if (!(dst && dst->dev && (dst->dev->flags & IFF_LOOPBACK)))
> +                       tcp_fastopen_active_timeout_reset();
> +               dst_release(dst);
> +       }
> +}
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 341f021f02a2..9f342a67dc74 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5300,8 +5300,16 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>
>                 if (rst_seq_match)
>                         tcp_reset(sk);
> -               else
> +               else {
> +                       /* Disable TFO if RST is out-of-order
> +                        * and no data has been received
> +                        * for current active TFO socket
> +                        */
> +                       if (tp->syn_fastopen && !tp->data_segs_in &&
> +                           sk->sk_state == TCP_ESTABLISHED)
> +                               tcp_fastopen_active_disable();
>                         tcp_send_challenge_ack(sk, skb);
> +               }
>                 goto discard;
>         }
>
> @@ -6044,9 +6052,16 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
>                         break;
>                 }
>
> -               if (tp->linger2 < 0 ||
> -                   (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
> -                    after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt))) {
> +               if (tp->linger2 < 0) {
> +                       tcp_done(sk);
> +                       NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
> +                       return 1;
> +               }
> +               if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
> +                   after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)) {
> +                       /* Receive out of order FIN after close() */
> +                       if (tp->syn_fastopen && th->fin)
> +                               tcp_fastopen_active_disable();
>                         tcp_done(sk);
>                         NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
>                         return 1;
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 20cbd2f07f28..cbbafe546c0f 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1855,6 +1855,9 @@ void tcp_v4_destroy_sock(struct sock *sk)
>         /* Cleanup up the write buffer. */
>         tcp_write_queue_purge(sk);
>
> +       /* Check if we want to disable active TFO */
> +       tcp_fastopen_active_disable_ofo_check(sk);
> +
>         /* Cleans up our, hopefully empty, out_of_order_queue. */
>         skb_rbtree_purge(&tp->out_of_order_queue);
>
> --
> 2.12.2.816.g2cccc81164-goog
>
