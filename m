From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: add ieee80211_stop_queues()
Date: Thu, 24 Aug 2006 00:07:23 +0200
Message-ID: <200608240007.23798.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B5F1@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:17550
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965237AbWHWWH5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 18:07:57 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B5F1@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 23:12, Simon Barber wrote:
> We already do have intelligent qdiscs - via TC. Anyone using htb for
> rate pacing, will achieve better control (less jitter) if the DMA queue
> latency is kept down.
> 
> One very important issue for 802.11 is the software rate control. At a
> certain point in time the rate control algorithm may determine it's time
> to start transmitting frames at a much lower rate - now all the frames
> already in the DMA queue will be transmitted at the old higher rate -
> and hence will suffer a lower probability of being received correctly.
> If the number of frames in the DMA queue can be kept down then the rate
> change happens faster. Obviously the limiting factor is keeping the DMA
> queue full enough that the hardware is not starved in the worst case of
> softirq latency. This is a time based limit.

Yes, that makes sense.
What about the following:

We don't remove the ieee80211_stop/wake_queue() mechanism, as it's
simply used to protect the hard bounds of the ring.

I think determining the ring latency might be possible without changing
the API or even changing the low level driver.

We have the ieee80211_tx_status() callback. We must simply
assume any packet that's gone through hw->tx() but not yet
got back through ieee80211_tx_status() is on the device queue.
And I think that's a valid assumption.

So accounting can be done before calling hw->tx()
and in ieee80211_tx_status().

At ieee80211_tx_status() time we have all needed information.
The frame length (skb), the transmission rate from the tx_control
array in the status report. We have that information in hw->tx(),
too, of course. So we can calculate the time (latency) the
current ring state has in O(1) time.

-- 
Greetings Michael.
