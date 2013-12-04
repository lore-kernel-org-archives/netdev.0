From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] macvlan: Support creating macvtaps from macvlans
Date: Wed, 04 Dec 2013 08:59:21 -0500
Message-ID: <529F3539.2070305@gmail.com>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net> <1386068122-12039-1-git-send-email-kevin@pentabarf.net> <529E0421.2090504@gmail.com> <20131203194707.GA32367@lion.mk-sys.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kevin Wallace <kevin@pentabarf.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:63890 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab3LDN7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 08:59:25 -0500
Received: by mail-yh0-f50.google.com with SMTP id b6so11194959yha.23
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 05:59:24 -0800 (PST)
In-Reply-To: <20131203194707.GA32367@lion.mk-sys.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2013 02:47 PM, Michal Kubecek wrote:
> On Tue, Dec 03, 2013 at 11:17:37AM -0500, Vlad Yasevich wrote:
>>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>>> index acf9379..cfb9157 100644
>>> --- a/drivers/net/macvlan.c
>>> +++ b/drivers/net/macvlan.c
>>> @@ -820,13 +820,11 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>>>  	if (lowerdev == NULL)
>>>  		return -ENODEV;
>>>  
>>> -	/* When creating macvlans on top of other macvlans - use
>>> +	/* When creating macvlans or macvtaps on top of other macvlans - use
>>>  	 * the real device as the lowerdev.
>>>  	 */
>>> -	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
>>> -		struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
>>> -		lowerdev = lowervlan->lowerdev;
>>> -	}
>>> +	if (netif_is_macvlan(lowerdev))
>>> +		lowerdev = macvlan_dev_real_dev(lowerdev);
>>>  
>>>  	if (!tb[IFLA_MTU])
>>>  		dev->mtu = lowerdev->mtu;
>>>
>>
>> the other question is should this be done in a loop?  What happens if
>> you have nested namespaces?
> 
> Nested namespaces are not a problem, what would be a problem, would be
> having a macvlan (macvtap) device on top of another macvlan. But the
> purpose of this particular code is to prevent it and use the underlying
> "real" device instead. That's why unlike vlan_dev_real_dev(),
> macvlan_dev_real_dev() doesn't need to recurse.
> 
>                                                          Michal Kubecek
> 

Wait,  so you have a namespace that uses macvlan to access the net.
That macvlan is configured on top of another macvlan, so you need to
get to the lower level device.  I understand that.  What I am asking
is that what happens if you have a namespace within a namespace with
the same network access restrictions.  The code as is, will think that
the first level macvlan is the real device.  Is this setup practical...

The reason I ask is that there is nothing preventing it, and it would
break just the same as your setup did.

-vlad
