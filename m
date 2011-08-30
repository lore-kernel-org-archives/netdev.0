From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Tue, 30 Aug 2011 17:19:26 +0200
Message-ID: <20110830151926.GC1972@minipsycho.brq.redhat.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
 <1314715608-978-2-git-send-email-jpirko@redhat.com>
 <1314717262.2752.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755072Ab1H3PTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 11:19:31 -0400
Content-Disposition: inline
In-Reply-To: <1314717262.2752.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 30, 2011 at 05:14:22PM CEST, bhutchings@solarflare.com wrote:
>On Tue, 2011-08-30 at 16:46 +0200, Jiri Pirko wrote:
>> Allow to write to "carrier" attribute. Devices may implement ndo_change_carrier
>> callback to allow changing carrier from userspace.
>[...]
>> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>> index 56e42ab..c8f2ca4 100644
>> --- a/net/core/net-sysfs.c
>> +++ b/net/core/net-sysfs.c
>> @@ -126,6 +126,30 @@ static ssize_t show_broadcast(struct device *dev,
>>  	return -EINVAL;
>>  }
>>  
>> +static ssize_t store_carrier(struct device *dev, struct device_attribute *attr,
>> +			     const char *buf, size_t len)
>> +{
>> +	struct net_device *netdev = to_net_dev(dev);
>> +	ssize_t ret;
>> +	int new_value;
>> +
>> +	if (!capable(CAP_NET_ADMIN))
>> +		return -EPERM;
>> +
>> +	if (!netif_running(netdev))
>> +		return -EINVAL;
>
>Not sure that's the right error code.

I stayed consistent with show_carrier in this.

>
>> +	if (sscanf(buf, "%d", &new_value) != 1)
>> +		return -EINVAL;
>
>kstrtoint()

Okay.

>
>(Or maybe we should have kstrobool().)
>
>> +	if (!rtnl_trylock())
>> +		return restart_syscall();
>[...]
>
>This is consistent with other attributes, but it seems like a really bad
>practice as it will generally result in the process busy-waiting on the
>RTNL lock!  I think it would be better to add and use an
>rtnl_lock_interruptible().

Right. But as you said, this is the same as with others. I would replace
this in another patch.

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
