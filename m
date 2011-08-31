From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: allow notifier subscribers to forbid
 device from closing
Date: Wed, 31 Aug 2011 18:21:48 +0200
Message-ID: <20110831162147.GA2051@minipsycho.redhat.com>
References: <1314803731-1222-1-git-send-email-jpirko@redhat.com>
 <1314804352.2741.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab1HaQVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 12:21:54 -0400
Content-Disposition: inline
In-Reply-To: <1314804352.2741.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 31, 2011 at 05:25:51PM CEST, bhutchings@solarflare.com wrote:
>On Wed, 2011-08-31 at 17:15 +0200, Jiri Pirko wrote:
>> In some situations, like when the device is used as slave device in
>> bond/br/etc it is not nice if someone closes the device. This allows
>> it's masters to forbid this closure.
>
>No it doesn't.
It does

>
>[...]
>> @@ -1269,9 +1282,12 @@ static int dev_close_many(struct list_head *head)
>>  	struct net_device *dev, *tmp;
>>  	LIST_HEAD(tmp_list);
>>  
>> -	list_for_each_entry_safe(dev, tmp, head, unreg_list)
>> +	list_for_each_entry_safe(dev, tmp, head, unreg_list) {
>>  		if (!(dev->flags & IFF_UP))
>>  			list_move(&dev->unreg_list, &tmp_list);
>> +		else
>> +			__dev_pre_close(dev);
>> +	}
>>  
>>  	__dev_close_many(head);
>
>The return value is ignored here.

That's intended. The reason is this is called from
rollback_registered_many - refuse should be ignored in that case
>
>And this is called from dev_close(), where you are adding the
>notification as well.  So the notifier will usually be called twice.
>
Indeed. Anyway I thought about it and we probably do not need this patch
as Stephen said.

>[...]
>> @@ -1397,6 +1418,7 @@ rollback:
>>  				break;
>>  
>>  			if (dev->flags & IFF_UP) {
>> +				nb->notifier_call(nb, NETDEV_PRE_DOWN, dev);
>>  				nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
>>  				nb->notifier_call(nb, NETDEV_DOWN, dev);
>>  			}
>[...]
>
>The return value has to be ignored here.  Not sure it makes any sense to
>call the notifier at all.
>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
