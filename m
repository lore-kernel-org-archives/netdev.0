From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH V1 5/6] net/mlx4_en: sk_prio <=> UP for untagged traffic
Date: Wed, 21 Mar 2012 17:18:43 +0200
Message-ID: <4F69F153.1010703@mellanox.com>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com> <1332321903-11704-6-git-send-email-amirv@mellanox.com> <4F69E3AD.2000501@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:59632 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755688Ab2CUPUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 11:20:15 -0400
In-Reply-To: <4F69E3AD.2000501@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2012 04:20 PM, John Fastabend wrote:
> On 3/21/2012 2:25 AM, Amir Vadai wrote:
>> From: Amir Vadai<amirv@mellanox.co.il>
>>
>> Since vlan egress map is only good for tagged traffic, need to have other
>> mapping to be used by untagged traffic.
>> For that, the driver uses sch_mqprio mapping. This mapping could be set by
>> using tc tool from iproute2 package.
>> Mapped UP will be used by the HW for QoS purposes, but won't go out on the
>> wire.
>>
>> Signed-off-by: Amir Vadai<amirv@mellanox.com>
>> ---
>
> [...]
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 445a771..f228728 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -570,15 +570,15 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
>>
>>   u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
>>   {
>> -	u16 vlan_tag = 0;
>> +	int up = -1;
>>
>> -	/* If we support per priority flow control and the packet contains
>> -	 * a vlan tag, send the packet to the TX ring assigned to that priority
>> -	 */
>> -	if (vlan_tx_tag_present(skb)) {
>> -		vlan_tag = vlan_tx_tag_get(skb);
>> -		return MLX4_EN_NUM_TX_RINGS + (vlan_tag>>  13);
>> -	}
>> +	if (vlan_tx_tag_present(skb))
>> +		up = (vlan_tx_tag_get(skb)>>  13);
>> +	else if (dev->num_tc)
>> +		up = netdev_get_prio_tc_map(dev, skb->priority);
>> +
>> +	if (up>= 0)
>> +		return MLX4_EN_NUM_TX_RINGS + up;
>
> I expected the else case covered by the netdev_set_tc_queue() setup above? Did
> I miss something.
>
It is me who missed something, will fix it in V2

>>
>>   	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS);
>>   }
>

- Amir
