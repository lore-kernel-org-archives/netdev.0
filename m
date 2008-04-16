From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/13] sb1250: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:34 -0700
Message-ID: <20080416233757.467685157@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	"Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43796 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138AbYDPXth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:37 -0400
Content-Disposition: inline; filename=sb1250
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb. This sets skb->dev and allows arch specific
allocation. Also simplify and cleanup the alignment code.

Not tested, depends on non-x86 hardware

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sb1250-mac.c	2008-04-02 10:55:30.000000000 -0700
+++ b/drivers/net/sb1250-mac.c	2008-04-16 16:32:06.000000000 -0700
@@ -179,7 +179,6 @@ enum sbmac_state {
 #define SBMAC_MAX_TXDESCR	256
 #define SBMAC_MAX_RXDESCR	256
 
-#define ETHER_ALIGN	2
 #define ETHER_ADDR_LEN	6
 #define ENET_PACKET_SIZE	1518
 /*#define ENET_PACKET_SIZE	9216 */
@@ -777,16 +776,13 @@ static void sbdma_channel_stop(struct sb
 	d->sbdma_remptr = NULL;
 }
 
-static void sbdma_align_skb(struct sk_buff *skb,int power2,int offset)
+static inline void sbdma_align_skb(struct sk_buff *skb,
+				   unsigned power2, unsigned offset)
 {
-	unsigned long addr;
-	unsigned long newaddr;
+	unsigned long addr = skb->data;
+	unsigned long newaddr = PTR_ALIGN(addr, power2);
 
-	addr = (unsigned long) skb->data;
-
-	newaddr = (addr + power2 - 1) & ~(power2 - 1);
-
-	skb_reserve(skb,newaddr-addr+offset);
+	skb_reserve(skb, newaddr - addr + offset);
 }
 
 
@@ -848,14 +844,15 @@ static int sbdma_add_rcvbuffer(struct sb
 	 */
 
 	if (sb == NULL) {
-		sb_new = dev_alloc_skb(ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER_ALIGN);
+		sb_new = netdev_alloc_skb(dev, ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2
+					  + NET_IP_ALIGN);
 		if (sb_new == NULL) {
 			pr_info("%s: sk_buff allocation failed\n",
 			       d->sbdma_eth->sbm_dev->name);
 			return -ENOBUFS;
 		}
 
-		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, ETHER_ALIGN);
+		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, NET_IP_ALIGN);
 	}
 	else {
 		sb_new = sb;

-- 

