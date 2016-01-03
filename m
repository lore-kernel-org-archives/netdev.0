From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 0/7] bnxt_en: Support combined and rx/tx channels.
Date: Sat, 2 Jan 2016 23:44:57 -0500
Message-ID: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:4198 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcACEpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnxt hardware uses a completion ring for rx and tx events.  The driver
has to process the completion ring entries sequentially for the events.
The current code only supports an rx/tx ring pair for each completion ring.
This patch series add support for using a dedicated completion ring for
rx only or tx only as an option configuarble using ethtool -L.

The benefits for using dedicated completion rings are:

1. A burst of rx packets can cause delay in processing tx events if the
completion ring is shared.  If tx queue is stopped by BQL, this can cause
delay in re-starting the tx queue.

2. A completion ring is sized according to the rx and tx ring size rounded
up to the nearest power of 2.  When the completion ring is shared, it is
sized by adding the rx and tx ring sizes and then rounded to the next power
of 2, often with a lot of wasted space.

3. Using dedicated completion ring, we can adjust the tx and rx coalescing
parameters independently for rx and tx.


Michael Chan (7):
  bnxt_en: Refactor bnxt_dbg_dump_states().
  bnxt_en: Separate bnxt_{rx|tx}_ring_info structs from bnxt_napi
    struct.
  bnxt_en: Check for NULL rx or tx ring.
  bnxt_en: Re-structure ring indexing and mapping.
  bnxt_en: Modify bnxt_get_max_rings() to support shared or non shared
    rings.
  bnxt_en: Modify init sequence to support shared or non shared rings.
  bnxt_en: Modify ethtool -l|-L to support combined or rx/tx rings.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 439 +++++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  15 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  59 ++-
 3 files changed, 328 insertions(+), 185 deletions(-)

-- 
1.8.3.1
