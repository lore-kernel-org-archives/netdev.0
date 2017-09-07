From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC PATCH v3 0/6] Configuring traffic classes via new hardware
 offload mechanism in tc/mqprio
Date: Thu, 07 Sep 2017 04:00:01 -0700
Message-ID: <150478158684.24662.17975701233699487888.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        amritha.nambiar@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34308 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753927AbdIGLBG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 07:01:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series introduces a new hardware offload mode in
tc/mqprio where the TCs, the queue configurations and
bandwidth rate limits are offloaded to the hardware. The existing
mqprio framework is extended to configure the queue counts and
layout and also added support for rate limiting. This is achieved
through new netlink attributes for the 'mode' option which takes
values such as 'dcb' (default) and 'channel' and a 'shaper' option
for QoS attributes such as bandwidth rate limits in hw mode 1.
Legacy devices can fall back to the existing setup supporting hw mode
1 without these additional options where only the TCs are offloaded
and then the 'mode' and 'shaper' options defaults to DCB support.
The i40e driver enables the new mqprio hardware offload mechanism
factoring the TCs, queue configuration and bandwidth rates by
creating HW channel VSIs.

In this new mode, the priority to traffic class mapping and the
user specified queue ranges are used to configure the traffic
class when the 'mode' option is set to 'channel'. This is achieved by
creating HW channels(VSI). A new channel is created for each of the
traffic class configuration offloaded via mqprio framework except for
the first TC (TC0) which is for the main VSI. TC0 for the main VSI is
also reconfigured as per user provided queue parameters. Finally,
bandwidth rate limits are set on these traffic classes through the
shaper attribute by sending these rates in addition to the number of
TCs and the queue configurations.

Example:
    # tc qdisc add dev eth0 root mqprio num_tc 2 map 0 0 0 0 1 1 1 1\
      queues 4@0 4@4 hw 1 mode channel shaper bw_rlimit\
      min_rate 1Gbit 2Gbit max_rate 4Gbit 5Gbit

    To dump the bandwidth rates:

    # tc qdisc show dev eth0

    qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
                 queues:(0:3) (4:7)
                 mode:channel
                 shaper:bw_rlimit   min_rate:1Gbit 2Gbit   max_rate:4Gbit 5Gbit

---

Amritha Nambiar (6):
      mqprio: Introduce new hardware offload mode and shaper in mqprio
      i40e: Add macro for PF reset bit
      i40e: Add infrastructure for queue channel support
      i40e: Enable 'channel' mode in mqprio for TC configs
      i40e: Refactor VF BW rate limiting
      i40e: Add support setting TC max bandwidth rates


 drivers/net/ethernet/intel/i40e/i40e.h             |   44 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    3 
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    8 
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 1463 +++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |    2 
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   50 -
 include/net/pkt_cls.h                              |    9 
 include/uapi/linux/pkt_sched.h                     |   32 
 net/sched/sch_mqprio.c                             |  183 ++-
 9 files changed, 1551 insertions(+), 243 deletions(-)
