From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmveth: Disable tx queue while changing mtu
Date: Tue, 09 Aug 2016 15:13:44 -0700 (PDT)
Message-ID: <20160809.151344.1875492869890678715.davem@davemloft.net>
References: <1470764857-7714-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932486AbcHIWNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 18:13:45 -0400
In-Reply-To: <1470764857-7714-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Tue,  9 Aug 2016 12:47:37 -0500

> If the device is running while the MTU is changed, ibmveth
> is closed and the bounce buffer is freed. If a transmission
> is sent before ibmveth can be reopened, ibmveth_start_xmit
> tries to copy to the null bounce buffer, leading to a kernel
> oops. The proposed solution disables the tx queue until
> ibmveth is restarted.
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Tested-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

The bugs in the patch show clearly why this kind of non-unwindable behavior
is so undesirable.

> @@ -1378,14 +1379,18 @@ static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
>  						ibmveth_get_desired_dma
>  						(viodev));
>  			if (need_restart) {
> -				return ibmveth_open(adapter->netdev);
> +				rc = ibmveth_open(adapter->netdev);
> +				netif_wake_queue(dev);
> +				return rc;

If the open fails, the last thing in the world you should do is wake the
TX queue.

Furthermore, ibmveth_open() does netif_start_queue() so this call should
be completely unnecessary.

But fundamentally here the real problem, the whole operation should be
done in a "prepare, commit" style transaction.  So that if we can't
make the MTU change for whatever reason, the original MTU
configuration is retained and the interface stays up and operational.

The error recovery mechanism here in this function is unacceptable,
and needs to be rewritten from scratch.
