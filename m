From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next] net/core: generic support for disabling netdev features down stack
Date: Mon,  2 Nov 2015 12:53:38 -0500
Message-ID: <1446486818-26166-1-git-send-email-jarod@redhat.com>
References: <1445658019-58621-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440AbbKBRxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2015 12:53:46 -0500
In-Reply-To: <1445658019-58621-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some netdev features, which when disabled on an upper device,
such as a bonding master or a bridge, must be disabled and cannot be
re-enabled on underlying devices.

This is a rework of an earlier more heavy-handed appraoch, which simply
disables and prevents re-enabling of netdev features listed in a new
define in include/net/netdev_features.h, NETIF_F_UPPER_DISABLES. Any upper
device that disables a flag in that feature mask, the disabling will
propagate down the stack, and any lower device that has any upper device
with one of those flags disabled should not be able to enable said flag.

Initially, only LRO is included for proof of concept, and because this
code effectively does the same thing as dev_disable_lro(), though it will
also activate from the ethtool path, which was one of the goals here.

[root@dell-per730-01 ~]# ethtool -k bond0 |grep large
large-receive-offload: on
[root@dell-per730-01 ~]# ethtool -k p5p1 |grep large
large-receive-offload: on
[root@dell-per730-01 ~]# ethtool -K bond0 lro off
[root@dell-per730-01 ~]# ethtool -k bond0 |grep large
large-receive-offload: off
[root@dell-per730-01 ~]# ethtool -k p5p1 |grep large
large-receive-offload: off

dmesg dump:

[ 1033.277986] bond0: Disabling feature 0x0000000000008000 on lower dev p5p2.
[ 1034.067949] bnx2x 0000:06:00.1 p5p2: using MSI-X  IRQs: sp 74  fp[0] 76 ... fp[7] 83
[ 1034.753612] bond0: Disabling feature 0x0000000000008000 on lower dev p5p1.
[ 1035.591019] bnx2x 0000:06:00.0 p5p1: using MSI-X  IRQs: sp 62  fp[0] 64 ... fp[7] 71

This has been successfully tested with bnx2x, qlcnic and netxen network
cards as slaves in a bond interface. Turning LRO on or off on the master
also turns it on or off on each of the slaves, new slaves are added with
LRO in the same state as the master, and LRO can't be toggled on the
slaves.

Also, this should largely remove the need for dev_disable_lro(), and most,
if not all, of its call sites can be replaced by simply making sure
NETIF_F_LRO isn't included in the relevant device's feature flags.

Note that this patch is driven by bug reports from users saying it was
confusing that bonds and slaves had different settings for the same
features, and while it won't be 100% in sync if a lower device doesn't
support a feature like LRO, I think this is a good step in the right
direction.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Nikolay Aleksandrov <razor@blackwall.org>
CC: Michal Kubecek <mkubecek@suse.cz>
CC: Alexander Duyck <alexander.duyck@gmail.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
Note: this replaces "[RFC PATCH net-next] net/core: initial support for
stacked dev feature toggles" for consideration.

 include/linux/netdev_features.h | 11 +++++++++
 net/core/dev.c                  | 52 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9672781..0f5837a 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -125,6 +125,11 @@ enum {
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
 
+#define for_each_netdev_feature(mask_addr, feature)				\
+	int bit;								\
+	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)	\
+		feature = __NETIF_F_BIT(bit);
+
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
 #define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
@@ -167,6 +172,12 @@ enum {
  */
 #define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
 
+/*
+ * If upper/master device has these features disabled, they must be disabled
+ * on all lower/slave devices as well.
+ */
+#define NETIF_F_UPPER_DISABLES	NETIF_F_LRO
+
 /* changeable features with no special hardware requirements */
 #define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 13f49f8..3a8dbbc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6288,9 +6288,51 @@ static void rollback_registered(struct net_device *dev)
 	list_del(&single);
 }
 
+static netdev_features_t netdev_sync_upper_features(struct net_device *lower,
+	struct net_device *upper, netdev_features_t features)
+{
+	netdev_features_t upper_disables = NETIF_F_UPPER_DISABLES;
+	netdev_features_t feature;
+
+	for_each_netdev_feature(&upper_disables, feature) {
+		if (!(upper->wanted_features & feature)
+		    && (features & feature)) {
+			netdev_dbg(lower, "Dropping feature %pNF, upper dev %s has it off.\n",
+				   &feature, upper->name);
+			features &= ~feature;
+		}
+	}
+
+	return features;
+}
+
+static void netdev_sync_lower_features(struct net_device *upper,
+	struct net_device *lower, netdev_features_t features)
+{
+	netdev_features_t upper_disables = NETIF_F_UPPER_DISABLES;
+	netdev_features_t feature;
+
+	for_each_netdev_feature(&upper_disables, feature) {
+		if (!(features & feature) && (lower->features & feature)) {
+			netdev_dbg(upper, "Disabling feature %pNF on lower dev %s.\n",
+				   &feature, lower->name);
+			upper->wanted_features &= ~feature;
+			lower->wanted_features &= ~feature;
+			netdev_update_features(lower);
+
+			if (unlikely(lower->features & feature))
+				netdev_WARN(upper, "failed to disable %pNF on %s!\n",
+					    &feature, lower->name);
+		}
+	}
+}
+
 static netdev_features_t netdev_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
+	struct net_device *upper, *lower;
+	struct list_head *iter;
+
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
 	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
@@ -6345,6 +6387,16 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		}
 	}
 
+	/* some features can't be enabled if they're off an an upper device */
+	netdev_for_each_upper_dev_rcu(dev, upper, iter)
+		features = netdev_sync_upper_features(dev, upper, features);
+
+	/* some features must be disabled on lower devices when disabled
+	 * on an upper device (think: bonding master or bridge)
+	 */
+	netdev_for_each_lower_dev(dev, lower, iter)
+		netdev_sync_lower_features(dev, lower, features);
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	if (dev->netdev_ops->ndo_busy_poll)
 		features |= NETIF_F_BUSY_POLL;
-- 
1.8.3.1
