From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 00/12] Mellanox 100G ethernet SRIOV Upgrades
Date: Tue,  3 May 2016 17:13:52 +0300
Message-ID: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48719 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcECOO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 10:14:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series introduces new features and upgrades for mlx5 etherenet SRIOV,
while the first patch provides a bug fixes for a compilation issue introduced 
buy the previous aRFS series for when CONFIG_RFS_ACCEL=y and CONFIG_MLX5_CORE_EN=n.

Changes from V0:
    - 1st patch: Don't add a new Kconfig flag.  Instead, compile out en_arfs.c contents when CONFIG_RFS_ACCEL=n

SRIOV upgrades:
    - Use synchronize_irq instead of the vport events spin_lock
    - Fix memory leak in error flow
    - Added full VST support
    - Spoofcheck support
    - Trusted VF promiscuous and allmulti support

VST and Spoofcheck in details:
    - Adding Low level firmware commands support for creating ACLs
     (Access Control Lists) Flow tables.  ACLs are regular flow tables with 
     the only exception that they are bound to a specific e-Switch vport (VF)
     and they can be one of two types 
        > egress ACL: filters traffic going from e-Switch to VF.
        > ingress ACL: filters traffic going from VF to e-Switch.
    - Ingress/Egress ACLs (per vport) for VF VST mode filtering.
    - Ingress/Egress ACLs (per vport) for VF spoofcheck filtering.
    - Ingress/Egress ACLs (per vport) configuration:
        > Created only when at least one of (VST, spoofcheck) is configured.
	> if (!spoofchk && !vst) allow all traffic.  i.e. no ACLs.
        > if (spoofchk && vst) allow only untagged traffic with smac=original mac sent from the VF.
        > if (spoofchk && !vst) allow only traffic with smac=original mac sent from the VF.
        > if (!spoofchk && vst) allow only untagged traffic.

Trusted VF promiscuous and allmulti support in details:
    - Added two flow groups for allmulti and promisc VFs to the e-Switch FDB table
        > Allmulti group: One rule that forwards any mcast traffic coming from
                          either uplink or VFs/PF vports.
        > Promisc group: One rule that forwards all unmatched traffic coming from uplink.
    - Add vport context change event handling for promisc and allmulti
      If VF is trusted respect the request and:
        > if allmulti request: add the vport to the allmulti group.
          and to all other L2 mcast address in the FDB table.
        > if promisc request: add the vport to the promisc group.
        > Note: A promisc VF can only see traffic that was not explicitly matched to 
                or requested by any other VF.

Applied on top: 

Maor Gottlieb (1):
  net/mlx5e: Fix aRFS compilation dependency

Mohamad Haj Yahia (11):
  net/mlx5: Flow steering, Add vport ACL support
  net/mlx5: E-Switch, Replace vport spin lock with synchronize_irq()
  net/mlx5: E-Switch, Fix error flow memory leak
  net/mlx5: E-Switch, Introduce VST vport ingress/egress ACLs
  net/mlx5: E-Switch, Vport ingress/egress ACLs rules for VST mode
  net/mlx5: E-Switch, Vport ingress/egress ACLs rules for spoofchk
  net/mlx5: E-Switch, Enable/disable ACL tables on demand
  net/mlx5: E-Switch, Use vport event handler for vport cleanup
  net/mlx5: E-Switch, Add promiscuous and allmulti FDB flowtable groups
  net/mlx5: E-Switch, Implement promiscuous rx modes vf request handling
  net/mlx5: E-Switch, Implement trust vf ndo

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  17 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 976 +++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  43 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  33 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  85 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   7 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   2 +
 include/linux/mlx5/device.h                        |  12 +
 include/linux/mlx5/driver.h                        |   2 +
 include/linux/mlx5/fs.h                            |   7 +
 13 files changed, 1118 insertions(+), 73 deletions(-)

-- 
2.8.0
