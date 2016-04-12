From: John Allen <jallen@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmvnic: Defer tx completion processing using a
 wait queue
Date: Tue, 12 Apr 2016 16:00:23 -0500
Message-ID: <570D61E7.2090203@linux.vnet.ibm.com>
References: <570D4EBC.60409@linux.vnet.ibm.com>
 <1460491940.6473.592.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:37953 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934074AbcDLVAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 17:00:45 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
	Tue, 12 Apr 2016 15:00:44 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C8EA73E4008D
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 15:00:41 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3CL0fms35324138
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 14:00:41 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3CL0dlh005656
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 15:00:41 -0600
In-Reply-To: <1460491940.6473.592.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2016 03:12 PM, Eric Dumazet wrote:
> On Tue, 2016-04-12 at 14:38 -0500, John Allen wrote:
>> Moves tx completion processing out of interrupt context, deferring work
>> using a wait queue. With this work now deferred, we must account for the
>> possibility that skbs can be sent faster than we can process completion
>> requests in which case the tx buffer will overflow. If the tx buffer is
>> full, ibmvnic_xmit will return NETDEV_TX_BUSY and stop the current tx
>> queue. Subsequently, the queue will be restarted in ibmvnic_complete_tx
>> when all pending tx completion requests have been cleared.
> 
> 1) Why is this needed ?

In the current ibmvnic implementation, tx completion processing is done in
interrupt context. Depending on the load, this can block further
interrupts for a long time. This patch just creates a bottom half so that
when a tx completion interrupt comes in, we can defer the majority of the
work and exit interrupt context quickly.

> 
> 2) If it is needed, why is this not done in a generic way, so that other
> drivers can use this ?

I'm still fairly new to network driver development so I'm not in tune with
the needs of other drivers. My assumption was that the wait queue data
structure was a reasonably generic way to handle something like this. Is
there a more appropriate/generic way of implementing a bottom half for
this purpose?

-John
> 
> Thanks.
> 
> 
> 
> 
