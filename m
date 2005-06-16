From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sk98lin: fix ethtool stats
Date: Thu, 16 Jun 2005 11:01:09 -0700
Message-ID: <20050616110109.728d315a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The ethtool stats code in the sk98lin driver doesn't correctly match
stats with names. Also it always reports stats for port 0, and doesn't
update stats before reporting.

This patch fixes that and adds statistics for the number
of pause frames sent/received.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: work/drivers/net/sk98lin/skethtool.c
===================================================================
--- work.orig/drivers/net/sk98lin/skethtool.c
+++ work/drivers/net/sk98lin/skethtool.c
@@ -268,6 +268,7 @@ static const char StringsStats[][ETH_GST
 	"rx_bytes",	"tx_bytes",
 	"rx_errors",	"tx_errors",	
 	"rx_dropped",	"tx_dropped",
+	"rx_pause",	"tx_pause",
 	"multicasts",	"collisions",	
 	"rx_length_errors",		"rx_buffer_overflow_errors",
 	"rx_crc_errors",		"rx_frame_errors",
@@ -297,37 +298,49 @@ static void getStrings(struct net_device
 static void getEthtoolStats(struct net_device *dev,
 			    struct ethtool_stats *stats, u64 *data)
 {
-	const DEV_NET	*pNet = netdev_priv(dev);
-	const SK_AC *pAC = pNet->pAC;
-	const SK_PNMI_STRUCT_DATA *pPnmiStruct = &pAC->PnmiStruct;
-
-	*data++ = pPnmiStruct->Stat[0].StatRxOkCts;
-	*data++ = pPnmiStruct->Stat[0].StatTxOkCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxOctetsOkCts;
-	*data++ = pPnmiStruct->Stat[0].StatTxOctetsOkCts;
-	*data++ = pPnmiStruct->InErrorsCts;
-	*data++ = pPnmiStruct->Stat[0].StatTxSingleCollisionCts;
-	*data++ = pPnmiStruct->RxNoBufCts;
-	*data++ = pPnmiStruct->TxNoBufCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxMulticastOkCts;
-	*data++ = pPnmiStruct->Stat[0].StatTxSingleCollisionCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxRuntCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxFifoOverflowCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxFcsCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxFramingCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxShortsCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxTooLongCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxCextCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxSymbolCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxIRLengthCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxCarrierCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxJabberCts;
-	*data++ = pPnmiStruct->Stat[0].StatRxMissedCts;
-	*data++ = pAC->stats.tx_aborted_errors;
-	*data++ = pPnmiStruct->Stat[0].StatTxCarrierCts;
-	*data++ = pPnmiStruct->Stat[0].StatTxFifoUnderrunCts;
-	*data++ = pPnmiStruct->Stat[0].StatTxCarrierCts;
-	*data++ = pAC->stats.tx_window_errors;
+	DEV_NET	*pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+	SK_PNMI_STRUCT_DATA *pPnmiStruct = &pAC->PnmiStruct;
+	u32 size = sizeof(*pPnmiStruct);
+	int port = pNet->NetNr;
+	int i = 0;
+
+	if (netif_running(dev))
+		SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, 
+				&size, port);
+
+	i = 0;
+	data[i++] = pPnmiStruct->Stat[port].StatRxOkCts;
+	data[i++] = pPnmiStruct->Stat[port].StatTxOkCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxOctetsOkCts;
+	data[i++] = pPnmiStruct->Stat[port].StatTxOctetsOkCts;
+	data[i++] = pPnmiStruct->InErrorsCts;
+	data[i++] = pPnmiStruct->OutErrorsCts;
+	data[i++] = pPnmiStruct->RxNoBufCts;
+	data[i++] = pPnmiStruct->TxNoBufCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxPauseMacCtrlCts;
+	data[i++] = pPnmiStruct->Stat[port].StatTxPauseMacCtrlCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxMulticastOkCts;
+	data[i++] = pPnmiStruct->Stat[port].StatTxSingleCollisionCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxRuntCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxFifoOverflowCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxFcsCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxFramingCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxShortsCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxTooLongCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxCextCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxSymbolCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxIRLengthCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxCarrierCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxJabberCts;
+	data[i++] = pPnmiStruct->Stat[port].StatRxMissedCts;
+	data[i++] = pAC->stats.tx_aborted_errors;
+	data[i++] = pPnmiStruct->Stat[port].StatTxCarrierCts;
+	data[i++] = pPnmiStruct->Stat[port].StatTxFifoUnderrunCts;
+	data[i++] = pPnmiStruct->Stat[port].StatTxCarrierCts;
+	data[i++] = pAC->stats.tx_window_errors;
+	
+	BUG_ON(i != ARRAY_SIZE(StringsStats));
 }
 
 
