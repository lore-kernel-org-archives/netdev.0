From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Mon, 06 Oct 2014 15:25:26 -0400 (EDT)
Message-ID: <20141006.152526.965519223260573233.davem@davemloft.net>
References: <20141003144024.GA12448@oracle.com>
	<20141003.120802.1213573830649867131.davem@davemloft.net>
	<20141006160418.GA3604@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaJFTZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:25:28 -0400
In-Reply-To: <20141006160418.GA3604@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 6 Oct 2014 12:04:18 -0400

>> I think you should be able to get rid of all of the in-driver
>> locking in the fast paths.
>> 
>> NAPI ->poll() is non-reentrant, so all RX processing occurs
>> strictly in a serialized environment.
>> 
>> Once you do TX reclaim in NAPI context, then all you have to do is
>> take the generic netdev TX queue lock during the evaluation of whether
>> to wakeup the TX queue or not.  Worst case you need to hold the
>> TX netdev queue lock across the whole TX reclaim operation.
>> 
>> The VIO lock really ought to be entirely superfluous in the data
>> paths.
> 
> A few clarifications, since there are more driver-examples using NAPI for
> Rx than for Tx reclaim

Those drivers fully go against our recommendations, we always say that
TX reclaim should also run from NAPI because it liberates SKBs that
therefore become available for RX processing.

> But we still need to hold the vio lock around the ldc_write 
> (and also around dring write) in vnet_start_xmit, right?

You might be able to avoid it, you're fully serialized by the TX queue
lock.
