From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 00/11] qed: Status block changes
Date: Thu, 1 Jun 2017 15:29:00 +0300
Message-ID: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0058.outbound.protection.outlook.com ([104.47.37.58]:39760
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751078AbdFAM3h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:29:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device maintains a CAM mapping of the internal status blocks
and the various PF/VF MSI-x vector mappings.
During initialization, the driver reads the HW memory and constructs
a shadow SW implementation which it would later use for manipulation
of interrupts. E.g., when enabling VFs and setting their MSI-x tables.

The driver currently has some very strict assumptions on the order the
entries are placed in the CAM. Specifically, it assumes that all entries
belonging to a PF would be consecutive and in-order in the CAM, and that
the VF entries would then follow. But there's no actual HW constraint
enforcing this assumption [although management firmware does set it
accordingly to same assumption initially].

Since the CAM is re-configurable, there are now SW flows employeed
by other OSes that might cause the assumption to be invalid.
Such flows allow the PF to forfeit some of it's available interrupts
in favor of its VFs or vice versa.
While those are not employeed today by qed, we want to relax the
assumptions as much as we can -
both to allow functionality after PDA as well as allowing future
compatibility where the driver would be loaded after a newer one has
'dirtied' the CAM configuration.

In addition to patches meant for the above relaxation, the series
also contains various cleanups & refactoring for interrupt logic
[most of which is !semantic].

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Yuval Mintz (11):
  qed: Make qed_int_cau_conf_pi() static
  qed: Minor refactoring in interrupt code
  qed: IGU read revised
  qed: Distinguish between sb_id and igu_sb_id
  qed: Add aux. function translating sb_id -> igu_sb_id
  qed: Encapsulate interrupt counters in struct
  qed: Remove assumption on SB order in IGU
  qed: Provide auxiliary for getting free VF SB
  qed: Hold a single array for SBs
  qed: Reset IGU CAM to default on init
  qed: No need to reset SBs on IOV init

 drivers/net/ethernet/qlogic/qed/qed.h       |   4 -
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  49 +--
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c  |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_int.c   | 605 +++++++++++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_int.h   |  93 ++---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c  |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.c  |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c |  91 ++---
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c    |  27 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.h    |  18 +
 include/linux/qed/qed_if.h                  |  12 +-
 13 files changed, 527 insertions(+), 391 deletions(-)

-- 
2.9.4
