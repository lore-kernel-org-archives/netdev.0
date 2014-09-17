From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Wed, 17 Sep 2014 07:59:51 -0700
Message-ID: <5419A1E7.8040109@intel.com>
References: <20140917152653.1c824a22@redhat.com> <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11695 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755672AbaIQO7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2014 10:59:52 -0400
In-Reply-To: <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/2014 07:32 AM, Eric Dumazet wrote:
> On Wed, 2014-09-17 at 15:26 +0200, Jesper Dangaard Brouer wrote:
>> The CPU to TXQ binding behavior of ixgbe vs. igb NIC driver are
>> somehow different.  Normally I setup NIC IRQ-to-CPU bindings 1-to-1,
>> with script set_irq_affinity [1].
>>
>> For forcing use of a specific HW TXQ, I normally force the CPU binding
>> of the process, either with "taskset" or with "netperf -T lcpu,rcpu".
>>
>> This works fine with driver ixgbe, but not with driver igb.  That is
>> with igb, the program forced to specific CPU, can still use another
>> TXQ. What am I missing?
>>
>>
>> I'm monitoring this with both:
>>  1) watch -d sudo tc -s -d q ls dev ethXX
>>  2) https://github.com/ffainelli/bqlmon
>>
>> [1] https://github.com/netoptimizer/network-testing/blob/master/bin/set_irq_affinity
> 
> Have you setup XPS ?
> 
> echo 0001 >/sys/class/net/ethX/queues/tx-0/xps_cpus
> echo 0002 >/sys/class/net/ethX/queues/tx-1/xps_cpus
> echo 0004 >/sys/class/net/ethX/queues/tx-2/xps_cpus
> echo 0008 >/sys/class/net/ethX/queues/tx-3/xps_cpus
> echo 0010 >/sys/class/net/ethX/queues/tx-4/xps_cpus
> echo 0020 >/sys/class/net/ethX/queues/tx-5/xps_cpus
> echo 0040 >/sys/class/net/ethX/queues/tx-6/xps_cpus
> echo 0080 >/sys/class/net/ethX/queues/tx-7/xps_cpus
> 
> Or something like that, depending on number of cpus and TX queues.
> 

That was what I was thinking as well.

ixgbe has ATR which makes use of XPS to setup the transmit queues for a
1:1 mapping.  The receive side of the flow is routed back to the same Rx
queue through flow director mappings.

In the case of igb it only has RSS and doesn't set a default XPS
configuration.  So you should probably setup XPS and you might also want
to try and make use of RPS to try and steer receive packets since the Rx
queues won't match the Tx queues.

Thanks,

Alex
