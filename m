From: Brian Haley <brian.haley@hp.com>
Subject: bnx2 receive ring crash
Date: Fri, 12 Feb 2010 16:50:20 -0500
Message-ID: <4B75CD1C.7090808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Montgomery, Bob" <bob.montgomery@hp.com>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:30098 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab0BLWHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 17:07:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

We've been seeing some crashes in the bnx2 driver lately in the 2.6.32.x stable
series kernels, v2.0.2 of the driver.  One of our engineers has gone through
the dumps and found some inconsistencies in the receive ring, but we don't know
how it happened.  I was hoping someone from Broadcom might be able to take a
look and help point us in the right direction so we can track this down, since
it's most likely broken upstream as well.  We'll be running tests against
the latest net-next kernel next week.  Hopefully there is enough information
below.

Thanks for any help,

-Brian


# ethtool -i eth4
driver: bnx2
version: 2.0.2
firmware-version: 5.0.6
bus-info: 0000:07:00.0

07:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
        Subsystem: Hewlett-Packard Company NC382T PCI Express Dual Port Multifunction Gigabit Server Adapter
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 32
        Region 0: Memory at f8000000 (64-bit, non-prefetchable) [size=32M]
        [virtual] Expansion ROM at dc100000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/4 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=9
                Vector table: BAR=0 offset=0000c000
                PBA: BAR=0 offset=0000e000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s <4us, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x4, ASPM L0s L1, Latency L0 <4us, L1 <4us
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Device Serial Number 04-21-af-fe-ff-81-24-00
        Capabilities: [110] Advanced Error Reporting <?>
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Kernel driver in use: bnx2
        Kernel modules: bnx2


Kernel Crash dump info:

crash-5.0.fix> sys
      KERNEL: kernel_link
    DUMPFILE: dump.201001241024  [PARTIAL DUMP]
        CPUS: 16
        DATE: Sun Jan 24 10:23:20 2010
      UPTIME: 1 days, 11:27:27
LOAD AVERAGE: 11.16, 11.47, 10.71
       TASKS: 360
    NODENAME: dl380g6-6.ned.telco
     RELEASE: 2.6.32-clim-3-amd64
     VERSION: #1 SMP Wed Jan 6 22:06:39 UTC 2010
     MACHINE: x86_64  (2267 Mhz)
      MEMORY: 12 GB
       PANIC: "[127452.588891] Oops: 0000 [#1] SMP " (check log for details)

This is a 2.6.32.2 stable kernel with a few backports, but the network drivers haven't
been touched.

>From dmesg:
[127452.577999] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[127452.582207] IP: [<ffffffffa00539b7>] bnx2_poll_work+0xc16/0x1111 [bnx2]

>From dis -l bnx2_poll_work:
/build/buildd/linux-2.6-clim-2.6.32-clim/debian/build/build_amd64_none_amd64/drivers/net/bnx2.c: 3007
0xffffffffa00539b7 <bnx2_poll_work+0xc16>:      mov    0x8(%rsi),%rax
0xffffffffa00539bb <bnx2_poll_work+0xc1a>:      mov    %rax,-0x98(%rbp)

Line 3007 is in inlined routine bnx2_rx_skb.

3002		rx_pg = &rxr->rx_pg_ring[pg_cons];
3003
3004		/* Don't unmap yet.  If we're unable to allocate a new
3005		 * page, we need to recycle the page and the DMA addr.
3006		 */
3007		mapping_old = pci_unmap_addr(rx_pg, mapping);
3008		if (i == pages - 1)
3009			frag_len -= 4;

But the rx_pg_ring isn't set up, and we are only here because the l2_fhdr
struct is full of garbage:

3094		rx_hdr = (struct l2_fhdr *) skb->data;
3095		len = rx_hdr->l2_fhdr_pkt_len;

/build/buildd/linux-2.6-clim-2.6.32-clim/debian/build/build_amd64_none_amd64/drivers/net/bnx2.c: 3094
0xffffffffa00531a7 <bnx2_poll_work+0x406>:      mov    0xd8(%r12),%rax
0xffffffffa00531af <bnx2_poll_work+0x40e>:      mov    %rax,-0x160(%rbp)

(0xd8 is offset of unsigned char *data in struct sk_buff.)

rx_hdr is 0xffff88018ddcd020

