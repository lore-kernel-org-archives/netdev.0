From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 14:12:50 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B5F1@dhost002-46.dex002.intermedia.net>
References: <200608232257.25590.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jiri Benc" <jbenc@suse.cz>, <linville@tuxdriver.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:40390 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965201AbWHWVMh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 17:12:37 -0400
Content-class: urn:content-classes:message
in-reply-to: <200608232257.25590.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We already do have intelligent qdiscs - via TC. Anyone using htb for
rate pacing, will achieve better control (less jitter) if the DMA queue
latency is kept down.

One very important issue for 802.11 is the software rate control. At a
certain point in time the rate control algorithm may determine it's time
to start transmitting frames at a much lower rate - now all the frames
already in the DMA queue will be transmitted at the old higher rate -
and hence will suffer a lower probability of being received correctly.
If the number of frames in the DMA queue can be kept down then the rate
change happens faster. Obviously the limiting factor is keeping the DMA
queue full enough that the hardware is not starved in the worst case of
softirq latency. This is a time based limit.

Simon


-----Original Message-----
From: Michael Buesch [mailto:mb@bu3sch.de] 
Sent: Wednesday, August 23, 2006 1:57 PM
To: Simon Barber
Cc: Jiri Benc; linville@tuxdriver.com; netdev@vger.kernel.org
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()

On Wednesday 23 August 2006 22:32, Simon Barber wrote:
> Right - and what I'm proposing is that we don't just count the number 
> of frames in the ring - but also count the amount of frame time the 
> ring takes too. This way if there are a number of large, slow frames 
> we can stop adding more frames into the ring well before we reach the 
> limit on the number of frames.

Ah, now I understand what you are trying to explain. :) But why do we
actually _want_ to stop a DMA ring, if it's not full (has free
descriptors)? I can't see any benefit on it. Adding frames to the ring
is done on the fly without stopping or otherwise interferring with any
running transmissions queued earlier.
I would say we don't care about the time it takes for the ring to go
into idle on the d80211 level. I think the only thing we care at d80211
level is: Can we queue another frame?
We have that logic. If a queue is not stopped, we can queue another
frame.

Or do you want to make the qdisc intelligent? Say, it drops a few
beacons, if there are already packets queued for the next 300ms, for
example. Do you want to optimize latency of payload data by dropping
low-priority packets while the queue is heavily loaded?
I can't see another usage for time based DMA ring accounting in d80211,
yet.

--
Greetings Michael.
