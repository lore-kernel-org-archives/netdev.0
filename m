From: Eyal perry <eyalpe@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Support for configurable RSS
 hash function
Date: Wed, 05 Nov 2014 15:05:52 +0200
Message-ID: <545A20B0.4080807@dev.mellanox.co.il>
References: <1415188769-19593-1-git-send-email-amirv@mellanox.com> <1415188769-19593-3-git-send-email-amirv@mellanox.com> <545A17C2.9070609@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51073 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaKENF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 08:05:58 -0500
Received: by mail-wi0-f174.google.com with SMTP id d1so12355830wiv.1
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 05:05:57 -0800 (PST)
In-Reply-To: <545A17C2.9070609@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/5/2014 2:27 PM, Or Gerlitz wrote:
> On 11/5/2014 1:59 PM, Amir Vadai wrote:
>> From: Eyal Perry <eyalpe@mellanox.com>
>>
>> The ConnectX HW is capable of using one of the following hash functions:
>> Toeplitz and an XOR hash function.
>> This patch implements ethtool_ops {get,set}_rxfh_func callbacks for the
>> mlx4_en driver in order to query and configure the RSS hash function to
>> be used by the device.
>>
>> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 40
>> +++++++++++++++++++++++++
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  9 ++++++
>>   drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 11 ++++---
>>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 +-
>>   4 files changed, 58 insertions(+), 5 deletions(-)
>>

[...]

>> +
>> +static int mlx4_en_set_rxfh_func(struct net_device *dev, u32 hfunc)
>> +{
>> +    struct mlx4_en_priv *priv = netdev_priv(dev);
>> +    struct mlx4_en_dev *mdev = priv->mdev;
>> +    u32 prev_rss_hash_fn = priv->rss_hash_fn;
>> +    int err = 0;
>> +
>> +    if (!(hfunc & priv->rss_hash_fn_caps))
>> +        return -EINVAL;
>> +
>> +    priv->rss_hash_fn = hfunc;
> 
> Seems that you are blindly setting here priv->rss_hash_fn to the
> function (xor or top) requested
> by the user w.o prior checking if the firmware actually supports that
> (e.g test it against priv->rss_hash_fn_caps, right?
> 
That exactly what I do 3 lines above, priv->rss_hash_fn_caps is derived
from firmware capabilities.

[...]

>> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> @@ -1113,10 +1113,13 @@ int mlx4_en_config_rss_steer(struct
>> mlx4_en_priv *priv)
>>       }
>>         rss_context->flags = rss_mask;
>> -    rss_context->hash_fn = MLX4_RSS_HASH_TOP;
>> -    for (i = 0; i < 10; i++)
>> -        rss_context->rss_key[i] = cpu_to_be32(rsskey[i]);
>> -
>> +    if (priv->rss_hash_fn & MLX4_RSS_HASH_XOR) {
>> +        rss_context->hash_fn = MLX4_RSS_HASH_XOR;
>> +    } else {
>> +        rss_context->hash_fn = MLX4_RSS_HASH_TOP;
>> +        for (i = 0; i < 10; i++)
>> +            rss_context->rss_key[i] = cpu_to_be32(rsskey[i]);
>> +    }
> 
> So this patch effectively changes the default from top to xor, right? is
> that intentional? if yes, spare few words on the change log.
> 
No, in general the default shouldn't be affected by the patch (unless
there's a bug). The default value is set in mlx4_en_init_netdev() and it
will remain Toeplitz unless firmware is supports only XOR hash function.

[...]
