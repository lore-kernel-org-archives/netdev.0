From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt
 context.
Date: Fri, 3 Oct 2014 10:40:24 -0400
Message-ID: <20141003144024.GA12448@oracle.com>
References: <20141001202315.GN17706@oracle.com>
 <20141001.162529.2246298941833907545.davem@davemloft.net>
 <20141002201203.GA6001@oracle.com>
 <20141002.134346.2291749763304558513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42378 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbaJCOkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 10:40:36 -0400
Content-Disposition: inline
In-Reply-To: <20141002.134346.2291749763304558513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/02/14 13:43), David Miller wrote:
> For example, you can now move everything into software IRQ context,
> just disable the VIO interrupt and unconditionally go into NAPI
> context from the VIO event.
> No more irqsave/irqrestore.
> Then the TX path even can run mostly lockless, it just needs
> to hold the VIO lock for a minute period of time.  The caller
> holds the xmit_lock of the network device to prevent re-entry
> into the ->ndo_start_xmit() path.
> 

let me check into this and get back. I think the xmit path
may also need to have some kind of locking for the dring access
and ldc_write? I think you are suggesting that I should also
move the control-packet processing to vnet_event_napi(), which
I have not done in my patch. I will examine where that leads.

But there is one thing that I do not understand - why does my hack
to lie to net_rx_action() by always returning "budget" 
make such a difference to throughput? 

Even if I set the budget to be as low as 64 (so I would get
called repeatedly under NAPIs polling infra), I have to 
turn on the "liar" commented code in my patch for the throughput
shoots up to 2 - 2.5  Gbps (whereas it's otherwise around 300 Mbps).
Eyeballing the net_rx_action() code quickly did not make the explanation
for this pop out at me (yet).

Pure polling (i.e., workq) gives me about 1.5 Gbps, and pure-tasklet
(i.e, just setting up a tasklet from vnet_event to handle data) gives me
approx 2 Gbps. So I dont understand why NAPI doesn't give me something
similar, if I adhere strictly to the documentation.

--Sowmini
