From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Mon, 5 May 2014 16:18:05 -0700
Message-ID: <CAK6E8=cQ37-O=z6oxwhNZ+rog2VrLZQvjKW4sq+E97Yz-VNorQ@mail.gmail.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org> <1399328773-6531-9-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	tom.zanussi@linux.intel.com, Andi Kleen <ak@linux.intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:39585 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756962AbaEEXSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 19:18:45 -0400
Received: by mail-ie0-f173.google.com with SMTP id rp18so8950352iec.18
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 16:18:45 -0700 (PDT)
In-Reply-To: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 5, 2014 at 3:25 PM, Andi Kleen <andi@firstfloor.org> wrote:
> From: Andi Kleen <ak@linux.intel.com>
>
> This is all the code that saves connection information
> between different sockets. Not really essential for
> small systems.
>
> Saves about 5.5k text
>
>    text    data     bss     dec     hex filename
>  492952   19571   13480  526003   806b3 net/built-in.o-with-metrics
>  487675   19275   13480  520430   7f0ee net/built-in.o-without-metrics
>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  include/net/tcp.h          | 25 +++++++++++++++++++++++++
>  net/ipv4/Kconfig           |  6 ++++++
>  net/ipv4/Makefile          |  3 ++-
>  net/ipv4/sysctl_net_ipv4.c |  2 ++
>  4 files changed, 35 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 87d8774..d741d2f 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -419,14 +419,29 @@ int tcp_child_process(struct sock *parent, struct sock *child,
>                       struct sk_buff *skb);
>  void tcp_enter_loss(struct sock *sk, int how);
>  void tcp_clear_retrans(struct tcp_sock *tp);
> +#ifdef CONFIG_TCP_METRICS
>  void tcp_update_metrics(struct sock *sk);
>  void tcp_init_metrics(struct sock *sk);
>  void tcp_metrics_init(void);
> +
>  bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst,
>                         bool paws_check);
>  bool tcp_remember_stamp(struct sock *sk);
>  bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw);
>  void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst);
> +#else
> +static inline void tcp_update_metrics(struct sock *sk) {}
> +static inline void tcp_init_metrics(struct sock *sk) {}
> +static inline void tcp_metrics_init(void) {}
> +static inline bool tcp_peer_is_proven(struct request_sock *req,
> +                                     struct dst_entry *dst,
> +                                     bool paws_check) { return false; }
> +static inline bool tcp_remember_stamp(struct sock *sk) { return false; }
> +static inline bool
> +tcp_tw_remember_stamp(struct inet_timewait_sock *tw) { return false; }
> +static inline void
> +tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst) {}
> +#endif
>  void tcp_disable_fack(struct tcp_sock *tp);
>  void tcp_close(struct sock *sk, long timeout);
>  void tcp_init_sock(struct sock *sk);
> @@ -1296,11 +1311,21 @@ int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
>                      const struct tcp_md5sig_key *key);
>
>  /* From tcp_fastopen.c */
> +#ifdef CONFIG_TCP_METRICS
>  void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
>                             struct tcp_fastopen_cookie *cookie, int *syn_loss,
>                             unsigned long *last_syn_loss);
>  void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
>                             struct tcp_fastopen_cookie *cookie, bool syn_lost);
> +#else
> +static inline void
> +tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
> +                      struct tcp_fastopen_cookie *cookie, int *syn_loss,
> +                      unsigned long *last_syn_loss) {}
> +static inline void
> +tcp_fastopen_cache_set(struct sock *sk, u16 mss,
> +                      struct tcp_fastopen_cookie *cookie, bool syn_lost) {}
> +#endif
>  struct tcp_fastopen_request {
>         /* Fast Open cookie. Size 0 means a cookie request */
>         struct tcp_fastopen_cookie      cookie;
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 6146b1b..db2dada 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -264,6 +264,12 @@ config IP_PIMSM_V2
>           gated-5). This routing protocol is not used widely, so say N unless
>           you want to play with it.
>
> +config TCP_METRICS
> +       bool "Report TCP metrics over netlink"
> +       ---help---
> +           Enable support in TCP to save host information between different
> +          connections.
Please add that "Certain TCP features such as active TCP Fast Open
depends on this."

> +
>  config SYN_COOKIES
>         bool "IP: TCP syncookie support"
>         ---help---
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index 756855c..8b17b83 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -7,7 +7,7 @@ obj-y     := route.o inetpeer.o protocol.o \
>              ip_output.o ip_sockglue.o inet_hashtables.o \
>              inet_timewait_sock.o inet_connection_sock.o \
>              tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
> -            tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
> +            tcp_minisocks.o tcp_cong.o tcp_fastopen.o \
>              tcp_offload.o datagram.o raw.o udp.o udplite.o \
>              udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
>              fib_frontend.o fib_semantics.o fib_trie.o \
> @@ -17,6 +17,7 @@ obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
>  obj-$(CONFIG_IP_PING) += ping.o
>  obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
>  obj-$(CONFIG_PROC_FS) += proc.o
> +obj-$(CONFIG_TCP_METRICS) += tcp_metrics.o
>  obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
>  obj-$(CONFIG_IP_MROUTE) += ipmr.o
>  obj-$(CONFIG_NET_IPIP) += ipip.o
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 44eba05..2110d2e 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -573,6 +573,7 @@ static struct ctl_table ipv4_table[] = {
>                 .mode           = 0644,
>                 .proc_handler   = proc_dointvec
>         },
> +#ifdef CONFIG_TCP_METRICS
>         {
>                 .procname       = "tcp_no_metrics_save",
>                 .data           = &sysctl_tcp_nometrics_save,
> @@ -580,6 +581,7 @@ static struct ctl_table ipv4_table[] = {
>                 .mode           = 0644,
>                 .proc_handler   = proc_dointvec,
>         },
> +#endif
>         {
>                 .procname       = "tcp_moderate_rcvbuf",
>                 .data           = &sysctl_tcp_moderate_rcvbuf,
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
