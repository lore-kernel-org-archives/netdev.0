From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 0/5] Device reset and reconfig fixes
Date: Wed, 19 Feb 2014 15:22:13 +0200
Message-ID: <1392816138-31645-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:39974
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753483AbaBSNWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 08:22:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches end up fixing some notable device reset & reconfig
related problems.  One issue is on-the-fly (Rx/Tx on) programming
of interrupt coalescing (IC) registers on the processing path,
against HW recommendation.  This is an old issue that became visible
after BQL introduction, as under certain conditions (low traffic)
one TX interrupt gets lost and BQL fires Tx timeout as a result.
Another notable issue is a race on the Tx path (xmit, clean_tx)
during device reset (i.e. during Tx timeout watchdog firing)
that leads to NULL access.
Fixing the problematic on-thy-fly register writes (i.e. the IC regs)
required the implementation of a MAC soft reset procedure.
The race leading to NULL access was addressed by fixing the
stop_gfar()/startup_gfar() pair (disable/enable napi a.s.o.)
and adding the device state DOWN to sync with the TX path.

Thanks.

Claudiu Manoil (5):
  gianfar: Implement MAC reset and reconfig procedure
  gianfar: Fix on-the-fly vlan and mtu updates
  gianfar: Don't free/request irqs on device reset
  gianfar: Fix device reset races (oops) for Tx
  gianfar: Fix Tx int miss, dont write IC on-the-fly

 drivers/net/ethernet/freescale/gianfar.c         | 599 ++++++++++-------------
 drivers/net/ethernet/freescale/gianfar.h         |  18 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 104 ++--
 3 files changed, 325 insertions(+), 396 deletions(-)

-- 
1.7.11.7
