From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 1/4] net core: Add protodown support.
Date: Wed, 15 Jul 2015 11:05:43 -0700
Message-ID: <CACcJQnTfnbQdsadAKwiwm2qLaQGW9vj=M_0sKDAFDhMOF_6xgA@mail.gmail.com>
References: <1436389465-3077-2-git-send-email-anuradhak@cumulusnetworks.com>
	<20150715103109.6c63d4f8@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:34995 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbGOSFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 14:05:45 -0400
Received: by lahh5 with SMTP id h5so29540898lah.2
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 11:05:43 -0700 (PDT)
In-Reply-To: <20150715103109.6c63d4f8@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 10:31 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed,  8 Jul 2015 14:04:22 -0700
> anuradhak@cumulusnetworks.com wrote:
>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index e20979d..99ebb01 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1041,6 +1041,11 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>   *   TX queue.
>>   * int (*ndo_get_iflink)(const struct net_device *dev);
>>   *   Called to get the iflink value of this device.
>> + * void (*ndo_change_proto_flags)(struct net_device *dev,
>> + *                             unsigned int proto_flags);
>> + *   This function is used to pass protocol port state information
>> + *   to the switch driver.
>> + *
>>   */
>>  struct net_device_ops {
>>       int                     (*ndo_init)(struct net_device *dev);
>> @@ -1211,6 +1216,8 @@ struct net_device_ops {
>>                                                     int queue_index,
>>                                                     u32 maxrate);
>>       int                     (*ndo_get_iflink)(const struct net_device *dev);
>> +     int                     (*ndo_change_proto_flags)(struct net_device *dev,
>> +                                                       unsigned int proto_flags);
>>  };
>>
>>  /**
>> @@ -1502,6 +1509,10 @@ enum netdev_priv_flags {
>>   *
>>   *   @qdisc_tx_busylock:     XXX: need comments on this one
>>   *
>> + *   @proto_flags:   protocol port state information can be sent to the
>> + *                   switch driver and used to set the phys state of the
>> + *                   switch port.
>> + *
>>   *   FIXME: cleanup struct net_device such that network protocol info
>>   *   moves out.
>>   */
>> @@ -1762,6 +1773,7 @@ struct net_device {
>>  #endif
>>       struct phy_device *phydev;
>>       struct lock_class_key *qdisc_tx_busylock;
>> +     unsigned int proto_flags;
>>  };
>>  #define to_net_dev(d) container_of(d, struct net_device, dev)
>>
>> @@ -2982,6 +2994,7 @@ int dev_get_phys_port_id(struct net_device *dev,
>>                        struct netdev_phys_item_id *ppid);
>>  int dev_get_phys_port_name(struct net_device *dev,
>>                          char *name, size_t len);
>> +int dev_change_proto_flags(struct net_device *dev, unsigned int proto_flags);
>>  struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
>>  struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>>                                   struct netdev_queue *txq, int *ret);
>> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
>> index 9cf2394..8d60fe7 100644
>> --- a/include/uapi/linux/if.h
>> +++ b/include/uapi/linux/if.h
>> @@ -156,6 +156,12 @@ enum {
>>       IF_LINK_MODE_DORMANT,   /* limit upward transition to dormant */
>>  };
>>
>> +/* proto_flags - port state information can be passed to the switch driver and
>> + * used to determine the phys state of the switch port */
>> +enum {
>> +     IF_PROTOF_DOWN          = 1<<0  /* set switch port phys state down */
>> +};
>> +
>>  /*
>>   *   Device mapping structure. I'd just gone off and designed a
>>   *   beautiful scheme using only loadable modules with arguments
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 6778a99..87571c4 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -6076,6 +6076,26 @@ int dev_get_phys_port_name(struct net_device *dev,
>>  EXPORT_SYMBOL(dev_get_phys_port_name);
>>
>>  /**
>> + *   dev_change_proto_flags - update protocol port state information
>> + *   @dev: device
>> + *   @proto_flags: new value
>> + *
>> + *   This info can be used by switch drivers to set the phys state of the
>> + *   port.
>> + */
>> +int dev_change_proto_flags(struct net_device *dev, unsigned int proto_flags)
>> +{
>> +     const struct net_device_ops *ops = dev->netdev_ops;
>> +
>> +     if (dev->proto_flags == proto_flags)
>> +             return 0;
>> +     if (!ops->ndo_change_proto_flags)
>> +             return -EOPNOTSUPP;
>> +     return ops->ndo_change_proto_flags(dev, proto_flags);
>> +}
>> +EXPORT_SYMBOL(dev_change_proto_flags);
>
> Rather than introducing yet another ndo op etc, can't this be handled under some other
> event (like change flags)?  It seems that this one small feature has grown to have bigger
> impact than necessary.
>
Yes, I really wanted to avoid another ndo as well. The advantage of
adding the ndo was to isolate functionality and verify if the
operation was actually performed.
