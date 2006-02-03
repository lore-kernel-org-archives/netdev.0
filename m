From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: [PATCH] acx: make firmware statistics parsing more intelligent
Date: Fri, 3 Feb 2006 11:58:57 +0100
Message-ID: <20060203105857.GB11173@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

Hi all,

this patch does:
- implement much more flexible firmware statistics parsing
  (for /proc/driver/acx_wlanX_diag)
  This has the nice effect that we now get output for both the older
  TNETW1100 USB and TNETW1450.
  Since firmware statistics information has non-stable layout depending on
  firmware version, please report if you suspect any parsing mismatch!
  This improved version now uses 2kB more driver space, unfortunately.
- use "% 8" modulo instead of more complicated "% 5" calculation
- use
    if (++idx >= count)
      idx = 0;
  instead of more bloaty
    idx = (idx + 1) % count;
  We might want to add a kernel macro for this *very* common and
  performance-critical driver operation, say ring_advance_next or so,
  in order to have the most optimized version for each architecture;
  Or ($1 million question): Is there already such a beast somewhere!?
- tiny cleanup

Andreas Mohr

diff -urN acx-20060202/acx_func.h acx-20060202_stats/acx_func.h
--- acx-20060202/acx_func.h	2006-02-01 10:49:31.000000000 +0100
+++ acx-20060202_stats/acx_func.h	2006-02-05 06:21:35.000000000 +0100
@@ -257,7 +257,7 @@
 **		but may be run under lock
 **
 ** A small number of local helpers do not have acx_[eisl]_ prefix.
-** They are always close to caller and are to be revieved locally.
+** They are always close to caller and are to be reviewed locally.
 **
 ** Theory of operation:
 **
diff -urN acx-20060202/acx_struct.h acx-20060202_stats/acx_struct.h
--- acx-20060202/acx_struct.h	2006-02-01 10:49:38.000000000 +0100
+++ acx-20060202_stats/acx_struct.h	2006-02-03 23:21:35.000000000 +0100
@@ -582,21 +582,34 @@
 
 
 /*--- Firmware statistics ----------------------------------------------------*/
