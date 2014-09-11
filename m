From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Why ECONNREFUSED from unix_dgram_sendmsg?
Date: Thu, 11 Sep 2014 10:52:04 -0700
Message-ID: <CALCETrWZQjcWawO2brnpfmzHFrmYekwaic9a6m_mKcWvB2dovg@mail.gmail.com>
References: <CALCETrUM1P0Sydps_4-5yPBOBD35zOcpACv-OX8b==xT0BC1xw@mail.gmail.com>
 <1410451139.2693347.166368361.32138EFC@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:49951 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaIKRw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 13:52:26 -0400
Received: by mail-la0-f50.google.com with SMTP id ty20so8768656lab.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 10:52:24 -0700 (PDT)
In-Reply-To: <1410451139.2693347.166368361.32138EFC@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep 11, 2014 8:59 AM, "Hannes Frederic Sowa"
<hannes@stressinduktion.org> wrote:
>
>
>
> On Thu, Sep 11, 2014, at 17:11, Andy Lutomirski wrote:
> > What is unix_dgram_sendmsg trying to tell me here?
> >
> >         if (sock_flag(other, SOCK_DEAD)) {
> >                 /*
> >                  *      Check with 1003.1g - what should
> >                  *      datagram error
> >                  */
> >                 unix_state_unlock(other);
> >                 sock_put(other);
> >
> >                 err = 0;
> >                 unix_state_lock(sk);
> >                 if (unix_peer(sk) == other) {
> >                         unix_peer(sk) = NULL;
> >                         unix_state_unlock(sk);
> >
> >                         unix_dgram_disconnected(sk, other);
> >                         sock_put(other);
> >                         err = -ECONNREFUSED;
> >
> > I'm getting this intermittently on a seqpacket socket when the other
> > end dies.  Shouldn't this be -ECONNRESET?
> >
> > git blame doesn't tell me anything here -- this code predates git.
>
> Changelogs were not that descriptive as they were today: :)
>
> commit 283fd6cf0be690a83b5dbb34e79130f8592c0765
> Author: davem <davem>
> Date:   Fri Aug 20 10:59:51 1999 +0000
>
>     Merge in ANK networking jumbo patch,
>     which includes ATM from Werner Almesberger, Netfilter
>     from Paul Russell, and massive SMP networking enhancements
>     by Alexey.
>
> (in
> https://git.kernel.org/cgit/linux/kernel/git/davem/netdev-vger-cvs.git/)
>
> I agree, -ECONNRESET would be a better errno value, but this is hard to
> change because of backwards compatibility.

Might it be safe to change it for just seqpacket sockets?  -ECONRESET
actually makes some sense for dgram sockets, assuming this code is
even reachable for dgram sockets.

Anyway, I'll have to fix my code regardless.

--Andy
