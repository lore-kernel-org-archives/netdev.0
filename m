From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net 1/2] vlan: make vlan_dev_real_dev work over stacked
 vlans
Date: Mon, 5 Aug 2013 08:58:55 +0200
Message-ID: <20130805065855.GF22756@redhat.com>
References: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
 <51FDB9C7.4090703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	jhs@mojatatu.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742Ab3HEHAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 03:00:49 -0400
Content-Disposition: inline
In-Reply-To: <51FDB9C7.4090703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 04, 2013 at 04:17:43AM +0200, Nikolay Aleksandrov wrote:
>On 08/03/2013 10:07 PM, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>>
>> Sometimes we might have stacked vlans on top of each other, and we're
>> interested in the first non-vlan real device on the path, so transform
>> vlan_dev_real_dev to go over the stacked vlans and extract the first
>> non-vlan device.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
>>  net/8021q/vlan_core.c | 7 ++++++-
>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> index 4a78c4d..6ee48aa 100644
>> --- a/net/8021q/vlan_core.c
>> +++ b/net/8021q/vlan_core.c
>> @@ -91,7 +91,12 @@ EXPORT_SYMBOL(__vlan_find_dev_deep);
>>
>>  struct net_device *vlan_dev_real_dev(const struct net_device *dev)
>>  {
>> -	return vlan_dev_priv(dev)->real_dev;
>> +	struct net_device *ret = vlan_dev_priv(dev)->real_dev;
>> +
>> +	while (is_vlan_dev(ret))
>> +		ret = vlan_dev_priv(ret)->real_dev;
>> +
>> +	return ret;
>>  }
>>  EXPORT_SYMBOL(vlan_dev_real_dev);
>>
>>
>I have one question - why not make it possible to call vlan_dev_real_dev()
>with any device (vlan/non-vlan) and make it return a real device in all
>cases (e.g. if it's a non-vlan device simply return it) ?
>In the terms of the code above - simply change:
>struct net_device *ret = vlan_dev_priv(dev)->real_dev;
>with
>struct net_device *ret = dev;
>
>This way we'll be able to simplify calls like if (is_vlan_dev(dev)) (or the
>flag check alternative of this) to just vlan_dev_real_dev(). The old call
>sites of this function will still work properly.

I think it'll be a bit harder to understand the callers' code. Now it
always has the logic "wait, we might be having a vlan here, so lets verify
if it's really a vlan and if yes - get the real device". However with this
approach it might look like "we *really* have a vlan here - so lets get the
real device" (because of the function name - vlan_dev_real_dev) - which is
wrong. And it doesn't really provide any speed/size improvements - so it's
kind of useless.

So, unless a better function name can be found (which I can't come up with
- dev_or_strip_vlan()? dev_devlanitize()? :) ) - I'd stay with the current
  version. Though, again, I don't have a strong opinion on this.

>
>Nik
