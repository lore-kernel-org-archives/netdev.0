From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next] tcp: Remove use of daddr_cache in tracepoint
Date: Tue, 17 Oct 2017 13:09:33 -0700
Message-ID: <1508270973-23789-1-git-send-email-dsahern@gmail.com>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:48877 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755964AbdJQUJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:09:39 -0400
Received: by mail-pf0-f196.google.com with SMTP id b79so2147175pfk.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:09:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running perf in one window to capture tcp_retransmit_skb tracepoint:
    $ perf record -e tcp:tcp_retransmit_skb -a

And causing a retransmission on an active TCP session (e.g., dropping
packets in the receiver, changing MTU on the interface to 500 and back
to 1500) triggers a panic:

[   58.543144] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[   58.545300] IP: perf_trace_tcp_retransmit_skb+0xd0/0x145
[   58.546770] PGD 0 P4D 0
[   58.547472] Oops: 0000 [#1] SMP
[   58.548328] Modules linked in: vrf
[   58.549262] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.14.0-rc4+ #26
[   58.551004] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   58.554560] task: ffffffff81a0e540 task.stack: ffffffff81a00000
[   58.555817] RIP: 0010:perf_trace_tcp_retransmit_skb+0xd0/0x145
[   58.557137] RSP: 0018:ffff88003fc03d68 EFLAGS: 00010282
[   58.558292] RAX: 0000000000000000 RBX: ffffe8ffffc0ec80 RCX: ffff880038543098
[   58.559850] RDX: 0400000000000000 RSI: ffff88003fc03d70 RDI: ffff88003fc14b68
[   58.561099] RBP: ffff88003fc03da8 R08: 0000000000000000 R09: ffffea0000d3224a
[   58.562005] R10: ffff88003fc03db8 R11: 0000000000000010 R12: ffff8800385428c0
[   58.562930] R13: ffffe8ffffc0e478 R14: ffffffff81a93a40 R15: ffff88003d4f0c00
[   58.563845] FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[   58.564873] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   58.565613] CR2: 0000000000000008 CR3: 000000003d68f004 CR4: 00000000000606f0
[   58.566538] Call Trace:
[   58.566865]  <IRQ>
[   58.567140]  __tcp_retransmit_skb+0x4ab/0x4c6
[   58.567704]  ? tcp_set_ca_state+0x22/0x3f
[   58.568231]  tcp_retransmit_skb+0x14/0xa3
[   58.568754]  tcp_retransmit_timer+0x472/0x5e3
[   58.569324]  ? tcp_write_timer_handler+0x1e9/0x1e9
[   58.569946]  tcp_write_timer_handler+0x95/0x1e9
[   58.570548]  tcp_write_timer+0x2a/0x58

Remove use of ipv6_pinfo in favor of data in sock_common.

Fixes: e086101b150a ("tcp: add a tracepoint for tcp retransmission")
Signed-off-by: David Ahern <dsahern@gmail.com>
---
v3
- remove use of inet6_sk and check sk_family (requested by Eric)
- Add IS_ENABLED(CONFIG_IPV6) around use of sk_v6_rcv_saddr and
  sk_v6_daddr as done in sock_common (noted by Cong)

v2
- remove np and get addresses from sock_common

 include/trace/events/tcp.h | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 3d1cbd072b7e..271812216ce3 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -27,7 +27,6 @@ TRACE_EVENT(tcp_retransmit_skb,
 	),
 
 	TP_fast_assign(
-		struct ipv6_pinfo *np = inet6_sk(sk);
 		struct inet_sock *inet = inet_sk(sk);
 		struct in6_addr *pin6;
 		__be32 *p32;
@@ -44,12 +43,15 @@ TRACE_EVENT(tcp_retransmit_skb,
 		p32 = (__be32 *) __entry->daddr;
 		*p32 =  inet->inet_daddr;
 
-		if (np) {
+#if IS_ENABLED(CONFIG_IPV6)
+		if (sk->sk_family == AF_INET6) {
 			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			*pin6 = np->saddr;
+			*pin6 = sk->sk_v6_rcv_saddr;
 			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			*pin6 = *(np->daddr_cache);
-		} else {
+			*pin6 = sk->sk_v6_daddr;
+		} else
+#endif
+		{
 			pin6 = (struct in6_addr *)__entry->saddr_v6;
 			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
 			pin6 = (struct in6_addr *)__entry->daddr_v6;
-- 
2.1.4
