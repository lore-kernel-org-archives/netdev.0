From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/8] brcm80211: Add and use brcmX_dbg_dump_hex
Date: Sun, 15 Jan 2012 00:38:40 -0800
Message-ID: <289e8a2dcdbb03315ba41788a358f5afc4bacb1b.1326616556.git.joe@perches.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54848 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751297Ab2AOIjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 03:39:42 -0500
In-Reply-To: <cover.1326616556.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the number of #ifdef DEBUG uses by
adding a dbg_hex_dump routine which has the
appropriate #ifdef DEBUG test.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |    6 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  141 +++++++-------------
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |   18 +++
 .../net/wireless/brcm80211/include/brcmu_utils.h   |   11 ++
 4 files changed, 84 insertions(+), 92 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
index f5ca9fc..a2c4576 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
@@ -68,6 +68,12 @@ do {									\
 
 #endif				/* defined(DEBUG) */
 
+#define brcmf_dbg_hex_dump(test, data, len, fmt, ...)			\
+do {									\
+	if (test)							\
+		brcmu_dbg_hex_dump(data, len, fmt, ##__VA_ARGS__);	\
+} while (0)
+
 extern int brcmf_msg_level;
 
 #endif				/* _BRCMF_DBG_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 7157a60..4ab1023 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -1279,13 +1279,10 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 			}
 			return 0;
 		}
-#ifdef DEBUG
-		if (BRCMF_GLOM_ON()) {
-			printk(KERN_DEBUG "SUPERFRAME:\n");
-			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-				pfirst->data, min_t(int, pfirst->len, 48));
-		}
-#endif
+
+		brcmf_dbg_hex_dump(BRCMF_GLOM_ON(),
+				   pfirst->data, min_t(int, pfirst->len, 48),
+				   "SUPERFRAME:\n");
 
 		/* Validate the superframe header */
 		dptr = (u8 *) (pfirst->data);
@@ -1362,13 +1359,8 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 			check = get_unaligned_le16(dptr + sizeof(u16));
 			chan = SDPCM_PACKET_CHANNEL(&dptr[SDPCM_FRAMETAG_LEN]);
 			doff = SDPCM_DOFFSET_VALUE(&dptr[SDPCM_FRAMETAG_LEN]);
-#ifdef DEBUG
-			if (BRCMF_GLOM_ON()) {
-				printk(KERN_DEBUG "subframe:\n");
-				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-						     dptr, 32);
-			}
-#endif
+			brcmf_dbg_hex_dump(BRCMF_GLOM_ON(),
+					   dptr, 32, "subframe:\n");
 
 			if ((u16)~(sublen ^ check)) {
 				brcmf_dbg(ERROR, "(subframe %d): HW hdr error: len/check 0x%04x/0x%04x\n",
@@ -1433,13 +1425,8 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 			}
 			rxseq++;
 
-#ifdef DEBUG
-			if (BRCMF_BYTES_ON() && BRCMF_DATA_ON()) {
-				printk(KERN_DEBUG "Rx Subframe Data:\n");
-				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-						     dptr, dlen);
-			}
-#endif
+			brcmf_dbg_hex_dump(BRCMF_BYTES_ON() && BRCMF_DATA_ON(),
+					   dptr, dlen, "Rx Subframe Data:\n");
 
 			__skb_trim(pfirst, sublen);
 			skb_pull(pfirst, doff);
@@ -1457,17 +1444,13 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 				continue;
 			}
 
-#ifdef DEBUG
-			if (BRCMF_GLOM_ON()) {
-				brcmf_dbg(GLOM, "subframe %d to stack, %p (%p/%d) nxt/lnk %p/%p\n",
-					  bus->glom.qlen, pfirst, pfirst->data,
-					  pfirst->len, pfirst->next,
-					  pfirst->prev);
-				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-						pfirst->data,
-						min_t(int, pfirst->len, 32));
-			}
-#endif				/* DEBUG */
+			brcmf_dbg_hex_dump(BRCMF_GLOM_ON(),
+					   pfirst->data,
+					   min_t(int, pfirst->len, 32),
+					   "subframe %d to stack, %p (%p/%d) nxt/lnk %p/%p\n",
+					   bus->glom.qlen, pfirst, pfirst->data,
+					   pfirst->len, pfirst->next,
+					   pfirst->prev);
 		}
 		/* sent any remaining packets up */
 		if (bus->glom.qlen) {
@@ -1584,12 +1567,8 @@ brcmf_sdbrcm_read_control(struct brcmf_sdio *bus, u8 *hdr, uint len, uint doff)
 
 gotpkt:
 
-#ifdef DEBUG
-	if (BRCMF_BYTES_ON() && BRCMF_CTL_ON()) {
-		printk(KERN_DEBUG "RxCtrl:\n");
-		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, bus->rxctl, len);
-	}
-#endif
+	brcmf_dbg_hex_dump(BRCMF_BYTES_ON() && BRCMF_CTL_ON(),
+			   bus->rxctl, len, "RxCtrl:\n");
 
 	/* Point to valid data and indicate its length */
 	bus->rxctl += doff;
