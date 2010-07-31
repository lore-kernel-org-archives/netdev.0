From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 11/29] LMC: Get rid of lmcConsoleLog().
Date: Sat, 31 Jul 2010 17:05:34 +0200
Message-ID: <1280588752-9340-11-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59352 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756508Ab0GaPGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:16 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/debug.c |   34 ----------------------------------
 drivers/net/wan/lmc/debug.h |   13 -------------
 drivers/net/wan/lmc/main.c  |   17 ++++++++++++++---
 3 files changed, 14 insertions(+), 50 deletions(-)

diff --git a/drivers/net/wan/lmc/debug.c b/drivers/net/wan/lmc/debug.c
index 0abae05..e01b6e2 100644
--- a/drivers/net/wan/lmc/debug.c
+++ b/drivers/net/wan/lmc/debug.c
@@ -7,40 +7,6 @@
  * Prints out len, max to 80 octets using printk, 20 per line
  */
=20
-#if defined(DEBUG) && defined(LMC_PACKET_LOG)
-void lmcConsoleLog(char *type, unsigned char *ucData, int iLen)
-{
-	int iNewLine =3D 1;
-	char str[80], *pstr;
-
-	sprintf(str, KERN_DEBUG "lmc: %s: ", type);
-	pstr =3D str+strlen(str);
-
-	if (iLen > 240) {
-		printk(KERN_DEBUG "lmc: Printing 240 chars... out of: %d\n",
-		       iLen);
-		iLen =3D 240;
-	} else
-		printk(KERN_DEBUG "lmc: Printing %d chars\n", iLen);
-
-	while (iLen > 0) {
-		sprintf(pstr, "%02x ", *ucData);
-		pstr +=3D 3;
-		ucData++;
-		if (!(iNewLine % 20)) {
-			sprintf(pstr, "\n");
-			printk(str);
-			sprintf(str, KERN_DEBUG "lmc: %s: ", type);
-			pstr =3D str + strlen(str);
-		}
-		iNewLine++;
-		iLen--;
-	}
-	sprintf(pstr, "\n");
-	printk(str);
-}
-#endif
-
 #ifdef DEBUG
 u32 lmcEventLogIndex;
 u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
diff --git a/drivers/net/wan/lmc/debug.h b/drivers/net/wan/lmc/debug.h
index 289f7d9..6bee4ee 100644
--- a/drivers/net/wan/lmc/debug.h
+++ b/drivers/net/wan/lmc/debug.h
@@ -1,18 +1,6 @@
 #ifndef _LMC_DEBUG_H_
 #define _LMC_DEBUG_H_
=20
-#ifdef DEBUG
-#ifdef LMC_PACKET_LOG
-#define LMC_CONSOLE_LOG(x, y, z) lmcConsoleLog((x), (y), (z))
-#else
-#define LMC_CONSOLE_LOG(x, y, z)
-#endif
-#else
-#define LMC_CONSOLE_LOG(x, y, z)
-#endif
-
-
-
 /* Debug --- Event log definitions --- */
 /* EVENTLOGSIZE*EVENTLOGARGS needs to be a power of 2 */
 #define LMC_EVENTLOGSIZE 1024	/* number of events in eventlog */
@@ -45,7 +33,6 @@ extern u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVEN=
TLOGARGS];
 #define LMC_EVENT_LOG(x, y, z)
 #endif /* end ifdef _DBG_EVENTLOG */
=20
-void lmcConsoleLog(char *type, unsigned char *ucData, int iLen);
 void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3);
 void lmc_trace(struct net_device *dev, char *msg);
=20
diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 1fbd802..a19d63a 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -62,6 +62,8 @@
 #include <asm/processor.h>   /* Processor type for cache alignment. */
 #include <asm/dma.h>
=20
+#undef DEBUG_PKT
+
 #define DRIVER_MAJOR_VERSION     1
 #define DRIVER_MINOR_VERSION    34
 #define DRIVER_SUB_VERSION       0
@@ -1329,7 +1331,10 @@ static netdev_tx_t lmc_start_xmit(struct sk_buff=
 *skb,
 	sc->lmc_txq[entry] =3D skb;
 	sc->lmc_txring[entry].buffer1 =3D virt_to_bus(skb->data);
=20
-	LMC_CONSOLE_LOG("xmit", skb->data, skb->len);
+#ifdef DEBUG_PKT
+	printk(KERN_DEBUG "%s TX(%i):", dev->name, skb->len);
+	debug_frame(skb);
+#endif
=20
 #ifndef GCOM
 	/* If the queue is less than half full, don't interrupt */
@@ -1479,8 +1484,6 @@ static int lmc_rx(struct net_device *dev)
 		sc->lmc_device->stats.rx_packets++;
 		sc->lmc_device->stats.rx_bytes +=3D len;
=20
-		LMC_CONSOLE_LOG("recv", skb->data, len);
-
 		/* I'm not sure of the sanity of this. Packets could be arriving
 		   at a constant 44.210mbits/sec and we're going to copy them
 		   into a new buffer?? */
@@ -1493,6 +1496,10 @@ give_it_anyways:
 			sc->lmc_rxring[i].buffer1 =3D 0x0;
=20
 			skb_put(skb, len);
+#ifdef DEBUG_PKT
+			printk(KERN_DEBUG "%s RX(%i):", dev->name, len);
+			debug_frame(skb);
+#endif
 			skb->protocol =3D hdlc_type_trans(skb, sc->lmc_device);
 			skb_reset_mac_header(skb);
 			/* skb_reset_network_header(skb); */
@@ -1524,6 +1531,10 @@ give_it_anyways:
 			if (!nsb)
 				goto give_it_anyways;
 			skb_copy_from_linear_data(skb, skb_put(nsb, len), len);
+#ifdef DEBUG_PKT
+			printk(KERN_DEBUG "%s RX(%i):", dev->name, len);
+			debug_frame(nsb);
+#endif
 			nsb->protocol =3D hdlc_type_trans(nsb, sc->lmc_device);
 			skb_reset_mac_header(nsb);
 			/* skb_reset_network_header(nsb); */
--=20
1.7.1.1

