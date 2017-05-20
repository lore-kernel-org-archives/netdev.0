From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH 0/4] Configuring traffic classes via new hardware offload
 mechanism in tc/mqprio
Date: Fri, 19 May 2017 17:58:17 -0700
Message-ID: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, sridhar.samudrala@intel.com,
        mitch.a.williams@intel.com, neerav.parikh@intel.com,
        jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7933 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755494AbdESU2A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 16:28:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series introduces a new harware offload mode in tc/mqprio where the TCs, the queue configurations and bandwidth rate limits are offloaded to the hardware.
The i40e driver enables the new mqprio hardware offload mechanism factoring the TCs, queue configuration and bandwidth rates by creating HW channel VSIs. 

In this mode, the priority to traffic class mapping and the user specified queue ranges are used to configure the traffic class when the 'hw' option is set to 2. This is achieved by creating HW channels(VSI). A new channel is created for each of the traffic class configuration offloaded via mqprio framework except for the first TC (TC0) which is for the main VSI. TC0 for the main VSI is also reconfigured as per user provided queue parameters. Finally, bandwidth rate limits are set on these traffic classes through the mqprio offload framework by sending these rates in addition to the number of TCs and the queue configurations.

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

Amritha Nambiar (4):
      [next-queue]net: mqprio: Introduce new hardware offload mode in mqprio for offloading full TC configurations
      [next-queue]net: i40e: Add infrastructure for queue channel support with the TCs and queue configurations offloaded via mqprio scheduler
      [next-queue]net: i40e: Enable mqprio full offload mode in the i40e driver for configuring TCs and queue mapping
      [next-queue]net: i40e: Add support to set max bandwidth rates for TCs offloaded via tc/mqprio


 drivers/net/ethernet/intel/i40e/i40e.h         |   42 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |    6 
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 1365 +++++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |    2 
 include/linux/netdevice.h                      |    2 
 include/net/pkt_cls.h                          |    7 
 include/uapi/linux/pkt_sched.h                 |   13 
 net/sched/sch_mqprio.c                         |  169 +++
 8 files changed, 1449 insertions(+), 157 deletions(-)
