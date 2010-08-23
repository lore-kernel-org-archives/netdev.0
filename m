From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/3] drivers/net/ixgbe/ixgbe_main.c: Add ixgbe_psum
Date: Sun, 22 Aug 2010 19:53:02 -0700
Message-ID: <935d637e23f2ef6f6187af426eeda70793d291bd.1282531322.git.joe@perches.com>
References: <cover.1282531322.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1282531322.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce indentation in a couple of places
Add static function ixgbe_psum
Add temporary for adapter->stats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgbe/ixgbe_main.c |  297 ++++++++++++++++++++--------------------
 1 files changed, 151 insertions(+), 146 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6e100d4..9911d4a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1634,34 +1634,35 @@ static void ixgbe_check_overtemp_task(struct work_struct *work)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr = adapter->interrupt_event;
 
-	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) {
-		switch (hw->device_id) {
-		case IXGBE_DEV_ID_82599_T3_LOM: {
-			u32 autoneg;
-			bool link_up = false;
-
-			if (hw->mac.ops.check_link)
-				hw->mac.ops.check_link(hw, &autoneg, &link_up, false);
-
-			if (((eicr & IXGBE_EICR_GPI_SDP0) && (!link_up)) ||
-			    (eicr & IXGBE_EICR_LSC))
-				/* Check if this is due to overtemp */
-				if (hw->phy.ops.check_overtemp(hw) == IXGBE_ERR_OVERTEMP)
-					break;
-			}
+	if (!(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE))
+		return;
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82599_T3_LOM: {
+		u32 autoneg;
+		bool link_up = false;
+
+		if (hw->mac.ops.check_link)
+			hw->mac.ops.check_link(hw, &autoneg, &link_up, false);
+
+		if (((eicr & IXGBE_EICR_GPI_SDP0) && (!link_up)) ||
+		    (eicr & IXGBE_EICR_LSC))
+			/* Check if this is due to overtemp */
+			if (hw->phy.ops.check_overtemp(hw) == IXGBE_ERR_OVERTEMP)
+				break;
+		return;
+	}
+	default:
+		if (!(eicr & IXGBE_EICR_GPI_SDP0))
 			return;
-		default:
-			if (!(eicr & IXGBE_EICR_GPI_SDP0))
-				return;
-			break;
-		}
-		e_crit(drv, "Network adapter has been stopped because it has "
-		       "over heated. Restart the computer. If the problem "
-		       "persists, power off the system and replace the "
-		       "adapter\n");
-		/* write to clear the interrupt */
-		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP0);
+		break;
 	}
+	e_crit(drv,
+	       "Network adapter has been stopped because it has over heated. "
+	       "Restart the computer. If the problem persists, "
+	       "power off the system and replace the adapter\n");
+	/* write to clear the interrupt */
+	IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP0);
 }
 
 static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
@@ -5396,6 +5397,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	u64 total_mpc = 0;
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 	u64 non_eop_descs = 0, restart_queue = 0;
+	struct ixgbe_hw_stats *hwstats = &adapter->stats;
 
 	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
 	    test_bit(__IXGBE_RESETTING, &adapter->state))
@@ -5406,7 +5408,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		u64 rsc_flush = 0;
 		for (i = 0; i < 16; i++)
 			adapter->hw_rx_no_dma_resources +=
-					     IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
+				IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			rsc_count += adapter->rx_ring[i]->rsc_count;
 			rsc_flush += adapter->rx_ring[i]->rsc_flush;
@@ -5424,121 +5426,118 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		non_eop_descs += adapter->rx_ring[i]->non_eop_descs;
 	adapter->non_eop_descs = non_eop_descs;
 
-	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
+	hwstats->crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
 	for (i = 0; i < 8; i++) {
 		/* for packet buffers not used, the register should read 0 */
 		mpc = IXGBE_READ_REG(hw, IXGBE_MPC(i));
 		missed_rx += mpc;
-		adapter->stats.mpc[i] += mpc;
-		total_mpc += adapter->stats.mpc[i];
+		hwstats->mpc[i] += mpc;
+		total_mpc += hwstats->mpc[i];
 		if (hw->mac.type == ixgbe_mac_82598EB)
-			adapter->stats.rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
-		adapter->stats.qptc[i] += IXGBE_READ_REG(hw, IXGBE_QPTC(i));
-		adapter->stats.qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC(i));
-		adapter->stats.qprc[i] += IXGBE_READ_REG(hw, IXGBE_QPRC(i));
-		adapter->stats.qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
+			hwstats->rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+		hwstats->qptc[i] += IXGBE_READ_REG(hw, IXGBE_QPTC(i));
+		hwstats->qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC(i));
+		hwstats->qprc[i] += IXGBE_READ_REG(hw, IXGBE_QPRC(i));
+		hwstats->qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
 		if (hw->mac.type == ixgbe_mac_82599EB) {
-			adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
-							    IXGBE_PXONRXCNT(i));
-			adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
-							   IXGBE_PXOFFRXCNT(i));
-			adapter->stats.qprdc[i] += IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
+			hwstats->pxonrxc[i] +=
+				IXGBE_READ_REG(hw, IXGBE_PXONRXCNT(i));
+			hwstats->pxoffrxc[i] +=
+				IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(i));
+			hwstats->qprdc[i] += IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		} else {
-			adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
-							      IXGBE_PXONRXC(i));
-			adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
-							     IXGBE_PXOFFRXC(i));
+			hwstats->pxonrxc[i] +=
+				IXGBE_READ_REG(hw, IXGBE_PXONRXC(i));
+			hwstats->pxoffrxc[i] +=
+				IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
 		}
