From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Mon, 24 Apr 2006 15:40:11 -0400
Message-ID: <20060424194006.GB21761@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:51725 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751186AbWDXTkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 15:40:41 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 6b426e785cb81e53dc2fc4dcf997661472b470ef:
  Linus Torvalds:
        Merge git://git.kernel.org/.../kyle/parisc-2.6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Johannes Berg:
      softmac: fix SIOCSIWAP

Michael Buesch:
      bcm43xx: add to MAINTAINERS
      bcm43xx: make PIO mode usable

Pavel Roskin:
      Fix crash on big-endian systems during scan

 MAINTAINERS                                     |    8 ++
 drivers/net/wireless/bcm43xx/bcm43xx_dma.h      |    8 ++
 drivers/net/wireless/bcm43xx/bcm43xx_pio.c      |   92 ++++++++++++++++-------
 drivers/net/wireless/bcm43xx/bcm43xx_pio.h      |   16 ++++
 drivers/net/wireless/hostap/hostap_ioctl.c      |    4 +
 include/net/ieee80211softmac.h                  |    5 +
 net/ieee80211/softmac/ieee80211softmac_assoc.c  |   20 ++++-
 net/ieee80211/softmac/ieee80211softmac_module.c |    2 +
 net/ieee80211/softmac/ieee80211softmac_wx.c     |   27 ++++---
 9 files changed, 133 insertions(+), 49 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4e1e817..d6a8e5b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -421,6 +421,14 @@ L:	linux-hams@vger.kernel.org
 W:	http://www.baycom.org/~tom/ham/ham.html
 S:	Maintained
 
+BCM43XX WIRELESS DRIVER
+P:	Michael Buesch
+M:	mb@bu3sch.de
+P:	Stefano Brivio
+M:	st3@riseup.net
+W:	http://bcm43xx.berlios.de/
+S:	Maintained
+
 BEFS FILE SYSTEM
 P:	Sergey S. Kostyliov
 M:	rathamahata@php4.ru
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_dma.h b/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
index 2d520e4..b7d7763 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
@@ -213,6 +213,14 @@ static inline
 void bcm43xx_dma_rx(struct bcm43xx_dmaring *ring)
 {
 }
+static inline
+void bcm43xx_dma_tx_suspend(struct bcm43xx_dmaring *ring)
+{
+}
+static inline
+void bcm43xx_dma_tx_resume(struct bcm43xx_dmaring *ring)
+{
+}
 
 #endif /* CONFIG_BCM43XX_DMA */
 #endif /* BCM43xx_DMA_H_ */
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_pio.c b/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
index c59ddd4..0aa1bd2 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
@@ -27,6 +27,7 @@
 #include "bcm43xx_pio.h"
 #include "bcm43xx_main.h"
 #include "bcm43xx_xmit.h"
+#include "bcm43xx_power.h"
 
 #include <linux/delay.h>
 
@@ -44,10 +45,10 @@ static void tx_octet(struct bcm43xx_pioq
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  octet);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
-				  BCM43xx_PIO_TXCTL_WRITEHI);
+				  BCM43xx_PIO_TXCTL_WRITELO);
 	} else {
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
-				  BCM43xx_PIO_TXCTL_WRITEHI);
+				  BCM43xx_PIO_TXCTL_WRITELO);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  octet);
 	}
