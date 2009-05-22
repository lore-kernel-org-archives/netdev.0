From: Karsten Keil <keil@b1-systems.de>
Subject: [mISDN PATCH v2 03/19] Echo canceler now gets delay information from hardware
Date: Fri, 22 May 2009 23:04:46 +0200
Message-ID: <ad217c4637c8b277978c3709923c4962e0724dee.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758358AbZEVVFt@vger.kernel.org>
In-Reply-To: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Eversberg <andreas@eversberg.eu>

Added tx-fifo information for calculation of current delay to sync tx and rx
streams for echo canceler.

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfc_multi.h |    1 +
 drivers/isdn/hardware/mISDN/hfcmulti.c  |    8 +++-
 drivers/isdn/hardware/mISDN/hfcpci.c    |   70 ++++++++++++++++++-------------
 drivers/isdn/hardware/mISDN/hfcsusb.c   |    4 +-
 drivers/isdn/mISDN/dsp.h                |    2 +-
 drivers/isdn/mISDN/dsp_core.c           |    2 +-
 drivers/isdn/mISDN/dsp_pipeline.c       |    5 +-
 drivers/isdn/mISDN/hwchannel.c          |    4 +-
 include/linux/mISDNdsp.h                |    3 +-
 include/linux/mISDNhw.h                 |    2 +-
 10 files changed, 60 insertions(+), 41 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfc_multi.h b/drivers/isdn/hardware/mISDN/hfc_multi.h
index 5765e19..c4878cc 100644
--- a/drivers/isdn/hardware/mISDN/hfc_multi.h
+++ b/drivers/isdn/hardware/mISDN/hfc_multi.h
@@ -44,6 +44,7 @@ struct hfc_chan {
 	int		conf;	/* conference setting of TX slot */
 	int		txpending;	/* if there is currently data in */
 					/* the FIFO 0=no, 1=yes, 2=splloop */
+	int		Zfill;	/* rx-fifo level on last hfcmulti_tx */
 	int		rx_off; /* set to turn fifo receive off */
 	int		coeff_count; /* curren coeff block */
 	s32		*coeff; /* memory pointer to 8 coeff blocks */
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index ca153de..3a7c26c 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -1945,6 +1945,9 @@ next_frame:
 				"%d!=%d\n", __func__, hc->id + 1, temp, z2);
 		z2 = temp; /* repeat unti Z2 is equal */
 	}
+	hc->chan[ch].Zfill = z1 - z2;
+	if (hc->chan[ch].Zfill < 0)
+		hc->chan[ch].Zfill += hc->Zlen;
 	Zspace = z2 - z1;
 	if (Zspace <= 0)
 		Zspace += hc->Zlen;
@@ -2031,6 +2034,7 @@ next_frame:
 
 	/* Have to prep the audio data */
 	hc->write_fifo(hc, d, ii - i);
+	hc->chan[ch].Zfill += ii - i;
 	*idxp = ii;
 
 	/* if not all data has been written */
@@ -2226,7 +2230,7 @@ next_frame:
 			if (dch)
 				recv_Dchannel(dch);
 			else
-				recv_Bchannel(bch);
+				recv_Bchannel(bch, MISDN_ID_ANY);
 			*sp = skb;
 			again++;
 			goto next_frame;
@@ -2258,7 +2262,7 @@ next_frame:
 			    "(z1=%04x, z2=%04x) TRANS\n",
 				__func__, hc->id + 1, ch, Zsize, z1, z2);
 		/* only bch is transparent */
-		recv_Bchannel(bch);
+		recv_Bchannel(bch, hc->chan[ch].Zfill);
 		*sp = skb;
 	}
 }
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 641a9cd..60dc925 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -452,7 +452,7 @@ hfcpci_empty_bfifo(struct bchannel *bch, struct bzfifo *bz,
 		}
 		bz->za[new_f2].z2 = cpu_to_le16(new_z2);
 		bz->f2 = new_f2;	/* next buffer */
-		recv_Bchannel(bch);
+		recv_Bchannel(bch, MISDN_ID_ANY);
 	}
 }
 
@@ -541,35 +541,45 @@ receive_dmsg(struct hfc_pci *hc)
  * check for transparent receive data and read max one 'poll' size if avail
  */
 static void
-hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *bz, u_char *bdata)
+hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *rxbz,
+	struct bzfifo *txbz, u_char *bdata)
 {
-	 __le16 *z1r, *z2r;
-	int		new_z2, fcnt, maxlen;
-	u_char		*ptr, *ptr1;
+	 __le16	*z1r, *z2r, *z1t, *z2t;
+	int	new_z2, fcnt_rx, fcnt_tx, maxlen;
+	u_char	*ptr, *ptr1;
 
-	z1r = &bz->za[MAX_B_FRAMES].z1;		/* pointer to z reg */
+	z1r = &rxbz->za[MAX_B_FRAMES].z1;	/* pointer to z reg */
 	z2r = z1r + 1;
+	z1t = &txbz->za[MAX_B_FRAMES].z1;
+	z2t = z1t + 1;
 
-	fcnt = le16_to_cpu(*z1r) - le16_to_cpu(*z2r);
-	if (!fcnt)
+	fcnt_rx = le16_to_cpu(*z1r) - le16_to_cpu(*z2r);
+	if (!fcnt_rx)
 		return;	/* no data avail */
 
-	if (fcnt <= 0)
-		fcnt += B_FIFO_SIZE;	/* bytes actually buffered */
-	new_z2 = le16_to_cpu(*z2r) + fcnt;	/* new position in fifo */
+	if (fcnt_rx <= 0)
+		fcnt_rx += B_FIFO_SIZE;	/* bytes actually buffered */
+	new_z2 = le16_to_cpu(*z2r) + fcnt_rx;	/* new position in fifo */
 	if (new_z2 >= (B_FIFO_SIZE + B_SUB_VAL))
 		new_z2 -= B_FIFO_SIZE;	/* buffer wrap */
 
-	if (fcnt > MAX_DATA_SIZE) {	/* flush, if oversized */
+	if (fcnt_rx > MAX_DATA_SIZE) {	/* flush, if oversized */
 		*z2r = cpu_to_le16(new_z2);		/* new position */
 		return;
 	}
 
-	bch->rx_skb = mI_alloc_skb(fcnt, GFP_ATOMIC);
+	fcnt_tx = le16_to_cpu(*z2t) - le16_to_cpu(*z1t);
+	if (fcnt_tx <= 0)
+		fcnt_tx += B_FIFO_SIZE;
+		    /* fcnt_tx contains available bytes in tx-fifo */
+	fcnt_tx = B_FIFO_SIZE - fcnt_tx;
+		    /* remaining bytes to send (bytes in tx-fifo) */
+
+	bch->rx_skb = mI_alloc_skb(fcnt_rx, GFP_ATOMIC);
 	if (bch->rx_skb) {
-		ptr = skb_put(bch->rx_skb, fcnt);
-		if (le16_to_cpu(*z2r) + fcnt <= B_FIFO_SIZE + B_SUB_VAL)
-			maxlen = fcnt;	/* complete transfer */
+		ptr = skb_put(bch->rx_skb, fcnt_rx);
+		if (le16_to_cpu(*z2r) + fcnt_rx <= B_FIFO_SIZE + B_SUB_VAL)
+			maxlen = fcnt_rx;	/* complete transfer */
 		else
 			maxlen = B_FIFO_SIZE + B_SUB_VAL - le16_to_cpu(*z2r);
 			    /* maximum */
@@ -577,14 +587,14 @@ hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *bz, u_char *bdata)
 		ptr1 = bdata + (le16_to_cpu(*z2r) - B_SUB_VAL);
 		    /* start of data */
 		memcpy(ptr, ptr1, maxlen);	/* copy data */
-		fcnt -= maxlen;
+		fcnt_rx -= maxlen;
 
-		if (fcnt) {	/* rest remaining */
+		if (fcnt_rx) {	/* rest remaining */
 			ptr += maxlen;
 			ptr1 = bdata;	/* start of buffer */
-			memcpy(ptr, ptr1, fcnt);	/* rest */
+			memcpy(ptr, ptr1, fcnt_rx);	/* rest */
 		}
-		recv_Bchannel(bch);
+		recv_Bchannel(bch, fcnt_tx); /* bch, id */
 	} else
 		printk(KERN_WARNING "HFCPCI: receive out of memory\n");
 
@@ -600,26 +610,28 @@ main_rec_hfcpci(struct bchannel *bch)
 	struct hfc_pci	*hc = bch->hw;
 	int		rcnt, real_fifo;
 	int		receive = 0, count = 5;
-	struct bzfifo	*bz;
+	struct bzfifo	*txbz, *rxbz;
 	u_char		*bdata;
 	struct zt	*zp;
 
 	if ((bch->nr & 2) && (!hc->hw.bswapped)) {
-		bz = &((union fifo_area *)(hc->hw.fifos))->b_chans.rxbz_b2;
+		rxbz = &((union fifo_area *)(hc->hw.fifos))->b_chans.rxbz_b2;
+		txbz = &((union fifo_area *)(hc->hw.fifos))->b_chans.txbz_b2;
 		bdata = ((union fifo_area *)(hc->hw.fifos))->b_chans.rxdat_b2;
 		real_fifo = 1;
 	} else {
-		bz = &((union fifo_area *)(hc->hw.fifos))->b_chans.rxbz_b1;
+		rxbz = &((union fifo_area *)(hc->hw.fifos))->b_chans.rxbz_b1;
+		txbz = &((union fifo_area *)(hc->hw.fifos))->b_chans.txbz_b1;
 		bdata = ((union fifo_area *)(hc->hw.fifos))->b_chans.rxdat_b1;
 		real_fifo = 0;
 	}
 Begin:
 	count--;
-	if (bz->f1 != bz->f2) {
+	if (rxbz->f1 != rxbz->f2) {
 		if (bch->debug & DEBUG_HW_BCHANNEL)
 			printk(KERN_DEBUG "hfcpci rec ch(%x) f1(%d) f2(%d)\n",
-			    bch->nr, bz->f1, bz->f2);
-		zp = &bz->za[bz->f2];
+			    bch->nr, rxbz->f1, rxbz->f2);
+		zp = &rxbz->za[rxbz->f2];
 
 		rcnt = le16_to_cpu(zp->z1) - le16_to_cpu(zp->z2);
 		if (rcnt < 0)
@@ -630,8 +642,8 @@ Begin:
 			    "hfcpci rec ch(%x) z1(%x) z2(%x) cnt(%d)\n",
 			    bch->nr, le16_to_cpu(zp->z1),
 			    le16_to_cpu(zp->z2), rcnt);
-		hfcpci_empty_bfifo(bch, bz, bdata, rcnt);
-		rcnt = bz->f1 - bz->f2;
+		hfcpci_empty_bfifo(bch, rxbz, bdata, rcnt);
+		rcnt = rxbz->f1 - rxbz->f2;
 		if (rcnt < 0)
 			rcnt += MAX_B_FRAMES + 1;
 		if (hc->hw.last_bfifo_cnt[real_fifo] > rcnt + 1) {
@@ -644,7 +656,7 @@ Begin:
 		else
 			receive = 0;
 	} else if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
-		hfcpci_empty_fifo_trans(bch, bz, bdata);
+		hfcpci_empty_fifo_trans(bch, rxbz, txbz, bdata);
 		return;
 	} else
 		receive = 0;
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 9c427fb..6b7704c 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -947,7 +947,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 				if (fifo->dch)
 					recv_Dchannel(fifo->dch);
 				if (fifo->bch)
-					recv_Bchannel(fifo->bch);
+					recv_Bchannel(fifo->bch, MISDN_ID_ANY);
 				if (fifo->ech)
 					recv_Echannel(fifo->ech,
 						     &hw->dch);
@@ -969,7 +969,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 	} else {
 		/* deliver transparent data to layer2 */
 		if (rx_skb->len >= poll)
-			recv_Bchannel(fifo->bch);
+			recv_Bchannel(fifo->bch, MISDN_ID_ANY);
 	}
 	spin_unlock(&hw->lock);
 }
