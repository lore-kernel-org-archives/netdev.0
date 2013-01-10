From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: splice: fix an infinite loop in tcp_read_sock()
Date: Thu, 10 Jan 2013 09:06:10 -0800
Message-ID: <1357837570.27446.2285.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Willy Tarreau <w@1wt.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:50943 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754350Ab3AJRGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 12:06:15 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so335790dad.10
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 09:06:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 02275a2ee7c0 (tcp: don't abort splice() after small transfers)
added a regression.


[   83.843570] INFO: rcu_sched self-detected stall on CPU
[   83.844575] INFO: rcu_sched detected stalls on CPUs/tasks: { 6} (detected by 0, t=21002 jiffies, g=4457, c=4456, q=13132)
[   83.844582] Task dump for CPU 6:
[   83.844584] netperf         R  running task        0  8966   8952 0x0000000c
[   83.844587]  0000000000000000 0000000000000006 0000000000006c6c 0000000000000000
[   83.844589]  000000000000006c 0000000000000096 ffffffff819ce2bc ffffffffffffff10
[   83.844592]  ffffffff81088679 0000000000000010 0000000000000246 ffff880c4b9ddcd8
[   83.844594] Call Trace:
[   83.844596]  [<ffffffff81088679>] ? vprintk_emit+0x1c9/0x4c0
[   83.844601]  [<ffffffff815ad449>] ? schedule+0x29/0x70
[   83.844606]  [<ffffffff81537bd2>] ? tcp_splice_data_recv+0x42/0x50
[   83.844610]  [<ffffffff8153beaa>] ? tcp_read_sock+0xda/0x260
[   83.844613]  [<ffffffff81537b90>] ? tcp_prequeue_process+0xb0/0xb0
[   83.844615]  [<ffffffff8153c0f0>] ? tcp_splice_read+0xc0/0x250
[   83.844618]  [<ffffffff814dc0c2>] ? sock_splice_read+0x22/0x30
[   83.844622]  [<ffffffff811b820b>] ? do_splice_to+0x7b/0xa0
[   83.844627]  [<ffffffff811ba4bc>] ? sys_splice+0x59c/0x5d0
[   83.844630]  [<ffffffff8119745b>] ? putname+0x2b/0x40
[   83.844633]  [<ffffffff8118bcb4>] ? do_sys_open+0x174/0x1e0
[   83.844636]  [<ffffffff815b6202>] ? system_call_fastpath+0x16/0x1b


if recv_actor() returns 0, we should stop immediately,
because looping wont give a chance to drain the pipe.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willy Tarreau <w@1wt.eu>
---
 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ca2536..5f173dc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1482,7 +1482,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 					break;
 			}
 			used = recv_actor(desc, skb, offset, len);
-			if (used < 0) {
+			if (used <= 0) {
 				if (!copied)
 					copied = used;
 				break;
