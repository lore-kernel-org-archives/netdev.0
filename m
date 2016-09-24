From: Eric Nelson <eric@nelint.com>
Subject: [PATCH 3/3] net: fec: align IP header in hardware
Date: Sat, 24 Sep 2016 07:42:19 -0700
Message-ID: <1474728139-9335-4-git-send-email-eric@nelint.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
Cc: linux@arm.linux.org.uk, andrew@lunn.ch, fugang.duan@nxp.com,
        otavio@ossystems.com.br, edumazet@google.com,
        troy.kisky@boundarydevices.com, davem@davemloft.net,
        u.kleine-koenig@pengutronix.de, Eric Nelson <eric@nelint.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fed1rmwml107.cox.net ([68.230.241.177]:57866 "EHLO
        fed1rmwml107.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754881AbcIXO6J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 10:58:09 -0400
Received: from fed1rmimpo306.cox.net ([68.230.241.174])
          by fed1rmfepo203.cox.net
          (InterMail vM.8.01.05.28 201-2260-151-171-20160122) with ESMTP
          id <20160924144429.FBTU3930.fed1rmfepo203.cox.net@fed1rmimpo306.cox.net>
          for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 10:44:29 -0400
In-Reply-To: <1474728139-9335-1-git-send-email-eric@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FEC receive accelerator (RACC) supports shifting the data payload of
received packets by 16-bits, which aligns the payload (IP header) on a
4-byte boundary, which is, if not required, at least strongly suggested
by the Linux networking layer.

Without this patch, a huge number of alignment faults will be taken by the
IP stack, as seen in /proc/cpu/alignment:

	~/$ cat /proc/cpu/alignment
	User:		0
	System:		72645 (inet_gro_receive+0x104/0x27c)
	Skipped:	0
	Half:		0
	Word:		0
	DWord:		0
	Multi:		72645
	User faults:	3 (fixup+warn)

This patch was suggested by Andrew Lunn in this message to linux-netdev:
	http://marc.info/?l=linux-arm-kernel&m=147465452108384&w=2

and adapted from a patch by Russell King from 2014:
	http://git.arm.linux.org.uk/cgit/linux-arm.git/commit/?id=70d8a8a

Signed-off-by: Eric Nelson <eric@nelint.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 0219e79..1fa2d87 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -180,6 +180,7 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 /* FEC receive acceleration */
 #define FEC_RACC_IPDIS		(1 << 1)
 #define FEC_RACC_PRODIS		(1 << 2)
+#define FEC_RACC_SHIFT16	BIT(7)
 #define FEC_RACC_OPTIONS	(FEC_RACC_IPDIS | FEC_RACC_PRODIS)
 
 /*
@@ -945,9 +946,11 @@ fec_restart(struct net_device *ndev)
 
 #if !defined(CONFIG_M5272)
 	if (fep->quirks & FEC_QUIRK_HAS_RACC) {
-		/* set RX checksum */
 		val = readl(fep->hwp + FEC_RACC);
+		/* align IP header */
+		val |= FEC_RACC_SHIFT16;
 		if (fep->csum_flags & FLAG_RX_CSUM_ENABLED)
+			/* set RX checksum */
 			val |= FEC_RACC_OPTIONS;
 		else
 			val &= ~FEC_RACC_OPTIONS;
@@ -1428,6 +1431,12 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		prefetch(skb->data - NET_IP_ALIGN);
 		skb_put(skb, pkt_len - 4);
 		data = skb->data;
+
+#if !defined(CONFIG_M5272)
+		if (fep->quirks & FEC_QUIRK_HAS_RACC)
+			data = skb_pull_inline(skb, 2);
+#endif
+
 		if (!is_copybreak && need_swap)
 			swap_buffer(data, pkt_len);
 
-- 
2.7.4
