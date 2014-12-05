From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD
 feature flag for switch device offloads
Date: Fri, 5 Dec 2014 10:53:47 -0800
Message-ID: <CAE4R7bBzQQeQAHof=gObugmOGdGE-e5GRh=6V2+KJbctity9pw@mail.gmail.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
	<20141205074127.GB1866@nanopsycho.orion>
	<5481BE27.6000505@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
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
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:58809 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaLESxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 13:53:48 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so2356706wiv.0
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 10:53:47 -0800 (PST)
In-Reply-To: <5481BE27.6000505@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 6:16 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> On 12/4/14, 11:41 PM, Jiri Pirko wrote:
>>
>> Fri, Dec 05, 2014 at 03:26:39AM CET, roopa@cumulusnetworks.com wrote:
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This is a generic high level feature flag for all switch asic features
>>> today.
>>>
>>> switch drivers set this flag on switch ports. Logical devices like
>>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>
>>
>> Can you please elaborate on how exactly would this inheritance look
>> like?
>
>
> My thought there was, when a port with the hw offload flag is added to the
> bridge, the same flag gets set on the bridge. And, for any bridge attributes
> (not port attributes), this flag on the bridge can be used to offload those
> bridge attributes.
> bridge attribute examples: IFLA_BR_FORWARD_DELAY, IFLA_BR_HELLO_TIME,
> IFLA_BR_MAX_AGE.

Ah, wait, why do those need to be pushed down to driver/HW?  Letting
the bridge (or external process like mstpd) own the ctrl-plane means
HW isn't running STP machine or aging out FDB entries.  Let Linux take
care of that.

Same goes for bonding, since that was mentioned earlier.  Keep LACP
ctrl processing in the kernel/bonding driver, and there is no need to
push bonding settings down to port driver/hw.  driver/hw just need to
know port membership and LACP status.

> I don't think offloads for these are handled today. I was going to look at
> them as part of continued work on this.
> The current patches only target bridge port attributes and the flag for this
> is already set by the port driver.
>
> I believe netdev_update_features() takes care of the updating the flag on
> the bridge part. I plan to check on that.
>
>
>
>>
>>
>>> I had to use SWITCH in the name to avoid ambiguity with other feature
>>> flags. But, since i have been harping about not calling it 'switch',
>>> I am welcome to any suggestions :)
>>>
>>> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
>>> in net_device_flags.
>>> ---
>>> include/linux/netdev_features.h |    2 ++
>>> 1 file changed, 2 insertions(+)
>>>
>>> diff --git a/include/linux/netdev_features.h
>>> b/include/linux/netdev_features.h
>>> index 8e30685..68db1de 100644
>>> --- a/include/linux/netdev_features.h
>>> +++ b/include/linux/netdev_features.h
>>> @@ -66,6 +66,7 @@ enum {
>>>         NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN
>>> STAGs */
>>>         NETIF_F_HW_L2FW_DOFFLOAD_BIT,   /* Allow L2 Forwarding in
>>> Hardware */
>>>         NETIF_F_BUSY_POLL_BIT,          /* Busy poll */
>>> +       NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
>>>
>>>         /*
>>>          * Add your fresh new feature above and remember to update
>>> @@ -124,6 +125,7 @@ enum {
>>> #define NETIF_F_HW_VLAN_STAG_TX __NETIF_F(HW_VLAN_STAG_TX)
>>> #define NETIF_F_HW_L2FW_DOFFLOAD        __NETIF_F(HW_L2FW_DOFFLOAD)
>>> #define NETIF_F_BUSY_POLL       __NETIF_F(BUSY_POLL)
>>> +#define NETIF_F_HW_SWITCH_OFFLOAD      __NETIF_F(HW_SWITCH_OFFLOAD)
>>>
>>> /* Features valid for ethtool to change */
>>> /* = all defined minus driver/device-class-related */
>>> --
>>> 1.7.10.4
>>>
>