-		adapter->stats.pxontxc[i] += IXGBE_READ_REG(hw,
-							    IXGBE_PXONTXC(i));
-		adapter->stats.pxofftxc[i] += IXGBE_READ_REG(hw,
-							     IXGBE_PXOFFTXC(i));
+		hwstats->pxontxc[i] += IXGBE_READ_REG(hw, IXGBE_PXONTXC(i));
+		hwstats->pxofftxc[i] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(i));
 	}
-	adapter->stats.gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
+	hwstats->gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
 	/* work around hardware counting issue */
-	adapter->stats.gprc -= missed_rx;
+	hwstats->gprc -= missed_rx;
 
 	/* 82598 hardware only has a 32 bit counter in the high register */
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		u64 tmp;
-		adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
+		hwstats->gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
 		tmp = IXGBE_READ_REG(hw, IXGBE_GORCH) & 0xF;
 						/* 4 high bits of GORC */
-		adapter->stats.gorc += (tmp << 32);
-		adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
+		hwstats->gorc += (tmp << 32);
+		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
 		tmp = IXGBE_READ_REG(hw, IXGBE_GOTCH) & 0xF;
 						/* 4 high bits of GOTC */
-		adapter->stats.gotc += (tmp << 32);
-		adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORL);
+		hwstats->gotc += (tmp << 32);
+		hwstats->tor += IXGBE_READ_REG(hw, IXGBE_TORL);
 		IXGBE_READ_REG(hw, IXGBE_TORH);	/* to clear */
-		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
-		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
-		adapter->stats.fdirmatch += IXGBE_READ_REG(hw, IXGBE_FDIRMATCH);
-		adapter->stats.fdirmiss += IXGBE_READ_REG(hw, IXGBE_FDIRMISS);
+		hwstats->lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
+		hwstats->lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
+		hwstats->fdirmatch += IXGBE_READ_REG(hw, IXGBE_FDIRMATCH);
+		hwstats->fdirmiss += IXGBE_READ_REG(hw, IXGBE_FDIRMISS);
 #ifdef IXGBE_FCOE
-		adapter->stats.fccrc += IXGBE_READ_REG(hw, IXGBE_FCCRC);
-		adapter->stats.fcoerpdc += IXGBE_READ_REG(hw, IXGBE_FCOERPDC);
-		adapter->stats.fcoeprc += IXGBE_READ_REG(hw, IXGBE_FCOEPRC);
-		adapter->stats.fcoeptc += IXGBE_READ_REG(hw, IXGBE_FCOEPTC);
-		adapter->stats.fcoedwrc += IXGBE_READ_REG(hw, IXGBE_FCOEDWRC);
-		adapter->stats.fcoedwtc += IXGBE_READ_REG(hw, IXGBE_FCOEDWTC);
+		hwstats->fccrc += IXGBE_READ_REG(hw, IXGBE_FCCRC);
+		hwstats->fcoerpdc += IXGBE_READ_REG(hw, IXGBE_FCOERPDC);
+		hwstats->fcoeprc += IXGBE_READ_REG(hw, IXGBE_FCOEPRC);
+		hwstats->fcoeptc += IXGBE_READ_REG(hw, IXGBE_FCOEPTC);
+		hwstats->fcoedwrc += IXGBE_READ_REG(hw, IXGBE_FCOEDWRC);
+		hwstats->fcoedwtc += IXGBE_READ_REG(hw, IXGBE_FCOEDWTC);
 #endif /* IXGBE_FCOE */
 	} else {
-		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
-		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
-		adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
-		adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
-		adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
+		hwstats->lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
+		hwstats->lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
+		hwstats->gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
+		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
+		hwstats->tor += IXGBE_READ_REG(hw, IXGBE_TORH);
 	}
 	bprc = IXGBE_READ_REG(hw, IXGBE_BPRC);
