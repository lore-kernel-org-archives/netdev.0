From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 7/7] chelsio: tabulate the update of the statistic counters
Date: Tue, 12 Dec 2006 00:21:36 +0100
Message-ID: <20061211232136.GH8568@electric-eye.fr.zoreil.com>
References: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40084 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbWLKXZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 18:25:34 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let's try to avoid some code duplication.

- cxgb2
  The data are contiguous. Use plain memcpy.

- ixf1010/pm3393/vsc7326
  The cast of &mac->stats to (u64 *) is not wonderful but it is not clear
  if it is worth to add an ad-hoc union under the struct cmac_statistics.

vsc7326_reg.h suggests that more statistics could be available.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/cxgb2.c       |   50 +++----------
 drivers/net/chelsio/ixf1010.c     |   87 ++++++++++++++---------
 drivers/net/chelsio/pm3393.c      |   83 +++++++++++++---------
 drivers/net/chelsio/vsc7326.c     |   68 ++++++++++--------
 drivers/net/chelsio/vsc7326_reg.h |  139 ++++++++++++++++++++-----------------
 5 files changed, 222 insertions(+), 205 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index c3b1648..7d0f24f 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -454,51 +454,21 @@ static void get_stats(struct net_device 
 	const struct cmac_statistics *s;
 	const struct sge_intr_counts *t;
 	struct sge_port_stats ss;
+	unsigned int len;
 
 	s = mac->ops->statistics_update(mac, MAC_STATS_UPDATE_FULL);
 
-	*data++ = s->TxOctetsOK;
-	*data++ = s->TxOctetsBad;
-	*data++ = s->TxUnicastFramesOK;
-	*data++ = s->TxMulticastFramesOK;
-	*data++ = s->TxBroadcastFramesOK;
-	*data++ = s->TxPauseFrames;
-	*data++ = s->TxFramesWithDeferredXmissions;
-	*data++ = s->TxLateCollisions;
-	*data++ = s->TxTotalCollisions;
-	*data++ = s->TxFramesAbortedDueToXSCollisions;
-	*data++ = s->TxUnderrun;
-	*data++ = s->TxLengthErrors;
-	*data++ = s->TxInternalMACXmitError;
-	*data++ = s->TxFramesWithExcessiveDeferral;
-	*data++ = s->TxFCSErrors;
-
-	*data++ = s->RxOctetsOK;
-	*data++ = s->RxOctetsBad;
-	*data++ = s->RxUnicastFramesOK;
-	*data++ = s->RxMulticastFramesOK;
-	*data++ = s->RxBroadcastFramesOK;
-	*data++ = s->RxPauseFrames;
-	*data++ = s->RxFCSErrors;
-	*data++ = s->RxAlignErrors;
-	*data++ = s->RxSymbolErrors;
-	*data++ = s->RxDataErrors;
-	*data++ = s->RxSequenceErrors;
-	*data++ = s->RxRuntErrors;
-	*data++ = s->RxJabberErrors;
-	*data++ = s->RxInternalMACRcvError;
-	*data++ = s->RxInRangeLengthErrors;
-	*data++ = s->RxOutOfRangeLengthField;
-	*data++ = s->RxFrameTooLongErrors;
+	len = sizeof(u64)*(&s->TxFCSErrors + 1 - &s->TxOctetsOK);
+	memcpy(data, &s->TxOctetsOK, len);
+	data += len;
+
+	len = sizeof(u64)*(&s->RxFrameTooLongErrors + 1 - &s->RxOctetsOK);
+	memcpy(data, &s->RxOctetsOK, len);
+	data += len;
 
 	t1_sge_get_port_stats(adapter->sge, dev->if_port, &ss);
-	*data++ = ss.rx_packets;
-	*data++ = ss.rx_cso_good;
-	*data++ = ss.tx_packets;
-	*data++ = ss.tx_cso;
-	*data++ = ss.tx_tso;
-	*data++ = ss.vlan_xtract;
-	*data++ = ss.vlan_insert;
+	memcpy(data, &ss, sizeof(ss));
+	data += sizeof(ss);
 
 	t = t1_sge_get_intr_counts(adapter->sge);
 	*data++ = t->rx_drops;
diff --git a/drivers/net/chelsio/ixf1010.c b/drivers/net/chelsio/ixf1010.c
index c40a88d..10b2a9a 100644
--- a/drivers/net/chelsio/ixf1010.c
+++ b/drivers/net/chelsio/ixf1010.c
@@ -145,48 +145,61 @@ static void disable_port(struct cmac *ma
 	t1_tpi_write(mac->adapter, REG_PORT_ENABLE, val);
 }
 
-#define RMON_UPDATE(mac, name, stat_name) \
-	t1_tpi_read((mac)->adapter, MACREG(mac, REG_##name), &val); \
-	(mac)->stats.stat_name += val;
-
 /*
  * Read the current values of the RMON counters and add them to the cumulative
  * port statistics.  The HW RMON counters are cleared by this operation.
  */
 static void port_stats_update(struct cmac *mac)
 {
-	u32 val;
+	static struct {
+		unsigned int reg;
+		unsigned int offset;
+	} hw_stats[] = {
+
+#define HW_STAT(name, stat_name) \
+	{ REG_##name, \
+	  (&((struct cmac_statistics *)NULL)->stat_name) - (u64 *)NULL }
+
+		/* Rx stats */
+		HW_STAT(RxOctetsTotalOK, RxOctetsOK),
+		HW_STAT(RxOctetsBad, RxOctetsBad),
+		HW_STAT(RxUCPkts, RxUnicastFramesOK),
+		HW_STAT(RxMCPkts, RxMulticastFramesOK),
+		HW_STAT(RxBCPkts, RxBroadcastFramesOK),
+		HW_STAT(RxJumboPkts, RxJumboFramesOK),
+		HW_STAT(RxFCSErrors, RxFCSErrors),
+		HW_STAT(RxAlignErrors, RxAlignErrors),
+		HW_STAT(RxLongErrors, RxFrameTooLongErrors),
+		HW_STAT(RxVeryLongErrors, RxFrameTooLongErrors),
+		HW_STAT(RxPauseMacControlCounter, RxPauseFrames),
+		HW_STAT(RxDataErrors, RxDataErrors),
+		HW_STAT(RxJabberErrors, RxJabberErrors),
+		HW_STAT(RxRuntErrors, RxRuntErrors),
+		HW_STAT(RxShortErrors, RxRuntErrors),
+		HW_STAT(RxSequenceErrors, RxSequenceErrors),
+		HW_STAT(RxSymbolErrors, RxSymbolErrors),
+
+		/* Tx stats (skip collision stats as we are full-duplex only) */
+		HW_STAT(TxOctetsTotalOK, TxOctetsOK),
+		HW_STAT(TxOctetsBad, TxOctetsBad),
+		HW_STAT(TxUCPkts, TxUnicastFramesOK),
+		HW_STAT(TxMCPkts, TxMulticastFramesOK),
+		HW_STAT(TxBCPkts, TxBroadcastFramesOK),
+		HW_STAT(TxJumboPkts, TxJumboFramesOK),
+		HW_STAT(TxPauseFrames, TxPauseFrames),
+		HW_STAT(TxExcessiveLengthDrop, TxLengthErrors),
+		HW_STAT(TxUnderrun, TxUnderrun),
+		HW_STAT(TxCRCErrors, TxFCSErrors)
+	}, *p = hw_stats;
+	u64 *stats = (u64 *) &mac->stats;
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(hw_stats); i++) {
+		u32 val;
 
-	/* Rx stats */
-	RMON_UPDATE(mac, RxOctetsTotalOK, RxOctetsOK);
-	RMON_UPDATE(mac, RxOctetsBad, RxOctetsBad);
-	RMON_UPDATE(mac, RxUCPkts, RxUnicastFramesOK);
-	RMON_UPDATE(mac, RxMCPkts, RxMulticastFramesOK);
-	RMON_UPDATE(mac, RxBCPkts, RxBroadcastFramesOK);
-	RMON_UPDATE(mac, RxJumboPkts, RxJumboFramesOK);
-	RMON_UPDATE(mac, RxFCSErrors, RxFCSErrors);
-	RMON_UPDATE(mac, RxAlignErrors, RxAlignErrors);
-	RMON_UPDATE(mac, RxLongErrors, RxFrameTooLongErrors);
-	RMON_UPDATE(mac, RxVeryLongErrors, RxFrameTooLongErrors);
-	RMON_UPDATE(mac, RxPauseMacControlCounter, RxPauseFrames);
-	RMON_UPDATE(mac, RxDataErrors, RxDataErrors);
-	RMON_UPDATE(mac, RxJabberErrors, RxJabberErrors);
-	RMON_UPDATE(mac, RxRuntErrors, RxRuntErrors);
-	RMON_UPDATE(mac, RxShortErrors, RxRuntErrors);
-	RMON_UPDATE(mac, RxSequenceErrors, RxSequenceErrors);
-	RMON_UPDATE(mac, RxSymbolErrors, RxSymbolErrors);
-
-	/* Tx stats (skip collision stats as we are full-duplex only) */
-	RMON_UPDATE(mac, TxOctetsTotalOK, TxOctetsOK);
-	RMON_UPDATE(mac, TxOctetsBad, TxOctetsBad);
-	RMON_UPDATE(mac, TxUCPkts, TxUnicastFramesOK);
-	RMON_UPDATE(mac, TxMCPkts, TxMulticastFramesOK);
-	RMON_UPDATE(mac, TxBCPkts, TxBroadcastFramesOK);
-	RMON_UPDATE(mac, TxJumboPkts, TxJumboFramesOK);
-	RMON_UPDATE(mac, TxPauseFrames, TxPauseFrames);
-	RMON_UPDATE(mac, TxExcessiveLengthDrop, TxLengthErrors);
-	RMON_UPDATE(mac, TxUnderrun, TxUnderrun);
-	RMON_UPDATE(mac, TxCRCErrors, TxFCSErrors);
+		t1_tpi_read(mac->adapter, MACREG(mac, p->reg), &val);
+		stats[p->offset] += val;
+	}
 }
 
 /* No-op interrupt operation as this MAC does not support interrupts */
@@ -390,6 +403,10 @@ static int mac_disable(struct cmac *mac,
 	return 0;
 }
 
+#define RMON_UPDATE(mac, name, stat_name) \
+	t1_tpi_read((mac)->adapter, MACREG(mac, REG_##name), &val); \
+	(mac)->stats.stat_name += val;
+
 /*
  * This function is called periodically to accumulate the current values of the
  * RMON counters into the port statistics.  Since the counters are only 32 bits
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
index 76a7ca9..69129ed 100644
--- a/drivers/net/chelsio/pm3393.c
+++ b/drivers/net/chelsio/pm3393.c
@@ -446,17 +446,51 @@ static void pm3393_rmon_update(struct ad
 		*val += 1ull << 40;
 }
 
-#define RMON_UPDATE(mac, name, stat_name) \
-	pm3393_rmon_update((mac)->adapter, OFFSET(name), 		\
-			   &(mac)->stats.stat_name,			\
-		   (ro &((name - SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW) >> 2)))
-
-
 static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 							      int flag)
 {
+	static struct {
+		unsigned int reg;
+		unsigned int offset;
+	} hw_stats [] = {
+
+#define HW_STAT(name, stat_name) \
+	{ name, (&((struct cmac_statistics *)NULL)->stat_name) - (u64 *)NULL }
+
+		/* Rx stats */
+		HW_STAT(RxOctetsReceivedOK, RxOctetsOK),
+		HW_STAT(RxUnicastFramesReceivedOK, RxUnicastFramesOK),
+		HW_STAT(RxMulticastFramesReceivedOK, RxMulticastFramesOK),
+		HW_STAT(RxBroadcastFramesReceivedOK, RxBroadcastFramesOK),
+		HW_STAT(RxPAUSEMACCtrlFramesReceived, RxPauseFrames),
+		HW_STAT(RxFrameCheckSequenceErrors, RxFCSErrors),
+		HW_STAT(RxFramesLostDueToInternalMACErrors,
+				RxInternalMACRcvError),
+		HW_STAT(RxSymbolErrors, RxSymbolErrors),
+		HW_STAT(RxInRangeLengthErrors, RxInRangeLengthErrors),
+		HW_STAT(RxFramesTooLongErrors , RxFrameTooLongErrors),
+		HW_STAT(RxJabbers, RxJabberErrors),
+		HW_STAT(RxFragments, RxRuntErrors),
+		HW_STAT(RxUndersizedFrames, RxRuntErrors),
+		HW_STAT(RxJumboFramesReceivedOK, RxJumboFramesOK),
+		HW_STAT(RxJumboOctetsReceivedOK, RxJumboOctetsOK),
+
+		/* Tx stats */
+		HW_STAT(TxOctetsTransmittedOK, TxOctetsOK),
+		HW_STAT(TxFramesLostDueToInternalMACTransmissionError,
+				TxInternalMACXmitError),
+		HW_STAT(TxTransmitSystemError, TxFCSErrors),
+		HW_STAT(TxUnicastFramesTransmittedOK, TxUnicastFramesOK),
+		HW_STAT(TxMulticastFramesTransmittedOK, TxMulticastFramesOK),
+		HW_STAT(TxBroadcastFramesTransmittedOK, TxBroadcastFramesOK),
+		HW_STAT(TxPAUSEMACCtrlFramesTransmitted, TxPauseFrames),
+		HW_STAT(TxJumboFramesReceivedOK, TxJumboFramesOK),
+		HW_STAT(TxJumboOctetsReceivedOK, TxJumboOctetsOK)
+	}, *p = hw_stats;
 	u64 ro;
 	u32 val0, val1, val2, val3;
+	u64 *stats = (u64 *) &mac->stats;
+	unsigned int i;
 
 	/* Snap the counters */
 	pmwrite(mac, SUNI1x10GEXP_REG_MSTAT_CONTROL,
@@ -470,35 +504,14 @@ static const struct cmac_statistics *pm3
 	ro = ((u64)val0 & 0xffff) | (((u64)val1 & 0xffff) << 16) |
 		(((u64)val2 & 0xffff) << 32) | (((u64)val3 & 0xffff) << 48);
 
-	/* Rx stats */
-	RMON_UPDATE(mac, RxOctetsReceivedOK, RxOctetsOK);
-	RMON_UPDATE(mac, RxUnicastFramesReceivedOK, RxUnicastFramesOK);
-	RMON_UPDATE(mac, RxMulticastFramesReceivedOK, RxMulticastFramesOK);
-	RMON_UPDATE(mac, RxBroadcastFramesReceivedOK, RxBroadcastFramesOK);
-	RMON_UPDATE(mac, RxPAUSEMACCtrlFramesReceived, RxPauseFrames);
-	RMON_UPDATE(mac, RxFrameCheckSequenceErrors, RxFCSErrors);
-	RMON_UPDATE(mac, RxFramesLostDueToInternalMACErrors,
-				RxInternalMACRcvError);
-	RMON_UPDATE(mac, RxSymbolErrors, RxSymbolErrors);
-	RMON_UPDATE(mac, RxInRangeLengthErrors, RxInRangeLengthErrors);
-	RMON_UPDATE(mac, RxFramesTooLongErrors , RxFrameTooLongErrors);
-	RMON_UPDATE(mac, RxJabbers, RxJabberErrors);
-	RMON_UPDATE(mac, RxFragments, RxRuntErrors);
-	RMON_UPDATE(mac, RxUndersizedFrames, RxRuntErrors);
-	RMON_UPDATE(mac, RxJumboFramesReceivedOK, RxJumboFramesOK);
-	RMON_UPDATE(mac, RxJumboOctetsReceivedOK, RxJumboOctetsOK);
-
-	/* Tx stats */
-	RMON_UPDATE(mac, TxOctetsTransmittedOK, TxOctetsOK);
-	RMON_UPDATE(mac, TxFramesLostDueToInternalMACTransmissionError,
-				TxInternalMACXmitError);
-	RMON_UPDATE(mac, TxTransmitSystemError, TxFCSErrors);
-	RMON_UPDATE(mac, TxUnicastFramesTransmittedOK, TxUnicastFramesOK);
-	RMON_UPDATE(mac, TxMulticastFramesTransmittedOK, TxMulticastFramesOK);
-	RMON_UPDATE(mac, TxBroadcastFramesTransmittedOK, TxBroadcastFramesOK);
-	RMON_UPDATE(mac, TxPAUSEMACCtrlFramesTransmitted, TxPauseFrames);
-	RMON_UPDATE(mac, TxJumboFramesReceivedOK, TxJumboFramesOK);
-	RMON_UPDATE(mac, TxJumboOctetsReceivedOK, TxJumboOctetsOK);
+	for (i = 0; i < ARRAY_SIZE(hw_stats); i++) {
+		unsigned reg = p->reg - SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW;
+
+		pm3393_rmon_update((mac)->adapter, OFFSET(p->reg),
+				   stats + p->offset, ro & (reg >> 2));
+	}
+
+
 
 	return &mac->stats;
 }
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/chelsio/vsc7326.c
index 31a67f5..534ffa0 100644
--- a/drivers/net/chelsio/vsc7326.c
+++ b/drivers/net/chelsio/vsc7326.c
@@ -589,40 +589,46 @@ static void rmon_update(struct cmac *mac
 
 static void port_stats_update(struct cmac *mac)
 {
-	int port = mac->instance->index;
+	struct {
+		unsigned int reg;
+		unsigned int offset;
+	} hw_stats[] = {
+
+#define HW_STAT(reg, stat_name) \
+	{ reg, (&((struct cmac_statistics *)NULL)->stat_name) - (u64 *)NULL }
+
+		/* Rx stats */
+		HW_STAT(RxUnicast, RxUnicastFramesOK),
+		HW_STAT(RxMulticast, RxMulticastFramesOK),
+		HW_STAT(RxBroadcast, RxBroadcastFramesOK),
+		HW_STAT(Crc, RxFCSErrors),
+		HW_STAT(RxAlignment, RxAlignErrors),
+		HW_STAT(RxOversize, RxFrameTooLongErrors),
+		HW_STAT(RxPause, RxPauseFrames),
+		HW_STAT(RxJabbers, RxJabberErrors),
+		HW_STAT(RxFragments, RxRuntErrors),
+		HW_STAT(RxUndersize, RxRuntErrors),
+		HW_STAT(RxSymbolCarrier, RxSymbolErrors),
+		HW_STAT(RxSize1519ToMax, RxJumboFramesOK),
+
+		/* Tx stats (skip collision stats as we are full-duplex only) */
+		HW_STAT(TxUnicast, TxUnicastFramesOK),
+		HW_STAT(TxMulticast, TxMulticastFramesOK),
+		HW_STAT(TxBroadcast, TxBroadcastFramesOK),
+		HW_STAT(TxPause, TxPauseFrames),
+		HW_STAT(TxUnderrun, TxUnderrun),
+		HW_STAT(TxSize1519ToMax, TxJumboFramesOK),
+	}, *p = hw_stats;
+	unsigned int port = mac->instance->index;
+	u64 *stats = (u64 *)&mac->stats;
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(hw_stats); i++)
+		rmon_update(mac, CRA(0x4, port, p->reg), stats + p->offset);
 
-	/* Rx stats */
+	rmon_update(mac, REG_TX_OK_BYTES(port), &mac->stats.TxOctetsOK);
 	rmon_update(mac, REG_RX_OK_BYTES(port), &mac->stats.RxOctetsOK);
 	rmon_update(mac, REG_RX_BAD_BYTES(port), &mac->stats.RxOctetsBad);
-	rmon_update(mac, REG_RX_UNICAST(port), &mac->stats.RxUnicastFramesOK);
-	rmon_update(mac, REG_RX_MULTICAST(port),
-		    &mac->stats.RxMulticastFramesOK);
-	rmon_update(mac, REG_RX_BROADCAST(port),
-		    &mac->stats.RxBroadcastFramesOK);
-	rmon_update(mac, REG_CRC(port), &mac->stats.RxFCSErrors);
-	rmon_update(mac, REG_RX_ALIGNMENT(port), &mac->stats.RxAlignErrors);
-	rmon_update(mac, REG_RX_OVERSIZE(port),
-		    &mac->stats.RxFrameTooLongErrors);
-	rmon_update(mac, REG_RX_PAUSE(port), &mac->stats.RxPauseFrames);
-	rmon_update(mac, REG_RX_JABBERS(port), &mac->stats.RxJabberErrors);
-	rmon_update(mac, REG_RX_FRAGMENTS(port), &mac->stats.RxRuntErrors);
-	rmon_update(mac, REG_RX_UNDERSIZE(port), &mac->stats.RxRuntErrors);
-	rmon_update(mac, REG_RX_SYMBOL_CARRIER(port),
-		    &mac->stats.RxSymbolErrors);
-	rmon_update(mac, REG_RX_SIZE_1519_TO_MAX(port),
-		    &mac->stats.RxJumboFramesOK);
-
-	/* Tx stats (skip collision stats as we are full-duplex only) */
-	rmon_update(mac, REG_TX_OK_BYTES(port), &mac->stats.TxOctetsOK);
-	rmon_update(mac, REG_TX_UNICAST(port), &mac->stats.TxUnicastFramesOK);
-	rmon_update(mac, REG_TX_MULTICAST(port),
-		    &mac->stats.TxMulticastFramesOK);
-	rmon_update(mac, REG_TX_BROADCAST(port),
-		    &mac->stats.TxBroadcastFramesOK);
-	rmon_update(mac, REG_TX_PAUSE(port), &mac->stats.TxPauseFrames);
-	rmon_update(mac, REG_TX_UNDERRUN(port), &mac->stats.TxUnderrun);
-	rmon_update(mac, REG_TX_SIZE_1519_TO_MAX(port),
-		    &mac->stats.TxJumboFramesOK);
 }
 
 /*
diff --git a/drivers/net/chelsio/vsc7326_reg.h b/drivers/net/chelsio/vsc7326_reg.h
index 491bcf7..479edbc 100644
--- a/drivers/net/chelsio/vsc7326_reg.h
+++ b/drivers/net/chelsio/vsc7326_reg.h
@@ -192,73 +192,84 @@ #define REG_TX_IFG(pn)		CRA(0x1,pn,0x18)
 #define REG_HDX(pn)		CRA(0x1,pn,0x19)	/* Half-duplex config */
 
 /* Statistics */
+/* CRA(0x4,pn,reg) */
+/* reg below */
 /* pn = port number, 0-a, a = 10GbE */
-#define REG_RX_IN_BYTES(pn)	CRA(0x4,pn,0x00)	/* # Rx in octets */
-#define REG_RX_SYMBOL_CARRIER(pn) CRA(0x4,pn,0x01)	/* Frames w/ symbol errors */
-#define REG_RX_PAUSE(pn)	CRA(0x4,pn,0x02)	/* # pause frames received */
-#define REG_RX_UNSUP_OPCODE(pn)	CRA(0x4,pn,0x03)	/* # control frames with unsupported opcode */
-#define REG_RX_OK_BYTES(pn)	CRA(0x4,pn,0x04)	/* # octets in good frames */
-#define REG_RX_BAD_BYTES(pn)	CRA(0x4,pn,0x05)	/* # octets in bad frames */
-#define REG_RX_UNICAST(pn)	CRA(0x4,pn,0x06)	/* # good unicast frames */
-#define REG_RX_MULTICAST(pn)	CRA(0x4,pn,0x07)	/* # good multicast frames */
-#define REG_RX_BROADCAST(pn)	CRA(0x4,pn,0x08)	/* # good broadcast frames */
-#define REG_CRC(pn)		CRA(0x4,pn,0x09)	/* # frames w/ bad CRC only */
-#define REG_RX_ALIGNMENT(pn)	CRA(0x4,pn,0x0a)	/* # frames w/ alignment err */
-#define REG_RX_UNDERSIZE(pn)	CRA(0x4,pn,0x0b)	/* # frames undersize */
-#define REG_RX_FRAGMENTS(pn)	CRA(0x4,pn,0x0c)	/* # frames undersize w/ crc err */
-#define REG_RX_IN_RANGE_LENGTH_ERROR(pn) CRA(0x4,pn,0x0d)	/* # frames with length error */
-#define REG_RX_OUT_OF_RANGE_ERROR(pn) CRA(0x4,pn,0x0e)	/* # frames with illegal length field */
-#define REG_RX_OVERSIZE(pn)	CRA(0x4,pn,0x0f)	/* # frames oversize */
-#define REG_RX_JABBERS(pn)	CRA(0x4,pn,0x10)	/* # frames oversize w/ crc err */
-#define REG_RX_SIZE_64(pn)	CRA(0x4,pn,0x11)	/* # frames 64 octets long */
-#define REG_RX_SIZE_65_TO_127(pn) CRA(0x4,pn,0x12)	/* # frames 65-127 octets */
-#define REG_RX_SIZE_128_TO_255(pn) CRA(0x4,pn,0x13)	/* # frames 128-255 */
-#define REG_RX_SIZE_256_TO_511(pn) CRA(0x4,pn,0x14)	/* # frames 256-511 */
-#define REG_RX_SIZE_512_TO_1023(pn) CRA(0x4,pn,0x15)	/* # frames 512-1023 */
-#define REG_RX_SIZE_1024_TO_1518(pn) CRA(0x4,pn,0x16)	/* # frames 1024-1518 */
-#define REG_RX_SIZE_1519_TO_MAX(pn) CRA(0x4,pn,0x17)	/* # frames 1519-max */
 
-#define REG_TX_OUT_BYTES(pn)	CRA(0x4,pn,0x18)	/* # octets tx */
-#define REG_TX_PAUSE(pn)	CRA(0x4,pn,0x19)	/* # pause frames sent */
-#define REG_TX_OK_BYTES(pn)	CRA(0x4,pn,0x1a)	/* # octets tx OK */
-#define REG_TX_UNICAST(pn)	CRA(0x4,pn,0x1b)	/* # frames unicast */
-#define REG_TX_MULTICAST(pn)	CRA(0x4,pn,0x1c)	/* # frames multicast */
-#define REG_TX_BROADCAST(pn)	CRA(0x4,pn,0x1d)	/* # frames broadcast */
-#define REG_TX_MULTIPLE_COLL(pn) CRA(0x4,pn,0x1e)	/* # frames tx after multiple collisions */
-#define REG_TX_LATE_COLL(pn)	CRA(0x4,pn,0x1f)	/* # late collisions detected */
-#define REG_TX_XCOLL(pn)	CRA(0x4,pn,0x20)	/* # frames lost, excessive collisions */
-#define REG_TX_DEFER(pn)	CRA(0x4,pn,0x21)	/* # frames deferred on first tx attempt */
-#define REG_TX_XDEFER(pn)	CRA(0x4,pn,0x22)	/* # frames excessively deferred */
-#define REG_TX_CSENSE(pn)	CRA(0x4,pn,0x23)	/* carrier sense errors at frame end */
-#define REG_TX_SIZE_64(pn)	CRA(0x4,pn,0x24)	/* # frames 64 octets long */
-#define REG_TX_SIZE_65_TO_127(pn) CRA(0x4,pn,0x25)	/* # frames 65-127 octets */
-#define REG_TX_SIZE_128_TO_255(pn) CRA(0x4,pn,0x26)	/* # frames 128-255 */
-#define REG_TX_SIZE_256_TO_511(pn) CRA(0x4,pn,0x27)	/* # frames 256-511 */
-#define REG_TX_SIZE_512_TO_1023(pn) CRA(0x4,pn,0x28)	/* # frames 512-1023 */
-#define REG_TX_SIZE_1024_TO_1518(pn) CRA(0x4,pn,0x29)	/* # frames 1024-1518 */
-#define REG_TX_SIZE_1519_TO_MAX(pn) CRA(0x4,pn,0x2a)	/* # frames 1519-max */
-#define REG_TX_SINGLE_COLL(pn)	CRA(0x4,pn,0x2b)	/* # frames tx after single collision */
-#define REG_TX_BACKOFF2(pn)	CRA(0x4,pn,0x2c)	/* # frames tx ok after 2 backoffs/collisions */
-#define REG_TX_BACKOFF3(pn)	CRA(0x4,pn,0x2d)	/*   after 3 backoffs/collisions */
-#define REG_TX_BACKOFF4(pn)	CRA(0x4,pn,0x2e)	/*   after 4 */
-#define REG_TX_BACKOFF5(pn)	CRA(0x4,pn,0x2f)	/*   after 5 */
-#define REG_TX_BACKOFF6(pn)	CRA(0x4,pn,0x30)	/*   after 6 */
-#define REG_TX_BACKOFF7(pn)	CRA(0x4,pn,0x31)	/*   after 7 */
-#define REG_TX_BACKOFF8(pn)	CRA(0x4,pn,0x32)	/*   after 8 */
-#define REG_TX_BACKOFF9(pn)	CRA(0x4,pn,0x33)	/*   after 9 */
-#define REG_TX_BACKOFF10(pn)	CRA(0x4,pn,0x34)	/*   after 10 */
-#define REG_TX_BACKOFF11(pn)	CRA(0x4,pn,0x35)	/*   after 11 */
-#define REG_TX_BACKOFF12(pn)	CRA(0x4,pn,0x36)	/*   after 12 */
-#define REG_TX_BACKOFF13(pn)	CRA(0x4,pn,0x37)	/*   after 13 */
-#define REG_TX_BACKOFF14(pn)	CRA(0x4,pn,0x38)	/*   after 14 */
-#define REG_TX_BACKOFF15(pn)	CRA(0x4,pn,0x39)	/*   after 15 */
-#define REG_TX_UNDERRUN(pn)	CRA(0x4,pn,0x3a)	/* # frames dropped from underrun */
-#define REG_RX_XGMII_PROT_ERR	CRA(0x4,0xa,0x3b)	/* # protocol errors detected on XGMII interface */
-#define REG_RX_IPG_SHRINK(pn)	CRA(0x4,pn,0x3c)	/* # of IPG shrinks detected */
+enum {
+	RxInBytes		= 0x00,	// # Rx in octets
+	RxSymbolCarrier		= 0x01,	// Frames w/ symbol errors
+	RxPause			= 0x02,	// # pause frames received
+	RxUnsupOpcode		= 0x03,	// # control frames with unsupported opcode
+	RxOkBytes		= 0x04,	// # octets in good frames
+	RxBadBytes		= 0x05,	// # octets in bad frames
+	RxUnicast		= 0x06,	// # good unicast frames
+	RxMulticast		= 0x07,	// # good multicast frames
+	RxBroadcast		= 0x08,	// # good broadcast frames
+	Crc			= 0x09,	// # frames w/ bad CRC only
+	RxAlignment		= 0x0a,	// # frames w/ alignment err
+	RxUndersize		= 0x0b,	// # frames undersize
+	RxFragments		= 0x0c,	// # frames undersize w/ crc err
+	RxInRangeLengthError	= 0x0d,	// # frames with length error
+	RxOutOfRangeError	= 0x0e,	// # frames with illegal length field
+	RxOversize		= 0x0f,	// # frames oversize
+	RxJabbers		= 0x10,	// # frames oversize w/ crc err
+	RxSize64		= 0x11,	// # frames 64 octets long
+	RxSize65To127		= 0x12,	// # frames 65-127 octets
+	RxSize128To255		= 0x13,	// # frames 128-255
+	RxSize256To511		= 0x14,	// # frames 256-511
+	RxSize512To1023		= 0x15,	// # frames 512-1023
+	RxSize1024To1518	= 0x16,	// # frames 1024-1518
+	RxSize1519ToMax		= 0x17,	// # frames 1519-max
 
-#define REG_STAT_STICKY1G(pn)	CRA(0x4,pn,0x3e)	/* tri-speed sticky bits */
-#define REG_STAT_STICKY10G	CRA(0x4,0xa,0x3e)	/* 10GbE sticky bits */
-#define REG_STAT_INIT(pn)	CRA(0x4,pn,0x3f)	/* Clear all statistics */
+	TxOutBytes		= 0x18,	// # octets tx
+	TxPause			= 0x19,	// # pause frames sent
+	TxOkBytes		= 0x1a, // # octets tx OK
+	TxUnicast		= 0x1b,	// # frames unicast
+	TxMulticast		= 0x1c,	// # frames multicast
+	TxBroadcast		= 0x1d,	// # frames broadcast
+	TxMultipleColl		= 0x1e,	// # frames tx after multiple collisions
+	TxLateColl		= 0x1f,	// # late collisions detected
+	TxXcoll			= 0x20,	// # frames lost, excessive collisions
+	TxDefer			= 0x21,	// # frames deferred on first tx attempt
+	TxXdefer		= 0x22,	// # frames excessively deferred
+	TxCsense		= 0x23,	// carrier sense errors at frame end
+	TxSize64		= 0x24,	// # frames 64 octets long
+	TxSize65To127		= 0x25,	// # frames 65-127 octets
+	TxSize128To255		= 0x26,	// # frames 128-255
+	TxSize256To511		= 0x27,	// # frames 256-511
+	TxSize512To1023		= 0x28,	// # frames 512-1023
+	TxSize1024To1518	= 0x29,	// # frames 1024-1518
+	TxSize1519ToMax		= 0x2a,	// # frames 1519-max
+	TxSingleColl		= 0x2b,	// # frames tx after single collision
+	TxBackoff2		= 0x2c,	// # frames tx ok after 2 backoffs/collisions
+	TxBackoff3		= 0x2d,	//   after 3 backoffs/collisions
+	TxBackoff4		= 0x2e,	//   after 4
+	TxBackoff5		= 0x2f,	//   after 5
+	TxBackoff6		= 0x30,	//   after 6
+	TxBackoff7		= 0x31,	//   after 7
+	TxBackoff8		= 0x32,	//   after 8
+	TxBackoff9		= 0x33,	//   after 9
+	TxBackoff10		= 0x34,	//   after 10
+	TxBackoff11		= 0x35,	//   after 11
+	TxBackoff12		= 0x36,	//   after 12
+	TxBackoff13		= 0x37,	//   after 13
+	TxBackoff14		= 0x38,	//   after 14
+	TxBackoff15		= 0x39,	//   after 15
+	TxUnderrun		= 0x3a,	// # frames dropped from underrun
+	// Hole. See REG_RX_XGMII_PROT_ERR below.
+	RxIpgShrink		= 0x3c,	// # of IPG shrinks detected
+	// Duplicate. See REG_STAT_STICKY10G below.
+	StatSticky1G		= 0x3e,	// tri-speed sticky bits
+	StatInit		= 0x3f	// Clear all statistics
+};
+
+#define REG_RX_XGMII_PROT_ERR	CRA(0x4,0xa,0x3b)		/* # protocol errors detected on XGMII interface */
+#define REG_STAT_STICKY10G	CRA(0x4,0xa,StatSticky1G)	/* 10GbE sticky bits */
+
+#define REG_RX_OK_BYTES(pn)	CRA(0x4,pn,RxOkBytes)
+#define REG_RX_BAD_BYTES(pn)	CRA(0x4,pn,RxBadBytes)
+#define REG_TX_OK_BYTES(pn)	CRA(0x4,pn,TxOkBytes)
 
 /* MII-Management Block registers */
 /* These are for MII-M interface 0, which is the bidirectional LVTTL one.  If
-- 
1.4.2.3

