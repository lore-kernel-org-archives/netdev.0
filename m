From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v3 00/10] introduce infrastructure for support of switch chip datapath
Date: Thu, 17 Apr 2014 14:14:27 +0200
Message-ID: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
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
	Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:48502 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161024AbaDQMOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 08:14:46 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so611163eek.3
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 05:14:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The basic idea is to introduce a generic infractructure to support various
switch chips in kernel.

The current patchset RFC is a heavy rework of the previous ones. The goal is to
be low-intrusive and to use as much as possible from the existing
infrastructure.

Also the idea is to benefit from currently existing Open vSwitch userspace
infrastructure prividing a HW offload for it. Note that this is just one
usecase. Other sw*dev_ndos can be easily added to support many more usecases,

Please see Documentation/networking/switchdev.txt for more details about
the model.

Next step would be to introduce a flag via which OVS userspace could tell if the
flow should be inserted in HW or just in the SW datapath. That would extend current
2 level cashing (kernel, userspace) to 3 level (hw, kernel, userspace).

Next step would be to improve internal kernel notifiers and introduce a listener
which would call sw*dev_ndos to setup the switch according to what the user
wants. This would allow a usecase then a user configures bridges, bonds, etc and
the switch chip underneath gets configured by that.

Any suggestions, feedbacks welcome.

Jiri Pirko (10):
  openvswitch: split flow structures into ovs specific and generic ones
  net: rename netdev_phys_port_id to more generic name
  net: introduce generic switch devices support
  rtnl: expose physical switch id for particular device
  switchdev: introduce basic support for flows
  net: introduce dummy switch
  dsa: implement ndo_swdev_get_id
  net: add netdev_for_each_all_lower_dev_rcu helper
  openvswitch: introduce vport_op get_netdev
  openvswitch: add support for datapath hardware offload

 Documentation/networking/switchdev.txt           |  53 +++++++
 drivers/net/Kconfig                              |   7 +
 drivers/net/Makefile                             |   1 +
 drivers/net/dummyswitch.c                        | 126 +++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   2 +-
 include/linux/netdevice.h                        |  74 ++++++++--
 include/linux/sw_flow.h                          | 122 ++++++++++++++++
 include/linux/switchdev.h                        |  55 ++++++++
 include/uapi/linux/if_link.h                     |  10 ++
 net/Kconfig                                      |   6 +
 net/core/Makefile                                |   1 +
 net/core/dev.c                                   |  28 ++--
 net/core/net-sysfs.c                             |   2 +-
 net/core/rtnetlink.c                             |  30 +++-
 net/core/switchdev.c                             |  90 ++++++++++++
 net/dsa/slave.c                                  |  16 +++
 net/openvswitch/Makefile                         |   3 +-
 net/openvswitch/datapath.c                       |  63 +++++----
 net/openvswitch/datapath.h                       |   4 +-
 net/openvswitch/dp_notify.c                      |   7 +-
 net/openvswitch/flow.c                           |  14 +-
 net/openvswitch/flow.h                           | 123 ++++------------
 net/openvswitch/flow_netlink.c                   |  24 ++--
 net/openvswitch/flow_netlink.h                   |   4 +-
 net/openvswitch/flow_table.c                     | 100 ++++++-------
 net/openvswitch/flow_table.h                     |  18 +--
 net/openvswitch/hw_offload.c                     | 170 +++++++++++++++++++++++
 net/openvswitch/hw_offload.h                     |  31 +++++
 net/openvswitch/vport-gre.c                      |   4 +-
 net/openvswitch/vport-internal_dev.c             |  53 ++++---
 net/openvswitch/vport-netdev.c                   |  16 +++
 net/openvswitch/vport-netdev.h                   |  12 --
 net/openvswitch/vport-vxlan.c                    |   2 +-
 net/openvswitch/vport.c                          |   2 +-
 net/openvswitch/vport.h                          |   4 +-
 37 files changed, 1004 insertions(+), 277 deletions(-)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 drivers/net/dummyswitch.c
 create mode 100644 include/linux/sw_flow.h
 create mode 100644 include/linux/switchdev.h
 create mode 100644 net/core/switchdev.c
 create mode 100644 net/openvswitch/hw_offload.c
 create mode 100644 net/openvswitch/hw_offload.h

-- 
1.9.0