-typedef struct fw_stats {
-	u32	val0x0 ACX_PACKED;		/* hdr; */
+
+/* define a random 100 bytes more to catch firmware versions which
+ * provide a bigger struct */
+#define FW_STATS_FUTURE_EXTENSION	100
+
+typedef struct fw_stats_tx {
 	u32	tx_desc_of ACX_PACKED;
+} fw_stats_tx_t;
+
+typedef struct fw_stats_rx {
 	u32	rx_oom ACX_PACKED;
 	u32	rx_hdr_of ACX_PACKED;
-	u32	rx_hdr_use_next ACX_PACKED;
+	u32	rx_hw_stuck ACX_PACKED; /* old: u32	rx_hdr_use_next */
 	u32	rx_dropped_frame ACX_PACKED;
 	u32	rx_frame_ptr_err ACX_PACKED;
 	u32	rx_xfr_hint_trig ACX_PACKED;
+	u32	rx_aci_events ACX_PACKED; /* later versions only */
+	u32	rx_aci_resets ACX_PACKED; /* later versions only */
+} fw_stats_rx_t;
 
+typedef struct fw_stats_dma {
 	u32	rx_dma_req ACX_PACKED;
 	u32	rx_dma_err ACX_PACKED;
 	u32	tx_dma_req ACX_PACKED;
 	u32	tx_dma_err ACX_PACKED;
+} fw_stats_dma_t;
 
+typedef struct fw_stats_irq {
 	u32	cmd_cplt ACX_PACKED;
 	u32	fiq ACX_PACKED;
 	u32	rx_hdrs ACX_PACKED;
@@ -604,23 +617,78 @@
 	u32	rx_mem_of ACX_PACKED;
 	u32	rx_rdys ACX_PACKED;
 	u32	irqs ACX_PACKED;
-	u32	acx_trans_procs ACX_PACKED;
+	u32	tx_procs ACX_PACKED;
 	u32	decrypt_done ACX_PACKED;
 	u32	dma_0_done ACX_PACKED;
 	u32	dma_1_done ACX_PACKED;
 	u32	tx_exch_complet ACX_PACKED;
 	u32	commands ACX_PACKED;
-	u32	acx_rx_procs ACX_PACKED;
+	u32	rx_procs ACX_PACKED;
 	u32	hw_pm_mode_changes ACX_PACKED;
 	u32	host_acks ACX_PACKED;
 	u32	pci_pm ACX_PACKED;
 	u32	acm_wakeups ACX_PACKED;
+} fw_stats_irq_t;
 
+typedef struct fw_stats_wep {
 	u32	wep_key_count ACX_PACKED;
 	u32	wep_default_key_count ACX_PACKED;
 	u32	dot11_def_key_mib ACX_PACKED;
 	u32	wep_key_not_found ACX_PACKED;
 	u32	wep_decrypt_fail ACX_PACKED;
+	u32	wep_pkt_decrypt ACX_PACKED;
+	u32	wep_decrypt_irqs ACX_PACKED;
+} fw_stats_wep_t;
+
+typedef struct fw_stats_pwr {
+	u32	tx_start_ctr ACX_PACKED;
+	u32	no_ps_tx_too_short ACX_PACKED;
+	u32	rx_start_ctr ACX_PACKED;
+	u32	no_ps_rx_too_short ACX_PACKED;
+	u32	lppd_started ACX_PACKED;
+	u32	no_lppd_too_noisy ACX_PACKED;
+	u32	no_lppd_too_short ACX_PACKED;
+	u32	no_lppd_matching_frame ACX_PACKED;
+} fw_stats_pwr_t;
+
+typedef struct fw_stats_mic {
+	u32 mic_rx_pkts ACX_PACKED;
+	u32 mic_calc_fail ACX_PACKED;
+} fw_stats_mic_t;
+
+typedef struct fw_stats_aes {
+	u32 aes_enc_fail ACX_PACKED;
+	u32 aes_dec_fail ACX_PACKED;
+	u32 aes_enc_pkts ACX_PACKED;
+	u32 aes_dec_pkts ACX_PACKED;
+	u32 aes_enc_irq ACX_PACKED;
+	u32 aes_dec_irq ACX_PACKED;
+} fw_stats_aes_t;
+
+typedef struct fw_stats_event {
+	u32 heartbeat ACX_PACKED;
+	u32 calibration ACX_PACKED;
+	u32 rx_mismatch ACX_PACKED;
+	u32 rx_mem_empty ACX_PACKED;
+	u32 rx_pool ACX_PACKED;
+	u32 oom_late ACX_PACKED;
+	u32 phy_tx_err ACX_PACKED;
+	u32 tx_stuck ACX_PACKED;
+} fw_stats_event_t;
+
+/* mainly for size calculation only */
+typedef struct fw_stats {
+	u16			type;
+	u16			len;
+	fw_stats_tx_t		tx;
+	fw_stats_rx_t		rx;
+	fw_stats_dma_t		dma;
+	fw_stats_irq_t		irq;
+	fw_stats_wep_t		wep;
+	fw_stats_pwr_t		pwr;
+	fw_stats_mic_t		mic;
+	fw_stats_aes_t		aes;
+	fw_stats_event_t	evt;
 } fw_stats_t;
 
 /* Firmware version struct */
diff -urN acx-20060202/common.c acx-20060202_stats/common.c
--- acx-20060202/common.c	2006-02-01 10:49:37.000000000 +0100
+++ acx-20060202_stats/common.c	2006-02-05 06:23:21.000000000 +0100
@@ -851,7 +851,7 @@
 	ACX1xx_IE_RXCONFIG_LEN,
 	0,
 	0,
-	ACX1xx_IE_FIRMWARE_STATISTICS_LEN,
+	sizeof(fw_stats_t)-4+FW_STATS_FUTURE_EXTENSION,
 	0,
 	ACX1xx_IE_FEATURE_CONFIG_LEN,
 	ACX111_IE_KEY_CHOOSE_LEN,
@@ -928,7 +928,7 @@
 	ACX1xx_IE_RXCONFIG_LEN,
 	0,
 	0,
-	ACX1xx_IE_FIRMWARE_STATISTICS_LEN,
+	sizeof(fw_stats_t)-4+FW_STATS_FUTURE_EXTENSION,
 	0,
 	ACX1xx_IE_FEATURE_CONFIG_LEN,
 	ACX111_IE_KEY_CHOOSE_LEN,
@@ -1148,20 +1148,27 @@
 acx_s_proc_diag_output(char *buf, acx_device_t *adev)
 {
 	char *p = buf;
-	fw_stats_t *fw_stats;
 	unsigned long flags;
+	unsigned int len = 0, partlen;
+	u32 temp1, temp2;
+	u8 *st, *st_end;
+#ifdef __BIG_ENDIAN
+	u8 *st2;
+#endif
+	fw_stats_t *fw_stats;
+	char *part_str = NULL;
+	fw_stats_tx_t *tx = NULL;
+	fw_stats_rx_t *rx = NULL;
+	fw_stats_dma_t *dma = NULL;
+	fw_stats_irq_t *irq = NULL;
+	fw_stats_wep_t *wep = NULL;
+	fw_stats_pwr_t *pwr = NULL;
+	fw_stats_mic_t *mic = NULL;
+	fw_stats_aes_t *aes = NULL;
+	fw_stats_event_t *evt = NULL;
 
 	FN_ENTER;
 
-	/* TODO: may replace kmalloc/memset with kzalloc once
-	 * Linux 2.6.14 is widespread */
-	fw_stats = kmalloc(sizeof(*fw_stats), GFP_KERNEL);
-	if (!fw_stats) {
-		FN_EXIT1(0);
-		return 0;
-	}
-	memset(fw_stats, 0, sizeof(*fw_stats));
-
 	acx_lock(adev, flags);
 
 	if (IS_PCI(adev))
@@ -1205,63 +1212,322 @@
 
 	acx_unlock(adev, flags);
 
-	if (OK != acx_s_interrogate(adev, fw_stats, ACX1xx_IE_FIRMWARE_STATISTICS))
-		p += sprintf(p,
-			"\n"
-			"** Firmware **\n"
-			"QUERY FAILED!!\n");
-	else {
-		p += sprintf(p,
-			"\n"
-			"** Firmware **\n"
-			"version \"%s\"\n"
-			"tx_desc_overfl %u, rx_OutOfMem %u, rx_hdr_overfl %u, rx_hdr_use_next %u\n"
-			"rx_dropped_frame %u, rx_frame_ptr_err %u, rx_xfr_hint_trig %u, rx_dma_req %u\n"
-			"rx_dma_err %u, tx_dma_req %u, tx_dma_err %u, cmd_cplt %u, fiq %u\n"
-			"rx_hdrs %u, rx_cmplt %u, rx_mem_overfl %u, rx_rdys %u, irqs %u\n"
-			"acx_trans_procs %u, decrypt_done %u, dma_0_done %u, dma_1_done %u\n",
-			adev->firmware_version,
-			le32_to_cpu(fw_stats->tx_desc_of),
-			le32_to_cpu(fw_stats->rx_oom),
-			le32_to_cpu(fw_stats->rx_hdr_of),
-			le32_to_cpu(fw_stats->rx_hdr_use_next),
-			le32_to_cpu(fw_stats->rx_dropped_frame),
-			le32_to_cpu(fw_stats->rx_frame_ptr_err),
-			le32_to_cpu(fw_stats->rx_xfr_hint_trig),
-			le32_to_cpu(fw_stats->rx_dma_req),
-			le32_to_cpu(fw_stats->rx_dma_err),
-			le32_to_cpu(fw_stats->tx_dma_req),
-			le32_to_cpu(fw_stats->tx_dma_err),
-			le32_to_cpu(fw_stats->cmd_cplt),
-			le32_to_cpu(fw_stats->fiq),
-			le32_to_cpu(fw_stats->rx_hdrs),
-			le32_to_cpu(fw_stats->rx_cmplt),
-			le32_to_cpu(fw_stats->rx_mem_of),
-			le32_to_cpu(fw_stats->rx_rdys),
-			le32_to_cpu(fw_stats->irqs),
-			le32_to_cpu(fw_stats->acx_trans_procs),
-			le32_to_cpu(fw_stats->decrypt_done),
-			le32_to_cpu(fw_stats->dma_0_done),
-			le32_to_cpu(fw_stats->dma_1_done));
+	p += sprintf(p,
+		"\n"
+		"** Firmware **\n"
+		"NOTE: version dependent statistics layout, "
+		"please report if you suspect wrong parsing!\n"
+		"\n"
+		"version \"%s\"\n", adev->firmware_version);
+
+	/* TODO: may replace kmalloc/memset with kzalloc once
+	 * Linux 2.6.14 is widespread */
+	fw_stats = kmalloc(sizeof(*fw_stats)+FW_STATS_FUTURE_EXTENSION, GFP_KERNEL);
+	if (!fw_stats) {
+		FN_EXIT1(0);
+		return 0;
+	}
+	memset(fw_stats, 0, sizeof(*fw_stats)+FW_STATS_FUTURE_EXTENSION);
+
+	st = (u8 *)fw_stats;
+
+	part_str = "statistics query command";
+
+	if (OK != acx_s_interrogate(adev, st, ACX1xx_IE_FIRMWARE_STATISTICS))
+		goto fw_stats_end;
+
+	st += sizeof(u16);
+	len = *(u16 *)st;
+
+	if (len > sizeof(*fw_stats)) {
 		p += sprintf(p,
-			"tx_exch_complet %u, commands %u, acx_rx_procs %u\n"
-			"hw_pm_mode_changes %u, host_acks %u, pci_pm %u, acm_wakeups %u\n"
-			"wep_key_count %u, wep_default_key_count %u, dot11_def_key_mib %u\n"
-			"wep_key_not_found %u, wep_decrypt_fail %u\n",
-			le32_to_cpu(fw_stats->tx_exch_complet),
-			le32_to_cpu(fw_stats->commands),
-			le32_to_cpu(fw_stats->acx_rx_procs),
-			le32_to_cpu(fw_stats->hw_pm_mode_changes),
-			le32_to_cpu(fw_stats->host_acks),
-			le32_to_cpu(fw_stats->pci_pm),
-			le32_to_cpu(fw_stats->acm_wakeups),
-			le32_to_cpu(fw_stats->wep_key_count),
-			le32_to_cpu(fw_stats->wep_default_key_count),
-			le32_to_cpu(fw_stats->dot11_def_key_mib),
-			le32_to_cpu(fw_stats->wep_key_not_found),
-			le32_to_cpu(fw_stats->wep_decrypt_fail));
+			"firmware version with bigger fw_stats struct detected\n"
+			"(%u vs. %u), PLEASE REPORT!!\n", len, sizeof(fw_stats_t));
+		if (len > sizeof(*fw_stats)+FW_STATS_FUTURE_EXTENSION) {
+			p += sprintf(p, "struct size exceeded allocation!\n");
+			len = sizeof(*fw_stats)+FW_STATS_FUTURE_EXTENSION;
+		}
+	}
+	st += sizeof(u16);
+	st_end = st - 2*sizeof(u16) + len;
+
+#ifdef __BIG_ENDIAN
+	/* let's make one bold assumption here:
+	 * (hopefully!) *all* statistics fields are u32 only,
+	 * thus if we need to make endianness corrections
+	 * we can simply do them in one go, in advance */
+	st2 = (u8 *)fw_stats;
+	for (temp1 = 0; temp1 < len; temp1 += 4, st2 += 4)
+		*(u32 *)st2 = le32_to_cpu(*(u32 *)st2);
+#endif
+
+	part_str = "Rx/Tx";
+
+	/* directly at end of a struct part? --> no error! */
+	if (st == st_end)
+		goto fw_stats_end;
+
+	tx = (fw_stats_tx_t *)st;
+	st += sizeof(fw_stats_tx_t);
+	rx = (fw_stats_rx_t *)st;
+	st += sizeof(fw_stats_rx_t);
+	partlen = sizeof(fw_stats_tx_t) + sizeof(fw_stats_rx_t);
+
+	if (
+	    (IS_PCI(adev) && IS_ACX100(adev))
+	||  (IS_USB(adev) && IS_ACX100(adev))
+	) {
+		/* at least ACX100 PCI F/W 1.9.8.b
+		 * and ACX100 USB F/W 1.0.7-USB
+		 * don't have those two fields... */
+		st -= 2*sizeof(u32);
+
+		/* our parsing doesn't quite match this firmware yet,
+	 	 * log failure */
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = temp2 = 999999999;
+	} else {
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = rx->rx_aci_events;
+		temp2 = rx->rx_aci_resets;
 	}
 
+	p += sprintf(p,
+		"%s:\n"
+		"  tx_desc_overfl %u\n"
+		"  rx_OutOfMem %u, rx_hdr_overfl %u, rx_hw_stuck %u\n"
+		"  rx_dropped_frame %u, rx_frame_ptr_err %u, rx_xfr_hint_trig %u\n"
+		"  rx_aci_events %u, rx_aci_resets %u\n",
+		part_str,
+		tx->tx_desc_of,
+		rx->rx_oom,
+		rx->rx_hdr_of,
+		rx->rx_hw_stuck,
+		rx->rx_dropped_frame,
+		rx->rx_frame_ptr_err,
+		rx->rx_xfr_hint_trig,
+		temp1,
+		temp2);
+
+	part_str = "DMA";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	dma = (fw_stats_dma_t *)st;
+	partlen = sizeof(fw_stats_dma_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  rx_dma_req %u, rx_dma_err %u, tx_dma_req %u, tx_dma_err %u\n",
+		part_str,
+		dma->rx_dma_req,
+		dma->rx_dma_err,
+		dma->tx_dma_req,
+		dma->tx_dma_err);
+
+	part_str = "IRQ";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	irq = (fw_stats_irq_t *)st;
+	partlen = sizeof(fw_stats_irq_t);
+	st += partlen;
+	
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  cmd_cplt %u, fiq %u\n"
+		"  rx_hdrs %u, rx_cmplt %u, rx_mem_overfl %u, rx_rdys %u\n"
+		"  irqs %u, tx_procs %u, decrypt_done %u\n"
+		"  dma_0_done %u, dma_1_done %u, tx_exch_complet %u\n"
+		"  commands %u, rx_procs %u, hw_pm_mode_changes %u\n"
+		"  host_acks %u, pci_pm %u, acm_wakeups %u\n",
+		part_str,
+		irq->cmd_cplt,
+		irq->fiq,
+		irq->rx_hdrs,
+		irq->rx_cmplt,
+		irq->rx_mem_of,
+		irq->rx_rdys,
+		irq->irqs,
+		irq->tx_procs,
+		irq->decrypt_done,
+		irq->dma_0_done,
+		irq->dma_1_done,
+		irq->tx_exch_complet,
+		irq->commands,
+		irq->rx_procs,
+		irq->hw_pm_mode_changes,
+		irq->host_acks,
+		irq->pci_pm,
+		irq->acm_wakeups);
+
+	part_str = "WEP";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	wep = (fw_stats_wep_t *)st;
+	partlen = sizeof(fw_stats_wep_t);
+	st += partlen;
+	
+	if (
+	    (IS_PCI(adev) && IS_ACX100(adev))
+	||  (IS_USB(adev) && IS_ACX100(adev))
+	) {
+		/* at least ACX100 PCI F/W 1.9.8.b
+		 * and ACX100 USB F/W 1.0.7-USB
+		 * don't have those two fields... */
+		st -= 2*sizeof(u32);
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = temp2 = 999999999;
+	} else {
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = wep->wep_pkt_decrypt;
+		temp2 = wep->wep_decrypt_irqs;
+	}
+
+	p += sprintf(p,
+		"%s:\n"
+		"  wep_key_count %u, wep_default_key_count %u, dot11_def_key_mib %u\n"
+		"  wep_key_not_found %u, wep_decrypt_fail %u\n"
+		"  wep_pkt_decrypt %u, wep_decrypt_irqs %u\n",
+		part_str,
+		wep->wep_key_count,
+		wep->wep_default_key_count,
+		wep->dot11_def_key_mib,
+		wep->wep_key_not_found,
+		wep->wep_decrypt_fail,
+		temp1,
+		temp2);
+
+	part_str = "power";
+	
+	if (st == st_end)
+		goto fw_stats_end;
+
+	pwr = (fw_stats_pwr_t *)st;
+	partlen = sizeof(fw_stats_pwr_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  tx_start_ctr %u, no_ps_tx_too_short %u\n"
+		"  rx_start_ctr %u, no_ps_rx_too_short %u\n"
+		"  lppd_started %u\n"
+		"  no_lppd_too_noisy %u, no_lppd_too_short %u, no_lppd_matching_frame %u\n",
+		part_str,
+		pwr->tx_start_ctr,
+		pwr->no_ps_tx_too_short,
+		pwr->rx_start_ctr,
+		pwr->no_ps_rx_too_short,
+		pwr->lppd_started,
+		pwr->no_lppd_too_noisy,
+		pwr->no_lppd_too_short,
+		pwr->no_lppd_matching_frame);
+
+	part_str = "MIC";
+	
+	if (st == st_end)
+		goto fw_stats_end;
+
+	mic = (fw_stats_mic_t *)st;
+	partlen = sizeof(fw_stats_mic_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  mic_rx_pkts %u, mic_calc_fail %u\n",
+		part_str,
+		mic->mic_rx_pkts,
+		mic->mic_calc_fail);
+	
+	part_str = "AES";
+	
+	if (st == st_end)
+		goto fw_stats_end;
+
+	aes = (fw_stats_aes_t *)st;
+	partlen = sizeof(fw_stats_aes_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  aes_enc_fail %u, aes_dec_fail %u\n"
+		"  aes_enc_pkts %u, aes_dec_pkts %u\n"
+		"  aes_enc_irq %u, aes_dec_irq %u\n",
+		part_str,
+		aes->aes_enc_fail,
+		aes->aes_dec_fail,
+		aes->aes_enc_pkts,
+		aes->aes_dec_pkts,
+		aes->aes_enc_irq,
+		aes->aes_dec_irq);
+
+	part_str = "event";
+	
+	if (st == st_end)
+		goto fw_stats_end;
+
+	evt = (fw_stats_event_t *)st;
+	partlen = sizeof(fw_stats_event_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  heartbeat %u, calibration %u\n"
+		"  rx_mismatch %u, rx_mem_empty %u, rx_pool %u\n"
+		"  oom_late %u\n"
+		"  phy_tx_err %u, tx_stuck %u\n",
+		part_str,
+		evt->heartbeat,
+		evt->calibration,
+		evt->rx_mismatch,
+		evt->rx_mem_empty,
+		evt->rx_pool,
+		evt->oom_late,
+		evt->phy_tx_err,
+		evt->tx_stuck);
+
+	if (st < st_end)
+		goto fw_stats_bigger;
+
+	goto fw_stats_end;
+
+fw_stats_fail:
+	st -= partlen;
+	p += sprintf(p,
+		"failed at %s part (size %u), offset %u (struct size %u), PLEASE REPORT!\n", part_str, partlen, (int)st - (int)fw_stats, len);
+fw_stats_bigger:
+	for (; st < st_end; st += 4)
+		p += sprintf(p,
+			"UNKN%3d: %u\n", (int)st - (int)fw_stats, *(u32 *)st);
+	
+fw_stats_end:
 	kfree(fw_stats);
 
 	FN_EXIT1(p - buf);
diff -urN acx-20060202/pci.c acx-20060202_stats/pci.c
--- acx-20060202/pci.c	2006-02-01 10:49:33.000000000 +0100
+++ acx-20060202_stats/pci.c	2006-02-04 19:30:29.000000000 +0100
@@ -1058,13 +1058,13 @@
 		/* Test for IDLE state */
 		if (!cmd_status)
 			break;
-		if (counter % 5 == 0) {
+		if (counter % 8 == 0) {
 			if (time_after(jiffies, timeout)) {
 				counter = 0;
 				break;
 			}
-			/* we waited 5 iterations, no luck. Sleep 5 ms */
-			acx_s_msleep(5);
+			/* we waited 8 iterations, no luck. Sleep 8 ms */
+			acx_s_msleep(8);
 		}
 	} while (likely(--counter));
 
@@ -1124,13 +1124,13 @@
 				break;
 		}
 
