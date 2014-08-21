From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 00/12] introduce rocker switch driver with openvswitch hardware accelerated datapath
Date: Thu, 21 Aug 2014 18:18:53 +0200
Message-ID: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wi0-f171.google.com ([209.85.212.171]:40913 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbaHUQTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:19:11 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so8965239wib.4
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 09:19:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset can be divided into 3 main sections:
- introduce switchdev api for implementing switch drivers
- add hardware acceleration bits into openvswitch datapath, This uses
  previously mentioned switchdev api
- introduce rocker switch driver which implenets switchdev api

More info in separate patches.

So now there is possible out of the box to create ovs bridge over rocker
switch ports and the flows will be offloaded into hardware.

Jiri Pirko (12):
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

 Documentation/networking/switchdev.txt           |   53 +
 MAINTAINERS                                      |    6 +
 drivers/net/Kconfig                              |   15 +
 drivers/net/Makefile                             |    3 +
 drivers/net/dummyswitch.c                        |  131 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 drivers/net/rocker.c                             | 3446 ++++++++++++++++++++++
 drivers/net/rocker.h                             |  465 +++
 include/linux/netdevice.h                        |   51 +-
 include/linux/sw_flow.h                          |  115 +
 include/linux/switchdev.h                        |   44 +
 include/uapi/linux/if_link.h                     |   10 +
 net/Kconfig                                      |    6 +
 net/core/Makefile                                |    1 +
 net/core/dev.c                                   |    2 +-
 net/core/net-sysfs.c                             |   26 +-
 net/core/rtnetlink.c                             |   30 +-
 net/core/switchdev.c                             |  173 ++
 net/dsa/Kconfig                                  |    2 +-
 net/dsa/slave.c                                  |   16 +
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
 net/openvswitch/hw_offload.c                     |  258 ++
 net/openvswitch/hw_offload.h                     |   22 +
 net/openvswitch/vport-gre.c                      |    4 +-
 net/openvswitch/vport-internal_dev.c             |   56 +-
 net/openvswitch/vport-netdev.c                   |   19 +
 net/openvswitch/vport-netdev.h                   |   12 -
 net/openvswitch/vport-vxlan.c                    |    2 +-
 net/openvswitch/vport.c                          |    2 +-
 net/openvswitch/vport.h                          |    6 +-
 43 files changed, 5145 insertions(+), 288 deletions(-)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 drivers/net/dummyswitch.c
 create mode 100644 drivers/net/rocker.c
 create mode 100644 drivers/net/rocker.h
 create mode 100644 include/linux/sw_flow.h
 create mode 100644 include/linux/switchdev.h
 create mode 100644 net/core/switchdev.c
 create mode 100644 net/openvswitch/hw_offload.c
 create mode 100644 net/openvswitch/hw_offload.h

-- 
1.9.3
