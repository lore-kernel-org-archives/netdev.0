From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv2] net: Abstract features usage.
Date: Tue, 24 May 2011 18:55:44 -0700
Message-ID: <1306288544-1700-1-git-send-email-maheshb@google.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:32978 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab1EYBzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 21:55:54 -0400
In-Reply-To: <1306263162-2022-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define macros to set/clear/test bits for feature set usage. This will eliminate
the direct use of these fields and enable future ease in managing these fields.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
Changes since v1:
 Split the patch into two pieces.

 include/linux/netdev_features.h |   64 +++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h       |    8 +++++
 2 files changed, 72 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netdev_features.h

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
new file mode 100644
index 0000000..3043c4d
--- /dev/null
+++ b/include/linux/netdev_features.h
@@ -0,0 +1,64 @@
+#ifndef _NETDEV_FEATURES_H
+#define _NETDEV_FEATURES_H
+
+/* Forward declarations */
+struct net_device;
+
+typedef unsigned long *nd_feature_t;
+
+static inline void _nd_set_feature(u32 *old_field,
+		unsigned long *new_field, int bit)
+{
+	if (bit < 32)
+		*old_field |= (1 << bit);
+	set_bit(bit, new_field);
+}
+
+static inline void _nd_clear_feature(u32 *old_field,
+		unsigned long *new_field, int bit)
+{
+	if (bit < 32)
+		*old_field &= ~(1 << bit);
+
+	clear_bit(bit, new_field);
+}
+
+static inline bool _nd_test_feature(u32 old_field,
+		unsigned long *new_field, int bit)
+{
+	if (bit < 32)
+		return (old_field & (1 << bit)) == 1;	
+
+	return test_bit(bit, new_field) == 1;
+}
+
+#define netdev_set_active_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->features, (dev)->active_feature, (bit))
+#define netdev_clear_active_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->features, (dev)->active_feature, (bit))
+#define netdev_test_active_feature(dev, bit)	\
+	_nd_test_feature((dev)->features, (dev)->active_feature, (bit))
+
+#define netdev_set_offered_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->hw_features, (dev)->offered_feature, (bit))
+#define netdev_clear_offered_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->hw_features, (dev)->offered_feature, (bit))
+#define netdev_test_offered_feature(dev, bit)	\
+	_nd_test_feature((dev)->hw_features, (dev)->offered_feature, (bit))
+
+#define netdev_set_vlan_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->vlan_features, (dev)->vlan_feature, (bit))
+#define netdev_clear_vlan_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->vlan_features, (dev)->vlan_feature, (bit))
+#define netdev_test_vlan_feature(dev, bit)	\
+	_nd_test_feature((dev)->vlan_features, (dev)->vlan_feature, (bit))
+
+#define netdev_set_wanted_feature(dev, bit)	\
+	_nd_set_feature(&(dev)->wanted_features, (dev)->wanted_feature, (bit))
+#define netdev_clear_wanted_feature(dev, bit)	\
+	_nd_clear_feature(&(dev)->wanted_features, (dev)->wanted_feature, (bit))
+#define netdev_test_wanted_feature(dev, bit)	\
+	_nd_test_feature((dev)->wanted_features, (dev)->wanted_feature, (bit))
+
+
+#endif	/* __NETDEV_FEATURES_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b4520b2..e565ceb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1079,6 +1079,14 @@ struct net_device {
 	/* mask of features inheritable by VLAN devices */
 	u32			vlan_features;
 
+#define DEV_FEATURE_WORDS	BITS_TO_LONGS(ND_FEATURE_NUM_BITS)
+#define DEV_FEATURE_BITS	(DEV_FEATURE_WORDS * BITS_PER_LONG)
+
+	DECLARE_BITMAP(active_feature, DEV_FEATURE_BITS);
+	DECLARE_BITMAP(offered_feature, DEV_FEATURE_BITS);
+	DECLARE_BITMAP(wanted_feature, DEV_FEATURE_BITS);
+	DECLARE_BITMAP(vlan_feature, DEV_FEATURE_BITS);
+
 #define BIT2FLAG(bit)		(1 << (bit))
 
 #define NETIF_F_SG		BIT2FLAG(SG_BIT)
-- 
1.7.3.1

