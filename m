From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH 3/3] gianfar: Implement workaround for eTSEC-A002 erratum
Date: Wed, 30 Jun 2010 01:00:13 +0400
Message-ID: <20100629210013.GC10905@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Manfred Rudigier <manfred.rudigier@omicron.at>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:21480 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756020Ab0F2VAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 17:00:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPC8313ECE says:

"If the controller receives a 1- or 2-byte frame (such as an illegal
 runt packet or a packet with RX_ER asserted) before GRS is asserted
 and does not receive any other frames, the controller may fail to set
 GRSC even when the receive logic is completely idle. Any subsequent
 receive frame that is larger than two bytes will reset the state so
 the graceful stop can complete. A MAC receiver (Rx) reset will also
 reset the state."

This patch implements the proposed workaround:

"If IEVENT[GRSC] is still not set after the timeout, read the eTSEC
 register at offset 0xD1C. If bits 7-14 are the same as bits 23-30,
 the eTSEC Rx is assumed to be idle and the Rx can be safely reset.
 If the register fields are not equal, wait for another timeout
 period and check again."

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/gianfar.c |   40 +++++++++++++++++++++++++++++++++++++---
 drivers/net/gianfar.h |    1 +
 2 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f8b9693..f3da17a 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -947,6 +947,11 @@ static void gfar_detect_errata(struct gfar_private *priv)
 			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_76;
 
+	/* MPC8313 and MPC837x all rev */
+	if ((pvr == 0x80850010 && mod == 0x80b0) ||
+			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+		priv->errata |= GFAR_ERRATA_A002;
+
 	if (priv->errata) {
 #ifdef CONFIG_GIANFAR_ERRATA
 		dev_info(dev, "enabled errata workarounds, flags: 0x%x\n",
@@ -1577,6 +1582,29 @@ static void init_registers(struct net_device *dev)
 	gfar_write(&regs->minflr, MINFLR_INIT_SETTINGS);
 }
 
+static int __gfar_is_rx_idle(struct gfar_private *priv)
+{
+	u32 res;
+
+	/*
+	 * Normaly TSEC should not hang on GRS commands, so we should
+	 * actually wait for IEVENT_GRSC flag.
+	 */
+	if (likely(!gfar_has_errata(priv, A002)))
+		return 0;
+
+	/*
+	 * Read the eTSEC register at offset 0xD1C. If bits 7-14 are
+	 * the same as bits 23-30, the eTSEC Rx is assumed to be idle
+	 * and the Rx can be safely reset.
+	 */
+	res = gfar_read((void __iomem *)priv->gfargrp[0].regs + 0xd1c);
+	res &= 0x7f807f80;
+	if ((res & 0xffff) == (res >> 16))
+		return 1;
+
+	return 0;
+}
 
 /* Halt the receive and transmit queues */
 static void gfar_halt_nodisable(struct net_device *dev)
@@ -1600,12 +1628,18 @@ static void gfar_halt_nodisable(struct net_device *dev)
 	tempval = gfar_read(&regs->dmactrl);
 	if ((tempval & (DMACTRL_GRS | DMACTRL_GTS))
 	    != (DMACTRL_GRS | DMACTRL_GTS)) {
+		int ret;
+
 		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
 		gfar_write(&regs->dmactrl, tempval);
 
-		spin_event_timeout(((gfar_read(&regs->ievent) &
-			 (IEVENT_GRSC | IEVENT_GTSC)) ==
-			 (IEVENT_GRSC | IEVENT_GTSC)), -1, 0);
+		do {
+			ret = spin_event_timeout(((gfar_read(&regs->ievent) &
+				 (IEVENT_GRSC | IEVENT_GTSC)) ==
+				 (IEVENT_GRSC | IEVENT_GTSC)), 1000000, 0);
+			if (!(gfar_read(&regs->ievent) & IEVENT_GRSC))
+				ret = __gfar_is_rx_idle(priv);
+		} while (!ret);
 	}
 }
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index fb308c8..e0907eb 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1028,6 +1028,7 @@ struct gfar_priv_grp {
 enum gfar_errata {
 	GFAR_ERRATA_74		= 0x01,
 	GFAR_ERRATA_76		= 0x02,
+	GFAR_ERRATA_A002	= 0x04,
 };
 
 #ifdef CONFIG_GIANFAR_ERRATA
-- 
1.7.0.5
