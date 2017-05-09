From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] dccp/tcp: do not inherit mc_list from parent
Date: Tue, 09 May 2017 15:51:13 -0700
Message-ID: <1494370273.7796.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494336559.7796.78.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXHXhnCJr6TNCUm06TkSQvdz6H+k=avN1AyBO9uBkWZAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Pray3r <pray3r.z@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35972 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEIWvQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 18:51:16 -0400
Received: by mail-pg0-f67.google.com with SMTP id 64so1643606pgb.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 15:51:15 -0700 (PDT)
In-Reply-To: <CAM_iQpXHXhnCJr6TNCUm06TkSQvdz6H+k=avN1AyBO9uBkWZAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 15:37 -0700, Cong Wang wrote:
> On Tue, May 9, 2017 at 6:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > syzkaller found a way to trigger double frees from ip_mc_drop_socket()
> >
> > It turns out that leave a copy of parent mc_list at accept() time,
> > which is very bad.
> >
> > Very similar to commit 8b485ce69876 ("tcp: do not inherit
> > fastopen_req from parent")
> >
> > Initial report from Pray3r, completed by Andrey one.
> > Thanks a lot to them !
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Pray3r <pray3r.z@gmail.com>
> > Reported-by: Andrey Konovalov <andreyknvl@google.com>
> > Tested-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> > v2: fix moved into inet_csk_clone_lock() to fix both DCCP and TCP
> >
> >  net/ipv4/inet_connection_sock.c |    2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> > index 5e313c1ac94fc88eca5fe3a0e9e46e551e955ff0..1054d330bf9df3189a21dbb08e27c0e6ad136775 100644
> > --- a/net/ipv4/inet_connection_sock.c
> > +++ b/net/ipv4/inet_connection_sock.c
> > @@ -794,6 +794,8 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
> >                 /* listeners have SOCK_RCU_FREE, not the children */
> >                 sock_reset_flag(newsk, SOCK_RCU_FREE);
> >
> > +               inet_sk(newsk)->mc_list = NULL;
> > +
> >                 newsk->sk_mark = inet_rsk(req)->ir_mark;
> >                 atomic64_set(&newsk->sk_cookie,
> >                              atomic64_read(&inet_rsk(req)->ir_cookie));
> >
> 
> I think IPv6 needs this too?
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index aeb9497..b3611d9 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1062,6 +1062,7 @@ static struct sock *tcp_v6_syn_recv_sock(const
> struct sock *sk, struct sk_buff *
>                 newtp->af_specific = &tcp_sock_ipv6_mapped_specific;
>  #endif
> 
> +               newnp->ipv6_mc_list = NULL;
>                 newnp->ipv6_ac_list = NULL;
>                 newnp->ipv6_fl_list = NULL;
>                 newnp->pktoptions  = NULL;

Good point, but it looks like you patched on only IPv4 mapped sockets.

And DCCP would need fixes as well.
