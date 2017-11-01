From: Jes Sorensen <jsorensen@fb.com>
Subject: mlx5 broken affinity
Date: Wed, 1 Nov 2017 12:19:51 -0400
Message-ID: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev@vger.kernel.org>, <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52916 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754965AbdKAQUT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 12:20:19 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The below patch seems to have broken PCI IRQ affinity assignments for mlx5.

Prior to this patch I could echo a value to /proc/irq/<x>/smp_affinity
and it would get assigned. With this patch applied I get -EIO

The actual affinity assignments seem to have changed too, but I assume
this is a result of the generic allocation?

With this applied I get:
[root@testbox /proc/irq]# cat 50/smp_affinity
000000,00000010
[root@textbox /proc/irq]# cat 100/smp_affinity
100000,00000000

Without I get:
[root@testbox /proc/irq]# cat 50/smp_affinity
000000,00000200
[root@testbox /proc/irq]# cat 100/smp_affinity
000100,00000000

I am not wildly familiar with the affinity assignment code. Is there
something obvious I am missing here?

Cheers,
Jes


commit a435393acafbf0ecff4deb3e3cb554b34f0d0664
Author: Sagi Grimberg <sagi@grimberg.me>
Date:   Thu Jul 13 11:09:40 2017 +0300

    mlx5: move affinity hints assignments to generic code

    generic api takes care of spreading affinity similar to
    what mlx5 open coded (and even handles better asymmetric
    configurations). Ask the generic API to spread affinity
    for us, and feed him pre_vectors that do not participate
    in affinity settings (which is an improvement to what we
    had before).

    The affinity assignments should match what mlx5 tried to
    do earlier but now we do not set affinity to async, cmd
    and pages dedicated vectors.

    Also, remove mlx5e_get_cpu and introduce mlx5e_get_node
    (used for allocation purposes) and mlx5_get_vector_affinity
    (for indirection table construction) as they provide the needed
    information. Luckily, we have generic helpers to get cpumask
    and node given a irq vector. mlx5_get_vector_affinity will
    be used by mlx5_ib in a subsequent patch.

    Reviewed-by: Christoph Hellwig <hch@lst.de>
    Acked-by: Leon Romanovsky <leonro@mellanox.com>
    Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
    Signed-off-by: Doug Ledford <dledford@redhat.com>
