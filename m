From: Oliver Neukum <oneukum@suse.de>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Thu, 06 Sep 2012 10:50:13 +0200
Message-ID: <6556435.5o3fR8ZcBa@linux-lqwf.site>
References: <2791550.LhGu6po6Xy@linux-lqwf.site> <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "bjorn@mork.no" <bjorn@mork.no>, Ming Lei <tom.leiming@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46055 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756787Ab2IFIve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 04:51:34 -0400
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 September 2012 10:13:01 Alexey ORISHKO wrote:
> > -----Original Message-----
> > From: Oliver Neukum [mailto:oneukum@suse.de]
> 
> 
> > looking at cdc-ncm it seeems to me that cdc-ncm is forced to play very
> > dirty games because usbnet doesn't have a notion about aggregating
> > packets for a single transfer.
> 
> Several issues need to be improved:
> Tx path:
> 1. IP packets must be accumulated in one NTB. Currently it's done via data copy.
> Preferred way would be a possibility to have a list of skb-s in resulting frame sent down.

I am afraid much HCD hardware is just not capable of doing DMA on a list of skbs.
I guess one copy will be necessary. We might consider not freeing the buffer used
to transfer over the bus.

> 2. Timer is needed to accumulate enough packets to get acceptable throughput and reducing amount of HW INTs on device side.
> If we get access to Tx queue size and can read skb from it, time can be removed. But Tx queue is above usbnet, so doesn't look possible in current framework.

I think we can use the number of transfers in flight to make that decision.
So if the choice is to not transfer data at all or to send transfers filled to the
max, we should send, otherwise we ought to accumulate.
That way we get rid of the timer.

> 3. While trying to get best throughput we also need to keep latency in mind, because in some setups it is quite important.
> As a simple solution configuration parameters could be used to address this issue.

I think we should just send the first (two) packages and use the time
to aggregate later packets.

> Rx path:
> 4. IP packets are cloned to separate skb and length of actual data set to eth packet size, while skb size is still the same as skb containing full NTB frame. This causes problems with TCP stack when throughput is high because of flow control in the stack, if too much data allocated.
> Someone suggested a patch for it, which was rejected. Anyway, I don't think copy data to a new skb would be a nice solution, but keeping several clones with size equal to incoming skb in not good either. 

Perhaps the problem is using an skb for aggregate reception at all.
Possibly enough buffers of fixed size should be allocated on open and reused,
not freed.

	Regards
		Oliver
