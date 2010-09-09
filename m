From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 09 Sep 2010 07:23:14 +0200
Message-ID: <1284009794.2428.32.camel@edumazet-laptop>
References: <1283986576.2428.21.camel@edumazet-laptop>
	 <AANLkTimZ=i1=c3SaEsw2_ncWJenuOgoSmHpMuN_UiG4K@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61166 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab0IIFXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 01:23:20 -0400
Received: by fxm16 with SMTP id 16so666073fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 22:23:19 -0700 (PDT)
In-Reply-To: <AANLkTimZ=i1=c3SaEsw2_ncWJenuOgoSmHpMuN_UiG4K@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 16:49 -0700, Jesse Gross a =C3=A9c=
rit :
> On Wed, Sep 8, 2010 at 3:56 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Use cmpxchg() to get rid of spinlocks in inet_add_protocol() and
> > friends.
> >
> > inet_protos[] & inet6_protos[] are moved to read_mostly section
> >
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> What's the benefit to this?  It's hard to imagine that add/deleting
> protocols is highly contended.  On the other hand, a simple spinlock
> is very easy to look at and verify correct, while this takes a little
> more thought.

Good question.

Did you know that _bh() was not necessary for example at this point ?

Its a leftover of an RCU conversion, done many years ago. It _was_
working of course, but it really hurts my mind. We could use
stop_machine or other brute force thing too ;)


Before patch :

# size net/ipv4/protocol.o net/ipv6/protocol.o
   text	   data	    bss	    dec	    hex	filename
    340	      0	   2052	   2392	    958	net/ipv4/protocol.o
    342	      0	   2052	   2394	    95a	net/ipv6/protocol.o

After patch :

# size net/ipv4/protocol.o net/ipv6/protocol.o
   text	   data	    bss	    dec	    hex	filename
    220	   2048	      0	   2268	    8dc	net/ipv4/protocol.o
    222	   2048	      0	   2270	    8de	net/ipv6/protocol.o

45 lines removed, 240 bytes of text removed, I found this interesting.

Removing the ____cacheline_aligned_in_smp is also good, because
the .data alignement, is reduced and linker is not force to propagate
this alignement to upper .o files, with many holes.

If you take a look at most patches flying around, this one at least too=
k
me to think a bit ;)

Thanks


