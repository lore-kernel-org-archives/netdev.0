From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 05:41:02 -0700
Message-ID: <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	   <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	   <alpine.DEB.2.02.1406101726390.11647@dtop>
	   <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	  <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.10.1406102114520.28698@dinf>
	 <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406110011170.11647@dtop>
	 <alpine.DEB.2.02.1406110022550.11647@dtop>
	 <alpine.DEB.2.02.1406110036490.11647@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:33015 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaFKMlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 08:41:03 -0400
Received: by mail-pb0-f51.google.com with SMTP id rp16so1979589pbb.38
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 05:41:03 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406110036490.11647@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-11 at 00:38 -0700, dormando wrote:
> On Wed, 11 Jun 2014, dormando wrote:
> >
> > --> Meant to say here that both *with* and *without* your two new patches
> > it still crashes.
> >
> > > Unfortunately 3.14 has a few regressions.. one is some bad CPU usage i'll
> > > have to track down, and two something about pstore is broken, so I can't
> > > get the trace from the crash. It's compressing now and has more of the
> > > kernel log, but it's missing the actual panic part.
> > >
> > > $ git log --oneline v3.14..v3.15 net/ipv4/route.c
> > > fbdc0ad ipv4: initialise the itag variable in __mkroute_input
> > > 0d5edc6 ipv4, route: pass 0 instead of LOOPBACK_IFINDEX to fib_validate_source()
> > > aad8872 ipv4: add a sock pointer to dst->output() path.
> > > 9114615 ipv4: return valid RTA_IIF on ip route get
> > > 3ed66e9 net: replace __this_cpu_inc in route.c with raw_cpu_inc
> > > 0b8c7f6 ipv4: remove ip_rt_dump from route.c
> > > 4a4eb21 ipv4: remove ipv4_ifdown_dst from route.c
> > > 1e8d642 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> > > 2045cea net: remove unnecessary return's
> > >
> > > No more obvious race fixes. I can try 3.15 fully vanilla but I'm having
> > > doubts?
> > >
> > > We have a few patches on top of this, but none of them are active at the
> > > time of my test. I've tried removing them in the past and it did nothing
> > > as well.
> > >
> > > Sorry :(
> > >
> 
> Spamming now! The pstore'd dmesg looked suspiciously like the boot before
> I booted the crashed kernel.. checked pstore again and the crash is there
> after a second reboot (wtf.. will test tomorrow).


OK then we probably have another bug in UDP, which is that we call
sk_dst_set(sk, dst_clone(&rt->dst)); with a dst having DST_NOCACHE set

Its a problem, because sk_dst_get() cannot deal safely with such dst.

Care to share your program triggering the bug ?
