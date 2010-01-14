From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Thu, 14 Jan 2010 14:56:33 -0800
Message-ID: <20100114145633.4c2d4ac6@nehalam>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36960 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754774Ab0ANW4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 17:56:51 -0500
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

Why not make a kobject out of cpus which would add subdirectory.
This would keep interface consistent with the one value per file
semantic of sysfs.
