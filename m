From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: dual_emac: fix reducing of
 rx descriptor during ifdown
Date: Wed, 3 Sep 2014 12:46:55 +0530
Message-ID: <5406C067.5080103@ti.com>
References: <1409304145-26179-1-git-send-email-mugunthanvnm@ti.com>	<20140901.183108.784916699845611422.davem@davemloft.net>	<54058C01.3010402@ti.com> <20140902.115434.1276391011837651390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41466 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbaICHQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 03:16:58 -0400
In-Reply-To: <20140902.115434.1276391011837651390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

On Wednesday 03 September 2014 12:24 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Tue, 2 Sep 2014 14:51:05 +0530
> 
>> When ifup and ifdown is run continuously, for each spilled packet (for
>> interface which is down) from DMA, the total number of rx descriptor
>> goes down and at one instance all the descriptor is lost and both the
>> interface stops working.
>>
>> To recover from this we need to put down both the interface and open the
>> interface which will re-init the DMA which intern queues fresh set of
>> skbs for rx.
> 
> But you still should not receive packets for a netdev which is down.
> As far as I can tell, you're feeding it into the stack still.

If there is separate DMA for each netdev, then it is true that there
won't be a packet for a closed netdev. But in CPSW dual EMAC case, one
DMA engine is shared between two slave ports, so when one slave netdev
is put down, the DMA is not teared down as the other slave netdev is
still active. In heavy traffic network when putting down netdev, there
are chances that packets are already processed by DMA, and waiting for
NAPI to be submitted to network stack might belong to the netdev which
is already down.

So instead of just freeing the skb received on netdev which is already
down (which will reduce the total rx descriptors in rx dma channel),
requeue it back to DMA and make sure that rx dma descriptor count is
never reduced.

> 
> Also this doesn't explain why the "status < 0" case applies to this
> new logic, you have not explained that at all.
> 

This scenario is not generated when "status < 0", "status < 0" happens
when DMA is in tear-down mode, the above scenario happens when
netif_running(ndev) is false which denotes that netdev is down already.

Regards
Mugunthan V N
