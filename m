From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: add BQL support
Date: Fri, 8 Apr 2016 21:13:39 -0700
Message-ID: <CAGXr9JEiz3W3HxBJSHbk1pjikTP6M-Dg9o7wNCQpqc1sguZQpw@mail.gmail.com>
References: <1459903801-83727-1-git-send-email-pgynther@google.com>
	<20160408.163648.2055481752216023669.davem@davemloft.net>
	<CAGXr9JE8Qp-u4gjm08oB8nXDoQxFM12=Da2=MZbWcZrRXOCi_w@mail.gmail.com>
	<1460166979.6473.451.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34996 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcDIENk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 00:13:40 -0400
Received: by mail-vk0-f52.google.com with SMTP id t129so73350092vkg.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 21:13:40 -0700 (PDT)
In-Reply-To: <1460166979.6473.451.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 6:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-04-08 at 18:39 -0700, Petri Gynther wrote:
>> On Fri, Apr 8, 2016 at 1:36 PM, David Miller <davem@davemloft.net> wrote:
>> > From: Petri Gynther <pgynther@google.com>
>> > Date: Tue,  5 Apr 2016 17:50:01 -0700
>> >
>> >> Add Byte Queue Limits (BQL) support to bcmgenet driver.
>> >>
>> >> Signed-off-by: Petri Gynther <pgynther@google.com>
>> >
>> > As Eric Dumazet indicated, your ->ndo_init() code to reset the queues is
>> > probably not necessary at all.
>>
>> I added the netdev_tx_reset_queue(txq) calls to ndo_open() path:
>> netdev->ndo_open()
>>   bcmgenet_open()
>>     bcmgenet_netif_start()
>>       for all Tx queues:
>>         netdev_tx_reset_queue(txq)
>>           clear __QUEUE_STATE_STACK_XOFF
>>           dql_reset()
>>       netif_tx_start_all_queues(dev)
>>         for all Tx queues:
>>           clear __QUEUE_STATE_DRV_XOFF
>>
>> So, I think the call to netdev_tx_reset_queue(txq) is in the right
>> place. It ensures that the Tx queue state is clean when the device is
>> opened.
>
>
> The netdev_tx_reset_queue(txq) calls are only needed in exceptional
> conditions.
>
> Not at device start, as the core networking layer init all txq
> (including their BQL state) properly before giving them to drivers for
> use.
>

What values does the networking core program into BQL dynamic limits
that my code in netdev->ndo_open() would wipe out?

You mentioned the queue init path:
netdev_init_one_queue() -> dql_init() -> dql_reset()

that is called when the netdev is created and Tx queues allocated.

But, does the networking core somewhere set *different* values for BQL
dynamic limits than what dql_reset() did, before opening the device?

> For example, tg3 calls netdev_tx_reset_queue() only when freeing tx
> rings, as it might have freed skb(s) not from normal TX complete path
> and thus missed appropriate dql_completed().
>

Looking at the tg3 driver, it calls:
tg3_stop()
  tg3_free_rings()
    netdev_tx_reset_queue()

netdev_tx_reset_queue() is called unconditionally, as long as the Tx
ring exists. So "ip link set dev eth<x> down" would cause it to be
called.

Why is it OK to call netdev_tx_reset_queue() from the
netdev->ndo_stop() path, but not from netdev->ndo_open() path?

> If you believe BQL drivers need a fix, please elaborate ?
>
> Thanks.
>
>
