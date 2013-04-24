From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: getting VF link info seems to be broken in 3.9-rc8
Date: Wed, 24 Apr 2013 16:08:22 +0300
Message-ID: <5177D946.9080704@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rony Efraim <ronye@mellanox.com>
To: David Miller <davem@davemloft.net>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:59216 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753742Ab3DXNIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 09:08:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[re-posting as of non text only content in the 1st post - sorry for the 
spam] Rony Efraim <ronye@mellanox.com>observed a regression in 3.9-rc8 
with respect to getting VFs link info from user space. Using latest 
iproute2 we can easily get the VF info on 3.8.8 but not on the net git 
which is now aligned on 3.9-rc8, will try to bisect it later 
today/tomorrow, but for the sake of maybe someone has an insight of the 
bug, reporting it now...

You can see below that for eth10 and eth11 which are ixgbe PFs, the VF 
info is reported on 3.8.8 but not on 3.9-rc8, we see the same problem 
with patches to mlx4 which implement ndo_get_vf_info which gives some 
evidence that the problem isn't in the ixgbe driver, but rather 
somewhere else, maybe the networking core, from quick looking on 
net/core/rtnetlink.c I don't see there a smoking gun, anyway

net.git]# git log --oneline v3.8..v3.9-rc8 net/core/rtnetlink.c
88c5b5c rtnetlink: Call nlmsg_parse() with correct header length
fcca143 rtnetlink: fix error return code in rtnl_link_fill()
a5b8db9 rtnetlink: Mask the rta_type when range checking
84d73cd rtnl: fix info leak on RTM_GETLINK request for VF devices
b67bfe0 hlist: drop the node parameter from iterators
1690be6 bridge: Add vlan support to static neighbors
6cbdcee bridge: Dump vlan information from a bridge port
407af32 bridge: Add netlink interface to configure vlans on bridge ports
c5c3510 netns: fdb: allow unprivileged users to add/del fdb entries
2afb9b5 ethtool: set addr_assign_type to NET_ADDR_SET when addr is 
passed on create
471cb5a bonding: remove usage of dev->master
898e506 rtnetlink: remove usage of dev->master
e7c3273 rtnl: use dev_set_mac_address() instead of plain ndo_
9a57247 rtnl: expose carrier value with possibility to set it


Or.

--> using 3.8.8

# lspci | grep Eth
01:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection (rev 01)
01:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection (rev 01)
05:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)
05:10.0 Ethernet controller: Intel Corporation 82599 Ethernet Controller 
Virtual Function (rev 01)
05:10.1 Ethernet controller: Intel Corporation 82599 Ethernet Controller 
Virtual Function (rev 01)

# cd /sys/class/net/
# ls -l
lrwxrwxrwx 1 root root 0 Apr 24 12:17 br0 -> ../../devices/virtual/net/br0
lrwxrwxrwx 1 root root 0 Apr 24 12:17 eth0 -> 
../../devices/pci0000:00/0000:00:01.0/0000:01:00.0/net/eth0
lrwxrwxrwx 1 root root 0 Apr 24 12:17 eth1 -> 
../../devices/pci0000:00/0000:00:01.0/0000:01:00.1/net/eth1
lrwxrwxrwx 1 root root 0 Apr 24 12:18 eth10 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:00.1/net/eth10
lrwxrwxrwx 1 root root 0 Apr 24 12:18 eth11 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:00.0/net/eth11
lrwxrwxrwx 1 root root 0 Apr 24 12:18 eth16 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.0/net/eth16
lrwxrwxrwx 1 root root 0 Apr 24 12:18 eth17 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.0/net/eth17
lrwxrwxrwx 1 root root 0 Apr 24 12:17 eth18 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.1/net/eth18
lrwxrwxrwx 1 root root 0 Apr 24 12:17 eth19 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.1/net/eth19
lrwxrwxrwx 1 root root 0 Apr 24 12:17 eth20 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:10.1/net/eth20
lrwxrwxrwx 1 root root 0 Apr 24 12:17 eth22 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:10.0/net/eth22
lrwxrwxrwx 1 root root 0 Apr 24 12:17 lo -> ../../devices/virtual/net/lo



# modprobe -r ixgbevf
# ip link set dev eth10 vf 0 mac 00:10:00:10:00:10
# ip link set dev eth11 vf 0 mac 00:11:00:11:00:11
# modprobe ixgbevf
# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode 
DEFAULT
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br0 
state UP mode DEFAULT qlen 1000
     link/ether 00:25:90:36:9c:ec brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:25:90:36:9c:ed brd ff:ff:ff:ff:ff:ff
