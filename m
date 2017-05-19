From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v6 net-next 0/7] Extend socket timestamping API
Date: Fri, 19 May 2017 17:52:34 +0200
Message-ID: <20170519155241.15817-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39306 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751916AbdESPwo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 11:52:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes v5->v6:
- fixed skb_is_swtx_tstamp() when OPT_TX_SWHW is disabled and improved
  its description
- improved OPT_PKTINFO documentation
- improved scm_timestamping documentation

Changes v4->v5:
- fixed initialization of reserved fields in struct scm_ts_pktinfo

Changes v3->v4:
- added reserved fields to struct scm_ts_pktinfo
- replaced patch fixing false SW timestamps with a documentation fix
- updated OPT_TX_SWHW patch to handle false SW timestamps

Changes v2->v3:
- modified struct scm_ts_pktinfo to use fixed-width integer types
- added WARN_ON_ONCE for missing RCU lock in dev_get_by_napi_id()
- modified dev_get_by_napi_id() to not return dev in unexpected branch
- modified recv to return SCM_TIMESTAMPING_PKTINFO even if the interface
  index is unknown

Changes v1->v2:
- added separate patch for new NAPI functions 
- split code from __sock_recv_timestamp() for better readability
- fixed RCU locking
- fixed compiler warning (missing case in switch in first patch)
- inline sw_tx_timestamp() in its only user

Changes RFC->v1:
- reworked SOF_TIMESTAMPING_OPT_PKTINFO patch to not add new fields to
  skb shared info (net device is now looked up by napi_id), not require
  any changes in drivers, and restrict the cmsg to incoming packets
- renamed SOF_TIMESTAMPING_OPT_MULTIMSG to SOF_TIMESTAMPING_OPT_TX_SWHW
  and fixed its description
- moved struct scm_ts_pktinfo from errqueue.h to net_tstamp.h as it
  can't be received from the error queue anymore
- improved commit descriptions and removed incorrect comment

This patchset adds new options to the timestamping API that will be
useful for NTP implementations and possibly other applications.

The first patch specifies a timestamp filter for NTP packets. The second
patch updates drivers that can timestamp all packets, or need to list
the filter as unsupported. There is no attempt to add the support to the
phyter driver.

The third patch adds two helper functions working with NAPI ID, which is
needed by the next patch. The fourth patch adds a new option to get a
new control message with the L2 length and interface index for incoming
packets with hardware timestamps.

The fifth patch fixes documentation on number of non-zero fields in
scm_timestamping and warns about false software timestamps when
SO_TIMESTAMP(NS) is combined with SCM_TIMESTAMPING.

The sixth patch adds a new option to request both software and hardware
timestamps for outgoing packets. The seventh patch updates drivers that
assumed software timestamping cannot be used together with hardware
timestamping.

The patches have been tested on x86_64 machines with igb and e1000e
drivers.

Miroslav Lichvar (7):
  net: define receive timestamp filter for NTP
  net: ethernet: update drivers to handle HWTSTAMP_FILTER_NTP_ALL
  net: add function to retrieve original skb device using NAPI ID
  net: add new control message for incoming HW-timestamped packets
  net: fix documentation of struct scm_timestamping
  net: allow simultaneous SW and HW transmit timestamping
  net: ethernet: update drivers to make both SW and HW TX timestamps

 Documentation/networking/timestamping.txt          | 26 +++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  1 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  1 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |  1 +
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c   |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c         |  5 ++-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  1 +
 drivers/net/ethernet/intel/igb/igb_ptp.c           |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  1 +
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  1 +
 drivers/net/ethernet/qlogic/qede/qede_ptp.c        |  1 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    |  3 +-
 drivers/net/ethernet/sfc/ef10.c                    |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  7 ++--
 drivers/net/ethernet/ti/cpsw.c                     |  1 +
 drivers/net/ethernet/tile/tilegx.c                 |  1 +
 include/linux/netdevice.h                          |  1 +
 include/linux/skbuff.h                             | 19 +++++----
 include/uapi/asm-generic/socket.h                  |  2 +
 include/uapi/linux/net_tstamp.h                    | 15 ++++++-
 net/core/dev.c                                     | 26 ++++++++++++
 net/core/dev_ioctl.c                               |  1 +
 net/core/skbuff.c                                  |  4 ++
 net/socket.c                                       | 47 ++++++++++++++++++++--
 27 files changed, 151 insertions(+), 23 deletions(-)

-- 
2.9.3
