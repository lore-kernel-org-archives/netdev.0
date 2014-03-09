From: Ming Chen <v.mingchen@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Sat, 8 Mar 2014 19:19:52 -0500
Message-ID: <CAG+wggY-bK-0V0tK+Vw24NqM+MaFf1fpWNRZP_wxN-auB5pj6g@mail.gmail.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<531AC2DC.4000403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:52476 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbaCIATw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 19:19:52 -0500
Received: by mail-ig0-f180.google.com with SMTP id hl1so5246347igb.1
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 16:19:52 -0800 (PST)
In-Reply-To: <531AC2DC.4000403@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

Thanks for the suggestion. Please find my comments inline.

On Sat, Mar 8, 2014 at 2:12 AM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 3/7/2014 10:13 PM, Ming Chen wrote:
>>
>> Hi,
>>
>> We have an Intel 82599EB dual-port 10GbE NIC, which has 128 tx queues
>> (64 per port and we used only one port). We found only 12 of the tx
>> queues are enabled, where 12 is number of CPUs of our system.
>>
>> We realized that, in the driver code, adapter->num_tx_queues (which
>> decides netdev->real_num_tx_queues) is indirectly set to "min_t(int,
>> IXGBE_MAX_RSS_INDICES, num_online_cpus())". It looks like the limit is
>> for RSS. But why tx queues is also set to the same as rx queues?
>>
>> The problem of having a small number of tx queues is high probability
>> of hash collision in skb_tx_hash(). If we have a small number of
>> long-lived data-intensive TCP flows, the hash collision can causes
>> unfairness. We found this problem during our benchmarking of NFS when
>> identical NFS clients are getting very different throughput when
>> reading a big file from the server. We call this problem Hash-Cast. If
>> interested, you can take a look at this poster:
>> http://www.fsl.cs.sunysb.edu/~mchen/fast14poster-hashcast-portrait.pdf
>>
>> Can anybody take a loot at this? It would be better to have all tx
>> queues enabled by default. If this is unlikely to happen, is there a
>> way to reconfigure the NIC so that we can use all tx queues if we
>> want?
>
>
> One way to solve this would be to use XPS and cgroups. XPS will allow
> you to map the queues to CPUs and then use cgroups to map your
> application (NFS here) onto the correct CPU. Then which queue is
> picked is deterministic and you could manage the hash-cast problem.
> Having to use cgroup to do the management is not ideal though.
>
> Also once you have many sessions on a single mq qdisc queue you
> should consider using fq-codel configured via 'tc qdisc add ...'
> to get nice fairness properties amongst flows sharing a queue.
>

Yeah, we can let all NFS flows share just one queue using XPS and
cgroups. And then use fd-codel to achieve fairness among them. But I
have two doubts: (1) Is cgroups also applicable to kernel process as
we were using the in-kernel NFS server. Never used cgroups before.

(2) I have not tried yet, but would the network throughput be lower if
we just use just one tx queue instead of multiple? Because NFS server
is the only thing we care about in the machine. Using just one tx
queue sounds like a waste of resources considering there are 64 in
total. I will try this and measure the throughput.

>
>>
>> FYI, our kernel version is 3.12.0, but I found the same limit of tx
>> queues in the code of the latest kernel. I am counting the number of
>> enabled queues using "ls /sys/class/net/p3p1/queues| grep -c tx-"
>
>
> Its been the same for sometime. It should be reasonably easy to allow
> this I'll take a look but wont get to it until next week. In the
> meantime I'll see what other sort of comments pop up.

Thanks. It will be great if we can enable all tx-queues somehow.

>
> This is only observable with a small number of flows correct? With
> many flows the distribution should be fair.

Right now we have only experimented with 5 flows. Not sure with larger
number of flows.

>
>>
>> Best,
>> Ming
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
