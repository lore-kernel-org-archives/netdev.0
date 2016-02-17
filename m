From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 0/8] tc offload for cls_u32 on ixgbe
Date: Tue, 16 Feb 2016 21:15:50 -0800
Message-ID: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: jiri@resnulli.us, amir@vadai.me, john.fastabend@gmail.com,
	jhs@mojatatu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34560 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbcBQFQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 00:16:09 -0500
Received: by mail-pf0-f179.google.com with SMTP id x65so4750524pfb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 21:16:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends the setup_tc framework so it can support more than just
the mqprio offload and push other classifiers and qdiscs into the
hardware. The series here targets the u32 classifier and ixgbe
driver. I worked out the u32 classifier because it is protocol
oblivious and aligns with multiple hardware devices I have access
to. I did an initial implementation on ixgbe because (a) I have one
in my box (b) its a stable driver and (c) it is relatively simple
compared to the other devices I have here but still has enough
flexibility to exercise the features of cls_u32.

I intentionally limited the scope of this series to the basic
feature set. Specifically this uses a 'big hammer' feature bit
to do the offload or not. If the bit is set you get offloaded rules
if it is not then rules will not be offloaded. If we can agree on
this patch series there are some more patches on my queue we can
talk about to make the offload decision per rule using flags similar
to how we do l2 mac updates. Additionally the error strategy can
be improved to be hard aborting, log and continue, etc. I think
these are nice to have improvements but shouldn't block this series.

Also by adding get_parse_graph and set_parse_graph attributes as
in my previous flow_api work we can build programmable devices
and programmatically learn when rules can or can not be loaded
into the hardware. Again future work.

... v3 includes a couple style fixups suggested by Jiri and a
quick fix to ixgbe to check features flag and not dev_features
flag the latter being always set.

---

John Fastabend (8):
      net: rework ndo tc op to consume additional qdisc handle parameter
      net: rework setup_tc ndo op to consume general tc operand
      net: sched: add cls_u32 offload hooks for netdevs
      net: add tc offload feature flag
      net: tc: helper functions to query action types
      net: ixgbe: add minimal parser details for ixgbe
      net: ixgbe: add support for tc_u32 offload
      net: ixgbe: abort with cls u32 divisor groups greater than 1


 drivers/net/ethernet/amd/xgbe/xgbe-drv.c         |   10 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    8 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    2 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 
 drivers/net/ethernet/broadcom/bnxt/bnxt.c        |    9 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |   11 +
 drivers/net/ethernet/intel/i40e/i40e.h           |    3 
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c      |    2 
 drivers/net/ethernet/intel/i40e/i40e_main.c      |   19 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    7 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    6 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  272 ++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h   |  112 +++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   13 +
 drivers/net/ethernet/sfc/efx.h                   |    3 
 drivers/net/ethernet/sfc/tx.c                    |   10 +
 drivers/net/ethernet/ti/netcp_core.c             |   14 +
 include/linux/netdev_features.h                  |    3 
 include/linux/netdevice.h                        |   25 ++
 include/net/pkt_cls.h                            |   34 +++
 include/net/tc_act/tc_gact.h                     |   16 +
 net/core/ethtool.c                               |    1 
 net/sched/cls_u32.c                              |   99 ++++++++
 net/sched/sch_mqprio.c                           |    8 -
 24 files changed, 632 insertions(+), 57 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