crash-5.0.fix> struct l2_fhdr 0xffff88018ddcd020
struct l2_fhdr {
  l2_fhdr_status = 0x28000000,
  l2_fhdr_hash = 0x3a7,
  l2_fhdr_vlan_tag = 0x0,
  l2_fhdr_pkt_len = 0x3000,   <<<<<<<<<<<<<<<<< NOT
  l2_fhdr_tcp_udp_xsum = 0x3a7,
  l2_fhdr_ip_xsum = 0x0
}

The l2_fhdr_pkt_len isn't really 0x3000.  The whole data area of this
skb is a page of test data from our networking test:

crash-5.0.fix> x/512xg 0xffff88018ddcd000
0xffff88018ddcd000:     0x000003a708000000      0x000003a710000000
0xffff88018ddcd010:     0x000003a718000000      0x000003a720000000
0xffff88018ddcd020:     0x000003a728000000      0x000003a730000000
0xffff88018ddcd030:     0x000003a738000000      0x000003a740000000
0xffff88018ddcd040:     0x000003a748000000      0x000003a750000000
0xffff88018ddcd050:     0x000003a758000000      0x000003a760000000
0xffff88018ddcd060:     0x000003a768000000      0x000003a770000000
...

That test pattern consists of an unaligned array of 8-byte integers that
increment by 8.   (0x3a708, 0x3a710, 0x3a718, 0x3a720, ...)

I spent a lot of time trying to show that some other part of the kernel
had trashed our ring of sk_buff data, but have concluded that this is
just an uninitialized "size-4096" allocation from a bnx2_alloc_rx_skb
that has not been filled in by the card yet.  So why are we trying to
process it in bnx2_rx_int?

Getting the ring info:

struct bnx2_napi is 0xffff8801a420cf00  
--------------------------------------

   Got this from the saved 2nd param to bnx2_poll_work:
   0xffffffffa0052db8 <bnx2_poll_work+0x17>:  mov %rsi,-0x1a0(%rbp)

   From oops tombstone in dmesg: RBP: ffff880028203e30
   crash-5.0.fix> x/xg 0xffff880028203e30-0x1a0
   0xffff880028203c90:     0xffff8801a420cf00

struct bnx2 is 0xffff8801a420c5c0
---------------------------------

   Got this from struct bnx2_napi:
   crash-5.0.fix> struct bnx2_napi.bp 0xffff8801a420cf00
   bp = 0xffff8801a420c5c0,

The 9 receive (rx) rings associated with this bnx2 struct:

crash-5.0.fix> struct bnx2 0xffff8801a420c5c0 | grep -e "rx_prod =" -e rx_cons -e hw_rx_cons_ptr -e rx_buf_ring

      hw_rx_cons_ptr = 0xffff8801a4de6012,  *hw_rx_cons_ptr in dump: 0x0001
        rx_prod = 0x101,
        rx_cons = 0x1,
        rx_buf_ring = 0xffffc900067bd000,

      hw_rx_cons_ptr = 0xffff8801a4de6080,  *hw_rx_cons_ptr in dump: 0xcac7
        rx_prod = 0xcbc7,
        rx_cons = 0xcac7,
        rx_buf_ring = 0xffffc900067e2000,

      hw_rx_cons_ptr = 0xffff8801a4de6100,  *hw_rx_cons_ptr in dump: 0x2cbd
        rx_prod = 0x2d90,
        rx_cons = 0x2c90,
        rx_buf_ring = 0xffffc900067e5000,

      hw_rx_cons_ptr = 0xffff8801a4de6180,  *hw_rx_cons_ptr in dump: 0x3f3f
        rx_prod = 0x403f,
        rx_cons = 0x3f3f,
        rx_buf_ring = 0xffffc900067e8000,

