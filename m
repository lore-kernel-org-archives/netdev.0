From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/9] Introduce devlink interface and first drivers to use it
Date: Tue, 23 Feb 2016 16:51:25 +0100
Message-ID: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34744 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbcBWPvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:51:38 -0500
Received: by mail-wm0-f43.google.com with SMTP id b205so205606220wmb.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:51:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

There a is need for some userspace API that would allow to expose things
that are not directly related to any device class like net_device of
ib_device, but rather chip-wide/switch-ASIC-wide stuff.

Use cases:
1) get/set of port type (Ethernet/InfiniBand)
2) setting up port splitters - split port into multiple ones and squash again,
   enables usage of splitter cable
3) setting up shared buffers - shared among multiple ports within
   one chip (work in progress)
4) configuration of switch wide properties - resources division etc - This will
   allow to pass configuration that is unacceptable to be passed as
   a module option.

First patch of this set introduces a new generic Netlink based interface,
called "devlink". It is similar to nl80211 model and it is heavily
influenced by it, including the API definition. The devlink introduction patch
implements use cases 1) and 2). Other 2 are in development atm and will
be addressed by follow-ups.

It is very convenient for drivers to use devlink, as you can see in other
patches in this set.

Counterpart for devlink is userspace tool for now called "dl". Command line
interface and outputs are derived from "ip" tool so it should be easy
for users to get used to it.

It is available here as a standalone tool for now:
https://github.com/jpirko/devlink
After this is merge in kernel, I will include the "dl" or "devlink" tool
into iproute2 toolset.

Port type setting example:
        myhost:~$ dl help
        Usage: dl [ OPTIONS ] OBJECT { COMMAND | help }
        where  OBJECT := { dev | port | monitor }
               OPTIONS := { -v/--verbose }

        myhost:~$ dl dev help
        Usage: dl dev show [DEV]
        Usage: dl dev set DEV [ name NEWNAME ]

        myhost:~$ dl dev show
        0: devlink0: bus pci dev 0000:01:00.0

        myhost:~$ dl port help
        Usage: dl port show [DEV/PORT_INDEX]
        Usage: dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]
        Usage: dl port split DEV/PORT_INDEX count
        Usage: dl port unsplit DEV/PORT_INDEX

        myhost:~$ dl port show
        devlink0/1: type ib ibdev mlx4_0
        devlink0/2: type ib ibdev mlx4_0

        myhost:~$ sudo dl port set devlink0/1 type eth   (or, for Hannes: "sudo dl port set pci_0000:01:00.0/1 type eth")

        myhost:~$ dl port show
        devlink0/1: type eth netdev ens4
        devlink0/2: type ib ibdev mlx4_0

        myhost:~$ sudo dl port set devlink0/2 type auto

        myhost:~$ dl port show
        devlink0/1: type eth netdev ens4
        devlink0/2: type ib(auto) ibdev mlx4_0

Port splitting example:
        myswitch:~$ dl port
        devlink0/1: type eth netdev eth0
        devlink0/3: type eth netdev eth1
        devlink0/5: type eth netdev eth2
        ...
        devlink0/63: type eth netdev eth31

        myswitch:~$ sudo dl port split devlink0/1 2

        myswitch:~$ dl port
        devlink0/3: type eth netdev eth1
        devlink0/5: type eth netdev eth2
        ...
        devlink0/63: type eth netdev eth31
        devlink0/1: type eth netdev eth0 split_group 16
        devlink0/2: type eth netdev eth32 split_group 16

        myswitch:~$ sudo dl port unsplit devlink0/1

        myswitch:~$ dl port
        devlink0/3: type eth netdev eth1
        devlink0/5: type eth netdev eth2
        ...
        devlink0/63: type eth netdev eth31
        devlink0/1: type eth netdev eth0

---
v1->v2:
patch 1/9
 -removed no longer used "devlink_dev" helper
 -fix couple of typos and misspells
patch 4/9:
 -removed SET_NETDEV_DEV set to devlink dev

Ido Schimmel (4):
  mlxsw: spectrum: Unmap local port from module during teardown
  mlxsw: spectrum: Store local port to module mapping during init
  mlxsw: spectrum: Mark unused ports using NULL
  mlxsw: spectrum: Introduce port splitting

Jiri Pirko (5):
  Introduce devlink infrastructure
  mlx4: Implement devlink interface
  mlx4: Implement port type setting via devlink interface
  mlxsw: Implement devlink interface
  mlxsw: core: Add devlink port splitter callbacks

 MAINTAINERS                                    |   8 +
 drivers/infiniband/hw/mlx4/main.c              |   7 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   8 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c      |   9 +
 drivers/net/ethernet/mellanox/mlx4/main.c      | 129 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |   2 +
 drivers/net/ethernet/mellanox/mlxsw/core.c     |  56 +-
 drivers/net/ethernet/mellanox/mlxsw/core.h     |   2 +
 drivers/net/ethernet/mellanox/mlxsw/port.h     |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 237 ++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   8 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  20 +
 include/linux/mlx4/driver.h                    |   3 +
 include/net/devlink.h                          | 151 +++++
 include/uapi/linux/devlink.h                   |  73 ++
 net/Kconfig                                    |   7 +
 net/core/Makefile                              |   1 +
 net/core/devlink.c                             | 887 +++++++++++++++++++++++++
 18 files changed, 1551 insertions(+), 59 deletions(-)
 create mode 100644 include/net/devlink.h
 create mode 100644 include/uapi/linux/devlink.h
 create mode 100644 net/core/devlink.c

-- 
2.5.0
