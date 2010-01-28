From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Wed, 27 Jan 2010 22:04:52 -0800
Message-ID: <20100127220452.445e9047@nehalam>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47082 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289Ab0A1GE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 01:04:58 -0500
In-Reply-To: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jan 2010 13:56:23 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> This patch implements software receive side packet steering (RPS).  RPS
> distributes the load of received packet processing across multiple CPUs.
> 
> Problem statement: Protocol processing done in the NAPI context for received
> packets is serialized per device queue and becomes a bottleneck under high
> packet load.  This substantially limits pps that can be achieved on a single
> queue NIC and provides no scaling with multiple cores.
> 
> This solution queues packets early on in the receive path on the backlog queues
> of other CPUs.   This allows protocol processing (e.g. IP and TCP) to be
> performed on packets in parallel.   For each device (or NAPI instance for
> a multi-queue device) a mask of CPUs is set to indicate the CPUs that can
> process packets for the device. A CPU is selected on a per packet basis by
> hashing contents of the packet header (the TCP or UDP 4-tuple) and using the
> result to index into the CPU mask.  The IPI mechanism is used to raise
> networking receive softirqs between CPUs.  This effectively emulates in
> software what a multi-queue NIC can provide, but is generic requiring no device
> support.
> 
> Many devices now provide a hash over the 4-tuple on a per packet basis
> (Toeplitz is popular).  This patch allow drivers to set the HW reported hash
> in an skb field, and that value in turn is used to index into the RPS maps.
> Using the HW generated hash can avoid cache misses on the packet when
> steering the packet to a remote CPU.
> 
> The CPU masks is set on a per device basis in the sysfs variable
> /sys/class/net/<device>/rps_cpus.  This is a set of canonical bit maps for
> each NAPI nstance of the device.  For example:
> 
> echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus
> 
> would set maps for four NAPI instances on eth0.
> 
> Generally, we have found this technique increases pps capabilities of a single
> queue device with good CPU utilization.  Optimal settings for the CPU mask
> seems to depend on architectures and cache hierarcy.  Below are some results
> running 500 instances of netperf TCP_RR test with 1 byte req. and resp.
> Results show cumulative transaction rate and system CPU utilization.
> 
> e1000e on 8 core Intel
>     Without RPS: 90K tps at 33% CPU
>     With RPS:    239K tps at 60% CPU
> 
> foredeth on 16 core AMD
>     Without RPS: 103K tps at 15% CPU
>     With RPS:    285K tps at 49% CPU
> 
> Caveats:
> - The benefits of this patch are dependent on architecture and cache hierarchy.
> Tuning the masks to get best performance is probably necessary.
> - This patch adds overhead in the path for processing a single packet.  In
> a lightly loaded server this overhead may eliminate the advantages of
> increased parallelism, and possibly cause some relative performance degradation.
> We have found that RPS masks that are cache aware (share same caches with
> the interrupting CPU) mitigate much of this.
> - The RPS masks can be changed dynamically, however whenever the mask is changed
> this introduces the possbility of generating out of order packets.  It's
> probably best not change the masks too frequently.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> 

I started playing and looking more closely at this.
1. CPU and several of the other parameters like backlog should be unsigned
   to avoid possible problems
2. __netif_receive_skb() can be static so gcc can optimize better
3. Not sure if it works or not with devices like sky2 that can have
   two netdevice's sharing same NAPI instance because both ports have
   shared irq.



-- 
