From: Zoran Markovic <zoran.markovic@linaro.org>
Subject: [RFC PATCH] net: ipv4: move inetpeer garbage collector work to power efficient workqueue
Date: Thu, 30 Jan 2014 15:40:13 -0800
Message-ID: <1391125213-8119-1-git-send-email-zoran.markovic@linaro.org>
Cc: netdev@vger.kernel.org, Shaibal Dutta <shaibal.dutta@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Zoran Markovic <zoran.markovic@linaro.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaibal Dutta <shaibal.dutta@broadcom.com>

Garbage collector work does not have to be bound to the CPU that scheduled
it. By moving work to the power-efficient workqueue, the selection of
CPU executing the work is left to the scheduler. This extends idle
residency times and conserves power.

This functionality is enabled when CONFIG_WQ_POWER_EFFICIENT is selected.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Shaibal Dutta <shaibal.dutta@broadcom.com>
[zoran.markovic@linaro.org: Rebased to latest kernel version. Added
commit message.]
Signed-off-by: Zoran Markovic <zoran.markovic@linaro.org>
---
 net/ipv4/inetpeer.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 48f4244..87155aa 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -161,7 +161,8 @@ static void inetpeer_gc_worker(struct work_struct *work)
 	list_splice(&list, &gc_list);
 	spin_unlock_bh(&gc_lock);
 
-	schedule_delayed_work(&gc_work, gc_delay);
+	queue_delayed_work(system_power_efficient_wq,
+		&gc_work, gc_delay);
 }
 
 /* Called from ip_output.c:ip_init  */
@@ -576,7 +577,8 @@ static void inetpeer_inval_rcu(struct rcu_head *head)
 	list_add_tail(&p->gc_list, &gc_list);
 	spin_unlock_bh(&gc_lock);
 
-	schedule_delayed_work(&gc_work, gc_delay);
+	queue_delayed_work(system_power_efficient_wq,
+		&gc_work, gc_delay);
 }
 
 void inetpeer_invalidate_tree(struct inet_peer_base *base)
-- 
1.7.9.5
