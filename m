From: Tomas Corej <tomas.corej@websupport.sk>
Subject: bnx2x SR-IOV PF/VF network issues
Date: Wed, 29 Apr 2015 12:18:55 +0000 (UTC)
Message-ID: <loom.20150429T131959-999@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36332 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422869AbbD2MuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 08:50:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YnRRE-00024W-3E
	for netdev@vger.kernel.org; Wed, 29 Apr 2015 14:50:04 +0200
Received: from blackhole.sk ([37.9.168.56])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 14:50:04 +0200
Received: from tomas.corej by blackhole.sk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 14:50:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm trying to use BCM57810 SR-IOV functionality in VM but I have 
communication issues between PF and VF on same card. I'm sorry if this is 
wrong mailing list, but I'm struggling with this issue for over few months. 
The issue persist across various FW,kernel and driver versions, so maybe
it is only misconfiguration.

Technical info:

Server: Dell PowerEdge M620
OS: Ubuntu 14.04
Kernel: 3.18.11-031811-generic, 3.13.0-49, 4.0.0-040000
Openstack: Icehouse 2014.1.2
Openvswitch: 2.3.1
Driver version: 1.710.51-0
Firmware-version: FFV7.12.17 bc 7.12.4
QEMU: 2.1.3
MTU: 9000
SR-IOV: enabled in NIC bios and system BIOS


I have three VM on host (Openstack compute node), 
- one that is connected through openvswitch to network (10.10.5.25) through 
bond0 
- two with SR-IOV interfaces from eth0 (10.10.5.26 and 10.10.5.30)

Host's network is done through bond0 interfaces from interfaces eth0 and 
eth1 (active-passive).Those eth interfaces are two ports of same NIC and 
they're connected to different switches (no LACP).

Issue is that I cannot ping VM on PF from VM with SR-IOV interface if 
active slave of bonding is on same NIC as VM's SR-IOV interfaces. 

I'm able to ping VM on PF if bonding is not on the same interface as SR-IOV 
interfaces.

Example:

hypervisor:/proc/net/bonding# grep Active bond0
Currently Active Slave: eth0

On VM 10.10.5.30:

10.10.5.30:~# ping -c 1 10.10.5.25
PING 10.10.5.25 (10.10.5.25) 56(84) bytes of data.

--- 10.10.5.25 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

However I'm able to ping second VM with SR-IOV interface, so VF<->VF is 
working:

10.10.5.30:~# ping -c 1 10.10.5.26
PING 10.10.5.26 (10.10.5.26) 56(84) bytes of data.
64 bytes from 10.10.5.26: icmp_req=1 ttl=64 time=0.183 ms

--- 10.10.5.26 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.183/0.183/0.183/0.000 ms


Then I switch bonding to eth1:
hypervisor:/proc/net/bonding# ifenslave -c bond0 eth1
hypervisor:/proc/net/bonding# grep Active bond0
Currently Active Slave: eth1

and try to ping again host that was unreachable early:

10.10.5.30:~# ping -c 1 10.10.5.25
PING 10.10.5.25 (10.10.5.25) 56(84) bytes of data.
64 bytes from 10.10.5.25: icmp_req=1 ttl=64 time=2.18 ms

--- 10.10.5.25 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2.182/2.182/2.182/0.000 ms

which is succesful. 

What have I tried:
- different versions of firmware, kernel driver and kernel
- various configuration of mtu and mac/vlan setup through ip link set dev 
eth0 vf ...
- setting eth features through ethtool (offloading features, loopback)
- I thought that problem would be in internal TX switching which I tried to 
turn off in driver. I had to patch it and recompile. Issue persist 
regardles of Tx switching feature is enabled or disabled.
- partition eth devices with NPAR and use SR-IOV from different interface 
than eth0/eth1. 
- I have same exact server/setup but with Intel X540 NICs where I could not 
replicate issue. It is working regardles of active slave of bonding.

Do you have any idea where could be a problem ? I would be happy to provide 
you additional information.

Best Regards,
