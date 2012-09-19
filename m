From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] tcp: Fixed a TFO server bug that crashed kernel by raw sockets
Date: Tue, 18 Sep 2012 19:14:09 -0700
Message-ID: <CAPshTChYfA5BpkLjWNn+V1QDQQX+gP6+HbUtPTTdAepkPCB9jg@mail.gmail.com>
References: <1348011351-13882-1-git-send-email-hkchu@google.com>
	<4380003.jOHRfqhomY@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com,
	edumazet@google.com
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63214 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab2ISCOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 22:14:11 -0400
Received: by wibhi8 with SMTP id hi8so4965443wib.1
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 19:14:10 -0700 (PDT)
In-Reply-To: <4380003.jOHRfqhomY@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 18, 2012 at 5:19 PM, Christoph Paasch
<christoph.paasch@uclouvain.be> wrote:
> On Tuesday 18 September 2012 16:35:51 H.K. Jerry Chu wrote:
>> From: Jerry Chu <hkchu@google.com>
>>
>> Crash dump msg looks like this:
>>
>> <1>[34468.419809] BUG: unable to handle kernel paging request at
>> ffffeb57000dc058 <1>[34468.426770] IP: [<ffffffff80383f9c>]
>> kfree+0x4c/0x2d0
>> ...
>> <4>[34468.603362] Call Trace:
>> <4>[34468.605802]  [<ffffffff807542a4>] inet_sock_destruct+0x174/0x1f0
>> <4>[34468.611786]  [<ffffffff806ced53>] __sk_free+0x23/0x170
>> <4>[34468.616907]  [<ffffffff806ceec5>] sk_free+0x25/0x30
>> <4>[34468.621762]  [<ffffffff806d066a>] sk_common_release+0x7a/0x80
>> <4>[34468.627481]  [<ffffffff80746782>] raw_close+0x22/0x30
>> <4>[34468.632515]  [<ffffffff80753038>] inet_release+0x58/0x90
>> <4>[34468.637802]  [<ffffffff806c9dd8>] sock_release+0x28/0x90
>> <4>[34468.643087]  [<ffffffff806c9f07>] sock_close+0x17/0x30
>> <4>[34468.648203]  [<ffffffff8039d60a>] fput+0xda/0x210
>> <4>[34468.652894]  [<ffffffff80398e06>] filp_close+0x66/0x90
>> <4>[34468.658016]  [<ffffffff802822cd>] put_files_struct+0x9d/0x120
>> <4>[34468.663743]  [<ffffffff802823fa>] exit_files+0x4a/0x60
>> <4>[34468.668857]  [<ffffffff802828e4>] do_exit+0x1a4/0x8c0
>> <4>[34468.673886]  [<ffffffff803697db>] ? do_munmap+0x2ab/0x390
>> <4>[34468.679256]  [<ffffffff80283384>] do_group_exit+0x44/0xa0
>> <4>[34468.684632]  [<ffffffff8028341f>] sys_exit_group+0x3f/0x50
>> <4>[34468.690094]  [<ffffffff807a5730>] sysenter_dispatch+0x7/0x1a
>>
>> This bug was introduced as part of patch
>> 7ab4551f3b391818e29263279031dca1e26417c6
>>
>> It turns out the call "socket(PF_INET/PF_INET6, SOCK_RAW, IPPROTO_TCP)"
>> will cause a raw socket to be created with protocol == IPPROTO_TCP
>> so checking against the protocol field in sk alone is not sufficient
>> to guarantee a TCP socket. One must also check type == SOCK_STREAM.
>>
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>> Cc: Neal Cardwell <ncardwell@google.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> ---
>>  net/ipv4/af_inet.c |   28 +++++++++++++++++-----------
>>  1 files changed, 17 insertions(+), 11 deletions(-)
>
> Why not moving the TCP-code out of inet_sock_destruct by modifying the sk_destruct
> callback when TFO is in use? Like the below (only compile-tested) patch. That
> way inet_sock_destruct stays TFO-free.

That will work too. (I briefly thought about this but was distracted by
the two pr_err() returns...)

>
>
> Cheers,
> Christoph
>
> ---------
>
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Wed, 19 Sep 2012 02:06:53 +0200
> Subject: [PATCH] Don't add TCP-code in inet_sock_destruct
>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  include/linux/tcp.h |    4 ++++
>  net/ipv4/af_inet.c  |    2 --
>  net/ipv4/tcp.c      |    7 +++++++
>  3 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index ae46df5..67c789a 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -574,6 +574,8 @@ static inline bool fastopen_cookie_present(struct tcp_fastopen_cookie *foc)
>         return foc->len != -1;
>  }
>
> +extern void tcp_sock_destruct(struct sock *sk);
> +
>  static inline int fastopen_init_queue(struct sock *sk, int backlog)
>  {
>         struct request_sock_queue *queue =
> @@ -585,6 +587,8 @@ static inline int fastopen_init_queue(struct sock *sk, int backlog)
>                     sk->sk_allocation);
>                 if (queue->fastopenq == NULL)
>                         return -ENOMEM;
> +
> +               sk->sk_destruct = tcp_sock_destruct;
>                 spin_lock_init(&queue->fastopenq->lock);
>         }
>         queue->fastopenq->max_qlen = backlog;
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 845372b..766c596 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -149,8 +149,6 @@ void inet_sock_destruct(struct sock *sk)
>                 pr_err("Attempt to release alive inet socket %p\n", sk);
>                 return;
>         }
> -       if (sk->sk_protocol == IPPROTO_TCP)
> -               kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
>
>         WARN_ON(atomic_read(&sk->sk_rmem_alloc));
>         WARN_ON(atomic_read(&sk->sk_wmem_alloc));
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index df83d74..7b1e940 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2325,6 +2325,13 @@ int tcp_disconnect(struct sock *sk, int flags)
>  }
>  EXPORT_SYMBOL(tcp_disconnect);
>
> +void tcp_sock_destruct(struct sock *sk)
> +{
> +       inet_sock_destruct(sk);
> +
> +       kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
> +}
> +
>  static inline bool tcp_can_repair_sock(const struct sock *sk)
>  {
>         return capable(CAP_NET_ADMIN) &&
> --
> 1.7.9.5
>
>

Acked-by: H.K. Jerry Chu <hkchu@google.com>
