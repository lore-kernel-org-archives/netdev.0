From: David Dillow <dave@thedillows.org>
Subject: Re: r8169, enabling TX checksumming breaks things?
Date: Wed, 23 Sep 2009 21:12:32 -0400
Message-ID: <1253754752.13176.19.camel@obelisk.thedillows.org>
References: <200909230915.27854.denys@visp.net.lb>
	 <1253714544.3925.6.camel@lap75545.ornl.gov>
	 <200909231724.23132.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:52355 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754223AbZIXBMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 21:12:39 -0400
In-Reply-To: <200909231724.23132.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-23 at 17:24 +0300, Denys Fedoryschenko wrote:
> On Wednesday 23 September 2009 17:02:24 David Dillow wrote:
> > On Wed, 2009-09-23 at 09:15 +0300, Denys Fedoryschenko wrote:
> > > Hi
> > >
> > > Is it expected that:
> > > 1)TX checksumming is off by default
> > > 2)If i try to enable it over ethtool -K eth0 tx on , TCP sessions on
> > > proxy getting stuck, even in tcpdump looks everything fine and packets
> > > reaching destination, i don't understand what is a reason of failure.
> > > Maybe if this feature supposed to not work - user must not be able just
> > > to turn it on?
> >
> > It is broken for large swaths of the hardware -- I have patches that got
> > it and TSO working on my hardware, and they provide a framework to see
> > about getting it working on yours.
> >
> > Basically, the fields are in different places depending on the chip
> > revision. I'll try to dig those out tonight and send them along so we
> > can experiment.
> Thanks, i have 8 hosts (4 hosts with RTL8168b/8111b. and 4 with 
> RTL8168d/8111d) to test. Ready for patches to test them :-)

This is the patch I have against HEAD, which Works For Me (TM). If I
recall correctly the list in rtl8169_set_tso_csum() is from combing the
vendor drivers, but I'm not 100% on that. Too much time has passed.

I added the MAC version to the driver banner, which should make it
easier to figure out which MAC you have, and to change that function if
it does not work for you out of the box. It seems that some chips don't
work with this at all, based on testing by Michael Riepe (XID 3c4000c0).

As should be obvious, this isn't ready to go anywhere near upstream yet
I think.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 50c6a3c..c58062e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -28,7 +28,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-#define RTL8169_VERSION "2.3LK-NAPI"
+#define RTL8169_VERSION "2.3LK-NAPI-TSO"
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
 
