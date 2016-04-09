From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: add BQL support
Date: Fri, 8 Apr 2016 19:26:18 -0700
Message-ID: <CAKgT0UcPmh_7D71F=nwmAByZGzqxBL3bif52RgKxT4ohFk2skA@mail.gmail.com>
References: <1459903801-83727-1-git-send-email-pgynther@google.com>
	<20160408.163648.2055481752216023669.davem@davemloft.net>
	<CAGXr9JE8Qp-u4gjm08oB8nXDoQxFM12=Da2=MZbWcZrRXOCi_w@mail.gmail.com>
	<1460166979.6473.451.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35521 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358AbcDIC0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 22:26:19 -0400
Received: by mail-io0-f174.google.com with SMTP id g185so152072726ioa.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 19:26:19 -0700 (PDT)
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
> For example, tg3 calls netdev_tx_reset_queue() only when freeing tx
> rings, as it might have freed skb(s) not from normal TX complete path
> and thus missed appropriate dql_completed().
>
> If you believe BQL drivers need a fix, please elaborate ?
>
> Thanks.

For a bit of history on why you might want to do the reset on clean-up
instead of init you might take a look at commit dad8a3b3eaa0 ("igb,
ixgbe: netdev_tx_reset_queue incorrectly called from tx init path").

Basically you want to make certain you flush the queues after bringing
the interface down so that you don't possibly trigger any false hangs
for having stalled queues.  Basically the rule with the BQL stuff is
you need to leave the Tx queue in the state you found it in instead of
just wiping it and making use of it and putting it away dirty.

- Alex
