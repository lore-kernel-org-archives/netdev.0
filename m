From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next 0/2] Add mqprio hardware offload support in hns3
 driver
Date: Mon, 16 Oct 2017 09:41:58 +0800
Message-ID: <f651e2c2-5233-bcc7-7488-3ec5905b92d4@huawei.com>
References: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
 <AM0PR0502MB36837A27C3EAA2A08590D709BF4B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <5c268e80-3b04-28bd-26fb-d77f2edd69a8@huawei.com>
 <AM0PR0502MB368336C6A93618A13ADBB68ABF4E0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
        "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
        "Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "john.garry@huawei.com" <john.garry@huawei.com>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>,
        "salil.mehta@huawei.com" <salil.mehta@huawei.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Yuval Mintz <yuvalm@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM0PR0502MB368336C6A93618A13ADBB68ABF4E0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Yuval

On 2017/10/15 13:14, Yuval Mintz wrote:
>> Hi, Yuval
>>
>> On 2017/10/13 4:21, Yuval Mintz wrote:
>>>> This patchset adds a new hardware offload type in mqprio before adding
>>>> mqprio hardware offload support in hns3 driver.
>>>
>>> I think one of the biggest issues in tying this to DCB configuration is the
>>> non-immediate [and possibly non persistent] configuration.
>>>
>>> Scenario #1:
>>> User is configuring mqprio offloaded with 3 TCs while device is in willing
>> mode.
>>> Would you expect the driver to immediately respond with a success or
>> instead
>>> delay the return until the DCBx negotiation is complete and the operational
>>> num of TCs is actually 3?
>>
>> Well, when user requsts the mqprio offloaded by a hardware shared by DCB,
>> I expect
>> the user is not using the dcb tool.
>> If user is still using dcb tool, then result is undefined.
>>
>> The scenario you mention maybe can be enforced by setting willing to zero
>> when user
>> is requesting the mqprio offload, and restore the willing bit when unloaded
>> the mqprio
>> offload.
> 
> Sounds a bit harsh but would probably work.
> 
>> But I think the real issue is that dcb and mqprio shares the tc system in the
>> stack,
>> the problem may be better to be fixed in the stack rather than in the driver,
>> as you
>> suggested in the DCB patchset. What do you think?
> 
> What did you have in mind?

I was thinking maybe the tc system can provide a notification to mqprio and dcb.
mqprio and dcb register a callback to the tc system, when there is some change of
tc configuration, the tc system call the callback from mqprio and dcb.

> 
>>
>>>
>>> Scenario #2:
>>> Assume user explicitly offloaded mqprio with 3 TCs, but now DCB
>> configuration
>>> has changed on the peer side and 4 TCs is the new negotiated operational
>> value.
>>> Your current driver logic would change the number of TCs underneath the
>> user
>>> configuration [and it would actually probably work due to mqprio being a
>> crappy
>>> qdisc]. But was that the user actual intention?
>>> [I think the likely answer in this scenario is 'yes' since the alternative is no
>> better.
>>> But I still thought it was worth mentioning]
>>
>> You are right, the problem also have something to do with mqprio and dcb
>> sharing
>> the tc in the stack.
>>
>> Druing testing, when user explicitly offloaded mqprio with 3 TCs, all
>> queue has a default pfifo mqprio attached, after DCB changes the tc num to
>> 4,
>> using tc qdisc shows some queue does not have a default pfifo mqprio
>> attached.
> 
> Really? Then what did it show? 
> [I assume it has some pfifo attached, and it's an mqprio dump kind of an issue]

When queue size of the ndev is 16 and tc num is 3, we set the real queue size to
15 ( 5 * 3 = 15), mqprio only attach pfifo to the first 15 queue, when tc num change
to 4 by DCB, we set the real queue size to 16 (4 * 4 = 16).
So tc qdisc shows the last queue has no qdisc attached.

> 
>>
>> Maybe we can add a callback to notify mqprio the configuration has changed.
>>
> 
> Which would do what?
> You already have the notifications available for monitoring using dcbnl logic if the
> configuration change [for user]; So user can re-configure whatever it wants.

Yes, if user is only using dcb tool.

> But other than dropping all the qdisc configurations and going back to the default
> qdiscs, what default action would mqprio be able to do when configuration changes
> that actually makes sense?

As explained above, after dcb changing the configuration, some queue may have no qdisc
attached, so I was thinking maybe we can add pfifo to it if there is no qdsic attached
to it.

Thanks,
Yunsheng Lin

> 
>> Thanks
>> Yunsheng Lin
>>
>>>
>>> Cheers,
>>> Yuval
>>>
>>>>
>>>> Yunsheng Lin (2):
>>>>   mqprio: Add a new hardware offload type in mqprio
>>>>   net: hns3: Add mqprio hardware offload support in hns3 driver
>>>>
>>>>  drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  1 +
>>>>  .../net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c | 23 +++++++++++
>>>>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 46
>> ++++++++++++++-
>>>> -------
>>>>  include/uapi/linux/pkt_sched.h                     |  1 +
>>>>  4 files changed, 55 insertions(+), 16 deletions(-)
>>>>
>>>> --
>>>> 1.9.1
>>>
>>>
>>>
> 
