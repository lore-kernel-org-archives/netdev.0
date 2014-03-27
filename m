From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH v2 net] mac802154: stop tx queue before destroy workqueue
Date: Thu, 27 Mar 2014 19:23:20 +0100
Message-ID: <1395944600-18330-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:53984 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756827AbaC0SXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 14:23:45 -0400
Received: by mail-ee0-f50.google.com with SMTP id c13so3277622eek.9
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 11:23:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While transmit over a at86rf231 device which use the mac802154 stack and
unloading the module I got:

[   29.643073] WARNING: CPU: 0 PID: 3 at kernel/workqueue.c:1335 __queue_work+0xb4/0x224()
[   29.651457] Modules linked in: at86rf230(-) autofs4
[   29.656612] CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G        W    3.14.0-rc6-01602-g902659e-dirty #294
[   29.666490] [<c00124f0>] (unwind_backtrace) from [<c0010ad0>] (show_stack+0x10/0x14)
[   29.674628] [<c0010ad0>] (show_stack) from [<c0032c80>] (warn_slowpath_common+0x60/0x80)
[   29.683116] [<c0032c80>] (warn_slowpath_common) from [<c0032d30>] (warn_slowpath_null+0x18/0x20)
[   29.692329] [<c0032d30>] (warn_slowpath_null) from [<c0045b08>] (__queue_work+0xb4/0x224)
[   29.700906] [<c0045b08>] (__queue_work) from [<c0045cc8>] (queue_work_on+0x50/0x78)
[   29.708944] [<c0045cc8>] (queue_work_on) from [<c05669cc>] (mac802154_tx+0x1e4/0x240)
[   29.717164] [<c05669cc>] (mac802154_tx) from [<c0471814>] (dev_hard_start_xmit+0x2f0/0x43c)
[   29.725926] [<c0471814>] (dev_hard_start_xmit) from [<c04878d0>] (sch_direct_xmit+0x64/0x2a0)
[   29.734867] [<c04878d0>] (sch_direct_xmit) from [<c0487c38>] (__qdisc_run+0x12c/0x18c)
[   29.743169] [<c0487c38>] (__qdisc_run) from [<c046e1b0>] (net_tx_action+0xe0/0x178)
[   29.751205] [<c046e1b0>] (net_tx_action) from [<c0036690>] (__do_softirq+0x100/0x264)
[   29.759420] [<c0036690>] (__do_softirq) from [<c0036818>] (run_ksoftirqd+0x24/0x4c)
[   29.767453] [<c0036818>] (run_ksoftirqd) from [<c005232c>] (smpboot_thread_fn+0x128/0x13c)
[   29.776121] [<c005232c>] (smpboot_thread_fn) from [<c004c3fc>] (kthread+0xd0/0xe4)
[   29.784061] [<c004c3fc>] (kthread) from [<c000da88>] (ret_from_fork+0x14/0x2c)
[   29.791628] ---[ end trace 3406ff24bd973834 ]---

The problem is that we use a workqueue on xmit which is already destroyed by
ieee802154_unregister_device. This patch stops the transmit of packets
before flush and destroy the workqueue which is used by the mac802154
transmit workflow.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
changes since v2:
 - changes patch subject to the right one.

 net/mac802154/ieee802154_dev.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 52ae664..f3d0c7a 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -269,6 +269,11 @@ void ieee802154_unregister_device(struct ieee802154_dev *dev)
 	struct mac802154_priv *priv = mac802154_to_priv(dev);
 	struct mac802154_sub_if_data *sdata, *next;
 
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &priv->slaves, list)
+		netif_stop_queue(sdata->dev);
+	rcu_read_unlock();
+
 	flush_workqueue(priv->dev_workqueue);
 	destroy_workqueue(priv->dev_workqueue);
 
-- 
1.9.1
