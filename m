From: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Subject: r8169 - panic and a fix
Date: Wed, 8 Sep 2004 22:24:23 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409082224.23829.sriharivijayaraghavan@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

As of 2.6.9-rc1-bk11, r8169 does not work on my Athlon 64 machine. It results 
in a panic :-(.

Here is the oops message for your information:
NET: Registered protocol family 1
----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at skbuff:91
invalid operand: 0000 [1] 
CPU 0 
Modules linked in: r8169 af_packet ipt_REJECT ipt_state ip_conntrack 
iptable_filter ip_tables ide_cd cdrom via_rhine mii crc32 floppy radeon 
reiserfs dm_mod uhci_hcd ehci_hcd usbcore button rtc unix
Pid: 1424, comm: ifup Not tainted 2.6.9-rc1-bk14
RIP: 0010:[<ffffffff80255172>] <ffffffff80255172>{skb_over_panic+50}
RSP: 0000:ffffffff80399328  EFLAGS: 00010292
RAX: 0000000000000036 RBX: 0000000000000c00 RCX: 000000000001ffff
RDX: 0000000000000006 RSI: 0000000000000000 RDI: ffffffff802f8880
RBP: 0000010036eda360 R08: 0000000000000036 R09: 0000000000000003
R10: 00000000ffffffff R11: 0000000000000000 R12: 0000000000000bfc
R13: 0000000000000000 R14: 0000000000000000 R15: 0000010036fca000
FS:  0000002a9556cd60(0000) GS:ffffffff803f0740(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000039cbd054d0 CR3: 0000000000101000 CR4: 00000000000006e0
Process ifup (pid: 1424, threadinfo 0000010036fd2000, task 000001003f7e07d0)
Stack: 000000000000000a ffffffffa00faf66 0000000000000bfc ffffffffa00fb3c0 
       0000010080399368 0000010036eda000 000001003fc34c80 0000000000008001 
       ffffff0000052000 0000000000000014 
Call Trace:<IRQ> <ffffffffa00faf66>{:r8169:rtl8169_rx_interrupt+502} 
       <ffffffffa00fb3c0>{:r8169:pci_unmap_single+0} 
<ffffffffa00fb0d3>{:r8169:rtl8169_interrupt+147} 
       <ffffffff801124ec>{handle_IRQ_event+44} <ffffffff80112683>{do_IRQ+147} 
       <ffffffff80110021>{ret_from_intr+0}  <EOI> 

Code: 0f 0b 8c 29 2d 80 ff ff ff ff 5b 00 48 83 c4 08 c3 66 66 66 
RIP <ffffffff80255172>{skb_over_panic+50} RSP <ffffffff80399328>
 <0>Kernel panic - not syncing: Aiee, killing interrupt handler!

Reversing this patch, which first appeared in 2.6.9-rc1-bk11, fixes the 
problem:
diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c       2004-07-02 11:51:44 -07:00
+++ b/drivers/net/r8169.c       2004-08-31 00:15:35 -07:00
@@ -983,7 +983,7 @@

        tp->cp_cmd = PCIMulRW | RxChkSum;

-       if ((sizeof(dma_addr_t) > 32) &&
+       if ((sizeof(dma_addr_t) > 4) &&
            !pci_set_dma_mask(pdev, DMA_64BIT_MASK))
                tp->cp_cmd |= PCIDAC;
        else {

In other words, no problem with 2.6.9-rc1-bk14 minus that patch.

Here is the lspci -vv for my card:
00:13.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit 
Ethernet (rev 10)
        Subsystem: Giga-byte Technology: Unknown device e000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size 08
        Interrupt: pin A routed to IRQ 18
        Region 0: I/O ports at e800
        Region 1: Memory at e3005000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

If you need more information, please ask.

Thank you.

Hari
