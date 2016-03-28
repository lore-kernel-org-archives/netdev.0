From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 11:55:46 -0700
Message-ID: <1459191346.6473.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
	 <1458944964-12890-3-git-send-email-edumazet@google.com>
	 <56F95884.8010901@hpe.com>
	 <1459184434.6473.104.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56F97B70.1000904@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35794 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcC1Szs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 14:55:48 -0400
Received: by mail-pa0-f44.google.com with SMTP id td3so103946490pab.2
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 11:55:48 -0700 (PDT)
In-Reply-To: <56F97B70.1000904@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 11:44 -0700, Rick Jones wrote:
> On 03/28/2016 10:00 AM, Eric Dumazet wrote:
> > On Mon, 2016-03-28 at 09:15 -0700, Rick Jones wrote:
> >> On 03/25/2016 03:29 PM, Eric Dumazet wrote:
> >>> UDP sockets are not short lived in the high usage case, so the added
> >>> cost of call_rcu() should not be a concern.
> >>
> >> Even a busy DNS resolver?
> >
> > If you mean that a busy DNS resolver spends _most_ of its time doing :
> >
> > fd = socket()
> > bind(fd  port=0)
> >    < send and receive one frame >
> > close(fd)
> 
> Yes.  Although it has been a long time, I thought that say the likes of 
> a caching named in the middle between hosts and the rest of the DNS 
> would behave that way as it was looking-up names on behalf those who 
> asked it.

I really doubt a modern program would dynamically allocate one UDP port
for every in-flight request, as it would limit them to number of
ephemeral ports concurrent requests (~30000 assuming the process can get
them all on the host)

Managing a pool would be more efficient (The 1.3 usec penalty becomes
more like 4 usec in multi threaded programs)

Sure, you always can find badly written programs, but they already hit
scalability issues anyway.

UDP refcounting cost about 2 cache line misses per packet in stress
situations, this really has to go, so that well written programs can get
full speed.
