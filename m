From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/l2tp:BUG: KASAN: use-after-free in l2tp_ip6_close
Date: Wed, 16 Nov 2016 11:08:23 -0800
Message-ID: <CAM_iQpUxNYpkRetxX88z=iFZiZ1beQqBt+9qFsDTnAYwWCoHfA@mail.gmail.com>
References: <33b1f154-3f9a-55b6-63d3-cd28c0524ea6@gmail.com>
 <CAM_iQpWpf--gXPy7zD7ax4vt-foMCh_dw8Pbb3=y_gSgegeF3Q@mail.gmail.com>
 <76f028b3-cf56-5526-352f-ff4826933779@gmail.com> <20161116163021.tblhptv37r6byjvp@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Baozeng Ding <sploving1@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36063 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbcKPTIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 14:08:44 -0500
Received: by mail-it0-f53.google.com with SMTP id l8so83482450iti.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 11:08:44 -0800 (PST)
In-Reply-To: <20161116163021.tblhptv37r6byjvp@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 8:30 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
> index fce25af..982f6c4 100644
> --- a/net/l2tp/l2tp_ip.c
> +++ b/net/l2tp/l2tp_ip.c
> @@ -251,8 +251,6 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>         int ret;
>         int chk_addr_ret;
>
> -       if (!sock_flag(sk, SOCK_ZAPPED))
> -               return -EINVAL;
>         if (addr_len < sizeof(struct sockaddr_l2tpip))
>                 return -EINVAL;
>         if (addr->l2tp_family != AF_INET)
> @@ -267,6 +265,9 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>         read_unlock_bh(&l2tp_ip_lock);
>
>         lock_sock(sk);
> +       if (!sock_flag(sk, SOCK_ZAPPED))
> +               goto out;
> +
>         if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_l2tpip))
>                 goto out;
>
> diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
> index ad3468c..9978d01 100644
> --- a/net/l2tp/l2tp_ip6.c
> +++ b/net/l2tp/l2tp_ip6.c
> @@ -269,8 +269,6 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>         int addr_type;
>         int err;
>
> -       if (!sock_flag(sk, SOCK_ZAPPED))
> -               return -EINVAL;
>         if (addr->l2tp_family != AF_INET6)
>                 return -EINVAL;
>         if (addr_len < sizeof(*addr))
> @@ -296,6 +294,9 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>         lock_sock(sk);
>
>         err = -EINVAL;
> +       if (!sock_flag(sk, SOCK_ZAPPED))
> +               goto out_unlock;
> +
>         if (sk->sk_state != TCP_CLOSE)
>                 goto out_unlock;


Makes sense, it should prevent a concurrent caller adding the socket
into bind table
twice after passing __l2tp_ip_bind_lookup() check.