-	adapter->stats.bprc += bprc;
-	adapter->stats.mprc += IXGBE_READ_REG(hw, IXGBE_MPRC);
+	hwstats->bprc += bprc;
+	hwstats->mprc += IXGBE_READ_REG(hw, IXGBE_MPRC);
 	if (hw->mac.type == ixgbe_mac_82598EB)
-		adapter->stats.mprc -= bprc;
-	adapter->stats.roc += IXGBE_READ_REG(hw, IXGBE_ROC);
-	adapter->stats.prc64 += IXGBE_READ_REG(hw, IXGBE_PRC64);
-	adapter->stats.prc127 += IXGBE_READ_REG(hw, IXGBE_PRC127);
-	adapter->stats.prc255 += IXGBE_READ_REG(hw, IXGBE_PRC255);
-	adapter->stats.prc511 += IXGBE_READ_REG(hw, IXGBE_PRC511);
-	adapter->stats.prc1023 += IXGBE_READ_REG(hw, IXGBE_PRC1023);
-	adapter->stats.prc1522 += IXGBE_READ_REG(hw, IXGBE_PRC1522);
-	adapter->stats.rlec += IXGBE_READ_REG(hw, IXGBE_RLEC);
+		hwstats->mprc -= bprc;
+	hwstats->roc += IXGBE_READ_REG(hw, IXGBE_ROC);
+	hwstats->prc64 += IXGBE_READ_REG(hw, IXGBE_PRC64);
+	hwstats->prc127 += IXGBE_READ_REG(hw, IXGBE_PRC127);
+	hwstats->prc255 += IXGBE_READ_REG(hw, IXGBE_PRC255);
+	hwstats->prc511 += IXGBE_READ_REG(hw, IXGBE_PRC511);
+	hwstats->prc1023 += IXGBE_READ_REG(hw, IXGBE_PRC1023);
+	hwstats->prc1522 += IXGBE_READ_REG(hw, IXGBE_PRC1522);
+	hwstats->rlec += IXGBE_READ_REG(hw, IXGBE_RLEC);
 	lxon = IXGBE_READ_REG(hw, IXGBE_LXONTXC);
-	adapter->stats.lxontxc += lxon;
+	hwstats->lxontxc += lxon;
 	lxoff = IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
-	adapter->stats.lxofftxc += lxoff;
-	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
-	adapter->stats.gptc += IXGBE_READ_REG(hw, IXGBE_GPTC);
-	adapter->stats.mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
+	hwstats->lxofftxc += lxoff;
+	hwstats->ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
+	hwstats->gptc += IXGBE_READ_REG(hw, IXGBE_GPTC);
+	hwstats->mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
 	/*
 	 * 82598 errata - tx of flow control packets is included in tx counters
 	 */
 	xon_off_tot = lxon + lxoff;
-	adapter->stats.gptc -= xon_off_tot;
-	adapter->stats.mptc -= xon_off_tot;
-	adapter->stats.gotc -= (xon_off_tot * (ETH_ZLEN + ETH_FCS_LEN));
-	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
-	adapter->stats.rfc += IXGBE_READ_REG(hw, IXGBE_RFC);
-	adapter->stats.rjc += IXGBE_READ_REG(hw, IXGBE_RJC);
-	adapter->stats.tpr += IXGBE_READ_REG(hw, IXGBE_TPR);
-	adapter->stats.ptc64 += IXGBE_READ_REG(hw, IXGBE_PTC64);
-	adapter->stats.ptc64 -= xon_off_tot;
-	adapter->stats.ptc127 += IXGBE_READ_REG(hw, IXGBE_PTC127);
-	adapter->stats.ptc255 += IXGBE_READ_REG(hw, IXGBE_PTC255);
-	adapter->stats.ptc511 += IXGBE_READ_REG(hw, IXGBE_PTC511);
-	adapter->stats.ptc1023 += IXGBE_READ_REG(hw, IXGBE_PTC1023);
-	adapter->stats.ptc1522 += IXGBE_READ_REG(hw, IXGBE_PTC1522);
-	adapter->stats.bptc += IXGBE_READ_REG(hw, IXGBE_BPTC);
+	hwstats->gptc -= xon_off_tot;
+	hwstats->mptc -= xon_off_tot;
+	hwstats->gotc -= (xon_off_tot * (ETH_ZLEN + ETH_FCS_LEN));
+	hwstats->ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
+	hwstats->rfc += IXGBE_READ_REG(hw, IXGBE_RFC);
+	hwstats->rjc += IXGBE_READ_REG(hw, IXGBE_RJC);
+	hwstats->tpr += IXGBE_READ_REG(hw, IXGBE_TPR);
+	hwstats->ptc64 += IXGBE_READ_REG(hw, IXGBE_PTC64);
+	hwstats->ptc64 -= xon_off_tot;
+	hwstats->ptc127 += IXGBE_READ_REG(hw, IXGBE_PTC127);
+	hwstats->ptc255 += IXGBE_READ_REG(hw, IXGBE_PTC255);
+	hwstats->ptc511 += IXGBE_READ_REG(hw, IXGBE_PTC511);
+	hwstats->ptc1023 += IXGBE_READ_REG(hw, IXGBE_PTC1023);
+	hwstats->ptc1522 += IXGBE_READ_REG(hw, IXGBE_PTC1522);
+	hwstats->bptc += IXGBE_READ_REG(hw, IXGBE_BPTC);
 
 	/* Fill out the OS statistics structure */
