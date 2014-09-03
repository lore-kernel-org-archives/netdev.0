From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/13] introduce rocker switch driver with openvswitch hardware accelerated datapath
Date: Wed,  3 Sep 2014 11:24:47 +0200
Message-ID: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:47238 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbaICJZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 05:25:04 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so501568wib.10
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 02:25:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset can be divided into 3 main sections:
- introduce switchdev api for implementing switch drivers
- add hardware acceleration bits into openvswitch datapath, This uses
  previously mentioned switchdev api
- introduce rocker switch driver which implements switchdev api

More info in separate patches.

So now there is possible out of the box to create ovs bridge over rocker
switch ports and the flows will be offloaded into hardware.

RFC->v1 changes:
- moved include/linux/*.h -> include/net/
- moved net/core/switchdev.c -> net/switchdev/
- moved drivers/net/rocker.* -> drivers/net/ethernet/rocker/
- fixed couple of little bugs and typos
- in dsa the switch id is generated randomly
- fixed rocker schedule in atomic context bug in rocker_port_set_rx_mode 
- added switchdev Netlink API

Jiri Pirko (13):
  openvswitch: split flow structures into ovs specific and generic ones
  net: rename netdev_phys_port_id to more generic name
  net: introduce generic switch devices support
  rtnl: expose physical switch id for particular device
  net-sysfs: expose physical switch id for particular device
  net: introduce dummy switch
  dsa: implement ndo_swdev_get_id
  net: introduce netdev_phys_item_ids_match helper
  openvswitch: introduce vport_op get_netdev
  openvswitch: add support for datapath hardware offload
  sw_flow: add misc section to key with in_port_ifindex field
  rocker: introduce rocker switch driver
  switchdev: introduce Netlink API

 Documentation/networking/switchdev.txt           |   53 +
 MAINTAINERS                                      |   14 +
 drivers/net/Kconfig                              |    7 +
 drivers/net/Makefile                             |    1 +
 drivers/net/dummyswitch.c                        |  130 +
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 drivers/net/ethernet/rocker/Kconfig              |   29 +
 drivers/net/ethernet/rocker/Makefile             |    5 +
 drivers/net/ethernet/rocker/rocker.c             | 3553 ++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker.h             |  465 +++
 include/linux/netdevice.h                        |   54 +-
 include/net/dsa.h                                |    1 +
 include/net/sw_flow.h                            |  116 +
 include/net/switchdev.h                          |   44 +
 include/uapi/linux/if_link.h                     |   10 +
 include/uapi/linux/switchdev.h                   |  119 +
 net/Kconfig                                      |    1 +
 net/Makefile                                     |    3 +
 net/core/dev.c                                   |    2 +-
 net/core/net-sysfs.c                             |   26 +-
 net/core/rtnetlink.c                             |   30 +-
 net/dsa/Kconfig                                  |    2 +-
 net/dsa/dsa.c                                    |    3 +
 net/dsa/slave.c                                  |   10 +
 net/openvswitch/Makefile                         |    3 +-
 net/openvswitch/actions.c                        |    3 +-
 net/openvswitch/datapath.c                       |  109 +-
 net/openvswitch/datapath.h                       |    7 +-
 net/openvswitch/dp_notify.c                      |    7 +-
 net/openvswitch/flow.c                           |    6 +-
 net/openvswitch/flow.h                           |  102 +-
 net/openvswitch/flow_netlink.c                   |   53 +-
 net/openvswitch/flow_netlink.h                   |   10 +-
 net/openvswitch/flow_table.c                     |  119 +-
 net/openvswitch/flow_table.h                     |   30 +-
 net/openvswitch/hw_offload.c                     |  267 ++
 net/openvswitch/hw_offload.h                     |   22 +
 net/openvswitch/vport-gre.c                      |    4 +-
 net/openvswitch/vport-internal_dev.c             |   56 +-
 net/openvswitch/vport-netdev.c                   |   19 +
 net/openvswitch/vport-netdev.h                   |   12 -
 net/openvswitch/vport-vxlan.c                    |    2 +-
 net/openvswitch/vport.c                          |    2 +-
 net/openvswitch/vport.h                          |    6 +-
 net/switchdev/Kconfig                            |   20 +
 net/switchdev/Makefile                           |    6 +
 net/switchdev/switchdev.c                        |  174 ++
 net/switchdev/switchdev_netlink.c                |  493 +++
 53 files changed, 5931 insertions(+), 289 deletions(-)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 drivers/net/dummyswitch.c
 create mode 100644 drivers/net/ethernet/rocker/Kconfig
 create mode 100644 drivers/net/ethernet/rocker/Makefile
 create mode 100644 drivers/net/ethernet/rocker/rocker.c
 create mode 100644 drivers/net/ethernet/rocker/rocker.h
 create mode 100644 include/net/sw_flow.h
 create mode 100644 include/net/switchdev.h
 create mode 100644 include/uapi/linux/switchdev.h
 create mode 100644 net/openvswitch/hw_offload.c
 create mode 100644 net/openvswitch/hw_offload.h
 create mode 100644 net/switchdev/Kconfig
 create mode 100644 net/switchdev/Makefile
 create mode 100644 net/switchdev/switchdev.c
 create mode 100644 net/switchdev/switchdev_netlink.c

-- 
1.9.3
