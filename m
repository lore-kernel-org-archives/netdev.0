From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 13:45:09 +0100
Message-ID: <4AF96055.90509@trash.net>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>	 <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>	 <4AF9471C.5080606@gmail.com>	 <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>	 <4AF95174.3060104@trash.net>	 <412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>	 <4AF95A3D.5060602@trash.net> <412e6f7f0911100437g2759eb6dg509af4edb8848291@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34030 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166AbZKJMpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 07:45:09 -0500
In-Reply-To: <412e6f7f0911100437g2759eb6dg509af4edb8848291@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Tue, Nov 10, 2009 at 8:19 PM, Patrick McHardy <kaber@trash.net> wrote:
>   
>> You have to add a get_tx_queues() callback to the rtnl_link_ops.
>>     
>
> It is used to get the current real_num_tx_queues and num_tx_queues,
> not to setting.
>   

Yes, it gets the number from a user-supplied parameter for device
allocation.

>> Additionally you need a new attribute (IFLA_NTXQ or something like
>> that) that contains the number of queues. The callback has to parse
>> the attribute and set the number of queues accordingly.
>>     
>
> It seems another patch is needed first.
>   

Its a trivial change, you can put them in the same patch:

static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
                             unsigned int *num_tx_queues,
                             unsigned int *real_num_tx_queues)
{
    unsigned int n = 1;

    if (tb[IFLA_NTXQ])
       n = nla_get_u32(tb[IFLA_NTXQ]);

    *num_tx_queues = n;
    *real_num_tx_queues = n;
    return 0;
}

>>> Does this work?
>>>
>>>         ifb_link_ops.priv_size = sizeof(struct ifb_private) * numtxqs;
>>>         rtnl_lock();
>>>         err = __rtnl_link_register(&ifb_link_ops);
>>>       
>> Only for the module parameter. For rtnl_link you need to either
>> allocate the private space seperately or turn priv_size into
>> a callback that returns the required space based on the number
>> of queues.
>>     
>
> Do you means that if module ifb is loaded automatically, parameters
> won't be set correctly?

No, I mean if you add a proper interface for this, you have to deal
with different interfaces using a different amount of queues.
