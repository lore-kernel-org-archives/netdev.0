From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 04/11] net: Export xmit_recursion
Date: Sun, 13 Jul 2014 17:13:26 -0700
Message-ID: <1405296806-3736-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:44354 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751623AbaGNANa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 20:13:30 -0400
Received: by mail-pa0-f50.google.com with SMTP id bj1so4373724pad.37
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 17:13:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next patch adds re-circulation action to OVS. This is recursive
action needs to be limited to safe number recursions to
avoid overflowing kernel stack space.  This patch export
xmit_recursion so that OVS can increment and check the value
before executing recirc action.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/netdevice.h |  3 +++
 net/core/dev.c            | 10 +++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a320db..ca7a1ab 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1941,6 +1941,9 @@ static inline struct net_device *first_net_device_rcu(struct net *net)
 	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
 }
 
+#define NET_RECURSION_LIMIT 10
+DECLARE_PER_CPU(int, net_xmit_recursion);
+
 int netdev_boot_setup_check(struct net_device *dev);
 unsigned long netdev_boot_base(const char *prefix, int unit);
 struct net_device *dev_getbyhwaddr_rcu(struct net *net, unsigned short type,
diff --git a/net/core/dev.c b/net/core/dev.c
index 6e2a2cd..7f36a4f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2804,8 +2804,8 @@ static void skb_update_prio(struct sk_buff *skb)
 #define skb_update_prio(skb)
 #endif
 
-static DEFINE_PER_CPU(int, xmit_recursion);
-#define RECURSION_LIMIT 10
+DEFINE_PER_CPU(int, net_xmit_recursion);
+EXPORT_SYMBOL_GPL(net_xmit_recursion);
 
 /**
  *	dev_loopback_xmit - loop back @skb
@@ -2895,15 +2895,15 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 		if (txq->xmit_lock_owner != cpu) {
 
-			if (__this_cpu_read(xmit_recursion) > RECURSION_LIMIT)
+			if (__this_cpu_read(net_xmit_recursion) > NET_RECURSION_LIMIT)
 				goto recursion_alert;
 
 			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_xmit_stopped(txq)) {
-				__this_cpu_inc(xmit_recursion);
+				__this_cpu_inc(net_xmit_recursion);
 				rc = dev_hard_start_xmit(skb, dev, txq);
-				__this_cpu_dec(xmit_recursion);
+				__this_cpu_dec(net_xmit_recursion);
 				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
-- 
1.9.3
