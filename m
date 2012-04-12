From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: Re: [RFC PATCH 1/2] net: ethtool: Add capability to retrieve plug-in
 module EEPROM
Date: Thu, 12 Apr 2012 10:18:40 +0100
Message-ID: <4F869DF0.1000709@solarflare.com>
References: <4F71FE0A.3060203@solarflare.com>  <1333389160.2623.30.camel@bwh-desktop.uk.solarflarecom.com>  <4F85B639.5090900@solarflare.com>  <1334168217.2552.5.camel@bwh-desktop.uk.solarflarecom.com> <1334187728.2552.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bruce.w.allan@intel.com>,
	<mirq-linux@rere.qmqm.pl>, <decot@google.com>,
	<amit.salecha@qlogic.com>, <alexander.h.duyck@intel.com>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16313 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1762255Ab2DLJSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 05:18:44 -0400
In-Reply-To: <1334187728.2552.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/12 00:42, Ben Hutchings wrote:
> On Wed, 2012-04-11 at 19:16 +0100, Ben Hutchings wrote:
>> On Wed, 2012-04-11 at 17:50 +0100, Stuart Hodgson wrote:
>>> On 02/04/12 18:52, Ben Hutchings wrote:
>> [...]
>>>>> --- a/net/core/ethtool.c
>>>>> +++ b/net/core/ethtool.c
>> [...]
>>>>> +    if (eeprom.offset + eeprom.len>   modinfo.eeprom_len)
>>>>> +        return -EINVAL;
>>>>> +
>>>>> +    data = kmalloc(PAGE_SIZE, GFP_USER);
>>>>> +    if (!data)
>>>>> +        return -ENOMEM;
>>>>
>>>> What if some device has a larger EEPROM?  Surely this length should be
>>>> eeprom.len.
>>>>
>>>
>>> Do you mean what if the eeprom length in te device is larger than
>>> PAGE_SIZE?
>>
>> Yes.
>>
>>> If so then it should really use modinfo.eeprom_len since
>>> this the size of the data. eeprom.len could be arbitary.
>>
>> No, eeprom.len is the size of the data and we've already validated it at
>> this point.
>
> Maybe we should start by refactoring ethtool_get_eeprom() so we can
> reuse most of its code in ethtool_get_module_eeprom(), rather than
> having to worry about what the maximum size of a module EEPROM might be
> and whether we need a loop:
>
> Subject: ethtool: Split ethtool_get_eeprom() to allow for additional EEPROM accessors
>
> We want to support reading module (SFP+, XFP, ...) EEPROMs as well as
> NIC EEPROMs.  They will need a different command number and driver
> operation, but the structure and arguments will be the same and so we
> can share most of the code here.
>
> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
> ---
>   net/core/ethtool.c |   24 +++++++++++++++++-------
>   1 files changed, 17 insertions(+), 7 deletions(-)
>
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index beacdd9..ca7698f 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -751,18 +751,17 @@ static int ethtool_get_link(struct net_device *dev, char __user *useraddr)
>   	return 0;
>   }
>
> -static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
> +static int ethtool_get_any_eeprom(struct net_device *dev, void __user *useraddr,
> +				  int (*getter)(struct net_device *,
> +						struct ethtool_eeprom *, u8 *),
> +				  u32 total_len)
>   {
>   	struct ethtool_eeprom eeprom;
> -	const struct ethtool_ops *ops = dev->ethtool_ops;
>   	void __user *userbuf = useraddr + sizeof(eeprom);
>   	u32 bytes_remaining;
>   	u8 *data;
>   	int ret = 0;
>
> -	if (!ops->get_eeprom || !ops->get_eeprom_len)
> -		return -EOPNOTSUPP;
> -
>   	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
>   		return -EFAULT;
>
> @@ -771,7 +770,7 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
>   		return -EINVAL;
>
>   	/* Check for exceeding total eeprom len */
> -	if (eeprom.offset + eeprom.len>  ops->get_eeprom_len(dev))
> +	if (eeprom.offset + eeprom.len>  total_len)
>   		return -EINVAL;
>
>   	data = kmalloc(PAGE_SIZE, GFP_USER);

Should this not be eeprom.len?

> @@ -782,7 +781,7 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
>   	while (bytes_remaining>  0) {
>   		eeprom.len = min(bytes_remaining, (u32)PAGE_SIZE);
>
> -		ret = ops->get_eeprom(dev,&eeprom, data);
> +		ret = getter(dev,&eeprom, data);
>   		if (ret)
>   			break;
>   		if (copy_to_user(userbuf, data, eeprom.len)) {
> @@ -803,6 +802,17 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
>   	return ret;
>   }
>
> +static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
> +{
> +	const struct ethtool_ops *ops = dev->ethtool_ops;
> +
> +	if (!ops->get_eeprom || !ops->get_eeprom_len)
> +		return -EOPNOTSUPP;
> +
> +	return ethtool_get_any_eeprom(dev, useraddr, ops->get_eeprom,
> +				      ops->get_eeprom_len(dev));
> +}
> +
>   static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
>   {
>   	struct ethtool_eeprom eeprom;

This would reduce the code size nicely between the two eeprom fetches.

Stu
