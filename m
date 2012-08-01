From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 00/12] Add Ethernet IPoIB driver
Date: Wed,  1 Aug 2012 20:09:23 +0300
Message-ID: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:52782 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753384Ab2HARKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:10:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from V1: 
- applied feedback from Ben H.
 - add stats64
 - use memcpy on ethtool
 - remove double indexing on ethtool and unused variables
 - remove extra tab ...
 - remove HW_VLAN_FILTER and the  add/kill_vid ndo entries

- applied feedback from Dave Miller to avoid using sysfs
 - added rtnl_link_ops support in ipoib and use them to add/delete childs
 - added usage to ndo_add/remove_slave in eipoib
 - added support for eipoib VIFs in rtnetlink and new ndo op to configure 
   that to the eipoib device

- some more little cleanups of unused variables 

changes from V0:
 - applied feedback from Eric/Dave - RX flow uses only the last 20 bytes of skb->cb[]
 - applied feedback from Ben H. on ethtool changes
 - fix sparse error on function which should be made static
 - made the netdev features related code of the driver more elegant/robust
 - used _bh locking in some paths which used plain rw locking in V0
 - some code rearrangements in flows that send ARPs

The eIPoIB driver provides a standard Ethernet netdevice over 
the InfiniBand IPoIB interface.

Some services can run only on top of Ethernet L2 interfaces, and cannot be
bound to an IPoIB interface. With this new driver, these services can run
seamlessly.

Main use case of the driver is the Ethernet Virtual Switching used in
virtualized environments, where an eipoib netdevice can be used as a 
Physical Interface (PIF) in the hypervisor domain, and allow other 
guests Virtual Interfaces (VIF) connected to the same Virtual Switch 
to run over the InfiniBand fabric.

This driver supports L2 Switching (Direct Bridging) as well as other L3
Switching modes (e.g. NAT).

Whenever an IPoIB interface is created, one eIPoIB PIF netdevice 
will be created. The default naming scheme is as in other Ethernet 
interfaces: ethX, for example, on a system with two IPoIB interfaces,
ib0 and ib1, two interfaces will be created ethX and ethX+1 When "X" 
is the next free Ethernet number in the system.

Using "ethtool -i " over the new interface can tell on which IPoIB
PIF interface that interface is above.  For example: driver: eth_ipoib:ib0 
indicates that eth3 is the Ethernet interface over the ib0 IPoIB interface.

The driver can be used as independent interface or to serve in
virtualization environment as the physical layer for the virtual
interfaces on the virtual guest.

The driver interface (eipoib interface or which is also referred to as parent) 
uses slave interfaces, IPoIB clones, which are the VIFs described above.

VIFs interfaces are enslaved/released from the eipoib driver on demand, according 
to the management interface provided to user space.

The management interface for the driver uses rtnl interface. Via these interfaces 
the driver gets details on new VIF's to manage. The driver can 
enslave new VIF (IPoIB cloned interface) or detaches from it.
The driver can also configure the slave to support specific mac/vlan of virtual guest.

Here's an example script on how the managment interface looks
like with the new rtnetlink code we added, this is based
on a patch to iproute2 which will be posted once the interface
is agreed.

#!/bin/bash

# create IPoIB clone (ib0.1), enslave it to eIPoIB (eth4), add VIF to 
# serve the master, the provided MAC is the master's one

ip link add link ib0 name ib0.1 type ipoib index 1
ip link set dev ib0.1 master eth4
ip link set dev eth4 vif ib0.1 mac 00:02:C9:43:3B:F1

# add a bridge whose uplink is the eIPOIB device

brctl addbr br2
brctl addif br2 eth4
ifconfig br2 12.134.41.1/16 up

# create IPoIB clone (ib0.2), enslave it to eIPoIB (eth4), add VIF to 
# serve a guest, the provided MAC is the guest's one, vnet1 is a hypervisor
# NIC (e.g tap) that serves that guest

ip link add link ib0 name ib0.2 type ipoib index 2
ip link set dev ib0.2 master eth4
ip link set dev eth4 vif ib0.2 mac 52:54:00:67:E9:BD
brctl addif br2 vnet1

# repeat the above with vlan

