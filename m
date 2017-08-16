From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] ipv6: reset fn->rr_ptr when replacing route
Date: Wed, 16 Aug 2017 11:18:09 -0700
Message-ID: <20170816181809.37073-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34412 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752185AbdHPSSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:18:18 -0400
Received: by mail-pg0-f42.google.com with SMTP id u185so26134513pgb.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 11:18:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

syzcaller reported the following use-after-free issue in rt6_select():
BUG: KASAN: use-after-free in rt6_select net/ipv6/route.c:755 [inline] at addr ffff8800bc6994e8
BUG: KASAN: use-after-free in ip6_pol_route.isra.46+0x1429/0x1470 net/ipv6/route.c:1084 at addr ffff8800bc6994e8
Read of size 4 by task syz-executor1/439628
CPU: 0 PID: 439628 Comm: syz-executor1 Not tainted 4.3.5+ #8
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
 0000000000000000 ffff88018fe435b0 ffffffff81ca384d ffff8801d3588c00
 ffff8800bc699380 ffff8800bc699500 dffffc0000000000 ffff8801d40a47c0
 ffff88018fe435d8 ffffffff81735751 ffff88018fe43660 ffff8800bc699380
Call Trace:
 [<ffffffff81ca384d>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff81ca384d>] dump_stack+0xc1/0x124 lib/dump_stack.c:51
sctp: [Deprecated]: syz-executor0 (pid 439615) Use of struct sctp_assoc_value in delayed_ack socket option.
Use struct sctp_sack_info instead
 [<ffffffff81735751>] kasan_object_err+0x21/0x70 mm/kasan/report.c:158
 [<ffffffff817359c4>] print_address_description mm/kasan/report.c:196 [inline]
 [<ffffffff817359c4>] kasan_report_error+0x1b4/0x4a0 mm/kasan/report.c:285
 [<ffffffff81735d93>] kasan_report mm/kasan/report.c:305 [inline]
 [<ffffffff81735d93>] __asan_report_load4_noabort+0x43/0x50 mm/kasan/report.c:325
 [<ffffffff82a28e39>] rt6_select net/ipv6/route.c:755 [inline]
 [<ffffffff82a28e39>] ip6_pol_route.isra.46+0x1429/0x1470 net/ipv6/route.c:1084
 [<ffffffff82a28fb1>] ip6_pol_route_output+0x81/0xb0 net/ipv6/route.c:1203
 [<ffffffff82ab0a50>] fib6_rule_action+0x1f0/0x680 net/ipv6/fib6_rules.c:95
 [<ffffffff8265cbb6>] fib_rules_lookup+0x2a6/0x7a0 net/core/fib_rules.c:223
 [<ffffffff82ab1430>] fib6_rule_lookup+0xd0/0x250 net/ipv6/fib6_rules.c:41
 [<ffffffff82a22006>] ip6_route_output+0x1d6/0x2c0 net/ipv6/route.c:1224
 [<ffffffff829e83d2>] ip6_dst_lookup_tail+0x4d2/0x890 net/ipv6/ip6_output.c:943
 [<ffffffff829e889a>] ip6_dst_lookup_flow+0x9a/0x250 net/ipv6/ip6_output.c:1079
 [<ffffffff82a9f7d8>] ip6_datagram_dst_update+0x538/0xd40 net/ipv6/datagram.c:91
 [<ffffffff82aa0978>] __ip6_datagram_connect net/ipv6/datagram.c:251 [inline]
 [<ffffffff82aa0978>] ip6_datagram_connect+0x518/0xe50 net/ipv6/datagram.c:272
 [<ffffffff82aa1313>] ip6_datagram_connect_v6_only+0x63/0x90 net/ipv6/datagram.c:284
 [<ffffffff8292f790>] inet_dgram_connect+0x170/0x1f0 net/ipv4/af_inet.c:564
 [<ffffffff82565547>] SYSC_connect+0x1a7/0x2f0 net/socket.c:1582
 [<ffffffff8256a649>] SyS_connect+0x29/0x30 net/socket.c:1563
 [<ffffffff82c72032>] entry_SYSCALL_64_fastpath+0x12/0x17
Object at ffff8800bc699380, in cache ip6_dst_cache size: 384

The root cause of it is that in fib6_add_rt2node(), when it replaces an
existing route with the new one, it does not update fn->rr_ptr.
This commit resets fn->rr_ptr to NULL when it points to a route which is
replaced in fib6_add_rt2node().

Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_fib.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 8c58c7558de0..78b9359b06fd 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1013,6 +1013,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		nsiblings = iter->rt6i_nsiblings;
 		iter->rt6i_node = NULL;
 		fib6_purge_rt(iter, fn, info->nl_net);
+		if (fn->rr_ptr == iter)
+			fn->rr_ptr = NULL;
 		rt6_release(iter);
 
 		if (nsiblings) {
@@ -1026,6 +1028,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 					*ins = iter->dst.rt6_next;
 					iter->rt6i_node = NULL;
 					fib6_purge_rt(iter, fn, info->nl_net);
+					if (fn->rr_ptr == iter)
+						fn->rr_ptr = NULL;
 					rt6_release(iter);
 					nsiblings--;
 				} else {
-- 
2.14.1.480.gb18f417b89-goog
