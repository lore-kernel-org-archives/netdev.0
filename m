From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 0/9] TC filter HW offloads
Date: Mon,  1 Feb 2016 08:34:36 +0000
Message-ID: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32826 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751853AbcBAIgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:36:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

So... just before sending that, I noted Jonh's series that
deals with tc and u32. One notable difference between the 
two approaches is that here we "normalize" the upper layer
way of describing matching and actions into a generic structure
(flow dissector, etc), which should allow to use offload different
potential consumer tools (TC flower, TC u32 subset), netfilter, etc).
Another difference is with this series uses the switchdev
framework which would allow using the proposed HW offloading
mechanisms for physical and SRIOV embedded switches too that
make use of switchdev.

This patchset introduces an infrastructure to offload matching of flows and
some basic actions to hardware, currenrtly using iproute2 / tc tool.

In this patchset, the classification is described using the flower filter, and
the supported actions are drop (using gact) and mark (using skbedit).

Flow classifcation is described using a flow dissector that is built by 
the tc filter. The filter also calls the actions to be serialized into the new
structure - switchdev_obj_port_flow_act.

The flow dissector and the serialized actions are passed using switchdev ops to
the HW driver, which parse it to hardware commands. We propose to use the
kernel flow-dissector to describe flows/ACLs in the switchdev framework which
by itself could be also used for HW offloading of other kernel networking
components.

An implementation for the above is provided using mlx5 driver and Mellanox 
ConnectX4 HW.

Some issues that will be addressed before making the final submission:
1. 'offload' should be a generic filter attribute and not flower filter
   specific.
2. Serialization of actions will be changed into a list instead of one big
   structure to describe all actions.

Few more matters to discuss 

1. Should HW offloading be done only under explicit admin directive?

2. switchdev is used today for physical switch HW and on an upcoming proposal
for SRIOV e-switch vport representors too. Here, we're doing that with a NIC, 
that can potentially serve as an uplink port for v-switch (e.g under Para-Virtual 
scheme).

Sample usage of the feature:

export TC=../iproute2/tc/tc
export ETH=ens9

ifconfig ens9 11.11.11.11/24 up

# add an ingress qdisc
$TC qdisc add dev $ETH ingress

# Drop ICMP (ip_proto 1) packets
$TC filter add dev $ETH protocol ip prio 20 parent ffff: \
                flower eth_type ip ip_proto 1 \
                indev $ETH offload \
                action drop

# Mark (with 0x1234) TCP (ip_proto 6) packets
$TC filter add dev $ETH protocol ip prio 30 parent ffff: \
                flower eth_type ip ip_proto 6 \
                indev $ETH offload \
                action skbedit mark 0x1234

# A NOP filter for packets that are marked (0x1234)
$TC filter add dev $ETH protocol ip prio 10 parent ffff: \
                handle 0x1234 fw action pass

# See that pings are blocked
# See that ssh is working (=TCP traffic)

# See NOP filter counters. If >0, HW marked and NOP filter catched it
$TC -s filter show dev $ETH parent ffff:

This patchset depends on a small fix [1] that is currently under review in the
mailing list.  It was applied and tested on net-next commit 7a26019
("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")

[1] Depends on "net/mlx5_core: Set flow steering dest only for forward rules"
    - http://patchwork.ozlabs.org/patch/574055/   

Thanks,
Amir

Amir Vadai (9):
  net/flow_dissector: Make dissector_uses_key() and
    skb_flow_dissector_target() public
  net/switchdev: Introduce hardware offload support
  net/act: Offload support by tc actions
  net/act_skbedit: Introduce hardware offload support
  net/act_gact: Introduce hardware offload support for drop
  net/cls_flower: Introduce hardware offloading
  net/mlx5_core: Go to next flow table support
  net/mlx5e: Introduce MLX5_FLOW_NAMESPACE_OFFLOADS
  net/mlx5e: Flow steering support through switchdev

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   2 +
 .../net/ethernet/mellanox/mlx5/core/en_switchdev.c | 475 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_switchdev.h |  60 +++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  26 ++
 include/linux/mlx5/fs.h                            |   1 +
 include/net/act_api.h                              |   3 +
 include/net/flow_dissector.h                       |  13 +
 include/net/pkt_cls.h                              |   2 +
 include/net/switchdev.h                            |  46 ++
 include/uapi/linux/pkt_cls.h                       |   1 +
 net/core/flow_dissector.c                          |  13 -
 net/sched/act_gact.c                               |  17 +
 net/sched/act_skbedit.c                            |  18 +
 net/sched/cls_api.c                                |  27 ++
 net/sched/cls_flower.c                             |  54 ++-
 net/switchdev/switchdev.c                          |  33 ++
 21 files changed, 807 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.h

-- 
2.7.0