-		if (counter % 5 == 0) {
+		if (counter % 8 == 0) {
 			if (time_after(jiffies, timeout)) {
 				counter = 0;
 				break;
 			}
-			/* we waited 5 iterations, no luck. Sleep 5 ms */
-			acx_s_msleep(5);
+			/* we waited 8 iterations, no luck. Sleep 8 ms */
+			acx_s_msleep(8);
 		}
 	} while (likely(--counter));
 
@@ -2307,7 +2307,9 @@
 	while (1) {
 		hostdesc = &adev->rxhostdesc_start[tail];
 		/* advance tail regardless of outcome of the below test */
-		tail = (tail + 1) % RX_CNT;
+		/* smaller/less writes than: tail = (tail + 1) % RX_CNT; */
+		if (++tail >= RX_CNT)
+			tail = 0;
 
 		if ((hostdesc->Ctl_16 & cpu_to_le16(DESC_CTL_HOSTOWN))
 		 && (hostdesc->Status & cpu_to_le32(DESC_STATUS_FULL)))
@@ -2338,7 +2340,9 @@
 		 || !(hostdesc->Status & cpu_to_le32(DESC_STATUS_FULL)))
 			break;
 
-		tail = (tail + 1) % RX_CNT;
+		/* slower: tail = (tail + 1) % RX_CNT; */
+		if (++tail >= RX_CNT)
+			tail = 0;
 	}
 end:
 	adev->rx_tail = tail;