-	netdev->stats.multicast = adapter->stats.mprc;
+	netdev->stats.multicast = hwstats->mprc;
 
 	/* Rx Errors */
-	netdev->stats.rx_errors = adapter->stats.crcerrs +
-				       adapter->stats.rlec;
+	netdev->stats.rx_errors = hwstats->crcerrs + hwstats->rlec;
 	netdev->stats.rx_dropped = 0;
-	netdev->stats.rx_length_errors = adapter->stats.rlec;
-	netdev->stats.rx_crc_errors = adapter->stats.crcerrs;
+	netdev->stats.rx_length_errors = hwstats->rlec;
+	netdev->stats.rx_crc_errors = hwstats->crcerrs;
 	netdev->stats.rx_missed_errors = total_mpc;
 }
 
@@ -5868,6 +5867,50 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 	return false;
 }
 
+static u32 ixgbe_psum(struct ixgbe_adapter *adapter, struct sk_buff *skb)
+{
+	u32 rtn = 0;
+	__be16 protocol;
+
+	if (skb->protocol == cpu_to_be16(ETH_P_8021Q))
+		protocol = ((const struct vlan_ethhdr *)skb->data)->
+					h_vlan_encapsulated_proto;
+	else
+		protocol = skb->protocol;
+
+	switch (protocol) {
+	case cpu_to_be16(ETH_P_IP):
+		rtn |= IXGBE_ADVTXD_TUCMD_IPV4;
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_TCP:
+			rtn |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
+			break;
+		case IPPROTO_SCTP:
+			rtn |= IXGBE_ADVTXD_TUCMD_L4T_SCTP;
+			break;
+		}
+		break;
+	case cpu_to_be16(ETH_P_IPV6):
+		/* XXX what about other V6 headers?? */
+		switch (ipv6_hdr(skb)->nexthdr) {
+		case IPPROTO_TCP:
+			rtn |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
+			break;
+		case IPPROTO_SCTP:
+			rtn |= IXGBE_ADVTXD_TUCMD_L4T_SCTP;
+			break;
+		}
+		break;
+	default:
+		if (unlikely(net_ratelimit()))
+			e_warn(probe, "partial checksum but proto=%x!\n",
+			       skb->protocol);
+		break;
+	}
+
+	return rtn;
+}
+
 static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring,
 			  struct sk_buff *skb, u32 tx_flags)
@@ -5898,46 +5941,8 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
 				    IXGBE_ADVTXD_DTYP_CTXT);
 
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			__be16 protocol;
-
-			if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
-				const struct vlan_ethhdr *vhdr =
-					(const struct vlan_ethhdr *)skb->data;
-
-				protocol = vhdr->h_vlan_encapsulated_proto;
-			} else {
-				protocol = skb->protocol;
-			}
-
-			switch (protocol) {
-			case cpu_to_be16(ETH_P_IP):
-				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
-				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
-					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_TCP;
-				else if (ip_hdr(skb)->protocol == IPPROTO_SCTP)
-					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_SCTP;
-				break;
-			case cpu_to_be16(ETH_P_IPV6):
-				/* XXX what about other V6 headers?? */
-				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
-					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_TCP;
-				else if (ipv6_hdr(skb)->nexthdr == IPPROTO_SCTP)
-					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_SCTP;
-				break;
-			default:
-				if (unlikely(net_ratelimit())) {
-					e_warn(probe, "partial checksum "
-					       "but proto=%x!\n",
-					       skb->protocol);
-				}
-				break;
-			}
-		}
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			type_tucmd_mlhl |= ixgbe_psum(adapter, skb);
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
 		/* use index zero for tx checksum offload */
-- 
1.7.2.19.g9a302