ip link add link ib0 name ib0.8003 type ipoib pkey 0x8003
ip link set dev ib0.8003 master eth4
ip link set dev eth4 vif ib0.8003 mac 00:02:C9:43:3B:F1 vlan 3

vconfig add eth4 3 
ifconfig eth4.3 up

brctl addbr br3
brctl addif br3 eth4.3
ifconfig br3 13.134.41.1/16 up

ip link add link ib0 name ib0.8003.1 type ipoib pkey 0x8003 index 1
ip link set dev ib0.8003.1 master eth4
ip link set dev eth4 vif ib0.8003.1 mac 52:54:00:DE:3A:23 vlan 3

cat /sys/class/net/eth4/eth/vifs

============= END OF SCRIPT =======

Note: Each ethX interface has at least one ibX.Y slave to serve the PIF
itself, in the VIFs list of ethX you'll notice that ibX.1 is always created 
to serve applications running from the Hypervisor on top of ethX interface directly.

For IB applications that require native IPoIB interfaces (e.g. RDMA-CM), the
original ipoib interfaces ibX can still be used.  For example, RDMA-CM and
eth_ipoib drivers can co-exist and make use of IPoIB

The last patch of this series was made such that the series works as is over net-next.
In parallel to effort a patch to modify IPoIB such that it doesn't assume dst/neighbour 
on the skb was pushed upstream, its commit b63b70d87741 "IPoIB: Use a private hash table 
for path lookup in xmit path", once present in net-next this patch can simply be dropped.

Erez Shitrit (10):
  include/linux: Add private flags for IPoIB interfaces
  IB/ipoib: Add support for acting as VIF
  net: Add ndo_set_vif_param operation to serve eIPoIB VIFs
  net/core: Add rtnetlink support to vif parameters
  net/eipoib: Add private header file
  net/eipoib: Add ethtool file support
  net/eipoib: Add main driver functionality
  net/eipoib: Add sysfs support
  net/eipoib: Add Makefile, Kconfig and MAINTAINERS entries
  IB/ipoib: Add support for transmission of skbs w.o dst/neighbour

Or Gerlitz (2):
  IB/ipoib: Add rtnl_link_ops support
  IB/ipoib: Add support for clones / multiple childs on the same partition

 Documentation/infiniband/ipoib.txt           |   15 +
 MAINTAINERS                                  |    6 +
 drivers/infiniband/ulp/ipoib/Makefile        |    3 +-
 drivers/infiniband/ulp/ipoib/ipoib.h         |   16 +
 drivers/infiniband/ulp/ipoib/ipoib_cm.c      |    9 +
 drivers/infiniband/ulp/ipoib/ipoib_ib.c      |    8 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   38 +-
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |  119 ++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |   89 +-
 drivers/net/Kconfig                          |   15 +
 drivers/net/Makefile                         |    1 +
 drivers/net/eipoib/Makefile                  |    4 +
 drivers/net/eipoib/eth_ipoib.h               |  215 +++
 drivers/net/eipoib/eth_ipoib_ethtool.c       |  114 ++
 drivers/net/eipoib/eth_ipoib_main.c          | 1953 ++++++++++++++++++++++++++
 drivers/net/eipoib/eth_ipoib_sysfs.c         |  435 ++++++
 include/linux/if.h                           |    2 +
 include/linux/if_link.h                      |   16 +
 include/linux/netdevice.h                    |    5 +-
 include/rdma/e_ipoib.h                       |   54 +
 net/core/rtnetlink.c                         |   42 +-
 21 files changed, 3117 insertions(+), 42 deletions(-)
 create mode 100644 drivers/infiniband/ulp/ipoib/ipoib_netlink.c
 create mode 100644 drivers/net/eipoib/Makefile
 create mode 100644 drivers/net/eipoib/eth_ipoib.h
 create mode 100644 drivers/net/eipoib/eth_ipoib_ethtool.c
 create mode 100644 drivers/net/eipoib/eth_ipoib_main.c
 create mode 100644 drivers/net/eipoib/eth_ipoib_sysfs.c
 create mode 100644 include/rdma/e_ipoib.h

Cc: Erez Shitrit <erezsh@mellanox.co.il>
