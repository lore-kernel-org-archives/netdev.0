From: Joe Perches <joe@perches.com>
Subject: [PATCH] skfp: hwmtm: Use proper logging macros, correct mismatches
Date: Wed, 21 Dec 2016 16:41:52 -0800
Message-ID: <8e5313732124084fd2084df874eed70f8f1af810.1482367105.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Colin King <colin.king@canonical.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Logging macros should allow format and argument validation.
The DB_TX, DB_RX, and DB_GEN macros did not.

Update the macros and uses and add no_printk validation to the
previously compiled away #ifndef DEBUG variants.

Done with coccinelle and some typing.

Signed-off-by: Joe Perches <joe@perches.com>
---

Compile tested DEBUG and non-DEBUG only, no hardware

 drivers/net/fddi/skfp/h/hwmtm.h |  24 ++++--
 drivers/net/fddi/skfp/hwmtm.c   | 176 ++++++++++++++++++++--------------------
 2 files changed, 106 insertions(+), 94 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/hwmtm.h b/drivers/net/fddi/skfp/h/hwmtm.h
index 4ca2341d7f06..123cfa09c354 100644
--- a/drivers/net/fddi/skfp/h/hwmtm.h
+++ b/drivers/net/fddi/skfp/h/hwmtm.h
@@ -168,13 +168,25 @@ struct os_debug {
 #define DB_P	debug
 #endif
 
-#define DB_RX(a,b,c,lev) if (DB_P.d_os.hwm_rx >= (lev))	printf(a,b,c)
-#define DB_TX(a,b,c,lev) if (DB_P.d_os.hwm_tx >= (lev))	printf(a,b,c)
-#define DB_GEN(a,b,c,lev) if (DB_P.d_os.hwm_gen >= (lev)) printf(a,b,c)
+#define DB_RX(lev, fmt, ...)						\
+do {									\
+	if (DB_P.d_os.hwm_rx >= (lev))					\
+		printf(fmt "\n", ##__VA_ARGS__);			\
+} while (0)
+#define DB_TX(lev, fmt, ...)						\
+do {									\
+	if (DB_P.d_os.hwm_tx >= (lev))					\
+		printf(fmt "\n", ##__VA_ARGS__);			\
+} while (0)
+#define DB_GEN(lev, fmt, ...)						\
+do {									\
+	if (DB_P.d_os.hwm_gen >= (lev))					\
+		printf(fmt "\n", ##__VA_ARGS__);			\
+} while (0)
 #else	/* DEBUG */
-#define DB_RX(a,b,c,lev)
-#define DB_TX(a,b,c,lev)
-#define DB_GEN(a,b,c,lev)
+#define DB_RX(lev, fmt, ...)	no_printk(fmt "\n", ##__VA_ARGS__)
+#define DB_TX(lev, fmt, ...)	no_printk(fmt "\n", ##__VA_ARGS__)
+#define DB_GEN(lev, fmt, ...)	no_printk(fmt "\n", ##__VA_ARGS__)
 #endif	/* DEBUG */
 
 #ifndef	SK_BREAK
diff --git a/drivers/net/fddi/skfp/hwmtm.c b/drivers/net/fddi/skfp/hwmtm.c
index d0a68bdd5f63..4937d36a9e1c 100644
--- a/drivers/net/fddi/skfp/hwmtm.c
+++ b/drivers/net/fddi/skfp/hwmtm.c
@@ -330,7 +330,7 @@ static u_long init_descr_ring(struct s_smc *smc,
 	union s_fp_descr volatile *d2 ;
 	u_long	phys ;
 
-	DB_GEN("descr ring starts at = %x ",(void *)start,0,3) ;
+	DB_GEN(3, "descr ring starts at = %p", start);
 	for (i=count-1, d1=start; i ; i--) {
 		d2 = d1 ;
 		d1++ ;		/* descr is owned by the host */
@@ -339,7 +339,7 @@ static u_long init_descr_ring(struct s_smc *smc,
 		phys = mac_drv_virt2phys(smc,(void *)d1) ;
 		d2->r.rxd_nrdadr = cpu_to_le32(phys) ;
 	}
-	DB_GEN("descr ring ends at = %x ",(void *)d1,0,3) ;
+	DB_GEN(3, "descr ring ends at = %p", d1);
 	d1->r.rxd_rbctrl = cpu_to_le32(BMU_CHECK) ;
 	d1->r.rxd_next = &start->r ;
 	phys = mac_drv_virt2phys(smc,(void *)start) ;
@@ -364,7 +364,7 @@ static void init_txd_ring(struct s_smc *smc)
 	ds = (struct s_smt_fp_txd volatile *) ((char *)smc->os.hwm.descr_p +
 		SMT_R1_RXD_COUNT*sizeof(struct s_smt_fp_rxd)) ;
 	queue = smc->hw.fp.tx[QUEUE_A0] ;
-	DB_GEN("Init async TxD ring, %d TxDs ",HWM_ASYNC_TXD_COUNT,0,3) ;
+	DB_GEN(3, "Init async TxD ring, %d TxDs", HWM_ASYNC_TXD_COUNT);
 	(void)init_descr_ring(smc,(union s_fp_descr volatile *)ds,
 		HWM_ASYNC_TXD_COUNT) ;
 	phys = le32_to_cpu(ds->txd_ntdadr) ;
@@ -378,7 +378,7 @@ static void init_txd_ring(struct s_smc *smc)
 	ds = (struct s_smt_fp_txd volatile *) ((char *)ds +
 		HWM_ASYNC_TXD_COUNT*sizeof(struct s_smt_fp_txd)) ;
 	queue = smc->hw.fp.tx[QUEUE_S] ;
-	DB_GEN("Init sync TxD ring, %d TxDs ",HWM_SYNC_TXD_COUNT,0,3) ;
+	DB_GEN(3, "Init sync TxD ring, %d TxDs", HWM_SYNC_TXD_COUNT);
 	(void)init_descr_ring(smc,(union s_fp_descr volatile *)ds,
 		HWM_SYNC_TXD_COUNT) ;
 	phys = le32_to_cpu(ds->txd_ntdadr) ;
@@ -400,7 +400,7 @@ static void init_rxd_ring(struct s_smc *smc)
 	 */
 	ds = (struct s_smt_fp_rxd volatile *) smc->os.hwm.descr_p ;
 	queue = smc->hw.fp.rx[QUEUE_R1] ;
-	DB_GEN("Init RxD ring, %d RxDs ",SMT_R1_RXD_COUNT,0,3) ;
+	DB_GEN(3, "Init RxD ring, %d RxDs", SMT_R1_RXD_COUNT);
 	(void)init_descr_ring(smc,(union s_fp_descr volatile *)ds,
 		SMT_R1_RXD_COUNT) ;
 	phys = le32_to_cpu(ds->rxd_nrdadr) ;
@@ -469,11 +469,11 @@ void init_fddi_driver(struct s_smc *smc, u_char *mac_addr)
 	 */
 	i = 16 - ((long)smc->os.hwm.descr_p & 0xf) ;
 	if (i != 16) {
-		DB_GEN("i = %d",i,0,3) ;
+		DB_GEN(3, "i = %d", i);
 		smc->os.hwm.descr_p = (union s_fp_descr volatile *)
 			((char *)smc->os.hwm.descr_p+i) ;
 	}
-	DB_GEN("pt to descr area = %x",(void *)smc->os.hwm.descr_p,0,3) ;
+	DB_GEN(3, "pt to descr area = %p", smc->os.hwm.descr_p);
 
 	init_txd_ring(smc) ;
 	init_rxd_ring(smc) ;
@@ -501,7 +501,7 @@ SMbuf *smt_get_mbuf(struct s_smc *smc)
 		mb->sm_off = 8 ;
 		mb->sm_use_count = 1 ;
 	}
-	DB_GEN("get SMbuf: mb = %x",(void *)mb,0,3) ;
+	DB_GEN(3, "get SMbuf: mb = %p", mb);
 	return mb;	/* May be NULL */
 }
 
@@ -510,14 +510,14 @@ void smt_free_mbuf(struct s_smc *smc, SMbuf *mb)
 
 	if (mb) {
 		mb->sm_use_count-- ;
-		DB_GEN("free_mbuf: sm_use_count = %d",mb->sm_use_count,0,3) ;
+		DB_GEN(3, "free_mbuf: sm_use_count = %d", mb->sm_use_count);
 		/*
 		 * If the use_count is != zero the MBuf is queued
 		 * more than once and must not queued into the
 		 * free MBuf queue
 		 */
 		if (!mb->sm_use_count) {
-			DB_GEN("free SMbuf: mb = %x",(void *)mb,0,3) ;
+			DB_GEN(3, "free SMbuf: mb = %p", mb);
 #ifndef	COMMON_MB_POOL
 			mb->sm_next = smc->os.hwm.mbuf_pool.mb_free ;
 			smc->os.hwm.mbuf_pool.mb_free = mb ;
@@ -741,7 +741,7 @@ void fddi_isr(struct s_smc *smc)
 
 	while ((is = GET_ISR() & ISR_MASK)) {
 		NDD_TRACE("CH0B",is,0,0) ;
-		DB_GEN("ISA = 0x%x",is,0,7) ;
+		DB_GEN(7, "ISA = 0x%lx", is);
 
 		if (is & IMASK_SLOW) {
 			NDD_TRACE("CH1b",is,0,0) ;
@@ -754,20 +754,20 @@ void fddi_isr(struct s_smc *smc)
 			if (is & IS_MINTR1) {	/* FORMAC+ STU1(U/L) */
 				stu = inpw(FM_A(FM_ST1U)) ;
 				stl = inpw(FM_A(FM_ST1L)) ;
-				DB_GEN("Slow transmit complete",0,0,6) ;
+				DB_GEN(6, "Slow transmit complete");
 				mac1_irq(smc,stu,stl) ;
 			}
 			if (is & IS_MINTR2) {	/* FORMAC+ STU2(U/L) */
 				stu= inpw(FM_A(FM_ST2U)) ;
 				stl= inpw(FM_A(FM_ST2L)) ;
-				DB_GEN("Slow receive complete",0,0,6) ;
-				DB_GEN("stl = %x : stu = %x",stl,stu,7) ;
+				DB_GEN(6, "Slow receive complete");
+				DB_GEN(7, "stl = %x : stu = %x", stl, stu);
 				mac2_irq(smc,stu,stl) ;
 			}
 			if (is & IS_MINTR3) {	/* FORMAC+ STU3(U/L) */
 				stu= inpw(FM_A(FM_ST3U)) ;
 				stl= inpw(FM_A(FM_ST3L)) ;
-				DB_GEN("FORMAC Mode Register 3",0,0,6) ;
+				DB_GEN(6, "FORMAC Mode Register 3");
 				mac3_irq(smc,stu,stl) ;
 			}
 			if (is & IS_TIMINT) {	/* Timer 82C54-2 */
@@ -814,7 +814,7 @@ void fddi_isr(struct s_smc *smc)
 		 *	Fast Tx complete Async/Sync Queue (BMU service)
 		 */
 		if (is & (IS_XS_F|IS_XA_F)) {
-			DB_GEN("Fast tx complete queue",0,0,6) ;
+			DB_GEN(6, "Fast tx complete queue");
 			/*
 			 * clear IRQ, Note: no IRQ is lost, because
 			 * 	we always service both queues
@@ -829,7 +829,7 @@ void fddi_isr(struct s_smc *smc)
 		 *	Fast Rx Complete (BMU service)
 		 */
 		if (is & IS_R1_F) {
-			DB_GEN("Fast receive complete",0,0,6) ;
+			DB_GEN(6, "Fast receive complete");
 			/* clear IRQ */
 #ifndef USE_BREAK_ISR
 			outpd(ADDR(B4_R1_CSR),CSR_IRQ_CL_F) ;
@@ -1083,13 +1083,13 @@ void process_receive(struct s_smc *smc)
 #endif
 		n = 0 ;
 		do {
-			DB_RX("Check RxD %x for OWN and EOF",(void *)r,0,5) ;
+			DB_RX(5, "Check RxD %p for OWN and EOF", r);
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
 			rbctrl = le32_to_cpu(CR_READ(r->rxd_rbctrl));
 
 			if (rbctrl & BMU_OWN) {
 				NDD_TRACE("RHxE",r,rfsw,rbctrl) ;
-				DB_RX("End of RxDs",0,0,4) ;
+				DB_RX(4, "End of RxDs");
 				goto rx_end ;
 			}
 			/*
@@ -1136,19 +1136,19 @@ void process_receive(struct s_smc *smc)
 			rx_used-- ;
 		} while (!(rbctrl & BMU_EOF)) ;
 		used_frags = frag_count ;
-		DB_RX("EOF set in RxD, used_frags = %d ",used_frags,0,5) ;
+		DB_RX(5, "EOF set in RxD, used_frags = %d", used_frags);
 
 		/* may be next 2 DRV_BUF_FLUSH() can be skipped, because */
 		/* BMU_ST_BUF will not be changed by the ASIC */
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
 		while (rx_used && !(r->rxd_rbctrl & cpu_to_le32(BMU_ST_BUF))) {
-			DB_RX("Check STF bit in %x",(void *)r,0,5) ;
+			DB_RX(5, "Check STF bit in %p", r);
 			r = r->rxd_next ;
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
 			frag_count++ ;
 			rx_used-- ;
 		}
-		DB_RX("STF bit found",0,0,5) ;
+		DB_RX(5, "STF bit found");
 
 		/*
 		 * The received frame is finished for the process receive
@@ -1164,7 +1164,7 @@ void process_receive(struct s_smc *smc)
 		rxd->rxd_rbctrl &= cpu_to_le32(~BMU_STF) ;
 
 		for (r=rxd, i=frag_count ; i ; r=r->rxd_next, i--){
-			DB_RX("dma_complete for RxD %x",(void *)r,0,5) ;
+			DB_RX(5, "dma_complete for RxD %p", r);
 			dma_complete(smc,(union s_fp_descr volatile *)r,DMA_WR);
 		}
 		smc->hw.fp.err_stats.err_valid++ ;
@@ -1173,34 +1173,34 @@ void process_receive(struct s_smc *smc)
 		/* the length of the data including the FC */
 		len = (rfsw & RD_LENGTH) - 4 ;
 
-		DB_RX("frame length = %d",len,0,4) ;
+		DB_RX(4, "frame length = %d", len);
 		/*
 		 * check the frame_length and all error flags
 		 */
 		if (rfsw & (RX_MSRABT|RX_FS_E|RX_FS_CRC|RX_FS_IMPL)){
 			if (rfsw & RD_S_MSRABT) {
-				DB_RX("Frame aborted by the FORMAC",0,0,2) ;
+				DB_RX(2, "Frame aborted by the FORMAC");
 				smc->hw.fp.err_stats.err_abort++ ;
 			}
 			/*
 			 * check frame status
 			 */
 			if (rfsw & RD_S_SEAC2) {
-				DB_RX("E-Indicator set",0,0,2) ;
+				DB_RX(2, "E-Indicator set");
 				smc->hw.fp.err_stats.err_e_indicator++ ;
 			}
 			if (rfsw & RD_S_SFRMERR) {
-				DB_RX("CRC error",0,0,2) ;
+				DB_RX(2, "CRC error");
 				smc->hw.fp.err_stats.err_crc++ ;
 			}
 			if (rfsw & RX_FS_IMPL) {
-				DB_RX("Implementer frame",0,0,2) ;
+				DB_RX(2, "Implementer frame");
 				smc->hw.fp.err_stats.err_imp_frame++ ;
 			}
 			goto abort_frame ;
 		}
 		if (len > FDDI_RAW_MTU-4) {
-			DB_RX("Frame too long error",0,0,2) ;
+			DB_RX(2, "Frame too long error");
 			smc->hw.fp.err_stats.err_too_long++ ;
 			goto abort_frame ;
 		}
@@ -1209,12 +1209,12 @@ void process_receive(struct s_smc *smc)
 		 * of aborded frames to the BMU
 		 */
 		if (len <= 4) {
-			DB_RX("Frame length = 0",0,0,2) ;
+			DB_RX(2, "Frame length = 0");
 			goto abort_frame ;
 		}
 
 		if (len != (n-4)) {
-			DB_RX("BMU: rx len differs: [%d:%d]",len,n,4);
+			DB_RX(4, "BMU: rx len differs: [%d:%d]", len, n);
 			smc->os.hwm.rx_len_error++ ;
 			goto abort_frame ;
 		}
@@ -1223,7 +1223,7 @@ void process_receive(struct s_smc *smc)
 		 * Check SA == MA
 		 */
 		virt = (u_char far *) rxd->rxd_virt ;
-		DB_RX("FC = %x",*virt,0,2) ;
+		DB_RX(2, "FC = %x", *virt);
 		if (virt[12] == MA[5] &&
 		    virt[11] == MA[4] &&
 		    virt[10] == MA[3] &&
@@ -1250,7 +1250,7 @@ void process_receive(struct s_smc *smc)
 					    virt[3] != MA[2] ||
 					    virt[2] != MA[1] ||
 					    virt[1] != MA[0]) {
-						DB_RX("DA != MA and not multi- or broadcast",0,0,2) ;
+						DB_RX(2, "DA != MA and not multi- or broadcast");
 						goto abort_frame ;
 					}
 				}
@@ -1259,13 +1259,13 @@ void process_receive(struct s_smc *smc)
 			/*
 			 * LLC frame received
 			 */
-			DB_RX("LLC - receive",0,0,4) ;
+			DB_RX(4, "LLC - receive");
 			mac_drv_rx_complete(smc,rxd,frag_count,len) ;
 		}
 		else {
 			if (!(mb = smt_get_mbuf(smc))) {
 				smc->hw.fp.err_stats.err_no_buf++ ;
-				DB_RX("No SMbuf; receive terminated",0,0,4) ;
+				DB_RX(4, "No SMbuf; receive terminated");
 				goto abort_frame ;
 			}
 			data = smtod(mb,char *) - 1 ;
@@ -1278,7 +1278,7 @@ void process_receive(struct s_smc *smc)
 #else
 			for (r=rxd, i=used_frags ; i ; r=r->rxd_next, i--){
 				n = le32_to_cpu(r->rxd_rbctrl) & RD_LENGTH ;
-				DB_RX("cp SMT frame to mb: len = %d",n,0,6) ;
+				DB_RX(6, "cp SMT frame to mb: len = %d", n);
 				memcpy(data,r->rxd_virt,n) ;
 				data += n ;
 			}
@@ -1294,15 +1294,15 @@ void process_receive(struct s_smc *smc)
 			switch(fc) {
 			case FC_SMT_INFO :
 				smc->hw.fp.err_stats.err_smt_frame++ ;
-				DB_RX("SMT frame received ",0,0,5) ;
+				DB_RX(5, "SMT frame received");
 
 				if (smc->os.hwm.pass_SMT) {
-					DB_RX("pass SMT frame ",0,0,5) ;
+					DB_RX(5, "pass SMT frame");
 					mac_drv_rx_complete(smc, rxd,
 						frag_count,len) ;
 				}
 				else {
-					DB_RX("requeue RxD",0,0,5) ;
+					DB_RX(5, "requeue RxD");
 					mac_drv_requeue_rxd(smc,rxd,frag_count);
 				}
 
@@ -1310,7 +1310,7 @@ void process_receive(struct s_smc *smc)
 				break ;
 			case FC_SMT_NSA :
 				smc->hw.fp.err_stats.err_smt_frame++ ;
-				DB_RX("SMT frame received ",0,0,5) ;
+				DB_RX(5, "SMT frame received");
 
 				/* if pass_NSA set pass the NSA frame or */
 				/* pass_SMT set and the A-Indicator */
@@ -1318,12 +1318,12 @@ void process_receive(struct s_smc *smc)
 				if (smc->os.hwm.pass_NSA ||
 					(smc->os.hwm.pass_SMT &&
 					!(rfsw & A_INDIC))) {
-					DB_RX("pass SMT frame ",0,0,5) ;
+					DB_RX(5, "pass SMT frame");
 					mac_drv_rx_complete(smc, rxd,
 						frag_count,len) ;
 				}
 				else {
-					DB_RX("requeue RxD",0,0,5) ;
+					DB_RX(5, "requeue RxD");
 					mac_drv_requeue_rxd(smc,rxd,frag_count);
 				}
 
@@ -1331,12 +1331,12 @@ void process_receive(struct s_smc *smc)
 				break ;
 			case FC_BEACON :
 				if (smc->os.hwm.pass_DB) {
-					DB_RX("pass DB frame ",0,0,5) ;
+					DB_RX(5, "pass DB frame");
 					mac_drv_rx_complete(smc, rxd,
 						frag_count,len) ;
 				}
 				else {
-					DB_RX("requeue RxD",0,0,5) ;
+					DB_RX(5, "requeue RxD");
 					mac_drv_requeue_rxd(smc,rxd,frag_count);
 				}
 				smt_free_mbuf(smc,mb) ;
@@ -1345,9 +1345,9 @@ void process_receive(struct s_smc *smc)
 				/*
 				 * unknown FC abord the frame
 				 */
-				DB_RX("unknown FC error",0,0,2) ;
+				DB_RX(2, "unknown FC error");
 				smt_free_mbuf(smc,mb) ;
-				DB_RX("requeue RxD",0,0,5) ;
+				DB_RX(5, "requeue RxD");
 				mac_drv_requeue_rxd(smc,rxd,frag_count) ;
 				if ((fc & 0xf0) == FC_MAC)
 					smc->hw.fp.err_stats.err_mac_frame++ ;
@@ -1358,16 +1358,16 @@ void process_receive(struct s_smc *smc)
 			}
 		}
 
-		DB_RX("next RxD is %x ",queue->rx_curr_get,0,3) ;
+		DB_RX(3, "next RxD is %p", queue->rx_curr_get);
 		NDD_TRACE("RHx1",queue->rx_curr_get,0,0) ;
 
 		continue ;
 	/*--------------------------------------------------------------------*/
 abort_frame:
-		DB_RX("requeue RxD",0,0,5) ;
+		DB_RX(5, "requeue RxD");
 		mac_drv_requeue_rxd(smc,rxd,frag_count) ;
 
-		DB_RX("next RxD is %x ",queue->rx_curr_get,0,3) ;
+		DB_RX(3, "next RxD is %p", queue->rx_curr_get);
 		NDD_TRACE("RHx2",queue->rx_curr_get,0,0) ;
 	}
 rx_end:
@@ -1381,7 +1381,7 @@ static void smt_to_llc(struct s_smc *smc, SMbuf *mb)
 {
 	u_char	fc ;
 
-	DB_RX("send a queued frame to the llc layer",0,0,4) ;
+	DB_RX(4, "send a queued frame to the llc layer");
 	smc->os.hwm.r.len = mb->sm_len ;
 	smc->os.hwm.r.mb_pos = smtod(mb,char *) ;
 	fc = *smc->os.hwm.r.mb_pos ;
@@ -1419,7 +1419,7 @@ void hwm_rx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 	__le32	rbctrl;
 
 	NDD_TRACE("RHfB",virt,len,frame_status) ;
-	DB_RX("hwm_rx_frag: len = %d, frame_status = %x\n",len,frame_status,2) ;
+	DB_RX(2, "hwm_rx_frag: len = %d, frame_status = %x", len, frame_status);
 	r = smc->hw.fp.rx_q[QUEUE_R1].rx_curr_put ;
 	r->rxd_virt = virt ;
 	r->rxd_rbadr = cpu_to_le32(phys) ;
@@ -1475,7 +1475,7 @@ void mac_drv_clear_rx_queue(struct s_smc *smc)
 	}
 
 	queue = smc->hw.fp.rx[QUEUE_R1] ;
-	DB_RX("clear_rx_queue",0,0,5) ;
+	DB_RX(5, "clear_rx_queue");
 
 	/*
 	 * dma_complete and mac_drv_clear_rxd for all RxDs / receive buffers
@@ -1483,7 +1483,7 @@ void mac_drv_clear_rx_queue(struct s_smc *smc)
 	r = queue->rx_curr_get ;
 	while (queue->rx_used) {
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
-		DB_RX("switch OWN bit of RxD 0x%p ",r,0,5) ;
+		DB_RX(5, "switch OWN bit of RxD 0x%p", r);
 		r->rxd_rbctrl &= ~cpu_to_le32(BMU_OWN) ;
 		frag_count = 1 ;
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORDEV) ;
@@ -1491,23 +1491,23 @@ void mac_drv_clear_rx_queue(struct s_smc *smc)
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
 		while (r != queue->rx_curr_put &&
 			!(r->rxd_rbctrl & cpu_to_le32(BMU_ST_BUF))) {
-			DB_RX("Check STF bit in %x",(void *)r,0,5) ;
+			DB_RX(5, "Check STF bit in %p", r);
 			r->rxd_rbctrl &= ~cpu_to_le32(BMU_OWN) ;
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORDEV) ;
 			r = r->rxd_next ;
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
 			frag_count++ ;
 		}
-		DB_RX("STF bit found",0,0,5) ;
+		DB_RX(5, "STF bit found");
 		next_rxd = r ;
 
 		for (r=queue->rx_curr_get,i=frag_count; i ; r=r->rxd_next,i--){
-			DB_RX("dma_complete for RxD %x",(void *)r,0,5) ;
+			DB_RX(5, "dma_complete for RxD %p", r);
 			dma_complete(smc,(union s_fp_descr volatile *)r,DMA_WR);
 		}
 
-		DB_RX("mac_drv_clear_rxd: RxD %x frag_count %d ",
-			(void *)queue->rx_curr_get,frag_count,5) ;
+		DB_RX(5, "mac_drv_clear_rxd: RxD %p frag_count %d",
+		      queue->rx_curr_get, frag_count);
 		mac_drv_clear_rxd(smc,queue->rx_curr_get,frag_count) ;
 
 		queue->rx_curr_get = next_rxd ;
@@ -1554,7 +1554,7 @@ int hwm_tx_init(struct s_smc *smc, u_char fc, int frag_count, int frame_len,
 	smc->os.hwm.tx_p = smc->hw.fp.tx[frame_status & QUEUE_A0] ;
 	smc->os.hwm.tx_descr = TX_DESCRIPTOR | (((u_long)(frame_len-1)&3)<<27) ;
 	smc->os.hwm.tx_len = frame_len ;
-	DB_TX("hwm_tx_init: fc = %x, len = %d",fc,frame_len,3) ;
+	DB_TX(3, "hwm_tx_init: fc = %x, len = %d", fc, frame_len);
 	if ((fc & ~(FC_SYNC_BIT|FC_LLC_PRIOR)) == FC_ASYNC_LLC) {
 		frame_status |= LAN_TX ;
 	}
@@ -1577,23 +1577,23 @@ int hwm_tx_init(struct s_smc *smc, u_char fc, int frag_count, int frame_len,
 	if (!smc->hw.mac_ring_is_up) {
 		frame_status &= ~LAN_TX ;
 		frame_status |= RING_DOWN ;
-		DB_TX("Ring is down: terminate LAN_TX",0,0,2) ;
+		DB_TX(2, "Ring is down: terminate LAN_TX");
 	}
 	if (frag_count > smc->os.hwm.tx_p->tx_free) {
 #ifndef	NDIS_OS2
 		mac_drv_clear_txd(smc) ;
 		if (frag_count > smc->os.hwm.tx_p->tx_free) {
-			DB_TX("Out of TxDs, terminate LAN_TX",0,0,2) ;
+			DB_TX(2, "Out of TxDs, terminate LAN_TX");
 			frame_status &= ~LAN_TX ;
 			frame_status |= OUT_OF_TXD ;
 		}
 #else
-		DB_TX("Out of TxDs, terminate LAN_TX",0,0,2) ;
+		DB_TX(2, "Out of TxDs, terminate LAN_TX");
 		frame_status &= ~LAN_TX ;
 		frame_status |= OUT_OF_TXD ;
 #endif
 	}
-	DB_TX("frame_status = %x",frame_status,0,3) ;
+	DB_TX(3, "frame_status = %x", frame_status);
 	NDD_TRACE("THiE",frame_status,smc->os.hwm.tx_p->tx_free,0) ;
 	return frame_status;
 }
@@ -1642,10 +1642,10 @@ void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 	 */
 	t = queue->tx_curr_put ;
 
-	DB_TX("hwm_tx_frag: len = %d, frame_status = %x ",len,frame_status,2) ;
+	DB_TX(2, "hwm_tx_frag: len = %d, frame_status = %x", len, frame_status);
 	if (frame_status & LAN_TX) {
 		/* '*t' is already defined */
-		DB_TX("LAN_TX: TxD = %p, virt = %p ",t,virt,3) ;
+		DB_TX(3, "LAN_TX: TxD = %p, virt = %p", t, virt);
 		t->txd_virt = virt ;
 		t->txd_txdscr = cpu_to_le32(smc->os.hwm.tx_descr) ;
 		t->txd_tbadr = cpu_to_le32(phys) ;
@@ -1674,11 +1674,11 @@ void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 		}
 	}
 	if (frame_status & LOC_TX) {
-		DB_TX("LOC_TX: ",0,0,3) ;
+		DB_TX(3, "LOC_TX:");
 		if (frame_status & FIRST_FRAG) {
 			if(!(smc->os.hwm.tx_mb = smt_get_mbuf(smc))) {
 				smc->hw.fp.err_stats.err_no_buf++ ;
-				DB_TX("No SMbuf; transmit terminated",0,0,4) ;
+				DB_TX(4, "No SMbuf; transmit terminated");
 			}
 			else {
 				smc->os.hwm.tx_data =
@@ -1693,7 +1693,7 @@ void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 		}
 		if (smc->os.hwm.tx_mb) {
 #ifndef	USE_OS_CPY
-			DB_TX("copy fragment into MBuf ",0,0,3) ;
+			DB_TX(3, "copy fragment into MBuf");
 			memcpy(smc->os.hwm.tx_data,virt,len) ;
 			smc->os.hwm.tx_data += len ;
 #endif
@@ -1718,7 +1718,7 @@ void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 				smc->os.hwm.tx_data++ ;
 				smc->os.hwm.tx_mb->sm_len =
 					smc->os.hwm.tx_len - 1 ;
-				DB_TX("pass LLC frame to SMT ",0,0,3) ;
+				DB_TX(3, "pass LLC frame to SMT");
 				smt_received_pack(smc,smc->os.hwm.tx_mb,
 						RD_FS_LOCAL) ;
 			}
@@ -1733,7 +1733,7 @@ void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
  */
 static void queue_llc_rx(struct s_smc *smc, SMbuf *mb)
 {
-	DB_GEN("queue_llc_rx: mb = %x",(void *)mb,0,4) ;
+	DB_GEN(4, "queue_llc_rx: mb = %p", mb);
 	smc->os.hwm.queued_rx_frames++ ;
 	mb->sm_next = (SMbuf *)NULL ;
 	if (smc->os.hwm.llc_rx_pipe == NULL) {
@@ -1763,7 +1763,7 @@ static SMbuf *get_llc_rx(struct s_smc *smc)
 		smc->os.hwm.queued_rx_frames-- ;
 		smc->os.hwm.llc_rx_pipe = mb->sm_next ;
 	}
-	DB_GEN("get_llc_rx: mb = 0x%x",(void *)mb,0,4) ;
+	DB_GEN(4, "get_llc_rx: mb = 0x%p", mb);
 	return mb;
 }
 
@@ -1773,7 +1773,7 @@ static SMbuf *get_llc_rx(struct s_smc *smc)
  */
 static void queue_txd_mb(struct s_smc *smc, SMbuf *mb)
 {
-	DB_GEN("_rx: queue_txd_mb = %x",(void *)mb,0,4) ;
+	DB_GEN(4, "_rx: queue_txd_mb = %p", mb);
 	smc->os.hwm.queued_txd_mb++ ;
 	mb->sm_next = (SMbuf *)NULL ;
 	if (smc->os.hwm.txd_tx_pipe == NULL) {
@@ -1796,7 +1796,7 @@ static SMbuf *get_txd_mb(struct s_smc *smc)
 		smc->os.hwm.queued_txd_mb-- ;
 		smc->os.hwm.txd_tx_pipe = mb->sm_next ;
 	}
-	DB_GEN("get_txd_mb: mb = 0x%x",(void *)mb,0,4) ;
+	DB_GEN(4, "get_txd_mb: mb = 0x%p", mb);
 	return mb;
 }
 
@@ -1819,7 +1819,7 @@ void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 	__le32	tbctrl;
 
 	NDD_TRACE("THSB",mb,fc,0) ;
-	DB_TX("smt_send_mbuf: mb = 0x%p, fc = 0x%x",mb,fc,4) ;
+	DB_TX(4, "smt_send_mbuf: mb = 0x%p, fc = 0x%x", mb, fc);
 
 	mb->sm_off-- ;	/* set to fc */
 	mb->sm_len++ ;	/* + fc */
@@ -1838,7 +1838,7 @@ void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 		if (n >= len) {
 			n = len ;
 		}
-		DB_TX("frag: virt/len = 0x%x/%d ",(void *)data,n,5) ;
+		DB_TX(5, "frag: virt/len = 0x%p/%d", data, n);
 		virt[frag_count] = data ;
 		frag_len[frag_count] = n ;
 		frag_count++ ;
@@ -1863,15 +1863,15 @@ void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 	if (!smc->hw.mac_ring_is_up || frag_count > queue->tx_free) {
 		frame_status &= ~LAN_TX;
 		if (frame_status) {
-			DB_TX("Ring is down: terminate LAN_TX",0,0,2) ;
+			DB_TX(2, "Ring is down: terminate LAN_TX");
 		}
 		else {
-			DB_TX("Ring is down: terminate transmission",0,0,2) ;
+			DB_TX(2, "Ring is down: terminate transmission");
 			smt_free_mbuf(smc,mb) ;
 			return ;
 		}
 	}
-	DB_TX("frame_status = 0x%x ",frame_status,0,5) ;
+	DB_TX(5, "frame_status = 0x%x", frame_status);
 
 	if ((frame_status & LAN_TX) && (frame_status & LOC_TX)) {
 		mb->sm_use_count = 2 ;
@@ -1881,7 +1881,7 @@ void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 		t = queue->tx_curr_put ;
 		frame_status |= FIRST_FRAG ;
 		for (i = 0; i < frag_count; i++) {
-			DB_TX("init TxD = 0x%x",(void *)t,0,5) ;
+			DB_TX(5, "init TxD = 0x%p", t);
 			if (i == frag_count-1) {
 				frame_status |= LAST_FRAG ;
 				t->txd_txdscr = cpu_to_le32(TX_DESCRIPTOR |
@@ -1912,7 +1912,7 @@ void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 	}
 
 	if (frame_status & LOC_TX) {
-		DB_TX("pass Mbuf to LLC queue",0,0,5) ;
+		DB_TX(5, "pass Mbuf to LLC queue");
 		queue_llc_rx(smc,mb) ;
 	}
 
@@ -1953,18 +1953,18 @@ static void mac_drv_clear_txd(struct s_smc *smc)
 	for (i = QUEUE_S; i <= QUEUE_A0; i++) {
 		queue = smc->hw.fp.tx[i] ;
 		t1 = queue->tx_curr_get ;
-		DB_TX("clear_txd: QUEUE = %d (0=sync/1=async)",i,0,5) ;
+		DB_TX(5, "clear_txd: QUEUE = %d (0=sync/1=async)", i);
 
 		for ( ; ; ) {
 			frag_count = 0 ;
 
 			do {
 				DRV_BUF_FLUSH(t1,DDI_DMA_SYNC_FORCPU) ;
-				DB_TX("check OWN/EOF bit of TxD 0x%p",t1,0,5) ;
+				DB_TX(5, "check OWN/EOF bit of TxD 0x%p", t1);
 				tbctrl = le32_to_cpu(CR_READ(t1->txd_tbctrl));
 
 				if (tbctrl & BMU_OWN || !queue->tx_used){
-					DB_TX("End of TxDs queue %d",i,0,4) ;
+					DB_TX(4, "End of TxDs queue %d", i);
 					goto free_next_queue ;	/* next queue */
 				}
 				t1 = t1->txd_next ;
@@ -1988,11 +1988,11 @@ static void mac_drv_clear_txd(struct s_smc *smc)
 			}
 			else {
 #ifndef PASS_1ST_TXD_2_TX_COMP
-				DB_TX("mac_drv_tx_comp for TxD 0x%p",t2,0,4) ;
+				DB_TX(4, "mac_drv_tx_comp for TxD 0x%p", t2);
 				mac_drv_tx_complete(smc,t2) ;
 #else
-				DB_TX("mac_drv_tx_comp for TxD 0x%x",
-					queue->tx_curr_get,0,4) ;
+				DB_TX(4, "mac_drv_tx_comp for TxD 0x%x",
+				      queue->tx_curr_get);
 				mac_drv_tx_complete(smc,queue->tx_curr_get) ;
 #endif
 			}
@@ -2043,7 +2043,7 @@ void mac_drv_clear_tx_queue(struct s_smc *smc)
 
 	for (i = QUEUE_S; i <= QUEUE_A0; i++) {
 		queue = smc->hw.fp.tx[i] ;
-		DB_TX("clear_tx_queue: QUEUE = %d (0=sync/1=async)",i,0,5) ;
+		DB_TX(5, "clear_tx_queue: QUEUE = %d (0=sync/1=async)", i);
 
 		/*
 		 * switch the OWN bit of all pending frames to the host
@@ -2052,7 +2052,7 @@ void mac_drv_clear_tx_queue(struct s_smc *smc)
 		tx_used = queue->tx_used ;
 		while (tx_used) {
 			DRV_BUF_FLUSH(t,DDI_DMA_SYNC_FORCPU) ;
-			DB_TX("switch OWN bit of TxD 0x%p ",t,0,5) ;
+			DB_TX(5, "switch OWN bit of TxD 0x%p", t);
 			t->txd_tbctrl &= ~cpu_to_le32(BMU_OWN) ;
 			DRV_BUF_FLUSH(t,DDI_DMA_SYNC_FORDEV) ;
 			t = t->txd_next ;
-- 
2.10.0.rc2.1.g053435c
