From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 08/17] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Tue, 25 Nov 2014 15:35:20 -1000
Message-ID: <CAE4R7bAiEyztdGo2BMVGXq9phfASHsMU+QW4oocTmr9=4antxw@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-9-git-send-email-jiri@resnulli.us>
	<5475073E.70503@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:58262 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbaKZBfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 20:35:21 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so2396633wgh.30
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 17:35:20 -0800 (PST)
In-Reply-To: <5475073E.70503@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So offload is a little strong for this particular function.  The
bridge driver or external STP process (msptd) is still controlling STP
state for the port and processing the BPDUs.  When the state changes
on the port, the bridge driver is letting HW know, that's it.  If the
port driver can't do anything with that notification, then it should
not implement ndo_switch_port_stp_update.  If it does implement
ndo_switch_port_stp_update, then it can adjust its HW (e.g. disable
port if BR_DISABLED, etc), and return err code if somehow it failed
while adjusting HW.

This is not offloading STP state ctrl plane to HW.  The ctrl plane is
kept in bridge driver (or mstpd) in SW.  HW stays dumb in this model.
The bridge currently has policy control to turn on/off STP per bridge
and a netlink hook for external processes to change STP state.

On Tue, Nov 25, 2014 at 12:48 PM, Roopa Prabhu
<roopa@cumulusnetworks.com> wrote:
> On 11/25/14, 2:28 AM, Jiri Pirko wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To notify switch driver of change in STP state of bridge port, add new
>> .ndo op and provide switchdev wrapper func to call ndo op. Use it in
>> bridge
>> code then.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>> v2->v3:
>> -changed "sw" string to "switch" to avoid confusion
>> v1->v2:
>> -no change
>> ---
>>   include/linux/netdevice.h |  5 +++++
>>   include/net/switchdev.h   |  7 +++++++
>>   net/bridge/br_stp.c       |  2 ++
>>   net/switchdev/switchdev.c | 19 +++++++++++++++++++
>>   4 files changed, 33 insertions(+)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index ce096dc..66cb64e 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1024,6 +1024,9 @@ typedef u16 (*select_queue_fallback_t)(struct
>> net_device *dev,
>>    *    Called to get an ID of the switch chip this port is part of.
>>    *    If driver implements this, it indicates that it represents a port
>>    *    of a switch chip.
>> + * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
>> + *     Called to notify switch device port of bridge port STP
>> + *     state change.
>>    */
>>   struct net_device_ops {
>>         int                     (*ndo_init)(struct net_device *dev);
>> @@ -1180,6 +1183,8 @@ struct net_device_ops {
>>   #ifdef CONFIG_NET_SWITCHDEV
>>         int                     (*ndo_switch_parent_id_get)(struct
>> net_device *dev,
>>                                                             struct
>> netdev_phys_item_id *psid);
>> +       int                     (*ndo_switch_port_stp_update)(struct
>> net_device *dev,
>> +                                                             u8 state);
>>   #endif
>>   };
>>   diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>> index 7a52360..8a6d164 100644
>> --- a/include/net/switchdev.h
>> +++ b/include/net/switchdev.h
>> @@ -16,6 +16,7 @@
>>     int netdev_switch_parent_id_get(struct net_device *dev,
>>                                 struct netdev_phys_item_id *psid);
>> +int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
>>     #else
>>   @@ -25,6 +26,12 @@ static inline int netdev_switch_parent_id_get(struct
>> net_device *dev,
>>         return -EOPNOTSUPP;
>>   }
>>   +static inline int netdev_switch_port_stp_update(struct net_device *dev,
>> +                                               u8 state)
>> +{
>> +       return -EOPNOTSUPP;
>> +}
>> +
>>   #endif
>>     #endif /* _LINUX_SWITCHDEV_H_ */
>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>> index 2b047bc..35e016c 100644
>> --- a/net/bridge/br_stp.c
>> +++ b/net/bridge/br_stp.c
>> @@ -12,6 +12,7 @@
>>    */
>>   #include <linux/kernel.h>
>>   #include <linux/rculist.h>
>> +#include <net/switchdev.h>
>>     #include "br_private.h"
>>   #include "br_private_stp.h"
>> @@ -39,6 +40,7 @@ void br_log_state(const struct net_bridge_port *p)
>>   void br_set_state(struct net_bridge_port *p, unsigned int state)
>>   {
>>         p->state = state;
>> +       netdev_switch_port_stp_update(p->dev, state);
>>   }
>>     /* called under bridge lock */
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index 66973de..d162b21 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -31,3 +31,22 @@ int netdev_switch_parent_id_get(struct net_device *dev,
>>         return ops->ndo_switch_parent_id_get(dev, psid);
>>   }
>>   EXPORT_SYMBOL(netdev_switch_parent_id_get);
>> +
>> +/**
>> + *     netdev_switch_port_stp_update - Notify switch device port of STP
>> + *                                     state change
>> + *     @dev: port device
>> + *     @state: port STP state
>> + *
>> + *     Notify switch device port of bridge port STP state change.
>> + */
>> +int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>> +{
>> +       const struct net_device_ops *ops = dev->netdev_ops;
>> +
>> +       if (!ops->ndo_switch_port_stp_update)
>> +               return -EOPNOTSUPP;
>> +       WARN_ON(!ops->ndo_switch_parent_id_get);
>> +       return ops->ndo_switch_port_stp_update(dev, state);
>> +}
>> +EXPORT_SYMBOL(netdev_switch_port_stp_update);
>
>
> This should also check  if offload is enabled on the bridge/port ?
>
