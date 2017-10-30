From: Marco Berizzi <pupilla@libero.it>
Subject: u32 match ip src
Date: Mon, 30 Oct 2017 14:30:59 +0100 (CET)
Message-ID: <1037397817.181788.1509370260042@mail.libero.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-32.italiaonline.it ([213.209.10.32]:47961 "EHLO libero.it"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751532AbdJ3NjL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 09:39:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks,

Sorry for writing to you, but I'm dealing with a very weird problem.
I'm monitoring a network wan link traffic with a linux box with two NIC:
one nic is for regular ipv4 network connectivity (eth0), and the other
nic (eth1) is for sniffing all packets coming from an HPE 5510 switch:
here is the relevant HPE 5510 configuration:

interface GigabitEthernet1/0/19
 port link-mode bridge
 port access vlan 10
 combo enable copper
 mirroring-group 1 monitor-port

interface GigabitEthernet1/0/24
 port link-mode bridge
 port access vlan 10
 combo enable copper
 mirroring-group 1 mirroring-port both

The sniffing nic (eth1) is connected to the 1/0/19 interface. All traffic
sent/received to the 1/0/24 interface is mirrored to the 1/0/19 interface.

I'm running this script/configuration:

modprobe ifb
tc qdisc del dev eth1 ingress
tc qdisc add dev eth1 ingress

ip link set dev eth1 up
ip link set dev ifb0 up
ip link set dev ifb1 up
ip link set eth1 promisc on

tc filter add dev eth1 parent ffff: protocol ip prio 10 u32 \
match ip src 10.81.120.0/21 \
action mirred egress redirect dev ifb0

tc filter add dev eth1 parent ffff: protocol ip prio 10 u32 \
match ip dst 10.81.120.0/21 \
action mirred egress redirect dev ifb1

What I'm trying to do, is to split the upload traffic from the download
traffic. On the eth1 I will obviously see all packets as received.

The problem is that the 'match ip src 10.81.120.0/21' is not matching any
packets, but 'tcpdump -pnvi eth1 src net 10.81.120.0/21' will catch a lot
of them (so I'm deducing the HPE switch configuration is fine: I see all
packets on the eth1). Here is the output from 'tc -s -p -d filter show
dev eth1 ingress':

filter parent ffff: protocol ip pref 10 u32 chain 0 
filter parent ffff: protocol ip pref 10 u32 chain 0 fh 800: ht divisor 1 
filter parent ffff: protocol ip pref 10 u32 chain 0 fh 800::800 order 2048 key ht 800 bkt 0 terminal flowid ??? not_in_hw 
  match IP src 10.81.120.0/21
        action order 1: mirred (Egress Redirect to device ifb0) stolen
        index 52 ref 1 bind 1 installed 107 sec used 0 sec
        Action statistics:
        Sent 7563 bytes 148 pkt (dropped 0, overlimits 0 requeues 0) 
        backlog 0b 0p requeues 0 

filter parent ffff: protocol ip pref 10 u32 chain 0 fh 800::801 order 2049 key ht 800 bkt 0 terminal flowid ??? not_in_hw 
  match IP dst 10.81.120.0/21
        action order 1: mirred (Egress Redirect to device ifb1) stolen
        index 53 ref 1 bind 1 installed 107 sec
        Action statistics:
        Sent 163495008 bytes 216362 pkt (dropped 0, overlimits 0 requeues 0) 
        backlog 0b 0p requeues 0 

A cloned linux machine (same hardware and software) on another subnet with
a different switch (cisco vs HPE) is working flawlessly:

filter parent ffff: protocol ip pref 10 u32 chain 0 
filter parent ffff: protocol ip pref 10 u32 chain 0 fh 800: ht divisor 1 
filter parent ffff: protocol ip pref 10 u32 chain 0 fh 800::800 order 2048 key ht 800 bkt 0 terminal flowid ??? not_in_hw 
  match IP src 10.81.136.0/21
        action order 1: mirred (Egress Redirect to device ifb0) stolen
        index 11 ref 1 bind 1 installed 10232 sec
        Action statistics:
        Sent 3252966422 bytes 14687184 pkt (dropped 0, overlimits 0 requeues 0) 
        backlog 0b 0p requeues 0 

filter parent ffff: protocol ip pref 10 u32 chain 0 fh 800::801 order 2049 key ht 800 bkt 0 terminal flowid ??? not_in_hw 
  match IP dst 10.81.136.0/21
        action order 1: mirred (Egress Redirect to device ifb1) stolen
        index 12 ref 1 bind 1 installed 10232 sec
        Action statistics:
        Sent 14784002285 bytes 17842914 pkt (dropped 0, overlimits 0 requeues 0) 
        backlog 0b 0p requeues 0 


The linux systems are vanilla-4.13.9 on slackware 64bit with iproute2-ss170905

I'm not able to find the configuration error from my side.
Any response are welcome.

TIA

Marco
