From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud filters in
 i40e
Date: Tue, 10 Oct 2017 17:24:12 -0700
Message-ID: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jiri@resnulli.us,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12810 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751858AbdJKAZi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 20:25:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables configuring cloud filters in i40e
using the tc-flower classifier. The classification function
of the filter is to match a packet to a class. cls_flower is
extended to offload classid to hardware. The offloaded classid
is used direct matched packets to a traffic class on the device. 
The approach here is similar to the tc 'prio' qdisc which uses
the classid for band selection. The ingress qdisc is called ffff:0,
so traffic classes are ffff:1 to ffff:8 (i40e has max of 8 TCs).
TC0 is minor number 1, TC1 is minor number 2 etc.

The cloud filters are added for a VSI and are cleaned up when
the VSI is deleted. The filters that match on L4 ports needs
enhanced admin queue functions with big buffer support for
extended fields in cloud filter commands.

Example:
# tc qdisc add dev eth0 ingress
# ethtool -K eth0 hw-tc-offload on

Match Dst IPv4,Dst Port and route to TC1:
# tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
  dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
  skip_sw classid ffff:2

# tc filter show dev eth0 parent ffff:
filter pref 1 flower chain 0
filter pref 1 flower chain 0 handle 0x1 classid ffff:2
  eth_type ipv4
  ip_proto udp
  dst_ip 192.168.1.1
  dst_port 22
  skip_sw
  in_hw

v4: classid based approach to set traffic class for matched packets.

Authors:
Amritha Nambiar <amritha.nambiar@intel.com>
Kiran Patil <kiran.patil@intel.com>
Anjali Singhai Jain <anjali.singhai@intel.com>
Jingjing Wu <jingjing.wu@intel.com>
---

Amritha Nambiar (6):
      cls_flower: Offload classid to hardware
      i40e: Map TCs with the VSI seids
      i40e: Cloud filter mode for set_switch_config command
      i40e: Admin queue definitions for cloud filters
      i40e: Clean up of cloud filters
      i40e: Enable cloud filters via tc-flower


 drivers/net/ethernet/intel/i40e/i40e.h             |   55 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  143 +++
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  193 ++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    2 
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  941 +++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   18 
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   10 
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  113 ++
 include/net/pkt_cls.h                              |    1 
 net/sched/cls_flower.c                             |    2 
 10 files changed, 1439 insertions(+), 39 deletions(-)
