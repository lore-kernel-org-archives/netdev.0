From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 00/14] net: extend busy polling support
Date: Wed, 18 Nov 2015 06:30:49 -0800
Message-ID: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33035 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbbKRObI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:08 -0500
Received: by pabfh17 with SMTP id fh17so48234353pab.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series extends busy polling range to tunnels devices,
and adds busy polling generic support to all NAPI drivers.

No need to provide ndo_busy_poll() method and extra synchronization
between ndo_busy_poll() and normal napi->poll() method.
This was proven very difficult and bug prone.

mlx5 driver is changed to support busy polling using this new method,
and a second mlx5 patch adds napi_complete_done() support and proper
SNMP accounting.

bnx2x and mlx4 drivers are converted to new infrastructure,
reducing kernel bloat and improving performance.

Latest patch, adding generic support, adds a new requirement :

 -free_netdev() and netif_napi_del() must be called from process context.

Since this might not be the case in some drivers, we might have to
either : fix the non conformant drivers (by disabling busy polling on them)
or revert this last patch.

Eric Dumazet (14):
  net: better skb->sender_cpu and skb->napi_id cohabitation
  mlx4: mlx4_en_low_latency_recv() called with BH disabled
  net: un-inline sk_busy_loop()
  net: allow BH servicing in sk_busy_loop()
  net: network drivers no longer need to implement ndo_busy_poll()
  mlx5: add busy polling support
  mlx5: support napi_complete_done()
  bnx2x: remove bnx2x_low_latency_recv() support
  mlx4: remove mlx4_en_low_latency_recv()
  net: move skb_mark_napi_id() into core networking stack
  net: add netif_tx_napi_add()
  net: move napi_hash[] into read mostly section
  net: napi_hash_del() returns a boolean status
  net: provide generic busy polling to all NAPI drivers

 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |   1 -
 drivers/net/ethernet/broadcom/bcmsysport.c         |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        | 113 ------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  50 +-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   7 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   3 -
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |   2 -
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   2 -
 drivers/net/ethernet/cisco/enic/enic_main.c        |   2 -
 drivers/net/ethernet/emulex/benet/be_main.c        |   2 -
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   2 +-
 drivers/net/ethernet/freescale/gianfar.c           |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |   3 -
 drivers/net/ethernet/mellanox/mlx4/en_cq.c         |  10 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  17 ---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  40 -------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  18 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       | 126 ---------------------
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   5 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  15 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  11 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |   3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   4 +-
 drivers/net/ethernet/rocker/rocker.c               |   2 +-
 drivers/net/ethernet/sfc/efx.c                     |   1 -
 drivers/net/ethernet/sfc/rx.c                      |   1 -
 drivers/net/ethernet/ti/cpsw.c                     |   2 +-
 drivers/net/ethernet/ti/netcp_core.c               |   2 +-
 drivers/net/virtio_net.c                           |   3 -
 drivers/net/wireless/ath/wil6210/netdev.c          |   2 +-
 include/linux/hashtable.h                          |   4 +
 include/linux/netdevice.h                          |  44 +++++--
 include/linux/skbuff.h                             |   3 -
 include/net/busy_poll.h                            |  45 +-------
 net/core/dev.c                                     | 116 +++++++++++++++----
 41 files changed, 171 insertions(+), 507 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
