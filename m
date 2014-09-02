From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: dual_emac: fix reducing of
 rx descriptor during ifdown
Date: Tue, 2 Sep 2014 14:51:05 +0530
Message-ID: <54058C01.3010402@ti.com>
References: <1409304145-26179-1-git-send-email-mugunthanvnm@ti.com> <20140901.183108.784916699845611422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:38711 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242AbaIBJVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 05:21:09 -0400
In-Reply-To: <20140901.183108.784916699845611422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

On Tuesday 02 September 2014 07:01 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Fri, 29 Aug 2014 14:52:25 +0530
> 
>> In Dual EMAC, when both interface are up and while doing ifdown with heavy
>> traffic then skbs already processed by DMA from that slave emac has to be
>> requeued as still the other interface is up and running.
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> 
> I don't see why this is important.
> 
> If the packet arrived via the down interface, let it be dropped and
> the sender will simply resend if necessary.
> 
> Also you are putting this new multi-slave logic under the "status < 0"
> condition as well as the interface being down, that's not right either.
> 

Multi slave logic is already there though out the driver, this is one
corner case where it fails. Let me explain more

DMA is common for both interfaces and serves both the slave ports. In
heavy traffic when one interface is put down, there are chances that
some packets are already processed in are in completed state.

Since DMA is a common entity for both interface, DMA is disabled only
when there all the slave interfaces are down. so when both interface is
up and putting down one interface, DMA de-init doesn't  happen as the
other interface is up.

In this scenario, when cpsw_rx_handler is called for processing the
packet which might have packets for interfaces which is down already.
Previously the driver simply drops the skb and doesn't do re-queue of
the descriptor which results in one descriptor less for rx DMA.

When ifup and ifdown is run continuously, for each spilled packet (for
interface which is down) from DMA, the total number of rx descriptor
goes down and at one instance all the descriptor is lost and both the
interface stops working.

To recover from this we need to put down both the interface and open the
interface which will re-init the DMA which intern queues fresh set of
skbs for rx.

So to overcome this issue, I did this fix by re-queuing the rx
descriptor back to DMA when any one interface is so that the no of rx
descriptor is kept constant always.

Regards
Mugunthan V N
