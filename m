From: Kai Makisara <Kai.Makisara@kolumbus.fi>
Subject: e1000 lockup in linux 2.6.9-rc2
Date: Mon, 20 Sep 2004 23:53:15 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409202339050.2170@kai.makisara.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When I started large data transfers in 100 Mb/s network, my computer very 
soon locked totally (i.e., not responding to network, keyboard and mouse 
dead). This had not happened for several days with 2.6.9-rc2 when the 
network activity had been light (1 Mb/s DSL).

Some experimentation showed that the lockups were caused by this patch 
fragment in 2.6.9-rc2:

diff -u b/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- b/drivers/net/e1000/e1000_main.c	2004-08-24 00:04:05 -07:00
+++ b/drivers/net/e1000/e1000_main.c	2004-09-12 22:34:24 -07:00
@@ -499,7 +499,9 @@
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-
+ 	/* hard_start_xmit is safe against parallel locking */
+ 	netdev->features |= NETIF_F_LLTX; 
+ 
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* before reading the EEPROM, reset the controller to 

The computer has Intel D875PBZLK motherboard with 1 GB memory and 2.6 GHz 
Pentium4 (HT). An SMP kernel has been used. lspci -vv gives the following 
information about the NIC:

0000:02:01.0 Ethernet controller: Intel Corp. 82547EI Gigabit Ethernet Controller (LOM)
        Subsystem: Intel Corp.: Unknown device 3025
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0 (63750ns min), cache line size 10
        Interrupt: pin A routed to IRQ 185
        Region 0: Memory at ff8e0000 (32-bit, non-prefetchable)
        Region 2: I/O ports at 9c00 [size=32]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-

(This kernel has MSI enabled and thus IRQ is 185. The hangup did occur 
also without MSI.)

-- 
Kai
