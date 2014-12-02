From: Eyal Perry <eyalpe@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 1/2] ethtool: Support for configurable RSS
 hash function
Date: Tue, 02 Dec 2014 17:21:29 +0200
Message-ID: <547DD8F9.8030403@dev.mellanox.co.il>
References: <1417530049-6943-1-git-send-email-amirv@mellanox.com> <1417530049-6943-2-git-send-email-amirv@mellanox.com> <547DD74C.9070603@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
To: Edward Cree <ecree@solarflare.com>, Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:34746 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbaLBPVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 10:21:33 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so17294469wgh.37
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 07:21:31 -0800 (PST)
In-Reply-To: <547DD74C.9070603@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/2/2014 17:14 PM, Edward Cree wrote:
> On 02/12/14 14:20, Amir Vadai wrote:
>> diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
>> index cad258a..2ac07c9 100644
>> --- a/drivers/net/ethernet/sfc/ethtool.c
>> +++ b/drivers/net/ethernet/sfc/ethtool.c
>> @@ -1086,19 +1086,29 @@ static u32 efx_ethtool_get_rxfh_indir_size(struct net_device *net_dev)
>>  		0 : ARRAY_SIZE(efx->rx_indir_table));
>>  }
>>  
>> -static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key)
>> +static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key,
>> +				u8 *hfunc)
>>  {
>>  	struct efx_nic *efx = netdev_priv(net_dev);
>>  
>> -	memcpy(indir, efx->rx_indir_table, sizeof(efx->rx_indir_table));
>> +	if (hfunc)
>> +		*hfunc = ETH_RSS_HASH_UNKNOWN;
> This should be ETH_RSS_HASH_TOP, especially as that's what you test
> against in the _set_ function below.
> (I don't know if we responded to your query.  If not, I can confirm
> we're using Toeplitz.)
Sending V3...
>> +	if (indir)
>> +		memcpy(indir, efx->rx_indir_table, sizeof(efx->rx_indir_table));
>>  	return 0;
>>  }
>>  
>> -static int efx_ethtool_set_rxfh(struct net_device *net_dev,
>> -				const u32 *indir, const u8 *key)
>> +static int efx_ethtool_set_rxfh(struct net_device *net_dev, const u32 *indir,
>> +				const u8 *key, const u8 hfunc)
>>  {
>>  	struct efx_nic *efx = netdev_priv(net_dev);
>>  
>> +	/* We do not allow change in unsupported parameters */
>> +	if (key ||
>> +	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
>> +		return -EOPNOTSUPP;
>> +	if (!indir)
>> +		return 0;
>>  	memcpy(efx->rx_indir_table, indir, sizeof(efx->rx_indir_table));
>>  	efx->type->rx_push_rss_config(efx);
>>  	return 0;
> -Edward
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
