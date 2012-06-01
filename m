From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Fri, 01 Jun 2012 11:34:46 +0200
Message-ID: <1338543286.2760.1477.camel@edumazet-glaptop>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	 <201206010939.22620.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39908 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759291Ab2FAJev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 05:34:51 -0400
Received: by bkcji2 with SMTP id ji2so1654304bkc.19
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 02:34:50 -0700 (PDT)
In-Reply-To: <201206010939.22620.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-01 at 09:36 +0200, Hans Schillstrom wrote:
> On Thursday 31 May 2012 23:56:37 Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > pfifo_fast being the default Qdisc, its pretty easy to fill it with
> > SYNACK (small) packets while host is under SYNFLOOD attack.
> > 
> > Packets of established TCP sessions are dropped and host appears almost
> > dead.
> > 
> > Avoid this problem assigning TC_PRIO_FILLER priority to SYNACK
> > generated in SYNCOOKIE mode, so that these packets are enqueued into
> > pfifo_fast band 2.
> > 
> > Other packets, queued to band 0 or 1 are dequeued before any SYNACK
> > packets waiting in band 2.
> > 
> Thanks Eric,
> the patch is in under test now.
> 

Thanks Hans

By the way, I found that we have another problem because __qdisc_run()
( called from net_tx_action()) only pushes 64 frames per invocation, and
in fact less if need_resched() breaks the loop.

Its not fair with the net_rx_action, allowed to receive 64 frames per
NAPI device regardless of need_resched().

So if our cpu is flooded by incoming frames, our output is muted.

Basically we need to make SYNACK frames aware of multiqueue devices,
since they currently all end on one single queue.

Obvious choice is to reflect incoming SYN packet @queue_mapping to
SYNACK packet.

I am testing a patch right now.