@@ -1818,17 +1797,13 @@ brcmf_sdbrcm_readframes(struct brcmf_sdio *bus, uint maxframes, bool *finished)
 			}
 			bus->tx_max = txmax;
 
-#ifdef DEBUG
-			if (BRCMF_BYTES_ON() && BRCMF_DATA_ON()) {
-				printk(KERN_DEBUG "Rx Data:\n");
-				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-						     rxbuf, len);
-			} else if (BRCMF_HDRS_ON()) {
-				printk(KERN_DEBUG "RxHdr:\n");
-				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-						     bus->rxhdr, SDPCM_HDRLEN);
-			}
-#endif
+			brcmf_dbg_hex_dump(BRCMF_BYTES_ON() && BRCMF_DATA_ON(),
+					   rxbuf, len, "Rx Data:\n");
+			brcmf_dbg_hex_dump(!(BRCMF_BYTES_ON() &&
+					     BRCMF_DATA_ON()) &&
+					   BRCMF_HDRS_ON(),
+					   bus->rxhdr, SDPCM_HDRLEN,
+					   "RxHdr:\n");
 
 			if (chan == SDPCM_CONTROL_CHANNEL) {
 				brcmf_dbg(ERROR, "(nextlen): readahead on control packet %d?\n",
@@ -1865,13 +1840,9 @@ brcmf_sdbrcm_readframes(struct brcmf_sdio *bus, uint maxframes, bool *finished)
 			brcmf_sdbrcm_rxfail(bus, true, true);
 			continue;
 		}
-#ifdef DEBUG
-		if (BRCMF_BYTES_ON() || BRCMF_HDRS_ON()) {
-			printk(KERN_DEBUG "RxHdr:\n");
-			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-					     bus->rxhdr, SDPCM_HDRLEN);
-		}
-#endif
+		brcmf_dbg_hex_dump(BRCMF_BYTES_ON() || BRCMF_HDRS_ON(),
+				   bus->rxhdr, SDPCM_HDRLEN, "RxHdr:\n");
+
 
 		/* Extract hardware header fields */
 		len = get_unaligned_le16(bus->rxhdr);
@@ -2024,13 +1995,8 @@ brcmf_sdbrcm_readframes(struct brcmf_sdio *bus, uint maxframes, bool *finished)
 		skb_push(pkt, BRCMF_FIRSTREAD);
 		memcpy(pkt->data, bus->rxhdr, BRCMF_FIRSTREAD);
 
-#ifdef DEBUG
-		if (BRCMF_BYTES_ON() && BRCMF_DATA_ON()) {
-			printk(KERN_DEBUG "Rx Data:\n");
-			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-					     pkt->data, len);
-		}
-#endif
+		brcmf_dbg_hex_dump(BRCMF_BYTES_ON() && BRCMF_DATA_ON(),
+				   pkt->data, len, "Rx Data:\n");
 
 deliver:
 		/* Save superframe descriptor and allocate packet frame */
