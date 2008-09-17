From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: [BUG 2.6.26] iscsi: LRO plus iSCSI causes panic
Date: Wed, 17 Sep 2008 16:25:59 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0809171558140.2536@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We found that just trying to connect with no authentication to an iSCSI 
target over an adapter running either the in-kernel LRO or an in-driver 
version will cause this panic.

This log was taken on stock 2.6.26, out of tree ixgbe driver using 
in-kernel LRO (the in-kernel driver for ixgbe will support LRO in 2.6.27)

I tried to debug down a ways but got lost in figuring out what the code 
was trying to do.  I believe the bug is because the memcpy in 
iscsi_tcp_segment_recv faults.

from looking at the debug messages below, 
skb_seq_read returns a negative value for avail, and a pointer value of 
5a8 into &ptr in the call at line 953: of iscsi_tcp.c

I didn't figure out where in skb_seq_read returns the bogus data, I wanted 
to send this along now that I've found out this much.

skb_seq_read appears to have the logic inside that it needs to handle LRO 
packets (data either in frags[] or frag_list) but something is wrong 
still.

I turned on tcp_debug messages in iscsi_tcp.c, here is the log and panic.  
I believe the offsets in the function are slightly different than normal 
due to the inclusion of the debug printks.

The normal panic is at 
EIP:    0060:[<f8c9c285>]    Tainted: G     U VLI
EFLAGS: 00010206   (2.6.16.60-0.17-bigsmp #1)
EIP is at iscsi_tcp_recv+0xe5/0x3e9 [iscsi_tcp]
eax: 00000088   ebx: c0393ce4   ecx: 00000022   edx: 00000178
esi: 000005a8   edi: f5a90778   ebp: f7c69810   esp: c0393cc0
ds: 007b   es: 007b   ss: 0068

 .config is available on request, we are using i686 arch, dell 2950, ixgbe 
adapter, inet_lro module.

console [netcon0] enabled
netconsole: network logging started
ixgbe: eth6: ixgbe_remove: complete
ACPI: PCI interrupt for device 0000:0c:00.0 disabled
ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 1.3.41-NAPI
Copyright (c) 1999-2008 Intel Corporation.
ACPI: PCI Interrupt 0000:0c:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:0c:00.0 to 64
ixgbe: 0000:0c:00.0: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 4, Tx Queue count = 1
ixgbe: eth0: ixgbe_probe: (PCI Express:2.5Gb/s:Width x4) 00:1b:21:09:1b:44
ixgbe: eth0: ixgbe_probe: MAC: 1, PHY: 2
ixgbe: eth0: ixgbe_probe: PCI-Express bandwidth available for this card is not sufficient for optimal performance.
ixgbe: eth0: ixgbe_probe: For optimal performance a x8 PCI-Express slot is required.
ixgbe: eth0: ixgbe_probe: In-kernel LRO is enabled
ixgbe: eth0: ixgbe_probe: Intel(R) 10 Gigabit Network Connection
ADDRCONF(NETDEV_UP): eth6: link is not ready
ixgbe: eth6: ixgbe_watchdog_task: NIC Link is Up 10 Gbps, Flow Control: None
ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
eth6: no IPv6 routers present
Loading iSCSI transport class v2.0-869.
iscsi: registered transport (tcp)
iscsi: registered transport (tcp)
scsi3 : iSCSI Initiator over TCP/IP
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: iscsi_tcp_send_linear_data_prepare(f751ca00, datalen=464)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 464 total_size 464
tcp: copied 0 0 size 464 xmit
tcp: copied 0 464 size 464 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 464 total size 464
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 464 total size 464
tcp: in 380 bytes
tcp: skb f446cb40 ptr=f446f854 avail=380
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x23 ahslen 0 datalen 331
tcp: skb f446cb40 ptr=f446f884 avail=332
tcp: copied 0 0 size 331 recv
tcp: iscsi_tcp_segment_recv copying 331
tcp: copied 0 331 size 331 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 331 total size 331
tcp: consume 1 pad bytes
tcp: iscsi_tcp_segment_recv copying 1
tcp: copied 0 1 size 1 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 332 total size 332
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 380
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: xmit 512 bytes
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 84 bytes
tcp: skb f446ca80 ptr=f446f054 avail=84
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 36
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=36)
tcp: skb f446ca80 ptr=f446f084 avail=36
tcp: copied 0 0 size 36 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 36
tcp: copied 0 36 size 36 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 36 total size 36
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 84
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 124 bytes
tcp: skb f446c9c0 ptr=f6540854 avail=124
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 74
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=74)
tcp: skb f446c9c0 ptr=f6540884 avail=76
tcp: copied 0 0 size 74 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 74
tcp: copied 0 74 size 74 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 74 total size 74
tcp: consume 2 pad bytes
tcp: iscsi_tcp_segment_recv copying 2
tcp: copied 0 2 size 2 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 76 total size 76
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 124
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
scsi 3:0:0:0: Direct-Access     SUN      LCSM100_I        0670 PQ: 0 ANSI: 5
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 48 bytes
tcp: skb f446c900 ptr=f6540054 avail=48
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x21 ahslen 0 datalen 0
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 48
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 56 bytes
tcp: skb f446c840 ptr=f6541854 avail=56
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 8
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=8)
tcp: skb f446c840 ptr=f6541884 avail=8
tcp: copied 0 0 size 8 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 8
tcp: copied 0 8 size 8 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 8 total size 8
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 56
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
sd 3:0:0:0: [sdb] 190421401 512-byte hardware sectors (97496 MB)
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 52 bytes
tcp: skb f446c780 ptr=f6541054 avail=52
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 4
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=4)
tcp: skb f446c780 ptr=f6541084 avail=4
tcp: copied 0 0 size 4 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 4
tcp: copied 0 4 size 4 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 4 total size 4
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 52
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
sd 3:0:0:0: [sdb] Write Protect is off
sd 3:0:0:0: [sdb] Mode Sense: 77 00 10 08
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 52 bytes
tcp: skb f446c6c0 ptr=f6542854 avail=52
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 4
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=4)
tcp: skb f446c6c0 ptr=f6542884 avail=4
tcp: copied 0 0 size 4 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 4
tcp: copied 0 4 size 4 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 4 total size 4
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 52
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 80 bytes
tcp: skb f446c600 ptr=f6542054 avail=80
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 32
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=32)
tcp: skb f446c600 ptr=f6542084 avail=32
tcp: copied 0 0 size 32 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 32
tcp: copied 0 32 size 32 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 32 total size 32
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 80
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, supports DPO and FUA
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 48 bytes
tcp: skb f446c540 ptr=f6543854 avail=48
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x21 ahslen 0 datalen 0
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 48
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 56 bytes
tcp: skb f446c480 ptr=f6543054 avail=56
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 8
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=8)
tcp: skb f446c480 ptr=f6543084 avail=8
tcp: copied 0 0 size 8 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 8
tcp: copied 0 8 size 8 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 8 total size 8
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 56
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
sd 3:0:0:0: [sdb] 190421401 512-byte hardware sectors (97496 MB)
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 52 bytes
tcp: skb f446c3c0 ptr=f6544854 avail=52
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 4
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=4)
tcp: skb f446c3c0 ptr=f6544884 avail=4
tcp: copied 0 0 size 4 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 4
tcp: copied 0 4 size 4 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 4 total size 4
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 52
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
sd 3:0:0:0: [sdb] Write Protect is off
sd 3:0:0:0: [sdb] Mode Sense: 77 00 10 08
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 52 bytes
tcp: skb f446c300 ptr=f6544054 avail=52
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 4
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=4)
tcp: skb f446c300 ptr=f6544084 avail=4
tcp: copied 0 0 size 4 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 4
tcp: copied 0 4 size 4 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 4 total size 4
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 52
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 80 bytes
tcp: skb f446c240 ptr=f6545854 avail=80
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 32
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=32)
tcp: skb f446c240 ptr=f6545884 avail=32
tcp: copied 0 0 size 32 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 32
tcp: copied 0 32 size 32 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 32 total size 32
tcp: segment done
tcp: iscsi_tcp_hdr_recv_prep(f751ca00)
tcp: no more data avail. Consumed 80
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 48 total size 48
tcp: Header done. Next segment size 0 total_size 0
tcp: copied 0 0 size 0 xmit
tcp: iscsi_tcp_segment_unmap f751cb4c
tcp: total copied 0 total size 0
tcp: xmit 48 bytes
sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, supports DPO and FUA
 sdb:<6>tcp: iscsi_tcp_send_hdr_prep(f751ca00)
