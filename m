From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/6] Introduce devlink interface and first drivers to use it
Date: Wed,  3 Feb 2016 11:47:56 +0100
Message-ID: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33154 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcBCKsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:48:06 -0500
Received: by mail-wm0-f47.google.com with SMTP id l66so157298287wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:48:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

There a is need for some userspace API that would allow to expose things
that are not directly related to any device class like net_device of
ib_device, but rather chip-wide/switch-ASIC-wide stuff.

Use cases:
1) get/set of port type (Ethernet/InfiniBand)
2) monitoring of hardware messages to and from chip
3) setting up port splitters - split port into multiple ones and squash again,
   enables usage of splitter cable
4) setting up shared buffers - shared among multiple ports within one chip

First patch of this set introduces a new generic Netlink based interface,
called "devlink". It is similar to nl80211 model and it is heavily
influenced by it, including the API definition. The devlink introduction patch
implements use cases 1) and 2). Other 2 are in development atm and will
be addressed by follow-ups.

It is very convenient for drivers to use devlink, as you can see in other
patches in this set.

Counterpart for devlink is userspace tool called "dl". Command line interface
and outputs are derived from "ip" tool so it should be easy for users to get
used to it.

It is available here:
https://github.com/jpirko/devlink

Example usage:
butter:~$ dl help
Usage: dl [ OPTIONS ] OBJECT { COMMAND | help }
where  OBJECT := { dev | port | monitor }
       OPTIONS := { -v/--verbose }

butter:~$ dl dev show
0: devlink0: bus pci dev 0000:01:00.0

butter:~$ dl port help
Usage: dl port show [DEV/PORT_INDEX]
Usage: dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]

butter:~$ dl port show
devlink0/1: type ib ibdev mlx4_0
devlink0/2: type ib ibdev mlx4_0

butter:~$ sudo dl port set devlink0/1 type eth

butter:~$ dl port show
devlink0/1: type eth netdev ens4
devlink0/2: type ib ibdev mlx4_0

butter:~$ sudo dl port set devlink0/1 type auto

butter:~$ dl port show
devlink0/1: type eth(auto) netdev ens4
devlink0/2: type ib ibdev mlx4_0

Jiri Pirko (6):
  Introduce devlink infrastructure
  mlxsw: Implement devlink interface
  mlxsw: Implement hardware messages notification using devlink
  mlx4: Implement devlink interface
  mlx4: Implement hardware messages notification using devlink
  mlx4: Implement port type setting via devlink interface

 MAINTAINERS                                    |   8 +
 drivers/infiniband/hw/mlx4/main.c              |   7 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   8 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |   9 +
 drivers/net/ethernet/mellanox/mlx4/intf.c      |   9 +
 drivers/net/ethernet/mellanox/mlx4/main.c      | 129 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |   2 +
 drivers/net/ethernet/mellanox/mlxsw/core.c     |  39 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  20 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   2 +
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  20 +
 include/linux/mlx4/driver.h                    |   3 +
 include/net/devlink.h                          | 152 +++++
 include/uapi/linux/devlink.h                   |  84 +++
 net/Kconfig                                    |   7 +
 net/core/Makefile                              |   1 +
 net/core/devlink.c                             | 856 +++++++++++++++++++++++++
 17 files changed, 1313 insertions(+), 43 deletions(-)
 create mode 100644 include/net/devlink.h
 create mode 100644 include/uapi/linux/devlink.h
 create mode 100644 net/core/devlink.c

-- 
1.9.3
