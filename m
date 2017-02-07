From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ping: fix a null pointer dereference
Date: Tue,  7 Feb 2017 12:59:46 -0800
Message-ID: <1486501187-12869-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, dvyukov@google.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36075 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753893AbdBGU76 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:59:58 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so13040384pgf.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 12:59:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a kernel crash:

  general protection fault: 0000 [#1] SMP KASAN
  Dumping ftrace buffer:
     (ftrace buffer empty)
  Modules linked in:
  CPU: 2 PID: 3880 Comm: syz-executor1 Not tainted 4.10.0-rc6+ #124
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
  task: ffff880060048040 task.stack: ffff880069be8000
  RIP: 0010:ping_v4_push_pending_frames net/ipv4/ping.c:647 [inline]
  RIP: 0010:ping_v4_sendmsg+0x1acd/0x23f0 net/ipv4/ping.c:837
  RSP: 0018:ffff880069bef8b8 EFLAGS: 00010206
  RAX: dffffc0000000000 RBX: ffff880069befb90 RCX: 0000000000000000
  RDX: 0000000000000018 RSI: ffff880069befa30 RDI: 00000000000000c2
  RBP: ffff880069befbb8 R08: 0000000000000008 R09: 0000000000000000
  R10: 0000000000000002 R11: 0000000000000000 R12: ffff880069befab0
  R13: ffff88006c624a80 R14: ffff880069befa70 R15: 0000000000000000
  FS:  00007f6f7c716700(0000) GS:ffff88006de00000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00000000004a6f28 CR3: 000000003a134000 CR4: 00000000000006e0
  Call Trace:
   inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:744
   sock_sendmsg_nosec net/socket.c:635 [inline]
   sock_sendmsg+0xca/0x110 net/socket.c:645
   SYSC_sendto+0x660/0x810 net/socket.c:1687
   SyS_sendto+0x40/0x50 net/socket.c:1655
   entry_SYSCALL_64_fastpath+0x1f/0xc2

This is because we miss a check for NULL pointer for skb_peek() when
the queue is empty. Other places already have the same check.

Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/ping.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 86cca61..68d77b1 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -642,6 +642,8 @@ static int ping_v4_push_pending_frames(struct sock *sk, struct pingfakehdr *pfh,
 {
 	struct sk_buff *skb = skb_peek(&sk->sk_write_queue);
 
+	if (!skb)
+		return 0;
 	pfh->wcheck = csum_partial((char *)&pfh->icmph,
 		sizeof(struct icmphdr), pfh->wcheck);
 	pfh->icmph.checksum = csum_fold(pfh->wcheck);
-- 
2.5.5
