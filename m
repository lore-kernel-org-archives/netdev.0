From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Potential race in ip4_datagram_release_cb
Date: Fri, 06 Jun 2014 10:56:04 -0700
Message-ID: <1402077364.3645.310.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	 <1402059375.3645.284.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQL=D_KF2iRLO1Ufoih3Rg-WtSA9UYuU0OjOZebGBryVHA@mail.gmail.com>
	 <1402071367.3645.305.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQL47b+nFo+WUJGw=oCEVwRHtK98poe8SJqw4F-jAUXoyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	dormando <dormando@rydia.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:43435 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbaFFR4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 13:56:07 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so2719769pdi.27
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 10:56:06 -0700 (PDT)
In-Reply-To: <CAADnVQL47b+nFo+WUJGw=oCEVwRHtK98poe8SJqw4F-jAUXoyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-06 at 10:44 -0700, Alexei Starovoitov wrote:
> On Fri, Jun 6, 2014 at 9:16 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > We should either :
> >
> > 1) use xchg() and no lock at all to change sk_dst_cache, as we did for
> > sk_rx_dst ( cf udp_sk_rx_dst_set() )
> >
> > 2) No longer use sk_dst_lock, and always use the socket lock
> > (sk->sk_lock.slock) instead.
> 
> Probably needs some combination of both.

I do not think so.

If we use xchg(), then we do not need anything else.

If we use a spinlock, then xchg() seems useless.

Any combination is buggy.

In the past, UDP transmit was holding socket lock,
but we added a lockless path, and I suppose more people
use a UDP socket from different threads.

Then, Steffen added the ip4_datagram_release_cb() thing,
increasing the chance of mixing both 'protections'.

Setting sk_dst_cache should hardly be a hot path.
