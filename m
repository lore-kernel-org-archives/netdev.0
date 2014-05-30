From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] cnic: don't take the rtnl_read_lock in
 cnic_rcv_netevent
Date: Fri, 30 May 2014 10:58:11 -0700
Message-ID: <1401472691.9728.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1401462019-7958-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<fcoe-devel@open-fcoe.org>, Robert Love <robert.w.love@intel.com>,
	Vasu Dev <vasu.dev@intel.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:3456 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbaE3R6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 13:58:12 -0400
In-Reply-To: <1401462019-7958-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 11:00 -0400, Neil Horman wrote: 
> The Cnic driver handles lots of ulp operations in its netdevice event hanlder.
> To do this, it accesses the ulp_ops array, which is an rcu protected array.
> However, some ulp operations (like bnx2fc_indicate_netevent) try to lock
> mutexes, which might sleep (somthing that you can't do while holding rcu read
> side locks if you've configured non-preemptive rcu.
> 
> Fix this by changing the dereference method.  All accesses to the ulp_ops array
> for a cnic dev are modified under the protection of the rtnl lock, and so we can
> safely just use rcu_dereference_rtnl, and remove the rcu_read_lock here

Because the bnx2fc function can sleep, we need a more complete fix to
prevent the ulp_ops from going away when the device is unregistered.
synchronize_rcu() won't be able to protect it.  I'll post the patch
later today.  Thanks.

> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Michael Chan <mchan@broadcom.com>
> CC: fcoe-devel@open-fcoe.org
> CC: Robert Love <robert.w.love@intel.com>
> CC: Vasu Dev <vasu.dev@intel.com>
> ---
>  drivers/net/ethernet/broadcom/cnic.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
> index f58a8b8..bfdb9f0 100644
> --- a/drivers/net/ethernet/broadcom/cnic.c
> +++ b/drivers/net/ethernet/broadcom/cnic.c
> @@ -5622,12 +5622,11 @@ static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
>  {
>  	int if_type;
>  
> -	rcu_read_lock();
>  	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
>  		struct cnic_ulp_ops *ulp_ops;
>  		void *ctx;
>  
> -		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
> +		ulp_ops = rcu_dereference_rtnl(cp->ulp_ops[if_type]);
>  		if (!ulp_ops || !ulp_ops->indicate_netevent)
>  			continue;
>  
> @@ -5635,7 +5634,6 @@ static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
>  
>  		ulp_ops->indicate_netevent(ctx, event, vlan_id);
>  	}
> -	rcu_read_unlock();
>  }
>  
>  /* netdev event handler */
