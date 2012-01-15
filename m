From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/8] brcm80211: Convert printk(KERN_DEBUG to pr_debug
Date: Sun, 15 Jan 2012 00:38:42 -0800
Message-ID: <ee800c0a4d90e61d71bf64cc62fd1b673975ce0e.1326616556.git.joe@perches.com>
References: <cover.1326616556.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1326616556.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_debug to allow dynamic debugging to work.

Move an #endif to allow brcmf_dbg_hex_dump
to be outside the #if/#endif block.
Move a const char* declaration to be inside a
pr_debug so the function doesn't need a #if/#endif
block.
Don't use temporaries in debugging functions so
the code can be optimized away.

Signed-off-by: Joe Perches <joe@perches.com>
---
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   11 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  147 +++++++++-----------
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |    4 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    3 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |    2 +-
 6 files changed, 78 insertions(+), 93 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
index 9385c84..1c75ea8 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
@@ -399,10 +399,10 @@ brcmf_c_show_host_event(struct brcmf_event_msg *event, void *event_data)
 		p = (char *)&buf[sizeof(struct msgtrace_hdr)];
 		while ((s = strstr(p, "\n")) != NULL) {
 			*s = '\0';
-			printk(KERN_DEBUG"%s\n", p);
+			pr_debug("%s\n", p);
 			p = s + 1;
 		}
-		printk(KERN_DEBUG "%s\n", p);
+		pr_debug("%s\n", p);
 
 		/* Reset datalen to avoid display below */
 		datalen = 0;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 79230e7..91ec023 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -2137,6 +2137,7 @@ static int brcmf_sdbrcm_txpkt(struct brcmf_sdio *bus, struct sk_buff *pkt,
 
 #ifdef DEBUG
 	tx_packets[pkt->priority]++;
+#endif
 
 	brcmf_dbg_hex_dump(BRCMF_BYTES_ON() &&
 			   ((BRCMF_CTL_ON() && chan == SDPCM_CONTROL_CHANNEL) ||
@@ -2149,7 +2150,6 @@ static int brcmf_sdbrcm_txpkt(struct brcmf_sdio *bus, struct sk_buff *pkt,
 			       chan != SDPCM_CONTROL_CHANNEL))) &&
 			   BRCMF_HDRS_ON(),
 			   frame, min_t(u16, len, 16), "TxHdr:\n");
-#endif
 
 	/* Raise len to next SDIO block to eliminate tail command */
 	if (bus->roundup && bus->blocksize && (len > bus->blocksize)) {
@@ -2806,7 +2806,7 @@ static int brcmf_sdbrcm_readconsole(struct brcmf_sdio *bus)
 			if (line[n - 1] == '\r')
 				n--;
 			line[n] = 0;
-			printk(KERN_DEBUG "CONSOLE: %s\n", line);
+			pr_debug("CONSOLE: %s\n", line);
 		}
 	}
 break2:
@@ -3676,11 +3676,8 @@ brcmf_sdbrcm_probe_attach(struct brcmf_sdio *bus, u32 regsva)
 	if (brcmf_sdcard_set_sbaddr_window(bus->sdiodev, SI_ENUM_BASE))
 		brcmf_dbg(ERROR, "FAILED to return to SI_ENUM_BASE\n");
 
