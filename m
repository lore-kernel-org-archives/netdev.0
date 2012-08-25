From: Cong Wang <amwang@redhat.com>
Subject: [Patch] netpoll: revert 6bdb7fe3104 and fix be_poll() instead
Date: Sat, 25 Aug 2012 15:41:11 +0800
Message-ID: <1345880471-29535-1-git-send-email-amwang@redhat.com>
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193Ab2HYHlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2012 03:41:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Against -net.

In the patch "netpoll: re-enable irq in poll_napi()", I tried to
fix the following warning:

[100718.051041] ------------[ cut here ]------------
[100718.051048] WARNING: at kernel/softirq.c:159 local_bh_enable_ip+0x7d/0xb0() 
(Not tainted)
[100718.051049] Hardware name: ProLiant BL460c G7
...
[100718.051068] Call Trace:
[100718.051073]  [<ffffffff8106b747>] ? warn_slowpath_common+0x87/0xc0
[100718.051075]  [<ffffffff8106b79a>] ? warn_slowpath_null+0x1a/0x20
[100718.051077]  [<ffffffff810747ed>] ? local_bh_enable_ip+0x7d/0xb0
[100718.051080]  [<ffffffff8150041b>] ? _spin_unlock_bh+0x1b/0x20
[100718.051085]  [<ffffffffa00ee974>] ? be_process_mcc+0x74/0x230 [be2net]
[100718.051088]  [<ffffffffa00ea68c>] ? be_poll_tx_mcc+0x16c/0x290 [be2net]
[100718.051090]  [<ffffffff8144fe76>] ? netpoll_poll_dev+0xd6/0x490
[100718.051095]  [<ffffffffa01d24a5>] ? bond_poll_controller+0x75/0x80 [bonding]
[100718.051097]  [<ffffffff8144fde5>] ? netpoll_poll_dev+0x45/0x490
[100718.051100]  [<ffffffff81161b19>] ? ksize+0x19/0x80
[100718.051102]  [<ffffffff81450437>] ? netpoll_send_skb_on_dev+0x157/0x240

by reenabling IRQ before calling ->poll, but it seems more
problems are introduced after that patch:

http://ozlabs.org/~akpm/stuff/IMG_20120824_122054.jpg
http://marc.info/?l=linux-netdev&m=134563282530588&w=2

So it is safe to fix be2net driver code directly.

This patch reverts the offending commit and fixes be_poll() by
avoid disabling BH there, this is okay because be_poll()
can be called either by poll_napi() which already disables
IRQ, or by net_rx_action() which already disables BH.

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
Cc: Sylvain Munaut <s.munaut@whatever-company.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>
Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7fac97b..8c63d06 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -259,7 +259,7 @@ int be_process_mcc(struct be_adapter *adapter)
 	int num = 0, status = 0;
 	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 
-	spin_lock_bh(&adapter->mcc_cq_lock);
+	spin_lock(&adapter->mcc_cq_lock);
 	while ((compl = be_mcc_compl_get(adapter))) {
 		if (compl->flags & CQE_FLAGS_ASYNC_MASK) {
 			/* Interpret flags as an async trailer */
@@ -280,7 +280,7 @@ int be_process_mcc(struct be_adapter *adapter)
 	if (num)
 		be_cq_notify(adapter, mcc_obj->cq.id, mcc_obj->rearm_cq, num);
 
-	spin_unlock_bh(&adapter->mcc_cq_lock);
+	spin_unlock(&adapter->mcc_cq_lock);
 	return status;
 }
 
@@ -295,7 +295,9 @@ static int be_mcc_wait_compl(struct be_adapter *adapter)
 		if (be_error(adapter))
 			return -EIO;
 
+		local_bh_disable();
 		status = be_process_mcc(adapter);
+		local_bh_enable();
 
 		if (atomic_read(&mcc_obj->q.used) == 0)
 			break;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 90a903d8..78b8aa8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3763,7 +3763,9 @@ static void be_worker(struct work_struct *work)
 	/* when interrupts are not yet enabled, just reap any pending
 	* mcc completions */
 	if (!netif_running(adapter->netdev)) {
+		local_bh_disable();
 		be_process_mcc(adapter);
+		local_bh_enable();
 		goto reschedule;
 	}
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 346b1eb..e4ba3e7 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -168,24 +168,16 @@ static void poll_napi(struct net_device *dev)
 	struct napi_struct *napi;
 	int budget = 16;
 
-	WARN_ON_ONCE(!irqs_disabled());
-
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
-		local_irq_enable();
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
-			rcu_read_lock_bh();
 			budget = poll_one_napi(rcu_dereference_bh(dev->npinfo),
 					       napi, budget);
-			rcu_read_unlock_bh();
 			spin_unlock(&napi->poll_lock);
 
-			if (!budget) {
-				local_irq_disable();
+			if (!budget)
 				break;
-			}
 		}
-		local_irq_disable();
 	}
 }
 
