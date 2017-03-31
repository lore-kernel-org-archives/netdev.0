From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Fri, 31 Mar 2017 09:52:47 -0700
Message-ID: <CAM_iQpXmx1GN3zvnuB6SAp9fBo_yf8G3nubGeec6tMYs4BTt2A@mail.gmail.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
 <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
 <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
 <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
 <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <1490748756.24891.27.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWyQJ+XN_4mSarzHRYX4eio81G49i=wyE5MHS+AUFWU8g@mail.gmail.com> <1490918579.24891.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daurnimator <quae@daurnimator.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38354 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933167AbdCaQxJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 12:53:09 -0400
Received: by mail-wm0-f49.google.com with SMTP id t189so3625373wmt.1
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 09:53:08 -0700 (PDT)
In-Reply-To: <1490918579.24891.82.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 5:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-30 at 16:36 -0700, Cong Wang wrote:
>> On Tue, Mar 28, 2017 at 5:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Tue, 2017-03-28 at 16:11 -0700, Eric Dumazet wrote:
>> >
>> >> Yes, this looks better.
>> >>
>> >> Although you probably need to change a bit later this part :
>> >>
>> >> if (!inet->inet_saddr)
>> >>       inet->inet_saddr = fl4->saddr;  /* Update source address */
>> >>
>> >
>> > I came up with the following tested patch for IPv4
>> >
>> > diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
>> > index f915abff1350a86af8d5bb89725b751c061b0fb5..1454b6191e0d38ffae0ae260578858285bc5f77b 100644
>> > --- a/net/ipv4/datagram.c
>> > +++ b/net/ipv4/datagram.c
>> > @@ -40,7 +40,7 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
>> >         sk_dst_reset(sk);
>> >
>> >         oif = sk->sk_bound_dev_if;
>> > -       saddr = inet->inet_saddr;
>> > +       saddr = (sk->sk_userlocks & SOCK_BINDADDR_LOCK) ? inet->inet_saddr : 0;
>> >         if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
>> >                 if (!oif)
>> >                         oif = inet->mc_index;
>> > @@ -64,9 +64,8 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
>> >                 err = -EACCES;
>> >                 goto out;
>> >         }
>> > -       if (!inet->inet_saddr)
>> > +       if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK)) {
>> >                 inet->inet_saddr = fl4->saddr;  /* Update source address */
>> > -       if (!inet->inet_rcv_saddr) {
>> >                 inet->inet_rcv_saddr = fl4->saddr;
>> >                 if (sk->sk_prot->rehash)
>> >                         sk->sk_prot->rehash(sk);
>>
>> Why do we need this here? If you mean bind() INADDR_ANY is bound,
>> then it is totally a different problem?
>
>
> Proper delivery of RX packets will need to find the socket, and this
> needs the 2-tuple (source address, source port) info for UDP.
>
> So after a connect(), we need to rehash

Oh, I didn't notice remove the if (!inet->inet_rcv_saddr) check...

[...]

>> 1) When a bind() is called before connect()'s, aka:
>>
>> bind();
>> connect(addr1); // should not change source addr
>
> It depends. bind() can be only allocating the source port.
>
> If bind(INADDR_ANY) was used, then we need to determine source addr at
> connect() time.

Yes, bind() only sets the flag for non-zero address:

        if (inet->inet_rcv_saddr)
                sk->sk_userlocks |= SOCK_BINDADDR_LOCK;


Please submit your patch formally and with a man page patch too.
