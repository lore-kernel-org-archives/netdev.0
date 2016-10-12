From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: tcp: restore IP6CB for pktoptions skbs
Date: Wed, 12 Oct 2016 19:01:45 +0200
Message-ID: <1476291705.5650.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <21019976-9e40-5e6d-b733-fa9eced710f0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35821 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbcJLRPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 13:15:22 -0400
Received: by mail-pa0-f65.google.com with SMTP id qn10so3556972pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 10:15:22 -0700 (PDT)
In-Reply-To: <21019976-9e40-5e6d-b733-fa9eced710f0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Baozeng Ding reported following KASAN splat :

BUG: KASAN: use-after-free in ip6_datagram_recv_specific_ctl+0x13f1/0x15c0 at addr ffff880029c84ec8
Read of size 1 by task poc/25548
Call Trace:
 [<ffffffff82cf43c9>] dump_stack+0x12e/0x185 /lib/dump_stack.c:15
 [<     inline     >] print_address_description /mm/kasan/report.c:204
 [<ffffffff817ced3b>] kasan_report_error+0x48b/0x4b0 /mm/kasan/report.c:283
 [<     inline     >] kasan_report /mm/kasan/report.c:303
 [<ffffffff817ced9e>] __asan_report_load1_noabort+0x3e/0x40 /mm/kasan/report.c:321
 [<ffffffff85c71da1>] ip6_datagram_recv_specific_ctl+0x13f1/0x15c0 /net/ipv6/datagram.c:687
 [<ffffffff85c734c3>] ip6_datagram_recv_ctl+0x33/0x40
 [<ffffffff85c0b07c>] do_ipv6_getsockopt.isra.4+0xaec/0x2150
 [<ffffffff85c0c7f6>] ipv6_getsockopt+0x116/0x230
 [<ffffffff859b5a12>] tcp_getsockopt+0x82/0xd0 /net/ipv4/tcp.c:3035
 [<ffffffff855fb385>] sock_common_getsockopt+0x95/0xd0 /net/core/sock.c:2647
 [<     inline     >] SYSC_getsockopt /net/socket.c:1776
 [<ffffffff855f8ba2>] SyS_getsockopt+0x142/0x230 /net/socket.c:1758
 [<ffffffff8685cdc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
Memory state around the buggy address:
 ffff880029c84d80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
 ffff880029c84e00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ffff880029c84e80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
                                              ^
 ffff880029c84f00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
 ffff880029c84f80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

He also provided a syzkaller reproducer.

Issue is that ip6_datagram_recv_specific_ctl() expects to find IP6CB
data that was moved at a different place in tcp_v6_rcv()

This patch moves tcp_v6_restore_cb() up and calls it from
tcp_v6_do_rcv() when np->pktoptions is set.

Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Baozeng Ding <sploving1@gmail.com>
---
 net/ipv6/tcp_ipv6.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 54cf7197c7ab..5a27ab4eab39 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1190,6 +1190,16 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	return NULL;
 }
 
+static void tcp_v6_restore_cb(struct sk_buff *skb)
+{
+	/* We need to move header back to the beginning if xfrm6_policy_check()
+	 * and tcp_v6_fill_cb() are going to be called again.
+	 * ip6_datagram_recv_specific_ctl() also expects IP6CB to be there.
+	 */
+	memmove(IP6CB(skb), &TCP_SKB_CB(skb)->header.h6,
+		sizeof(struct inet6_skb_parm));
+}
+
 /* The socket must have it's spinlock held when we get
  * here, unless it is a TCP_LISTEN socket.
  *
@@ -1319,6 +1329,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 			np->flow_label = ip6_flowlabel(ipv6_hdr(opt_skb));
 		if (ipv6_opt_accepted(sk, opt_skb, &TCP_SKB_CB(opt_skb)->header.h6)) {
 			skb_set_owner_r(opt_skb, sk);
+			tcp_v6_restore_cb(opt_skb);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
 		} else {
 			__kfree_skb(opt_skb);
@@ -1352,15 +1363,6 @@ static void tcp_v6_fill_cb(struct sk_buff *skb, const struct ipv6hdr *hdr,
 	TCP_SKB_CB(skb)->sacked = 0;
 }
 
-static void tcp_v6_restore_cb(struct sk_buff *skb)
-{
-	/* We need to move header back to the beginning if xfrm6_policy_check()
-	 * and tcp_v6_fill_cb() are going to be called again.
-	 */
-	memmove(IP6CB(skb), &TCP_SKB_CB(skb)->header.h6,
-		sizeof(struct inet6_skb_parm));
-}
-
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
 	const struct tcphdr *th;