@@ -2038,14 +2004,9 @@ deliver:
 			if (SDPCM_GLOMDESC(&bus->rxhdr[SDPCM_FRAMETAG_LEN])) {
 				brcmf_dbg(GLOM, "glom descriptor, %d bytes:\n",
 					  len);
-#ifdef DEBUG
-				if (BRCMF_GLOM_ON()) {
-					printk(KERN_DEBUG "Glom Data:\n");
-					print_hex_dump_bytes("",
-							     DUMP_PREFIX_OFFSET,
-							     pkt->data, len);
-				}
-#endif
+				brcmf_dbg_hex_dump(BRCMF_GLOM_ON(),
+						   pkt->data, len,
+						   "Glom Data:\n");
 				__skb_trim(pkt, len);
 				skb_pull(pkt, SDPCM_HDRLEN);
 				bus->glomd = pkt;
@@ -2178,16 +2139,18 @@ static int brcmf_sdbrcm_txpkt(struct brcmf_sdio *bus, struct sk_buff *pkt,
 
 #ifdef DEBUG
 	tx_packets[pkt->priority]++;
-	if (BRCMF_BYTES_ON() &&
-	    (((BRCMF_CTL_ON() && (chan == SDPCM_CONTROL_CHANNEL)) ||
-	      (BRCMF_DATA_ON() && (chan != SDPCM_CONTROL_CHANNEL))))) {
-		printk(KERN_DEBUG "Tx Frame:\n");
-		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, frame, len);
-	} else if (BRCMF_HDRS_ON()) {
-		printk(KERN_DEBUG "TxHdr:\n");
-		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-				     frame, min_t(u16, len, 16));
-	}
+
+	brcmf_dbg_hex_dump(BRCMF_BYTES_ON() &&
+			   ((BRCMF_CTL_ON() && chan == SDPCM_CONTROL_CHANNEL) ||
+			    (BRCMF_DATA_ON() && chan != SDPCM_CONTROL_CHANNEL)),
+			   frame, len, "Tx Frame:\n");
+	brcmf_dbg_hex_dump(!(BRCMF_BYTES_ON() &&
+			     ((BRCMF_CTL_ON() &&
+			       chan == SDPCM_CONTROL_CHANNEL) ||
+			      (BRCMF_DATA_ON() &&
+			       chan != SDPCM_CONTROL_CHANNEL))) &&
+			   BRCMF_HDRS_ON(),
+			   frame, min_t(u16, len, 16), "TxHdr:\n");
 #endif
 
 	/* Raise len to next SDIO block to eliminate tail command */
@@ -2982,17 +2945,11 @@ brcmf_sdbrcm_bus_txctl(struct device *dev, unsigned char *msg, uint msglen)
 	}
 
 	if (ret == -1) {
-#ifdef DEBUG
-		if (BRCMF_BYTES_ON() && BRCMF_CTL_ON()) {
-			printk(KERN_DEBUG "Tx Frame:\n");
-			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-					     frame, len);
-		} else if (BRCMF_HDRS_ON()) {
-			printk(KERN_DEBUG "TxHdr:\n");
-			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
-					     frame, min_t(u16, len, 16));
-		}
-#endif
+		brcmf_dbg_hex_dump(BRCMF_BYTES_ON() && BRCMF_CTL_ON(),
+				   frame, len, "Tx Frame:\n");
+		brcmf_dbg_hex_dump(!(BRCMF_BYTES_ON() && BRCMF_CTL_ON()) &&
+				   BRCMF_HDRS_ON(),
+				   frame, min_t(u16, len, 16), "TxHdr:\n");
 
 		do {
 			ret = brcmf_tx_frame(bus, frame, len);
diff --git a/drivers/net/wireless/brcm80211/brcmutil/utils.c b/drivers/net/wireless/brcm80211/brcmutil/utils.c
index e25fb2d..2207eaa 100644
--- a/drivers/net/wireless/brcm80211/brcmutil/utils.c
+++ b/drivers/net/wireless/brcm80211/brcmutil/utils.c
@@ -253,4 +253,22 @@ void brcmu_prpkt(const char *msg, struct sk_buff *p0)
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, p->data, p->len);
 }
 EXPORT_SYMBOL(brcmu_prpkt);
+
+void brcmu_dbg_hex_dump(const void *data, size_t size, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	pr_debug("%pV", &vaf);
+
+	va_end(args);
+
+	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, data, size);
+}
+EXPORT_SYMBOL(brcmu_dbg_hex_dump);
 #endif				/* defined(DEBUG) */
diff --git a/drivers/net/wireless/brcm80211/include/brcmu_utils.h b/drivers/net/wireless/brcm80211/include/brcmu_utils.h
index 0cde38a..477b92a 100644
--- a/drivers/net/wireless/brcm80211/include/brcmu_utils.h
+++ b/drivers/net/wireless/brcm80211/include/brcmu_utils.h
@@ -182,4 +182,15 @@ extern void brcmu_prpkt(const char *msg, struct sk_buff *p0);
 #define brcmu_prpkt(a, b)
 #endif				/* DEBUG */
 
+#ifdef DEBUG
+extern __printf(3, 4)
+void brcmu_dbg_hex_dump(const void *data, size_t size, const char *fmt, ...);
+#else
+__printf(3, 4)
+static inline
+void brcmu_dbg_hex_dump(const void *data, size_t size, const char *fmt, ...)
+{
+}
+#endif
+
 #endif				/* _BRCMU_UTILS_H_ */
-- 
1.7.8.111.gad25c.dirty
