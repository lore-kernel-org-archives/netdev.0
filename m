From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 0/9] Add Ethernet IPoIB driver
Date: Wed, 18 Jul 2012 13:59:53 +0300
Message-ID: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, shlomop@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:35523 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753587Ab2GRLAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 07:00:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

The management interface for the driver uses sysfs entries. Via these sysfs 
entries the driver gets details on new VIF's to manage. The driver can 
enslave new VIF (IPoIB cloned interface) or detaches from it.

Here are few sysfs commands that are used in order to manage the driver, 
according to few scenarios:

1. create new clone of IPoIB interface:

	$ echo .Y > /sys/class/net/ibX/create_child

create new clone ibX.Y with the same pkey as ibX, for example:

	$ echo .1 > /sys/class/net/ib0/create_child

will create new interface ib0.1

2. notify parent interface on new VIF to enslave:

	$ echo +ibX.Y > /sys/class/net/ethZ/eth/slaves

where ethZ is the driver interface, for example:

	$ echo +ib0.1 > /sys/class/net/eth4/eth/slaves

will enslave ib0.1 to eth4

3. notify parent interface interface on VIF details (mac and vlan)

	$ echo +ibX.Y <MAC address> > /sys/class/net/ethZ/eth/vifs

for example:

	$ echo +ib0.1 00:02:c9:43:3b:f1 > /sys/class/net/eth4/eth/vifs

4. notify parent to release VIF:

	$ echo -ibX.Y > /sys/class/net/ethZ/eth/slaves

where ethZ is the driver interface, for example:

        $ echo -ib0.1 > /sys/class/net/eth4/eth/slaves

will release ib0.1 from eth4

5. see the list of ipoib interfaces enslaved under eipoib interface,

	$ cat /sys/class/net/ethX/eth/vifs

for example:
	
	$ cat /sys/class/net/eth4/eth/vifs

	SLAVE=ib0.1      MAC=9a:c2:1f:d7:3b:63 VLAN=N/A
	SLAVE=ib0.2      MAC=52:54:00:60:55:88 VLAN=N/A
	SLAVE=ib0.3      MAC=52:54:00:60:55:89 VLAN=N/A

Note: Each ethX interface has at least one ibX.Y slave to serve the PIF
itself, in the VIFs list of ethX you'll notice that ibX.1 is always created 
to serve applications running from the Hypervisor on top of ethX interface directly.

For IB applications that require native IPoIB interfaces (e.g. RDMA-CM), the
original ipoib interfaces ibX can still be used.  For example, RDMA-CM and
eth_ipoib drivers can co-exist and make use of IPoIB

The last patch of this series was made such that the series works as is over 
net-next, in parallel to the submission of this driver, a patch to modify IPoIB 
such that it doesn't assume dst/neighbour on the skb was posted. 

Or.


Erez Shitrit (8):
  include/linux: Add private flags for IPoIB interfaces
  IB/ipoib: Add support for acting as VIF
  net/eipoib: Add private header file
  net/eipoib: Add ethtool file support
  net/eipoib: Add sysfs support
  net/eipoib: Add main driver functionality
  net/eipoib: Add Makefile, Kconfig and MAINTAINERS entries
  IB/ipoib: Add support for transmission of skbs w.o dst/neighbour

Or Gerlitz (1):
  IB/ipoib: Add support for clones / multiple childs on the same partition

 Documentation/infiniband/ipoib.txt         |   23 +
 MAINTAINERS                                |    6 +
 drivers/infiniband/ulp/ipoib/ipoib.h       |   12 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c    |    9 +
 drivers/infiniband/ulp/ipoib/ipoib_ib.c    |    8 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c  |   76 +-
 drivers/infiniband/ulp/ipoib/ipoib_verbs.c |    3 +-
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c  |   46 +-
 drivers/net/Kconfig                        |   15 +
 drivers/net/Makefile                       |    1 +
 drivers/net/eipoib/Makefile                |    4 +
 drivers/net/eipoib/eth_ipoib.h             |  227 ++++
 drivers/net/eipoib/eth_ipoib_ethtool.c     |  126 ++
 drivers/net/eipoib/eth_ipoib_main.c        | 1915 ++++++++++++++++++++++++++++
 drivers/net/eipoib/eth_ipoib_sysfs.c       |  640 ++++++++++
 include/linux/if.h                         |    2 +
 include/rdma/e_ipoib.h                     |   54 +
 17 files changed, 3134 insertions(+), 33 deletions(-)
 create mode 100644 drivers/net/eipoib/Makefile
 create mode 100644 drivers/net/eipoib/eth_ipoib.h
 create mode 100644 drivers/net/eipoib/eth_ipoib_ethtool.c
 create mode 100644 drivers/net/eipoib/eth_ipoib_main.c
 create mode 100644 drivers/net/eipoib/eth_ipoib_sysfs.c
 create mode 100644 include/rdma/e_ipoib.h
