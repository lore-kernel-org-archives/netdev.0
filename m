From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Thu, 30 Mar 2017 17:02:59 -0700
Message-ID: <1490918579.24891.82.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
         <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
         <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
         <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
         <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490748756.24891.27.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWyQJ+XN_4mSarzHRYX4eio81G49i=wyE5MHS+AUFWU8g@mail.gmail.com>
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
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36526 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933005AbdCaADD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 20:03:03 -0400
Received: by mail-pg0-f66.google.com with SMTP id 81so13164482pgh.3
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 17:03:02 -0700 (PDT)
In-Reply-To: <CAM_iQpWyQJ+XN_4mSarzHRYX4eio81G49i=wyE5MHS+AUFWU8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 16:36 -0700, Cong Wang wrote:
> On Tue, Mar 28, 2017 at 5:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2017-03-28 at 16:11 -0700, Eric Dumazet wrote:
> >
> >> Yes, this looks better.
> >>
> >> Although you probably need to change a bit later this part :
> >>
> >> if (!inet->inet_saddr)
> >>       inet->inet_saddr = fl4->saddr;  /* Update source address */
> >>
> >
> > I came up with the following tested patch for IPv4
> >
> > diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
> > index f915abff1350a86af8d5bb89725b751c061b0fb5..1454b6191e0d38ffae0ae260578858285bc5f77b 100644
> > --- a/net/ipv4/datagram.c
> > +++ b/net/ipv4/datagram.c
> > @@ -40,7 +40,7 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
> >         sk_dst_reset(sk);
> >
> >         oif = sk->sk_bound_dev_if;
> > -       saddr = inet->inet_saddr;
> > +       saddr = (sk->sk_userlocks & SOCK_BINDADDR_LOCK) ? inet->inet_saddr : 0;
> >         if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
> >                 if (!oif)
> >                         oif = inet->mc_index;
> > @@ -64,9 +64,8 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
> >                 err = -EACCES;
> >                 goto out;
> >         }
> > -       if (!inet->inet_saddr)
> > +       if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK)) {
> >                 inet->inet_saddr = fl4->saddr;  /* Update source address */
> > -       if (!inet->inet_rcv_saddr) {
> >                 inet->inet_rcv_saddr = fl4->saddr;
> >                 if (sk->sk_prot->rehash)
> >                         sk->sk_prot->rehash(sk);
> 
> Why do we need this here? If you mean bind() INADDR_ANY is bound,
> then it is totally a different problem?


Proper delivery of RX packets will need to find the socket, and this
needs the 2-tuple (source address, source port) info for UDP.

So after a connect(), we need to rehash

> 
> BTW, I am still not sure about what POSIX says about the connect()
> behavior, I can only find this [1]:
> 
> "
> If the initiating socket is not connection-mode, then connect() shall set the
> socket's peer address, and no connection is made. For SOCK_DGRAM
> sockets, the peer address identifies where all datagrams are sent on
> subsequent send() functions, and limits the remote sender for subsequent
> recv() functions.
> "
> 
> It doesn't say anything about source address. But the man page [2] says:
> 
> "
> When
>        connect(2) is called on an unbound socket, the socket is
>        automatically bound to a random free port or to a usable shared port
>        with the local address set to INADDR_ANY.
> "
> 
> Seems the last part is inaccurate, kernel actually picks a source address
> from route instead of just using INADDR_ANY for connect(2).
> 
> So, for me, I think the following behaviors make sense for UDP:
> 
> 1) When a bind() is called before connect()'s, aka:
> 
> bind();
> connect(addr1); // should not change source addr

It depends. bind() can be only allocating the source port.

If bind(INADDR_ANY) was used, then we need to determine source addr at
connect() time.

Point of connect() is that future send() wont have to guess the 4-tuple
infos. But also that incoming packets will find this precise socket
thanks to a higher score.

And tools like "ss -aun" should display the 4-tuple after a successful
connect()

> connect(addr2); // should fail is the source addr can not reach peer addr
> 
> 2) No bind() before connect()'s, aka:
> 
> connect(addr1); // Free to bind a source addr
> connect(addr2); // Free to bind a new source addr and change peer addr

Exactly. My patch does this.

> 
> Thoughts?
> 
> 1. http://pubs.opengroup.org/onlinepubs/9699919799/functions/connect.html
> 2. http://man7.org/linux/man-pages/man7/ip.7.html
