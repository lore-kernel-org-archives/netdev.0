From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC TLS Offload Support 05/15] tcp: Add TLS socket options for
 TCP sockets
Date: Tue, 28 Mar 2017 07:56:46 -0700
Message-ID: <CALx6S378aiPhkJ_EX3Xm5UVYvcsoM6vKd9cQ=vW4o+17aBP0CA@mail.gmail.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com> <1490707592-1430-6-git-send-email-aviadye@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, ilyal@mellanox.com,
        borisp@mellanox.com, Dave Watson <davejwatson@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        Herbert Xu <herbert@gondor.apana.org.au>, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        aviadye@dev.mellanox.co.il
To: Aviad Yehezkel <aviadye@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33712 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752231AbdC1O46 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:56:58 -0400
Received: by mail-qt0-f195.google.com with SMTP id r45so12428502qte.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:56:52 -0700 (PDT)
In-Reply-To: <1490707592-1430-6-git-send-email-aviadye@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 6:26 AM, Aviad Yehezkel <aviadye@mellanox.com> wrote:
> This patch adds TLS_TX and TLS_RX TCP socket options.
>
> Setting these socket options will change the sk->sk_prot
> operations of the TCP socket. The user is responsible to
> prevent races between calls to the previous operations
> and the new operations. After successful return, data
> sent on this socket will be encapsulated in TLS.
>
> Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
> Signed-off-by: Boris Pismenny <borisp@mellanox.com>
> Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
> ---
>  include/uapi/linux/tcp.h |  2 ++
>  net/ipv4/tcp.c           | 32 ++++++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+)
>
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index c53de26..f9f0e29 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -116,6 +116,8 @@ enum {
>  #define TCP_SAVE_SYN           27      /* Record SYN headers for new connections */
>  #define TCP_SAVED_SYN          28      /* Get SYN headers recorded for connection */
>  #define TCP_REPAIR_WINDOW      29      /* Get/set window parameters */
> +#define TCP_TLS_TX             30
> +#define TCP_TLS_RX             31
>
>  struct tcp_repair_opt {
>         __u32   opt_code;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 302fee9..2d190e3 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -273,6 +273,7 @@
>  #include <net/icmp.h>
>  #include <net/inet_common.h>
>  #include <net/tcp.h>
> +#include <net/tls.h>
>  #include <net/xfrm.h>
>  #include <net/ip.h>
>  #include <net/sock.h>
> @@ -2676,6 +2677,21 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>                 tp->notsent_lowat = val;
>                 sk->sk_write_space(sk);
>                 break;
> +       case TCP_TLS_TX:
> +       case TCP_TLS_RX: {
> +               int (*fn)(struct sock *sk, int optname,
> +                         char __user *optval, unsigned int optlen);
> +
> +               fn = symbol_get(tls_sk_attach);
> +               if (!fn) {
> +                       err = -EINVAL;
> +                       break;
> +               }
> +
> +               err = fn(sk, optname, optval, optlen);
> +               symbol_put(tls_sk_attach);
> +               break;
> +       }
>         default:
>                 err = -ENOPROTOOPT;
>                 break;
> @@ -3064,6 +3080,22 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>                 }
>                 return 0;
>         }
> +       case TCP_TLS_TX:
> +       case TCP_TLS_RX: {
> +               int err;
> +               int (*fn)(struct sock *sk, int optname,
> +                         char __user *optval, int __user *optlen);
> +
> +               fn = symbol_get(tls_sk_query);
> +               if (!fn) {
> +                       err = -EINVAL;
> +                       break;
> +               }
> +
> +               err = fn(sk, optname, optval, optlen);
> +               symbol_put(tls_sk_query);
> +               return err;
> +       }

This mechanism should be generalized. If we can do this with TLS then
there will likely be other ULPs that we might want to set on a TCP
socket. Maybe something like TCP_ULP_PUSH, TCP_ULP_POP (borrowing from
STREAMS ever so slightly :-) ). I'd also suggest that the ULPs are
indicated by a text string in the socket option argument, then have
each ULP perform a registration for their service.


>         default:
>                 return -ENOPROTOOPT;
>         }
> --
> 2.7.4
>
