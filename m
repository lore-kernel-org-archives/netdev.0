From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.9-rc2 1/1] r8169: default on disabling PCIDAC
Date: Tue, 21 Sep 2004 01:36:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920233610.GB15760@electric-eye.fr.zoreil.com>
References: <20040919224102.GA32577@electric-eye.fr.zoreil.com> <414F1DFD.9030008@pobox.com> <20040920190252.GA16429@electric-eye.fr.zoreil.com> <414F2B4F.3080606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans-Frieder Vogt <hfvogt@arcor.de>, Andy Lutomirski <luto@myrealbox.com>,
        Jon Mason <jdmason@us.ibm.com>,
        Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <414F2B4F.3080606@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> It's only a one-time operation that occurs on weird 64-bit boxes :)
> 
> I applied the using_dac stuff, but do think there is _some_ better way.

Chainsaw coded patch below. It seems to be able to recover on my 32 bit
system (the 'dtc' thing is not really needed). On real 64 bit host,
people will have to disable NETIF_F_HIGHDMA, set an adequate dma mask
and probably reallocate Tx and Rx rings (from irq context: joy and
happyness). May be it would make sense to prevent allocating the rings
on high memory from the start.

Btw, the adapter apparently quiesce if the following sequence is not
used:
+                       tp->cp_cmd &= ~PCIDAC;
+                       RTL_W16(CPlusCmd, tp->cp_cmd);
+                       RTL_W8(ChipCmd, CmdReset | CmdTxEnb | CmdRxEnb);


diff -puN drivers/net/r8169.c~r8169-145b-6 drivers/net/r8169.c
--- linux-2.6.9-rc2/drivers/net/r8169.c~r8169-145b-6	2004-09-21 01:00:17.000000000 +0200
+++ linux-2.6.9-rc2-fr/drivers/net/r8169.c	2004-09-21 01:04:04.000000000 +0200
@@ -1483,6 +1483,11 @@ rtl8169_hw_start(struct net_device *dev)
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 
+	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
+	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
+	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
+	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
+
 	/* Soft reset the chip. */
 	RTL_W8(ChipCmd, CmdReset);
 
@@ -1494,7 +1499,6 @@ rtl8169_hw_start(struct net_device *dev)
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
 	// For gigabit rtl8169
@@ -1509,24 +1513,9 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W32(TxConfig,
 		(TX_DMA_BURST << TxDMAShift) | (InterFrameGap <<
 						TxInterFrameGapShift));
-	tp->cp_cmd |= RTL_R16(CPlusCmd);
-	RTL_W16(CPlusCmd, tp->cp_cmd);
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
-		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
-			"Bit-3 and bit-14 MUST be 1\n");
-		tp->cp_cmd |= (1 << 14) | PCIMulRW;
-		RTL_W16(CPlusCmd, tp->cp_cmd);
-	}
-
 	tp->cur_rx = 0;
 
-	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
-	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
-	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
-	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
 	RTL_W8(Cfg9346, Cfg9346_Lock);
-	udelay(10);
 
 	RTL_W32(RxMissed, 0);
 
@@ -1538,6 +1527,17 @@ rtl8169_hw_start(struct net_device *dev)
 	/* Enable all known interrupts by setting the interrupt mask. */
 	RTL_W16(IntrMask, rtl8169_intr_mask);
 
+	tp->cp_cmd |= RTL_R16(CPlusCmd);
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
+		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
+			"Bit-3 and bit-14 MUST be 1\n");
+		tp->cp_cmd |= (1 << 14) | PCIMulRW;
+	}
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+
 	netif_start_queue(dev);
 }
 
@@ -2056,11 +2056,31 @@ rtl8169_interrupt(int irq, void *dev_ins
 			break;
 
 		if (unlikely(status & SYSErr)) {
-			printk(KERN_ERR PFX "%s: PCI error (status: 0x%04x)."
-			       " Device disabled.\n", dev->name, status);
-			RTL_W8(ChipCmd, 0x00);
-			RTL_W16(IntrMask, 0x0000);
-			RTL_R16(IntrMask);
+			struct pci_dev *pdev = tp->pci_dev;
+			static int dtc = 0;
+			u16 pci_status, pci_cmd;
+
+			pci_read_config_word(pdev, PCI_COMMAND, &pci_cmd);
+			pci_write_config_word(pdev, PCI_COMMAND, 0x0157);
+			pci_read_config_word(pdev, PCI_STATUS, &pci_status);
+			pci_write_config_word(pdev, PCI_STATUS,
+					      pci_status & 0xf800);
+			printk(KERN_ERR PFX
+			       "%s: PCI error (cmd:status=0x%04x:%04x)\n",
+			       dev->name, pci_cmd, pci_status);
+
+			tp->cp_cmd &= ~PCIDAC;
+			RTL_W16(CPlusCmd, tp->cp_cmd);
+			RTL_W8(ChipCmd, CmdReset | CmdTxEnb | CmdRxEnb);
+
+			if (dtc++ > 128) {
+				printk(KERN_ERR PFX
+				       "%s: disabled (status: 0x%04x)\n",
+				       dev->name, status);
+				RTL_W8(ChipCmd, 0x00);
+				RTL_W16(IntrMask, 0x0000);
+				RTL_R16(IntrMask);
+			}
 			break;
 		}
 

_
