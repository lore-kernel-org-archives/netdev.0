From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Fri, 26 Jun 2015 12:31:43 -0700
Message-ID: <3036c2aaa52dc2817e674a77b5eac24d@imap.linux.ibm.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
 <CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
 <0b2eff60824ac7b7d3a672da9be9bf99@imap.linux.ibm.com>
 <CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
 <3df94e04daebca29c94b6d32fb372177@imap.linux.ibm.com>
 <CALx6S35-GKW+hgn-9Y5a87hETfetKuusALFUDZ5vzwrtQSiypA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	pradeeps@linux.vnet.ibm.com, J Kidambi <jkidambi@us.ibm.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:49399 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbbFZTbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 15:31:47 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Fri, 26 Jun 2015 13:31:47 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A5CB819D8026
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 13:22:45 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5QJVMmg40501476
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 12:31:22 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5QJVhYe021610
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 13:31:45 -0600
In-Reply-To: <CALx6S35-GKW+hgn-9Y5a87hETfetKuusALFUDZ5vzwrtQSiypA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-06-26 11:04, Tom Herbert wrote:
>> I am testing the simplest configuration which has 1 TCP flow generated 
>> by
>> iperf from
>> a VM connected to a linux bridge with a vxlan tunnel interface. The 
>> 10G nic
>> (82599 ES) has
>> multiple receive queues, but in this simple test, it is likely 
>> immaterial
>> (because, the
>> tuple on which it hashes would be fixed). The real difference in 
>> performance
>> appears to
>> be whether or not vxlan gro is performed by software.
>> 
> 
> Please do "ethtool -k vxlan0" of whatever interface is for vxlan.
> Ensure GRO is "on", if not enable it on the interface by "ethtool _k
> vxlan0 gro on". Run iperf and to tcpdump on the vxlan interface to
> verify GRO is being done. If we are seeing performance degradation
> when GRO is being done at tunnel versus device that would be a
> different problem than no GRO being done at all.

Heres more details on the test.

gro is "on" on the device and the tunnel. tcpdump on the vxlan interface 
show un-aggregated packets

[root@ramu1 tracing]# tcpdump -i vxlan0
<snip>
ptions [nop,nop,TS val 1972850548 ecr 193703], length 1398
14:14:38.911955 IP 1.1.1.21.44134 > 1.1.1.11.commplex-link: Flags [.], 
seq 224921449:224922847, ack 1, win 221, options [nop,nop,TS val 
1972850548 ecr 193703], length 1398
14:14:38.911957 IP 1.1.1.21.44134 > 1.1.1.11.commplex-link: Flags [.], 
seq 224922847:224924245, ack 1, win 221, options [nop,nop,TS val 
1972850548 ecr 193703], length 1398
14:14:38.911958 IP 1.1.1.21.44134 > 1.1.1.11.commplex-link: Flags [.], 
seq 224924245:224925643, ack 1, win 221, options [nop,nop,TS val 
1972850548 ecr 193703], length 1398
14:14:38.911959 IP 1.1.1.21.44134 > 1.1.1.11.commplex-link: Flags [.], 
seq 224925643:224927041, ack 1, win 221, options [nop,nop,TS val 
1972850548 ecr 193703], length 1398

In the kernel trace I dont see "vxlan_gro_receive" being hit at all.

[root@localhost ~]# ./iperf -s -i 2
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 1.1.1.11 port 5001 connected with 1.1.1.21 port 44135
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 2.0 sec   503 MBytes  2.11 Gbits/sec


With the proposed patch (and everything else remaining the same) tcpdump 
shows aggregated frames like this:

