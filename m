From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] switchdev: fix stp update API to work with
 layered netdevices
Date: Mon, 16 Mar 2015 08:47:15 -0700
Message-ID: <5506FB03.1010108@cumulusnetworks.com>
References: <1426518099-3203-1-git-send-email-roopa@cumulusnetworks.com> <20150316154210.GC2058@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34198 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932939AbbCPPrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 11:47:18 -0400
Received: by pacwe9 with SMTP id we9so68294762pac.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 08:47:18 -0700 (PDT)
In-Reply-To: <20150316154210.GC2058@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15, 8:42 AM, Jiri Pirko wrote:
> Mon, Mar 16, 2015 at 04:01:39PM CET, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> make it same as the netdev_switch_port_bridge_setlink/dellink
>> api (ie traverse lowerdevs to get to the switch port).
>>
>> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
>> direct bridge ports can be stacked netdevices (like bonds
>> and team of switch ports) which may not imeplement this ndo.
>>
>> v2 to v3:
>> 	- remove changes to bond and team. Bring back the
>> 	transparently following lowerdevs like i initially
>> 	had for setlink/getlink
>> 	(http://www.spinics.net/lists/netdev/msg313436.html)
>> 	dave and scott feldman also seem to prefer it be that
>> 	way and move to non-transparent way of doing things
>> 	if we see a problem down the lane.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> net/switchdev/switchdev.c |   20 ++++++++++++++++----
>> 1 file changed, 16 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index c9bfa00..5c53951 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -47,11 +47,23 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
>> int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>> {
>> 	const struct swdev_ops *ops = dev->swdev_ops;
>> +	struct net_device *lower_dev;
>> +	struct list_head *iter;
>> +	int ret = 0, err = -EOPNOTSUPP;
> 	No need to initialize err.

ack, i wanted to initialize ret there actually.
>
>> -	if (!ops || !ops->swdev_port_stp_update)
>> -		return -EOPNOTSUPP;
>> -	WARN_ON(!ops->swdev_parent_id_get);
>> -	return ops->swdev_port_stp_update(dev, state);
>> +	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
>> +		return ret;
> 		Just flat "0" might be nicer here.
>
>> +
>> +	if (ops && ops->swdev_port_stp_update)
>> +		return ops->swdev_port_stp_update(dev, state);
>> +
>> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>> +		err = netdev_switch_port_stp_update(lower_dev, state);
>> +		if (err && err != -EOPNOTSUPP)
>> +			ret = err;
>> +	}
>> +
>> +	return ret;
>
> Do we want to return 0 in case no lower dev is there? -EOPNOTSUPP seems
> to make more sense to me in that case.

yes, that was not intentional. I will fix the ret initialization like i 
intended and that
should take care of it.

thanks for the review.
