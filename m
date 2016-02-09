From: John <john.phillips5@hpe.com>
Subject: Mellanox ConnectX3 Pro and kernel 4.4 low throughput bug
Date: Tue, 9 Feb 2016 13:21:34 -0700
Message-ID: <56BA4A4E.4050703@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t4625.austin.hp.com ([15.73.212.76]:34541 "EHLO
	g2t4625.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbcBIU1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 15:27:32 -0500
Received: from g1t6216.austin.hp.com (g1t6216.austin.hp.com [15.73.96.123])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t4625.austin.hp.com (Postfix) with ESMTPS id AA7543F3D
	for <netdev@vger.kernel.org>; Tue,  9 Feb 2016 20:27:31 +0000 (UTC)
Received: from g2t4689.austin.hpicorp.net (g2t4689.austin.hpicorp.net [15.94.10.175])
	by g1t6216.austin.hp.com (Postfix) with ESMTP id 092306B
	for <netdev@vger.kernel.org>; Tue,  9 Feb 2016 20:27:31 +0000 (UTC)
Received: from [16.78.178.194] (zzzzzzzzz.americas.hpqcorp.net [16.78.178.194])
	by g2t4689.austin.hpicorp.net (Postfix) with ESMTP id CE61435
	for <netdev@vger.kernel.org>; Tue,  9 Feb 2016 20:27:30 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     I'm running into a bug with kernel 4.4.0 where a VM-VM test between two
different baremetal hosts (HP Proliant dl360gen9s) has receive-side 
throughput
that's about 25% lower than expected with a Mellanox ConnectX3-pro NIC. 
The VMs
are connected over a VXLAN tunnel that I used OpenvSwitch 2.4.90 to set 
up on
both hosts. When the mellanox NIC is the endpoint of the vxlan tunnel 
and its VM
receives a throughput test the VM gets about 6.65Gb/s throughput where other
NICs get ~8.3Gb/s (8.04 for niantic, 8.65 for broadcom). When I test the
mellanox in a (patched) 3.14.57 kernel, I get 8.9Gb/s between VMs. I 
have traced
the issue as far as a TUN interface that 'plugs in' to openvswitch, 
which takes
packets for the VM. If I run tcpdump on this tun interface (called vnet0 
in my
case), I get small tcp packets - they're all 1398 in length - when I do 
a VM-VM
test. I also see high CPU usage for the vhost kernel thread. If I run ftrace
during a throughput test and grep for the vhost thread (once done), and 
wc -l
the result there is an order of magnitude more function calls in this thread
versus the same thing with the broadcom. If I do the same test with a 
broadcom
NIC as the endpoint for the vxlan tunnel, I get large packets - the size 
varies
but generally it's in the five digit range - some are almost 65535. 
There are
fewer calls in the vhost thread, as mentioned above. This is also visible in
top, the vhost kernel thread and the libvirt+ process both have noticeably
higher CPU usage.

     I've tried doing a bisect of the kernel and figuring out where the 
change
occurred that allowed the broadcom NIC to perform GRO but not the 
mellanox. I
know that between 4.2 and 4.3 the tun device started to perform GRO and 
this is
where the difference in throughput started. However there's something 
between
these two versions that breaks my setup completely and I can't get any 
kind of
traffic to or from the VM from anywhere. I tried to draw a diagram here:

|-high CPU%
->[mlx4_en/core]---->[vxlan]--->[openvswitch]--->[tun]---->[vhost]--->VM
                                                    |-small packets (1398)

|-low CPU%
->[bnx2x ]---->[vxlan]--->[openvswitch]--->[tun]---->[vhost]--->VM
                                                    |-big packets (~65535)


NIC info:

root@hLinux-ovstest-1:/home/john# ethtool -i rename8
driver: mlx4_en
version: 2.2-1 (Feb 2014)
firmware-version: 2.34.5010
bus-info: 0000:08:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: yes

root@hLinux-ovstest-1:/home/john# ethtool -k rename8
Features for rename8:
rx-checksumming: on
tx-checksumming: on
         tx-checksum-ipv4: on
         tx-checksum-ip-generic: off [fixed]
         tx-checksum-ipv6: on
         tx-checksum-fcoe-crc: off [fixed]
         tx-checksum-sctp: off [fixed]
scatter-gather: on
         tx-scatter-gather: on
         tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
         tx-tcp-segmentation: on
         tx-tcp-ecn-segmentation: off [fixed]
         tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: on [requested off]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: on [fixed]

root@hLinux-ovstest-1:/home/john# lspci -vvs 0000:08:00.0
08:00.0 Ethernet controller: Mellanox Technologies MT27520 Family 
[ConnectX-3 Pro]
         Subsystem: Hewlett-Packard Company Device 801f
         Physical Slot: 1
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 0
         Region 0: Memory at 96000000 (64-bit, non-prefetchable) [size=1M]
         Region 2: Memory at 94000000 (64-bit, prefetchable) [size=32M]
         Capabilities: [40] Power Management version 3
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [48] Vital Product Data
                 Product Name: HP Ethernet 10G 2-port 546SFP+ Adapter
                 Read-only fields:
                         [PN] Part number: 779793-B21
                         [EC] Engineering changes: A-5522
                         [SN] Serial number: IL2521040D
                         [V0] Vendor specific: PCIe 10GbE x8 6W
                         [V2] Vendor specific: 5522
                         [V4] Vendor specific: 5065F3857BE0
                         [V5] Vendor specific: 0A
                         [VA] Vendor specific: 
HP:V2=MFG:V3=FW_VER:V4=MAC:V5=PCAR
                         [VB] Vendor specific: HP ConnectX-3Pro SFP+
                         [RV] Reserved: checksum good, 0 byte(s) reserved


Tun interface information:
root@hLinux-ovstest-1:/home/john# ip link show dev vnet0
15: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue 
master ovs-system state UNKNOWN mode DEFAULT group default qlen 500
     link/ether fe:54:00:12:2b:f2 brd ff:ff:ff:ff:ff:ff

root@hLinux-ovstest-1:/home/john# ovs-vsctl show
6b886f7e-dc7e-41fa-bc15-27289cee7679
     Bridge "br0"
         Port "br0"
             Interface "br0"
                 type: internal
         Port "vxlan0"
             Interface "vxlan0"
                 type: vxlan
                 options: {dst_port="4789", key="99", remote_ip="10.0.1.5"}
         Port "veth0"
             Interface "veth0"
         Port "vnet0"
             Interface "vnet0"
     ovs_version: "2.4.90"

root@hLinux-ovstest-1:/home/john# ethtool -i vnet0
driver: tun
version: 1.6
firmware-version:
bus-info: tap
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no


Thanks,
   John
