From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Tue, 28 Mar 2017 16:11:52 -0700
Message-ID: <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
         <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
         <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
         <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daurnimator <quae@daurnimator.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35430 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752735AbdC1XL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:11:57 -0400
Received: by mail-it0-f66.google.com with SMTP id y18so6680019itc.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:11:56 -0700 (PDT)
In-Reply-To: <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-27 at 21:22 -0700, Cong Wang wrote:
> On Fri, Mar 24, 2017 at 4:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Fri, 2017-03-24 at 15:34 -0700, Cong Wang wrote:
> >> (Cc'ing Michael Kerrisk)
> >>
> >> On Wed, Mar 22, 2017 at 10:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> > On Thu, 2017-03-23 at 13:22 +1100, Daurnimator wrote:
> >> >> On 9 March 2017 at 14:10, Daurnimator <quae@daurnimator.com> wrote:
> >> >> > When debugging https://github.com/daurnimator/lua-http/issues/73 which
> >> >> > uses https://github.com/wahern/dns we ran into an issue where modern
> >> >> > linux kernels return EINVAL if you try and re-use a udp socket.
> >> >> > The issue seems to occur if you go from a local destination ip to a
> >> >> > non-local one.
> >> >>
> >> >> Did anyone get a chance to look into this issue?
> >> >
> >> > I believe man page is not complete.
> >> >
> >> > A disconnect is needed before another connect()
> >>
> >> Is it? Making connect() reentrant is reasonable for connection-less
> >> protocol like UDP, but I don't dig POSIX for the details. If so we need
> >> something like below...
> >>
> >> --- a/net/ipv4/datagram.c
> >> +++ b/net/ipv4/datagram.c
> >> @@ -40,7 +40,7 @@ int __ip4_datagram_connect(struct sock *sk, struct
> >> sockaddr *uaddr, int addr_len
> >>         sk_dst_reset(sk);
> >>
> >>         oif = sk->sk_bound_dev_if;
> >> -       saddr = inet->inet_saddr;
> >> +       saddr = inet->inet_saddr = 0;
> >>         if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
> >>                 if (!oif)
> >>                         oif = inet->mc_index;
> >
> > Wont this break bind() ?
> >
> 
> Right. We need to distinguish bind() and connect(), something
> like below?
> 
> --- a/net/ipv4/datagram.c
> +++ b/net/ipv4/datagram.c
> @@ -26,7 +26,7 @@ int __ip4_datagram_connect(struct sock *sk, struct
> sockaddr *uaddr, int addr_len
>         struct sockaddr_in *usin = (struct sockaddr_in *) uaddr;
>         struct flowi4 *fl4;
>         struct rtable *rt;
> -       __be32 saddr;
> +       __be32 saddr = 0;
>         int oif;
>         int err;
> 
> @@ -40,7 +40,8 @@ int __ip4_datagram_connect(struct sock *sk, struct
> sockaddr *uaddr, int addr_len
>         sk_dst_reset(sk);
> 
>         oif = sk->sk_bound_dev_if;
> -       saddr = inet->inet_saddr;
> +       if (sk->sk_userlocks & SOCK_BINDADDR_LOCK)
> +               saddr = inet->inet_saddr;
>         if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
>                 if (!oif)
>                         oif = inet->mc_index;

Yes, this looks better.

Although you probably need to change a bit later this part :

if (!inet->inet_saddr)
	inet->inet_saddr = fl4->saddr;  /* Update source address */


Should we also fix IPv6 or is this bug only about IPv4 ?

Thanks !
