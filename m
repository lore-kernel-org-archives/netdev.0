From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v3 2/2] macvtap: Allow tap features change when IFF_VNET_HDR
 is disabled.
Date: Thu, 15 Aug 2013 14:39:39 -0400
Message-ID: <520D206B.3000203@redhat.com>
References: <1376586173-4242-1-git-send-email-vyasevic@redhat.com> <1376586173-4242-3-git-send-email-vyasevic@redhat.com> <20130815173347.GA10265@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276Ab3HOSjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 14:39:41 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7FIdfRs004421
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 14:39:41 -0400
In-Reply-To: <20130815173347.GA10265@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 01:33 PM, Michael S. Tsirkin wrote:
> On Thu, Aug 15, 2013 at 01:02:53PM -0400, Vlad Yasevich wrote:
>> When the user turns off IFF_VNET_HDR flag, attempts to change
>> offload features via TUNSETOFFLOAD do not work.  This could cause
>> GSO packets to be delivered to the user when the user is
>> not prepared to handle them.
>>
>> To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
>> disabled.  Also, take the setting of IFF_VNET_HDR into consideration
>> when determining the feature set to apply to incommig traffic.
>> If IFF_VNET_HDR is set, we use user-specfied feature set.  if the
>> IFF_VNET_HDR is clear, we mask off all tun-specific offload features,
>> since user can not be notified of the possbile offloads.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   drivers/net/macvtap.c | 30 ++++++++++++++++++++++++------
>>   1 file changed, 24 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 8121358..df45a59 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -269,6 +269,28 @@ static void macvtap_del_queues(struct net_device *dev)
>>   		sock_put(&qlist[j]->sk);
>>   }
>>
>> +/* Determine features to be applied to the packet as it
>
> /*
>   * Please use comments
>   * like this
>   */
>
>> + * gets sent to the tap.  The features depend on the offloads
>> + * set by user and by whether or not IFF_VNET_HDR is enabled.
>> + */
>> +static netdev_features_t macvtap_skb_features(struct sk_buff *skb,
>> +					      struct macvtap_queue *q)
>> +{
>> +	struct macvlan_dev *vlan = netdev_priv(skb->dev);
>> +	netdev_features_t features = netif_skb_features(skb);
>> +
>> +	/* If VNET_HDR is enabled, user can receive offload info so
>> +	 * use user-specified tap_features.
>> +	 * Otherwise, mask off all tap offload features.
>> +	 */
>> +	if (q->flags & IFF_VNET_HDR)
>> +		features &= vlan->tap_features;
>> +	else
>> +		features &= ~TUN_OFFLOADS;
>> +
>> +	return features;
>> +}
>> +
>
> Okay, but this means we need to do netdev_update_features
> on SETIFF since it changes q->flags.

Why?  The whole point it not to change features on SETIFF, so that
they are preserved for when the flags change again.  It just that
flag values either allow whatever offload user specified (correctly
masked via netdev_update_features) or turn off all offloads at the tap.

-vlad

>>   /*
>>    * Forward happens for data that gets sent from one macvlan
>>    * endpoint to another one in bridge mode. We just take
>> @@ -276,9 +298,9 @@ static void macvtap_del_queues(struct net_device *dev)
>>    */
>>   static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
>>   {
>> -	struct macvlan_dev *vlan = netdev_priv(dev);
>>   	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
>>   	netdev_features_t features;
>> +
>>   	if (!q)
>>   		goto drop;
>>
>> @@ -289,7 +311,7 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
>>   	/* Apply the forward feature mask so that we perform segmentation
>>   	 * according to users wishes.
>>   	 */
>> -	features = netif_skb_features(skb) & vlan->tap_features;
>> +	features = macvtap_skb_features(skb, q);
>>   	if (netif_needs_gso(skb, features)) {
>>   		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
>>
>> @@ -1161,10 +1183,6 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>   			    TUN_F_TSO_ECN | TUN_F_UFO))
>>   			return -EINVAL;
>>
>> -		/* TODO: only accept frames with the features that
>> -			 got enabled for forwarded frames */
>> -		if (!(q->flags & IFF_VNET_HDR))
>> -			return  -EINVAL;
>>   		rtnl_lock();
>>   		ret = set_offload(q, arg);
>>   		rtnl_unlock();
>> --
>> 1.8.1.4
