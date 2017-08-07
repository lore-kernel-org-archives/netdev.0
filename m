From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/16] net: sched: summer cleanup part 2, ndo_setup_tc
Date: Mon,  7 Aug 2017 10:15:16 +0200
Message-ID: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36770 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752322AbdHGIPf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:35 -0400
Received: by mail-wr0-f196.google.com with SMTP id y67so7124999wrb.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset focuses on ndo_setup_tc and its args.
Currently there are couple of things that do not make much sense.
The type is passed in struct tc_to_netdev, but as it is always
required, should be arg of the ndo. Other things are passed as args
but they are only relevant for cls offloads and not mqprio. Therefore,
they should be pushed to struct. As the tc_to_netdev struct in the end
is just a container of single pointer, we get rid of it and pass the
struct according to type. So in the end, we have:
ndo_setup_tc(dev, type, type_data_struct)

There are couple of cosmetics done on the way to make things smooth.
Also, reported error is consolidated to eopnotsupp in case the
asked offload is not supported.

v1->v2:
- added forgotten hns3pf bits

Jiri Pirko (16):
  net: sched: make type an argument for ndo_setup_tc
  net: sched: rename TC_SETUP_MATCHALL to TC_SETUP_CLSMATCHALL
  net: sched: make egress_dev flag part of flower offload struct
  cxgb4: push cls_u32 setup_tc processing into a separate function
  ixgbe: push cls_u32 and mqprio setup_tc processing into separate
    functions
  mlx5e: push cls_flower and mqprio setup_tc processing into separate
    functions
  mlx5e_rep: push cls_flower setup_tc processing into a separate
    function
  mlxsw: spectrum: push cls_flower and cls_matchall setup_tc processing
    into separate functions
  mlxsw: spectrum: rename cls arg in matchall processing
  dsa: push cls_matchall setup_tc processing into a separate function
  nfp: change flows in apps that offload ndo_setup_tc
  hns3pf: don't check handle during mqprio offload
  net: sched: push cls related args into cls_common structure
  net: sched: move prio into cls_common
  net: sched: change return value of ndo_setup_tc for driver supporting
    mqprio only
  net: sched: get rid of struct tc_to_netdev

 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  14 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  14 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  14 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  43 +++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |   7 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h  |   6 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  13 +--
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  13 +--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |  14 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  15 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  65 +++++++------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  17 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  55 +++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  45 +++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 102 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |   4 +-
 drivers/net/ethernet/netronome/nfp/bpf/main.c      |  20 ++--
 drivers/net/ethernet/netronome/nfp/flower/main.h   |   4 +-
 .../net/ethernet/netronome/nfp/flower/offload.c    |  15 ++-
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |   8 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |   9 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |   5 +-
 drivers/net/ethernet/sfc/efx.h                     |   4 +-
 drivers/net/ethernet/sfc/falcon/efx.h              |   4 +-
 drivers/net/ethernet/sfc/falcon/tx.c               |  13 +--
 drivers/net/ethernet/sfc/tx.c                      |  13 +--
 drivers/net/ethernet/ti/netcp_core.c               |  13 +--
 include/linux/netdevice.h                          |  30 ++----
 include/net/pkt_cls.h                              |  23 ++++-
 net/dsa/slave.c                                    |  39 ++++----
 net/sched/cls_bpf.c                                |  24 ++---
 net/sched/cls_flower.c                             |  60 +++++-------
 net/sched/cls_matchall.c                           |  31 +++----
 net/sched/cls_u32.c                                |  95 ++++++++-----------
 net/sched/sch_mqprio.c                             |  16 ++--
 39 files changed, 438 insertions(+), 441 deletions(-)

-- 
2.9.3
