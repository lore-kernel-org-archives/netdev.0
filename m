From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH 0/3] net: mv643xx_eth: various small fixes for v3.12
Date: Wed,  2 Oct 2013 12:57:19 +0200
Message-ID: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:41984 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab3JBK5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 06:57:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set comprises some one-liners to fix issues with repeated
loading and unloading of a modular mv643xx_eth driver.

First two patches take care of the periodic port statistic timer, that
updates statistics by reading port registers using add_timer/mod_timer.

Patch 1 moves timer re-schedule from mib_counters_update to the timer
callback. As mib_counters_update is also called from non-timer context,
this ensures the timer is reactivated from timer context only.

Patch 2 moves initial timer schedule from _probe() time to right before
the port is actually started as the corresponding del_timer_sync is at
_stop() time. This fixes a regression, where unloading the driver from a
non-started eth device can cause the timer to access deallocated mem.

Patch 3 adds an assignment of the ports device_node to the corresponding
self-created platform_device. This is required to allow fixups based on
the device_node's compatible string later. Actually, it is also a potential
regression because we already check compatible string for Kirkwood, but
does not (yet) rely on the fixup.

All patches are based on v3.12-rc3 and have been tested on Kirkwood-based
Seagate Dockstar.

Patches 1 and 2 can also possibly queued up for -stable.

Sebastian Hesselbarth (3):
  net: mv643xx_eth: update statistics timer from timer context only
  net: mv643xx_eth: fix orphaned statistics timer crash
  net: mv643xx_eth: fix missing device_node for port devices

 drivers/net/ethernet/marvell/mv643xx_eth.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

---
Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
-- 
1.7.10.4
