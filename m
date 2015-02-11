From: Jan Stancek <jstancek@redhat.com>
Subject: [PATCH] ipv6: fix possible deadlock in ip6_fl_purge / ip6_fl_gc
Date: Wed, 11 Feb 2015 14:06:23 +0100
Message-ID: <a26e3a5267c2a8816655018c5d46adcf52e71948.1423659369.git.jstancek@redhat.com>
Cc: linux-kernel@vger.kernel.org, jstancek@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746AbbBKNGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2015 08:06:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use spin_lock_bh in ip6_fl_purge() to prevent following potentially
deadlock scenario between ip6_fl_purge() and ip6_fl_gc() timer.

  =================================
  [ INFO: inconsistent lock state ]
  3.19.0 #1 Not tainted
  ---------------------------------
  inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
  swapper/5/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
   (ip6_fl_lock){+.?...}, at: [<ffffffff8171155d>] ip6_fl_gc+0x2d/0x180
  {SOFTIRQ-ON-W} state was registered at:
    [<ffffffff810ee9a0>] __lock_acquire+0x4a0/0x10b0
    [<ffffffff810efd54>] lock_acquire+0xc4/0x2b0
    [<ffffffff81751d2d>] _raw_spin_lock+0x3d/0x80
    [<ffffffff81711798>] ip6_flowlabel_net_exit+0x28/0x110
    [<ffffffff815f9759>] ops_exit_list.isra.1+0x39/0x60
    [<ffffffff815fa320>] cleanup_net+0x100/0x1e0
    [<ffffffff810ad80a>] process_one_work+0x20a/0x830
    [<ffffffff810adf4b>] worker_thread+0x11b/0x460
    [<ffffffff810b42f4>] kthread+0x104/0x120
    [<ffffffff81752bfc>] ret_from_fork+0x7c/0xb0
  irq event stamp: 84640
  hardirqs last  enabled at (84640): [<ffffffff81752080>] _raw_spin_unlock_irq+0x30/0x50
  hardirqs last disabled at (84639): [<ffffffff81751eff>] _raw_spin_lock_irq+0x1f/0x80
  softirqs last  enabled at (84628): [<ffffffff81091ad1>] _local_bh_enable+0x21/0x50
  softirqs last disabled at (84629): [<ffffffff81093b7d>] irq_exit+0x12d/0x150

  other info that might help us debug this:
   Possible unsafe locking scenario:

         CPU0
         ----
    lock(ip6_fl_lock);
    <Interrupt>
      lock(ip6_fl_lock);

   *** DEADLOCK ***

Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 net/ipv6/ip6_flowlabel.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 2f780cb..f45d6db 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -172,7 +172,7 @@ static void __net_exit ip6_fl_purge(struct net *net)
 {
 	int i;
 
-	spin_lock(&ip6_fl_lock);
+	spin_lock_bh(&ip6_fl_lock);
 	for (i = 0; i <= FL_HASH_MASK; i++) {
 		struct ip6_flowlabel *fl;
 		struct ip6_flowlabel __rcu **flp;
@@ -190,7 +190,7 @@ static void __net_exit ip6_fl_purge(struct net *net)
 			flp = &fl->next;
 		}
 	}
-	spin_unlock(&ip6_fl_lock);
+	spin_unlock_bh(&ip6_fl_lock);
 }
 
 static struct ip6_flowlabel *fl_intern(struct net *net,
-- 
1.7.1
