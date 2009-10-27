From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [net-next-2.6 PATCH 0/6] net: Speedup netdevice unregisters
Date: Tue, 27 Oct 2009 18:02:19 +0100
Message-ID: <4AE7279B.7070300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50940 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756177AbZJ0RCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:02:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdevice unregisters are serialized and call synchronize_{net|rcu}()
three times per device.

This means it can take a long time to remove a device, if many virtual
devices are attached. (vlan, macvlan, tunnels, ...)

This patch series partially solve the problem by batching several devices in a list,
so that two synchronize_net() calls can be factorized.

Some results on my dev machine (2x4 cpus, HZ=1000, PREEMPT):

modprobe dummy numdummies=10000
# unregister 10000 DOWN netdevices
time rmmod dummy

Before patches :

real    2m0.303s  (12 ms per device)
user    0m0.001s
sys     0m0.117s

After patches 1,2,3 :

real	0m1.111s
user	0m0.001s
sys	0m0.922s (mostly sysfs overhead)


modprobe dummy
ip link set dummy0 up
for f in `seq 1 1000`
do
 ip link add link dummy0 dummy0.$f type vlan id $f
 ip link set dummy0.$f up
done
# Dismantle of 1000 UP vlans (but no IP address)
time rmmod dummy

Before patches :

real    0m40.410s  (40 ms per vlan)
user    0m0.000s
sys     0m0.022s

After patches 1,2,3 :

real	0m20.990s
user	0m0.001s
sys	0m0.011s

After patch 4 (vlan: Use unregister_netdevice_many())

real	0m4.392s (-> 4.3 ms per vlan)
user	0m0.000s
sys	0m0.067s

We still have a synchronize_rcu() in dev_deactivate() that could be
factorized in followup patches if there is some interest.


PATCH 1/6 : net: Introduce unregister_netdevice_queue()
PATCH 2/6 : net: Introduce unregister_netdevice_many()
PATCH 3/6 : net: Add a list_head parameter to dellink() method
PATCH 4/6 : vlan: Optimize multiple unregistration
PATCH 5/6 : ipip: Optimize multiple unregistration
PATCH 6/6 : gre: Optimize multiple unregistration

