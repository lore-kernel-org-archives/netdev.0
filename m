From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v2 0/9] mlxsw: implement port mirroring offload
Date: Fri, 22 Jul 2016 12:26:30 -0700
Message-ID: <b31ce9ad-3d64-5e4b-b616-8060e2e26b7c@gmail.com>
References: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
 <4304f9b7-a0ab-aee7-fdc7-1fe68cd9b250@gmail.com>
 <20160722192056.GB2050@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
	eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, jhs@mojatatu.com,
	Andrew Lunn <andrew@lunn.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35840 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431AbcGVT0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 15:26:38 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so7704324pfg.3
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 12:26:37 -0700 (PDT)
In-Reply-To: <20160722192056.GB2050@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2016 12:20 PM, Jiri Pirko wrote:
> Fri, Jul 22, 2016 at 08:24:31PM CEST, f.fainelli@gmail.com wrote:
>> On 07/21/2016 03:03 AM, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This patchset introduces tc matchall classifier and its offload
>>> to Spectrum hardware. In combination with mirred action, defined port mirroring
>>> setup is offloaded by mlxsw/spectrum driver.
>>>
>>> The commands used for creating mirror ports:
>>>
>>> # ingress mirroring using matchall
>>> tc qdisc  add dev eth25 handle ffff: ingress
>>> tc filter add dev eth25 parent ffff:            \
>>>         matchall skip_sw                        \
>>>         action mirred egress mirror             \
>>>         dev eth27
>>>
>>> # egress mirroring using matchall
>>> tc qdisc add dev eth25 handle 1: root prio
>>> tc filter add dev eth25 parent 1:               \
>>>         matchall skip_sw                        \
>>>         action mirred egress mirror             \
>>>         dev eth27
>>
>> Is there any logic that guards against the following cases where the
>> target device is:
>>
>> - outside of the switch hardware/cluster (which would imply going
>> through software)?
> 
> In that case only kernel (slow) path can be used. Not possible to
> offload of course.

So then what happens if I target a device that is outside of the switch,
do we get an error like -EOPNOTSUPP, or this just silently succeeed, but
nothing happens?

> 
> 
>> - has a downstream speed which is lower than the mirrored device?
> 
> The default behaviour is "strict" which means that if the mirrored
> packet can't be send, the packet is dropped. That is aligned with the
> behaviour of act_mirred.

What determines if the packet can be sent or not?

> 
> 
>>
>> this might already be in place for 1), I just could not locate it, thanks!
>>
>>>
>>> These patches contain:
>>>  - Resource query implementation
>>>  - Hardware port mirorring support for spectrum.
>>>  - Definition of the matchall traffic classifier.
>>>  - General support for hw-offloading for that classifier.
>>>  - Specific spectrum implementaion for matchall offloading.
>>>
>>> ---
>>> v1->v2:
>>>  - couple of minor style fixes
>>>
>>> Jiri Pirko (1):
>>>   net/sched: introduce Match-all classifier
>>>
>>> Nogah Frankel (2):
>>>   mlxsw: pci: Add resources query implementation.
>>>   mlxsw: pci: Add max span resources to resources query
>>>
>>> Yotam Gigi (6):
>>>   net/sched: Add match-all classifier hw offloading.
>>>   mlxsw: reg: Add Shared Buffer Internal Buffer register
>>>   mlxsw: reg: Add Monitoring Port Analyzer Table register
>>>   mlxsw: reg: Add the Monitoring Port Analyzer register
>>>   net/sched: act_mirred: Add helper inlines to access tcf_mirred info.
>>>   mlxsw: spectrum: Add support in matchall mirror TC offloading
>>>
>>>  drivers/net/ethernet/mellanox/mlxsw/cmd.h      |  32 ++
>>>  drivers/net/ethernet/mellanox/mlxsw/core.c     |  10 +-
>>>  drivers/net/ethernet/mellanox/mlxsw/core.h     |  11 +-
>>>  drivers/net/ethernet/mellanox/mlxsw/pci.c      |  64 +++-
>>>  drivers/net/ethernet/mellanox/mlxsw/reg.h      | 162 +++++++++
>>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 465 ++++++++++++++++++++++++-
>>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  44 +++
>>>  drivers/net/ethernet/mellanox/mlxsw/switchx2.c |   1 +
>>>  include/linux/netdevice.h                      |   2 +
>>>  include/net/pkt_cls.h                          |  11 +
>>>  include/net/tc_act/tc_mirred.h                 |   9 +
>>>  include/uapi/linux/pkt_cls.h                   |  12 +
>>>  net/sched/Kconfig                              |  10 +
>>>  net/sched/Makefile                             |   1 +
>>>  net/sched/cls_matchall.c                       | 318 +++++++++++++++++
>>>  15 files changed, 1148 insertions(+), 4 deletions(-)
>>>  create mode 100644 net/sched/cls_matchall.c
>>>
>>
>>
>> -- 
>> Florian


-- 
Florian
