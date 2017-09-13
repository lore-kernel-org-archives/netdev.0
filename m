From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC PATCH v3 0/7] tc-flower based cloud filters in i40e
Date: Wed, 13 Sep 2017 02:59:13 -0700
Message-ID: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        amritha.nambiar@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4581 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751991AbdIMKAW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 06:00:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables configuring cloud filters in i40e
using the tc-flower classifier. The only tc-filter action
supported is to redirect packets to a traffic class on the
same device. The mirror/redirect action is extended to
accept a traffic class to achieve this.

The cloud filters are added for a VSI and are cleaned up when
the VSI is deleted. The filters that match on L4 ports needs
enhanced admin queue functions with big buffer support for
extended fields in cloud filter commands.

Example:
# tc qdisc add dev eth0 ingress

# ethtool -K eth0 hw-tc-offload on

# tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
  dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
  skip_sw action mirred ingress redirect dev eth0 tclass 1

# tc filter show dev eth0 parent ffff:
filter protocol ip pref 1 flower chain 0
filter protocol ip pref 1 flower chain 0 handle 0x1
  eth_type ipv4
  ip_proto udp
  dst_ip 192.168.1.1
  dst_port 22
  skip_sw
  in_hw
        action order 1: mirred (Ingress Redirect to device eth0) stolen tclass 1
        index 7 ref 1 bind 1

v3: Added an extra patch to clean up white-space noise. Cleaned up
some lengthy function names. Used __be32 array for ipv6 address.
Used macro for IP version. Minor formatting changes.

---

Amritha Nambiar (7):
      tc_mirred: Clean up white-space noise
      sched: act_mirred: Traffic class option for mirror/redirect action
      i40e: Map TCs with the VSI seids
      i40e: Cloud filter mode for set_switch_config command
      i40e: Admin queue definitions for cloud filters
      i40e: Clean up of cloud filters
      i40e: Enable cloud filters via tc-flower


 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |    2 
 drivers/net/ethernet/intel/i40e/i40e.h             |   59 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  143 +++
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  193 ++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    2 
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  999 +++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   18 
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   10 
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  113 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    2 
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |    2 
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |    3 
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |    3 
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   |    1 
 drivers/net/ethernet/netronome/nfp/flower/action.c |    4 
 include/net/tc_act/tc_mirred.h                     |   16 
 include/uapi/linux/tc_act/tc_mirred.h              |    9 
 net/dsa/slave.c                                    |    3 
 net/sched/act_mirred.c                             |   15 
 19 files changed, 1547 insertions(+), 50 deletions(-)
