From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a
 tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 22:29:41 -0700 (PDT)
Message-ID: <20140812.222941.2255442432293393813.davem@davemloft.net>
References: <163B73C6-95EF-4398-B399-ECD5B95F5EC8@oracle.com>
	<20140812.213157.60038488349789826.davem@davemloft.net>
	<8BE2AE04-EF39-45A0-9AB4-15F5160C1449@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: Raghuram.Kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaHMF3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 01:29:44 -0400
In-Reply-To: <8BE2AE04-EF39-45A0-9AB4-15F5160C1449@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Date: Tue, 12 Aug 2014 22:14:09 -0700

> On Aug 12, 2014, at 9:31 PM, David Miller <davem@davemloft.net> wrote:
> 
>> From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
>> Date: Tue, 12 Aug 2014 21:26:28 -0700
>> 
>>> One important point to keep in mind that packets to different peers shouldn't
>>> be blocked by one blocked peer. Any flow controlling or dropping of the packets
>>> needs to be done on a per-port basis.
>> 
>> Until we use a big hammer and reset the LDC channel of that peer, we
>> _absolutely_ should not reorder traffic and send to non-stuck peers.
> 
> The packet ordering requirement applies only for packets destined to
> a specific destination. The packets to different destinations can flow
> as long as they do not cause ordering issues. In case of sunvnet, 
> each peer except the switch-port would be for a specific destination,
> so sending packets to other ports would not result in re-ordering of the packets.
> 
> Even if the peer to peer LDC is the one that is blocked then disconnecting
> that LDC channel and sending the packets via switch-port would not be
> expected to change the order of the packet as the LDC reset is expect
> to drop all packets in the ring so far.  

Ok, that makes sense.

So the question is how to manage this on the driver side, and the most
natural way I see do this would be to use multiple TX netdev queues
and a custom netdev_ops->ndo_select_queue() method which selects the
queue based upon the peer that would be selected.
