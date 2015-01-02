From: sfeldma@gmail.com
Subject: [PATCH net-next 0/3] swdev: add IPv4 routing offload
Date: Thu,  1 Jan 2015 19:29:18 -0800
Message-ID: <1420169361-31767-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us, john.fastabend@gmail.com,
	tgraf@suug.ch, jhs@mojatatu.com, andy@greyhouse.net,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:55995 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbABD2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 22:28:53 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so23528248pad.27
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 19:28:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This patch set adds L3 routing offload support for IPv4 routes.  The idea is to
mirror routes installed in the kernel's FIB down to a hardware switch device to
offload the data forwarding path for L3.  Only the data forwarding path is
intercepted.  Control and management of the kernel's FIB remains with the
kernel.

A couple of new ndo ops (ndo_switch_fib_ipv4_add/del) are added to the swdev
model to add/remove FIB entries to/from the offload device.  The ops are called
from the core IPv4 FIB code directly.  Just before the FIB entry is installed
in the kernel's FIB, the swdev device driver gets a chance at the FIB entry
(assuming the swdev driver implements the new ndo ops).  This is a synchronous
call in the RTM_NEWROUTE path, and the swdev has the option to fail the
install, which means the FIB entry is not installed in swdev or the kernel, and
the user is notified of the failure.  The swdev driver also has the option to
return -EOPNOTSUPP to pass on the FIB entry, so it'll only be installed in the
kernel FIB.

The FIB flush path is modified also to call into the swdev driver to flush the
FIB entries from hardware.

The rocker swdev driver is updated to support these new ndo ops.  Right now
rocker only supports IPv4 singlepath routes, but follow-on patches will add
IPv6 and ECMP support.  Also, only unicast IPv4 routes are supported, but
follow-on patches will add multicast route support.

Testing was done in my simulated network envionment using VMs and the rocker
device.  I'm using Quagga OSPFv2 for the routing protocol for automatic control
plane processing.  No modifications to Quagga or netlink/iproute2 is required;
it just works.

One important metric is the time spent installing/removing FIB entries from the
kernel and the device.  With these patches applied, I measured the wall time
required to install and remove 10K IPv4 routes.  I used ip route add cmd in
batch mode to install static routes.  I used the ip route flush cmd to delete
the routes.  This is 10000 routes installed to the kernel's FIB and to the
swdev device's L3 tables.  And then removed from each.  The performance is less
than a second for each operation.  This is on my simulated rocker device running
on a VM, so a real embedded CPU would probably do much better.

My batch has 10K lines of:

simp@simp:~$ head east
route add 16.0.0.0/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.1/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.2/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.3/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.4/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.5/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.6/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.7/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.8/32 nexthop via 11.0.0.2 dev swp1
route add 16.0.0.9/32 nexthop via 11.0.0.2 dev swp1
[...]

Install/removing routes:

simp@simp:~$ wc -l east
10000 east
simp@simp:~$ ip route show root 16/8 | wc -l
0
simp@simp:~$ time sudo ip --batch east

real    0m0.715s
user    0m0.092s
sys     0m0.388s
simp@simp:~$ ip route show root 16/8 | wc -l
10000

[At this point, 10K routes are installed in kernel and the device]

simp@simp:~$ time sudo ip route flush root 16/8

real    0m0.458s
user    0m0.000s
sys     0m0.284s
simp@simp:~$ ip route show root 16/8 | wc -l
0

[All gone]

Scott Feldman (3):
  net: add IPv4 routing FIB support for swdev
  net: call swdev fib del for flushed routes
  rocker: implement IPv4 fib offloading

 drivers/net/ethernet/rocker/rocker.c |  441 +++++++++++++++++++++++++++++++++-
 include/linux/netdevice.h            |   22 ++
 include/net/switchdev.h              |   18 ++
 net/ipv4/fib_trie.c                  |   31 ++-
 net/switchdev/switchdev.c            |   89 +++++++
 5 files changed, 592 insertions(+), 9 deletions(-)

-- 
1.7.10.4