/* This is the ring that we're on when we fail: */
/* The value of hw_cons left on the stack when we entered bnx2_rx_int: 0xcac8
      hw_rx_cons_ptr = 0xffff8801a4de6200,  *hw_rx_cons_ptr in dump: 0xcb48
        rx_prod = 0x6cce,
        rx_cons = 0x6bce,
        rx_buf_ring = 0xffffc900067eb000,

      hw_rx_cons_ptr = 0xffff8801a4de6280,  *hw_rx_cons_ptr in dump: 0x2af9
        rx_prod = 0x2bf0,
        rx_cons = 0x2af0,
        rx_buf_ring = 0xffffc900067ee000,

      hw_rx_cons_ptr = 0xffff8801a4de6300,  *hw_rx_cons_ptr in dump: 0x5763
        rx_prod = 0x57f4,
        rx_cons = 0x56f4,
        rx_buf_ring = 0xffffc900067f1000,

      hw_rx_cons_ptr = 0xffff8801a4de6380,  *hw_rx_cons_ptr in dump: 0x9a2b
        rx_prod = 0x9b0f,
        rx_cons = 0x9a0f,
        rx_buf_ring = 0xffffc900067f4000,

      hw_rx_cons_ptr = 0xffff8801a4de6400,  *hw_rx_cons_ptr in dump: 0x0000
        rx_prod = 0x0,
        rx_cons = 0x0,
        rx_buf_ring = 0x0,

      hw_rx_cons_ptr = 0xffff8801a4de6400,
        rx_prod = 0x0,
        rx_cons = 0x0,
        rx_buf_ring = 0x0,

Notes:
   1) The first (0) ring has seen no action.
   2) The last (8) ring isn't initialized.
   3) All other rings have the hw_rx_cons_ptr within the limits
      shown for rx_cons and rx_prod, except for the ring we're on
      when we die.
   4) The bad ring's bnx2_napi info is shown again here:

      hw_rx_cons_ptr = 0xffff8801a4de6200,  *hw_rx_cons_ptr in dump: 0xcb48
        rx_prod = 0x6cce,
        rx_cons = 0x6bce,
        rx_buf_ring = 0xffffc900067eb000,

      The hw_cons left on the stack from the first part of bnx2_rx_int
      is 0xcac8.

	3063         hw_cons = bnx2_get_hw_rx_cons(bnapi);
	3064         sw_cons = rxr->rx_cons;
	3065         sw_prod = rxr->rx_prod;
	...
	3071         while (sw_cons != hw_cons) {

      That value (0xcac8) is way outside of the rx_cons (0x6bce) and
      rx_prod (0x6cce) for this loop.  By the time the dump was captured,
      the memory value of *hw_rx_cons_ptr had increased to 0xcb48.

      Since sw_cons can only catch hw_cons by going around the loop
      about 95 more times, this loop isn't going to terminate without 
      passing through uninitialized skb's.

      The values of sw_cons and sw_prod on the stack at the time of 
      the crash are:
	crash-5.0.fix> x/xh 0xffff880028203e30-0x130
	0xffff880028203d00:     0x6bcf   (sw_cons)
	crash-5.0.fix> x/xh 0xffff880028203e30-0x150
	0xffff880028203ce0:     0x6ccf   (sw_prod)

      The hw_cons left on the stack (0xcac8) is suspiciously similar to
      the value in the apparently well-behaved 2nd rx_loop shown here:

      hw_rx_cons_ptr = 0xffff8801a4de6080,  *hw_rx_cons_ptr in dump: 0xcac7
        rx_prod = 0xcbc7,
        rx_cons = 0xcac7,
        rx_buf_ring = 0xffffc900067e2000,

So I think the crash was caused by some corruption of the hw_rx_cons
index to take it way out of the range of rx_prod and rx_cons on this ring,
and that corruption is suspiciously similar to the hw_rx_cons value of
another ring in the set.

      hw_rx_cons_ptr = 0xffff8801a4de6200,  *hw_rx_cons_ptr in dump: 0xcb48
        rx_prod = 0x6cce,
        rx_cons = 0x6bce,
        rx_buf_ring = 0xffffc900067eb000,

	(hw_cons on stack: 0xcac8)

======================================

To test the theory that skb->data on an rx ring could (at times) look like
a whole page of test pattern, I looked through the uninitialized parts of
the other rings (between hw_cons and rx_prod).  Two of the other rings
also had data buffers that looked like test patterns.  Here is one of them:

rx_buf_ring: 0xffffc900067e5000
        rx_prod = 0x2d90,
        rx_cons = 0x2c90,
	*hw_rx_cons_ptr = 0x2cbd

At index 0x20:  (outside of the range of 0x2c90...0x2cbd)

crash-5.0.fix> p ((struct sw_bd *)0xffffc900067e5000)[0x20]
$5 = {
  skb = 0xffff8801a185b180,
  mapping = 0x194886020
}

crash-5.0.fix> struct sk_buff.data 0xffff8801a185b180
  data = 0xffff880194886020 "",

crash-5.0.fix>   x/512xg 0xffff880194886000
0xffff880194886000:     0x02c6280000000000      0x02c6300000000000
0xffff880194886010:     0x02c6380000000000      0x02c6400000000000
0xffff880194886020:     0x02c6480000000000      0x02c6500000000000
0xffff880194886030:     0x02c6580000000000      0x02c6600000000000
0xffff880194886040:     0x02c6680000000000      0x02c6700000000000
...

