From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 0/8] cls_flower hardware offload support
Date: Tue,  1 Mar 2016 16:24:42 +0200
Message-ID: <1456842290-7844-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34109 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636AbcCAOVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:21:33 -0500
Received: by mail-wm0-f66.google.com with SMTP id p65so4361859wmp.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:21:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduces cls_flower hardware offload support over ConnectX-4
driver, more hardware vendors are welcome to use it too.

This patchset is based on John's infrastructure for tc offloading [2] to add
hardware offload support to the flower filter. It also extends the support to
an additional tc action - skbedit mark operation.
NIC driver that was used is ConnectX-4. Feature is off by default and could be
turned on using ethtool.

Some commands to use this code:

export TC=../iproute2/tc/tc
export ETH=ens9

ethtool  -K ens9 hw-tc-offload on

# add an ingress qdisc
$TC qdisc add dev $ETH ingress

# Drop ICMP (ip_proto 1) packets
$TC filter add dev $ETH protocol ip prio 20 parent ffff: \
	flower ip_proto 1 \
	dst_mac 7c:fe:90:69:81:62 \
	src_mac 7c:fe:90:69:81:56 \
	dst_ip 11.11.11.11 \
	src_ip 11.11.11.12 \
	indev $ETH \
	action drop

# Mark (with 0x1234) TCP (ip_proto 6) packets
$TC filter add dev $ETH protocol ip prio 30 parent ffff: \
	flower ip_proto 6 \
	indev $ETH \
	action skbedit mark 0x1234

# A NOP software filter used to count marked packets using "tc show -s"
$TC filter add dev $ETH protocol ip prio 10 parent ffff: \
	handle 0x1234 fw action pass

The code was tested and applied on top of commit f12d33f
("3c59x: Ensure to apply the expires time") + John's pending patches [3]

Main changes from the RFC [1]:
- API
  - Using ndo_setup_tc() instead of switchdev
- act_skbedit, act_gact
  - Actions are not serialized to NIC driver, instead using access functions.
- cls_flower
  - prevent double classification by software by not adding
    successfuly offloaded filters to the hashtable
  - Fixed some bugs in original RFC with rule delete  
- mlx5
  - Adding flow table to kernel namespace instead of a new namespace
  - s/offload/tc/ in many places
  - no need for a special kconfig since switchdev is not used

Thanks,
Amir

[1] - http://permalink.gmane.org/gmane.linux.network/397064
[2] - http://permalink.gmane.org/gmane.linux.network/397045 
[3] - http://permalink.gmane.org/gmane.linux.network/401226

Amir Vadai (8):
  net/flower: Introduce hardware offload support
  net/flow_dissector: Make dissector_uses_key() and
    skb_flow_dissector_target() public
  net/act_skbedit: Utility functions for mark action
  net/mlx5_core: Set flow steering dest only for forward rules
  net/mlx5e: Add a new priority for kernel flow tables
  net/mlx5e: Introduce tc offload support
  net/mlx5e: Support offload cls_flower with drop action
  net/mlx5e: Support offload cls_flower with sskbedit mark action

 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  40 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 434 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  51 +++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  29 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |  22 +-
 include/linux/netdevice.h                         |   2 +
 include/net/flow_dissector.h                      |  13 +
 include/net/pkt_cls.h                             |  14 +
 include/net/tc_act/tc_skbedit.h                   |  15 +
 include/uapi/linux/pkt_cls.h                      |   2 +
 net/core/flow_dissector.c                         |  13 -
 net/sched/cls_flower.c                            |  75 +++-
 16 files changed, 686 insertions(+), 42 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h

-- 
2.7.0