@@ -103,7 +104,7 @@ static void tx_complete(struct bcm43xx_p
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  skb->data[skb->len - 1]);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
-				  BCM43xx_PIO_TXCTL_WRITEHI |
+				  BCM43xx_PIO_TXCTL_WRITELO |
 				  BCM43xx_PIO_TXCTL_COMPLETE);
 	} else {
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
@@ -112,9 +113,10 @@ static void tx_complete(struct bcm43xx_p
 }
 
 static u16 generate_cookie(struct bcm43xx_pioqueue *queue,
-			   int packetindex)
+			   struct bcm43xx_pio_txpacket *packet)
 {
 	u16 cookie = 0x0000;
+	int packetindex;
 
 	/* We use the upper 4 bits for the PIO
 	 * controller ID and the lower 12 bits
@@ -135,6 +137,7 @@ static u16 generate_cookie(struct bcm43x
 	default:
 		assert(0);
 	}
+	packetindex = pio_txpacket_getindex(packet);
 	assert(((u16)packetindex & 0xF000) == 0x0000);
 	cookie |= (u16)packetindex;
 
@@ -184,7 +187,7 @@ static void pio_tx_write_fragment(struct
 	bcm43xx_generate_txhdr(queue->bcm,
 			       &txhdr, skb->data, skb->len,
 			       (packet->xmitted_frags == 0),
-			       generate_cookie(queue, pio_txpacket_getindex(packet)));
+			       generate_cookie(queue, packet));
 
 	tx_start(queue);
 	octets = skb->len + sizeof(txhdr);
@@ -241,7 +244,7 @@ static int pio_tx_packet(struct bcm43xx_
 		queue->tx_devq_packets++;
 		queue->tx_devq_used += octets;
 
-		assert(packet->xmitted_frags <= packet->txb->nr_frags);
+		assert(packet->xmitted_frags < packet->txb->nr_frags);
 		packet->xmitted_frags++;
 		packet->xmitted_octets += octets;
 	}
@@ -257,8 +260,14 @@ static void tx_tasklet(unsigned long d)
 	unsigned long flags;
 	struct bcm43xx_pio_txpacket *packet, *tmp_packet;
 	int err;
+	u16 txctl;
 
 	bcm43xx_lock_mmio(bcm, flags);
+
+	txctl = bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
+	if (txctl & BCM43xx_PIO_TXCTL_SUSPEND)
+		goto out_unlock;
+
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txqueue, list) {
 		assert(packet->xmitted_frags < packet->txb->nr_frags);
 		if (packet->xmitted_frags == 0) {
@@ -288,6 +297,7 @@ static void tx_tasklet(unsigned long d)
 	next_packet:
 		continue;
 	}
+out_unlock:
 	bcm43xx_unlock_mmio(bcm, flags);
 }
 
@@ -330,12 +340,19 @@ struct bcm43xx_pioqueue * bcm43xx_setup_
 		     (unsigned long)queue);
 
 	value = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
-	value |= BCM43xx_SBF_XFER_REG_BYTESWAP;
+	value &= ~BCM43xx_SBF_XFER_REG_BYTESWAP;
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, value);
 
 	qsize = bcm43xx_read16(bcm, queue->mmio_base + BCM43xx_PIO_TXQBUFSIZE);
+	if (qsize == 0) {
+		printk(KERN_ERR PFX "ERROR: This card does not support PIO "
+				    "operation mode. Please use DMA mode "
+				    "(module parameter pio=0).\n");
+		goto err_freequeue;
+	}
 	if (qsize <= BCM43xx_PIO_TXQADJUST) {
-		printk(KERN_ERR PFX "PIO tx device-queue too small (%u)\n", qsize);
+		printk(KERN_ERR PFX "PIO tx device-queue too small (%u)\n",
+		       qsize);
 		goto err_freequeue;
 	}
 	qsize -= BCM43xx_PIO_TXQADJUST;
@@ -444,15 +461,10 @@ int bcm43xx_pio_tx(struct bcm43xx_privat
 {
 	struct bcm43xx_pioqueue *queue = bcm43xx_current_pio(bcm)->queue1;
 	struct bcm43xx_pio_txpacket *packet;
-	u16 tmp;
 
 	assert(!queue->tx_suspended);
 	assert(!list_empty(&queue->txfree));
 
-	tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
-	if (tmp & BCM43xx_PIO_TXCTL_SUSPEND)
-		return -EBUSY;
-
 	packet = list_entry(queue->txfree.next, struct bcm43xx_pio_txpacket, list);
 	packet->txb = txb;
 	packet->xmitted_frags = 0;
@@ -462,7 +474,7 @@ int bcm43xx_pio_tx(struct bcm43xx_privat
 	assert(queue->nr_txfree < BCM43xx_PIO_MAXTXPACKETS);
 
 	/* Suspend TX, if we are out of packets in the "free" queue. */
-	if (unlikely(list_empty(&queue->txfree))) {
+	if (list_empty(&queue->txfree)) {
 		netif_stop_queue(queue->bcm->net_dev);
 		queue->tx_suspended = 1;
 	}
@@ -480,15 +492,15 @@ void bcm43xx_pio_handle_xmitstatus(struc
 
 	queue = parse_cookie(bcm, status->cookie, &packet);
 	assert(queue);
-//TODO
-if (!queue)
-return;
+
 	free_txpacket(packet, 1);
-	if (unlikely(queue->tx_suspended)) {
+	if (queue->tx_suspended) {
 		queue->tx_suspended = 0;
 		netif_wake_queue(queue->bcm->net_dev);
 	}
-	/* If there are packets on the txqueue, poke the tasklet. */
+	/* If there are packets on the txqueue, poke the tasklet
+	 * to transmit them.
+	 */
 	if (!list_empty(&queue->txqueue))
 		tasklet_schedule(&queue->txtask);
 }
@@ -519,12 +531,9 @@ void bcm43xx_pio_rx(struct bcm43xx_pioqu
 	int i, preamble_readwords;
 	struct sk_buff *skb;
 
-return;
 	tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXCTL);
-	if (!(tmp & BCM43xx_PIO_RXCTL_DATAAVAILABLE)) {
-		dprintkl(KERN_ERR PFX "PIO RX: No data available\n");//TODO: remove this printk.
+	if (!(tmp & BCM43xx_PIO_RXCTL_DATAAVAILABLE))
 		return;
-	}
 	bcm43xx_pio_write(queue, BCM43xx_PIO_RXCTL,
 			  BCM43xx_PIO_RXCTL_DATAAVAILABLE);
 
@@ -538,8 +547,7 @@ return;
 	return;
 data_ready:
 
-//FIXME: endianess in this function.
-	len = le16_to_cpu(bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA));
+	len = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
 	if (unlikely(len > 0x700)) {
 		pio_rx_error(queue, 0, "len > 0x700");
 		return;
@@ -555,7 +563,7 @@ data_ready:
 		preamble_readwords = 18 / sizeof(u16);
 	for (i = 0; i < preamble_readwords; i++) {
 		tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
-		preamble[i + 1] = cpu_to_be16(tmp);//FIXME?
+		preamble[i + 1] = cpu_to_le16(tmp);
 	}
 	rxhdr = (struct bcm43xx_rxhdr *)preamble;
 	rxflags2 = le16_to_cpu(rxhdr->flags2);
@@ -591,16 +599,40 @@ data_ready:
 	}
 	skb_put(skb, len);
 	for (i = 0; i < len - 1; i += 2) {
-		tmp = cpu_to_be16(bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA));
-		*((u16 *)(skb->data + i)) = tmp;
+		tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
+		*((u16 *)(skb->data + i)) = cpu_to_le16(tmp);
 	}
 	if (len % 2) {
 		tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
 		skb->data[len - 1] = (tmp & 0x00FF);
+/* The specs say the following is required, but
+ * it is wrong and corrupts the PLCP. If we don't do
+ * this, the PLCP seems to be correct. So ifdef it out for now.
+ */
+#if 0
 		if (rxflags2 & BCM43xx_RXHDR_FLAGS2_TYPE2FRAME)
-			skb->data[0x20] = (tmp & 0xFF00) >> 8;
+			skb->data[2] = (tmp & 0xFF00) >> 8;
 		else
-			skb->data[0x1E] = (tmp & 0xFF00) >> 8;
+			skb->data[0] = (tmp & 0xFF00) >> 8;
+#endif
 	}
+	skb_trim(skb, len - IEEE80211_FCS_LEN);
 	bcm43xx_rx(queue->bcm, skb, rxhdr);
 }
