From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: tg3 kernel BUG at include/linux/netdevice.h:918!
Date: Fri, 8 Feb 2008 11:06:15 +0100
Message-ID: <20080208100615.GA17375@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:56600 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759225AbYBHKaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 05:30:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FWIW,

kernel 2.6.22.10, tainted with nvidia and vmware. BUG triggered twice
now when a large number of processes (unrelated to vmware) tried to send
lots of TCP data to other linux boxes (real, not virtual). tg3 TSO has
been disabled with ethtool.


kernel BUG at include/linux/netdevice.h:918! 
invalid opcode: 0000 [#1] 
SMP  
Modules linked in: nvidia(P) vmnetfilter vmnet(P) vmmon(P) vmthrottle sysprof 
CPU:    0 
EIP:    0060:[<c0344b61>]    Tainted: P       VLI 
EFLAGS: 00010046   (2.6.22.10-x168 #1) 
EIP is at tg3_poll+0x161/0x1c0 
eax: 00000006   ebx: f7445000   ecx: 00000000   edx: f7532000 
esi: f7445600   edi: 00000202   ebp: e1f55bcc   esp: e1f55bb4 
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068 
Process fcp (pid: 13068, ti=e1f54000 task=dc6fb400 task.ti=e1f54000)
 
Stack: e1f55bcc 00000001 e1f55bdc f7445000 c2b3aa80 c2a22d2c e1f55bec c04b8e4d  
       0ae106dd c2a22d00 0000012c 00000005 c0796b18 c07fb820 e1f55c08 c0128de8  
       00000000 0000000a 00000246 f7445000 c7a179ac e1f55c14 c0128eac f7445200  
Call Trace: 
 [<c01054aa>] show_trace_log_lvl+0x1a/0x30 
 [<c010557a>] show_stack_log_lvl+0x9a/0xc0 
 [<c01057d6>] show_registers+0x1d6/0x2e0 
 [<c0105a46>] die+0x106/0x240 
 [<c0105c11>] 
do_trap+0x91/0xd0 
 [<c0105eb9>] do_invalid_op+0x89/0xa0 
 [<c0575b42>] error_code+0x72/0x80 
 [<c04b8e4d>] net_rx_action+0x8d/0x170 
 [<c0128de8>] __do_softirq+0x78/0x100 
 [<c0128eac>] do_softirq+0x3c/0x40 
 [<c0128cf0>] local_bh_enable+0x80/0xb0 
 [<c04b85f2>] dev_queue_xmit+0x222/0x310 
 [<c04f0de4>] ip_output+0x1d4/0x350 
 [<c04f13bc>] ip_queue_xmit+0x45c/0x480 
 [<c0502e06>] tcp_transmit_skb+0x2b6/0x490 
 [<c050461a>] tcp_write_xmit+0x18a/0x260 
 [<c0504707>] __tcp_push_pending_frames+0x17/0x80 
 [<c04f88c0>] tcp_sendmsg+0x780/0xbe0 
 [<c04acb67>] do_sock_write+0x97/0xb0 
 [<c04acbea>] sock_aio_write+0x6a/0x80 
 [<c0173b47>] 
do_sync_write+0xc7/0x120 
 [<c0173cbf>] vfs_write+0x11f/0x130 
 [<c0173d7d>] sys_write+0x3d/0x70 
 [<c0104132>] syscall_call+0x7/0xb 
 ======================= 
Code: e0 fd 83 c8 01 89 07 8d 83 04 06 00 00 89 45 e8 e8 c5 
0a 23 00 31 d2 89 f0 e8 7c f4 ff ff 8b 45 e8 e8 c4 0b 23 00 e9 c9 fe ff ff <0f> 0b 
eb fe 9c 5f fa 8b 43 
2c a8 20 74 40 
8d 8b 80 
01 00 00 
8b  
EIP: [<c0344b61>] 
tg3_poll+0x161/0x1c0 SS:ESP 0068:e1f55bb4 
Kernel panic - not syncing: Fatal exception in interrupt 

 913 /* same as netif_rx_complete, except that local_irq_save(flags)
 914  * has already been issued
 915  */
 916 static inline void __netif_rx_complete(struct net_device *dev)
 917 {
>918         BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
 919         list_del(&dev->poll_list);
 920         smp_mb__before_clear_bit();
 921         clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
 922 }


-- 
Frank