-#ifdef DEBUG
-	printk(KERN_DEBUG "F1 signature read @0x18000000=0x%4x\n",
-	       brcmf_sdcard_reg_read(bus->sdiodev, SI_ENUM_BASE, 4));
-
-#endif				/* DEBUG */
+	pr_debug("F1 signature read @0x18000000=0x%4x\n",
+		 brcmf_sdcard_reg_read(bus->sdiodev, SI_ENUM_BASE, 4));
 
 	/*
 	 * Force PLL off until brcmf_sdio_chip_attach()
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 3ae07bb..14ab606 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -5765,56 +5765,43 @@ int brcms_c_module_unregister(struct brcms_pub *pub, const char *name,
 	return -ENODATA;
 }
 
-#ifdef DEBUG
-static const char * const supr_reason[] = {
-	"None", "PMQ Entry", "Flush request",
-	"Previous frag failure", "Channel mismatch",
-	"Lifetime Expiry", "Underflow"
-};
-
-static void brcms_c_print_txs_status(u16 s)
-{
-	printk(KERN_DEBUG "[15:12]  %d  frame attempts\n",
-	       (s & TX_STATUS_FRM_RTX_MASK) >> TX_STATUS_FRM_RTX_SHIFT);
-	printk(KERN_DEBUG " [11:8]  %d  rts attempts\n",
-	       (s & TX_STATUS_RTS_RTX_MASK) >> TX_STATUS_RTS_RTX_SHIFT);
-	printk(KERN_DEBUG "    [7]  %d  PM mode indicated\n",
-	       ((s & TX_STATUS_PMINDCTD) ? 1 : 0));
-	printk(KERN_DEBUG "    [6]  %d  intermediate status\n",
-	       ((s & TX_STATUS_INTERMEDIATE) ? 1 : 0));
-	printk(KERN_DEBUG "    [5]  %d  AMPDU\n",
-	       (s & TX_STATUS_AMPDU) ? 1 : 0);
-	printk(KERN_DEBUG "  [4:2]  %d  Frame Suppressed Reason (%s)\n",
-	       ((s & TX_STATUS_SUPR_MASK) >> TX_STATUS_SUPR_SHIFT),
-	       supr_reason[(s & TX_STATUS_SUPR_MASK) >> TX_STATUS_SUPR_SHIFT]);
-	printk(KERN_DEBUG "    [1]  %d  acked\n",
-	       ((s & TX_STATUS_ACK_RCV) ? 1 : 0));
-}
-#endif				/* DEBUG */
-
 void brcms_c_print_txstatus(struct tx_status *txs)
 {
-#if defined(DEBUG)
-	u16 s = txs->status;
-	u16 ackphyrxsh = txs->ackphyrxsh;
-
-	printk(KERN_DEBUG "\ntxpkt (MPDU) Complete\n");
-
-	printk(KERN_DEBUG "FrameID: %04x   ", txs->frameid);
-	printk(KERN_DEBUG "TxStatus: %04x", s);
-	printk(KERN_DEBUG "\n");
-
-	brcms_c_print_txs_status(s);
-
-	printk(KERN_DEBUG "LastTxTime: %04x ", txs->lasttxtime);
-	printk(KERN_DEBUG "Seq: %04x ", txs->sequence);
-	printk(KERN_DEBUG "PHYTxStatus: %04x ", txs->phyerr);
-	printk(KERN_DEBUG "RxAckRSSI: %04x ",
-	       (ackphyrxsh & PRXS1_JSSI_MASK) >> PRXS1_JSSI_SHIFT);
-	printk(KERN_DEBUG "RxAckSQ: %04x",
-	       (ackphyrxsh & PRXS1_SQ_MASK) >> PRXS1_SQ_SHIFT);
-	printk(KERN_DEBUG "\n");
-#endif				/* defined(DEBUG) */
+	pr_debug("\ntxpkt (MPDU) Complete\n");
+
+	pr_debug("FrameID: %04x   TxStatus: %04x\n", txs->frameid, txs->status);
+
+	pr_debug("[15:12]  %d  frame attempts\n",
+		  (txs->status & TX_STATUS_FRM_RTX_MASK) >>
+		 TX_STATUS_FRM_RTX_SHIFT);
+	pr_debug(" [11:8]  %d  rts attempts\n",
+		 (txs->status & TX_STATUS_RTS_RTX_MASK) >>
+		 TX_STATUS_RTS_RTX_SHIFT);
+	pr_debug("    [7]  %d  PM mode indicated\n",
+		 txs->status & TX_STATUS_PMINDCTD ? 1 : 0);
+	pr_debug("    [6]  %d  intermediate status\n",
+		 txs->status & TX_STATUS_INTERMEDIATE ? 1 : 0);
+	pr_debug("    [5]  %d  AMPDU\n",
+		 txs->status & TX_STATUS_AMPDU ? 1 : 0);
+	pr_debug("  [4:2]  %d  Frame Suppressed Reason (%s)\n",
+		 (txs->status & TX_STATUS_SUPR_MASK) >> TX_STATUS_SUPR_SHIFT,
+		 (const char *[]) {
+			"None",
+			"PMQ Entry",
+			"Flush request",
+			"Previous frag failure",
+			"Channel mismatch",
+			"Lifetime Expiry",
+			"Underflow"
+		 } [(txs->status & TX_STATUS_SUPR_MASK) >>
+		    TX_STATUS_SUPR_SHIFT]);
+	pr_debug("    [1]  %d  acked\n",
+		 txs->status & TX_STATUS_ACK_RCV ? 1 : 0);
+
+	pr_debug("LastTxTime: %04x Seq: %04x PHYTxStatus: %04x RxAckRSSI: %04x RxAckSQ: %04x\n",
+		 txs->lasttxtime, txs->sequence, txs->phyerr,
+		 (txs->ackphyrxsh & PRXS1_JSSI_MASK) >> PRXS1_JSSI_SHIFT,
+		 (txs->ackphyrxsh & PRXS1_SQ_MASK) >> PRXS1_SQ_SHIFT);
 }
 
 bool brcms_c_chipmatch(u16 vendor, u16 device)
