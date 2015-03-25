From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v8 0/7]: ixgbevf: Allow querying VFs RSS indirection table and key
Date: Wed, 25 Mar 2015 19:42:35 +0200
Message-ID: <1427305362-23948-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com, intel-wired-lan@lists.osuosl.org,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33810 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182AbbCYRmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 13:42:49 -0400
Received: by wgs2 with SMTP id 2so36458686wgs.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:42:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS Random Key.

On some devices VFs share the RSS Redirection Table and Hash Key with a PF and letting
the VF query this information may introduce some security risks. Therefore we disable this
feature by default for such devices (e.g. 82599) and allow it for those where there isn't any
possible risk (e.g. on x550). The new netdev op is going to allow a system administrator to
change the default behaviour with "ip link set" command.

 - netdev: Add a new netdev op to allow/block VF from querying RSS Indirection Table and
   RSS Hash Key.
 - PF driver: Add new VF-PF channel commands.
 - VF driver: Utilize these new commands and add the corresponding
              ethtool callbacks.

New in v8:
   - Protect new mailbox operations with adapter.mbx_lock spinlock.

New in v7:
   - Add ixgbe_mbox_api_12 case in ixgbevf_set_num_queues().
   - Properly expand HW RETA into the ethtool buffer.

New in v6:
   - Add a proper return code when an VF query operations are blocked by PF.
   - Added a required get_rxnfc callback to ixgbevf_ethtool_ops.
   - Changed a description of PATCH7: set the correct ethtool options names.

New in v5:
   - Added a new netdev op to allow/block VF from querying RSS Indirection Table and
     RSS Hash Key.
   - Let VF query the RSS info only if VF is allowed to.

New in v4:
   - Forgot to run checkpatch on v3 and there were a few styling things to fix. ;)

New in v3:
   - Added a missing support for x550 devices.
   - Mask the indirection table values according to PSRTYPE[n].RQPL.
   - Minimized the number of added VF-PF commands.

New in v2:
   - Added a detailed description to patches 4 and 5.

New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case.
     More specifically: in cases where the newly added API version is the only one
     allowed. We may consider using a "switch-case" back again when the list of
     allowed API versions in these specific places grows up.


Vlad Zolotarov (7):
  if_link: Add an additional parameter to ifla_vf_info for RSS querying
  ixgbe: Add a new netdev op to allow/prevent a VF from querying an RSS
    info
  ixgbe: Add a RETA query command to VF-PF channel API
  ixgbevf: Add a RETA query code
  ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
  ixgbevf: Add RSS Key query code
  ixgbevf: Add the appropriate ethtool ops to query RSS indirection
    table and key

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   7 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 119 ++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   2 +
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  58 +++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   5 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 184 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   3 +
 include/linux/if_link.h                           |   1 +
 include/linux/netdevice.h                         |   8 +
 include/uapi/linux/if_link.h                      |   8 +
 net/core/rtnetlink.c                              |  32 +++-
 14 files changed, 441 insertions(+), 7 deletions(-)

-- 
2.1.0
