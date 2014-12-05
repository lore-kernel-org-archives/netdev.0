From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD
 feature flag for switch device offloads
Date: Thu, 4 Dec 2014 22:47:45 -0800
Message-ID: <CAE4R7bCAcuJQi4bYc+6pbCpz0fCifrcD=iVQAXYWwXwSnJ2+Dw@mail.gmail.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bBC+W+9F3cmR5TVuO+BbhK+zBuiQhNtk6gCvK5CC2MkMg@mail.gmail.com>
	<54815180.30900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59249 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaLEGrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 01:47:46 -0500
Received: by mail-wg0-f44.google.com with SMTP id b13so86506wgh.31
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 22:47:45 -0800 (PST)
In-Reply-To: <54815180.30900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2014 at 10:32 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 12/04/2014 10:08 PM, Scott Feldman wrote:
>>
>> On Thu, Dec 4, 2014 at 6:26 PM,  <roopa@cumulusnetworks.com> wrote:
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This is a generic high level feature flag for all switch asic features
>>> today.
>>>
>>> switch drivers set this flag on switch ports. Logical devices like
>>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>>
>>> I had to use SWITCH in the name to avoid ambiguity with other feature
>>> flags. But, since i have been harping about not calling it 'switch',
>>> I am welcome to any suggestions :)
>>>
>>> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
>>> in net_device_flags.
>>> ---
>>>   include/linux/netdev_features.h |    2 ++
>>>   1 file changed, 2 insertions(+)
>>>
>>> diff --git a/include/linux/netdev_features.h
>>> b/include/linux/netdev_features.h
>>> index 8e30685..68db1de 100644
>>> --- a/include/linux/netdev_features.h
>>> +++ b/include/linux/netdev_features.h
>>> @@ -66,6 +66,7 @@ enum {
>>>          NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN
>>> STAGs */
>>>          NETIF_F_HW_L2FW_DOFFLOAD_BIT,   /* Allow L2 Forwarding in
>>> Hardware */
>>>          NETIF_F_BUSY_POLL_BIT,          /* Busy poll */
>>> +       NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
>>>
>>>          /*
>>>           * Add your fresh new feature above and remember to update
>>> @@ -124,6 +125,7 @@ enum {
>>>   #define NETIF_F_HW_VLAN_STAG_TX        __NETIF_F(HW_VLAN_STAG_TX)
>>>   #define NETIF_F_HW_L2FW_DOFFLOAD       __NETIF_F(HW_L2FW_DOFFLOAD)
>>>   #define NETIF_F_BUSY_POLL      __NETIF_F(BUSY_POLL)
>>> +#define NETIF_F_HW_SWITCH_OFFLOAD      __NETIF_F(HW_SWITCH_OFFLOAD)
>>
>>
>> Can we use existing flag NETIF_F_HW_L2FW_DOFFLOAD?  The comment above
>> on that flag suggests it would be perfect for what we're doing with L2
>> bridging: offloading the L2 forwarding path in HW.
>>
>> NETIF_F_HW_L2FW_DOFFLOAD seems to be orphaned in current net-next, so
>> I'm not sure of it's status, but see if it makes sense to recycle it.
>>
>> I could see a NETIF_F_HW_L3FW_DOFFLOAD for L3 fwd offload, down the road.
>>
>
> Its not orphaned its used by the macvlan device to indicate that the
> port switching should be done in hardware. For example put macvlan in
> VEPA mode and the hardware will deliver the packets directly to the
> netdev and get the pruning right. In VEB mode the hardware will forward
> packets correctly between macvlan netdevs. The implementation on ixgbe
> for example is to give a set of hardware queues per macvlan netdev. I
> still need to add offloaded QOS to make this more interesting.
>
> I could support a l3vlan device as well even on some of the host nics.
>
> The issue with generalizing it is at the moment it is used by ixgbe
> which can't forward between two physical ports. It works on macvlan
> because each macvlan netdev uses the same physical uplink. I think switching
> between different ports is going to require another feature
> bit like its done here.


My bad...I grepped for the _BIT variant and missed the usage in
macvlan, etc.  Sorry about that.

>
> .John
>
>
>>
>>>   /* Features valid for ethtool to change */
>>>   /* = all defined minus driver/device-class-related */
>>> --
>>> 1.7.10.4
>>>
>
>
> --
> John Fastabend         Intel Corporation
