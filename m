From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Packet dropps in virtual tap interface
Date: Tue, 24 Feb 2015 09:03:48 -0800
Message-ID: <54ECAEF4.1060602@hp.com>
References: <54EC24FF.3000407@marathonbet.ru> <54EC25E3.5050602@marathonbet.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Michael Kazakov <michael@marathonbet.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:54569 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbbBXRDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:03:50 -0500
In-Reply-To: <54EC25E3.5050602@marathonbet.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2015 11:18 PM, Michael Kazakov wrote:
>
>
> Hello. We use our highly load system in OpenStack environment. And faced
> with serious problems in network highload guests. At a relatively high
> CPU load of hypervisor (40-60%) virtual network interfaces of this
> guests starts to droppart of the packets. We use for virtualization
> qemu-kvm with vhost driver: "... -netdev
> tap,fd=30,id=hostnet0,vhost=on,vhostfd=31 -device
> virtio-net-pci,netdev=hostnet0,id=net0,mac=fa:16:3e:86:67:7b,bus=pci.0,addr=0x3...".
>
>
> The problem can be seen with the ifconfig utility:
> tape4009073-0b Link encap:Ethernet  HWaddr fe:16:3e:86:67:7b
>            inet6 addr: fe80::fc16:3eff:fe86:677b/64 Scope:Link
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:1587622634 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:1484106438 errors:0 dropped:460259 overruns:0
> carrier:0
>            collisions:0 txqueuelen:500
>            RX bytes:877878711500 (877.8 GB)  TX bytes:3071846828531 (3.0
> TB)
>
> Could you do a little look at our problem and give advice which
> direction to continue our investigation?

If I recall the OpenStack plumbing correctly, the TX direction on the 
tap device is inbound to the instance.  You could, I suppose, try 
increasing the size of the txqueuelen via ifconfig, but you may want to 
triple check that the KVM I/O thread (?) isn't running at 100%. 
Particularly if when you say the hypervisor is running at 40-60% CPU 
utilization you mean overall CPU utilization of a multiple CPU system.

I'm assuming that in broad handwaving terms, the TX queue of the tap 
device is behaving something like the SO_RCVBUF of a UDP socket would in 
a "normal"  system - if the VM (tap device case) or receiving process 
(UDP socket case) is held-up for a little while, that buffer is there to 
try to pick-up the slack.  If the VM is held-off from running long 
enough that queue will overflow and traffic will be dropped.

That might be the "raising the bridge" side of things.  The "lower the 
river" side might be to find-out why and for how long the VM is being 
held-off from running and see if you can address that.

rick jones
