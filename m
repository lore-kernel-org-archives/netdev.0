From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 12:54:24 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B5D2@dhost002-46.dex002.intermedia.net>
References: <200608232145.05763.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jiri Benc" <jbenc@suse.cz>, <linville@tuxdriver.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:46497 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965170AbWHWTyM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:54:12 -0400
Content-class: urn:content-classes:message
in-reply-to: <200608232145.05763.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'd agree the memory benefit is not worth the work and complexity. The
additional benefit is tighter queue control - reducing the latency
between the software qdisc (and whatever scheduling/rate controlling/etc
work they are doing) and the frames coming out of the hardware. A 100
frame DMA queue can be 1.2 seconds of transmit time, or it can be 30ms
of transmit time depending on frame size and transmission rate. This
disparity will only get larger as rates go up with 11n.

A further benefit in reducing this latency - is to keep the latency
between the software rate control algorithm (which sees frames before
they hit the DMA queue) and the hardware tx down. This allows the
software rate control to be more responsive.

Simon

-----Original Message-----
From: Michael Buesch [mailto:mb@bu3sch.de] 
Sent: Wednesday, August 23, 2006 12:45 PM
To: Simon Barber
Cc: Jiri Benc; linville@tuxdriver.com; netdev@vger.kernel.org
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()

On Wednesday 23 August 2006 21:30, Simon Barber wrote:
> One question - in most hardware implementations today the queues are 
> DMA rings. In this case the right length of the queue is determined by

> the interrupt/tx_softirq latency required to keep the queue from 
> becoming empty. With 802.11 there are large differences in the time it

> takes to transmit different frames - a full size 1Mbit frame vs. a 
> short 54Mbit frame. Would it be worth optimizing the DMA queue length 
> to be a function of the amount of time rather than number of frames?

I doubt that the added complexity would do any good.
We should look at what a ring actually is.
A ring is an allocated memory space with dma descriptors in it.
The ring size if the number of dma descriptors. So theoretically the
number of descriptors adds up to the size to allocate.
In practice we have alignment issues (at least for bcm43xx).
For a ring we always allocate one page of memory. Regardless of how much
of it is actually used by descriptors.
One wireless-specific thing remains, though. We store meta data for each
descriptor (The ieee80211_tx_control at least).
So basically only the memory consumption of the meta data could be
optimized.

We used to have 512 TX descriptors for each ring until I recently
submitted a patch to lower it to 128. I did this because after doing
stress tests the maximum amount of used descriptors did not go over
about 80 on my machines.

I think it basically comes down to the question:
Do we want to save 1 kb of memory[*] but pay the price of additional
code complexity?

[*] 1kb is a random value invented by me. I did not calculate
    it, but it should be somewhere around that value.

--
Greetings Michael.
