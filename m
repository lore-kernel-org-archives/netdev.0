From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH 0/6] bonding: only advertise LRO if underlying hardware can LRO
Date: Thu, 13 Aug 2015 14:02:54 -0400
Message-ID: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, Jiri Pirko <jiri@resnulli.us>,
	Jon Mason <jdmason@kudzu.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At present, you can create a bond, containing only underlying slaves that do
not support LRO, and the bond will happily claim to support LRO, and allow
LRO to be toggled on and off by ethtool. While things actually do function
fine in the scenario, and this is merely cosmetic, its a bit misleading to
users, and its something we can fix.

If we add NETIF_F_LRO to the NETIF_F_ONE_FOR_ALL flags in
netdev_features.h, then netdev_features_increment() will only enable LRO
if 1) its listed in the device's feature mask and 2) if there's actually a
slave present that supports the feature.

However, the bnx2x, ixgbe, netxen, qlcnic and s2io drivers all fail to report
support for LRO in their vlan_features, which requires some minor fixups to
these drivers to keep LRO working in cases where it should have been before
this set. The mellanox mlx5 and cavium liquidio drivers already properly set
the LRO flag in their vlan_features.

Note: I've only tested explicitly with bnx2x, as well as some non-LRO hw,
to confirm that:

1) if all slaves support LRO, the bond enables LRO
2) if some slaves support LRO, the bond enables LRO
3) if no slaves support LRO, the bond disables LRO

This set was generated against net-next master, it applies to 4.2.0-rc6 with
a bit of fuzz.

Jarod Wilson (6):
  net/bonding: enable LRO if one device supports it
  ethernet/bnx2x: advertise LRO support in vlan_features
  ethernet/ixgbe: advertise LRO support in vlan_features
  ethernet/netxen: advertise LRO support in vlan_features
  ethernet/qlcnic: advertise LRO support in vlan_features
  ethernet/s2io: advertise what hw supports in vlan_features

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     | 3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        | 4 +++-
 drivers/net/ethernet/neterion/s2io.c                 | 1 +
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 4 +++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     | 4 +++-
 include/linux/netdev_features.h                      | 3 ++-
 6 files changed, 14 insertions(+), 5 deletions(-)

CC: "David S. Miller" <davem@davemloft.net>
CC: Ariel Elior <ariel.elior@qlogic.com>
CC: Manish Chopra <manish.chopra@qlogic.com>
CC: Rajesh Borundia <rajesh.borundia@qlogic.com>
CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
CC: Sony Chacko <sony.chacko@qlogic.com>
CC: Dept-GELinuxNICDev@qlogic.com
CC: Jiri Pirko <jiri@resnulli.us>
CC: Jon Mason <jdmason@kudzu.us>
CC: Scott Feldman <sfeldma@gmail.com>
CC: Tom Herbert <therbert@google.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
-- 
1.8.3.1
