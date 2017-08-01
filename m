From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control autonegotiation by default
Date: Tue,  1 Aug 2017 16:37:39 -0500
Message-ID: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40440 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752390AbdHAVhr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 17:37:47 -0400
In-Reply-To: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC has a curious qwirk when RX flow control is enabled and the
kernel hangs.  With the kernel hung, the EMAC's RX queue soon fills.
If RX flow control is enabled, the EMAC will then send a non-stop
stream of pause frames until the system is reset.  The EMAC does not
have a built-in watchdog.

In various tests, the pause frame stream sometimes overloads nearby
switches, effectively disabling the network.  Since the RX queue is
large and the host processor is more than capable of handling incoming
packets quickly, the only time the EMAC will send any pause frames is
when the kernel is hung and unrecoverable.

To avoid all these problems, we disable flow control autonegotiation
by default, and only enable receiving pause frames.

Cc: stable@vger.kernel.org # 4.11.x
Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 60850bfa3d32..475c0ea29235 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -441,8 +441,13 @@ static void emac_init_adapter(struct emac_adapter *adpt)
 	/* others */
 	adpt->preamble = EMAC_PREAMBLE_DEF;
 
-	/* default to automatic flow control */
-	adpt->automatic = true;
+	/* Disable transmission of pause frames by default, to avoid the
+	 * risk of a pause frame flood that can occur if the kernel hangs.
+	 * We still want to be able to respond to them, however.
+	 */
+	adpt->automatic = false;
+	adpt->tx_flow_control = false;
+	adpt->rx_flow_control = true;
 }
 
 /* Get the clock */
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