+
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue)
+{
+	bcm43xx_power_saving_ctl_bits(queue->bcm, -1, 1);
+	bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
+			  bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL)
+			  | BCM43xx_PIO_TXCTL_SUSPEND);
+}
+
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue)
+{
+	bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
+			  bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL)
+			  & ~BCM43xx_PIO_TXCTL_SUSPEND);
+	bcm43xx_power_saving_ctl_bits(queue->bcm, -1, -1);
+	tasklet_schedule(&queue->txtask);
+}
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_pio.h b/drivers/net/wireless/bcm43xx/bcm43xx_pio.h
index 970627b..dfc7820 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_pio.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_pio.h
@@ -14,8 +14,8 @@
 #define BCM43xx_PIO_RXCTL		0x08
 #define BCM43xx_PIO_RXDATA		0x0A
 
-#define BCM43xx_PIO_TXCTL_WRITEHI	(1 << 0)
-#define BCM43xx_PIO_TXCTL_WRITELO	(1 << 1)
+#define BCM43xx_PIO_TXCTL_WRITELO	(1 << 0)
+#define BCM43xx_PIO_TXCTL_WRITEHI	(1 << 1)
 #define BCM43xx_PIO_TXCTL_COMPLETE	(1 << 2)
 #define BCM43xx_PIO_TXCTL_INIT		(1 << 3)
 #define BCM43xx_PIO_TXCTL_SUSPEND	(1 << 7)
