From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Mon, 06 Apr 2015 19:48:38 -0700
Message-ID: <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34857 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbbDGCsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 22:48:41 -0400
Received: by iggg4 with SMTP id g4so1308287igg.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 19:48:40 -0700 (PDT)
In-Reply-To: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-07 at 00:45 +0200, Jan Engelhardt wrote:
> I have here a Linux 3.19(.0) system where activated TSO on a veth slave 
> device makes IPv4-TCP transfers going into that veth-connected container 
> progress slowly.
> 
> 
> Host side (hv03):
> hv03# ip l
> 2: ge0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast 
> state UP mode DEFAULT group default qlen 1000 [Intel 82579LM]
> 7: ve-build01: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
> pfifo_fast state UP mode DEFAULT group default qlen 1000 [veth]
> hv03# ethtool -k ve-build01
> Features for ve-build01:
> rx-checksumming: on
> tx-checksumming: on
>         tx-checksum-ipv4: off [fixed]
>         tx-checksum-ip-generic: on
>         tx-checksum-ipv6: off [fixed]
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: off [fixed]
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: on
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: on
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: off [fixed]
> receive-hashing: off [fixed]
> highdma: on
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: on [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: on
> tx-ipip-segmentation: on
> tx-sit-segmentation: on
> tx-udp_tnl-segmentation: on
> fcoe-mtu: off [fixed]
> tx-nocache-copy: off
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: on
> rx-vlan-stag-hw-parse: on
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> busy-poll: off [fixed]
> 
> 
> Guest side (build01):
> build01# ip l
> 2: host0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast 
> state UP mode DEFAULT group default qlen 1000
> build01# ethtool -k host0
> Features for host0:
> rx-checksumming: on
> tx-checksumming: on
>         tx-checksum-ipv4: off [fixed]
>         tx-checksum-ip-generic: on
>         tx-checksum-ipv6: off [fixed]
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: off [fixed]
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: on
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: on
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: off [fixed]
> receive-hashing: off [fixed]
> highdma: on
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: on [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: on
> tx-ipip-segmentation: on
> tx-sit-segmentation: on
> tx-udp_tnl-segmentation: on
> fcoe-mtu: off [fixed]
> tx-nocache-copy: off
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: on
> rx-vlan-stag-hw-parse: on
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> busy-poll: off [fixed]
> 
> 
> Using an independent machine, I query a xinetd-chargen sample service
> to send a sufficient number of bytes through the pipe.
> 
> ares40# traceroute build01
> traceroute to build01 (x), 30 hops max, 60 byte packets
>  1  hv03 ()  0.713 ms  0.663 ms  0.636 ms
>  2  build01 ()  0.905 ms  0.882 ms  0.858 ms
> 
> ares40$ socat tcp4-connect:build01:19 - | pv >/dev/null
>  480KiB 0:00:05 [91.5KiB/s] [    <=>             ]
> 1.01MiB 0:00:11 [91.1KiB/s] [          <=>       ]
> 1.64MiB 0:00:18 [ 110KiB/s] [                <=> ]
> 
> (PV is the Pipe Viewer, showing throughput.)
> 
> It hovers between 80 and 110 kilobytes/sec, which is 600-fold lower
> than what I would normally see. Once TSO is turned off on the
> container-side interface:
> 
> build01# ethtool -K host0 tso off
> (must be host0 // doing it on ve-build01 has no effect)
> 
> I observe restoration of expected throughput:
> 
> ares40$ socat tcp4-connect:build01:19 - | pv >/dev/null
>  182MiB 0:02:05 [66.1MiB/s] [                       <=> ]
> 
> 
> This problem does not manifest when using IPv6.
> The problem also does not manifest if the TCP4 connection is kernel-local,
> e.g. hv03->build01.
> The problem also does not manifest if the TCP4 connection is outgoing, 
> e.g. build01->ares40.
> IOW, the tcp4 listening socket needs to be inside a veth-connected 
> container.

Hi Jan

Nothing comes to mind. It would help if you could provide a script to
reproduce the issue.

I've tried the following on current net-next :

lpaa23:~# cat veth.sh
#!/bin/sh
#This script has to be launched as root
#
brctl addbr br0
ip addr add 192.168.64.1/24 dev br0
ip link set br0 up
ip link add name ext0 type veth peer name int0
ip link set ext0 up
brctl addif br0 ext0
ip netns add vnode0
ip link set dev int0 netns vnode0
ip netns exec vnode0 ip addr add 192.168.64.2/24 dev int0 
ip netns exec vnode0 ip link set dev int0 up
ip link add name ext1 type veth peer name int0
ip link set ext1 up
brctl addif br0 ext1
ip netns add vnode1
ip link set dev int0 netns vnode1
ip netns exec vnode1 ip addr add 192.168.64.3/24 dev int0
ip netns exec vnode1 ip link set dev int0 up

ip netns exec vnode0 netserver &
sleep 1
ip netns exec vnode1 netperf -H 192.168.64.2 -l 10

# Cleanup
ip netns exec vnode0 killall netserver
ifconfig br0 down ; brctl delbr br0
ip netns delete vnode0 ; ip netns delete vnode1


lpaa23:~# ./veth.sh
Starting netserver with host 'IN(6)ADDR_ANY' port '12865' and family AF_UNSPEC
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.64.2 () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    14924.09   

Seems pretty honest result.
