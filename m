From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 2/3] net/tcp_fastopen: Add snmp counter for
 blackhole detection
Date: Thu, 20 Apr 2017 17:30:49 -0700
Message-ID: <CAK6E8=eT7J-CRwbS_mNWj7duJ00RVUKe6BmauBbu+6+X3ezEJw@mail.gmail.com>
References: <20170420214548.23666-1-tracywwnj@gmail.com> <20170420214548.23666-2-tracywwnj@gmail.com>
 <20170420214548.23666-3-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:32864 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948188AbdDUAbb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 20:31:31 -0400
Received: by mail-io0-f176.google.com with SMTP id k87so94389332ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 17:31:30 -0700 (PDT)
In-Reply-To: <20170420214548.23666-3-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 2:45 PM, Wei Wang <weiwan@google.com> wrote:
> From: Wei Wang <weiwan@google.com>
>
> This counter records the number of times the firewall blackhole issue is
> detected and active TFO is disabled.
>
> Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  include/net/tcp.h         | 2 +-
>  include/uapi/linux/snmp.h | 1 +
>  net/ipv4/proc.c           | 1 +
>  net/ipv4/tcp_fastopen.c   | 5 +++--
>  net/ipv4/tcp_input.c      | 4 ++--
>  5 files changed, 8 insertions(+), 5 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c1abc2abbdcb..da28bef1d82b 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1507,7 +1507,7 @@ struct tcp_fastopen_context {
>  };
>
>  extern unsigned int sysctl_tcp_fastopen_blackhole_timeout;
> -void tcp_fastopen_active_disable(void);
> +void tcp_fastopen_active_disable(struct sock *sk);
>  bool tcp_fastopen_active_should_disable(struct sock *sk);
>  void tcp_fastopen_active_disable_ofo_check(struct sock *sk);
>  void tcp_fastopen_active_timeout_reset(void);
> diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
> index cec0e171d20c..95cffcb21dfd 100644
> --- a/include/uapi/linux/snmp.h
> +++ b/include/uapi/linux/snmp.h
> @@ -259,6 +259,7 @@ enum
>         LINUX_MIB_TCPFASTOPENPASSIVEFAIL,       /* TCPFastOpenPassiveFail */
>         LINUX_MIB_TCPFASTOPENLISTENOVERFLOW,    /* TCPFastOpenListenOverflow */
>         LINUX_MIB_TCPFASTOPENCOOKIEREQD,        /* TCPFastOpenCookieReqd */
> +       LINUX_MIB_TCPFASTOPENBLACKHOLE,         /* TCPFastOpenBlackholeDetect */
/* TCPFastOpenBlackhole */

>         LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
>         LINUX_MIB_BUSYPOLLRXPACKETS,            /* BusyPollRxPackets */
>         LINUX_MIB_TCPAUTOCORKING,               /* TCPAutoCorking */
> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
> index 4ccbf464d1ac..fa44e752a9a3 100644
> --- a/net/ipv4/proc.c
> +++ b/net/ipv4/proc.c
> @@ -281,6 +281,7 @@ static const struct snmp_mib snmp4_net_list[] = {
>         SNMP_MIB_ITEM("TCPFastOpenPassiveFail", LINUX_MIB_TCPFASTOPENPASSIVEFAIL),
>         SNMP_MIB_ITEM("TCPFastOpenListenOverflow", LINUX_MIB_TCPFASTOPENLISTENOVERFLOW),
>         SNMP_MIB_ITEM("TCPFastOpenCookieReqd", LINUX_MIB_TCPFASTOPENCOOKIEREQD),
> +       SNMP_MIB_ITEM("TCPFastOpenBlackhole", LINUX_MIB_TCPFASTOPENBLACKHOLE),
>         SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
>         SNMP_MIB_ITEM("BusyPollRxPackets", LINUX_MIB_BUSYPOLLRXPACKETS),
>         SNMP_MIB_ITEM("TCPAutoCorking", LINUX_MIB_TCPAUTOCORKING),
> diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> index ff2d30ffc6f3..4af82b914dd4 100644
> --- a/net/ipv4/tcp_fastopen.c
> +++ b/net/ipv4/tcp_fastopen.c
> @@ -410,10 +410,11 @@ static unsigned long tfo_active_disable_stamp __read_mostly;
>  /* Disable active TFO and record current jiffies and
>   * tfo_active_disable_times
>   */
> -void tcp_fastopen_active_disable(void)
> +void tcp_fastopen_active_disable(struct sock *sk)
>  {
>         atomic_inc(&tfo_active_disable_times);
>         tfo_active_disable_stamp = jiffies;
> +       NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPFASTOPENBLACKHOLE);
>  }
>
>  /* Reset tfo_active_disable_times to 0 */
> @@ -469,7 +470,7 @@ void tcp_fastopen_active_disable_ofo_check(struct sock *sk)
>                 if (p && !rb_next(p)) {
>                         skb = rb_entry(p, struct sk_buff, rbnode);
>                         if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) {
> -                               tcp_fastopen_active_disable();
> +                               tcp_fastopen_active_disable(sk);
>                                 return;
>                         }
>                 }
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 9f342a67dc74..5af2f04f8859 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5307,7 +5307,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>                          */
>                         if (tp->syn_fastopen && !tp->data_segs_in &&
>                             sk->sk_state == TCP_ESTABLISHED)
> -                               tcp_fastopen_active_disable();
> +                               tcp_fastopen_active_disable(sk);
>                         tcp_send_challenge_ack(sk, skb);
>                 }
>                 goto discard;
> @@ -6061,7 +6061,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
>                     after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)) {
>                         /* Receive out of order FIN after close() */
>                         if (tp->syn_fastopen && th->fin)
> -                               tcp_fastopen_active_disable();
> +                               tcp_fastopen_active_disable(sk);
>                         tcp_done(sk);
>                         NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
>                         return 1;
> --
> 2.12.2.816.g2cccc81164-goog
>
