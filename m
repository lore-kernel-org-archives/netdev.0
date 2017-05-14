From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net 1/6] net/mlx5e: Use a spinlock to synchronize statistics
Date: Sun, 14 May 2017 11:52:13 +0300
Message-ID: <CALzJLG-CbN5ipg3_CsN9_1RWtY_q_UaQGMu3KwDpgoYk53xkOQ@mail.gmail.com>
References: <20170512115650.11635-1-saeedm@mellanox.com> <20170512115650.11635-2-saeedm@mellanox.com>
 <20170512.121354.1583292892374462482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Gal Pressman <galp@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35679 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdENIwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 04:52:34 -0400
Received: by mail-qk0-f196.google.com with SMTP id k74so13309722qke.2
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 01:52:34 -0700 (PDT)
In-Reply-To: <20170512.121354.1583292892374462482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 7:13 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Fri, 12 May 2017 14:56:45 +0300
>
>> From: Gal Pressman <galp@mellanox.com>
>>
>> Add a spinlock to prevent races when querying statistics, for example
>> querying counters in the middle of a non atomic memcpy() operation in
>> mlx5e_update_stats().
>>
>> This RW lock should be held when accessing priv->stats, to prevent other
>> reads/writes.
>>
>> Fixes: 9218b44dcc05 ("net/mlx5e: Statistics handling refactoring")
>> Signed-off-by: Gal Pressman <galp@mellanox.com>
>> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: kernel-team@fb.com
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>
> This is overkill, and that rwlock is going to show up in perf for some
> workloads.
>
> Furthermore, two kzalloc()'s for a single state update operation?
> That's not reasonable either.
>

Hi Dave,

Well, the idea of the patch is to minimize the stats update to a
single safe copy operation under stats_lock
for that we need a temp buffer to store stats FW commands output, and
then safely -under stats_lock- copy it to
the buffer ethtool is going to report.

I agree, it is really ridiculous that we allocate/free a couple of
buffers on each update_stats operations, regardless of this patch.
Is it ok if we use a temp buffer under netdev_priv for such usages or
even use kmemcache ?

> Use a seqlock, which is the primitive for handling this kind of
> situation cheaply, and adds no atomics to the read path.
>

Will change this. Thanks for the tip.
I will drop this patch for now and I will resend it later once Gal
addresses all of the above comments.

Thanks,
Saeed.
