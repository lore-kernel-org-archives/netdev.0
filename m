From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v3 net-next] tcp: Change txhash on every SYN and RTO retransmit
Date: Tue, 27 Sep 2016 17:18:51 -0700
Message-ID: <CAK6E8=dDXd9PFA=AojMOsTOXTm_KkczB2_4G3vPuQLC2Ni5QsQ@mail.gmail.com>
References: <20160927233123.2447232-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:35853 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756100AbcI1ATe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 20:19:34 -0400
Received: by mail-it0-f42.google.com with SMTP id u134so58019882itb.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 17:19:33 -0700 (PDT)
In-Reply-To: <20160927233123.2447232-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 4:31 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>
> The current code changes txhash (flowlables) on every retransmitted
> SYN/ACK, but only after the 2nd retransmitted SYN and only after
> tcp_retries1 RTO retransmits.
>
> With this patch:
> 1) txhash is changed with every SYN retransmits
> 2) adds the option for the txhash to be changed before tcp_retries1
>    RTO retransmits. A new sysctl tcp_rto_txhash_prob represents the
>    probability that txhash will be changed. A value of 0 maintains
>    previous behavior and a value of 100 will always change it.
>
> The result is that we can start re-routing around failed (or very
> congested paths) as soon as possible. Otherwise application health
> checks may fail and the connection may be terminated before we start
> to change txhash.
>
> v3: Removed text saying default value of sysctl is 0 (it is 100)
> v2: Added sysctl documentation and cleaned code
>
> Tested with packetdrill tests
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
> ---
>  Documentation/networking/ip-sysctl.txt | 11 +++++++++++
>  include/net/tcp.h                      |  1 +
>  net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
>  net/ipv4/tcp_input.c                   |  2 ++
>  net/ipv4/tcp_timer.c                   |  4 ++++
>  5 files changed, 28 insertions(+)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 3db8c67..0e7f9ac 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -472,6 +472,17 @@ tcp_max_reordering - INTEGER
>         if paths are using per packet load balancing (like bonding rr mode)
>         Default: 300
>
> +tcp_rto_txhash_prob - INTEGER
> +       Probability [0 to 100] that we will recalculate txhash when a
> +       packet is resent due to an RTO and the RTO for this packet has
> +       fired less than tcp_retries1 times. It is always recalculated
> +       after tcp_retries_times.
> +
> +       Setting it to 100 helps re-route around failed (or very congested
> +       paths) as soon as possible. Otherwise application health checks may
> +       fail and the connection may be terminated before the txhash has
> +       a chance to change.
> +
>  tcp_retrans_collapse - BOOLEAN
>         Bug-to-bug compatibility with some broken printers.
>         On retransmit try to send bigger packets to work around bugs in
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index f83b7f2..406d474 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -271,6 +271,7 @@ extern int sysctl_tcp_autocorking;
>  extern int sysctl_tcp_invalid_ratelimit;
>  extern int sysctl_tcp_pacing_ss_ratio;
>  extern int sysctl_tcp_pacing_ca_ratio;
> +extern int sysctl_tcp_rto_txhash_prob;
>
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 1cb67de..0b185a1 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -28,6 +28,7 @@
>  static int zero;
>  static int one = 1;
>  static int four = 4;
> +static int hundred = 100;
>  static int thousand = 1000;
>  static int gso_max_segs = GSO_MAX_SEGS;
>  static int tcp_retr1_max = 255;
> @@ -624,6 +625,15 @@ static struct ctl_table ipv4_table[] = {
>                 .proc_handler   = proc_dointvec_ms_jiffies,
>         },
>         {
> +               .procname       = "tcp_rto_txhash_prob",
> +               .data           = &sysctl_tcp_rto_txhash_prob,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_dointvec_minmax,
> +               .extra1         = &zero,
> +               .extra2         = &hundred,
> +       },
> +       {
>                 .procname       = "icmp_msgs_per_sec",
>                 .data           = &sysctl_icmp_msgs_per_sec,
>                 .maxlen         = sizeof(int),
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 8c6ad2d..2fea29d 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -101,6 +101,8 @@ int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
>  int sysctl_tcp_early_retrans __read_mostly = 3;
>  int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
>
> +int sysctl_tcp_rto_txhash_prob __read_mostly = 100;
> +
>  #define FLAG_DATA              0x01 /* Incoming frame contained data.          */
>  #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was a window update.       */
>  #define FLAG_DATA_ACKED                0x04 /* This ACK acknowledged new data.         */
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index f712b41..8bdb215 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -192,6 +192,8 @@ static int tcp_write_timeout(struct sock *sk)
>                         if (tp->syn_data && icsk->icsk_retransmits == 1)
>                                 NET_INC_STATS(sock_net(sk),
>                                               LINUX_MIB_TCPFASTOPENACTIVEFAIL);
> +               } else if (!tp->syn_data && !tp->syn_fastopen) {
The TFO check is not needed if it's to avoid re-routing SYN-data
packet, because TFO always retries with a pure SYN to avoid middle-box
issues. And it would benefit TFO by re-routing these SYN retries too.

> +                       sk_rethink_txhash(sk);
>                 }
>                 retry_until = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_syn_retries;
>                 syn_set = true;
> @@ -213,6 +215,8 @@ static int tcp_write_timeout(struct sock *sk)
>                         tcp_mtu_probing(icsk, sk);
>
>                         dst_negative_advice(sk);
> +               } else if (prandom_u32_max(100) < sysctl_tcp_rto_txhash_prob) {
The sysctl is not really needed but that's just my opinion.

> +                       sk_rethink_txhash(sk);
>                 }
>
>                 retry_until = net->ipv4.sysctl_tcp_retries2;
> --
> 2.9.3
>
