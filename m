From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [RFT] r8169 changes against 2.6.22-rc6
Date: Fri, 29 Jun 2007 01:42:22 +0200
Message-ID: <20070628234222.GA8180@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, Roel.Teuwen@advalvas.be,
	Tim Durack <tdurack@gmail.com>,
	Jens Stroebel <drifter@bcsoft.de>,
	Soren Hansen <soren@ubuntu.com>,
	Kacper Bielecki <kazjote@stud.ics.p.lodz.pl>,
	Andrew Paprocki <andrew@ishiboo.com>,
	Clemens Brunner <clemens.brunner@tugraz.at>,
	Alexey Borzenkov <snaury@gmail.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Daniel Drake <dsd@gentoo.org>, Raoul Bhatia <r.bhatia@ipax.at>,
	Philip Craig <philipc@snapgear.com>,
	Mike Isely <isely@pobox.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	mirek kratochvil <exa.exa@gmail.com>,
	Mathew <mathewfer@gmail.com>,
	Oleg Verych <olecom@flower.upol.cz>,
	Will Trives <will@trivescon.com.au>,
	"Thomas A. Oehser" <tom@toms.net>,
	James Morris <jmorris@namei.org>,
	"Boris B. Zhmurov" <bb@kernel
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932448AbXF1Xro@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The latest serie of r8169 changes is available against 2.6.22-rc6 as:
http://www.fr.zoreil.com/people/francois/misc/20070628-2.6.22-rc6-r8169-test.patch

or (tarball sits one level higher):

http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/

or (rebase prone branch)

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#r8169
 
Please do not clone your whole git kernel tree from here, thanks.

Changes (most recent first):

- perform RX config change after mac filtering
- mac address change support
- display some extra debug information during startup
- add endianess annotations to [RT]xDesc
- align the IP header when there is no DMA constraint
- add bit description for the TxPoll register
- cleanup
- remove the media option
- small 8101 comment
- confusion between hardware and IP header alignment
- merge with version 8.001.00 of Realtek's r8168 driver
- merge with version 6.001.00 of Realtek's r8169 driver
- prettify mac_version
- populate the hw_start handler for the 8110
- populate the hw_start handler for the 8168
- add helpers for per-device hw_start handler
- add hooks for per-device hw_start handler
- Rx path update
- kill eth_copy_and_sum()
- de-obfuscate modulo arithmetic
- use netdev_alloc_skb

Use of this serie is strongly suggested if:
- you own an asrock ConRoe945G-DVI
- you need bonding
- you need to fix the performance regression due to misalignment

This serie should fix the non-wol related issues if you are an asus P5B
user.

Catastrophic events apart, the patches will be sent for review on netdev
tomorow and scheduled for inclusion in 2.6.23.

Success and failure reports or patches will be welcome. Please Cc: netdev
and include "r8169" in the Subject.

As a bonus, the patch below on top of the current serie could help Benjamin
(and probably others too). It's still WIP though.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2fe3652..dc302c2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2518,7 +2518,7 @@ static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned int frags, cur_tx, entry = tp->cur_tx % NUM_TX_DESC;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
 	dma_addr_t mapping;
@@ -2571,13 +2571,17 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
+	cur_tx = tp->cur_tx;
+
 	tp->cur_tx += frags + 1;
 
-	smp_wmb();
+	mmiowb();
 
-	RTL_W8(TxPoll, NPQ);	/* set polling bit */
+	smp_mb();
 
-	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+	if (cur_tx == tp->dirty_tx)
+		RTL_W8(TxPoll, NPQ);
+	else if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
 		smp_rmb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
@@ -2681,10 +2685,18 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-		smp_wmb();
-		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
-			netif_wake_queue(dev);
+		smp_mb();
+		if (unlikely(netif_queue_stopped(dev))) {
+			netif_tx_lock(dev);
+		    	if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+				netif_wake_queue(dev);
+			if (dirty_tx != tp->cur_tx)
+				RTL_W8(TxPoll, NPQ);
+			netif_tx_unlock(dev);
+		} else if (dirty_tx != tp->cur_tx) {
+			netif_tx_lock(dev);
+			RTL_W8(TxPoll, NPQ);
+			netif_tx_unlock(dev);
 		}
 	}
 }

-- 
Ueimor
