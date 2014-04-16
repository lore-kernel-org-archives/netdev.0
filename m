From: "Li, Zhen-Hua" <zhen-hual@hp.com>
Subject: [PATCH 1/1] net: Add rtnl_lock for netif_device_attach/detach
Date: Wed, 16 Apr 2014 15:08:02 +0800
Message-ID: <1397632082-18453-1-git-send-email-zhen-hual@hp.com>
Cc: "Li, Zhen-Hua" <zhen-hual@hp.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Li, Zhen-Hua" <zhen-hual@hp.com>

As netif_running is called in netif_device_attach/detach. There should be
rtnl_lock/unlock called, to avoid dev stat change during netif_device_attach
and detach being called.
I checked NIC some drivers,  some of them have netif_device_attach/detach
called between rtnl_lock/unlock, while some drivers do not.

This patch is tring to find a generic way to fix this for all NIC drivers.

Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>
---
 net/core/dev.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5b3042e..795bbc5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2190,10 +2190,19 @@ EXPORT_SYMBOL(__dev_kfree_skb_any);
  */
 void netif_device_detach(struct net_device *dev)
 {
+	/**
+	 * As netif_running is called , rtnl_lock and unlock are needed to
+	 * avoid __LINK_STATE_START bit changes during this function call.
+	 */
+	int need_unlock;
+
+	need_unlock = rtnl_trylock();
 	if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
 	    netif_running(dev)) {
 		netif_tx_stop_all_queues(dev);
 	}
+	if (need_unlock)
+		rtnl_unlock();
 }
 EXPORT_SYMBOL(netif_device_detach);
 
@@ -2205,11 +2214,20 @@ EXPORT_SYMBOL(netif_device_detach);
  */
 void netif_device_attach(struct net_device *dev)
 {
+	/**
+	 * As netif_running is called , rtnl_lock and unlock are needed to
+	 * avoid __LINK_STATE_START bit changes during this function call.
+	 */
+	int need_unlock;
+
+	need_unlock = rtnl_trylock();
 	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
 	    netif_running(dev)) {
 		netif_tx_wake_all_queues(dev);
 		__netdev_watchdog_up(dev);
 	}
+	if (need_unlock)
+		rtnl_unlock();
 }
 EXPORT_SYMBOL(netif_device_attach);
 
-- 
1.7.10.4
