From: Petr Vandrovec <petr@vandrovec.name>
Subject: [PATCH] Unbreak sky2 on 88E8039 with current git
Date: Sat, 2 Feb 2008 11:52:43 +0100
Message-ID: <20080202105243.GA14581@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vana.vc.cvut.cz ([147.32.240.58]:37424 "EHLO vana.vc.cvut.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753950AbYBBLNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 06:13:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
  since I synced my tree to Linus's one two days ago, sky2's packet receiption
dies almost instantly.  Device still transmits packets, but no receive.  
Fortunately fix is simple, unfortunately I do not know why fix works...

Commit f03b865491c2f30f2a4d77cdafc69c978ceb38a0 (sky2: align IP header on Rx
if possible) stopped aligning receive buffers on devices which do not need
HANG_CHECK.  Unfortunately there is at least one device (mine, Yukon FE, rev 3)
which is not happy if receive buffer is not aligned.  I have no idea which
other chips/revisions are affected as well.

Without patch 'ping -f -b 192.168.101.255' RX count stops incrementing in less
than 50 packets.  With patch in place it can run like before, for hours...
Box is an AMD rev F processor, with nVidia's MCP61 chipset.
							Petr

gwy:/home/petr# lspci -vv -s 4:0.0  
04:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8039 PCI-E Fast Ethernet Controller (rev 14)
        Subsystem: Elitegroup Computer Systems Unknown device 8039
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 377
        Region 0: Memory at fdcfc000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at 8c00 [size=256]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
                Address: 00000000fee0300c  Data: 41c9
        Capabilities: [e0] Express (v1) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <256ns, L1 unlimited
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Kernel driver in use: sky2
        Kernel modules: sky2


Yukon FE, rev 3 needs receive buffers aligned, otherwise receiver hangs
almost instantly.  They were aligned before, so let's start aligning
them again - a bit suboptimal networking is much better than no networking
at all.

Signed-off-by: Petr Vandrovec <petr@vandrovec.name>

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1192,7 +1192,7 @@ static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
 	struct sk_buff *skb;
 	int i;
 
-	if (sky2->hw->flags & SKY2_HW_FIFO_HANG_CHECK) {
+	if (sky2->hw->flags & SKY2_HW_FIFO_RX_ALIGN) {
 		unsigned char *start;
 		/*
 		 * Workaround for a bug in FIFO that cause hang
@@ -2718,7 +2718,7 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 		hw->flags = SKY2_HW_GIGABIT
 			| SKY2_HW_NEWER_PHY;
 		if (hw->chip_rev < 3)
-			hw->flags |= SKY2_HW_FIFO_HANG_CHECK;
+			hw->flags |= SKY2_HW_FIFO_HANG_CHECK | SKY2_HW_FIFO_RX_ALIGN;
 
 		break;
 
@@ -2745,10 +2745,12 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 			dev_err(&hw->pdev->dev, "unsupported revision Yukon-EC rev A1\n");
 			return -EOPNOTSUPP;
 		}
-		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_FIFO_HANG_CHECK;
+		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_FIFO_HANG_CHECK | SKY2_HW_FIFO_RX_ALIGN;
 		break;
 
 	case CHIP_ID_YUKON_FE:
+		if (hw->chip_rev == 3)
+			hw->flags |= SKY2_HW_FIFO_RX_ALIGN;
 		break;
 
 	case CHIP_ID_YUKON_FE_P:
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 2bced1a..b5c1457 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2049,6 +2049,7 @@ struct sky2_hw {
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
+#define SKY2_HW_FIFO_RX_ALIGN	0x00000100
 
 	u8	     	     chip_id;
 	u8		     chip_rev;
