From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/3] cxgb - fix stats
Date: Tue, 27 Nov 2007 13:30:20 -0800
Message-ID: <20071127213020.841.64392.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greearb@candelatech.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:14594 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759270AbXK0VaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 16:30:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Fix MAC stats accounting. 
Fix get_stats.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/chelsio/cxgb2.c  |   67 +++++++++++++++++++------
 drivers/net/chelsio/pm3393.c |  112 +++++++++++++++++-------------------------
 drivers/net/chelsio/sge.c    |    4 --
 drivers/net/chelsio/sge.h    |    2 -
 4 files changed, 96 insertions(+), 89 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 2461f91..c597504 100755
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -374,7 +374,9 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"TxInternalMACXmitError",
 	"TxFramesWithExcessiveDeferral",
 	"TxFCSErrors",
-
+	"TxJumboFramesOk",
+	"TxJumboOctetsOk",
+	
 	"RxOctetsOK",
 	"RxOctetsBad",
 	"RxUnicastFramesOK",
@@ -392,11 +394,11 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"RxInRangeLengthErrors",
 	"RxOutOfRangeLengthField",
 	"RxFrameTooLongErrors",
+	"RxJumboFramesOk",
+	"RxJumboOctetsOk",
 
 	/* Port stats */
-	"RxPackets",
 	"RxCsumGood",
-	"TxPackets",
 	"TxCsumOffload",
 	"TxTso",
 	"RxVlan",
@@ -464,23 +466,56 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	const struct cmac_statistics *s;
 	const struct sge_intr_counts *t;
 	struct sge_port_stats ss;
-	unsigned int len;
 
 	s = mac->ops->statistics_update(mac, MAC_STATS_UPDATE_FULL);
-
-	len = sizeof(u64)*(&s->TxFCSErrors + 1 - &s->TxOctetsOK);
-	memcpy(data, &s->TxOctetsOK, len);
-	data += len;
-
-	len = sizeof(u64)*(&s->RxFrameTooLongErrors + 1 - &s->RxOctetsOK);
-	memcpy(data, &s->RxOctetsOK, len);
-	data += len;
-
+	t = t1_sge_get_intr_counts(adapter->sge);
 	t1_sge_get_port_stats(adapter->sge, dev->if_port, &ss);
-	memcpy(data, &ss, sizeof(ss));
-	data += sizeof(ss);
 
-	t = t1_sge_get_intr_counts(adapter->sge);
+	*data++ = s->TxOctetsOK;
+	*data++ = s->TxOctetsBad;
+	*data++ = s->TxUnicastFramesOK;
+	*data++ = s->TxMulticastFramesOK;
+	*data++ = s->TxBroadcastFramesOK;
+	*data++ = s->TxPauseFrames;
+	*data++ = s->TxFramesWithDeferredXmissions;
+	*data++ = s->TxLateCollisions;
+	*data++ = s->TxTotalCollisions;
+	*data++ = s->TxFramesAbortedDueToXSCollisions;
+	*data++ = s->TxUnderrun;
+	*data++ = s->TxLengthErrors;
+	*data++ = s->TxInternalMACXmitError;
+	*data++ = s->TxFramesWithExcessiveDeferral;
+	*data++ = s->TxFCSErrors;
+	*data++ = s->TxJumboFramesOK;
+	*data++ = s->TxJumboOctetsOK;
+
+	*data++ = s->RxOctetsOK;
+	*data++ = s->RxOctetsBad;
+	*data++ = s->RxUnicastFramesOK;
+	*data++ = s->RxMulticastFramesOK;
+	*data++ = s->RxBroadcastFramesOK;
+	*data++ = s->RxPauseFrames;
+	*data++ = s->RxFCSErrors;
+	*data++ = s->RxAlignErrors;
+	*data++ = s->RxSymbolErrors;
+	*data++ = s->RxDataErrors;
+	*data++ = s->RxSequenceErrors;
+	*data++ = s->RxRuntErrors;
+	*data++ = s->RxJabberErrors;
+	*data++ = s->RxInternalMACRcvError;
+	*data++ = s->RxInRangeLengthErrors;
+	*data++ = s->RxOutOfRangeLengthField;
+	*data++ = s->RxFrameTooLongErrors;
+	*data++ = s->RxJumboFramesOK;
+	*data++ = s->RxJumboOctetsOK;
+
+	*data++ = ss.rx_cso_good;
+	*data++ = ss.tx_cso;
+	*data++ = ss.tx_tso;
+	*data++ = ss.vlan_xtract;
+	*data++ = ss.vlan_insert;
+	*data++ = ss.tx_need_hdrroom;
+	
 	*data++ = t->rx_drops;
 	*data++ = t->pure_rsps;
 	*data++ = t->unhandled_irqs;
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
old mode 100644
new mode 100755
index 678778a..2117c4f
--- a/drivers/net/chelsio/pm3393.c
+++ b/drivers/net/chelsio/pm3393.c
@@ -45,7 +45,7 @@
 
 #include <linux/crc32.h>
 
