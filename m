From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] e1000e: stop unnecessary polling when using msi-x
Date: Fri, 19 Jun 2009 11:06:34 -0400
Message-ID: <20090619150634.GH8515@gospo.rdu.redhat.com>
References: <20090618215737.GF8515@gospo.rdu.redhat.com> <4A3ABA6C.9030604@intel.com> <20090619.002454.04323414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, andy@greyhouse.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36291 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbZFSPHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 11:07:39 -0400
Content-Disposition: inline
In-Reply-To: <20090619.002454.04323414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2009 at 12:24:54AM -0700, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Thu, 18 Jun 2009 15:06:36 -0700
> 
> > Andy Gospodarek wrote:
> >> The last hunk of this commit:
> >>     commit 12d04a3c12b420f23398b4d650127642469a60a6
> >>     Author: Alexander Duyck <alexander.h.duyck@intel.com>
> >>     Date:   Wed Mar 25 22:05:03 2009 +0000
> >>         e1000e: commonize tx cleanup routine to match e1000 & igb
> >> changed the logic for determining if we should call napi_complete or
> >> not at then end of a napi poll.
> >> If the NIC is using MSI-X with no work to do in ->poll, net_rx_action
> >> can just spin indefinitely on older kernels and for 2 jiffies on newer
> >> kernels since napi_complete is never called and budget isn't
> >> decremented.
> >> Discovered and verified while testing driver backport to an older
> >> kernel.
> >> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >> ---
> >>  netdev.c |    2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> >> index 677f604..679885a 100644
> >> --- a/drivers/net/e1000e/netdev.c
> >> +++ b/drivers/net/e1000e/netdev.c
> >> @@ -1997,7 +1997,7 @@ static int e1000_clean(struct napi_struct *napi,
> >> int budget)
> >>  	struct e1000_adapter *adapter = container_of(napi, struct
> >>  	e1000_adapter, napi);
> >>  	struct e1000_hw *hw = &adapter->hw;
> >>  	struct net_device *poll_dev = adapter->netdev;
> >> -	int tx_cleaned = 0, work_done = 0;
> >> +	int tx_cleaned = 1, work_done = 0;
> >>   	adapter = netdev_priv(poll_dev);
> >> 
> > This is most certainly a bug, and the fix is correct.  The logic for
> > tx_cleaned is supposed to default to true in the event that there are
> > no tx queues cleaned as part of the polling routine.
> > 
> > Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Applied, thanks.

Thanks, Dave.

I did some more testing with 2.6.30 and ksoftirqd uses 100% of the cpu
once the device is up.  With this patch it does not, so it should
probably go into 2.6.29-stable as well.

