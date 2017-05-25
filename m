From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net] net/mlx4: Fix the check in attaching steering rules
Date: Thu, 25 May 2017 16:07:13 +0300
Message-ID: <e6fc81fe-5eb6-0a6b-18df-90a018b687da@mellanox.com>
References: <1495543807-14956-1-git-send-email-tariqt@mellanox.com>
 <20170524.153625.1291847374941790972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eranbe@mellanox.com>,
        <ogerlitz@mellanox.com>, <talatb@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0089.outbound.protection.outlook.com ([104.47.2.89]:23781
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751881AbdEYNHX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 09:07:23 -0400
In-Reply-To: <20170524.153625.1291847374941790972.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 24/05/2017 10:36 PM, David Miller wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
> Date: Tue, 23 May 2017 15:50:07 +0300
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
>> index ae5fdc2df654..00a7cd3dcc2e 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
>> @@ -1562,8 +1562,7 @@ static int mlx4_en_flow_replace(struct net_device *dev,
>>   		qpn = priv->drop_qp.qpn;
>>   	else if (cmd->fs.ring_cookie & EN_ETHTOOL_QP_ATTACH) {
>>   		qpn = cmd->fs.ring_cookie & (EN_ETHTOOL_QP_ATTACH - 1);
>> -		if (qpn < priv->rss_map.base_qpn ||
>> -		    qpn >= priv->rss_map.base_qpn + priv->rx_ring_num) {
>> +		if (!mlx4_qp_lookup(priv->mdev->dev, qpn)) {
>>   			en_warn(priv, "rxnfc: QP (0x%x) doesn't exist\n", qpn);
>>   			return -EINVAL;
>>   		}
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
>> index 2d6abd4662b1..1eff2fe32a8b 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/qp.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
>> @@ -384,6 +384,20 @@ static void mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn)
>>   		__mlx4_qp_free_icm(dev, qpn);
>>   }
>>   
>> +struct mlx4_qp *mlx4_qp_lookup(struct mlx4_dev *dev, u32 qpn)
>   ...
>> +EXPORT_SYMBOL_GPL(mlx4_qp_lookup);
>> +
>
> This phony separation between MLX4_CORE and MLX4_EN is the only reason
> you need this unreasonable symbol export.
>
> I doubt you'll ever use this function anywhere outside of en_ethtool.c
> so this export is wasted space in the kernel image.  Probably compiler
> could inline it decently as well.
>
> So find another way to do this without the symbol export.  I don't
> really want to hear any stories about "clean separation" or whatever.
> What's happening here is exactly why this separate modules scheme
> results in ugly unreasonable code, and unnecessary gymnastics and
> wasted object space just to make routines available in one place from
> another.

I see. I'll remove this EXPORT_SYMBOL_GPL and send a re-spin shortly.
Function will still be accessible within EN driver, as mlx4_en.h includes qp.h.

Regards,
Tariq