-#define OFFSET(REG_ADDR)    (REG_ADDR << 2)
+#define OFFSET(REG_ADDR)    ((REG_ADDR) << 2)
 
 /* Max frame size PM3393 can handle. Includes Ethernet header and CRC. */
 #define MAX_FRAME_SIZE  9600
@@ -428,69 +428,26 @@ static int pm3393_set_speed_duplex_fc(struct cmac *cmac, int speed, int duplex,
 	return 0;
 }
 
-static void pm3393_rmon_update(struct adapter *adapter, u32 offs, u64 *val,
-			       int over)
-{
-	u32 val0, val1, val2;
-
-	t1_tpi_read(adapter, offs, &val0);
-	t1_tpi_read(adapter, offs + 4, &val1);
-	t1_tpi_read(adapter, offs + 8, &val2);
-
-	*val &= ~0ull << 40;
-	*val |= val0 & 0xffff;
-	*val |= (val1 & 0xffff) << 16;
-	*val |= (u64)(val2 & 0xff) << 32;
-
-	if (over)
-		*val += 1ull << 40;
+#define RMON_UPDATE(mac, name, stat_name) \
+{ \
+	t1_tpi_read((mac)->adapter, OFFSET(name), &val0);     \
+	t1_tpi_read((mac)->adapter, OFFSET((name)+1), &val1); \
+	t1_tpi_read((mac)->adapter, OFFSET((name)+2), &val2); \
+	(mac)->stats.stat_name = (u64)(val0 & 0xffff) | \
+				 ((u64)(val1 & 0xffff) << 16) | \
+				 ((u64)(val2 & 0xff) << 32) | \
+				 ((mac)->stats.stat_name & \
+					0xffffff0000000000ULL); \
+	if (ro & \
+	    (1ULL << ((name - SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW) >> 2))) \
+		(mac)->stats.stat_name += 1ULL << 40; \
 }
 
 static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 							      int flag)
 {
-	static struct {
-		unsigned int reg;
-		unsigned int offset;
-	} hw_stats [] = {
-
-#define HW_STAT(name, stat_name) \
-	{ name, (&((struct cmac_statistics *)NULL)->stat_name) - (u64 *)NULL }
-
-		/* Rx stats */
-		HW_STAT(RxOctetsReceivedOK, RxOctetsOK),
-		HW_STAT(RxUnicastFramesReceivedOK, RxUnicastFramesOK),
-		HW_STAT(RxMulticastFramesReceivedOK, RxMulticastFramesOK),
-		HW_STAT(RxBroadcastFramesReceivedOK, RxBroadcastFramesOK),
-		HW_STAT(RxPAUSEMACCtrlFramesReceived, RxPauseFrames),
-		HW_STAT(RxFrameCheckSequenceErrors, RxFCSErrors),
-		HW_STAT(RxFramesLostDueToInternalMACErrors,
-				RxInternalMACRcvError),
-		HW_STAT(RxSymbolErrors, RxSymbolErrors),
-		HW_STAT(RxInRangeLengthErrors, RxInRangeLengthErrors),
-		HW_STAT(RxFramesTooLongErrors , RxFrameTooLongErrors),
-		HW_STAT(RxJabbers, RxJabberErrors),
-		HW_STAT(RxFragments, RxRuntErrors),
-		HW_STAT(RxUndersizedFrames, RxRuntErrors),
-		HW_STAT(RxJumboFramesReceivedOK, RxJumboFramesOK),
-		HW_STAT(RxJumboOctetsReceivedOK, RxJumboOctetsOK),
-
-		/* Tx stats */
-		HW_STAT(TxOctetsTransmittedOK, TxOctetsOK),
-		HW_STAT(TxFramesLostDueToInternalMACTransmissionError,
-				TxInternalMACXmitError),
-		HW_STAT(TxTransmitSystemError, TxFCSErrors),
-		HW_STAT(TxUnicastFramesTransmittedOK, TxUnicastFramesOK),
-		HW_STAT(TxMulticastFramesTransmittedOK, TxMulticastFramesOK),
-		HW_STAT(TxBroadcastFramesTransmittedOK, TxBroadcastFramesOK),
-		HW_STAT(TxPAUSEMACCtrlFramesTransmitted, TxPauseFrames),
-		HW_STAT(TxJumboFramesReceivedOK, TxJumboFramesOK),
-		HW_STAT(TxJumboOctetsReceivedOK, TxJumboOctetsOK)
-	}, *p = hw_stats;
-	u64 ro;
-	u32 val0, val1, val2, val3;
-	u64 *stats = (u64 *) &mac->stats;
-	unsigned int i;
+	u64	ro;
+	u32	val0, val1, val2, val3;
 
 	/* Snap the counters */
 	pmwrite(mac, SUNI1x10GEXP_REG_MSTAT_CONTROL,
@@ -504,14 +461,35 @@ static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 	ro = ((u64)val0 & 0xffff) | (((u64)val1 & 0xffff) << 16) |
 		(((u64)val2 & 0xffff) << 32) | (((u64)val3 & 0xffff) << 48);
 
-	for (i = 0; i < ARRAY_SIZE(hw_stats); i++) {
-		unsigned reg = p->reg - SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW;
-
-		pm3393_rmon_update((mac)->adapter, OFFSET(p->reg),
-				   stats + p->offset, ro & (reg >> 2));
-	}
-
-
+	/* Rx stats */
+	RMON_UPDATE(mac, RxOctetsReceivedOK, RxOctetsOK);
+	RMON_UPDATE(mac, RxUnicastFramesReceivedOK, RxUnicastFramesOK);
+	RMON_UPDATE(mac, RxMulticastFramesReceivedOK, RxMulticastFramesOK);
+	RMON_UPDATE(mac, RxBroadcastFramesReceivedOK, RxBroadcastFramesOK);
+	RMON_UPDATE(mac, RxPAUSEMACCtrlFramesReceived, RxPauseFrames);
+	RMON_UPDATE(mac, RxFrameCheckSequenceErrors, RxFCSErrors);
+	RMON_UPDATE(mac, RxFramesLostDueToInternalMACErrors,
+				RxInternalMACRcvError);
+	RMON_UPDATE(mac, RxSymbolErrors, RxSymbolErrors);
+	RMON_UPDATE(mac, RxInRangeLengthErrors, RxInRangeLengthErrors);
+	RMON_UPDATE(mac, RxFramesTooLongErrors , RxFrameTooLongErrors);
+	RMON_UPDATE(mac, RxJabbers, RxJabberErrors);
+	RMON_UPDATE(mac, RxFragments, RxRuntErrors);
+	RMON_UPDATE(mac, RxUndersizedFrames, RxRuntErrors);
+	RMON_UPDATE(mac, RxJumboFramesReceivedOK, RxJumboFramesOK);
+	RMON_UPDATE(mac, RxJumboOctetsReceivedOK, RxJumboOctetsOK);
+
+	/* Tx stats */
+	RMON_UPDATE(mac, TxOctetsTransmittedOK, TxOctetsOK);
+	RMON_UPDATE(mac, TxFramesLostDueToInternalMACTransmissionError,
+				TxInternalMACXmitError);
+	RMON_UPDATE(mac, TxTransmitSystemError, TxFCSErrors);
+	RMON_UPDATE(mac, TxUnicastFramesTransmittedOK, TxUnicastFramesOK);
+	RMON_UPDATE(mac, TxMulticastFramesTransmittedOK, TxMulticastFramesOK);
+	RMON_UPDATE(mac, TxBroadcastFramesTransmittedOK, TxBroadcastFramesOK);
+	RMON_UPDATE(mac, TxPAUSEMACCtrlFramesTransmitted, TxPauseFrames);
+	RMON_UPDATE(mac, TxJumboFramesReceivedOK, TxJumboFramesOK);
+	RMON_UPDATE(mac, TxJumboOctetsReceivedOK, TxJumboOctetsOK);
 
 	return &mac->stats;
 }
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
old mode 100644
new mode 100755
index 4b6258f..b301c04
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -986,9 +986,7 @@ void t1_sge_get_port_stats(const struct sge *sge, int port,
 	for_each_possible_cpu(cpu) {
 		struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[port], cpu);
 
-		ss->rx_packets += st->rx_packets;
 		ss->rx_cso_good += st->rx_cso_good;
-		ss->tx_packets += st->tx_packets;
 		ss->tx_cso += st->tx_cso;
 		ss->tx_tso += st->tx_tso;
 		ss->tx_need_hdrroom += st->tx_need_hdrroom;
@@ -1381,7 +1379,6 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 	__skb_pull(skb, sizeof(*p));
 
 	st = per_cpu_ptr(sge->port_stats[p->iff], smp_processor_id());
-	st->rx_packets++;
 
 	skb->protocol = eth_type_trans(skb, adapter->port[p->iff].dev);
 	skb->dev->last_rx = jiffies;
@@ -1946,7 +1943,6 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		cpl->vlan_valid = 0;
 
 send:
-	st->tx_packets++;
 	dev->trans_start = jiffies;
 	ret = t1_sge_tx(skb, adapter, 0, dev);
 
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
index 285bbb2..cced9df 100755
--- a/drivers/net/chelsio/sge.h
+++ b/drivers/net/chelsio/sge.h
@@ -57,9 +57,7 @@ struct sge_intr_counts {
 };
 
 struct sge_port_stats {
-	u64 rx_packets;      /* # of Ethernet packets received */
 	u64 rx_cso_good;     /* # of successful RX csum offloads */
-	u64 tx_packets;      /* # of TX packets */
 	u64 tx_cso;          /* # of TX checksum offloads */
 	u64 tx_tso;          /* # of TSO requests */
 	u64 vlan_xtract;     /* # of VLAN tag extractions */