diff --git a/drivers/isdn/mISDN/dsp.h b/drivers/isdn/mISDN/dsp.h
index 0a4a362..4a1c444 100644
--- a/drivers/isdn/mISDN/dsp.h
+++ b/drivers/isdn/mISDN/dsp.h
@@ -262,5 +262,5 @@ extern int  dsp_pipeline_build(struct dsp_pipeline *pipeline, const char *cfg);
 extern void dsp_pipeline_process_tx(struct dsp_pipeline *pipeline, u8 *data,
 		int len);
 extern void dsp_pipeline_process_rx(struct dsp_pipeline *pipeline, u8 *data,
-		int len);
+		int len, unsigned int txlen);
 
diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 3083338..1c49368 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -710,7 +710,7 @@ dsp_function(struct mISDNchannel *ch,  struct sk_buff *skb)
 		/* pipeline */
 		if (dsp->pipeline.inuse)
 			dsp_pipeline_process_rx(&dsp->pipeline, skb->data,
-				skb->len);
+				skb->len, hh->id);
 		/* change volume if requested */
 		if (dsp->rx_volume)
 			dsp_change_volume(skb, dsp->rx_volume);
diff --git a/drivers/isdn/mISDN/dsp_pipeline.c b/drivers/isdn/mISDN/dsp_pipeline.c
index 18cf87c..ac61f19 100644
--- a/drivers/isdn/mISDN/dsp_pipeline.c
+++ b/drivers/isdn/mISDN/dsp_pipeline.c
@@ -347,7 +347,8 @@ void dsp_pipeline_process_tx(struct dsp_pipeline *pipeline, u8 *data, int len)
 			entry->elem->process_tx(entry->p, data, len);
 }
 
