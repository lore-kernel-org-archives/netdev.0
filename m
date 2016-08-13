From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ibmveth: Disable tx queue while changing mtu
Date: Sat, 13 Aug 2016 15:07:18 -0700 (PDT)
Message-ID: <20160813.150718.707775477809550559.davem@davemloft.net>
References: <1470945679-29133-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jstancek@redhat.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbcHNInX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:43:23 -0400
In-Reply-To: <1470945679-29133-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Thu, 11 Aug 2016 15:01:19 -0500

> If the device is running while the MTU is changed, ibmveth
> is closed and the bounce buffer is freed. If a transmission
> is sent before ibmveth can be reopened, ibmveth_start_xmit
> tries to copy to the null bounce buffer, leading to a kernel
> oops. The proposed solution disables the tx queue until
> ibmveth is restarted.
> 
> The error recovery mechanism is revised to revert back to
> the original MTU configuration in case there is a failure
> when restarting the device.
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Tested-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> ---
> v2: rewrote error checking mechanism to revert to original MTU 
> configuration on failure in accordance with David Miller's comments

This is a step in the right direction but misses the mark still.

Reverting to the original MTU can still fail via the call to
ibmveth_open(), with -ENOMEM or whatever, and this will leave
the device inoperative.  This is exactly the behavior which
must be avoided.

This change has to be reworked it so that a guaranteed rewind from
ibmveth_open() can be performed no matter what happens.

This means you must rework how ibmveth_open() works such that there
is a prepare and a commit phase for all resources whose allocations
can fail.

For example, you must not throw away the original ->buffer_list_addr
and ->filter_list_addr buffers, you must not throw away the DMA
allocations made to adapter->rx_queue.queue_addr...

And on and on and on, for everything ibmveth_open() does.

If set MTU fails, the device must return to the orignal MTU and it
must be fully operational.  Restoring to the orignal MTU cannot fail.

I know this is perhaps hard, but sometimes correct is hard.

Thanks.
