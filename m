From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 16 Jun 2008 16:45:08 -0700
Message-ID: <1213659908.18055.26.camel@dell>
References: <20080616140454.GD5350@solarflare.com>
 <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com>
 <20080616191354.GA11760@orion.carnet.hr>
 <20080616213821.GA8844@orion.carnet.hr>
 <20080616214829.GA9334@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, mirrors@debian.org
To: "Josip Rodin" <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3047 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbYFPXnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 19:43:43 -0400
In-Reply-To: <20080616214829.GA9334@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-16 at 23:48 +0200, Josip Rodin wrote:
> > Crap, it just crashed again, with 2.6.25.6.

Looking at the panic dmesg, I believe it was crashing because skb was
NULL in bnx2_tx_int().

> 
> I should mention that I might have a clue - around the time the crashes
> started, I started using HTB with the following configuration:

This rings a bell.  A similar crash was reported by a user using HTB on
a tg3 device.  After some analysis, my suspicion was that the shinfo
(skb)->nr_frags on the TX packet was corrupted before the SKB was freed
by the driver.  In both the tg3 and bnx2 drivers, we rely on the
nr_frags to locate the TX packet boundaries on the ring to free the
packets.

Please try this debug patch below.  If the theory is correct, the patch
should avoid the crash and will print something to the dmesg log every
time a crash is avoided.  Please run it again with the HTB rules and
send me the dmesg log containing:

bnx2: skb->nr_frags ...

Here's the debug patch below.  It saves the nr_frags from the SKB and
uses it to locate the packet boundaries instead.  It will also compare
the saved value with the one in SKB and print a warning when they don't
match.  Please apply to 2.6.25.6.

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4b46e68..f7ecd07 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2495,14 +2495,20 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		tx_buf = &bp->tx_buf_ring[sw_ring_cons];
 		skb = tx_buf->skb;
 
+		if (tx_buf->nr_frags != skb_shinfo(skb)->nr_frags) {
+			printk(KERN_ALERT "bnx2: skb->nr_frags=%d is corrupted,"
+					  " should be %d\n",
+					  skb_shinfo(skb)->nr_frags,
+					  tx_buf->nr_frags);
+		}
 		/* partial BD completions possible with TSO packets */
 		if (skb_is_gso(skb)) {
 			u16 last_idx, last_ring_idx;
 
 			last_idx = sw_cons +
-				skb_shinfo(skb)->nr_frags + 1;
+				tx_buf->nr_frags + 1;
 			last_ring_idx = sw_ring_cons +
-				skb_shinfo(skb)->nr_frags + 1;
+				tx_buf->nr_frags + 1;
 			if (unlikely(last_ring_idx >= MAX_TX_DESC_CNT)) {
 				last_idx++;
 			}
@@ -2515,7 +2521,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			skb_headlen(skb), PCI_DMA_TODEVICE);
 
 		tx_buf->skb = NULL;
-		last = skb_shinfo(skb)->nr_frags;
+		last = tx_buf->nr_frags;
 
 		for (i = 0; i < last; i++) {
 			sw_cons = NEXT_TX_BD(sw_cons);
@@ -4806,7 +4812,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 
 		tx_buf->skb = NULL;
 
-		last = skb_shinfo(skb)->nr_frags;
+		last = tx_buf->nr_frags;
 		for (j = 0; j < last; j++) {
 			tx_buf = &bp->tx_buf_ring[i + j + 1];
 			pci_unmap_page(bp->pdev,
@@ -5859,6 +5865,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	last_frag = skb_shinfo(skb)->nr_frags;
 
+	tx_buf->nr_frags = last_frag;
+
 	for (i = 0; i < last_frag; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 1eaf5bb..aa9fa6f 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6485,6 +6485,7 @@ struct l2_fhdr {
 struct sw_bd {
 	struct sk_buff		*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapping)
+	unsigned short		nr_frags;
 };
 
 struct sw_pg {


