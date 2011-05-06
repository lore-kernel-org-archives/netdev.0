From: David Miller <davem@davemloft.net>
Subject: [PATCH] hamachi: Delete TX checksumming code commented out since
 1999
Date: Fri, 06 May 2011 11:59:45 -0700 (PDT)
Message-ID: <20110506.115945.104066424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753883Ab1EFTAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 15:00:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D843024C088
	for <netdev@vger.kernel.org>; Fri,  6 May 2011 11:59:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


TX checksumming support has been ifdef commented out of this driver
for more than 10 years, and it makes references to aspects of the IPv4
stack from back then as well.

If someone has one of these rare cards and wants to properly resurrect
TX checksumming support, they can still get at this code in the
version control history.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I stumbled over this cruft while auditing ip_queue_xmit() users.

 drivers/net/hamachi.c |   79 -------------------------------------------------
 1 files changed, 0 insertions(+), 79 deletions(-)

diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 80d25ed..f5fba73 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -132,14 +132,8 @@ static int tx_params[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 /*
  * RX_CHECKSUM turns on card-generated receive checksum generation for
  *   TCP and UDP packets.  Otherwise the upper layers do the calculation.
- * TX_CHECKSUM won't do anything too useful, even if it works.  There's no
- *   easy mechanism by which to tell the TCP/UDP stack that it need not
- *   generate checksums for this device.  But if somebody can find a way
- *   to get that to work, most of the card work is in here already.
  * 3/10/1999 Pete Wyckoff <wyckoff@ca.sandia.gov>
  */
-#undef  TX_CHECKSUM
-#define RX_CHECKSUM
 
 /* Operational parameters that usually are not changed. */
 /* Time in jiffies before concluding the transmitter is hung. */
@@ -630,11 +624,6 @@ static int __devinit hamachi_init_one (struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-#ifdef TX_CHECKSUM
-	printk("check that skbcopy in ip_queue_xmit isn't happening\n");
-	dev->hard_header_len += 8;  /* for cksum tag */
-#endif
-
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = 1 ? read_eeprom(ioaddr, 4 + i)
 			: readb(ioaddr + StationAddr + i);
@@ -937,11 +926,7 @@ static int hamachi_open(struct net_device *dev)
 
 	/* always 1, takes no more time to do it */
 	writew(0x0001, ioaddr + RxChecksum);
-#ifdef TX_CHECKSUM
-	writew(0x0001, ioaddr + TxChecksum);
-#else
 	writew(0x0000, ioaddr + TxChecksum);
-#endif
 	writew(0x8000, ioaddr + MACCnfg); /* Soft reset the MAC */
 	writew(0x215F, ioaddr + MACCnfg);
 	writew(0x000C, ioaddr + FrameGap0);
@@ -1226,40 +1211,6 @@ static void hamachi_init_ring(struct net_device *dev)
 }
 
 
-#ifdef TX_CHECKSUM
-#define csum_add(it, val) \
-do { \
-    it += (u16) (val); \
-    if (it & 0xffff0000) { \
-	it &= 0xffff; \
-	++it; \
-    } \
-} while (0)
-    /* printk("add %04x --> %04x\n", val, it); \ */
-
-/* uh->len already network format, do not swap */
-#define pseudo_csum_udp(sum,ih,uh) do { \
-    sum = 0; \
-    csum_add(sum, (ih)->saddr >> 16); \
-    csum_add(sum, (ih)->saddr & 0xffff); \
-    csum_add(sum, (ih)->daddr >> 16); \
-    csum_add(sum, (ih)->daddr & 0xffff); \
-    csum_add(sum, cpu_to_be16(IPPROTO_UDP)); \
-    csum_add(sum, (uh)->len); \
-} while (0)
-
-/* swap len */
-#define pseudo_csum_tcp(sum,ih,len) do { \
-    sum = 0; \
-    csum_add(sum, (ih)->saddr >> 16); \
-    csum_add(sum, (ih)->saddr & 0xffff); \
-    csum_add(sum, (ih)->daddr >> 16); \
-    csum_add(sum, (ih)->daddr & 0xffff); \
-    csum_add(sum, cpu_to_be16(IPPROTO_TCP)); \
-    csum_add(sum, htons(len)); \
-} while (0)
-#endif
-
 static netdev_tx_t hamachi_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
@@ -1292,36 +1243,6 @@ static netdev_tx_t hamachi_start_xmit(struct sk_buff *skb,
 
 	hmp->tx_skbuff[entry] = skb;
 
-#ifdef TX_CHECKSUM
-	{
-	    /* tack on checksum tag */
-	    u32 tagval = 0;
-	    struct ethhdr *eh = (struct ethhdr *)skb->data;
-	    if (eh->h_proto == cpu_to_be16(ETH_P_IP)) {
-		struct iphdr *ih = (struct iphdr *)((char *)eh + ETH_HLEN);
-		if (ih->protocol == IPPROTO_UDP) {
-		    struct udphdr *uh
-		      = (struct udphdr *)((char *)ih + ih->ihl*4);
-		    u32 offset = ((unsigned char *)uh + 6) - skb->data;
-		    u32 pseudo;
-		    pseudo_csum_udp(pseudo, ih, uh);
-		    pseudo = htons(pseudo);
-		    printk("udp cksum was %04x, sending pseudo %04x\n",
-		      uh->check, pseudo);
-		    uh->check = 0;  /* zero out uh->check before card calc */
-		    /*
-		     * start at 14 (skip ethhdr), store at offset (uh->check),
-		     * use pseudo value given.
-		     */
-		    tagval = (14 << 24) | (offset << 16) | pseudo;
-		} else if (ih->protocol == IPPROTO_TCP) {
-		    printk("tcp, no auto cksum\n");
-		}
-	    }
-	    *(u32 *)skb_push(skb, 8) = tagval;
-	}
-#endif
-
         hmp->tx_ring[entry].addr = cpu_to_leXX(pci_map_single(hmp->pci_dev,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
 
-- 
1.7.5.1

