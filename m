From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: systemport: reset UniMAC coming out of a suspend cycle
Date: Tue, 28 Oct 2014 11:12:01 -0700
Message-ID: <1414519921-3246-3-git-send-email-f.fainelli@gmail.com>
References: <1414519921-3246-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:46589 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbaJ1SMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 14:12:33 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so1296699pab.14
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 11:12:32 -0700 (PDT)
In-Reply-To: <1414519921-3246-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm_sysport_resume() was missing an UniMAC reset which can lead to
various receive FIFO corruptions coming out of a suspend cycle. If the
RX FIFO is stuck, it will deliver corrupted/duplicate packets towards
the host CPU interface.

This could be reproduced on crowded network and when Wake-on-LAN is
enabled for this particular interface because the switch still forwards
packets towards the host CPU interface (SYSTEMPORT), and we had to leave
the UniMAC RX enable bit on to allow matching MagicPackets.

Once we re-enter the resume function, there is a small window during
which the UniMAC receive is still enabled, and we start queueing
packets, but the RDMA and RBUF engines are not ready, which leads to
having packets stuck in the UniMAC RX FIFO, ultimately delivered towards
the host CPU as corrupted.

Fixes: 40755a0fce17 ("net: systemport: add suspend and resume support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 7dce91189e51..3a6778a667f4 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1858,6 +1858,8 @@ static int bcm_sysport_resume(struct device *d)
 	if (!netif_running(dev))
 		return 0;
 
+	umac_reset(priv);
+
 	/* We may have been suspended and never received a WOL event that
 	 * would turn off MPD detection, take care of that now
 	 */
-- 
1.9.1
