From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 1/2] macvtap: Let TUNSETOFFLOAD actually controll
 offload features.
Date: Wed, 19 Jun 2013 11:26:52 -0400
Message-ID: <51C1CDBC.4040003@redhat.com>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com>  <1371653272-11703-2-git-send-email-vyasevic@redhat.com> <1371655038.3252.312.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	jasowang@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934836Ab3FSP04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 11:26:56 -0400
In-Reply-To: <1371655038.3252.312.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 11:17 AM, Eric Dumazet wrote:
> On Wed, 2013-06-19 at 10:47 -0400, Vlad Yasevich wrote:
>> When the user issues TUNSETOFFLOAD ioctl, macvtap does not do
>> anything other then to verify arguments.  This patch adds
>> functionality to allow users to actually control offload features.
>> NETIF_F_GSO and NETIF_F_GRO are always on, but the rest of the
>> features can be controlled.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   drivers/net/macvlan.c      |  9 +++++++++
>>   drivers/net/macvtap.c      | 41 ++++++++++++++++++++++++++++++++++++++++-
>>   include/linux/if_macvlan.h |  1 +
>>   3 files changed, 50 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index edfddc5..fa47415 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -638,6 +638,14 @@ static int macvlan_ethtool_get_settings(struct net_device *dev,
>>   	return __ethtool_get_settings(vlan->lowerdev, cmd);
>>   }
>>
>> +static netdev_features_t macvlan_fix_features(struct net_device *dev,
>> +					      netdev_features_t features)
>> +{
>> +	struct macvlan_dev *vlan = netdev_priv(dev);
>> +
>> +	return (features & vlan->set_features) | (features & ~MACVLAN_FEATURES);
>> +}
>> +
>>   static const struct ethtool_ops macvlan_ethtool_ops = {
>>   	.get_link		= ethtool_op_get_link,
>>   	.get_settings		= macvlan_ethtool_get_settings,
>> @@ -651,6 +659,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
>>   	.ndo_stop		= macvlan_stop,
>>   	.ndo_start_xmit		= macvlan_start_xmit,
>>   	.ndo_change_mtu		= macvlan_change_mtu,
>> +	.ndo_fix_features	= macvlan_fix_features,
>>   	.ndo_change_rx_flags	= macvlan_change_rx_flags,
>>   	.ndo_set_mac_address	= macvlan_set_mac_address,
>>   	.ndo_set_rx_mode	= macvlan_set_mac_lists,
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 5a76f20..09f0b1f 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -976,6 +976,45 @@ static int macvtap_ioctl_set_queue(struct file *file, unsigned int flags)
>>   	return ret;
>>   }
>>
>> +static int set_offload(struct macvtap_queue *q, unsigned long arg)
>> +{
>> +	struct macvlan_dev *vlan;
>> +	netdev_features_t features = NETIF_F_GSO|NETIF_F_GRO;
>> +	int err = 0;
>> +
>> +	if (arg & TUN_F_CSUM) {
>> +		features = NETIF_F_HW_CSUM;
>> +
>> +		if (arg & (TUN_F_TSO4 | TUN_F_TSO6)) {
>> +			if (arg & TUN_F_TSO_ECN)
>> +				features |= NETIF_F_TSO_ECN;
>> +			if (arg & TUN_F_TSO4)
>> +				features |= NETIF_F_TSO;
>> +			if (arg & TUN_F_TSO6)
>> +				features |= NETIF_F_TSO6;
>> +		}
>> +
>> +		if (arg & TUN_F_UFO)
>> +			features |= NETIF_F_UFO;
>> +	}
>> +
>> +	rtnl_lock();
>> +	rcu_read_lock_bh();
>
> This looks wrong/suspect to me.
>
> Once RTNL is owned, you should not need rcu_read_lock_bh()
>

I think I do since vlan pointer may change even when I am holding
rtnl.  rtnl is needed to change features.  rcu is needed to get
the vlan pointer.

> (A BH handler will not change q->vlan )

No, but the _bh rcu calls seem to be used when dereferencing q->vlan.
I am not sure the reason for that...

>
> BTW, it looks like ->vlan is protected by macvtap_lock

Right.  This is why I use rcu to get vlan.  rtnl is needed to avoid
asserts in the feature change code.

-vlad

>
>> +	vlan = rcu_dereference_bh(q->vlan);
>
> vlan = rtnl_dereference(q->vlan);
>
>> +	if (!vlan) {
>> +		err = -ENOLINK;
>> +		goto unlock;
>> +	}
>> +
>> +	vlan->set_features = features;
>> +	netdev_update_features(vlan->dev);
>
> Can this really be called with BH disabled ?
>
>> +
>> +unlock:
>> +	rcu_read_unlock_bh();
>> +	rtnl_unlock();
>> +	return err;
>> +}
>> +
>
>
>
