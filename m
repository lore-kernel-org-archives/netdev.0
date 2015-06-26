From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net] ipv4: fix RCU lockdep warning from linkdown changes
Date: Fri, 26 Jun 2015 19:37:11 -0400
Message-ID: <1435361831-1104-1-git-send-email-gospo@cumulusnetworks.com>
Cc: sergey.senozhatsky.work@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35353 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127AbbFZXho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 19:37:44 -0400
Received: by qkbp125 with SMTP id p125so63002317qkb.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 16:37:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following lockdep splat was seen due to the wrong context for
grabbing in_dev.

===============================
[ INFO: suspicious RCU usage. ]
4.1.0-next-20150626-dbg-00020-g54a6d91-dirty #244 Not tainted
-------------------------------
include/linux/inetdevice.h:205 suspicious rcu_dereference_check() usage!

other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 0
2 locks held by ip/403:
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81453305>] rtnl_lock+0x17/0x19
 #1:  ((inetaddr_chain).rwsem){.+.+.+}, at: [<ffffffff8105c327>] __blocking_notifier_call_chain+0x35/0x6a

stack backtrace:
CPU: 2 PID: 403 Comm: ip Not tainted 4.1.0-next-20150626-dbg-00020-g54a6d91-dirty #244
 0000000000000001 ffff8800b189b728 ffffffff8150a542 ffffffff8107a8b3
 ffff880037bbea40 ffff8800b189b758 ffffffff8107cb74 ffff8800379dbd00
 ffff8800bec85800 ffff8800bf9e13c0 00000000000000ff ffff8800b189b7d8
Call Trace:
 [<ffffffff8150a542>] dump_stack+0x4c/0x6e
 [<ffffffff8107a8b3>] ? up+0x39/0x3e
 [<ffffffff8107cb74>] lockdep_rcu_suspicious+0xf7/0x100
 [<ffffffff814b63c3>] fib_dump_info+0x227/0x3e2
 [<ffffffff814b6624>] rtmsg_fib+0xa6/0x116
 [<ffffffff814b978f>] fib_table_insert+0x316/0x355
 [<ffffffff814b362e>] fib_magic+0xb7/0xc7
 [<ffffffff814b4803>] fib_add_ifaddr+0xb1/0x13b
 [<ffffffff814b4d09>] fib_inetaddr_event+0x36/0x90
 [<ffffffff8105c086>] notifier_call_chain+0x4c/0x71
 [<ffffffff8105c340>] __blocking_notifier_call_chain+0x4e/0x6a
 [<ffffffff8105c370>] blocking_notifier_call_chain+0x14/0x16
 [<ffffffff814a7f50>] __inet_insert_ifa+0x1a5/0x1b3
 [<ffffffff814a894d>] inet_rtm_newaddr+0x350/0x35f
 [<ffffffff81457866>] rtnetlink_rcv_msg+0x17b/0x18a
 [<ffffffff8107e7c3>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff8146965f>] ? netlink_deliver_tap+0x1cb/0x1f7
 [<ffffffff814576eb>] ? rtnl_newlink+0x72a/0x72a
...

This patch resolves that splat.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
---
 net/ipv4/fib_semantics.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3bfccd8..c7358ea 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1045,7 +1045,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif))
 			goto nla_put_failure;
 		if (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN) {
-			in_dev = __in_dev_get_rcu(fi->fib_nh->nh_dev);
+			in_dev = __in_dev_get_rtnl(fi->fib_nh->nh_dev);
 			if (in_dev &&
 			    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev))
 				rtm->rtm_flags |= RTNH_F_DEAD;
@@ -1074,7 +1074,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 
 			rtnh->rtnh_flags = nh->nh_flags & 0xFF;
 			if (nh->nh_flags & RTNH_F_LINKDOWN) {
-				in_dev = __in_dev_get_rcu(nh->nh_dev);
+				in_dev = __in_dev_get_rtnl(nh->nh_dev);
 				if (in_dev &&
 				    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev))
 					rtnh->rtnh_flags |= RTNH_F_DEAD;
-- 
1.9.3
