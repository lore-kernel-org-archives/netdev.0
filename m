From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 2/2] tcp: add TCP_CC_INFO socket option
Date: Wed, 29 Apr 2015 09:15:34 -0700
Message-ID: <CAK6E8=ekC_p-210vBS=m5vAZZ56AnBwoQaOnu0ZzP8cL7UReYQ@mail.gmail.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com> <1430263429-4069-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34123 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbbD2Qlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 12:41:35 -0400
Received: by iget9 with SMTP id t9so111189331ige.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 09:41:34 -0700 (PDT)
In-Reply-To: <1430263429-4069-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 4:23 PM, Eric Dumazet <edumazet@google.com> wrote:
> Some Congestion Control modules can provide per flow information,
> but current way to get this information is to use netlink.
>
> Like TCP_INFO, let's add TCP_CC_INFO so that applications can
> issue a getsockopt() if they have a socket file descriptor,
> instead of playing complex netlink games.
>
> Sample usage would be :
>
>   union tcp_cc_info info;
>   socklen_t len = sizeof(info);
>
>   if (getsockopt(fd, SOL_TCP, TCP_CC_INFO, &info, &len) == -1)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

Nice extension!

> ---
>  include/uapi/linux/tcp.h |  1 +
>  net/ipv4/tcp.c           | 21 +++++++++++++++++++++
>  2 files changed, 22 insertions(+)
>
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index 3b9718328d8b..937ec387276f 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -112,6 +112,7 @@ enum {
>  #define TCP_FASTOPEN           23      /* Enable FastOpen on listeners */
>  #define TCP_TIMESTAMP          24
>  #define TCP_NOTSENT_LOWAT      25      /* limit number of unsent bytes in write queue */
> +#define TCP_CC_INFO            26      /* Get Congestion Control (optional) info */
>
>  struct tcp_repair_opt {
>         __u32   opt_code;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 8c5cd9efebbc..1e06c75a6837 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -252,6 +252,7 @@
>  #include <linux/types.h>
>  #include <linux/fcntl.h>
>  #include <linux/poll.h>
> +#include <linux/inet_diag.h>
>  #include <linux/init.h>
>  #include <linux/fs.h>
>  #include <linux/skbuff.h>
> @@ -2734,6 +2735,26 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>                         return -EFAULT;
>                 return 0;
>         }
> +       case TCP_CC_INFO: {
> +               const struct tcp_congestion_ops *ca_ops;
> +               union tcp_cc_info info;
> +               size_t sz = 0;
> +               int attr;
> +
> +               if (get_user(len, optlen))
> +                       return -EFAULT;
> +
> +               ca_ops = icsk->icsk_ca_ops;
> +               if (ca_ops && ca_ops->get_info)
> +                       sz = ca_ops->get_info(sk, ~0U, &attr, &info);
> +
> +               len = min_t(unsigned int, len, sz);
> +               if (put_user(len, optlen))
> +                       return -EFAULT;
> +               if (copy_to_user(optval, &info, len))
> +                       return -EFAULT;
> +               return 0;
> +       }
>         case TCP_QUICKACK:
>                 val = !icsk->icsk_ack.pingpong;
>                 break;
> --
> 2.2.0.rc0.207.ga3a616c
>
