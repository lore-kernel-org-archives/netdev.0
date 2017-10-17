From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/20] net: sched: convert cls ndo_setup_tc offload calls to per-block callbacks
Date: Tue, 17 Oct 2017 22:05:55 +0200
Message-ID: <20171017200615.4530-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:54173 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764008AbdJQUGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:18 -0400
Received: by mail-wm0-f65.google.com with SMTP id q132so6159917wmd.2
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset is a bit bigger, but most of the patches are doing the
same changes in multiple classifiers and drivers. I could do some
squashes, but I think it is better split.

This is another dependency on the way to shared block implementation.
The goal is to remove use of tp->q in classifiers code.

Also, this provides drivers possibility to track binding of blocks to
qdiscs. Legacy drivers which do not support shared block offloading.
register one callback per binding. That maintains the current
functionality we have with ndo_setup_tc. Drivers which support block
sharing offload register one callback per block which safes overhead.

Patches 1-4 introduce the binding notifications and per-block callbacks
Patches 5-8 add block callbacks calls to classifiers
Patches 9-17 do convert from ndo_setup_tc calls to block callbacks for
             classifier offloads in drivers
Patches 18-20 do cleanup

Jiri Pirko (20):
  net: sched: add block bind/unbind notif. and extended block_get/put
  net: sched: use extended variants of block_get/put in ingress and
    clsact qdiscs
  net: sched: introduce per-block callbacks
  net: sched: use tc_setup_cb_call to call per-block callbacks
  net: sched: cls_matchall: call block callbacks for offload
  net: sched: cls_u32: swap u32_remove_hw_knode and u32_remove_hw_hnode
  net: sched: cls_u32: call block callbacks for offload
  net: sched: cls_bpf: call block callbacks for offload
  mlxsw: spectrum: Convert ndo_setup_tc offloads to block callbacks
  mlx5e: Convert ndo_setup_tc offloads to block callbacks
  bnxt: Convert ndo_setup_tc offloads to block callbacks
  cxgb4: Convert ndo_setup_tc offloads to block callbacks
  ixgbe: Convert ndo_setup_tc offloads to block callbacks
  mlx5e_rep: Convert ndo_setup_tc offloads to block callbacks
  nfp: flower: Convert ndo_setup_tc offloads to block callbacks
  nfp: bpf: Convert ndo_setup_tc offloads to block callbacks
  dsa: Convert ndo_setup_tc offloads to block callbacks
  net: sched: avoid ndo_setup_tc calls for TC_SETUP_CLS*
  net: sched: remove unused classid field from tc_cls_common_offload
  net: sched: remove unused is_classid_clsact_ingress/egress helpers

 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  37 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c       |   3 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c      |  41 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  42 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  45 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  45 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  62 +++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  83 +++++++---
 drivers/net/ethernet/netronome/nfp/bpf/main.c      |  52 +++++-
 .../net/ethernet/netronome/nfp/flower/offload.c    |  54 +++++-
 include/linux/netdevice.h                          |   1 +
 include/net/pkt_cls.h                              | 129 ++++++++++++++-
 include/net/pkt_sched.h                            |  13 --
 include/net/sch_generic.h                          |   1 +
 net/dsa/slave.c                                    |  64 ++++++--
 net/sched/cls_api.c                                | 182 ++++++++++++++++++++-
 net/sched/cls_bpf.c                                |  28 +++-
 net/sched/cls_flower.c                             |  29 +---
 net/sched/cls_matchall.c                           |  58 +++----
 net/sched/cls_u32.c                                |  67 ++++----
 net/sched/sch_ingress.c                            |  36 +++-
 22 files changed, 849 insertions(+), 227 deletions(-)

-- 
2.9.5
