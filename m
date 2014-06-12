From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Very Minor Patch to loopback.c
Date: Thu, 12 Jun 2014 13:46:24 -0700
Message-ID: <CAGVrzcaoJ4vdKoaMOh-XDKkOSSu6Q1W3axkzu6-B_e4-GZeu0g@mail.gmail.com>
References: <CAECMkcNrXmuE4saV2==GrCwjwEUzAaGi+NroP5ZXxrRpqr0AwA@mail.gmail.com>
 <CAGVrzcaxhQfV_BRWew8omfQhDWzzFUpe6c7yhdjR=qSTX1zXvA@mail.gmail.com> <CAECMkcODXWjKpqzgct8iKGgLKAepeuPfwxZEwT9vtzBnuR3AKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Zachary <zacharyw09264@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:58903 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbaFLUrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 16:47:05 -0400
Received: by mail-ob0-f182.google.com with SMTP id nu7so1947636obb.41
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 13:47:04 -0700 (PDT)
In-Reply-To: <CAECMkcODXWjKpqzgct8iKGgLKAepeuPfwxZEwT9vtzBnuR3AKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-12 13:30 GMT-07:00 Zachary <zacharyw09264@gmail.com>:
> Should this be changed in dummy.c then to prevent the same bug?

dummy.c uses skb->len before calling dev_kfree_skb(), and in its
transmit path, which is a valid use case that will not introduce use
after free issues.

(BTW: we avoid top-posting on netdev and other linux mailing-lists)

>
> On Thu, Jun 12, 2014 at 4:27 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> 2014-06-12 12:53 GMT-07:00 Zachary <zacharyw09264@gmail.com>:
>>> Very minor patch to loopback.c that I noticed while comparing the
>>> dummy.c code to loopback.c code (dummy.c was based on loopback.c).  I
>>> did not see a maintainer in MAINTAINERS in my cursory glance, so I
>>> apologize if this is to the wrong place.  I am testing this patch
>>> right now on my laptop and it appears to be working without issues.
>>> It also compiled without warnings.
>>
>> Your patch introduces a potential use after free type of bug. As soon
>> as the skb pointer has been passed to netif_rx(), the network stack is
>> allowed to free this skb as soon as it has determined it is unused,
>> this is the reason why this 'len' variable exists in the first place.
>>
>>>
>>> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
>>> index bb96409..f9f88d7 100644
>>> --- a/drivers/net/loopback.c
>>> +++ b/drivers/net/loopback.c
>>> @@ -22,6 +22,7 @@
>>>   *                                      interface.
>>>   *             Alexey Kuznetsov:       Potential hang under some extreme
>>>   *                                     cases removed.
>>> + *             Zachary Winnerman:  Extremely minor patch in loopback_xmit
>>>   *
>>>   *             This program is free software; you can redistribute it and/or
>>>   *             modify it under the terms of the GNU General Public License
>>> @@ -72,7 +73,6 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>>>                                  struct net_device *dev)
>>>  {
>>>         struct pcpu_lstats *lb_stats;
>>> -       int len;
>>>
>>>         skb_orphan(skb);
>>>
>>> @@ -86,10 +86,9 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>>>         /* it's OK to use per_cpu_ptr() because BHs are off */
>>>         lb_stats = this_cpu_ptr(dev->lstats);
>>>
>>> -       len = skb->len;
>>>         if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
>>>                 u64_stats_update_begin(&lb_
>>> stats->syncp);
>>> -               lb_stats->bytes += len;
>>> +               lb_stats->bytes += skb->len;
>>>                 lb_stats->packets++;
>>>                 u64_stats_update_end(&lb_stats->syncp);
>>>         }
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>
>> --
>> Florian



-- 
Florian
