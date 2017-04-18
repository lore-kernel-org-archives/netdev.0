From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] net/packet: initialize val in packet_getsockopt()
Date: Tue, 18 Apr 2017 19:47:08 +0200
Message-ID: <20170418174708.26341-1-glider@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:35313 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757822AbdDRRrN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:47:13 -0400
Received: by mail-wr0-f171.google.com with SMTP id o21so81437wrb.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:47:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case getsockopt() is called with PACKET_HDRLEN and zero length,
|val| remains uninitialized and the syscall may behave differently
depending on its value. This doesn't have security consequences (as the
uninit bytes aren't copied back), but it's still cleaner to initialize
|val|.

This bug has been detected with KMSAN.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
KMSAN report below:

==================================================================
BUG: KMSAN: use of unitialized memory in packet_getsockopt+0xb9b/0xbe0
inter: 0
CPU: 0 PID: 1036 Comm: probe Tainted: G    B           4.11.0-rc5+ #2444
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x143/0x1b0 lib/dump_stack.c:52
 kmsan_report+0x16b/0x1e0 mm/kmsan/kmsan.c:1078
 __kmsan_warning_32+0x5c/0xa0 mm/kmsan/kmsan_instr.c:510
 packet_getsockopt+0xb9b/0xbe0 net/packet/af_packet.c:3839
 SYSC_getsockopt+0x495/0x540 net/socket.c:1829
 SyS_getsockopt+0xb0/0xd0 net/socket.c:1811
 entry_SYSCALL_64_fastpath+0x13/0x94 arch/x86/entry/entry_64.S:204
RIP: 0033:0x436d8a
RSP: 002b:00007ffce54e52c8 EFLAGS: 00000203 ORIG_RAX: 0000000000000037
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000436d8a
RDX: 000000000000000b RSI: 0000000000000107 RDI: 0000000000000003
RBP: 00007ffce54e52b0 R08: 00007ffce54e52d8 R09: 0000000000000004
R10: 00007ffce54e52d4 R11: 0000000000000203 R12: 00007ffce54e53c8
R13: 00007ffce54e53d8 R14: 0000000000000002 R15: 0000000000000000
origin description: ----val@packet_getsockopt (origin=00000000f6600052)
local variable created at:
 packet_getsockopt+0xcd/0xbe0 net/packet/af_packet.c:3789
 SYSC_getsockopt+0x495/0x540 net/socket.c:1829
==================================================================
---
 net/packet/af_packet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8489beff5c25..09398454ec66 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3787,7 +3787,7 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 			     char __user *optval, int __user *optlen)
 {
 	int len;
-	int val, lv = sizeof(val);
+	int val = 0, lv = sizeof(val);
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
 	void *data = &val;
-- 
2.12.2.816.g2cccc81164-goog
