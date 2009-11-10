From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 13:19:09 +0100
Message-ID: <4AF95A3D.5060602@trash.net>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>	 <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>	 <4AF9471C.5080606@gmail.com>	 <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>	 <4AF95174.3060104@trash.net> <412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33341 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbZKJMTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 07:19:09 -0500
In-Reply-To: <412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Tue, Nov 10, 2009 at 7:41 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Changli Gao wrote:
>>> 2009/11/10 Eric Dumazet <eric.dumazet@gmail.com>:
>>>
>>> The whole ifb.c file is attached, please review and test it. Thanks!
>>> /* Number of TX queues per ifb */
>>> static int numtxqs = 1;
>>> module_param(numtxqs, int, 0444);
>>> MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");
>> Module parameters suck as a configuration API. The existing numifbs
>> option exists purely for compatibility reasons, I'd prefer if you'd
>> this to the netlink interface.
> 
> How to do that? I haven't found any examples. Is there a interface to
> config the number of the TX queues of a NIC.

You have to add a get_tx_queues() callback to the rtnl_link_ops.
Additionally you need a new attribute (IFLA_NTXQ or something like
that) that contains the number of queues. The callback has to parse
the attribute and set the number of queues accordingly.

>>> static int __init ifb_init_one(int index)
>>> {
>>>       struct net_device *dev_ifb;
>>>       int err;
>>>
>>>       dev_ifb = alloc_netdev_mq(sizeof(struct ifb_private) * numtxqs, "ifb%d",
>>>                                 ifb_setup, numtxqs);
>>>
>> This won't work for the rtnl_link setup since the size must
>> be constant.
>>
> 
> Does this work?
> 
>         ifb_link_ops.priv_size = sizeof(struct ifb_private) * numtxqs;
>         rtnl_lock();
>         err = __rtnl_link_register(&ifb_link_ops);

Only for the module parameter. For rtnl_link you need to either
allocate the private space seperately or turn priv_size into
a callback that returns the required space based on the number
of queues.

