From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/13] Mellanox 100G SRIOV offloads tunnel_key set/release
Date: Mon,  7 Nov 2016 15:14:35 +0200
Message-ID: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39578 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753413AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
  
>From Hadar Hen Zion: 

This series further enhances the SRIOV TC offloads of mlx5 to handle the
TC tunnel_key release and set actions.

This serves a common use-case in virtualization systems where the virtual
switch encapsulate packets (tunnel_key set action) sent from VMs with
outer headers corresponding to the local/remote host IPs and de-capsulate
(tunnel_key release) outer headers before the packets are received by the
VM. 

We use the new E-Switch switchdev mode and TC tunnel_key set/release
action to achieve that also in SW defined SRIOV environments by
offloading TC rules that contain these actions along with forwarding
(TC mirred/redirect action) the packets.

The first six patches are adding the needed support in flow dissector,
flower and tc for offloading tunnel_key actions:
    - The first three patches are adding the needed help functions
      and enums
    - The next three patches in the series are adding UDP port attribute
      to tunnel_key release and set actions. 

The addition of UDP ports would allow the HW driver to make sure they are
given (say) a VXLAN tunnel to offload (mlx5e uses that).

Patches 7-10 are mlx5 preparations for tunnel_key actions offloads support.

Patch #11 adds mlx5e support to offload tunnel_key release action, and the
last two patches (#12-13) add mlx5e support to tc tunnel_key set action.

Currently in order to offload tc tunnel_key release action, the tc rule
should be placed on top of the mlx5e offloading (uplink) interface instead
of the shared tunnel interface. The resolution between the tunnel interface
to the HW netdevice will be implemented in a follow up series.

Hadar.

This series was generated against commit
94edc86bf13f ("Merge branch 'dwmac-sti-refactor-cleanup'")

Thanks,
Saeed.

Hadar Hen Zion (13):
  net/sched: act_tunnel_key: add helper inlines to access tcf_tunnel_key
  flow_dissector: Add enums for encapsulation keys
  net/sched: cls_flower: Allow setting encapsulation fields as used key
  net/sched: cls_flower: Add UDP port to tunnel parameters
  net/dst: Add dst port to dst_metadata utility functions
  net/sched: act_tunnel_key: Add UDP dst port option
  net/mlx5: Move alloc/dealloc encap commands declarations to common
    header file
  net/mlx5: Check max encap header size capability
  net/mlx5: Add creation flags when adding new flow table
  net/mlx5: Support encap id when setting new steering entry
  net/mlx5e: Add TC tunnel release action for SRIOV offloads
  net/mlx5e: Add ndo_udp_tunnel_add to VF representors
  net/mlx5e: Add basic TC tunnel set action for SRIOV offloads

 drivers/infiniband/hw/mlx5/main.c                  |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  19 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  35 +-
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 462 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  26 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  20 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  42 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  46 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  76 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   2 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   6 +
 include/linux/mlx5/fs.h                            |  19 +-
 include/net/dst_metadata.h                         |  10 +-
 include/net/flow_dissector.h                       |   5 +
 include/net/tc_act/tc_tunnel_key.h                 |  37 ++
 include/uapi/linux/pkt_cls.h                       |   5 +
 include/uapi/linux/tc_act/tc_tunnel_key.h          |   1 +
 net/sched/act_tunnel_key.c                         |  15 +-
 net/sched/cls_flower.c                             |  39 +-
 24 files changed, 764 insertions(+), 148 deletions(-)

-- 
2.7.4
