From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 13:00:09 -0800
Message-ID: <CAKgT0UduWGLXdBFoRtVV-96kFFeB_Lp-7Q7A2tVps+8-MQMd5A@mail.gmail.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com> <20170227.111944.1725806340309799464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34588 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdB0VBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 16:01:07 -0500
Received: by mail-io0-f170.google.com with SMTP id 90so36831118ios.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 13:00:10 -0800 (PST)
In-Reply-To: <20170227.111944.1725806340309799464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 8:19 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 27 Feb 2017 06:21:38 -0800
>
>> A NAPI driver normally arms the IRQ after the napi_complete_done(),
>> after NAPI_STATE_SCHED is cleared, so that the hard irq handler can grab
>> it.
>>
>> Problem is that if another point in the stack grabs NAPI_STATE_SCHED bit
>> while IRQ are not disabled, we might have later an IRQ firing and
>> finding this bit set, right before napi_complete_done() clears it.
>>
>> This can happen with busy polling users, or if gro_flush_timeout is
>> used. But some other uses of napi_schedule() in drivers can cause this
>> as well.
>>
>> This patch adds a new NAPI_STATE_MISSED bit, that napi_schedule_prep()
>> can set if it could not grab NAPI_STATE_SCHED
>
> Various rules were meant to protect these sequences, and make sure
> nothing like this race could happen.
>
> Can you show the specific sequence that fails?
>
> One of the basic protections is that the device IRQ is not re-enabled
> until napi_complete_done() is finished, most drivers do something like
> this:
>
>         napi_complete_done();
>                 - sets NAPI_STATE_SCHED
>         enable device IRQ
>
> So I don't understand how it is possible that "later an IRQ firing and
> finding this bit set, right before napi_complete_done() clears it".
>
> While napi_complete_done() is running, the device's IRQ is still
> disabled, so there cannot be an IRQ firing before napi_complete_done()
> is finished.

So there are some drivers that will need to have the interrupts
enabled when busy polling and I assume that can cause this kind of
issue. Specifically in the case of i40e the part will not flush
completed descriptors until either 4 completed descriptors are ready
to be written back, or an interrupt fires.

Our other drivers have code in them that will force the interrupt to
unmask and fire once every 2 seconds in the unlikely event that an
interrupt was lost which can occur on some platforms.

- Alex
