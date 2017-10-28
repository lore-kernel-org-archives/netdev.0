From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next] ipv6: prevent user from adding cached routes
Date: Fri, 27 Oct 2017 17:30:12 -0700
Message-ID: <20171028003012.15609-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:49144 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdJ1AaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:30:22 -0400
Received: by mail-io0-f195.google.com with SMTP id j17so16113425iod.5
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:30:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Cached routes should only be created by the system when receiving pmtu
discovery or ip redirect msg. Users should not be allowed to create
cached routes.

Furthermore, after the patch series to move cached routes into exception
table, user added cached routes will trigger the following warning in
fib6_add():

WARNING: CPU: 0 PID: 2985 at net/ipv6/ip6_fib.c:1137
fib6_add+0x20d9/0x2c10 net/ipv6/ip6_fib.c:1137
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 2985 Comm: syzkaller320388 Not tainted 4.14.0-rc3+ #74
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 panic+0x1e4/0x417 kernel/panic.c:181
 __warn+0x1c4/0x1d9 kernel/panic.c:542
 report_bug+0x211/0x2d0 lib/bug.c:183
 fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:178
 do_trap_no_signal arch/x86/kernel/traps.c:212 [inline]
 do_trap+0x260/0x390 arch/x86/kernel/traps.c:261
 do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:298
 do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:311
 invalid_op+0x18/0x20 arch/x86/entry/entry_64.S:905
RIP: 0010:fib6_add+0x20d9/0x2c10 net/ipv6/ip6_fib.c:1137
RSP: 0018:ffff8801cf09f6a0 EFLAGS: 00010297
RAX: ffff8801ce45e340 RBX: 1ffff10039e13eec RCX: ffff8801d749c814
RDX: 0000000000000000 RSI: ffff8801d749c700 RDI: ffff8801d749c780
RBP: ffff8801cf09fa08 R08: 0000000000000000 R09: ffff8801cf09f360
R10: ffff8801cf09f2d8 R11: 1ffff10039c8befb R12: 0000000000000001
R13: dffffc0000000000 R14: ffff8801d749c700 R15: ffffffff860655c0
 __ip6_ins_rt+0x6c/0x90 net/ipv6/route.c:1011
 ip6_route_add+0x148/0x1a0 net/ipv6/route.c:2782
 ipv6_route_ioctl+0x4d5/0x690 net/ipv6/route.c:3291
 inet6_ioctl+0xef/0x1e0 net/ipv6/af_inet6.c:521
 sock_do_ioctl+0x65/0xb0 net/socket.c:961
 sock_ioctl+0x2c2/0x440 net/socket.c:1058
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1b1/0x1530 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xbe

So we fix this by failing the attemp to add cached routes from userspace
with returning EINVAL error.

Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/ipv6_route.h | 2 +-
 net/ipv6/route.c                | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
index d496c02e14bc..c15d8054905c 100644
--- a/include/uapi/linux/ipv6_route.h
+++ b/include/uapi/linux/ipv6_route.h
@@ -28,7 +28,7 @@
 
 #define RTF_ROUTEINFO	0x00800000	/* route information - RA	*/
 
-#define RTF_CACHE	0x01000000	/* cache entry			*/
+#define RTF_CACHE	0x01000000	/* read-only: can not be set by user */
 #define RTF_FLOW	0x02000000	/* flow significant route	*/
 #define RTF_POLICY	0x04000000	/* policy route			*/
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 605e5dc1c010..70d9659fc1e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2478,6 +2478,12 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 		goto out;
 	}
 
+	/* RTF_CACHE is an internal flag; can not be set by userspace */
+	if (cfg->fc_flags & RTF_CACHE) {
+		NL_SET_ERR_MSG(extack, "Userspace can not set RTF_CACHE");
+		goto out;
+	}
+
 	if (cfg->fc_dst_len > 128) {
 		NL_SET_ERR_MSG(extack, "Invalid prefix length");
 		goto out;
-- 
2.15.0.rc2.357.g7e34df9404-goog