@@ -5871,53 +5858,53 @@ void brcms_c_print_txdesc(struct d11txh *txh)
 	struct ieee80211_rts rts = txh->rts_frame;
 
 	/* add plcp header along with txh descriptor */
-	printk(KERN_DEBUG "Raw TxDesc + plcp header:\n");
+	pr_debug("Raw TxDesc + plcp header:\n");
 	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
 			     txh, sizeof(struct d11txh) + 48);
 
-	printk(KERN_DEBUG "TxCtlLow: %04x ", mtcl);
-	printk(KERN_DEBUG "TxCtlHigh: %04x ", mtch);
-	printk(KERN_DEBUG "FC: %04x ", mfc);
-	printk(KERN_DEBUG "FES Time: %04x\n", tfest);
-	printk(KERN_DEBUG "PhyCtl: %04x%s ", ptcw,
+	pr_debug("TxCtlLow: %04x ", mtcl);
+	pr_debug("TxCtlHigh: %04x ", mtch);
+	pr_debug("FC: %04x ", mfc);
+	pr_debug("FES Time: %04x\n", tfest);
+	pr_debug("PhyCtl: %04x%s ", ptcw,
 	       (ptcw & PHY_TXC_SHORT_HDR) ? " short" : "");
-	printk(KERN_DEBUG "PhyCtl_1: %04x ", ptcw_1);
-	printk(KERN_DEBUG "PhyCtl_1_Fbr: %04x\n", ptcw_1_Fbr);
-	printk(KERN_DEBUG "PhyCtl_1_Rts: %04x ", ptcw_1_Rts);
-	printk(KERN_DEBUG "PhyCtl_1_Fbr_Rts: %04x\n", ptcw_1_FbrRts);
-	printk(KERN_DEBUG "MainRates: %04x ", mainrates);
-	printk(KERN_DEBUG "XtraFrameTypes: %04x ", xtraft);
-	printk(KERN_DEBUG "\n");
+	pr_debug("PhyCtl_1: %04x ", ptcw_1);
+	pr_debug("PhyCtl_1_Fbr: %04x\n", ptcw_1_Fbr);
+	pr_debug("PhyCtl_1_Rts: %04x ", ptcw_1_Rts);
+	pr_debug("PhyCtl_1_Fbr_Rts: %04x\n", ptcw_1_FbrRts);
+	pr_debug("MainRates: %04x ", mainrates);
+	pr_debug("XtraFrameTypes: %04x ", xtraft);
+	pr_debug("\n");
 
 	print_hex_dump_bytes("SecIV:", DUMP_PREFIX_OFFSET, iv, sizeof(txh->IV));
 	print_hex_dump_bytes("RA:", DUMP_PREFIX_OFFSET,
 			     ra, sizeof(txh->TxFrameRA));
 
-	printk(KERN_DEBUG "Fb FES Time: %04x ", tfestfb);
+	pr_debug("Fb FES Time: %04x ", tfestfb);
 	print_hex_dump_bytes("Fb RTS PLCP:", DUMP_PREFIX_OFFSET,
 			     rtspfb, sizeof(txh->RTSPLCPFallback));
-	printk(KERN_DEBUG "RTS DUR: %04x ", rtsdfb);
+	pr_debug("RTS DUR: %04x ", rtsdfb);
 	print_hex_dump_bytes("PLCP:", DUMP_PREFIX_OFFSET,
 			     fragpfb, sizeof(txh->FragPLCPFallback));
-	printk(KERN_DEBUG "DUR: %04x", fragdfb);
-	printk(KERN_DEBUG "\n");
+	pr_debug("DUR: %04x", fragdfb);
+	pr_debug("\n");
 
-	printk(KERN_DEBUG "MModeLen: %04x ", mmodelen);
-	printk(KERN_DEBUG "MModeFbrLen: %04x\n", mmodefbrlen);
+	pr_debug("MModeLen: %04x ", mmodelen);
+	pr_debug("MModeFbrLen: %04x\n", mmodefbrlen);
 
-	printk(KERN_DEBUG "FrameID:     %04x\n", tfid);
-	printk(KERN_DEBUG "TxStatus:    %04x\n", txs);
+	pr_debug("FrameID:     %04x\n", tfid);
+	pr_debug("TxStatus:    %04x\n", txs);
 
-	printk(KERN_DEBUG "MaxNumMpdu:  %04x\n", mnmpdu);
-	printk(KERN_DEBUG "MaxAggbyte:  %04x\n", mabyte);
-	printk(KERN_DEBUG "MaxAggbyte_fb:  %04x\n", mabyte_f);
-	printk(KERN_DEBUG "MinByte:     %04x\n", mmbyte);
+	pr_debug("MaxNumMpdu:  %04x\n", mnmpdu);
+	pr_debug("MaxAggbyte:  %04x\n", mabyte);
+	pr_debug("MaxAggbyte_fb:  %04x\n", mabyte_f);
+	pr_debug("MinByte:     %04x\n", mmbyte);
 
 	print_hex_dump_bytes("RTS PLCP:", DUMP_PREFIX_OFFSET,
 			     rtsph, sizeof(txh->RTSPhyHeader));
 	print_hex_dump_bytes("RTS Frame:", DUMP_PREFIX_OFFSET,
 			     (u8 *)&rts, sizeof(txh->rts_frame));
-	printk(KERN_DEBUG "\n");
+	pr_debug("\n");
 }
 #endif				/* defined(DEBUG) */
 