@@ -95,6 +95,7 @@ void bcm43xx_pio_write(struct bcm43xx_pi
 		       u16 offset, u16 value)
 {
 	bcm43xx_write16(queue->bcm, queue->mmio_base + offset, value);
+	mmiowb();
 }
 
 
@@ -107,6 +108,9 @@ void bcm43xx_pio_handle_xmitstatus(struc
 				   struct bcm43xx_xmitstatus *status);
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue);
 
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue);
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue);
+
 #else /* CONFIG_BCM43XX_PIO */
 
 static inline
@@ -133,6 +137,14 @@ static inline
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue)
 {
 }
+static inline
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue)
+{
+}
+static inline
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue)
+{
+}
 
 #endif /* CONFIG_BCM43XX_PIO */
 #endif /* BCM43xx_PIO_H_ */
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 8b37e82..8399de5 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1860,7 +1860,7 @@ static char * __prism2_translate_scan(lo
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
 	if (scan) {
-		chan = scan->chid;
+		chan = le16_to_cpu(scan->chid);
 	} else if (bss) {
 		chan = bss->chan;
 	} else {
@@ -1868,7 +1868,7 @@ static char * __prism2_translate_scan(lo
 	}
 
 	if (chan > 0) {
-		iwe.u.freq.m = freq_list[le16_to_cpu(chan - 1)] * 100000;
+		iwe.u.freq.m = freq_list[chan - 1] * 100000;
 		iwe.u.freq.e = 1;
 		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
 						  IW_EV_FREQ_LEN);
diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index 6b3693f..b1ebfba 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -96,10 +96,13 @@ struct ieee80211softmac_assoc_info {
 	 *
 	 * bssvalid is true if we found a matching network
 	 * and saved it's BSSID into the bssid above.
+	 *
+	 * bssfixed is used for SIOCSIWAP.
 	 */
 	u8 static_essid:1,
 	   associating:1,
-	   bssvalid:1;
+	   bssvalid:1,
+	   bssfixed:1;
 
 	/* Scan retries remaining */
 	int scan_retry;
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index 4498023..fb79ce7 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -144,6 +144,12 @@ network_matches_request(struct ieee80211
 	if (!we_support_all_basic_rates(mac, net->rates_ex, net->rates_ex_len))
 		return 0;
 
+	/* assume that users know what they're doing ...
+	 * (note we don't let them select a net we're incompatible with) */
+	if (mac->associnfo.bssfixed) {
+		return !memcmp(mac->associnfo.bssid, net->bssid, ETH_ALEN);
+	}
+
 	/* if 'ANY' network requested, take any that doesn't have privacy enabled */
 	if (mac->associnfo.req_essid.len == 0 
 	    && !(net->capability & WLAN_CAPABILITY_PRIVACY))
@@ -176,7 +182,7 @@ ieee80211softmac_assoc_work(void *d)
 		ieee80211softmac_disassoc(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
 
 	/* try to find the requested network in our list, if we found one already */
-	if (mac->associnfo.bssvalid)
+	if (mac->associnfo.bssvalid || mac->associnfo.bssfixed)
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);	
 	
 	/* Search the ieee80211 networks for this network if we didn't find it by bssid,
@@ -241,19 +247,25 @@ ieee80211softmac_assoc_work(void *d)
 			if (ieee80211softmac_start_scan(mac))
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
 			return;
-		}
-		else {
+		} else {
 			spin_lock_irqsave(&mac->lock, flags);
 			mac->associnfo.associating = 0;
 			mac->associated = 0;
 			spin_unlock_irqrestore(&mac->lock, flags);
 
 			dprintk(KERN_INFO PFX "Unable to find matching network after scan!\n");
+			/* reset the retry counter for the next user request since we
+			 * break out and don't reschedule ourselves after this point. */
+			mac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_NET_NOT_FOUND, NULL);
 			return;
 		}
 	}
-	
+
+	/* reset the retry counter for the next user request since we
+	 * now found a net and will try to associate to it, but not
+	 * schedule this function again. */
+	mac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 	mac->associnfo.bssvalid = 1;
 	memcpy(mac->associnfo.bssid, found->bssid, ETH_ALEN);
 	/* copy the ESSID for displaying it */
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee80211/softmac/ieee80211softmac_module.c
index 60f06a3..be83bdc 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -45,6 +45,8 @@ struct net_device *alloc_ieee80211softma
 	softmac->ieee->handle_disassoc = ieee80211softmac_handle_disassoc;
 	softmac->scaninfo = NULL;
 
+	softmac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
+
 	/* TODO: initialise all the other callbacks in the ieee struct
 	 *	 (once they're written)
 	 */
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 00f0d4f..27edb2b 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -27,7 +27,8 @@
 #include "ieee80211softmac_priv.h"
 
 #include <net/iw_handler.h>
-
+/* for is_broadcast_ether_addr and is_zero_ether_addr */
+#include <linux/etherdevice.h>
 
 int
 ieee80211softmac_wx_trigger_scan(struct net_device *net_dev,
@@ -83,7 +84,6 @@ ieee80211softmac_wx_set_essid(struct net
 			sm->associnfo.static_essid = 1;
 		}
 	}
-	sm->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 
 	/* set our requested ESSID length.
 	 * If applicable, we have already copied the data in */
@@ -310,8 +310,6 @@ ieee80211softmac_wx_set_wap(struct net_d
 			    char *extra)
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
-	static const unsigned char any[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-	static const unsigned char off[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
 	unsigned long flags;
 
 	/* sanity check */
@@ -320,10 +318,17 @@ ieee80211softmac_wx_set_wap(struct net_d
 	}
 
 	spin_lock_irqsave(&mac->lock, flags);
-	if (!memcmp(any, data->ap_addr.sa_data, ETH_ALEN) ||
-	    !memcmp(off, data->ap_addr.sa_data, ETH_ALEN)) {
-		schedule_work(&mac->associnfo.work);
-		goto out;
+	if (is_broadcast_ether_addr(data->ap_addr.sa_data)) {
+		/* the bssid we have is not to be fixed any longer,
+		 * and we should reassociate to the best AP. */
+		mac->associnfo.bssfixed = 0;
+		/* force reassociation */
+		mac->associnfo.bssvalid = 0;
+		if (mac->associated)
+			schedule_work(&mac->associnfo.work);
+	} else if (is_zero_ether_addr(data->ap_addr.sa_data)) {
+		/* the bssid we have is no longer fixed */
+		mac->associnfo.bssfixed = 0;
         } else {
 		if (!memcmp(mac->associnfo.bssid, data->ap_addr.sa_data, ETH_ALEN)) {
 			if (mac->associnfo.associating || mac->associated) {
@@ -333,12 +338,14 @@ ieee80211softmac_wx_set_wap(struct net_d
 		} else {
 			/* copy new value in data->ap_addr.sa_data to bssid */
 			memcpy(mac->associnfo.bssid, data->ap_addr.sa_data, ETH_ALEN);
-		}	
+		}
+		/* tell the other code that this bssid should be used no matter what */
+		mac->associnfo.bssfixed = 1;
 		/* queue associate if new bssid or (old one again and not associated) */
 		schedule_work(&mac->associnfo.work);
         }
 
-out:
+ out:
 	spin_unlock_irqrestore(&mac->lock, flags);
 	return 0;
 }
-- 
John W. Linville
linville@tuxdriver.com
