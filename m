From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.7-rc2 + bk-netdev 3/4] r8169: gcc bug workaround
Date: Thu, 3 Jun 2004 01:35:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040603013511.B22272@electric-eye.fr.zoreil.com>
References: <200406010922.i519MIr27814@mail.osdl.org> <40BE2FAB.1040008@pobox.com> <20040603013128.D18059@electric-eye.fr.zoreil.com> <20040603013319.A22272@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, luto@myrealbox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040603013319.A22272@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, Jun 03, 2004 at 01:33:19AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Add a temporary variable to workaround gcc 2.95.3 bug.

diff -puN drivers/net/r8169.c~r8169-gcc-killed-me drivers/net/r8169.c
--- linux-2.6.7-rc2/drivers/net/r8169.c~r8169-gcc-killed-me	2004-06-03 00:15:34.000000000 +0200
+++ linux-2.6.7-rc2-fr/drivers/net/r8169.c	2004-06-03 00:15:34.000000000 +0200
@@ -1542,6 +1542,7 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 
 	if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
 		dma_addr_t mapping;
+		u32 status;
 
 		mapping = pci_map_single(tp->pci_dev, skb->data, len,
 					 PCI_DMA_TODEVICE);
@@ -1549,8 +1550,10 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		tp->Tx_skbuff[entry] = skb;
 		tp->TxDescArray[entry].addr = cpu_to_le64(mapping);
 
-		tp->TxDescArray[entry].status = cpu_to_le32(OWNbit | FSbit |
-			LSbit | len | (EORbit * !((entry + 1) % NUM_TX_DESC)));
+		/* anti gcc 2.95.3 bugware */
+		status = OWNbit | FSbit | LSbit | len |
+			 (EORbit * !((entry + 1) % NUM_TX_DESC));
+		tp->TxDescArray[entry].status = cpu_to_le32(status);
 			
 		RTL_W8(TxPoll, 0x40);	//set polling bit
 

_
