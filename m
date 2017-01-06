From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] net: Fix inconsistent rtnl_lock usage on dev_get_stats().
Date: Fri, 6 Jan 2017 11:30:09 -0800
Message-ID: <CACKFLimE1BafzurRje1no6kcNR1-7OnQevyYahdpYiUko_uRiA@mail.gmail.com>
References: <1483676478-14228-1-git-send-email-michael.chan@broadcom.com>
 <1483723976.9712.19.camel@edumazet-glaptop3.roam.corp.google.com> <20170106.130134.50153126758574257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34676 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032848AbdAFTaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:30:11 -0500
Received: by mail-oi0-f48.google.com with SMTP id 3so443397369oih.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 11:30:10 -0800 (PST)
In-Reply-To: <20170106.130134.50153126758574257.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2017 at 10:01 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 06 Jan 2017 09:32:56 -0800
>
>> This makes no sense to me.
>>
>> RTNL is absolutely not needed to get device stats.
>>
>> We try to not add RTNL, especially when not required.
>>
>> Sure, RTNETLINK dumps currently hold RTNL, but we had various attempts
>> in the past to get rid of this behavior.
>>
>> If a device driver expects RTNL being locked, it is clearly a bug that
>> needs a fix anyway.
>
> This is extremely problematic when the driver has to synchronize some
> piece of state between the get stats method and open/close.  It is
> exactly the case we are trying to solve in tg3, and lots of drivers
> end up hitting the same exact issue.
>
> If open/close can happen asynchronously to get stats, it is very hard
> to make dynamically allocated data structures or DMA buffers usable
> from the stats call.
>
> Drivers in this situation will just add a mutex specifically for this
> situation if we don't consistently apply RTNL locking here.

The patch doesn't work anyway in the net-procfs code path upon closer
examination.  Because we are using seq_ops and taking the RCU lock at
the beginning of the sequence, we cannot take RTNL.  That means
drivers cannot use mutex as well.

For tg3, I think I will just use tp->lock spinlock to protect
get_stats64 and the freeing of the stats memory.