@@ -3065,7 +3069,10 @@
 	}
 
 	/* returning current descriptor, so advance to next free one */
-	adev->tx_head = (head + 1) % TX_CNT;
+	/* slower: adev->tx_head = (head + 1) % TX_CNT; */
+	adev->tx_head = head + 1;
+	if (adev->tx_head >= TX_CNT)
+		adev->tx_head = 0;
 end:
 	FN_EXIT0;
 
@@ -3497,7 +3504,9 @@
 				finger, ack_failures, rts_failures, rts_ok, r100);
 
 		/* update pointer for descr to be cleaned next */
-		finger = (finger + 1) % TX_CNT;
+		/* slower: finger = (finger + 1) % TX_CNT; */
+		if (++finger >= TX_CNT)
+			finger = 0;
 	}
 
 	/* remember last position */
diff -urN acx-20060202/usb.c acx-20060202_stats/usb.c
--- acx-20060202/usb.c	2006-02-01 10:49:34.000000000 +0100
+++ acx-20060202_stats/usb.c	2006-02-03 10:24:07.000000000 +0100
@@ -1576,7 +1576,10 @@
 
 	head = adev->tx_head;
 	do {
-		head = (head + 1) % ACX_TX_URB_CNT;
+		/* slower: head = (head + 1) % ACX_TX_URB_CNT; */
+		if (++head >= ACX_TX_URB_CNT)
+			head = 0;
+
 		if (!adev->usb_tx[head].busy) {
 			log(L_USBRXTX, "allocated tx %d\n", head);
 			tx = &adev->usb_tx[head];


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
