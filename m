From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: (unknown)
Date: Sun, 4 Jun 2017 13:30:58 +0300
Message-ID: <20170604103109.3082-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0065.outbound.protection.outlook.com ([104.47.37.65]:63055
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750847AbdFDKbS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 06:31:18 -0400
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH net-next 00/11] qed*: Support VF XDP attachment

Each driver queue [Rx, Tx, XDP-forwarding] requires an allocated HW/FW
connection + configured queue-zone.

VF handling by the PF has several limitations that prevented adding the
capability to perform XDP at driver-level:

 - The VF assumes there's 1-to-1 correspondance between the VF queue and
   the used connection, meaning q<x> is always going to use cid<x>,
   whereas for its own queues the PF is acquiring a new cid per each new
   queue.

 - There's a 1-to-1 correspondate between the VF-queues and the HW queue
   zones. While this is necessary for Rx-queues [as the queue-zone
   contains the producer], transmission queues can share the underlaying
   queue-zone [only shared configuration is coalescing].
   But all VF<->PF communication mechanisms assume there's a single
   identifier that identify a queue [as queue-zone == queue], while
   sharing queue-zones requires passing additional information.

 - VFs currently don't try mapping a doorbell bar - there's a small
   doorbell window in the regview allowing VFs to doorbell up to 16
   connections; but this window isn's wide enough for the added XDP
   forwarding queues.

This series is going to add the necessary infrastrucutre to finally let
our VFs support XDP assuming both the PF and VF drivers are sufficiently
new [Legacy support would be retained both for older VFs and older PFs,
but both will be needed for this new support to work].
Basically, the various database driver maintains for its queue-cids
would be revised, and queue-cids would be identified using the
(queue-zone, unique index) pair. The TLV mechanism would then be
extended to allow VFs to communicate that unique-index as well as the
already provided queue-zone. Finally, the VFs would try to map their
doorbell bar and inform their PF that they're using it.

Almost all the changes are in qed, with exception of #3 [which does some
cleanup in qede as well] and #11 that actually enables the feature.

Dave,

Please consider applying this series to 'net-next'.

Thanks,
Yuval

Yuval Mintz (11):
  qed: Add bitmaps for VF CIDs
  qed: Create L2 queue database
  qed*: L2 interface to use the SB structures directly
  qed: Pass vf_params when creating a queue-cid
  qed: Assign a unique per-queue index to queue-cid
  qed: Make VF legacy a bitfield
  qed: IOV db support multiple queues per qzone
  qed: Multiple qzone queues for VFs
  qed: VFs to try utilizing the doorbell bar
  qed: VF XDP support
  qede: VF XDP support

 drivers/net/ethernet/qlogic/qed/qed.h          |   8 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      | 230 ++++++++++----
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |  54 +++-
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  32 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c       | 298 +++++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_l2.h       |  79 ++++-
 drivers/net/ethernet/qlogic/qed/qed_main.c     |  24 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   1 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    | 418 +++++++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h    |  20 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c       | 244 +++++++++++----
 drivers/net/ethernet/qlogic/qed/qed_vf.h       |  79 ++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c   |  38 ++-
 include/linux/qed/qed_eth_if.h                 |   6 +-
 include/linux/qed/qed_if.h                     |   4 +
 15 files changed, 1205 insertions(+), 330 deletions(-)

-- 
2.9.4
