From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Thu, 22 Jan 2009 12:55:21 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: olaf.kirch@oracle.com, tgraf@suug.ch, jesse.brandeburg@intel.com,
	kkeil@suse.de, michaelc@cs.wisc.edu, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32096 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbZAVUz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 15:55:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've filed this bugzilla a while ago.
http://bugzilla.kernel.org/show_bug.cgi?id=11804
now other customers are becoming interested as well

what happens is that when a device driver (inet_lro) hands an skb that has 
possibly multiple skb->data pointers, chained together with skb->next and 
each one possibly having pages attached, skb_seq_read called by iSCSI 
doesn't follow the chain as it should.  result is a panic.

to reproduce you just get lro enabled igb or ixgbe and try to connect to 
an iSCSI target.

BUG: unable to handle kernel NULL pointer dereference at 000005a8
IP: [<f8de64b2>] :iscsi_tcp:iscsi_tcp_recv+0x161/0x473
*pdpt = 0000000036533001 *pde = 0000000000000000
Oops: 0000 [#1] SMP
Modules linked in: crc32c libcrc32c iscsi_tcp libiscsi 
scsi_transport_iscsi
ixgbe netconsole inet_lro ipv6 af_packet button battery ac loop usbhid
ff_memless ehci_hcd uhci_hcd usbcore dm_mod bnx2 ext3 jbd edd fan thermal
processor thermal_sys sg megaraid_sas ata_piix libata dock piix sd_mod 
scsi_mod
ide_disk ide_core [last unloaded: iscsi_tcp]

Pid: 0, comm: swapper Not tainted (2.6.26-bigsmp #1)
EIP: 0060:[<f8de64b2>] EFLAGS: 00010202 CPU: 3
EIP is at iscsi_tcp_recv+0x161/0x473 [iscsi_tcp]
EAX: 0000002b EBX: f747dd48 ECX: 00000038 EDX: 00000000
ESI: 000005a8 EDI: f593db20 EBP: f751ca10 ESP: f747dd20
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f747c000 task=f745abe0 task.ti=f747c000)
Stack: f8de78e7 000000e0 f446c0c0 f6c35544 f751ca00 000005a8 00000000 
000000e0
       000005a8 08745958 00000000 00000a88 00000000 000005a8 f446c0c0 
f78ba0ac
       00000000 c0289617 00000000 00000000 05a80001 00007fff f78ba040 
000005a8
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
Code: 24 14 0f 46 44 24 14 89 44 24 14 50 68 e7 78 de f8 e8 2e b3 33 c7 8b 
7d
08 03 7d 00 8b 4c 24 1c 8b 74 24 20 03 74 24 18 c1 e9 02 <f3> a5 8b 4c 24 
1c 83
e1 03 74 02 f3 a4 8b 4c 24 1c 01 4c 24 18
EIP: [<f8de64b2>] iscsi_tcp_recv+0x161/0x473 [iscsi_tcp] SS:ESP 
0068:f747dd20
Kernel panic - not syncing: Fatal exception in interrupt



skb_copy_bits is an example of the code flow that does work.

skb_seq_read appears to only be used by iSCSI and the skb text match 
support in tc/netfilter (aka skb_find_text)

skb_seq_read is so complex that it is not a simple job just to re-write it 
with a state machine switch statement, and I am unable to spend the time 
on it to fix it.  Can someone help?

I am also a little bit concerned that the recent effort to make GRO frames 
become more utilized in the stack may end up causing this issue to trigger 
as well.

We have test resources that can test patches with iSCSI.
