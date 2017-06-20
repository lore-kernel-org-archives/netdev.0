From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] igmp: add a missing spin_lock_init()
Date: Tue, 20 Jun 2017 10:46:27 -0700
Message-ID: <1497980787-4040-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35988 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdFTRqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 13:46:43 -0400
Received: by mail-pf0-f195.google.com with SMTP id y7so24832735pfd.3
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 10:46:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a lockdep warning on non-initialized
spinlock:

 INFO: trying to register non-static key.
 the code is fine but needs lockdep annotation.
 turning off the locking correctness validator.
 CPU: 1 PID: 4099 Comm: a.out Not tainted 4.12.0-rc6+ #9
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 Call Trace:
  __dump_stack lib/dump_stack.c:16
  dump_stack+0x292/0x395 lib/dump_stack.c:52
  register_lock_class+0x717/0x1aa0 kernel/locking/lockdep.c:755
  ? 0xffffffffa0000000
  __lock_acquire+0x269/0x3690 kernel/locking/lockdep.c:3255
  lock_acquire+0x22d/0x560 kernel/locking/lockdep.c:3855
  __raw_spin_lock_bh ./include/linux/spinlock_api_smp.h:135
  _raw_spin_lock_bh+0x36/0x50 kernel/locking/spinlock.c:175
  spin_lock_bh ./include/linux/spinlock.h:304
  ip_mc_clear_src+0x27/0x1e0 net/ipv4/igmp.c:2076
  igmpv3_clear_delrec+0xee/0x4f0 net/ipv4/igmp.c:1194
  ip_mc_destroy_dev+0x4e/0x190 net/ipv4/igmp.c:1736

We miss a spin_lock_init() in igmpv3_add_delrec(), probably
because previously we never use it on this code path. Since
we already unlink it from the global mc_tomb list, it is
probably safe not to acquire this spinlock here. It does not
harm to have it although, to avoid conditional locking.

Fixes: c38b7d327aaf ("igmp: acquire pmc lock for ip_mc_clear_src()")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/igmp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 8f6b5bb..ec9a396 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1112,6 +1112,7 @@ static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 	pmc = kzalloc(sizeof(*pmc), GFP_KERNEL);
 	if (!pmc)
 		return;
+	spin_lock_init(&pmc->lock);
 	spin_lock_bh(&im->lock);
 	pmc->interface = im->interface;
 	in_dev_hold(in_dev);
-- 
2.5.5
