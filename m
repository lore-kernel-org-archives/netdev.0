From: Ming Chen <v.mingchen@gmail.com>
Subject: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Sat, 8 Mar 2014 01:13:35 -0500
Message-ID: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33756 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbaCHGNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 01:13:36 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so5357251iec.21
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 22:13:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have an Intel 82599EB dual-port 10GbE NIC, which has 128 tx queues
(64 per port and we used only one port). We found only 12 of the tx
queues are enabled, where 12 is number of CPUs of our system.

We realized that, in the driver code, adapter->num_tx_queues (which
decides netdev->real_num_tx_queues) is indirectly set to "min_t(int,
IXGBE_MAX_RSS_INDICES, num_online_cpus())". It looks like the limit is
for RSS. But why tx queues is also set to the same as rx queues?

The problem of having a small number of tx queues is high probability
of hash collision in skb_tx_hash(). If we have a small number of
long-lived data-intensive TCP flows, the hash collision can causes
unfairness. We found this problem during our benchmarking of NFS when
identical NFS clients are getting very different throughput when
reading a big file from the server. We call this problem Hash-Cast. If
interested, you can take a look at this poster:
http://www.fsl.cs.sunysb.edu/~mchen/fast14poster-hashcast-portrait.pdf

Can anybody take a loot at this? It would be better to have all tx
queues enabled by default. If this is unlikely to happen, is there a
way to reconfigure the NIC so that we can use all tx queues if we
want?

FYI, our kernel version is 3.12.0, but I found the same limit of tx
queues in the code of the latest kernel. I am counting the number of
enabled queues using "ls /sys/class/net/p3p1/queues| grep -c tx-"

Best,
Ming
