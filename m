From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 8 Jun 2007 10:35:36 +0530
Message-ID: <OFB3E7F689.931E12C0-ON652572F4.0019C1EA-652572F4.001BFADE@in.ibm.com>
References: <20070607161335.GA4987@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:61164 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756444AbXFHFIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 01:08:46 -0400
Received: from sd0112e0.au.ibm.com (d23rh903.au.ibm.com [202.81.18.201])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l585TiI1323146
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:29:44 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0112e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l585C5xM108890
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:12:05 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5856M0c029733
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:06:23 +1000
In-Reply-To: <20070607161335.GA4987@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

> Let me clarify: there are two possibilities to send data:
> 1. via batched sending, which runs via queue of packets and performs
> prepare call (which only setups some private flags, no work with
> hardware) and then sending call.
> 2. old xmit function (which seems to be unused by kernel now?)

The old xmit is used by all drivers. Only drivers providing this new
API will go through the other path. I am planning to also submit some
changes on top of jamal's patch, which will provide a configuration
parameter to enable/disable this API for a particular device.

> Btw, prep_queue_frame seems to be always called under tx_lock, but it
> old e1000 xmit function calls it without lock. Locked case is correct,
> since it accesses private registers via e1000_transfer_dhcp_info() for
> some adapters.

Prep is called after holding the dev->queue lock (not tx_lock). The old
E1000 xmit also calls prep holding just the dev->queue lock. tx_lock is
held after that.

> So, essentially batched sending is
> lock
> while ((skb = dequue))
>   send
> unlock
>
> where queue of skbs are prepared by stack using the same transmit lock.
>
> Where is a gain?

(Not the transmit lock). But in any case, we are amortizing the cost of
the lock in the driver by starting multiple I/O's and doing a single DMA
operation. The prep part is done in both cases holding the dev->queue
lock. Similarly IPoIB could have performance gains as it requires a
completion notification for every skb, and this could be changed to get
notification for only the last skb (and avoid calling completion
notification for 1 to n-1 skbs).

> Btw, this one forces a smile:
>    if (unlikely(ret != NETDEV_TX_OK))
>          return NETDEV_TX_OK;

Actually that is how the original code is handling error in prep since
those skbs are freed up anyway and should not be retried or requeue'd :-)

Thanks,

- KK

