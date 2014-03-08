From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Fri, 07 Mar 2014 23:12:28 -0800
Message-ID: <531AC2DC.4000403@intel.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59187 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbaCHHMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 02:12:51 -0500
In-Reply-To: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/2014 10:13 PM, Ming Chen wrote:
> Hi,
>
> We have an Intel 82599EB dual-port 10GbE NIC, which has 128 tx queues
> (64 per port and we used only one port). We found only 12 of the tx
> queues are enabled, where 12 is number of CPUs of our system.
>
> We realized that, in the driver code, adapter->num_tx_queues (which
> decides netdev->real_num_tx_queues) is indirectly set to "min_t(int,
> IXGBE_MAX_RSS_INDICES, num_online_cpus())". It looks like the limit is
> for RSS. But why tx queues is also set to the same as rx queues?
>
> The problem of having a small number of tx queues is high probability
> of hash collision in skb_tx_hash(). If we have a small number of
> long-lived data-intensive TCP flows, the hash collision can causes
> unfairness. We found this problem during our benchmarking of NFS when
> identical NFS clients are getting very different throughput when
> reading a big file from the server. We call this problem Hash-Cast. If
> interested, you can take a look at this poster:
> http://www.fsl.cs.sunysb.edu/~mchen/fast14poster-hashcast-portrait.pdf
>
> Can anybody take a loot at this? It would be better to have all tx
> queues enabled by default. If this is unlikely to happen, is there a
> way to reconfigure the NIC so that we can use all tx queues if we
> want?

One way to solve this would be to use XPS and cgroups. XPS will allow
you to map the queues to CPUs and then use cgroups to map your
application (NFS here) onto the correct CPU. Then which queue is
picked is deterministic and you could manage the hash-cast problem.
Having to use cgroup to do the management is not ideal though.

Also once you have many sessions on a single mq qdisc queue you
should consider using fq-codel configured via 'tc qdisc add ...'
to get nice fairness properties amongst flows sharing a queue.

>
> FYI, our kernel version is 3.12.0, but I found the same limit of tx
> queues in the code of the latest kernel. I am counting the number of
> enabled queues using "ls /sys/class/net/p3p1/queues| grep -c tx-"

Its been the same for sometime. It should be reasonably easy to allow
this I'll take a look but wont get to it until next week. In the
meantime I'll see what other sort of comments pop up.

This is only observable with a small number of flows correct? With
many flows the distribution should be fair.

>
> Best,
> Ming
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