@@ -5999,7 +5986,7 @@ void brcms_c_print_rxh(struct d11rxhdr *rxh)
 		{0, NULL}
 	};
 
-	printk(KERN_DEBUG "Raw RxDesc:\n");
+	pr_debug("Raw RxDesc:\n");
 	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, rxh,
 			     sizeof(struct d11rxhdr));
 
@@ -6007,14 +5994,14 @@ void brcms_c_print_rxh(struct d11rxhdr *rxh)
 
 	snprintf(lenbuf, sizeof(lenbuf), "0x%x", len);
 
-	printk(KERN_DEBUG "RxFrameSize:     %6s (%d)%s\n", lenbuf, len,
+	pr_debug("RxFrameSize:     %6s (%d)%s\n", lenbuf, len,
 	       (rxh->PhyRxStatus_0 & PRXS0_SHORTH) ? " short preamble" : "");
-	printk(KERN_DEBUG "RxPHYStatus:     %04x %04x %04x %04x\n",
+	pr_debug("RxPHYStatus:     %04x %04x %04x %04x\n",
 	       phystatus_0, phystatus_1, phystatus_2, phystatus_3);
-	printk(KERN_DEBUG "RxMACStatus:     %x %s\n", macstatus1, flagstr);
-	printk(KERN_DEBUG "RXMACaggtype:    %x\n",
+	pr_debug("RxMACStatus:     %x %s\n", macstatus1, flagstr);
+	pr_debug("RXMACaggtype:    %x\n",
 	       (macstatus2 & RXS_AGGTYPE_MASK));
-	printk(KERN_DEBUG "RxTSFTime:       %04x\n", rxh->RxTSFTime);
+	pr_debug("RxTSFTime:       %04x\n", rxh->RxTSFTime);
 }
 #endif				/* defined(DEBUG) */
 
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.h b/drivers/net/wireless/brcm80211/brcmsmac/main.h
index 84a2a0d..8debc74 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.h
@@ -651,7 +651,9 @@ extern int brcms_b_xmtfifo_sz_get(struct brcms_hardware *wlc_hw, uint fifo,
 #if defined(DEBUG)
 extern void brcms_c_print_txdesc(struct d11txh *txh);
 #else
-#define brcms_c_print_txdesc(a)
+static inline void brcms_c_print_txdesc(struct d11txh *txh)
+{
+}
 #endif
 
 extern int brcms_c_set_gmode(struct brcms_c_info *wlc, u8 gmode, bool config);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
index a16f1ab..a0909be6 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
@@ -26434,8 +26434,7 @@ cal_try:
 	}
 
 	if (bcmerror != 0) {
-		printk(KERN_DEBUG "%s: Failed, cnt = %d\n", __func__,
-		       cal_retry);
+		pr_debug("%s: Failed, cnt = %d\n", __func__, cal_retry);
 
 		if (cal_retry < CAL_RETRY_CNT) {
 			cal_retry++;
diff --git a/drivers/net/wireless/brcm80211/brcmutil/utils.c b/drivers/net/wireless/brcm80211/brcmutil/utils.c
index 2207eaa..4908660 100644
--- a/drivers/net/wireless/brcm80211/brcmutil/utils.c
+++ b/drivers/net/wireless/brcm80211/brcmutil/utils.c
@@ -247,7 +247,7 @@ void brcmu_prpkt(const char *msg, struct sk_buff *p0)
 	struct sk_buff *p;
 
 	if (msg && (msg[0] != '\0'))
-		printk(KERN_DEBUG "%s:\n", msg);
+		pr_debug("%s:\n", msg);
 
 	for (p = p0; p; p = p->next)
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, p->data, p->len);
-- 
1.7.8.111.gad25c.dirty
