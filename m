From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH 5/5 net-next] inet: reset tb->fastreuseport when adding a
 reuseport sk
Date: Wed, 21 Dec 2016 11:49:09 -0500
Message-ID: <CAEfhGixdnn32bw=BWYQqG5KirdmA8rNZJEYG4MhCpLZGm7npvA@mail.gmail.com>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com> <1482264424-15439-6-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>, kernel-team@fb.com
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35574 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755524AbcLUQtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 11:49:14 -0500
Received: by mail-lf0-f66.google.com with SMTP id p100so14283694lfg.2
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 08:49:13 -0800 (PST)
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com. [209.85.215.53])
        by smtp.gmail.com with ESMTPSA id f186sm5994211lfg.25.2016.12.21.08.49.10
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 08:49:11 -0800 (PST)
Received: by mail-lf0-f53.google.com with SMTP id b14so101607435lfg.2
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 08:49:10 -0800 (PST)
In-Reply-To: <1482264424-15439-6-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2016 at 3:07 PM, Josef Bacik <jbacik@fb.com> wrote:
> If we have non reuseport sockets on a tb we will set tb->fastreuseport to 0 and
> never set it again.  Which means that in the future if we end up adding a bunch
> of reuseport sk's to that tb we'll have to do the expensive scan every time.
> Instead add a sock_common to the tb so we know what reuseport sk succeeded last.
> Once one sk has made it onto the list we know that there are no potential bind
> conflicts on the owners list that match that sk's rcv_addr.  So copy the sk's
> common into our tb->fastsock and set tb->fastruseport to FASTREUSESOCK_STRICT so
> we know we have to do an extra check for subsequent reuseport sockets and skip
> the expensive bind conflict check.
>
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  include/net/inet_hashtables.h   |  4 ++++
>  net/ipv4/inet_connection_sock.c | 53 +++++++++++++++++++++++++++++++++++++----
>  2 files changed, 53 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 50f635c..b776401 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -74,12 +74,16 @@ struct inet_ehash_bucket {
>   * users logged onto your box, isn't it nice to know that new data
>   * ports are created in O(1) time?  I thought so. ;-)  -DaveM
>   */
> +#define FASTREUSEPORT_ANY      1
> +#define FASTREUSEPORT_STRICT   2
> +
>  struct inet_bind_bucket {
>         possible_net_t          ib_net;
>         unsigned short          port;
>         signed char             fastreuse;
>         signed char             fastreuseport;
>         kuid_t                  fastuid;
> +       struct sock_common      fastsock;
>         int                     num_owners;
>         struct hlist_node       node;
>         struct hlist_head       owners;
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index d3ccf62..9e29fad 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -164,6 +164,32 @@ success:
>         return head;
>  }
>
> +static inline int sk_reuseport_match(struct inet_bind_bucket *tb,
> +                                    struct sock *sk)
> +{
> +       struct sock *sk2 = (struct sock *)&tb->fastsock;
> +       kuid_t uid = sock_i_uid(sk);
> +
> +       if (tb->fastreuseport <= 0)
> +               return 0;
> +       if (!sk->sk_reuseport)
> +               return 0;
> +       if (rcu_access_pointer(sk->sk_reuseport_cb))
> +               return 0;
> +       if (!uid_eq(tb->fastuid, uid))
> +               return 0;
> +       /* We only need to check the rcv_saddr if this tb was once marked
> +        * without fastreuseport and then was reset, as we can only know that
> +        * the fastsock has no potential bind conflicts with the rest of the
> +        * possible socks on the owners list.
> +        */
> +       if (tb->fastreuseport == FASTREUSEPORT_ANY)
> +               return 1;
> +       if (!inet_csk(sk)->icsk_af_ops->rcv_saddr_equal(sk, sk2, true))
The rcv_saddr_equal functions assume the type of the sk to be
inet_sock.  It doesn't look like they actually depend on any of the
inet-specific fields, but it's probably safer to either remove this
assumption or change the type of tb->fastsock to be a full inet_sock.

> +               return 0;
> +       return 1;
> +}
> +
>  /* Obtain a reference to a local port for the given sock,
>   * if snum is zero it means select any available local port.
>   * We try to allocate an odd port (and leave even ports for connect())
> @@ -206,9 +232,7 @@ tb_found:
>                         goto success;
>
>                 if ((tb->fastreuse > 0 && reuse) ||
> -                    (tb->fastreuseport > 0 &&
> -                     !rcu_access_pointer(sk->sk_reuseport_cb) &&
> -                     sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
> +                   sk_reuseport_match(tb, sk))
>                         goto success;
>                 if (inet_csk_bind_conflict(sk, tb, true, true))
>                         goto fail_unlock;
> @@ -220,14 +244,35 @@ success:
>                 if (sk->sk_reuseport) {
>                         tb->fastreuseport = 1;
>                         tb->fastuid = uid;
> +                       memcpy(&tb->fastsock, &sk->__sk_common,
> +                              sizeof(struct sock_common));
>                 } else {
>                         tb->fastreuseport = 0;
>                 }
>         } else {
>                 if (!reuse)
>                         tb->fastreuse = 0;
> -               if (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))
> +               if (sk->sk_reuseport) {
> +                       /* We didn't match or we don't have fastreuseport set on
> +                        * the tb, but we have sk_reuseport set on this socket
> +                        * and we know that there are no bind conflicts with
> +                        * this socket in this tb, so reset our tb's reuseport
> +                        * settings so that any subsequent sockets that match
> +                        * our current socket will be put on the fast path.
> +                        *
> +                        * If we reset we need to set FASTREUSEPORT_STRICT so we
> +                        * do extra checking for all subsequent sk_reuseport
> +                        * socks.
> +                        */
> +                       if (!sk_reuseport_match(tb, sk)) {
> +                               tb->fastreuseport = FASTREUSEPORT_STRICT;
> +                               tb->fastuid = uid;
> +                               memcpy(&tb->fastsock, &sk->__sk_common,
> +                                      sizeof(struct sock_common));
> +                       }
> +               } else {
>                         tb->fastreuseport = 0;
> +               }
>         }
>         if (!inet_csk(sk)->icsk_bind_hash)
>                 inet_bind_hash(sk, tb, port);
> --
> 2.9.3
>
