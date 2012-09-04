From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [RFC] packet: change call of synchronize_net to call_rcu
Date: Tue, 4 Sep 2012 16:53:06 +0200
Message-ID: <CAD6jFUSa7gD45m7WdtDymJq-WkGq+kbofkws5n3dGMtuDE6d3A@mail.gmail.com>
References: <1346768215-5194-1-git-send-email-icurt@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, edumazet@google.com, xemul@parallels.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Iulius Curt <icurt@ixiacom.com>,
	Sorin Dumitru <sdumitru@ixiacom.com>
To: Iulius Curt <iulius.curt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38012 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757147Ab2IDOxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 10:53:14 -0400
In-Reply-To: <1346768215-5194-1-git-send-email-icurt@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 4, 2012 at 4:16 PM, Iulius Curt <iulius.curt@gmail.com> wrote:
> synchronize_net is called every time we close a PF_PACKET socket which is
> causing performance loss when doing this on many sockets.

Do you have any particular use case in mind? I can imagine if you are
closing a PF_PACKET socket in a network analyzer application, you're
more or less out of its 'critical path' anyway.

> Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
> Signed-off-by: Iulius Curt <icurt@ixiacom.com>
> ---
> Statistics using test program [1]
>
> Sockets count  |  Not patched  |  Patched
> _________________________________________
>     1 000 000  |       1.28 s  |   1.22 s
>     5 000 000  |        7.3 s  |   6.25 s
>    50 000 000  |      72.89 s  |  64.41 s
>
> [1] http://pastebin.com/xQ9BziaP
> ---
>  net/packet/af_packet.c |   46 ++++++++++++++++++++++++++++++++++++----------
>  net/packet/internal.h  |    1 +
>  2 files changed, 37 insertions(+), 10 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 5dafe84..7b60135 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2299,6 +2299,32 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
>                 return packet_snd(sock, msg, len);
>  }
>
> +void packet_release_finish(struct sock *sk, int null)
> +{
> +       struct socket *sock = sk->sk_socket;
> +
> +       sock_orphan(sk);
> +       /* Modifing this after the socket has been released
> +        * might lead to memory corruption so we don't do it */
> +       if (null)
> +               sock->sk = NULL;

One minor remark: please don't name this variable "null" since it can
have a value of 0 or 1 in your code, it's a bit misleading. Maybe
rather "nullify" or something.

> +       /* Purge queues */
> +
> +       skb_queue_purge(&sk->sk_receive_queue);
> +       sk_refcnt_debug_release(sk);
> +
> +       sock_put(sk);
> +}
> +
> +void packet_release_rcu(struct rcu_head *rcu)
> +{
> +       struct packet_sock *po = container_of(rcu, struct packet_sock, rcu_head);
> +       struct sock *sk = &po->sk;
> +
> +       packet_release_finish(sk, 0);
> +}
> +
>  /*
>   *     Close a PACKET socket. This is fairly simple. We immediately go
>   *     to 'closed' state and remove our protocol entry in the device list.
> @@ -2310,6 +2336,7 @@ static int packet_release(struct socket *sock)
>         struct packet_sock *po;
>         struct net *net;
>         union tpacket_req_u req_u;
> +       int postpone = 0;
>
>         if (!sk)
>                 return 0;
> @@ -2326,7 +2353,10 @@ static int packet_release(struct socket *sock)
>         preempt_enable();
>
>         spin_lock(&po->bind_lock);
> -       unregister_prot_hook(sk, false);
> +       if (po->running) {
> +               postpone = 1;
> +               __unregister_prot_hook(sk, false);
> +       }
>         if (po->prot_hook.dev) {
>                 dev_put(po->prot_hook.dev);
>                 po->prot_hook.dev = NULL;
> @@ -2345,19 +2375,15 @@ static int packet_release(struct socket *sock)
>
>         fanout_release(sk);
>
> -       synchronize_net();
>         /*
>          *      Now the socket is dead. No more input will appear.
>          */
> -       sock_orphan(sk);
> -       sock->sk = NULL;
> -
> -       /* Purge queues */
> -
> -       skb_queue_purge(&sk->sk_receive_queue);
> -       sk_refcnt_debug_release(sk);
> +       if (postpone) {
> +               call_rcu(&po->rcu_head, packet_release_rcu);
> +               return 0;
> +       }
>
> -       sock_put(sk);
> +       packet_release_finish(sk, 1);
>         return 0;
>  }
>
> diff --git a/net/packet/internal.h b/net/packet/internal.h
> index 44945f6..5778c12 100644
> --- a/net/packet/internal.h
> +++ b/net/packet/internal.h
> @@ -104,6 +104,7 @@ struct packet_sock {
>         int                     ifindex;        /* bound device         */
>         __be16                  num;
>         struct packet_mclist    *mclist;
> +       struct rcu_head         rcu_head;
>         atomic_t                mapped;
>         enum tpacket_versions   tp_version;
>         unsigned int            tp_hdrlen;
> --
> 1.7.9.5
