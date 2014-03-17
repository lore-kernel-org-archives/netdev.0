From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net] net: vxlan: fix crash when interface is created with no group
Date: Mon, 17 Mar 2014 13:17:30 +0200
Message-ID: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:47326 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514AbaCQLRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 07:17:41 -0400
Received: by mail-ee0-f49.google.com with SMTP id c41so3984001eek.36
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 04:17:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the vxlan interface is created without group definition, there is a
panic on the first packet reception:

$ ip link add dev vxlan0 type vxlan id 1
$ ip addr add dev vxlan0 10.0.0.1/24
$ ip link set up dev vxlan0

  BUG: unable to handle kernel paging request at 0000000100000103
  IP: [<ffffffff8143435b>] ipv6_rcv+0xfa/0x399
  PGD 7c397067 PUD 0
  Oops: 0000 [#1] SMP
  Modules linked in:
  CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc6-hvx-xen-00153-gee7d07e #95
  Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  task: ffffffff81813450 ti: ffffffff81800000 task.ti: ffffffff81800000
  RIP: 0010:[<ffffffff8143435b>]  [<ffffffff8143435b>] ipv6_rcv+0xfa/0x399
  RSP: 0018:ffff88007fc03d78  EFLAGS: 00010282
  RAX: 0000000100000003 RBX: ffff88007bd29000 RCX: 0000000000000000
  RDX: ffff88007bd29028 RSI: ffff88007c29a000 RDI: ffff88007bd29040
  RBP: ffff88007fc03da8 R08: 0000000000000000 R09: ffff88007b1bc548
  R10: ffff88007bd29a00 R11: ffff88007bd29000 R12: ffff88007bcc5800
  R13: ffffffff8186a000 R14: ffff88007c29a000 R15: 0000000000000000
  FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
  CR2: 0000000100000103 CR3: 000000007bc01000 CR4: 00000000000006f0
  Stack:
   ffff88007bd29a00 ffffffff81886010 ffffffff8187fa48 000000000000dd86
   ffff88007c29a000 0000000000000000 ffff88007fc03e18 ffffffff8139a42c
   ffff88007fc03dd8 ffffffff812a320f ffffffff8187fa70 ffff88007bd29000
  Call Trace:
   <IRQ>
   [<ffffffff8139a42c>] __netif_receive_skb_core+0x43e/0x478
   [<ffffffff812a320f>] ? virtqueue_poll+0x16/0x27
   [<ffffffff8139a4bb>] __netif_receive_skb+0x55/0x5a
   [<ffffffff8139a536>] process_backlog+0x76/0x12f
   [<ffffffff8139a864>] net_rx_action+0xa2/0x1ab
   [<ffffffff81047847>] __do_softirq+0xca/0x1d1
   [<ffffffff81047ace>] irq_exit+0x3e/0x85
   [<ffffffff8100b98b>] do_IRQ+0xa9/0xc4
   [<ffffffff814a972d>] common_interrupt+0x6d/0x6d
   <EOI>
   [<ffffffff810378db>] ? native_safe_halt+0x6/0x8
   [<ffffffff810110c7>] default_idle+0x9/0xd
   [<ffffffff81011694>] arch_cpu_idle+0x13/0x1c
   [<ffffffff810747fd>] cpu_startup_entry+0xbc/0x137
   [<ffffffff8149bd8e>] rest_init+0x72/0x74
   [<ffffffff8189eda7>] start_kernel+0x3e6/0x3f3
   [<ffffffff8189e7ca>] ? repair_env_string+0x56/0x56
   [<ffffffff8189e120>] ? early_idt_handlers+0x120/0x120
   [<ffffffff8189e4cd>] x86_64_start_reservations+0x2a/0x2c
   [<ffffffff8189e5c2>] x86_64_start_kernel+0xf3/0x102
  Code: 40 68 e9 a9 02 00 00 48 8d 53 28 31 c0 b9 06 00 00 00 48 89 d7 f3 ab 48 8b 43 58 48 83 e0 fe 74 12 48 8b 80 48 01 00 00 48 8b 00 <8b> 80 00 01 00 00 eb 07 41 8b 86 00 01 00 00 8b 53 68 89 43 28
  RIP  [<ffffffff8143435b>] ipv6_rcv+0xfa/0x399
   RSP <ffff88007fc03d78>
  CR2: 0000000100000103
  ---[ end trace d4e5022768991ebe ]---

The crash occurs because vxlan_rcv decides on protocol version of outer
packed using vxlan->default_dst.remote_ip.sa.sa_family field which is
not initialized if no multicast group was specified at interface
creation time. This causes vxlan driver to always assume that outer
packet is IPv6.

Using IP protocol version from skb instead of default destination
address family fixes the problem.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b0f705c..a810ce4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1206,7 +1206,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 		goto drop;
 
 	/* Re-examine inner Ethernet packet */
-	if (remote_ip->sa.sa_family == AF_INET) {
+	if (ip_hdr(skb)->version == 4) {
 		oip = ip_hdr(skb);
 		saddr.sin.sin_addr.s_addr = oip->saddr;
 		saddr.sa.sa_family = AF_INET;
-- 
1.8.1.5
