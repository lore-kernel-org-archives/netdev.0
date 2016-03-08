From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V3 00/10] cls_flower hardware offload support
Date: Tue,  8 Mar 2016 12:42:28 +0200
Message-ID: <1457433758-9193-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34469 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703AbcCHKjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 05:39:07 -0500
Received: by mail-wm0-f67.google.com with SMTP id p65so3237237wmp.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 02:39:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please see changes from V2 at the bottom.

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

The code was tested and applied on top of commit 3ebeac1 ("Merge branch
'cxgb4-next'")

Changes from V2:
- patch 1/10 ("net/flower: Introduce hardware offload support")
  - Remove unused variable [Dave]
  - Don't fail command when HW can't offload filter [John]
- patch 3/10 ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")
  - Mention in changelog that struct tc_action is now exposed out of the ifdef.
- patch 4/10 ("net/act_skbedit: Utility functions for mark action")
  - Document clearly that is_tcf_skbedit_mark() is returning true if and only
    if the only action is mark [Dave]
- patch 8/10 ("net/mlx5e: Introduce tc offload support")
  - make mlx5e_tc_add_flow() static

Changes from V1:
- patch 3/10 ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")
  - fixed return value of tc_no_actions

Changes from V0:
- Use tc_no_actions and tc_for_each_action instead of ifdef CONFIG_NET_CLS_ACT
- Replace ENOTSUPP (and some EINVAL) with EOPNOTSUPP
- Name the flower command enum
- fl_hw_destroy_filter() to return void - nobody uses the return value
- mlx5e_tc_init() and mlx5e_tc_cleanup() to be called from the right places.
- When adding HW rule fails - fail the command
- Rules are added to be processed both by HW and SW unless SKIP_HW is given
- Adding patch 6/10 ("net/mlx5e: Relax ndo_setup_tc handle restriction")

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

Amir Vadai (10):
  net/flower: Introduce hardware offload support
  net/flow_dissector: Make dissector_uses_key() and
    skb_flow_dissector_target() public
  net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef
  net/act_skbedit: Utility functions for mark action
  net/mlx5_core: Set flow steering dest only for forward rules
  net/mlx5e: Relax ndo_setup_tc handle restriction
  net/mlx5e: Add a new priority for kernel flow tables
  net/mlx5e: Introduce tc offload support
  net/mlx5e: Support offload cls_flower with drop action
  net/mlx5e: Support offload cls_flower with skbedit mark action

 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  47 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 429 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  51 +++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  29 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |  22 +-
 include/linux/netdevice.h                         |   2 +
 include/net/act_api.h                             |  21 +-
 include/net/flow_dissector.h                      |  13 +
 include/net/pkt_cls.h                             |  14 +
 include/net/tc_act/tc_gact.h                      |   4 +-
 include/net/tc_act/tc_skbedit.h                   |  16 +
 include/uapi/linux/pkt_cls.h                      |   2 +
 net/core/flow_dissector.c                         |  13 -
 net/sched/cls_flower.c                            |  64 +++-
 18 files changed, 698 insertions(+), 47 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h

-- 
2.7.0
