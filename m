From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next PATCH 2/2] ixgbe: deleting dfwd stations out of order
 can cause null ptr deref
Date: Fri, 8 Nov 2013 07:31:06 -0500
Message-ID: <20131108123106.GC4819@hmsreliant.think-freely.org>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
 <20131108085109.6935.99661.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41892 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830Ab3KHMbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 07:31:12 -0500
Content-Disposition: inline
In-Reply-To: <20131108085109.6935.99661.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 08, 2013 at 12:51:10AM -0800, John Fastabend wrote:
> The number of stations in use is kept in the num_rx_pools counter
> in the ixgbe_adapter structure. This is in turn used by the queue
> allocation scheme to determine how many queues are needed to support
> the number of pools in use with the current feature set.
> 
> This works as long as the pools are added and destroyed in order
> because (num_rx_pools * queues_per_pool) is equal to the last
> queue in use by a pool. But as soon as you delete a pool out of
> order this is no longer the case. So the above multiplication
> allocates to few queues and a pool may reference a ring that has
> not been allocated/initialized.
> 
> To resolve use the bit mask of in use pools to determine the final
> pool being used and allocate enough queues so that we don't
> inadvertently remove its queues.
> 
> # ip link add link eth2 \
> 	numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
> # ip link set dev macvlan0 up
> # ip link add link eth2 \
> 	numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
> # ip link set dev macvlan1 up
> # for i in {0..100}; do
>   ip link set dev macvlan0 down; ip link set dev macvlan0 up;
>   done;
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
