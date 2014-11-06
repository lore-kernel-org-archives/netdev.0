From: Eyal perry <eyalpe@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/2] ethtool: Support for configurable RSS hash
 function
Date: Thu, 06 Nov 2014 11:41:43 +0200
Message-ID: <545B4257.8000001@dev.mellanox.co.il>
References: <1415188769-19593-1-git-send-email-amirv@mellanox.com>	 <1415188769-19593-2-git-send-email-amirv@mellanox.com> <1415224298.3398.27.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:51776 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbaKFJls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:41:48 -0500
Received: by mail-wg0-f43.google.com with SMTP id y10so720079wgg.16
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:41:47 -0800 (PST)
In-Reply-To: <1415224298.3398.27.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/5/2014 11:51 PM, Ben Hutchings wrote:
> On Wed, 2014-11-05 at 13:59 +0200, Amir Vadai wrote:
>> From: Eyal Perry <eyalpe@mellanox.com>
>>
>> This patch adds an RSS hash functions string-set, and two
>> ethtool-options for set/get current RSS hash function. User-kernel API is done
>> through the new hfunc mask field in the ethtool_rxfh struct. A bit set
>> in the hfunc is corresponding to an index in the string-set.
>>
>> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  include/linux/ethtool.h      | 28 ++++++++++++++++++++++++
>>  include/uapi/linux/ethtool.h |  6 ++++-
>>  net/core/ethtool.c           | 52 ++++++++++++++++++++++++++++++--------------
>>  3 files changed, 69 insertions(+), 17 deletions(-)
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index c1a2d60..61003b1 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -59,6 +59,29 @@ enum ethtool_phys_id_state {
>>  	ETHTOOL_ID_OFF
>>  };
>>  
>> +enum {
>> +	RSS_HASH_TOP_BIT, /* Configurable RSS hash function - Toeplitz */
>> +	RSS_HASH_XOR_BIT, /* Configurable RSS hash function - Xor */
>> +
>> +	/*
>> +	 * Add your fresh new hash function bits above and remember to update
>> +	 * rss_hash_func_strings[] below
>> +	 */
>> +	RSS_HASH_FUNCS_COUNT
>> +};
>> +
>> +#define __RSS_HASH_BIT(bit)	((u32)1 << (bit))
>> +#define __RSS_HASH(name)	 __RSS_HASH_BIT(RSS_HASH_##name##_BIT)
>> +
>> +#define RSS_HASH_TOP		__RSS_HASH(TOP)
>> +#define RSS_HASH_XOR		__RSS_HASH(XOR)
> 
> I think #define RSS_HASH_UNKNOWN 0 might also be useful.
> 
> And I think all of these names should get an ETH_ prefix.
> 
I'll add it in V1.
>> +static const char
>> +rss_hash_func_strings[RSS_HASH_FUNCS_COUNT][ETH_GSTRING_LEN] = {
>> +	[RSS_HASH_TOP_BIT] =     "toeplitz",
>> +	[RSS_HASH_XOR_BIT] =     "xor",
>> +};
> 
> This belongs in net/core/ethtool.c.
> 
I agree, will be fixed in V1.
>>  struct net_device;
>>  
>>  /* Some generic methods drivers may use in their ethtool_ops */
>> @@ -158,6 +181,9 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
>>   *	Returns zero if not supported for this specific device.
>>   * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
>>   *	Returns zero if not supported for this specific device.
>> + * @get_rxfh_func: Get the hardware RX flow hash function.
>> + * @set_rxfh_func: Set the hardware RX flow hash function. Returns a negative
>> + *	error code or zero.
>>   * @get_rxfh: Get the contents of the RX flow hash indirection table and hash
>>   *	key.
>>   *	Will only be called if one or both of @get_rxfh_indir_size and
>> @@ -241,6 +267,8 @@ struct ethtool_ops {
>>  	int	(*reset)(struct net_device *, u32 *);
>>  	u32	(*get_rxfh_key_size)(struct net_device *);
>>  	u32	(*get_rxfh_indir_size)(struct net_device *);
>> +	u32	(*get_rxfh_func)(struct net_device *);
>> +	int	(*set_rxfh_func)(struct net_device *, u32);
> 
> Why not another parameter to get_rxfh/set_rxfh?  I know it's a pain to
> update all the implementations, but changing algorithm potentially
> changes the supported indirection table and key lengths.  They have to
> be validated together.
> 
OK, I'll do it for V1.
>>  	int	(*get_rxfh)(struct net_device *, u32 *indir, u8 *key);
>>  	int	(*set_rxfh)(struct net_device *, const u32 *indir,
>>  			    const u8 *key);
>> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
>> index eb2095b..eb91da4 100644
>> --- a/include/uapi/linux/ethtool.h
>> +++ b/include/uapi/linux/ethtool.h
>> @@ -534,6 +534,7 @@ struct ethtool_pauseparam {
>>   * @ETH_SS_NTUPLE_FILTERS: Previously used with %ETHTOOL_GRXNTUPLE;
>>   *	now deprecated
>>   * @ETH_SS_FEATURES: Device feature names
>> + * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
>>   */
>>  enum ethtool_stringset {
>>  	ETH_SS_TEST		= 0,
>> @@ -541,6 +542,7 @@ enum ethtool_stringset {
>>  	ETH_SS_PRIV_FLAGS,
>>  	ETH_SS_NTUPLE_FILTERS,
>>  	ETH_SS_FEATURES,
>> +	ETH_SS_RSS_HASH_FUNCS,
>>  };
>>  
>>  /**
>> @@ -900,7 +902,9 @@ struct ethtool_rxfh {
>>  	__u32	rss_context;
>>  	__u32   indir_size;
>>  	__u32   key_size;
>> -	__u32	rsvd[2];
>> +	__u8	hfunc;
> 
> Missing kernel-doc.  This needs to be very clear about what the valid
> values are.
> 
I'll add it in V1.
>> +	__u8	rsvd8[3];
>> +	__u32	rsvd32;
>>  	__u32   rss_config[0];
>>  };
>>  #define ETH_RXFH_INDIR_NO_CHANGE	0xffffffff
>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>> index 06dfb29..4791c17 100644
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>> @@ -185,6 +185,9 @@ static int __ethtool_get_sset_count(struct net_device *dev, int sset)
>>  	if (sset == ETH_SS_FEATURES)
>>  		return ARRAY_SIZE(netdev_features_strings);
>>  
>> +	if (sset == ETH_SS_RSS_HASH_FUNCS)
>> +		return ARRAY_SIZE(rss_hash_func_strings);
>> +
>>  	if (ops->get_sset_count && ops->get_strings)
>>  		return ops->get_sset_count(dev, sset);
>>  	else
> [...]
>> @@ -760,32 +769,43 @@ static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
>>  	const struct ethtool_ops *ops = dev->ethtool_ops;
>>  	struct ethtool_rxnfc rx_rings;
>>  	struct ethtool_rxfh rxfh;
>> -	u32 dev_indir_size = 0, dev_key_size = 0, i;
>> +	u32 dev_indir_size = 0, dev_key_size = 0, dev_hfunc = 0, i;
>>  	u32 *indir = NULL, indir_bytes = 0;
>>  	u8 *hkey = NULL;
>>  	u8 *rss_config;
>>  	u32 rss_cfg_offset = offsetof(struct ethtool_rxfh, rss_config[0]);
>>  
>> -	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size) ||
>> -	    !ops->get_rxnfc || !ops->set_rxfh)
>> +	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size ||
>> +	      ops->get_rxfh_func) || !ops->get_rxnfc || !ops->set_rxfh)
>>  		return -EOPNOTSUPP;
>>  
>> +	if (ops->get_rxfh_func)
>> +		dev_hfunc = ops->get_rxfh_func(dev);
>>  	if (ops->get_rxfh_indir_size)
>>  		dev_indir_size = ops->get_rxfh_indir_size(dev);
>>  	if (ops->get_rxfh_key_size)
>>  		dev_key_size = dev->ethtool_ops->get_rxfh_key_size(dev);
>> -	if ((dev_key_size + dev_indir_size) == 0)
>> +	if ((dev_key_size + dev_indir_size + dev_hfunc) == 0)
>>  		return -EOPNOTSUPP;
>>  
>>  	if (copy_from_user(&rxfh, useraddr, sizeof(rxfh)))
>>  		return -EFAULT;
>>  
>>  	/* Check that reserved fields are 0 for now */
>> -	if (rxfh.rss_context || rxfh.rsvd[0] || rxfh.rsvd[1])
>> +	if (rxfh.rss_context || rxfh.rsvd8[0] || rxfh.rsvd8[1] ||
>> +	    rxfh.rsvd8[2] || rxfh.rsvd32)
>>  		return -EINVAL;
>>  
>> +	if (rxfh.hfunc != dev_hfunc) {
>> +		if (!ops->set_rxfh_func)
>> +			return -EOPNOTSUPP;
>> +		ret = ops->set_rxfh_func(dev, rxfh.hfunc);
>> +		if (ret)
>> +			return ret;
>> +	}
>> +
>>  	/* If either indir or hash key is valid, proceed further.
>> -	 * It is not valid to request that both be unchanged.
>> +	 * Must request at least one change: indir size, hash key or function.
>>  	 */
>>  	if ((rxfh.indir_size &&
>>  	     rxfh.indir_size != ETH_RXFH_INDIR_NO_CHANGE &&
>> @@ -793,7 +813,7 @@ static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
>>  	    (rxfh.key_size && (rxfh.key_size != dev_key_size)) ||
>>  	    (rxfh.indir_size == ETH_RXFH_INDIR_NO_CHANGE &&
>>  	     rxfh.key_size == 0))
>> -		return -EINVAL;
>> +		return rxfh.hfunc ? 0 : -EINVAL;
> 
> Shouldn't the condition be rxfh.hfunc != dev_hfunc ?
> 
> Ben.
>
On current implementation it's not necessary since we have already
checked that above. However, according to your suggestion, after I'll
remove the set/get_rxfh_func() callbacks I wouldn't be able to check
that condition at this point of the code.

Best Regards,
Eyal.
