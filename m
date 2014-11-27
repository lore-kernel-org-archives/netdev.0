From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 00/21] introduce rocker switch driver with hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Thu, 27 Nov 2014 11:40:05 +0100
Message-ID: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:43580 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbaK0Kk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:29 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so7861121wiv.14
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

This patchset is just the first phase of switch and switch-ish device
support api in kernel. Note that the api will extend.

So what this patchset includes:
- introduce switchdev api skeleton for implementing switch drivers
- introduce rocker switch driver which implements switchdev api fdb and
  bridge set/get link ndos

As to the discussion if there is need to have specific class of device
representing the switch itself, so far we found no need to introduce that.
But we are generally ok with the idea and when the time comes and it will
be needed, it can be easily introduced without any disturbance.

This patchset introduces switch id export through rtnetlink and sysfs,
which is similar to what we have for port id in SR-IOV. I will send iproute2
patchset for showing the switch id for port netdevs once this is applied.
This applies also for the PF_BRIDGE and fdb iproute2 patches.

iproute2 patches are now available here:
https://github.com/jpirko/iproute2-rocker

For detailed description and version history, please see individual patches.

In v4 I reordered the patches leaving rocker patches on the end of the patchset.

Jiri Pirko (10):
  bridge: rename fdb_*_hw to fdb_*_hw_addr to avoid confusion
  neigh: sort Neighbor Cache Entry Flags
  bridge: convert flags in fbd entry into bitfields
  net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
  net: rename netdev_phys_port_id to more generic name
  net: introduce generic switch devices support
  rtnl: expose physical switch id for particular device
  net-sysfs: expose physical switch id for particular device
  rocker: introduce rocker switch driver
  rocker: implement ndo_fdb_dump

Scott Feldman (9):
  bridge: call netdev_sw_port_stp_update when bridge port STP status
    changes
  bridge: add API to notify bridge driver of learned FBD on offloaded
    device
  bridge: move private brport flags to if_bridge.h so port drivers can
    use flags
  bridge: add new brport flag LEARNING_SYNC
  bridge: add new hwmode swdev
  bridge: add brport flags to dflt bridge_getlink
  rocker: implement rocker ofdpa flow table manipulation
  rocker: implement L2 bridge offloading
  rocker: add ndo_bridge_setlink/getlink support for learning policy

Thomas Graf (2):
  rocker: Add proper validation of Netlink attributes
  rocker: Use logical operators on booleans

 Documentation/ABI/testing/sysfs-class-net        |    8 +
 Documentation/networking/switchdev.txt           |   59 +
 MAINTAINERS                                      |   14 +
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c      |    3 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   11 +-
 drivers/net/ethernet/rocker/Kconfig              |   27 +
 drivers/net/ethernet/rocker/Makefile             |    5 +
 drivers/net/ethernet/rocker/rocker.c             | 4374 ++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker.h             |  428 +++
 drivers/net/macvlan.c                            |    4 +-
 drivers/net/vxlan.c                              |    4 +-
 include/linux/if_bridge.h                        |   31 +
 include/linux/netdevice.h                        |   39 +-
 include/linux/rtnetlink.h                        |    9 +-
 include/net/switchdev.h                          |   37 +
 include/uapi/linux/if_bridge.h                   |    1 +
 include/uapi/linux/if_link.h                     |    2 +
 include/uapi/linux/neighbour.h                   |    6 +-
 net/Kconfig                                      |    1 +
 net/Makefile                                     |    3 +
 net/bridge/br_fdb.c                              |  144 +-
 net/bridge/br_private.h                          |   21 +-
 net/bridge/br_stp.c                              |    7 +
 net/core/dev.c                                   |    2 +-
 net/core/net-sysfs.c                             |   26 +-
 net/core/rtnetlink.c                             |  119 +-
 net/switchdev/Kconfig                            |   13 +
 net/switchdev/Makefile                           |    5 +
 net/switchdev/switchdev.c                        |   52 +
 35 files changed, 5366 insertions(+), 105 deletions(-)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 drivers/net/ethernet/rocker/Kconfig
 create mode 100644 drivers/net/ethernet/rocker/Makefile
 create mode 100644 drivers/net/ethernet/rocker/rocker.c
 create mode 100644 drivers/net/ethernet/rocker/rocker.h
 create mode 100644 include/net/switchdev.h
 create mode 100644 net/switchdev/Kconfig
 create mode 100644 net/switchdev/Makefile
 create mode 100644 net/switchdev/switchdev.c

-- 
1.9.3
