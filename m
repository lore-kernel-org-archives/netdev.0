From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] net: l3mdev: Add hook in ip and ipv6
Date: Sat, 7 May 2016 20:25:40 -0600
Message-ID: <572EA3A4.9010200@cumulusnetworks.com>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
 <1462585781-9146-2-git-send-email-dsa@cumulusnetworks.com>
 <20160507113025.67c3ab43@halley> <572E00C9.4050109@cumulusnetworks.com>
 <20160507213205.02529bde@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36033 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbcEHCZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 22:25:43 -0400
Received: by mail-io0-f180.google.com with SMTP id u185so169371656iod.3
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 19:25:43 -0700 (PDT)
In-Reply-To: <20160507213205.02529bde@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/16 12:32 PM, Shmulik Ladkani wrote:
> Hi David,
>
> On Sat, 7 May 2016 08:50:49 -0600 David Ahern <dsa@cumulusnetworks.com> wrote:
>>>> +static inline
>>>> +struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
>>>> +{
>>>> +	struct net_device *master = NULL;
>>>> +
>>>> +	if (netif_is_l3_slave(skb->dev))
>>>> +		master = netdev_master_upper_dev_get_rcu(skb->dev);
>>>> +
>>>> +	else if (netif_is_l3_master(skb->dev))
>>>> +		master = skb->dev;
>>>> +
>>>> +	if (master && master->l3mdev_ops->l3mdev_l3_rcv)
>>>> +		skb = master->l3mdev_ops->l3mdev_l3_rcv(master, skb, proto);
>>>
>>> In the case where netif_is_l3_master(skb->dev) is true, can you explain
>>> why we need to pass it through the l3mdev_l3_rcv callback again?
>>
>> what do you mean again? This is only time the l3mdev_l3_rcv method is
>> called on a packet.
>
> You have the following:
>
> 	if (netif_is_l3_slave(skb->dev))
> 		master = netdev_master_upper_dev_get_rcu(skb->dev);
> 	else if (netif_is_l3_master(skb->dev))
> 		master = skb->dev;
> 	if (master && master->l3mdev_ops->l3mdev_l3_rcv)
> 		skb = master->l3mdev_ops->l3mdev_l3_rcv(master, skb, proto);
>
> So in both conditions (skb->dev being the slave or the master) the skb
> is passed to master's l3mdev_l3_rcv callback.
>
> Appreciate if you can elaborate:
>   - Why callback needs to be invoked when skb->dev is the L3 master?

Every l3mdev_ops has converged on that ordering -- if l3 slave else if 
l3 master.

>   - On which circumstances we end up entering
>     l3mdev_ip_rcv/l3mdev_ip6_rcv where skb->dev is the master?
>     If I got it right, we enter 'ip_rcv_finish' on a slave device,
>     the callback is invoked and eventually sets skb->dev and skb->skb_iif
>     to the VRF device; then ip_rcv_finish continues processing the
>     altered skb (with the changed skb->dev).
>     So on which cicumstances do we enter 'ip_rcv_finish' where the
>     skb->dev is ALREADY a master device?

If you look at the full patchset I posted on 5/4 the patch after PKTINFO 
allows local traffic. That change needs the netif_is_l3_master().
