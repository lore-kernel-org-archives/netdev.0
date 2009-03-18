From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [lxc-devel] Poor bridging performance on 10 GbE
Date: Wed, 18 Mar 2009 11:10:03 +0100
Message-ID: <49C0C87B.7070507@fr.ibm.com>
References: <b30d1c3b0903180221h5175618eue162ffdec3817b4c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lxc-devel@lists.sourceforge.net,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:60294 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbZCRKK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 06:10:59 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate5.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2IAA4ed600844
	for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 10:10:05 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2IAA4dv3416192
	for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 10:10:04 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2IAA4PN025220
	for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 10:10:04 GMT
In-Reply-To: <b30d1c3b0903180221h5175618eue162ffdec3817b4c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano wrote:
> Hi all,
> 
> I am evaluating the networking performance of lxc on 10 Gigabit Ethernet by
> using netperf benchmark.

Thanks for doing benchmarking.
I did two years ago similar tests and there is an analysis of the 
performances at:
http://lxc.sourceforge.net/network/benchs.php

It is not up to date, but that will give you some clues of what is 
happening with this overhead.

> Using a macvlan device, the throughput was 9.6 Gbps. But, using a veth device,
> the throughput was only 2.7 Gbps.

Yeah, definitively the macvlan interfaces is the best in terms of 
performances but with the restriction of not being able to communicate 
between containers on the same hosts.

There are some discussions around that:

http://marc.info/?l=linux-netdev&m=123643508124711&w=2

The veth is a virtual device hence it has not offloading. When the 
packet are sent out, the network stack looks at the nic offloading 
capability which is not present. So the kernel will compute the 
checksums instead of letting the nic to do that either if the packet is 
transmitted through the physical nic. This is a well known issue related 
to network virtualization and xen has developed a specific network driver:
http://www.cse.psu.edu/~bhuvan/teaching/spring06/papers/xen-net-opt.pdf

> I think this is because the overhead of bridging devices is high.

Yes, bridging adds some overhead and AFAIR bridging + netfilter does 
some skb copy.

> I also checked the host OS's performance when I used a veth device.
> I observed a strange phenomenon.
> 
> Before issuing lxc-start command, the throughput was 9.6 Gbps.
> Here is the output of brctl show:
> 	$ brctl show
> 	bridge name	bridge id		STP enabled	interfaces
> 	br0		8000.0060dd470d49	no		eth1
> 
> After issuing lxc-start command, the throughput decreased to 3.2 Gbps.
> Here is the output of brctl show:
> 	$ sudo brctl show
> 	bridge name	bridge id		STP enabled	interfaces
> 	br0		8000.0060dd470d49	no		eth1
> 								veth0_7573
> 
> I wonder why the performance is greatly influenced by adding a veth device
> to a bridge device.

Hmm, good question :)

> Here is my experimental setting:
> 	OS: Ubuntu server 8.10 amd64
> 	Kernel: 2.6.27-rc8 (checkout from the lxc git repository)

I would recommend to use the 2.6.29-rc8 vanilla because this kernel does 
no longer need patches, a lot of fixes were done in the network 
namespace and maybe the bridge has been improved in the meantime :)

> 	Userland tool: 0.6.0
> 	NIC: Myricom Myri-10G
> 
> Any comments and suggestions will be appreciate.
> If this list is not proper place to talk about this problem, can anyone tell me
> the proper one?

The performances question is more related to the network virtualization 
implementation and should be sent to netdev@ and containers@ (added in 
the Cc' of this email), of course people at lxc-devel@ will be 
interested by these aspects, so lxc-devel@ is the right mailing list too.

Thanks for your testings
   -- Daniel
