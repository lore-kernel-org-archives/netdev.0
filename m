From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: mlx5 broken affinity
Date: Wed, 1 Nov 2017 19:21:07 +0200
Message-ID: <d65d6156-07da-14dc-88ff-fcb5c0ef5f83@grimberg.me>
References: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev@vger.kernel.org>, leonro@mellanox.com,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Christoph Hellwig <hch@lst.de>
To: Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:57015 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbdKARVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:21:11 -0400
Received: by mail-wm0-f53.google.com with SMTP id z3so6244106wme.5
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:21:10 -0700 (PDT)
In-Reply-To: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi,

Hi Jes,

> The below patch seems to have broken PCI IRQ affinity assignments for mlx5.

I wouldn't call it breaking IRQ affinity assignments. It just makes
them automatic.

> Prior to this patch I could echo a value to /proc/irq/<x>/smp_affinity
> and it would get assigned. With this patch applied I get -EIO

Adding Christoph,

Ideally the affinity assignments would be better left alone, but
I wasn't aware that they are now immutable. Christoph?

> The actual affinity assignments seem to have changed too, but I assume
> this is a result of the generic allocation?

The affinity assignments should be giving you perfect linear assignment
of the rx/tx rings completion vectors to CPU cores:
first  -> 0
second -> 1
third  -> 2
...

Before, mlx5 spread affinity starting from the local numa node as it
relied on that when constructing RSS indirection table only to the local
numa node (which as a side effect hurt applications running on the far
node as the traffic was guaranteed to arrive rx rings located in the
"wrong" node).

Now the RSS indirection table is linear across both numa nodes just like
the irq affinity settings. Another thing that was improved was the
pre/post vectors which blacklisted any non rx/tx completion vectors from
the affinity assignments (like port events completion vectors from
example).

> With this applied I get:
> [root@testbox /proc/irq]# cat 50/smp_affinity
> 000000,00000010
> [root@textbox /proc/irq]# cat 100/smp_affinity
> 100000,00000000
> 
> Without I get:
> [root@testbox /proc/irq]# cat 50/smp_affinity
> 000000,00000200
> [root@testbox /proc/irq]# cat 100/smp_affinity
> 000100,00000000
> 
> I am not wildly familiar with the affinity assignment code. Is there
> something obvious I am missing here?

The affinity assignment is indeed changed, should be better though.
If you do not see a linear (diagonal) affinity assignment then
its a bug that needs to be fixed (probably in msi.c code).
