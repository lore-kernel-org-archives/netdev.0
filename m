From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: restore fastopen with no data in SYN packet
Date: Wed, 16 Dec 2015 15:02:02 -0800
Message-ID: <CAK6E8=ekbipXbX8tko9F8O0w1zfJ_eqYPE3VBak5k-wGUiSGOQ@mail.gmail.com>
References: <1450302790.8474.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36263 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbbLPXCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 18:02:43 -0500
Received: by mail-wm0-f42.google.com with SMTP id p187so22365489wmp.1
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 15:02:42 -0800 (PST)
In-Reply-To: <1450302790.8474.101.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 1:53 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> Yuchung tracked a regression caused by commit 57be5bdad759 ("ip: convert
> tcp_sendmsg() to iov_iter primitives") for TCP Fast Open.
>
> Some Fast Open users do not actually add any data in the SYN packet.
>
> Fixes: 57be5bdad759 ("ip: convert tcp_sendmsg() to iov_iter primitives")
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> ---
Acked-by: Yuchung Cheng <ycheng@google.com>
>  net/ipv4/tcp_output.c |   23 ++++++++++++-----------
>  1 file changed, 12 insertions(+), 11 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index cb7ca569052c..9bfc39ff2285 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3150,7 +3150,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct tcp_fastopen_request *fo = tp->fastopen_req;
> -       int syn_loss = 0, space, err = 0, copied;
> +       int syn_loss = 0, space, err = 0;
>         unsigned long last_syn_loss = 0;
>         struct sk_buff *syn_data;
>
> @@ -3188,17 +3188,18 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
>                 goto fallback;
>         syn_data->ip_summed = CHECKSUM_PARTIAL;
>         memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
> -       copied = copy_from_iter(skb_put(syn_data, space), space,
> -                               &fo->data->msg_iter);
> -       if (unlikely(!copied)) {
> -               kfree_skb(syn_data);
> -               goto fallback;
> -       }
> -       if (copied != space) {
> -               skb_trim(syn_data, copied);
> -               space = copied;
> +       if (space) {
> +               int copied = copy_from_iter(skb_put(syn_data, space), space,
> +                                           &fo->data->msg_iter);
> +               if (unlikely(!copied)) {
> +                       kfree_skb(syn_data);
> +                       goto fallback;
> +               }
> +               if (copied != space) {
> +                       skb_trim(syn_data, copied);
> +                       space = copied;
> +               }
>         }
> -
>         /* No more data pending in inet_wait_for_connect() */
>         if (space == fo->size)
>                 fo->data = NULL;
>
>
