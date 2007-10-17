From: Tina Yang <tina.yang@oracle.com>
Subject: Re: [patch] net: avoid race between netpoll and network fast path
Date: Tue, 16 Oct 2007 22:46:30 -0700
Message-ID: <4715A1B6.5020300@oracle.com>
References: <47158540.7000709@oracle.com> <20071016.210613.71104656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:18605 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbXJQFx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 01:53:29 -0400
In-Reply-To: <20071016.210613.71104656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Tina Yang <tina.yang@oracle.com>
> Date: Tue, 16 Oct 2007 20:45:04 -0700
> 
>> The current netpoll design and implementation has serveral race issues with the
>> network fast path that panics/hangs the system or causes interface timeout/reset
>> but the fix is likely to have impact on the overall system performance and could
>> involve a large number of drivers.  The proposal is to disable the problem code
>> for normal operations but only to enable it at the time of crash in case polling
>> is necessary.  Tests that have been done included the bug fix verification
>> as well as regression check on the netlog results in various crash modes.
>>
>> Signed-off-by: Tina Yang <tina.yang@oracle.com>
> 
> This is at best a kludge, and it's the wrong way to approach this problem.
> 
> Fix the bug, and fix it right.
> 
	
> If you disable that stretch of code, what you've done is make the
> netpoll code hang and/or drop console messages if the TX queue is full
> in the driver and the only way to liberate TX space is to call into
> ->poll().


	Isn't net_rx_action() calling ->poll() to free the TX space ?
	TX queue full can only be emptied when the device is done transmitting
	not because of netpoll ->poll() it.  The softirq (net_rx_action)
	is the purpose for such an event.  Netconsole messages will be
	dropped if the device can't keep up with it regardless of netpoll
	->poll() or not.  If no dropping can be tolerated, then the
	netpoll upper layer probably should be redesigned to buffer the data.

	The poll_list currently is in a per_cpu structure, not being
	protected globally that netpoll thread from any cpu can
	trash it.

> 
> You haven't shown the precise race that leads to corruption so that someone
> so motivated can guide you towards a more correct fix if you are not
> capable of implementing it properly on your own.


	The precise race is
	1) net_rx_action get the dev from poll_list
	2) at the same time, netpoll poll_napi() get a hold of the poll lock
	   and calls ->poll(), remove dev from the poll list
	3) after it finishes, net_rx_action get the poll lock, and calls
	   ->poll() the second time, and panic when trying to remove (again)
	   the dev from the poll list.
	and I had logged all the crash info from the crash scenes into the
	bug database.

	As Matt Mackall had acknowledged, the network fast path went to great
	length to reduce locking overhead, should that be undone because of
	netpoll if that's what it takes to fix it more correctly ?

	

	

