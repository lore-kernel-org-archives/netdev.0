From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH][REPOST] 21143 Tulip problems with 10BaseT
Date: Thu, 02 Sep 2004 14:27:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3isaw7t4i.fsf@defiant.pm.waw.pl>
References: <m3brk8pwre.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <m3brk8pwre.fsf@defiant.pm.waw.pl> (Krzysztof Halasa's message
 of "Fri, 28 May 2004 14:21:57 +0200")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Looking at my kernel tree I noticed this patch has not been applied.
I'm currently unable to test it, but it was required in the past and
I don't think the situation has changed.

Please apply. Thanks.

--- linux-2.6/drivers/net/tulip/21142.c	19 Mar 2004 15:01:15 -0000
+++ linux-2.6/drivers/net/tulip/21142.c	2 Sep 2004 12:26:31 -0000
@@ -149,11 +149,13 @@
 		else if (negotiated & 0x0080)	dev->if_port = 3;
 		else if (negotiated & 0x0040)	dev->if_port = 4;
 		else if (negotiated & 0x0020)	dev->if_port = 0;
-		else {
+		else if ((csr12 & 2) == 0 && (tp->sym_advertise & 0x0180))
+			dev->if_port = 3;
+		else if ((csr12 & 4) == 0 && (tp->sym_advertise & 0x0060))
+			dev->if_port = 0;
+		else
 			tp->nwayset = 0;
-			if ((csr12 & 2) == 0  &&  (tp->sym_advertise & 0x0180))
-				dev->if_port = 3;
-		}
+
 		tp->full_duplex = (tulip_media_cap[dev->if_port] & MediaAlwaysFD) ? 1:0;
 
 		if (tulip_debug > 1) {


My original mail:

From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] 21143 Tulip problems with 10BaseT
To: Jeff Garzik <jgarzik@pobox.com>
Cc: <netdev@oss.sgi.com>
Date: Fri, 28 May 2004 14:21:57 +0200

Current 2.4 and 2.6 kernels have problems with Tulip 21143 on 10BaseT
link (with not-NWay-capable 10 Mbps peer) - tulip_debug shows:

Linux Tulip driver version 1.1.13 (May 11, 2002)
tulip0:  EEPROM default media type Autosense.
tulip0:  Index #0 - Media 10baseT (#0) described by a 21142 Serial PHY (2) block.
tulip0:  Index #1 - Media 10baseT-FDX (#4) described by a 21142 Serial PHY (2) block.
tulip0:  Index #2 - Media 100baseTx (#3) described by a 21143 SYM PHY (4) block.
tulip0:  Index #3 - Media 100baseTx-FDX (#5) described by a 21143 SYM PHY (4) block.
eth2: Digital DS21143 Tulip rev 48 at 0xe400, 00:C0:CA:13:48:10, IRQ 9.
eth2: Restarting 21143 autonegotiation, csr14=0003ffff.
eth2: tulip_up(), irq==9.
eth2: Restarting 21143 autonegotiation, csr14=0003ffff.
eth2: Done tulip_up(), CSR0 ffa08000, CSR5 f0760000 CSR6 b2422202.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: interrupt  csr5=0xf0668010 new csr5=0xf0660000.
eth2: 21143 link status interrupt 000050ca, CSR5 f0668010, fffbffff.
                                  ^^^^^^^^ = got NLP but no FLP (no NWay)
eth2: Autonegotiation failed, using 10baseT, link beat status 50ca.
      ... while we know the peer is using NLP and therefore is 10BaseT-HD
      capable.
eth2: 21143 non-MII 10baseT transceiver control 08af/00a5.
eth2:  Setting CSR15 to 08af0008/00a50008.
eth2: Using media type 10baseT, CSR12 is c6.
eth2:  Setting CSR6 82420000/b2422002 CSR12 000010c6.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: 21143 negotiation status 000010c6, 10baseT.
eth2: 21143 negotiation failed, status 000010c6.
eth2: Testing new 21143 media 100baseTx.
eth2: interrupt  csr5=0xf0008102 new csr5=0xf0000000.
eth2: The transmitter stopped.  CSR5 is f0008102, CSR6 b2420000, new CSR6 83860000.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: 21143 negotiation status 000000c6, 100baseTx.
eth2: No 21143 100baseTx link beat, 000000c6, trying NWay.
eth2: Restarting 21143 autonegotiation, csr14=0003ffff.
eth2: interrupt  csr5=0xf0008102 new csr5=0xf0000000.
eth2: The transmitter stopped.  CSR5 is f0008102, CSR6 b2420200, new CSR6 82420200.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: interrupt  csr5=0xf0668010 new csr5=0xf0660000.
eth2: 21143 link status interrupt 000050ca, CSR5 f0668010, fffbffff.
eth2: Autonegotiation failed, using 10baseT, link beat status 50ca.



After the attached patch is applied:



eth2: Restarting 21143 autonegotiation, csr14=0003ffff.
eth2: tulip_up(), irq==9.
eth2: Restarting 21143 autonegotiation, csr14=0003ffff.
eth2: Done tulip_up(), CSR0 ffa08000, CSR5 f0360000 CSR6 b2422202.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: interrupt  csr5=0xf0670004 new csr5=0xf0660000.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: interrupt  csr5=0xf0668010 new csr5=0xf0660000.
eth2: 21143 link status interrupt 000050ca, CSR5 f0668010, fffbffff.
                                  ^^^^^^^^
      The same here - 0x50CA = got NLP, negotiation ok (seems like NLP only
      sets this bit as well), no 100 Mbps link status (whatever that means).

eth2: Switching to 10baseT based on link negotiation 01e0 & 0000 = 0000.

      Correct, we haven't received FLP so no "capability bits" are present.

eth2: 21143 non-MII 10baseT transceiver control 08af/00a5.
eth2:  Setting CSR15 to 08af0008/00a50008.
eth2: Using media type 10baseT, CSR12 is c6.
eth2:  Setting CSR6 82420000/b2422002 CSR12 000010c6.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: 21143 negotiation status 000010c6, 10baseT.
                                   ^^^^
      Not sure about it (no 10 nor 100 Mbps link pulse?). But the chip does
      it this way. Possibly the bit should be cleared before read?

eth2: Using NWay-set 10baseT media, csr12 000010c6.
eth2: interrupt  csr5=0xf0668010 new csr5=0xf0660000.
eth2: 21143 link status interrupt 000050ca, CSR5 f0668010, fff8ffff.
eth2: 21143 10baseT link beat good.
eth2: exiting interrupt, csr5=0xf0660000.
eth2: 21143 negotiation status 000050ca, 10baseT.
eth2: Using NWay-set 10baseT media, csr12 000050ca.
eth2: 21143 negotiation status 000050ca, 10baseT.
eth2: Using NWay-set 10baseT media, csr12 000050ca.


The chip on this card (Micronet SP2500K - Taiwan I think) is DEC 21143-PC:
00:08.0 Class 0200: 1011:0019 (rev 30)
        Subsystem: 1113:1207
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (5000ns min, 10000ns max), Cache Line Size 08
        Interrupt: pin A routed to IRQ 9
        Region 0: I/O ports at e400 [size=128]
        Region 1: Memory at eb901000 (32-bit, non-prefetchable) [size=128]
        Expansion ROM at e9000000 [disabled] [size=256K]


I'm not sure if it's optimal fix, though.
-- 
Krzysztof Halasa
