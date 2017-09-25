From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next 10/10] net: hns3: Add mqprio support when
 interacting with network stack
Date: Mon, 25 Sep 2017 15:22:43 +0800
Message-ID: <bf64c912-a8c3-bcaa-1b32-d6d284ab155c@huawei.com>
References: <1505992913-107256-1-git-send-email-linyunsheng@huawei.com>
 <1505992913-107256-11-git-send-email-linyunsheng@huawei.com>
 <20170922125541.GA2005@nanopsycho.orion>
 <59c51a37.a1c4df0a.ac4e2.8df0SMTPIN_ADDED_BROKEN@mx.google.com>
 <20170922160322.GB2005@nanopsycho.orion>
 <fdd8d8af-6d74-143a-adfa-502bd94a90d9@huawei.com>
 <20170924113724.GA2029@nanopsycho>
 <290b0679-bfc2-c23c-00ee-43768c1c2327@huawei.com>
 <20170925065740.GB1899@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        huangdaode <huangdaode@hisilicon.com>,
        "xuwei (O)" <xuwei5@hisilicon.com>,
        "Liguozhu (Kenneth)" <liguozhu@hisilicon.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        John Garry <john.garry@huawei.com>,
        Linuxarm <linuxarm@huawei.com>,
        "Salil Mehta" <salil.mehta@huawei.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925065740.GB1899@nanopsycho>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Jiri

On 2017/9/25 14:57, Jiri Pirko wrote:
> Mon, Sep 25, 2017 at 02:45:08AM CEST, linyunsheng@huawei.com wrote:
>> Hi, Jiri
>>
>> On 2017/9/24 19:37, Jiri Pirko wrote:
>>> Sat, Sep 23, 2017 at 02:47:20AM CEST, linyunsheng@huawei.com wrote:
>>>> Hi, Jiri
>>>>
>>>> On 2017/9/23 0:03, Jiri Pirko wrote:
>>>>> Fri, Sep 22, 2017 at 04:11:51PM CEST, linyunsheng@huawei.com wrote:
>>>>>> Hi, Jiri
>>>>>>
>>>>>>>> - if (!tc) {
>>>>>>>> + if (if_running) {
>>>>>>>> + (void)hns3_nic_net_stop(netdev);
>>>>>>>> + msleep(100);
>>>>>>>> + }
>>>>>>>> +
>>>>>>>> + ret = (kinfo->dcb_ops && kinfo->dcb_ops->>setup_tc) ?
>>>>>>>> + kinfo->dcb_ops->setup_tc(h, tc, prio_tc) : ->EOPNOTSUPP;
>>>>>>
>>>>>>> This is most odd. Why do you call dcb_ops from >ndo_setup_tc callback?
>>>>>>> Why are you mixing this together? prio->tc mapping >can be done
>>>>>>> directly in dcbnl
>>>>>>
>>>>>> Here is what we do in dcb_ops->setup_tc:
>>>>>> Firstly, if current tc num is different from the tc num
>>>>>> that user provide, then we setup the queues for each
>>>>>> tc.
>>>>>>
>>>>>> Secondly, we tell hardware the pri to tc mapping that
>>>>>> the stack is using. In rx direction, our hardware need
>>>>>> that mapping to put different packet into different tc'
>>>>>> queues according to the priority of the packet, then
>>>>>> rss decides which specific queue in the tc should the
>>>>>> packet goto.
>>>>>>
>>>>>> By mixing, I suppose you meant why we need the
>>>>>> pri to tc infomation?
>>>>>
>>>>> by mixing, I mean what I wrote. You are calling dcb_ops callback from
>>>>> ndo_setup_tc callback. So you are mixing DCBNL subsystem and TC
>>>>> subsystem. Why? Why do you need sch_mqprio? Why DCBNL is not enough for
>>>>> all?
>>>>
>>>> When using lldptool, dcbnl is involved.
>>>>
>>>> But when using tc qdisc, dcbbl is not involved, below is the a few key
>>>> call graph in the kernel when tc qdisc cmd is executed.
>>>>
>>>> cmd:
>>>> tc qdisc add dev eth0 root handle 1:0 mqprio num_tc 4 map 1 2 3 3 1 3 1 1 hw 1
>>>>
>>>> call graph:
>>>> rtnetlink_rcv_msg -> tc_modify_qdisc -> qdisc_create -> mqprio_init ->
>>>> hns3_nic_setup_tc
>>>>
>>>> When hns3_nic_setup_tc is called, we need to know how many tc num and
>>>> prio_tc mapping from the tc_mqprio_qopt which is provided in the paramter
>>>> in the ndo_setup_tc function, and dcb_ops is the our hardware specific
>>>> method to setup the tc related parameter to the hardware, so this is why
>>>> we call dcb_ops callback in ndo_setup_tc callback.
>>>>
>>>> I hope this will answer your question, thanks for your time.
>>>
>>> Okay. I understand that you have a usecase for mqprio mapping offload
>>> without lldptool being involved. Ok. I believe it is wrong to call dcb_ops
>>> from tc callback. You should have a generic layer inside the driver and
>>> call it from both dcb_ops and tc callbacks.
>>
>> Actually, dcb_ops is our generic layer inside the driver.
>> Below is high level architecture:
>>
>>       [ tc qdisc ]	       [ lldpad ]
>>             |                     |
>>             |                     |
>>             |                     |
>>       [ hns3_enet ]        [ hns3_dcbnl ]
>>             \                    /
>>                \              /
>>                   \        /
>>                 [ hclge_dcb ]
>>                   /      \
>>                /            \
>>             /                  \
>>     [ hclgc_main ]        [ hclge_tm ]
>>
>> hns3_enet.c implements the ndo_setup_tc callback.
>> hns3_dcbnl.c implements the dcbnl_rtnl_ops for stack's DCBNL system.
>> hclge_dcb implements the dcb_ops.
>> So we already have a generic layer that tc and dcbnl all call from.
>>
>>>
>>> Also, what happens If I run lldptool concurrently with mqprio? Who wins
>>> and is going to configure the mapping?
>>
>> Both lldptool and tc qdisc cmd use rtnl interface provided by stack, so
>> they are both protected by rtnl_lock, so we do not have to do the locking
>> in the driver.
> 
> I was not asking about locking, which is obvious, I was asking about the
> behaviour. Like for example:
> If I use tc to configure some mapping, later on I run lldptool and change
> the mapping. Does the tc dump show the updated values or the original
> ones?

If it is that case, tc dump show the updated values.
Normally, we use tc qdisc to configure the netdev to use mqprio, and
then use the lldptool the tc_prio mapping, tc schedule mode, tc bandwidth
and pfc option.

if lldptool change the tc num and tc_prio mapping, it will tell the tc
system by the following function which is called in client_ops->setup_tc:
netdev_set_tc_queue
netdev_set_prio_tc_map

So lldptool and tc qdisc can work together.



> 
>>
>> The locking is in rtnetlink_rcv_msg:
>>
>> 	rtnl_lock();
>> 	handlers = rtnl_dereference(rtnl_msg_handlers[family]);
>> 	if (handlers) {
>> 		doit = READ_ONCE(handlers[type].doit);
>> 		if (doit)
>> 			err = doit(skb, nlh, extack);
>> 	}
>> 	rtnl_unlock();
>>
>> Thanks.
>>
>>>
>>>
>>>>
>>>>>
>>>>>
>>>>>
>>>>>> I hope I did not misunderstand your question, thanks
>>>>>> for your time reviewing.
>>>>>
>>>>> .
>>>>>
>>>>
>>>
>>> .
>>>
>>
> 
> .
> 
