From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net] mac802154: move flush and destroy
	workqueue
Date: Thu, 27 Mar 2014 19:19:07 +0100
Message-ID: <1395944347-17589-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
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


------------------------------------------------------------------------------