@@ -384,13 +384,19 @@ enum desc_status_bit {
 	FirstFrag	= (1 << 29), /* First segment of a packet */
 	LastFrag	= (1 << 28), /* Final segment of a packet */
 
-	/* Tx private */
+	/* Tx private -- TxDesc->opts1 */
 	LargeSend	= (1 << 27), /* TCP Large Send Offload (TSO) */
 	MSSShift	= 16,        /* MSS value position */
 	MSSMask		= 0xfff,     /* MSS value + LargeSend bit: 12 bits */
 	IPCS		= (1 << 18), /* Calculate IP checksum */
 	UDPCS		= (1 << 17), /* Calculate UDP/IP checksum */
 	TCPCS		= (1 << 16), /* Calculate TCP/IP checksum */
+
+	/* Tx private -- TxDesc->opts2 */
+	UDPCS_2		= (1 << 31), /* Calculate UDP/IP checksum */
+	TCPCS_2		= (1 << 30), /* Calculate TCP/IP checksum */
+	IPCS_2		= (1 << 29), /* Calculate IP checksum */
+	MSSShift_2	= 18,        /* MSS value position */
 	TxVlanTag	= (1 << 17), /* Add VLAN tag */
 
 	/* Rx private */
@@ -2310,11 +2316,12 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (netif_msg_probe(tp)) {
 		u32 xid = RTL_R32(TxConfig) & 0x9cf0f8ff;
 
-		printk(KERN_INFO "%s: %s at 0x%lx, "
+		printk(KERN_INFO "%s: %s (%d) at 0x%lx, "
 		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
 		       "XID %08x IRQ %d\n",
 		       dev->name,
 		       rtl_chip_info[tp->chipset].name,
+		       rtl_chip_info[tp->chipset].mac_version,
 		       dev->base_addr,
 		       dev->dev_addr[0], dev->dev_addr[1],
 		       dev->dev_addr[2], dev->dev_addr[3],
@@ -3299,7 +3306,7 @@ static void rtl8169_tx_timeout(struct net_device *dev)
 }
 
 static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
-			      u32 opts1)
+			      u32 opts1, u32 opts2)
 {
 	struct skb_shared_info *info = skb_shinfo(skb);
 	unsigned int cur_frag, entry;
@@ -3323,6 +3330,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 
 		txd->opts1 = cpu_to_le32(status);
+		txd->opts2 = cpu_to_le32(opts2);
 		txd->addr = cpu_to_le64(mapping);
 
 		tp->tx_skb[entry].len = len;
@@ -3336,24 +3344,64 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 	return cur_frag;
 }
 
-static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
+static void rtl8169_set_tso_csum(struct sk_buff *skb, struct net_device *dev,
+				u32 *opts1, u32 *opts2)
 {
-	if (dev->features & NETIF_F_TSO) {
-		u32 mss = skb_shinfo(skb)->gso_size;
+	struct rtl8169_private *tp = netdev_priv(dev);
+	const struct iphdr *ip = ip_hdr(skb);
+	u32 mss = 0;
 
-		if (mss)
-			return LargeSend | ((mss & MSSMask) << MSSShift);
-	}
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		const struct iphdr *ip = ip_hdr(skb);
+	if (dev->features & NETIF_F_TSO)
+		mss = skb_shinfo(skb)->gso_size;
 
-		if (ip->protocol == IPPROTO_TCP)
-			return IPCS | TCPCS;
-		else if (ip->protocol == IPPROTO_UDP)
-			return IPCS | UDPCS;
-		WARN_ON(1);	/* we need a WARN() */
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01: case RTL_GIGA_MAC_VER_02:
+	case RTL_GIGA_MAC_VER_03: case RTL_GIGA_MAC_VER_04:
+	case RTL_GIGA_MAC_VER_05: case RTL_GIGA_MAC_VER_06:
+	case RTL_GIGA_MAC_VER_10: case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12: case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_16: case RTL_GIGA_MAC_VER_17:
+		/* LargeSend implies checksums, as IPCS et al occupy the
+		 * same bits as the MSS.
+		 *
+		 * FIXME: MSS may actually go in opts2 on all MAC versions,
+		 * but I only have the one below so I'll keep this as it was.
+		 */
+		if (mss) {
+			*opts1 |= LargeSend;
+			*opts1 |= (mss & MSSMask) << MSSShift;
+		} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			if (ip->protocol == IPPROTO_TCP)
+				*opts1 |= IPCS | TCPCS;
+			else if (ip->protocol == IPPROTO_UDP)
+				*opts1 |= IPCS | UDPCS;
+			else
+				WARN_ON_ONCE(1);
+		}
+		break;
+	default:
+		/* LargeSend implies checksums
+		 */
+		if (mss) {
+			/* This used to put (mss & MSSMask) << MSSShift
+			 * in opts1, but that causes my NIC to retransmit
+			 * the last packet over and over and over again...
+			 *
+			 * I have XID 281000c0, so this may be different
+			 * for other chips. Testers welcomed!
+			 */
+			*opts1 |= LargeSend;
+			*opts2 |= (mss & MSSMask) << MSSShift_2;
+		} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			if (ip->protocol == IPPROTO_TCP)
+				*opts2 |= IPCS_2 | TCPCS_2;
+			else if (ip->protocol == IPPROTO_UDP)
+				*opts2 |= IPCS_2 | UDPCS_2;
+			else
+				WARN_ON_ONCE(1);
+		}
+		break;
 	}
-	return 0;
 }
 
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -3365,7 +3413,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	void __iomem *ioaddr = tp->mmio_addr;
 	dma_addr_t mapping;
 	u32 status, len;
-	u32 opts1;
+	u32 opts1, opts2;
 
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
 		if (netif_msg_drv(tp)) {
@@ -3379,9 +3427,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
 		goto err_stop;
 
-	opts1 = DescOwn | rtl8169_tso_csum(skb, dev);
+	opts1 = DescOwn;
+	opts2 = rtl8169_tx_vlan_tag(tp, skb);
+	rtl8169_set_tso_csum(skb, dev, &opts1, &opts2);
 
-	frags = rtl8169_xmit_frags(tp, skb, opts1);
+	frags = rtl8169_xmit_frags(tp, skb, opts1, opts2);
 	if (frags) {
 		len = skb_headlen(skb);
 		opts1 |= FirstFrag;
@@ -3395,7 +3445,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
-	txd->opts2 = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
+	txd->opts2 = cpu_to_le32(opts2);
 
 	wmb();
 


