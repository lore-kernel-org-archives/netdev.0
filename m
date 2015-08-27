From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/6] net: add netif_is_ovs_master helper with
 IFF_OPENVSWITCH private flag
Date: Thu, 27 Aug 2015 08:30:01 +0200
Message-ID: <20150827063001.GF2228@nanopsycho.orion>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
 <1440606998-11072-4-git-send-email-jiri@resnulli.us>
 <CAE4R7bA5S6WcycMxWXPyOWyA-dPVs4Jy6TS2hq2176FGC8BKbg@mail.gmail.com>
 <20150827054307.GC2228@nanopsycho.orion>
 <CAE4R7bDokROc=9tWrS2wQ8HaYLMQVBDY5=X=p0YcxLodqfyw-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35408 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbbH0GaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:30:04 -0400
Received: by wicne3 with SMTP id ne3so64277161wic.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 23:30:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bDokROc=9tWrS2wQ8HaYLMQVBDY5=X=p0YcxLodqfyw-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 27, 2015 at 08:23:13AM CEST, sfeldma@gmail.com wrote:
>On Wed, Aug 26, 2015 at 10:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Aug 26, 2015 at 07:43:18PM CEST, sfeldma@gmail.com wrote:
>>>On Wed, Aug 26, 2015 at 9:36 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>> Add this helper so code can easily figure out if netdev is openswitch.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>>  include/linux/netdevice.h            | 8 ++++++++
>>>>  net/openvswitch/vport-internal_dev.c | 2 +-
>>>>  2 files changed, 9 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>> index be625f4..0a884e6 100644
>>>> --- a/include/linux/netdevice.h
>>>> +++ b/include/linux/netdevice.h
>>>> @@ -1264,6 +1264,7 @@ struct net_device_ops {
>>>>   * @IFF_MACVLAN: Macvlan device
>>>>   * @IFF_VRF_MASTER: device is a VRF master
>>>>   * @IFF_NO_QUEUE: device can run without qdisc attached
>>>> + * @IFF_VRF_OPENVSWITCH: device is a Open vSwitch master
>>>>   */
>>>>  enum netdev_priv_flags {
>>>>         IFF_802_1Q_VLAN                 = 1<<0,
>>>> @@ -1293,6 +1294,7 @@ enum netdev_priv_flags {
>>>>         IFF_IPVLAN_SLAVE                = 1<<24,
>>>>         IFF_VRF_MASTER                  = 1<<25,
>>>>         IFF_NO_QUEUE                    = 1<<26,
>>>> +       IFF_OPENVSWITCH                 = 1<<27,
>>>>  };
>>>>
>>>>  #define IFF_802_1Q_VLAN                        IFF_802_1Q_VLAN
>>>> @@ -1322,6 +1324,7 @@ enum netdev_priv_flags {
>>>>  #define IFF_IPVLAN_SLAVE               IFF_IPVLAN_SLAVE
>>>>  #define IFF_VRF_MASTER                 IFF_VRF_MASTER
>>>>  #define IFF_NO_QUEUE                   IFF_NO_QUEUE
>>>> +#define IFF_OPENVSWITCH                        IFF_OPENVSWITCH
>>>>
>>>>  /**
>>>>   *     struct net_device - The DEVICE structure.
>>>> @@ -3853,6 +3856,11 @@ static inline bool netif_is_bridge_master(const struct net_device *dev)
>>>>         return dev->priv_flags & IFF_EBRIDGE;
>>>>  }
>>>>
>>>> +static inline bool netif_is_ovs_master(const struct net_device *dev)
>>>> +{
>>>> +       return dev->priv_flags & IFF_OPENVSWITCH;
>>>> +}
>>>
>>>We're going to run out of priv_flags bits.  This flag doesn't seem
>>>like something that will be checked lots of places.  How about using
>>>rtnl_link_ops->kind to save a bit in priv_flags?
>>>
>>>static inline bool netif_is_ovs_master(const struct net_device *dev)
>>>{
>>>    return !strcmp(dev->rtnl_link_ops->kind, "openvswitch"));
>>>}
>>
>> There are lot of helpers like this for other soft-devices. I think that
>> is okay to have it this way. The thing is that sometimes you need to use
>> thi helper in fast path and in that case, you do not want to strcmp.
>>
>> There is plenty of priv_flags bits for now when I killed the bonding
>> stuff.
>
>Ya, but think about the bit: you (and others) used a bit in priv_flags
>to indicate the netdev type.  Can you add an enum field to
>rtnl_link_ops->type to indicate link type?  Then it's not a strcmp.
>You can write your helper using strcmp first, and then later migrate
>to using rtnl_link_ops->type.

But how different this would be to the priv_flags? You have to have
"central storage" for these types anyway, same as for flags. + it's one
more pointer dereference and null check on fastpath.
