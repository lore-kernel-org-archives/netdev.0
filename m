From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/3] ethtool: Add generic options for
 tunables
Date: Thu, 21 Aug 2014 16:18:16 -0700 (PDT)
Message-ID: <20140821.161816.1372290442061854758.davem@davemloft.net>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>
	<1408008560-1067-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	stephen@networkplumber.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920AbaHUXSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 19:18:20 -0400
In-Reply-To: <1408008560-1067-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu, 14 Aug 2014 14:59:19 +0530

> @@ -1621,6 +1621,50 @@ static int ethtool_get_module_eeprom(struct net_device *dev,
>  				      modinfo.eeprom_len);
>  }
>  
> +static int ethtool_get_tunable(struct net_device *dev, void __user *useraddr)
> +{
> +	int ret;
> +	struct ethtool_tunable tuna;
> +	const struct ethtool_tunable_ops *ops;
> +
> +	if (copy_from_user(&tuna, useraddr, sizeof(tuna)))
> +		return -EFAULT;
> +	if (tuna.tcmd >= ETHTOOL_TUNABLE_MAX)
> +		return -EOPNOTSUPP;
> +	ops = &dev->ethtool_ops->tunable_ops[tuna.tcmd];
> +	if (!ops->get)
> +		return -EOPNOTSUPP;
> +	ret = ops->get(dev, &tuna);
> +	if (ret)
> +		return ret;
> +	if (copy_to_user(useraddr, &tuna, sizeof(tuna)))
> +		return -EFAULT;
> +
> +	return 0;
> +}

You should be validating tuna.len here, it should not be happening in the drivers
as I see you are doing in your enic implementation.

Also, having a seperate OP for each tunable might be overkill.
Consider instead one "get_tunable" and one "set_tunable" callback,
which contains a switch statement over 'tcmd'.  The generic
ethtool_{g,s}et_tunable() would still validate the length, so that the
driver method does not need to do so.
