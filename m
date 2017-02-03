From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] Add a eBPF helper function to retrieve
 socket uid
Date: Thu, 02 Feb 2017 17:51:48 -0800
Message-ID: <1486086708.21871.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
         <20170202205950.100334-3-chenbofeng.kernel@gmail.com>
         <5893A587.6090000@iogearbox.net>
         <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com>
         <1486081861.21871.39.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKD1Yr1tPP-7ic4nreqzKk6Gb+ZgyKo8yqw-KP=w7oqABkiZQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36655 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751570AbdBCBvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 20:51:51 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so520404pgf.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 17:51:51 -0800 (PST)
In-Reply-To: <CAKD1Yr1tPP-7ic4nreqzKk6Gb+ZgyKo8yqw-KP=w7oqABkiZQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 10:18 +0900, Lorenzo Colitti wrote:
> On Fri, Feb 3, 2017 at 9:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> It should be safe to call sock_net_uid on any type of socket
> >> (including NULL). sk_uid was added to struct sock in 86741ec25462
> >> ("net: core: Add a UID field to struct sock.")
> >
> > But a request socket or a timewait socket do not have this field.
> >
> > Daniel point is valid.
> 
> My bad. Yes.
> 
> It would definitely be useful to have the UID available in request
> sockets, and perhaps timewait sockets as well. That could be done by
> moving the UID to sock_common, or with something along the lines of:
> 
>  static inline kuid_t sock_net_uid(const struct net *net, const struct sock *sk)
>  {
> +       if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
> +               sk = sk->__sk_common.skc_listener;
> +       else if (sk && !sk_fullsock(sk))
> +               sk = NULL;
> +
>         return sk ? sk->sk_uid : make_kuid(net->user_ns, 0);
>  }
> 
> Any thoughts on which is better?

You could use

if (sk) {
    sk = sk_to_full_sk(sk);
    if (sk_fullsock(sk))
        return sk->sk_uid;
}
