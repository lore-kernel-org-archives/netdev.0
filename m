From: Don Fry <pcnet32@frontier.com>
Subject: Re: [PATCH net-next 1/2] pcnet32: fix reallocation error
Date: Tue, 18 Feb 2014 20:58:55 -0800
Message-ID: <1392785935.2570.16.camel@Linux>
References: <1392699466.4020.27.camel@Linux>
	 <201402182129.BDD57369.FVOQHFOFtJSLOM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter04.roch.ny.frontiernet.net ([66.133.183.234]:36014 "EHLO
	filter04.roch.ny.frontiernet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750838AbaBSE7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 23:59:02 -0500
In-Reply-To: <201402182129.BDD57369.FVOQHFOFtJSLOM@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-next 1/2] pcnet32: fix reallocation error
Date: Tue, 18 Feb 2014 21:29:00 +0900

>Don Fry wrote:
>> pcnet32_realloc_rx_ring() only worked on the first log2 number of
>> entries in the receive ring instead of the all the entries.
>> Replaced "1 << size" with more descriptive variable.
>
>>  	/* first copy the current receive buffers */
>> -	overlap = min(size, lp->rx_ring_size);
>> +	overlap = min(entries, lp->rx_ring_size);
>
>>  	/* now allocate any new buffers needed */
>> -	for (; new < size; new++) {
>> +	for (; new < entries; new++) {
>>
>Until this fix, lp->rx_skbuff[size...(1<<size)-1] were not allocated by
>netdev_alloc_skb() and lp->rx_ring_dma_addr[size...(1<<size)-1] were not mapped
>by pci_map_single(), right?
>
>Since lp->rx_ring_size was set to (1<<size), wasn't there possibility that
>something bad happens by accessing lp->rx_skbuff[] and lp->rx_ring_dma_addr[]
>up to (1<<size)-1 ? (In other words, don't we want to backport this fix?)
>

I looked into this when testing.  If the device is operational
(netif_running) when the ring is resized, it will do pcnet32_restart and
make sure all rx buffers are full.  If the device is not operational it
will leave the ring partially full until it is opened and then the ring
is filled via pcnet32_init_ring().  Another thing that could happen
while it is down is that a selftest is done (offline) which also calls
pcnet32_restart and makes sure the ring is full.  I could not find a
case that would cause a problem.  No-one has reported this in the last 8
years so it does not look like backporting this fix is needed, in my
opinion.
