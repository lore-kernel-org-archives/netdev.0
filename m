From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 2.6.0-test11-bk27-netdrvr-exp1 - r8169 update
Date: Sun, 30 Nov 2003 01:47:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031130014738.A2589@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <20031126004550.A25408@electric-eye.fr.zoreil.com> <20031127235143.A16767@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="u3/rZRmxL6MmkK24"
Cc: Jeff Garzik <jgarzik@pobox.com>, brad_mssw@gentoo.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031127235143.A16767@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, Nov 27, 2003 at 11:51:43PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hopefully last round of Brad/Realtek's merging. 

Patches apply in this order:
1 - r8169-hw_start.patch
2 - r8169-missing-tx-stats.patch
3 - r8169-intr_mask.patch

on top of:

  2.6.0-test11
+ 2.6.0-test9-bk25-netdrvr-exp1
+ r8169-mac-phy-version
+ r8169-init_one
+ r8169-timer

The unconditional calls to rtl8169_{rx/tx}_interrupt in rtl8169_interrupt()
are not integrated. That should not make a huge difference.

--
Ueimor

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-hw_start.patch"


Merge of changes from Realtek:
- register voodoo in rtl8169_hw_start().


 drivers/net/r8169.c |    6 ++++++
 1 files changed, 6 insertions(+)

diff -puN drivers/net/r8169.c~r8169-hw_start drivers/net/r8169.c
--- linux-2.6.0-test11/drivers/net/r8169.c~r8169-hw_start	2003-11-29 20:36:12.000000000 +0100
+++ linux-2.6.0-test11-fr/drivers/net/r8169.c	2003-11-29 20:44:17.000000000 +0100
@@ -1028,6 +1028,12 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W32(TxConfig,
 		(TX_DMA_BURST << TxDMAShift) | (InterFrameGap <<
 						TxInterFrameGapShift));
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd));
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
+		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0: bit-3 and bit-14 MUST be 1\n");
+		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | (1 << 14) | (1 << 3));
+	}
 
 	tp->cur_rx = 0;
 

_

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-missing-tx-stats.patch"


Driver forgot to update the transmitted bytes counter.
Originally done in rtl8169_start_xmit() by Realtek.


 drivers/net/r8169.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff -puN drivers/net/r8169.c~r8169-missing-tx-stats drivers/net/r8169.c
--- linux-2.6.0-test11/drivers/net/r8169.c~r8169-missing-tx-stats	2003-11-29 22:34:10.000000000 +0100
+++ linux-2.6.0-test11-fr/drivers/net/r8169.c	2003-11-30 00:26:09.000000000 +0100
@@ -1303,10 +1303,13 @@ rtl8169_tx_interrupt(struct net_device *
 			int cur = dirty_tx % NUM_TX_DESC;
 			struct sk_buff *skb = tp->Tx_skbuff[cur];
 
+			/* FIXME: is it really accurate for TxErr ? */
+			tp->stats.tx_bytes += skb->len >= ETH_ZLEN ?
+					      skb->len : ETH_ZLEN;
+			tp->stats.tx_packets++;
 			rtl8169_unmap_tx_skb(tp->pci_dev, tp->Tx_skbuff + cur,
 					     tp->TxDescArray + cur);
 			dev_kfree_skb_irq(skb);
-			tp->stats.tx_packets++;
 			dirty_tx++;
 			tx_left--;
 			entry++;

_

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-intr_mask.patch"

 drivers/net/r8169.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff -puN drivers/net/r8169.c~r8169-intr_mask drivers/net/r8169.c
--- linux-2.6.0-test11/drivers/net/r8169.c~r8169-intr_mask	2003-11-30 01:16:48.000000000 +0100
+++ linux-2.6.0-test11-fr/drivers/net/r8169.c	2003-11-30 01:18:22.000000000 +0100
@@ -334,8 +334,7 @@ static void rtl8169_tx_timeout(struct ne
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 
 static const u16 rtl8169_intr_mask =
-    SYSErr | PCSTimeout | RxUnderrun | RxOverflow | RxFIFOOver | TxErr | TxOK |
-    RxErr | RxOK;
+    RxUnderrun | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
 static const unsigned int rtl8169_rx_config =
     (RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
@@ -1445,9 +1444,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 
-		if ((status &
-		     (SYSErr | PCSTimeout | RxUnderrun | RxOverflow | RxFIFOOver
-		      | TxErr | TxOK | RxErr | RxOK)) == 0)
+		if (!(status & rtl8169_intr_mask))
 			break;
 
 		// Rx interrupt 

_

--u3/rZRmxL6MmkK24--
