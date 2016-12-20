From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Mon, 19 Dec 2016 20:52:16 -0800
Message-ID: <1482209536.1521.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481928610.17731.0@smtp.office365.com>
         <e32b5375-38fb-1fd8-d97a-bf740e368205@stressinduktion.org>
         <286A21B1-2A15-4DDF-B334-A016DA3D52EA@fb.com>
         <20161219.205646.1955469060856026212.davem@davemloft.net>
         <CALx6S340vCsaymbx+CcKL3Zi2p9EvDSwc0fDAxKsSqs4C2p5kg@mail.gmail.com>
        ,<1482201702.1521.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <9DF94C8E-1463-4C10-81E3-E6F4534097CB@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34661 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756935AbcLTEwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 23:52:19 -0500
Received: by mail-it0-f65.google.com with SMTP id 75so12714355ite.1
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 20:52:18 -0800 (PST)
In-Reply-To: <9DF94C8E-1463-4C10-81E3-E6F4534097CB@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-20 at 03:40 +0000, Josef Bacik wrote:
> > On Dec 19, 2016, at 9:42 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> >> On Mon, 2016-12-19 at 18:07 -0800, Tom Herbert wrote:
> >> 
> >> When sockets created SO_REUSEPORT move to TW state they are placed
> >> back on the the tb->owners. fastreuse port is no longer set so we have
> >> to walk potential long list of sockets in tb->owners to open a new
> >> listener socket. I imagine this is happens when we try to open a new
> >> listener SO_REUSEPORT after the system has been running a while and so
> >> we hit the long tb->owners list.
> > 
> > Hmm...  __inet_twsk_hashdance() does not change tb->fastreuse
> > 
> > So where tb->fastreuse is cleared ?
> > 
> > If all your sockets have SO_REUSEPORT set, this should not happen.
> > 
> 
> The app starts out with no SO_REUSEPORT, and then we restart it with
> that option enabled.

But... why would the application do this dance ?

I now better understand why we never had these issues...


>   What I suspect is we have all the twsks from the original service,
> and the fastreuse stuff is cleared.  My naive patch resets it once we
> add a reuseport sk to the tb and that makes the problem go away.  I'm
> reworking all of this logic and adding some extra info to the tb to
> make the reset actually safe.  I'll send those patches out tomorrow.
> Thanks,

Okay, we will review them ;)

Note that Willy Tarreau wants some mechanism to be able to freeze a
listener, to allow haproxy to be replaced without closing any sessions.
