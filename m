From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Fri, 19 Oct 2012 12:29:22 +0200
Message-ID: <1350642562.2293.411.camel@edumazet-glaptop>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	 <507C4401.7050500@oracle.com>
	 <CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	 <CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
	 <5080279F.80008@oracle.com> <5080340F.3050207@oracle.com>
	 <CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
	 <CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
	 <1350629413.2293.157.camel@edumazet-glaptop>
	 <1350634013.2293.262.camel@edumazet-glaptop>
	 <CAGK4HS_9mLzL9ESm=n5hvO0cw1hkHFMCSmBiYTBnqEMqQOvPvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: enh <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:36304 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419Ab2JSK33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 06:29:29 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so98162eaa.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 03:29:25 -0700 (PDT)
In-Reply-To: <CAGK4HS_9mLzL9ESm=n5hvO0cw1hkHFMCSmBiYTBnqEMqQOvPvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 02:14 -0700, Vijay Subramanian wrote:
> > diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > index ef998b0..0404926 100644
> > --- a/net/ipv4/tcp_ipv4.c
> > +++ b/net/ipv4/tcp_ipv4.c
> > @@ -1507,7 +1507,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
> >          * clogging syn queue with openreqs with exponentially increasing
> >          * timeout.
> >          */
> > -       if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
> > +       if (__sk_acceptq_is_full(sk, inet_csk_reqsk_queue_young(sk)))
> >                 goto drop;
> >
> 
> For what its worth, I think the changes make sense. But is there any
> reason to exclude old request_socks in the  call to
> __sk_acceptq_is_full().?
> as in
>       if (__sk_acceptq_is_full(sk, inet_csk_reqsk_queue_len(sk)))
>                goto drop;
> 
> I am not sure why the current code looks only at young request_socks.
> Thanks,
> Vijay

Old requests are assumed to be unlikely to complete (SYN attack).

young requests are assumed to have a reasonable chance to complete.

Note that we drop the SYN packet, so its not a 'final' decision.

Some other OSes send RST in case the listener queue is full
(I tested FreeBSD 9.0 this morning.)

Note also we probably have a bug elsewhere :

If we send a SYNACK, then receive the ACK from client, and the acceptq
is full, we should reset the connexion. Right now we have kind of stupid
situation, were we drop the ACK, and leave the REQ in the SYN_RECV
state, so we retransmit SYNACKS.

I am working on this part as well.
