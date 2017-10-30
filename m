From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/9] qdisc RED offload
Date: Mon, 30 Oct 2017 09:56:04 +0100
Message-ID: <20171030085613.8697-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:51444 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752577AbdJ3I4Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:16 -0400
Received: by mail-wm0-f67.google.com with SMTP id b9so14751857wmh.0
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Nogah says:

Add an offload support for RED qdisc for mlxsw driver.
The first patch adds the ability to offload RED qdisc by using
ndo_setup_tc. It gives RED three commands, to offload, change or delete
the qdisc, to get the qdisc generic stats and to get it's RED xstats.
There is no enforcement on a driver to offload or not offload the qdisc and
it is up to the driver to decide.
RED qdisc is first being created and only later graft to a parent (unless
it is a root qdisc). For that reason the return value of the offload
replace command that is called in the init process doesn't reflect actual
offload state. The offload state is determined in the dump function so it
can be reflected to the user. This function is also responsible for stats
update.

The patchses 2-3 change the name of TC_SETUP_MQPRIO & TC_SETUP_CBS to match
with the new convention of QDISC prefix.
The rest of the patchset is driver support for the qdisc. Currently only
as root qdisc that is being set on the default traffic class. It supports
only the following parameters of RED: min, max, probability and ECN mode.
Limit and burst size related params are being ignored at this moment.

Nogah Frankel (8):
  net_sch: red: Add offload ability to RED qdisc
  net_sch: mqprio: Change TC_SETUP_MQPRIO to TC_SETUP_QDISC_MQPRIO
  net_sch: cbs: Change TC_SETUP_CBS to TC_SETUP_QDISC_CBS
  mlxsw: reg: Add cwtp & cwtpm registers
  mlxsw: spectrum: Support RED qdisc offload
  mlxsw: spectrum: Collect tclass related stats periodically
  mlxsw: spectrum: Support RED xstats
  mlxsw: spectrum: Support general qdisc stats

Yuval Mintz (1):
  mlxsw: reg: Add ext and tc-cong counter groups

 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |   2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |   2 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |   2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   3 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 206 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  36 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  38 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_qdisc.c   | 254 +++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/tx.c               |   2 +-
 drivers/net/ethernet/sfc/tx.c                      |   2 +-
 drivers/net/ethernet/ti/netcp_core.c               |   2 +-
 include/linux/netdevice.h                          |   5 +-
 include/net/pkt_cls.h                              |  30 +++
 include/uapi/linux/pkt_sched.h                     |   1 +
 net/sched/sch_cbs.c                                |   4 +-
 net/sched/sch_mqprio.c                             |   5 +-
 net/sched/sch_red.c                                |  90 ++++++++
 25 files changed, 679 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c

-- 
2.9.5
