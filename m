From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Sat, 25 Aug 2012 10:20:43 +0800
Message-ID: <CAF1ivSa-LO_skzCkSAi0nGykpp9RMRyzVjz8O4dHw6zGjZ9LKQ@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
	<CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	<1345640757.5158.1321.camel@edumazet-glaptop>
	<CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:53012 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750787Ab2HYCVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 22:21:24 -0400
Received: from mail-iy0-f174.google.com (mail-iy0-f174.google.com [209.85.210.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 50501DB9AF
	for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 10:20:46 +0800 (CST)
Received: by ialo24 with SMTP id o24so4606859ial.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 19:20:43 -0700 (PDT)
In-Reply-To: <CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 10:29 PM, Sylvain Munaut
<s.munaut@whatever-company.com> wrote:
> Hi,
>
>> my patch was incomplete, sorry :
>>
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index 346b1eb..ddc453b 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -335,8 +335,13 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
>>         /* don't get messages out of order, and no recursion */
>>         if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
>>                 struct netdev_queue *txq;
>> +               int queue_index = skb_get_queue_mapping(skb);
>>
>> -               txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>> +               if (queue_index >= dev->real_num_tx_queues) {
>> +                       queue_index = 0;
>> +                       skb_set_queue_mapping(skb, 0);
>> +               }
>> +               txq = netdev_get_tx_queue(dev, queue_index);
>>
>>                 /* try until next clock tick */
>>                 for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
>
> Ok, I tried this.
>
> The machine with the intel card still hard freeze (no output / no nothing ...)

Did you enable hard lockup detector?

CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y

> The machine with the bnx2 don't crash anymore and no NULL deref, but
> the modprobe still hangs and I get this every 180 sec or so :
>
