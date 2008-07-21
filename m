From: Simon Arlott <simon@fire.lp0.eu>
Subject: e1000 82546EB MSI support
Date: Mon, 21 Jul 2008 22:41:34 +0100
Message-ID: <4885028E.5050405@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

MSI support was added to e1000 a long time ago:

Commit fa4f7ef3aaa6cee6b04ebe90266ee893e0b2ce07 (Wed Nov 1 08:48:10 2006 -0800)
[e1000: MSI support for PCI-e adapters]
+       if(adapter->hw.mac_type > e1000_82547_rev_2) {
+               adapter->have_msi = TRUE;
+               if((err = pci_enable_msi(adapter->pdev))) {
+                       DPRINTK(PROBE, ERR,
+                        "Unable to allocate MSI interrupt Error: %d\n", err);
+                       adapter->have_msi = FALSE;
+               }
+       }

and commit 9ac98284428961bd5be285a6cc1f5e6f5b6644aa (Thu Apr 28 19:39:13 2005 -0700)
[e1000: add dynamic generic MSI interrupt routine]
-       if (adapter->hw.mac_type > e1000_82547_rev_2) {
+       if (adapter->hw.mac_type >= e1000_82571) {

Is there are reason why it's only enabled for >= e1000_82571? This isn't explained in 
the commit descriptions or in comments (aside from mentioning that the support is for 
PCI-e cards).

82546EB appears to support it (lspci below), but I get multiple TX hangs if I enable it:

[  230.518382] e1000: em0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[  230.522873] ADDRCONF(NETDEV_CHANGE): em0: link becomes ready
[  234.683290] e1000: em0: e1000_clean_tx_irq: Detected Tx Unit Hang
[  234.683293]   Tx Queue             <0>
[  234.683295]   TDH                  <6>
[  234.683296]   TDT                  <6>
[  234.683298]   next_to_use          <6>
[  234.683299]   next_to_clean        <4>
[  234.683300] buffer_info[next_to_clean]
[  234.683302]   time_stamp           <fffef59d>
[  234.683303]   next_to_watch        <4>
[  234.683305]   jiffies              <ffff00db>
[  234.683306]   next_to_watch.status <10>
[  236.683701] e1000: em0: e1000_clean_tx_irq: Detected Tx Unit Hang
[  236.683703]   Tx Queue             <0>
[  236.683704]   TDH                  <6>
[  236.683705]   TDT                  <6>
[  236.683705]   next_to_use          <6>
[  236.683706]   next_to_clean        <4>
[  236.683707] buffer_info[next_to_clean]
[  236.683707]   time_stamp           <fffef59d>
[  236.683708]   next_to_watch        <4>
[  236.683709]   jiffies              <ffff08ab>
[  236.683710]   next_to_watch.status <10>
[  238.683697] e1000: em0: e1000_clean_tx_irq: Detected Tx Unit Hang
[  238.683699]   Tx Queue             <0>
[  238.683700]   TDH                  <6>
[  238.683700]   TDT                  <6>
[  238.683701]   next_to_use          <6>
[  238.683702]   next_to_clean        <4>
[  238.683703] buffer_info[next_to_clean]
[  238.683703]   time_stamp           <fffef59d>
[  238.683704]   next_to_watch        <4>
[  238.683705]   jiffies              <ffff107b>
[  238.683705]   next_to_watch.status <10>

It manages to receive a couple of packets sometimes (like IPv6 RAs)...


04:00.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet Controller (Copper) (rev 01)
        Subsystem: Intel Corporation PRO/1000 MT Dual Port Server Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (63750ns min), Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 19
        Region 0: Memory at fe9e0000 (64-bit, non-prefetchable) [size=128K]
        Region 4: I/O ports at dc00 [size=64]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [e4] PCI-X non-bridge device
                Command: DPERE- ERO+ RBC=512 OST=1
                Status: Dev=04:00.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
        Capabilities: [f0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000
        Kernel driver in use: e1000

04:00.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet Controller (Copper) (rev 01)
        Subsystem: Intel Corporation PRO/1000 MT Dual Port Server Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (63750ns min), Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 18
        Region 0: Memory at fe9c0000 (64-bit, non-prefetchable) [size=128K]
        Region 4: I/O ports at d880 [size=64]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [e4] PCI-X non-bridge device
                Command: DPERE- ERO+ RBC=512 OST=1
                Status: Dev=04:00.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
        Capabilities: [f0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000
        Kernel driver in use: e1000

-- 
Simon Arlott

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
