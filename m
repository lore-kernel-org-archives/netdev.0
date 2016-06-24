From: Michal Soltys <soltys@ziu.info>
Subject: switch / linux STP interoperation issues.
Date: Fri, 24 Jun 2016 21:14:30 +0200
Message-ID: <47b27017-6cfb-4a5c-8403-120848902173@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:47907 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbcFXTVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 15:21:50 -0400
Received: from [10.0.0.2] (89-65-72-120.dynamic.chello.pl [89.65.72.120])
	(Authenticated sender: nozo)
	by drutsystem.com (Postfix) with ESMTPA id 0C17F64139
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 21:14:31 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In the last week I've been trying to get STP on the linux side (both its 
builtin STP implementation as well as mstpd userspace daemon). Initially 
I started with more complex setups (vlan aware bridge, bonds, mst) and 
gradually (with identical problems on each step) ended with the most 
basic setup that can be summarized by:

brctl addbr br0
brctl addif br0 eno1
brctl addif br0 eno2
brctl stp br0 on
ip li set eno1 up
ip li set eno2 up
ip li set br0 up

The same config on switch's side (cisco 2960-x in its most basic 
incarnation) - in the other words two cables between linux machine and 
the switch, enabled stp, access ports in vlan1.

The end effect of this setup (and any of the more complex previous ones):

The switch respected BPDUs sent to it (if applicable) - for example it 
complied properly if it's priority was less (numerically higher) than 
linux's - showing linux box as root bridge, marking one port as root, 
the other as alternate/blocking.

The linux box itself was completely deaf to any BPDUs arriving to it 
(e.g. if it's priority was lower) and just keept pushing its own data 
units all the time with little care (quickly leading to loops in some 
scenarios). Whether it was builtin stp implementation, or whether it was 
mstpd's stp/rstp/mstp - the behaviour was the same.

With the bridge itself happily claiming to be the root (despite lower 
priority):

br0
  bridge id              a000.000af77cddc4
  designated root        a000.000af77cddc4
  root port                 0

<cut>

enp8s0f0 (3)
  port id                8003                    state 
forwarding
  designated root        a000.000af77cddc4       path cost 
    4
  designated bridge      a000.000af77cddc4

<cut>
(and analogous output from mstpctl tool)

tcpdump looked like:

17:33:28.701425 00:0a:f7:7c:dd:c4 > 01:80:c2:00:00:00, 802.3, length 52: 
LLC, dsap STP (0x42) Individual, ssap STP (0x42) Command, ctrl 0x03
: STP 802.1d, Config, Flags [none], bridge-id 
a000.00:0a:f7:7c:dd:c4.8003, length 35
         message-age 0.00s, max-age 20.00s, hello-time 2.00s, 
forwarding-delay 15.00s
         root-id a000.00:0a:f7:7c:dd:c4, root-pathcost 0
17:33:29.026185 18:8b:45:6f:38:86 > 01:80:c2:00:00:00, 802.3, length 60: 
LLC, dsap STP (0x42) Individual, ssap STP (0x42) Command, ctrl 0x03
: STP 802.1d, Config, Flags [none], bridge-id 
2001.18:8b:45:6f:38:80.8006, length 43
         message-age 0.00s, max-age 20.00s, hello-time 2.00s, 
forwarding-delay 15.00s
         root-id 2001.18:8b:45:6f:38:80, root-pathcost 0

The first sent by linux box, the second by the switch (the above from 
basic stp scenario on both sides).


The cards in question used:
Ethernet controller: Broadcom Corporation NetXtreme BCM5719 Gigabit 
Ethernet PCIe (rev 01) handled by:

driver: tg3
version: 3.137
firmware-version: FFV7.10.17 bc 5719-v1.37


Linux is fresh stock archlinux (so vanilla 4.6.2 kernel and the most (or 
almost) recent userland utils - iproute2, etc.), running on relatively 
recent poweredge dell.

I'm kind of lost at this point - am I missing some basic 
options/sysctls/sysfs ? Is there some known incompatibility here 
somewhere between switch/linux/nic/versions/etc. ? Some by-default 
enabled BPDU filtering maybe ?


Any suggestions / hints appreciated.
