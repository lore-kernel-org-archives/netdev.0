From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to
 stalled CPU task )
Date: Thu, 23 Aug 2012 09:12:31 +0000 (UTC)
Message-ID: <k14s5v$7bs$2@ger.gmane.org>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
 <1345634026.5158.1084.camel@edumazet-glaptop>
 <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
 <1345640757.5158.1321.camel@edumazet-glaptop>
 <CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
 <k14noo$lfj$1@ger.gmane.org> <k14poh$7bs$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60075 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899Ab2HWJMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:12:50 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1T4TT6-00067P-Qf
	for netdev@vger.kernel.org; Thu, 23 Aug 2012 11:12:48 +0200
Received: from 112.132.201.16 ([112.132.201.16])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 11:12:48 +0200
Received: from xiyou.wangcong by 112.132.201.16 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 11:12:48 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 at 08:31 GMT, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, 23 Aug 2012 at 07:57 GMT, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, 22 Aug 2012 at 14:29 GMT, Sylvain Munaut <s.munaut@whatever-company.com> wrote:
>>> Hi,
>>>
>>>
>>> The machine with the intel card still hard freeze (no output / no nothing ...)
>>> The machine with the bnx2 don't crash anymore and no NULL deref, but
>>> the modprobe still hangs and I get this every 180 sec or so :
>>
>> The NULL-deref can be reproduced easily, and Eric's patch could fix it.
>> So, Eric, can you resend your patch with your SOB?
>>
>> I can't reproduce the hang as it is net driver specific, it is
>> probably related with my patch:
>>
>> commit 6bdb7fe31046ac50b47e83c35cd6c6b6160a475d
>> Author: Amerigo Wang <amwang@redhat.com>
>> Date:   Fri Aug 10 01:24:50 2012 +0000
>>
>>     netpoll: re-enable irq in poll_napi()
>>
>
> Could you test the following patch?
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index ddc453b..ed4d1e4 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -166,11 +166,18 @@ static int poll_one_napi(struct netpoll_info *npinfo,
>  static void poll_napi(struct net_device *dev)
>  {
>  	struct napi_struct *napi;
> +	LIST_HEAD(napi_list);
>  	int budget = 16;
>  
>  	WARN_ON_ONCE(!irqs_disabled());
>  
> -	list_for_each_entry(napi, &dev->napi_list, dev_list) {
> +	/* After we enable the IRQ, new entries could be added
> +	 * to this list, we need to save it before re-enable
> +	 * IRQ.
> +	 */
> +	list_splice_tail(&dev->napi_list, &napi_list);
> +

This one should be list_splice_init()...


> +	list_for_each_entry(napi, &napi_list, dev_list) {
>  		local_irq_enable();
>  		if (napi->poll_owner != smp_processor_id() &&
>  		    spin_trylock(&napi->poll_lock)) {
> @@ -187,6 +194,7 @@ static void poll_napi(struct net_device *dev)
>  		}
>  		local_irq_disable();
>  	}
> +	list_splice_tail(&napi_list, &dev->napi_list);
>  }
>  
>  static void service_arp_queue(struct netpoll_info *npi)
>
>
>
>
> However, it seems we should take rtnl lock to make sure dev->napi_list
> is really safe, I am not sure if the following one makes sense.
>
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index ddc453b..7770e2b 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -170,8 +170,9 @@ static void poll_napi(struct net_device *dev)
>  
>  	WARN_ON_ONCE(!irqs_disabled());
>  
> +	local_irq_enable();
> +	rtnl_lock();
>  	list_for_each_entry(napi, &dev->napi_list, dev_list) {
> -		local_irq_enable();
>  		if (napi->poll_owner != smp_processor_id() &&
>  		    spin_trylock(&napi->poll_lock)) {
>  			rcu_read_lock_bh();
> @@ -180,13 +181,12 @@ static void poll_napi(struct net_device *dev)
>  			rcu_read_unlock_bh();
>  			spin_unlock(&napi->poll_lock);
>  
> -			if (!budget) {
> -				local_irq_disable();
> +			if (!budget)
>  				break;
> -			}
>  		}
> -		local_irq_disable();
>  	}
> +	rtnl_unlock();
> +	local_irq_disable();
>  }
>  
>  static void service_arp_queue(struct netpoll_info *npi)
>
