From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 17:03:28 -0800
Message-ID: <1383786208.2878.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131106013038.GA14894@gondor.apana.org.au>
	 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106040717.GA15711@gondor.apana.org.au>
	 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106042858.GA15745@gondor.apana.org.au>
	 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106080425.GA17556@gondor.apana.org.au>
	 <20131106081638.GA17665@gondor.apana.org.au>
	 <20131106131252.GA20680@gondor.apana.org.au>
	 <1383750070.4291.163.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107003658.GA27976@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:43830 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab3KGBDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:03:33 -0500
Received: by mail-qc0-f180.google.com with SMTP id e9so299890qcy.11
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 17:03:32 -0800 (PST)
In-Reply-To: <20131107003658.GA27976@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 08:36 +0800, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 07:01:10AM -0800, Eric Dumazet wrote:
> > Have you thought about arches having PAGE_SIZE=65536, and how bad it is
> > to use a full page per network frame ? It is lazy and x86 centered.
> 
> So instead if we were sending a full 64K packet on such an arch to
> another guest, we'd now chop it up into 1.5K chunks and reassemble them.
> 

Yep, and speed is now better than before the patches.

I understand you do not believe it. But this is the truth.

And now your guest can receive a bunch of small UDP frames, without
having to drop them because sk->rcvbuf limit is hit.

> > So after our patches, we now have an optimal situation, even on these
> > arches.
> 
> Optimal only for physical incoming packets with no jumbo frames.

Have you actually tested this ?

> 
> What's worse, I now realise that the coalesce thing isn't even
> guaranteed to work.  It probably works in your benchmarks because
> you're working with freshly allocated pages.
> 

Oh well.

> But once the system has been running for a while, I see nothing
> in the virtio_net code that tries to prevent fragmentation.  Once
> fragmentation sets in, you'll be back in the terrible situation
> that we were in prior to the coalesce patch.
> 

There is no fragmentation, since we allocate 32Kb pages.

Michael Dalton worked on a patch to add EWMA for auto sizing and a
private page_frag per virtio queue, instead of using the per cpu one.

On x86 :

- All offloads enabled (average packet size should be >> MTU-size)

net-next trunk w/ virtio_net prior to 2613af0ed (PAGE_SIZE bufs): 14179.17Gb/s
net-next trunk (MTU-size bufs):  13390.69Gb/s
net-next trunk + auto-tune - 14358.41Gb/s

- guest_tso4/guest_csum disabled (forces MTU-sized packets on receiver)

net-next trunk w/ virtio_net prior to 2613af0ed: 4059.49Gb/s
net-next trunk (MTU 1500- packet takes two bufs due to sizing bug): 4174.30Gb/s
net-next trunk (MTU 1480- packet fits in one buf): 6672.16Gb/s
net-next trunk + auto-tune (MTU 1500- fixed, packet uses one buf) - 6791.28Gb/s
