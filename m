From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix keepalive code vs TCP_FASTOPEN_CONNECT
Date: Wed, 02 Aug 2017 23:10:46 -0700
Message-ID: <1501740646.25002.31.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Wei Wang <weiwan@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35946 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdHCGKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 02:10:50 -0400
Received: by mail-wm0-f67.google.com with SMTP id d40so916811wma.3
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 23:10:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller was able to trigger a divide by 0 in TCP stack [1]

Issue here is that keepalive timer needs to be updated to not attempt
to send a probe if the connection setup was deferred using
TCP_FASTOPEN_CONNECT socket option added in linux-4.11

[1]
 divide error: 0000 [#1] SMP 
 CPU: 18 PID: 0 Comm: swapper/18 Not tainted
 task: ffff986f62f4b040 ti: ffff986f62fa2000 task.ti: ffff986f62fa2000
 RIP: 0010:[<ffffffff8409cc0d>]  [<ffffffff8409cc0d>] __tcp_select_window+0x8d/0x160
 Call Trace:
  <IRQ> 
  [<ffffffff8409d951>] tcp_transmit_skb+0x11/0x20
  [<ffffffff8409da21>] tcp_xmit_probe_skb+0xc1/0xe0
  [<ffffffff840a0ee8>] tcp_write_wakeup+0x68/0x160
  [<ffffffff840a151b>] tcp_keepalive_timer+0x17b/0x230
  [<ffffffff83b3f799>] call_timer_fn+0x39/0xf0
  [<ffffffff83b40797>] run_timer_softirq+0x1d7/0x280
  [<ffffffff83a04ddb>] __do_softirq+0xcb/0x257
  [<ffffffff83ae03ac>] irq_exit+0x9c/0xb0
  [<ffffffff83a04c1a>] smp_apic_timer_interrupt+0x6a/0x80
  [<ffffffff83a03eaf>] apic_timer_interrupt+0x7f/0x90
  <EOI> 
  [<ffffffff83fed2ea>] ? cpuidle_enter_state+0x13a/0x3b0
  [<ffffffff83fed2cd>] ? cpuidle_enter_state+0x11d/0x3b0


Tested:

Following packetdrill no longer crashes the kernel

`echo 0 >/proc/sys/net/ipv4/tcp_timestamps`

// Cache warmup: send a Fast Open cookie request
    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0
   +0 setsockopt(3, SOL_TCP, TCP_FASTOPEN_CONNECT, [1], 4) = 0
   +0 connect(3, ..., ...) = -1 EINPROGRESS (Operation is now in progress)
   +0 > S 0:0(0) <mss 1460,nop,nop,sackOK,nop,wscale 8,FO,nop,nop>
 +.01 < S. 123:123(0) ack 1 win 14600 <mss 1460,nop,nop,sackOK,nop,wscale 6,FO abcd1234,nop,nop>
   +0 > . 1:1(0) ack 1
   +0 close(3) = 0
   +0 > F. 1:1(0) ack 1
   +0 < F. 1:1(0) ack 2 win 92
   +0 > .  2:2(0) ack 2

   +0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 4
   +0 fcntl(4, F_SETFL, O_RDWR|O_NONBLOCK) = 0
   +0 setsockopt(4, SOL_TCP, TCP_FASTOPEN_CONNECT, [1], 4) = 0
   +0 setsockopt(4, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0
 +.01 connect(4, ..., ...) = 0
   +0 setsockopt(4, SOL_TCP, TCP_KEEPIDLE, [5], 4) = 0
   +10 close(4) = 0

`echo 1 >/proc/sys/net/ipv4/tcp_timestamps`


Fixes: 19f6d3f3c842 ("net/tcp-fastopen: Add new API support")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Wei Wang <weiwan@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_timer.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index c0feeeef962a..e906014890b6 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -652,7 +652,8 @@ static void tcp_keepalive_timer (unsigned long data)
 		goto death;
 	}
 
-	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
+	if (!sock_flag(sk, SOCK_KEEPOPEN) ||
+	    ((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)))
 		goto out;
 
 	elapsed = keepalive_time_when(tp);
