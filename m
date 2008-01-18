From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Fri, 18 Jan 2008 23:27:18 +0100
Message-ID: <479127C6.1080701@gmail.com>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com> <20080116133646.GE2307@ff.dom.local> <478EE7FC.4040301@miraclelinux.com> <20080117111822.GB1710@ff.dom.local> <4790ACF2.1090207@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:10803 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761214AbYARWXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 17:23:37 -0500
Received: by ug-out-1314.google.com with SMTP id z38so538665ugc.16
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 14:23:36 -0800 (PST)
In-Reply-To: <4790ACF2.1090207@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makito SHIOKAWA wrote, On 01/18/2008 02:43 PM:

>> Hmm... I'm not sure I understand your point, but it seems both
>> bonding_store_arp_interval() and bonding_store_miimon() where this
>> field could be changed, currently use cancel_delayed_work() with
>> flush_workqueue(), so I presume, there is no rtnl_lock() nor
>> write_lock(&bond->lock) held, so cancel_delayed_work_sync() could
>> be used, which doesn't require this additional check.
> I see. I rewrited the patch as below. How about this?
> (But, it may be just a matter to change 'if (new_value < 0)' to 'if (new_value
> <= 0)' in bonding_store_miimon() and bonding_store_arp_interval()...)


Yes, looks fine to me.

(But new_value = 0 seems needed - just like from module_param()?)

Maybe only a few slight doubts, yet:
- maybe before this cancel IFF_UP test would be useful as well,
- maybe to test if the value has changed at all,
- maybe it's OK, I don't know, but it seems both monitors could be
  turned off now.

Thanks,
Jarek P.

> 
> ---
>   drivers/net/bonding/bond_sysfs.c |    4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> 
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -997,6 +997,8 @@ static ssize_t bonding_store_miimon(stru
>   		       ": %s: Setting MII monitoring interval to %d.\n",
>   		       bond->dev->name, new_value);
>   		bond->params.miimon = new_value;
> +		if (bond->params.miimon == 0)
> +			cancel_delayed_work_sync(&bond->mii_work);
>   		if(bond->params.updelay)
>   			printk(KERN_INFO DRV_NAME
>   			      ": %s: Note: Updating updelay (to %d) "
> @@ -1026,7 +1028,7 @@ static ssize_t bonding_store_miimon(stru
>   				cancel_delayed_work_sync(&bond->lb_arp_work);
>   		}
> 
> -		if (bond->dev->flags & IFF_UP) {
> +		if (bond->params.miimon && (bond->dev->flags & IFF_UP)) {
>   			/* If the interface is up, we may need to fire off
>   			 * the MII timer. If the interface is down, the
>   			 * timer will get fired off when the open function
> 
> 


