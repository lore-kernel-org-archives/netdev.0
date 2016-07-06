From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH net] net: mvneta: set real interrupt per packet for tx_done
Date: Wed,  6 Jul 2016 04:18:58 +0200
Message-ID: <1467771538-31811-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, nadavh@marvell.com,
	alior@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, Dmitri Epshtein <dima@marvell.com>,
	<stable@vger.kernel.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34070 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbcGFCQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 22:16:26 -0400
Received: by mail-lf0-f43.google.com with SMTP id h129so146055092lfh.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 19:16:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitri Epshtein <dima@marvell.com>

Commit aebea2ba0f74 ("net: mvneta: fix Tx interrupt delay") intended to
set coalescing threshold to a value guaranteeing interrupt generation
per each sent packet, so that buffers can be released with no delay.

In fact setting threshold to '1' was wrong, because it causes interrupt
every two packets. According to the documentation a reason behind it is
following - interrupt occurs once sent buffers counter reaches a value,
which is higher than one specified in MVNETA_TXQ_SIZE_REG(q). This
behavior was confirmed during tests. Also when testing the SoC working
as a NAS device, better performance was observed with int-per-packet,
as it strongly depends on the fact that all transmitted packets are
released immediately.

This commit enables NETA controller work in interrupt per sent packet mode
by setting coalescing threshold to 0.

Signed-off-by: Dmitri Epshtein <dima@marvell.com>
Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Cc: <stable@vger.kernel.org> # v3.10+
Fixes aebea2ba0f74 ("net: mvneta: fix Tx interrupt delay")
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index cf04c97..0ad2fa3 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -244,7 +244,7 @@
 /* Various constants */
 
 /* Coalescing */
-#define MVNETA_TXDONE_COAL_PKTS		1
+#define MVNETA_TXDONE_COAL_PKTS		0	/* interrupt per packet */
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
-- 
1.8.3.1