tcp: copied 0 0 size 48 xmit
tcp: copied 0 48 size 48 xmit
tcp: in 1448 bytes
tcp: skb f446c180 ptr=f6545054 avail=1448
tcp: copied 0 0 size 48 recv
tcp: iscsi_tcp_segment_recv copying 48
tcp: copied 0 48 size 48 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: total copied 48 total size 48
tcp: segment done
tcp: opcode 0x25 ahslen 0 datalen 4096
tcp: iscsi_tcp_begin_data_in(f751ca00, offset=0, datalen=4096)
tcp: skb f446c180 ptr=f6545084 avail=1400
tcp: copied 0 0 size 512 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 512
tcp: copied 0 512 size 512 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 512 total size 4096
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 512
tcp: copied 0 512 size 512 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 1024 total size 4096
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 376
tcp: copied 0 376 size 512 recv
tcp: iscsi_tcp_segment_recv copied 1400 bytes
tcp: no more data avail. Consumed 1448
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: in 2696 bytes
tcp: skb f446c0c0 ptr=f6546854 avail=1448
tcp: copied 376 0 size 512 recv
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 136
tcp: copied 376 136 size 512 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 1536 total size 4096
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 512
tcp: copied 0 512 size 512 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 2048 total size 4096
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 512
tcp: copied 0 512 size 512 recv
tcp: iscsi_tcp_segment_unmap f751ca10
tcp: iscsi_tcp_segment_unmap valid
tcp: total copied 2560 total size 4096
tcp: iscsi_tcp_segment_map recv f751ca10
tcp: iscsi_tcp_segment_recv copying 288
tcp: copied 0 288 size 512 recv
tcp: iscsi_tcp_segment_recv copied 1448 bytes
tcp: skb f446c0c0 ptr=000005a8 avail=141842776
tcp: copied 288 0 size 512 recv
tcp: iscsi_tcp_segment_recv copying 224
BUG: unable to handle kernel NULL pointer dereference at 000005a8
IP: [<f8de64b2>] :iscsi_tcp:iscsi_tcp_recv+0x161/0x473
*pdpt = 0000000036533001 *pde = 0000000000000000
Oops: 0000 [#1] SMP
Modules linked in: crc32c libcrc32c iscsi_tcp libiscsi scsi_transport_iscsi ixgbe netconsole inet_lro ipv6 af_packet button battery ac loop usbhid ff_memless ehci_hcd uhci_hcd usbcore dm_mod bnx2 ext3 jbd edd fan thermal processor thermal_sys sg megaraid_sas ata_piix libata dock piix sd_mod scsi_mod ide_disk ide_core [last unloaded: iscsi_tcp]

Pid: 0, comm: swapper Not tainted (2.6.26-bigsmp #1)
EIP: 0060:[<f8de64b2>] EFLAGS: 00010202 CPU: 3
EIP is at iscsi_tcp_recv+0x161/0x473 [iscsi_tcp]
EAX: 0000002b EBX: f747dd48 ECX: 00000038 EDX: 00000000
ESI: 000005a8 EDI: f593db20 EBP: f751ca10 ESP: f747dd20
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f747c000 task=f745abe0 task.ti=f747c000)
Stack: f8de78e7 000000e0 f446c0c0 f6c35544 f751ca00 000005a8 00000000 000000e0
       000005a8 08745958 00000000 00000a88 00000000 000005a8 f446c0c0 f78ba0ac
       00000000 c0289617 00000000 00000000 05a80001 00007fff f78ba040 000005a8
Call Trace:
 [<c0289617>] tcp_ack+0x15bd/0x1757
 [<c028391e>] tcp_read_sock+0x8c/0x1e0
 [<f8de6351>] iscsi_tcp_recv+0x0/0x473 [iscsi_tcp]
 [<f8de716a>] iscsi_tcp_data_ready+0x36/0x80 [iscsi_tcp]
 [<c028d1a2>] tcp_send_ack+0xab/0xaf
 [<c028c02e>] tcp_rcv_established+0x3b3/0x639
 [<c02909fb>] tcp_v4_do_rcv+0x22/0x16f
 [<c0292294>] tcp_v4_rcv+0x512/0x562
 [<c027b921>] ip_local_deliver_finish+0xb2/0x14a
 [<c027b852>] ip_rcv_finish+0x286/0x2a3
 [<f8ce9a93>] packet_rcv_spkt+0xb6/0xbd [af_packet]
 [<c0261889>] netif_receive_skb+0x2d0/0x33b
 [<f8afd5ca>] lro_flush+0x314/0x340 [inet_lro]
 [<f8afd636>] lro_flush_all+0x1b/0x28 [inet_lro]
 [<f8b410eb>] ixgbe_clean_rx_irq+0x73b/0x850 [ixgbe]
 [<f8b44183>] ixgbe_clean_rxonly+0x53/0xd0 [ixgbe]
 [<c0263521>] net_rx_action+0x8a/0x152
 [<c0124c6e>] __do_softirq+0x5d/0xc1
 [<c0124d04>] do_softirq+0x32/0x36
 [<c010663a>] do_IRQ+0x73/0x85
 [<c0109152>] mwait_idle+0x0/0x32
 [<c0105143>] common_interrupt+0x23/0x28
 [<c0109152>] mwait_idle+0x0/0x32
 [<c0109181>] mwait_idle+0x2f/0x32
 [<c0103535>] cpu_idle+0x88/0x9c
 =======================
Code: 24 14 0f 46 44 24 14 89 44 24 14 50 68 e7 78 de f8 e8 2e b3 33 c7 8b 7d 08 03 7d 00 8b 4c 24 1c 8b 74 24 20 03 74 24 18 c1 e9 02 <f3> a5 8b 4c 24 1c 83 e1 03 74 02 f3 a4 8b 4c 24 1c 01 4c 24 18
EIP: [<f8de64b2>] iscsi_tcp_recv+0x161/0x473 [iscsi_tcp] SS:ESP 0068:f747dd20
Kernel panic - not syncing: Fatal exception in interrupt

