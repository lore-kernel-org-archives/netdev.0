From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/10)  sk98: rlmt send locking
Date: Thu, 18 Nov 2004 14:39:25 -0800
Message-ID: <20041118143925.406eed05@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Mirko Lindner <demon@pro-linux.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Earlier patch changed the locking of normal transmit frame path,
but missed the special case of the management interface.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-17 09:22:37 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-17 09:22:37 -08:00
@@ -4233,12 +4233,18 @@
 		SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_EVENT,
 			("RLS "));
 		pRlmtMbuf = (SK_MBUF*) Param.pParaPtr;
+		FromPort = pRlmtMbuf->PortIdx;
 		pMsg = (struct sk_buff*) pRlmtMbuf->pOs;
 		skb_put(pMsg, pRlmtMbuf->Length);
-		if (XmitFrame(pAC, &pAC->TxPort[pRlmtMbuf->PortIdx][TX_PRIO_LOW],
-			pMsg) < 0)
 
+		spin_lock_irqsave(&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
+			Flags);
+		if (XmitFrame(pAC, &pAC->TxPort[FromPort][TX_PRIO_LOW],
+			      pMsg) < 0)
 			dev_kfree_skb_any(pMsg);
+		spin_unlock_irqrestore(&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
+			Flags);
+
 		break;
 	case SK_DRV_TIMER:
 		if (Param.Para32[0] == SK_DRV_MODERATION_TIMER) {
