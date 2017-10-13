From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 40GbE Intel Wired LAN Driver Updates 2017-10-13
Date: Fri, 13 Oct 2017 14:52:40 -0700
Message-ID: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:13198 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751889AbdJMVxS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 17:53:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to mqprio and i40e.

Amritha introduces a new hardware offload mode in tc/mqprio where the TCs,
the queue configurations and bandwidth rate limits are offloaded to the
hardware. The existing mqprio framework is extended to configure the queue
counts and layout and also added support for rate limiting. This is
achieved through new netlink attributes for the 'mode' option which takes
values such as 'dcb' (default) and 'channel' and a 'shaper' option for
QoS attributes such as bandwidth rate limits in hw mode 1.  Legacy devices
can fall back to the existing setup supporting hw mode 1 without these
additional options where only the TCs are offloaded and then the 'mode'
and 'shaper' options defaults to DCB support.  The i40e driver enables the
new mqprio hardware offload mechanism factoring the TCs, queue
configuration and bandwidth rates by creating HW channel VSIs.
In this new mode, the priority to traffic class mapping and the user
specified queue ranges are used to configure the traffic class when the
'mode' option is set to 'channel'. This is achieved by creating HW
channels(VSI). A new channel is created for each of the traffic class
configuration offloaded via mqprio framework except for the first TC (TC0)
which is for the main VSI. TC0 for the main VSI is also reconfigured as
per user provided queue parameters. Finally, bandwidth rate limits are set
on these traffic classes through the shaper attribute by sending these
rates in addition to the number of TCs and the queue configurations.

Colin Ian King makes an array of constant values "constant".

Alan fixes and issue where on some firmware versions, we were failing to
actually fill out the phy_types which caused ethtool to not report any
link types.  Also hardened against a potentially malicious VF by not
letting the VF to reset itself after requesting to change the number of
queues (via ethtool), let the PF reset the VF to institute the requested
changes.

The following are changes since commit a00344bd1bbea2ba40719ae0eb3b6da7fae08cf2:
  Merge branch 'tipc-comm-groups'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40e: fix link reporting
  i40e/i40evf: don't trust VF to reset itself

Amritha Nambiar (6):
  mqprio: Introduce new hardware offload mode and shaper in mqprio
  i40e: Add macro for PF reset bit
  i40e: Add infrastructure for queue channel support
  i40e: Enable 'channel' mode in mqprio for TC configs
  i40e: Refactor VF BW rate limiting
  i40e: Add support setting TC max bandwidth rates

Colin Ian King (1):
  i40e: make const array patterns static, reduces object code size

 drivers/net/ethernet/intel/i40e/i40e.h             |   44 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |    7 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    3 +-
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |    4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    8 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 1462 +++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |    2 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   59 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |    7 +-
 include/linux/avf/virtchnl.h                       |    4 +-
 include/net/pkt_cls.h                              |    9 +
 include/uapi/linux/pkt_sched.h                     |   32 +
 net/sched/sch_mqprio.c                             |  183 ++-
 13 files changed, 1571 insertions(+), 253 deletions(-)

-- 
2.14.2
