From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 broken affinity
Date: Wed, 1 Nov 2017 15:41:41 -0700
Message-ID: <CALzJLG-Z2fJibyZ74XU7XCSx-g3=YapV9VyekAYZkS5JwvkwWw@mail.gmail.com>
References: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com> <d65d6156-07da-14dc-88ff-fcb5c0ef5f83@grimberg.me>
 <f8624a01-f77a-ac0b-ba19-19c7150ca133@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Sagi Grimberg <sagi@grimberg.me>,
        Networking <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Christoph Hellwig <hch@lst.de>
To: Jes Sorensen <jsorensen@fb.com>, Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:53574 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754732AbdKAWmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 18:42:03 -0400
Received: by mail-lf0-f49.google.com with SMTP id l23so4210972lfk.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 15:42:03 -0700 (PDT)
In-Reply-To: <f8624a01-f77a-ac0b-ba19-19c7150ca133@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 1, 2017 at 11:20 AM, Jes Sorensen <jsorensen@fb.com> wrote:
> On 11/01/2017 01:21 PM, Sagi Grimberg wrote:
>>> Hi,
>>
>> Hi Jes,
>>
>>> The below patch seems to have broken PCI IRQ affinity assignments for
>>> mlx5.
>>
>> I wouldn't call it breaking IRQ affinity assignments. It just makes
>> them automatic.
>
> Well it explicitly breaks the option for an admin to assign them
> manually, which contradicts what is written in
> Documentation/IRQ-affinity.txt
>
>>> Prior to this patch I could echo a value to /proc/irq/<x>/smp_affinity
>>> and it would get assigned. With this patch applied I get -EIO
>>
>> Adding Christoph,
>>
>> Ideally the affinity assignments would be better left alone, but
>> I wasn't aware that they are now immutable. Christoph?
>>
>>> The actual affinity assignments seem to have changed too, but I assume
>>> this is a result of the generic allocation?
>>
>> The affinity assignments should be giving you perfect linear assignment
>> of the rx/tx rings completion vectors to CPU cores:
>> first  -> 0
>> second -> 1
>> third  -> 2
>> ...
>>
>> Before, mlx5 spread affinity starting from the local numa node as it
>> relied on that when constructing RSS indirection table only to the local
>> numa node (which as a side effect hurt applications running on the far
>> node as the traffic was guaranteed to arrive rx rings located in the
>> "wrong" node).
>>
>> Now the RSS indirection table is linear across both numa nodes just like
>> the irq affinity settings. Another thing that was improved was the
>> pre/post vectors which blacklisted any non rx/tx completion vectors from
>> the affinity assignments (like port events completion vectors from
>> example).
>
> I am all in favor of making the automatic setup better, but assuming an
> automatic setup is always right seems problematic. There could be
> workloads where you may want to assign affinity explicitly.
>
> Jes

I vaguely remember Nacking Sagi's patch as we knew it would break
mlx5e netdev affinity assumptions.
Anyway we already submitted the mlx5e patch that removed such assumption

https://patchwork.ozlabs.org/patch/809196/ ("net/mlx5e: Distribute RSS
table among all RX rings")
Jes please confirm you have it.

And I agree here that user should be able to read
/proc/irq/x/smp_affinity and even modify it if required.
