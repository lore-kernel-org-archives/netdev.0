From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Mon, 21 Jun 2004 22:33:50 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <E1BcNzi-0000eh-00@gondolin.me.apana.org.au>
References: <1087568322.4455.22.camel@localhost>
Cc: linux-kernel@vger.kernel.org, davem@redhat.com,
	benh@kernel.crashing.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266212AbUFUMew@vger.kernel.org>
To: kernel@nn7.de (Soeren Sonnenburg)
In-Reply-To: <1087568322.4455.22.camel@localhost>
List-Id: netdev.vger.kernel.org

Soeren Sonnenburg <kernel@nn7.de> wrote:
> 
> When I have some ethernet connection and then do:
> 
> ifconfig eth0 mtu 1300
> 
> I get an immediate kernel panic (kernel 2.6.6) on a powerbook g4 15"
> 1ghz.
> 
> xmon trace (jpeg) is here: http://www.nn7.de/kernel/mtu1300.jpg  (use a
> webbrowser to view it as it is a redirect)
> 
> this is 100% reproducable here so I hope it is more easy to fix.

Does this patch fix your problems?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== drivers/net/sungem.c 1.56 vs edited =====
--- 1.56/drivers/net/sungem.c	2004-06-19 17:16:13 +10:00
+++ edited/drivers/net/sungem.c	2004-06-21 22:28:40 +10:00
@@ -33,6 +33,7 @@
 #include <linux/crc32.h>
 #include <linux/random.h>
 #include <linux/workqueue.h>
+#include <linux/if_vlan.h>
 
 #include <asm/system.h>
 #include <asm/bitops.h>
@@ -742,7 +743,7 @@
 				       PCI_DMA_FROMDEVICE);
 			gp->rx_skbs[entry] = new_skb;
 			new_skb->dev = gp->dev;
-			skb_put(new_skb, (ETH_FRAME_LEN + RX_OFFSET));
+			skb_put(new_skb, (VLAN_ETH_FRAME_LEN + RX_OFFSET));
 			rxd->buffer = cpu_to_le64(pci_map_page(gp->pdev,
 							       virt_to_page(new_skb->data),
 							       offset_in_page(new_skb->data),
@@ -1482,6 +1483,9 @@
 
 	gem_clean_rings(gp);
 
+	gp->rx_buf_sz = min(dev->mtu + ETH_HLEN + VLAN_HLEN,
+			    (unsigned)VLAN_ETH_FRAME_LEN);
+
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
 		struct gem_rxd *rxd = &gb->rxd[i];
@@ -1495,7 +1499,7 @@
 
 		gp->rx_skbs[i] = skb;
 		skb->dev = dev;
-		skb_put(skb, (ETH_FRAME_LEN + RX_OFFSET));
+		skb_put(skb, (VLAN_ETH_FRAME_LEN + RX_OFFSET));
 		dma_addr = pci_map_page(gp->pdev,
 					virt_to_page(skb->data),
 					offset_in_page(skb->data),
===== drivers/net/sungem.h 1.14 vs edited =====
--- 1.14/drivers/net/sungem.h	2004-01-26 18:03:59 +11:00
+++ edited/drivers/net/sungem.h	2004-06-21 22:24:46 +10:00
@@ -911,7 +911,7 @@
 	  (GP)->tx_old - (GP)->tx_new - 1)
 
 #define RX_OFFSET          2
-#define RX_BUF_ALLOC_SIZE(gp)	((gp)->dev->mtu + 46 + RX_OFFSET + 64)
+#define RX_BUF_ALLOC_SIZE(gp)	((gp)->rx_buf_sz + 32 + RX_OFFSET + 64)
 
 #define RX_COPY_THRESHOLD  256
 
@@ -979,6 +979,7 @@
 	int			rx_fifo_sz;
 	int			rx_pause_off;
 	int			rx_pause_on;
+	int			rx_buf_sz;
 	int			mii_phy_addr;
 
 	u32			mac_rx_cfg;