[root@ramu1 perf]# tcpdump -i vxlan0
<snip>
14:29:50.961380 IP 1.1.1.21.44138 > 1.1.1.11.commplex-link: Flags [.], 
seq 24565681:24629989, ack 1, win 221, options [nop,nop,TS val 
1973762616 ecr 4294793113], length 64308
14:29:50.961506 IP 1.1.1.11.commplex-link > 1.1.1.21.44138: Flags [.], 
ack 24629989, win 21888, options [nop,nop,TS val 4294793113 ecr 
1973762616], length 0
14:29:50.961463 IP 1.1.1.21.44138 > 1.1.1.11.commplex-link: Flags [.], 
seq 24629989:24694297, ack 1, win 221, options [nop,nop,TS val 
1973762616 ecr 4294793113], length 64308
14:29:50.961518 IP 1.1.1.21.44138 > 1.1.1.11.commplex-link: Flags [.], 
seq 24694297:24758605, ack 1, win 221, options [nop,nop,TS val 
1973762616 ecr 4294793113], length 64308
14:29:50.961655 IP 1.1.1.11.commplex-link > 1.1.1.21.44138: Flags [.], 
ack 24694297, win 21932, options [nop,nop,TS val 4294793113 ecr 
1973762616], length 0
14:29:50.961626 IP 1.1.1.21.44138 > 1.1.1.11.commplex-link: Flags [P.], 
seq 24758605:24822913, ack 1, win 221, options [nop,nop,TS val 
1973762616 ecr 4294793113], length 64308


[root@localhost ~]# ./iperf -s -i 2
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 1.1.1.11 port 5001 connected with 1.1.1.21 port 44136
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 2.0 sec  1.64 GBytes  7.04 Gbits/sec
[  4]  2.0- 4.0 sec  1.98 GBytes  8.48 Gbits/sec
[  4]  4.0- 6.0 sec  1.98 GBytes  8.52 Gbits/sec
[  4]  6.0- 8.0 sec  1.99 GBytes  8.53 Gbits/sec

kernel trace shows vxlan_gro_receive being hit.


Topology:
---------

VM1 ---bridge 
(br_perf)---vxlan0----10Gnic(int4)-----10Gnic---vxlan0----bridge 
(br_perf)---VM2

MTUs:
   VM        (1450)
   br_perf   (9000)
   vxlan0    (9000)
   int4      (9000)

Hw/Sw Adapter, Drivers
-----------------------

02:00.0 Ethernet controller: Intel Corporation 82599ES 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)

[root@ramu1 ~]# ethtool -i int4
driver: ixgbe
version: 4.0.1-k-rh7.1
firmware-version: 0x80000208
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

Config HOST1:
-------------

[root@ramu1 perf]# cat docfg.sh
ip link del vxlan0
ip link set dev br_perf down
brctl delbr br_perf

brctl addbr br_perf
ip link set dev br_perf up
ip link add vxlan0 mtu 9000 type vxlan id 1 l2miss l3miss rsc proxy 
nolearning dstport 8472
ip link set dev vxlan0 up
brctl addif br_perf vxlan0

ip neigh add 1.1.1.21 lladdr 52:54:00:17:c8:4d dev vxlan0 nud permanent

bridge fdb replace 52:54:00:17:c8:4d  dev vxlan0 self permanent dst 
10.50.117.216


Config VM1:
-----------
eth0 IP,MAC:  1.1.1.11, 52:54:00:6c:53:61

CPU affinity for both VMs
--------------------------
[root@ramu1 perf]# virsh vcpuinfo centos-6.5
VCPU:           0
CPU:            N/A
State:          N/A
CPU time        N/A
CPU Affinity:   ---y------------------------------------

Iptables disabled on bridges
------------------------------
echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables

Offload Settings both hosts are at default
-------------------------------------------

[root@ramu1 perf]# ethtool -k int4
Features for int4:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: on
	tx-checksum-fcoe-crc: on [fixed]
	tx-checksum-sctp: on
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
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: on [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: on [fixed]



[root@ramu1 perf]# ethtool -k br_perf
Features for br_perf:
rx-checksumming: off [fixed]
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [requested on]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: on
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [requested on]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: on [fixed]
tx-gso-robust: off [requested on]
tx-fcoe-segmentation: off [requested on]
tx-gre-segmentation: on
tx-ipip-segmentation: on
tx-sit-segmentation: on
tx-udp_tnl-segmentation: on
tx-mpls-segmentation: on
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]







[root@ramu1 perf]# ethtool -k vxlan0
Features for vxlan0:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: on
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: on [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: on
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]
[root@ramu1 perf]#
