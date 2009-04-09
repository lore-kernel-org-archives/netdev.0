From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Oops in tun: bisected to  Limit amount of queued packets per device
Date: Thu, 9 Apr 2009 09:52:01 +0200
Message-ID: <200904090952.01175.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:38636 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755537AbZDIHwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 03:52:06 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n397q3Af291956
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 07:52:03 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n397q3BT3649678
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 08:52:03 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n397q2Nt028424
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 08:52:03 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Herbert,

with my kvm test scenario on s390 I get the following oops:
Unable to handle kernel pointer dereference at virtual kernel address 0000000400000000
Oops: 003b [#1] SMP
Modules linked in: kvm dm_multipath sunrpc qeth_l2 dm_mod qeth ccwgroup
CPU: 0 Not tainted 2.6.29-kvm-06607-ga317a1e-dirty #8
Process kuli (pid: 14827, task: 00000000b3df8138, ksp: 00000000b4703a98)
Krnl PSW : 0404e00180000000 0000000000171278 (__lock_acquire+0x3d4/0x191c)
           R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:0 EA:3
Krnl GPRS: 0000000000000001 0000000000000001 0000000000000001 0000000000000001
           0000000000000000 0000000000000000 0000000000000002 0000000000000000
           00000000b3df8138 00000000b3126c30 0000000000000000 00000000bfeb3498
           0000000400000137 0000000000527600 00000000bfeb3590 00000000bfeb3498
Krnl Code: 000000000017126c: a784fe66             brc     8,170f38
           0000000000171270: 41c0c138             la      %r12,312(%r12)
           0000000000171274: a7180001             lhi     %r1,1
          >0000000000171278: 5820c000             l       %r2,0(%r12)
           000000000017127c: 1832                 lr      %r3,%r2
           000000000017127e: 1a31                 ar      %r3,%r1
           0000000000171280: ba23c000             cs      %r2,%r3,0(%r12)
           0000000000171284: a744fffc             brc     4,17127c
Call Trace:
([<0000000000170270>] trace_hardirqs_on+0x2c/0x3c)
 [<0000000000172858>] lock_acquire+0x98/0xc0
 [<000000000051e9c8>] _spin_lock_irqsave+0x64/0xac
 [<0000000000127354>] __wake_up_sync+0x38/0x78
 [<00000000003a3dda>] tun_sock_write_space+0x5e/0xb4
 [<000000000040f924>] sock_wfree+0xb4/0xb8
 [<000000000041487a>] skb_release_head_state+0x82/0x134
 [<0000000000414460>] __kfree_skb+0x2c/0x120
 [<0000000000414660>] kfree_skb+0x88/0xcc
 [<00000000003a3938>] tun_net_xmit+0xbc/0x22c
 [<000000000041fd56>] dev_hard_start_xmit+0x2a6/0x324
 [<00000000004381f8>] __qdisc_run+0x164/0x2a0
 [<000000000042020c>] dev_queue_xmit+0x2b8/0x444
 [<00000000004fb1dc>] br_dev_queue_push_xmit+0x94/0xd4
 [<00000000004fb2aa>] br_forward_finish+0x8e/0xa0
 [<0000000000501718>] br_nf_forward_finish+0x160/0x174
 [<0000000000501bca>] br_nf_forward_arp+0x17a/0x184
 [<000000000043e18c>] nf_iterate+0x9c/0xe4
 [<000000000043e29e>] nf_hook_slow+0xca/0x16c
 [<00000000004fb358>] __br_forward+0x9c/0x100
 [<00000000004fb07a>] br_flood+0xb6/0x10c
 [<00000000004fb0fe>] br_flood_forward+0x2e/0x3c
 [<00000000004fc4a4>] br_handle_frame_finish+0x1d0/0x1e4
 [<00000000004fc716>] br_handle_frame+0x25e/0x270
 [<000000000041e848>] netif_receive_skb+0x278/0x484
 [<000000000041eb26>] process_backlog+0xd2/0x140
 [<000000000041cb78>] net_rx_action+0xf4/0x1a8
 [<0000000000143fdc>] __do_softirq+0xc0/0x1a0
 [<0000000000110af4>] do_softirq+0x9c/0xf0
([<0000000000110ab4>] do_softirq+0x5c/0xf0)
 [<000000000041f73e>] netif_rx_ni+0x3a/0x4c
 [<00000000003a4cc2>] tun_chr_aio_write+0x3fa/0x4d8
 [<00000000001e7b58>] do_sync_readv_writev+0xd8/0x130
 [<00000000001e842a>] do_readv_writev+0xe2/0x238
 [<00000000001e85f2>] vfs_writev+0x72/0x88
 [<00000000001e8660>] SyS_writev+0x58/0xb0
 [<0000000000117866>] sysc_noemu+0x10/0x16
 [<0000004161704d28>] 0x4161704d28


I was able to bisect the problem to 
commit 33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Feb 5 21:25:32 2009 -0800

    tun: Limit amount of queued packets per device

Reverting the patch fixes the problem. Do you have any idea whats wrong?

Christian
