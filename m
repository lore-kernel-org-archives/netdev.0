From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH 0/6] Configuring traffic classes via new hardware offload
 mechanism in tc/mqprio
Date: Tue, 11 Jul 2017 03:18:30 -0700
Message-ID: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:54321 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932322AbdGKKS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 06:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series introduces a new hardware offload mode in
tc/mqprio where the TCs, the queue configurations and
bandwidth rate limits are offloaded to the hardware. The existing
mqprio framework is extended to configure the queue counts and
layout and also added support for rate limiting. This is achieved
by setting the value 2 for the "hw" mode. Legacy devices can fall
back to the existing setup supporting hw mode 1 where only the
TCs are offloaded, however if hw mode 2 is specified, then this
type of offload fails to initialize if the requested mode is not
supported. The i40e driver enables the new mqprio hardware offload
mechanism factoring the TCs, queue configuration and bandwidth
rates by creating HW channel VSIs.

In this new mode, the priority to traffic class mapping and the
user specified queue ranges are used to configure the traffic
class when the 'hw' option is set to 2. This is achieved by
creating HW channels(VSI). A new channel is created for each
of the traffic class configuration offloaded via mqprio
framework except for the first TC (TC0) which is for the main
VSI. TC0 for the main VSI is also reconfigured as per user
provided queue parameters. Finally, bandwidth rate limits are
set on these traffic classes through the mqprio offload
framework by sending these rates in addition to the number of
TCs and the queue configurations.

Example:
# tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
  queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2

To dump the bandwidth rates:

# tc qdisc show dev eth0
  qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
               queues:(0:3) (4:7)
               min rates:0bit 0bit
               max rates:55Mbit 60Mbit
---

Amritha Nambiar (6):
      [next-queue]net: mqprio: Introduce new hardware offload mode in mqprio for offloading full TC configurations
      [next-queue]net: i40e: Add macro for PF reset bit
      [next-queue]net: i40e: Add infrastructure for queue channel support with the TCs and queue configurations offloaded via mqprio scheduler
      [next-queue]net: i40e: Enable mqprio full offload mode in the i40e driver for configuring TCs and queue mapping
      [next-queue]net: i40e: Refactor VF BW rate limiting function to be reused on the PF as well
      [next-queue]net: i40e: Add support to set max bandwidth rates for TCs offloaded via tc/mqprio


 drivers/net/ethernet/intel/i40e/i40e.h             |   45 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    3 
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    8 
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 1478 +++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |    2 
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   50 -
 include/linux/netdevice.h                          |    2 
 include/net/pkt_cls.h                              |    7 
 include/uapi/linux/pkt_sched.h                     |   13 
 net/sched/sch_mqprio.c                             |  170 ++
 10 files changed, 1526 insertions(+), 252 deletions(-)
