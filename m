From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Mon, 06 Oct 2014 15:37:12 -0400 (EDT)
Message-ID: <20141006.153712.1610016632407187994.davem@davemloft.net>
References: <20141006160418.GA3604@oracle.com>
	<20141006.152526.965519223260573233.davem@davemloft.net>
	<20141006193111.GE24721@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbaJFThO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:37:14 -0400
In-Reply-To: <20141006193111.GE24721@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 6 Oct 2014 15:31:11 -0400

> On (10/06/14 15:25), David Miller wrote:
>> 
>> > But we still need to hold the vio lock around the ldc_write 
>> > (and also around dring write) in vnet_start_xmit, right?
>> 
>> You might be able to avoid it, you're fully serialized by the TX queue
>> lock.
> 
> yes, I was just noticing that. The only place where I believe I need
> to hold the vio spin-lock is to sync with the dr->cons checks
> (the "should I send a start_cons LDC message?" check in vnet_start_xmit()
> vs the vnet_ack() updates).

I don't see how that is any different from the netif_queue_wake() checks,
it should be just as easy to cover it with the generic xmit lock.

> But isn't it better in general to declare NETIF_F_LLTX and have finer lock
> granularity in the driver?

No, NETIF_F_LLTX drivers are heavily discouraged.  And on the
contrary, it's easier to optimize the locking when we can consolidate
what is covered at both the mid-level of the networking send paths and
what the drivers need in their ->ndo_start_xmit() routines.