4: eth16: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:01:11 brd ff:ff:ff:ff:ff:ff
5: eth17: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:01:12 brd ff:ff:ff:ff:ff:ff
6: eth18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:02:11 brd ff:ff:ff:ff:ff:ff
7: eth19: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:02:12 brd ff:ff:ff:ff:ff:ff
8: eth11: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state 
DOWN mode DEFAULT qlen 1000
     link/ether 00:1b:21:55:1d:00 brd ff:ff:ff:ff:ff:ff
     vf 0 MAC 00:11:00:11:00:11, spoof checking on
9: eth10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP 
mode DORMANT qlen 1000
     link/ether 00:1b:21:55:1d:01 brd ff:ff:ff:ff:ff:ff
     vf 0 MAC 00:10:00:10:00:10, spoof checking on
12: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state 
UP mode DEFAULT
     link/ether 00:25:90:36:9c:ec brd ff:ff:ff:ff:ff:ff
23: eth22: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:11:00:11:00:11 brd ff:ff:ff:ff:ff:ff
24: eth20: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:10:00:10:00:10 brd ff:ff:ff:ff:ff:ff


--> using 3.9-rc8

# lspci | grep Eth
01:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection (rev 01)
01:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection (rev 01)
05:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)
05:10.0 Ethernet controller: Intel Corporation 82599 Ethernet Controller 
Virtual Function (rev 01)
05:10.1 Ethernet controller: Intel Corporation 82599 Ethernet Controller 
Virtual Function (rev 01)

# cd /sys/class/net/
# ls -l
lrwxrwxrwx 1 root root 0 Apr 24 11:48 br0 -> ../../devices/virtual/net/br0
lrwxrwxrwx 1 root root 0 Apr 24 11:48 eth0 -> 
../../devices/pci0000:00/0000:00:01.0/0000:01:00.0/net/eth0
lrwxrwxrwx 1 root root 0 Apr 24 11:48 eth1 -> 
../../devices/pci0000:00/0000:00:01.0/0000:01:00.1/net/eth1
lrwxrwxrwx 1 root root 0 Apr 24 11:49 eth10 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:00.1/net/eth10
lrwxrwxrwx 1 root root 0 Apr 24 11:49 eth11 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:00.0/net/eth11
lrwxrwxrwx 1 root root 0 Apr 24 11:49 eth16 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.0/net/eth16
lrwxrwxrwx 1 root root 0 Apr 24 11:48 eth17 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.0/net/eth17
lrwxrwxrwx 1 root root 0 Apr 24 11:49 eth18 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.1/net/eth18
lrwxrwxrwx 1 root root 0 Apr 24 11:48 eth19 -> 
../../devices/pci0000:00/0000:00:07.0/0000:04:00.1/net/eth19
lrwxrwxrwx 1 root root 0 Apr 24 11:48 eth20 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:10.1/net/eth20
lrwxrwxrwx 1 root root 0 Apr 24 11:48 eth22 -> 
../../devices/pci0000:00/0000:00:09.0/0000:05:10.0/net/eth22
lrwxrwxrwx 1 root root 0 Apr 24 11:47 lo -> ../../devices/virtual/net/lo

# ip  link show <--- no sign for VFs
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode 
DEFAULT
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br0 
state UP mode DEFAULT qlen 1000
     link/ether 00:25:90:36:9c:ec brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:25:90:36:9c:ed brd ff:ff:ff:ff:ff:ff
4: eth11: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:1b:21:55:1d:00 brd ff:ff:ff:ff:ff:ff
5: eth10: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:1b:21:55:1d:01 brd ff:ff:ff:ff:ff:ff
6: eth16: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:01:11 brd ff:ff:ff:ff:ff:ff
7: eth17: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:01:12 brd ff:ff:ff:ff:ff:ff
8: eth18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:02:11 brd ff:ff:ff:ff:ff:ff
9: eth19: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:02:12 brd ff:ff:ff:ff:ff:ff
10: eth22: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether 3e:9c:76:28:d9:da brd ff:ff:ff:ff:ff:ff
11: eth20: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT qlen 1000
     link/ether ea:f6:42:a7:d9:40 brd ff:ff:ff:ff:ff:ff
12: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state 
UP mode DEFAULT
     link/ether 00:25:90:36:9c:ec brd ff:ff:ff:ff:ff:ff
