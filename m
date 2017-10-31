From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: caif: chnl_net: remove unnecessary null check in
 chnl_recv_cb
Date: Mon, 30 Oct 2017 23:12:09 -0500
Message-ID: <20171030231209.Horde.iiLMY2GN0VQCKhOT-2lzgNs@gator4166.hostgator.com>
References: <20171030224714.GA31045@embeddedor.com>
 <20171030183338.Horde.vVqSFCm_FOajDoq8fJoJ13P@gator4166.hostgator.com>
 <20171030213357.Horde.6OOG7UXJzbPReRCnj5zqscs@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway31.websitewelcome.com ([192.185.143.35]:11827 "EHLO
        gateway31.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751192AbdJaEMK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 00:12:10 -0400
Received: from cm10.websitewelcome.com (cm10.websitewelcome.com [100.42.49.4])
        by gateway31.websitewelcome.com (Postfix) with ESMTP id 1E37D1E81E1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 23:12:10 -0500 (CDT)
In-Reply-To: <20171030213357.Horde.6OOG7UXJzbPReRCnj5zqscs@gator4166.hostgator.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quoting "Gustavo A. R. Silva" <garsilva@embeddedor.com>:

> Quoting "Gustavo A. R. Silva" <garsilva@embeddedor.com>:
>
>> Hi,
>>
>> Quoting "Gustavo A. R. Silva" <garsilva@embeddedor.com>:
>>
>>> container_of is never null, so this null check is unnecessary.
>>>
>>> This code was detected with the help of Coccinelle.
>>>
>>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>>> ---
>>> net/caif/chnl_net.c | 2 --
>>> 1 file changed, 2 deletions(-)
>>>
>>> diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
>>> index 922ac1d..489298d 100644
>>> --- a/net/caif/chnl_net.c
>>> +++ b/net/caif/chnl_net.c
>>> @@ -77,8 +77,6 @@ static int chnl_recv_cb(struct cflayer *layr,  
>>> struct cfpkt *pkt)
>>> 	u8 buf;
>>>
>>> 	priv = container_of(layr, struct chnl_net, chnl);
>>> -	if (!priv)
>>> -		return -EINVAL;

But the driver only passes in to container_of the type of driver  
structure registered with it. So this type of manipulation must be  
completely safe. Right?

Now it seems to me (again) that the patch is fine.

I'm sorry, I'm a little bit confused here.

>>>
>>> 	skb = (struct sk_buff *) cfpkt_tonative(pkt);
>>>
>>> --
>>> 2.7.4
>>
>> Please, ignore this patch.
>>
>> I just realized that function chnl_recv_cb is being called only  
>> during initialization:
>>
>> chnl_init_module() -> rtnl_link_register() -> ipcaif_net_setup() ->  
>> chnl_recv_cb():
>>
>
> Well, here ipcaif_net_setup stores a pointer to chnl_recv_cb in a  
> structure. It doesn't call it.
>
>> static void ipcaif_net_setup(struct net_device *dev)
>> {
>> [...]
>> 	priv = netdev_priv(dev);
>> 	priv->chnl.receive = chnl_recv_cb;
>>
>> [...]
>> }
>>
>> static struct rtnl_link_ops ipcaif_link_ops __read_mostly = {
>> 	.kind		= "caif",
>> 	.priv_size	= sizeof(struct chnl_net),
>> 	.setup		= ipcaif_net_setup,
>> 	.maxtype	= IFLA_CAIF_MAX,
>> 	.policy		= ipcaif_policy,
>> 	.newlink	= ipcaif_newlink,
>> 	.changelink	= ipcaif_changelink,
>> 	.get_size	= ipcaif_get_size,
>> 	.fill_info	= ipcaif_fill_info,
>>
>> };
>>
>> static int __init chnl_init_module(void)
>> {
>> 	return rtnl_link_register(&ipcaif_link_ops);
>> }
>>
>
