From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v4 1/2] New kernel function to get IP overhead on
 a socket.
Date: Wed, 22 Mar 2017 16:03:23 -0700
Message-ID: <CALx6S351vjeWtKhi9GmXhBjq0Kw5wriz6Hv-h-E9bVTtgeYXjg@mail.gmail.com>
References: <alpine.DEB.2.11.1703221554000.9002@vera100.eng.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kleptog@svana.org, jchapman@katalix.com,
        David Miller <davem@redhat.com>, nprachan@brocade.com,
        rshearma@brocade.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        sdietric@brocade.com, ciwillia@brocade.com, lboccass@brocade.com,
        dfawcus@brocade.com, bhong@brocade.com, jblunck@brocade.com,
        LKML <linux-kernel@vger.kernel.org>
To: "R. Parameswaran" <parameswaran.r7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1703221554000.9002@vera100.eng.brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 22, 2017 at 3:59 PM, R. Parameswaran
<parameswaran.r7@gmail.com> wrote:
>
> A new function, kernel_sock_ip_overhead(), is provided
> to calculate the cumulative overhead imposed by the IP
> Header and IP options, if any, on a socket's payload.
> The new function returns an overhead of zero for sockets
> that do not belong to the IPv4 or IPv6 address families.
>
Can you provide some context as to why this is needed?

Tom

> Signed-off-by: R. Parameswaran <rparames@brocade.com>
> ---
>  include/linux/net.h |  3 +++
>  net/socket.c        | 44 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 47 insertions(+)
>
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 0620f5e..a42fab2 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -298,6 +298,9 @@ int kernel_sendpage(struct socket *sock, struct page *page, int offset,
>  int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
>  int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how);
>
> +/* Following routine returns the IP overhead imposed by a socket.  */
> +u32 kernel_sock_ip_overhead(struct sock *sk);
> +
>  #define MODULE_ALIAS_NETPROTO(proto) \
>         MODULE_ALIAS("net-pf-" __stringify(proto))
>
> diff --git a/net/socket.c b/net/socket.c
> index e034fe4..69598e1 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -3345,3 +3345,47 @@ int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
>         return sock->ops->shutdown(sock, how);
>  }
>  EXPORT_SYMBOL(kernel_sock_shutdown);
> +
> +/* This routine returns the IP overhead imposed by a socket i.e.
> + * the length of the underlying IP header, depending on whether
> + * this is an IPv4 or IPv6 socket and the length from IP options turned
> + * on at the socket.
> + */
> +u32 kernel_sock_ip_overhead(struct sock *sk)
> +{
> +       struct inet_sock *inet;
> +       struct ipv6_pinfo *np;
> +       struct ip_options_rcu *opt;
> +       struct ipv6_txoptions *optv6 = NULL;
> +       u32 overhead = 0;
> +       bool owned_by_user;
> +
> +       if (!sk)
> +               return overhead;
> +
> +       owned_by_user = sock_owned_by_user(sk);
> +       switch (sk->sk_family) {
> +       case AF_INET:
> +               inet = inet_sk(sk);
> +               overhead += sizeof(struct iphdr);
> +               opt = rcu_dereference_protected(inet->inet_opt,
> +                                               owned_by_user);
> +               if (opt)
> +                       overhead += opt->opt.optlen;
> +               return overhead;
> +#if IS_ENABLED(CONFIG_IPV6)
> +       case AF_INET6:
> +               np = inet6_sk(sk);
> +               overhead += sizeof(struct ipv6hdr);
> +               if (np)
> +                       optv6 = rcu_dereference_protected(np->opt,
> +                                                         owned_by_user);
> +               if (optv6)
> +                       overhead += (optv6->opt_flen + optv6->opt_nflen);
> +               return overhead;
> +#endif /* IS_ENABLED(CONFIG_IPV6) */
> +       default: /* Returns 0 overhead if the socket is not ipv4 or ipv6 */
> +               return overhead;
> +       }
> +}
> +EXPORT_SYMBOL(kernel_sock_ip_overhead);
> --
> 2.1.4
>
