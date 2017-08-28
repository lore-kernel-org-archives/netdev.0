From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: do not set sk_destruct in IPV6_ADDRFORM sockopt
Date: Mon, 28 Aug 2017 10:45:01 +0800
Message-ID: <4cfe77b4a829c0d6134b842fe2ea7c41b6b210ff.1503888301.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, pabeni@redhat.com, chunwang@redhat.com,
        syzkaller@googlegroups.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37125 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdH1CpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 22:45:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id r187so3205505pfr.4
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2017 19:45:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ChunYu found a kernel warn_on during syzkaller fuzzing:

[40226.038539] WARNING: CPU: 5 PID: 23720 at net/ipv4/af_inet.c:152 inet_sock_destruct+0x78d/0x9a0
[40226.144849] Call Trace:
[40226.147590]  <IRQ>
[40226.149859]  dump_stack+0xe2/0x186
[40226.176546]  __warn+0x1a4/0x1e0
[40226.180066]  warn_slowpath_null+0x31/0x40
[40226.184555]  inet_sock_destruct+0x78d/0x9a0
[40226.246355]  __sk_destruct+0xfa/0x8c0
[40226.290612]  rcu_process_callbacks+0xaa0/0x18a0
[40226.336816]  __do_softirq+0x241/0x75e
[40226.367758]  irq_exit+0x1f6/0x220
[40226.371458]  smp_apic_timer_interrupt+0x7b/0xa0
[40226.376507]  apic_timer_interrupt+0x93/0xa0

The warn_on happned when sk->sk_rmem_alloc wasn't 0 in inet_sock_destruct.
As after commit f970bd9e3a06 ("udp: implement memory accounting helpers"),
udp has changed to use udp_destruct_sock as sk_destruct where it would
udp_rmem_release all rmem.

But IPV6_ADDRFORM sockopt sets sk_destruct with inet_sock_destruct after
changing family to PF_INET. If rmem is not 0 at that time, and there is
no place to release rmem before calling inet_sock_destruct, the warn_on
will be triggered.

This patch is to fix it by not setting sk_destruct in IPV6_ADDRFORM sockopt
any more. As IPV6_ADDRFORM sockopt only works for tcp and udp. TCP sock has
already set it's sk_destruct with inet_sock_destruct and UDP has set with
udp_destruct_sock since they're created.

Fixes: f970bd9e3a06 ("udp: implement memory accounting helpers")
Reported-by: ChunYu Wang <chunwang@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ipv6_sockglue.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 02d795f..a5e466d 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -242,7 +242,6 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			pktopt = xchg(&np->pktoptions, NULL);
 			kfree_skb(pktopt);
 
-			sk->sk_destruct = inet_sock_destruct;
 			/*
 			 * ... and add it to the refcnt debug socks count
 			 * in the new family. -acme
-- 
2.1.0
