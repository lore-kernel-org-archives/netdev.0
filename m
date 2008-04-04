From: Mandeep Singh Baines <msb@google.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Thu, 3 Apr 2008 18:41:30 -0700
Message-ID: <20080404014129.GA28593@google.com>
References: <20080403180021.GA5974@google.com> <1207267417.23161.353.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, matthew@wil.cx,
	davem@davemloft.net, nil@google.com, thockin@google.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:30872 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215AbYDDBm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 21:42:27 -0400
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m341gHlU022966
	for <netdev@vger.kernel.org>; Fri, 4 Apr 2008 02:42:18 +0100
Received: from an-out-0708.google.com (anac25.prod.google.com [10.100.54.25])
	by zps37.corp.google.com with ESMTP id m341gGTp000676
	for <netdev@vger.kernel.org>; Thu, 3 Apr 2008 18:42:16 -0700
Received: by an-out-0708.google.com with SMTP id c25so2405877ana.77
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2008 18:42:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1207267417.23161.353.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches (joe@perches.com) wrote:
> This looks better.
> There's a typo at line 315 though, it needs a ";".
> 

Oops. In my haste to get out the revised patch I didn't bother to test.
Bad Mandeep.

> I was also wrong that int ret _does_ need to be
> initialized to 0 in case (eeprom.len == 0)
> 

I knew I had that there for a reason. But I forgot to initialize ret in
ethtool_get_eeprom. You've fixed this in your update to the patch:)

> I think this should be written as below:
> 

Agreed. You've fixed my bugs and I think setting ret inside the if
makes the code easier to reason about.

I've tested your updated version of the patch and it looks good.

> cheers, Joe
> 
>  net/core/ethtool.c |   68 +++++++++++++++++++++++++++++-----------------------
>  1 files changed, 38 insertions(+), 30 deletions(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 1163eb2..a29b43d 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -284,8 +284,10 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
>  {
>  	struct ethtool_eeprom eeprom;
>  	const struct ethtool_ops *ops = dev->ethtool_ops;
> +	void __user *userbuf = useraddr + sizeof(eeprom);
> +	u32 bytes_remaining;
>  	u8 *data;
> -	int ret;
> +	int ret = 0;
>  
>  	if (!ops->get_eeprom || !ops->get_eeprom_len)
>  		return -EOPNOTSUPP;
> @@ -301,26 +303,26 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
>  	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
>  		return -EINVAL;
>  
> -	data = kmalloc(eeprom.len, GFP_USER);
> +	data = kmalloc(PAGE_SIZE, GFP_USER);
>  	if (!data)
>  		return -ENOMEM;
>  
> -	ret = -EFAULT;
> -	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
> -		goto out;
> -
> -	ret = ops->get_eeprom(dev, &eeprom, data);
> -	if (ret)
> -		goto out;
> +	bytes_remaining = eeprom.len;
> +	while (bytes_remaining > 0) {
> +		eeprom.len = min(bytes_remaining, (u32)PAGE_SIZE);
>  
> -	ret = -EFAULT;
> -	if (copy_to_user(useraddr, &eeprom, sizeof(eeprom)))
> -		goto out;
> -	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
> -		goto out;
> -	ret = 0;
> +		ret = ops->get_eeprom(dev, &eeprom, data);
> +		if (ret)
> +			break;
> +		if (copy_to_user(userbuf, data, eeprom.len)) {
> +			ret = -EFAULT;
> +			break;
> +		}
> +		userbuf += eeprom.len;
> +		eeprom.offset += eeprom.len;
> +		bytes_remaining -= eeprom.len;
> +	}
>  
> - out:
>  	kfree(data);
>  	return ret;
>  }
> @@ -329,8 +331,10 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
>  {
>  	struct ethtool_eeprom eeprom;
>  	const struct ethtool_ops *ops = dev->ethtool_ops;
> +	void __user *userbuf = useraddr + sizeof(eeprom);
> +	u32 bytes_remaining;
>  	u8 *data;
> -	int ret;
> +	int ret = 0;
>  
>  	if (!ops->set_eeprom || !ops->get_eeprom_len)
>  		return -EOPNOTSUPP;
> @@ -346,22 +350,26 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
>  	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
>  		return -EINVAL;
>  
> -	data = kmalloc(eeprom.len, GFP_USER);
> +	data = kmalloc(PAGE_SIZE, GFP_USER);
>  	if (!data)
>  		return -ENOMEM;
>  
> -	ret = -EFAULT;
> -	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
> -		goto out;
> -
> -	ret = ops->set_eeprom(dev, &eeprom, data);
> -	if (ret)
> -		goto out;
> +	bytes_remaining = eeprom.len;
> +	while (bytes_remaining > 0) {
> +		eeprom.len = min(bytes_remaining, (u32)PAGE_SIZE);
>  
> -	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
> -		ret = -EFAULT;
> +		if (copy_from_user(data, userbuf, eeprom.len)) {
> +			ret = -EFAULT;
> +			break;
> +		}
> +		ret = ops->set_eeprom(dev, &eeprom, data);
> +		if (ret)
> +			break;
> +		userbuf += eeprom.len;
> +		eeprom.offset += eeprom.len;
> +		bytes_remaining -= eeprom.len;
> +	}
>  
> - out:
>  	kfree(data);
>  	return ret;
>  }
> 
> 
