From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 3/3] bridge: allow zero ageing time
Date: Tue,  8 Mar 2016 12:59:35 -0800
Message-ID: <1457470775-32224-4-git-send-email-stephen@networkplumber.org>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36583 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbcCHU70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:59:26 -0500
Received: by mail-pa0-f52.google.com with SMTP id tt10so20615139pab.3
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 12:59:26 -0800 (PST)
In-Reply-To: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>

This fixes a regression in the bridge ageing time caused by:
commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to switchdev")

There are users of Linux bridge which use the feature that if ageing time
is set to 0 it causes entries to never expire. See:
  https://www.linuxfoundation.org/collaborate/workgroups/networking/bridge

For a pure software bridge, it is unnecessary for the code to have
arbitrary restrictions on what values are allowable.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Please apply to 4.4 for stable as well.
---
 include/linux/if_bridge.h |  4 ----
 net/bridge/br_stp.c       | 11 ++++++++---
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index a338a68..dcb89e3 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -46,10 +46,6 @@ struct br_ip_list {
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
 
-/* values as per ieee8021QBridgeFdbAgingTime */
-#define BR_MIN_AGEING_TIME	(10 * HZ)
-#define BR_MAX_AGEING_TIME	(1000000 * HZ)
-
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index b3cca12..8b5898a 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -568,6 +568,14 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
 
 }
 
+/* Set time interval that dynamic forwarding entries live
+ * For pure software bridge, allow values outside the 802.1
+ * standard specification for special cases:
+ *  0 - entry never ages (all permanant)
+ *  1 - entry disappears (no persistance)
+ *
+ * Offloaded switch entries maybe more restrictive
+ */
 int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
 {
 	struct switchdev_attr attr = {
@@ -579,9 +587,6 @@ int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
 	unsigned long t = clock_t_to_jiffies(ageing_time);
 	int err;
 
-	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
-		return -ERANGE;
-
 	err = switchdev_port_attr_set(br->dev, &attr);
 	if (err)
 		return err;
-- 
2.1.4