-void dsp_pipeline_process_rx(struct dsp_pipeline *pipeline, u8 *data, int len)
+void dsp_pipeline_process_rx(struct dsp_pipeline *pipeline, u8 *data, int len,
+	unsigned int txlen)
 {
 	struct dsp_pipeline_entry *entry;
 
@@ -356,7 +357,7 @@ void dsp_pipeline_process_rx(struct dsp_pipeline *pipeline, u8 *data, int len)
 
 	list_for_each_entry_reverse(entry, &pipeline->list, list)
 		if (entry->elem->process_rx)
-			entry->elem->process_rx(entry->p, data, len);
+			entry->elem->process_rx(entry->p, data, len, txlen);
 }
 
 
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index ab1168a..0481a0c 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -185,13 +185,13 @@ recv_Echannel(struct dchannel *ech, struct dchannel *dch)
 EXPORT_SYMBOL(recv_Echannel);
 
 void
-recv_Bchannel(struct bchannel *bch)
+recv_Bchannel(struct bchannel *bch, unsigned int id)
 {
 	struct mISDNhead *hh;
 
 	hh = mISDN_HEAD_P(bch->rx_skb);
 	hh->prim = PH_DATA_IND;
-	hh->id = MISDN_ID_ANY;
+	hh->id = id;
 	if (bch->rcount >= 64) {
 		printk(KERN_WARNING "B-channel %p receive queue overflow, "
 			"fushing!\n", bch);
diff --git a/include/linux/mISDNdsp.h b/include/linux/mISDNdsp.h
index 6b71d2d..2c483d4 100644
--- a/include/linux/mISDNdsp.h
+++ b/include/linux/mISDNdsp.h
@@ -12,7 +12,8 @@ struct mISDN_dsp_element {
 	void	*(*new)(const char *arg);
 	void	(*free)(void *p);
 	void	(*process_tx)(void *p, unsigned char *data, int len);
-	void	(*process_rx)(void *p, unsigned char *data, int len);
+	void	(*process_rx)(void *p, unsigned char *data, int len,
+			unsigned int txlen);
 	int	num_args;
 	struct mISDN_dsp_element_arg
 		*args;
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index 97ffdc1..ce900f4 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -185,7 +185,7 @@ extern int	dchannel_senddata(struct dchannel *, struct sk_buff *);
 extern int	bchannel_senddata(struct bchannel *, struct sk_buff *);
 extern void	recv_Dchannel(struct dchannel *);
 extern void	recv_Echannel(struct dchannel *, struct dchannel *);
-extern void	recv_Bchannel(struct bchannel *);
+extern void	recv_Bchannel(struct bchannel *, unsigned int id);
 extern void	recv_Dchannel_skb(struct dchannel *, struct sk_buff *);
 extern void	recv_Bchannel_skb(struct bchannel *, struct sk_buff *);
 extern void	confirm_Bsend(struct bchannel *bch);
-- 
1.6.0.2
