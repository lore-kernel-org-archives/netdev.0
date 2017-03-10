From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Thu, 9 Mar 2017 19:42:53 -0800
Message-ID: <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35806 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdCJDmz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 22:42:55 -0500
Received: by mail-qk0-f196.google.com with SMTP id o135so24576007qke.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 19:42:54 -0800 (PST)
In-Reply-To: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 9, 2017 at 7:31 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
> Certain system process significant unconnected UDP workload.
> It would be preferrable to disable UDP early demux for those systems
> and enable it for TCP only.
>
Presumably you want this for performance reasons. Can you provide some
before and after numbers?

> v1->v2: Change function pointer instead of adding conditional as
> suggested by Stephen.
>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> ---
>  include/net/netns/ipv4.h   |  2 ++
>  include/net/tcp.h          |  2 ++
>  include/net/udp.h          |  2 ++
>  net/ipv4/af_inet.c         | 22 ++++++++++++++++++++--
>  net/ipv4/sysctl_net_ipv4.c | 47 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/tcp_ipv6.c        | 10 +++++++++-
>  6 files changed, 82 insertions(+), 3 deletions(-)
>
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index 0378e88..1e74da23 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -86,6 +86,8 @@ struct netns_ipv4 {
>         /* Shall we try to damage output packets if routing dev changes? */
>         int sysctl_ip_dynaddr;
>         int sysctl_ip_early_demux;
> +       int sysctl_tcp_early_demux;
> +       int sysctl_udp_early_demux;
>
>         int sysctl_fwmark_reflect;
>         int sysctl_tcp_fwmark_accept;
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 6061963..3b6446d 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1953,4 +1953,6 @@ static inline void tcp_listendrop(const struct sock *sk)
>         __NET_INC_STATS(sock_net(sk), LINUX_MIB_LISTENDROPS);
>  }
>
> +void tcp_v4_early_demux_configure(int enable);
> +void tcp_v6_early_demux_configure(int enable);
>  #endif /* _TCP_H */
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 1661791..7de31d5 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -373,4 +373,6 @@ struct udp_iter_state {
>  #if IS_ENABLED(CONFIG_IPV6)
>  void udpv6_encap_enable(void);
>  #endif
> +
> +void udp_v4_early_demux_configure(int enable);
>  #endif /* _UDP_H */
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index f750698..3e11d74 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1579,7 +1579,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
>  };
>  #endif
>
> -static const struct net_protocol tcp_protocol = {
> +static struct net_protocol tcp_protocol = {
>         .early_demux    =       tcp_v4_early_demux,
>         .handler        =       tcp_v4_rcv,
>         .err_handler    =       tcp_v4_err,
> @@ -1588,7 +1588,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
>         .icmp_strict_tag_validation = 1,
>  };
>
> -static const struct net_protocol udp_protocol = {
> +static struct net_protocol udp_protocol = {
>         .early_demux =  udp_v4_early_demux,
>         .handler =      udp_rcv,
>         .err_handler =  udp_err,
> @@ -1596,6 +1596,22 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
>         .netns_ok =     1,
>  };
>
> +void tcp_v4_early_demux_configure(int enable)
> +{
> +       if (enable)
> +               tcp_protocol.early_demux = tcp_v4_early_demux;
> +       else
> +               tcp_protocol.early_demux = NULL;
> +}
> +
> +void udp_v4_early_demux_configure(int enable)
> +{
> +       if (enable)
> +               udp_protocol.early_demux = udp_v4_early_demux;
> +       else
> +               udp_protocol.early_demux = NULL;
> +}
> +
>  static const struct net_protocol icmp_protocol = {
>         .handler =      icmp_rcv,
>         .err_handler =  icmp_err,
> @@ -1700,6 +1716,8 @@ static __net_init int inet_init_net(struct net *net)
>         net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
>         net->ipv4.sysctl_ip_dynaddr = 0;
>         net->ipv4.sysctl_ip_early_demux = 1;
> +       net->ipv4.sysctl_udp_early_demux = 1;
> +       net->ipv4.sysctl_tcp_early_demux = 1;
>
>         return 0;
>  }
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index b2fa498..c61383b 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -253,6 +253,39 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
>         return ret;
>  }
>
> +static int proc_tcp_early_demux(struct ctl_table *table, int write,
> +                               void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +       int ret = 0;
> +
> +       ret = proc_dointvec(table, write, buffer, lenp, ppos);
> +
> +       if (write && !ret) {
> +               int enabled = init_net.ipv4.sysctl_tcp_early_demux;
> +
> +               tcp_v4_early_demux_configure(enabled);
> +               tcp_v6_early_demux_configure(enabled);
> +       }
> +
> +       return ret;
> +}
> +
> +static int proc_udp_early_demux(struct ctl_table *table, int write,
> +                               void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +       int ret = 0;
> +
> +       ret = proc_dointvec(table, write, buffer, lenp, ppos);
> +
> +       if (write && !ret) {
> +               int enabled = init_net.ipv4.sysctl_udp_early_demux;
> +
> +               udp_v4_early_demux_configure(enabled);
> +       }
> +
> +       return ret;
> +}
> +
>  static struct ctl_table ipv4_table[] = {
>         {
>                 .procname       = "tcp_timestamps",
> @@ -737,6 +770,20 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
>                 .proc_handler   = proc_dointvec
>         },
>         {
> +               .procname       = "udp_early_demux",
> +               .data           = &init_net.ipv4.sysctl_udp_early_demux,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_udp_early_demux
> +       },
> +       {
> +               .procname       = "tcp_early_demux",
> +               .data           = &init_net.ipv4.sysctl_tcp_early_demux,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_tcp_early_demux
> +       },
> +       {
>                 .procname       = "ip_default_ttl",
>                 .data           = &init_net.ipv4.sysctl_ip_default_ttl,
>                 .maxlen         = sizeof(int),
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 4c60c6f..0dd761c 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1926,13 +1926,21 @@ struct proto tcpv6_prot = {
>         .diag_destroy           = tcp_abort,
>  };
>
> -static const struct inet6_protocol tcpv6_protocol = {
> +static struct inet6_protocol tcpv6_protocol = {
>         .early_demux    =       tcp_v6_early_demux,
>         .handler        =       tcp_v6_rcv,
>         .err_handler    =       tcp_v6_err,
>         .flags          =       INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
>  };
>
> +void tcp_v6_early_demux_configure(int enable)
> +{
> +       if (enable)
> +               tcpv6_protocol.early_demux = tcp_v6_early_demux;
> +       else
> +               tcpv6_protocol.early_demux = NULL;
> +}
> +
>  static struct inet_protosw tcpv6_protosw = {
>         .type           =       SOCK_STREAM,
>         .protocol       =       IPPROTO_TCP,
> --
> 1.9.1
>
