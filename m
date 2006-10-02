From: Jiri Benc <jbenc@suse.cz>
Subject: d80211: for testing only: really stupid rate control algorithm
Date: Mon, 2 Oct 2006 20:26:41 +0200
Message-ID: <20061002202641.3595a310@griffin.suse.cz>
References: <20061002202530.235763132.midnight@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45518 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965277AbWJBS0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 14:26:43 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20061002202530.235763132.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a rate control algorithm intended for the testing of rate modules
changing. It's name is "lowest". It uses always the lowest rate available.

Usage:
echo -n lowest > /sys/class/ieee80211/phy0/rate_ctrl_alg

---

 net/d80211/Makefile         |    2 -
 net/d80211/rc80211_lowest.c |  106 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+), 1 deletions(-)
 create mode 100644 net/d80211/rc80211_lowest.c

5b994b344d168fae604c7c4270a651d562d4701d
diff --git a/net/d80211/Makefile b/net/d80211/Makefile
index d5d4d41..d02c2d6 100644
--- a/net/d80211/Makefile
+++ b/net/d80211/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_D80211) += 80211.o rc80211_simple.o
+obj-$(CONFIG_D80211) += 80211.o rc80211_simple.o rc80211_lowest.o
 
 80211-objs-$(CONFIG_D80211_LEDS) += ieee80211_led.o
 
diff --git a/net/d80211/rc80211_lowest.c b/net/d80211/rc80211_lowest.c
new file mode 100644
index 0000000..e1b6ccf
--- /dev/null
+++ b/net/d80211/rc80211_lowest.c
@@ -0,0 +1,106 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005, Devicescape Software, Inc.
+ * Copyright (c) 2006 Jiri Benc <jbenc@suse.cz>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+
+#include <net/d80211.h>
+#include "ieee80211_i.h"
+#include "ieee80211_rate.h"
+
+static void rate_control_lowest_tx_status(void *priv, struct net_device *dev,
+					  struct sk_buff *skb,
+					  struct ieee80211_tx_status *status)
+{
+}
+
+static struct ieee80211_rate *
+rate_control_lowest_get_rate(void *priv, struct net_device *dev,
+			     struct sk_buff *skb,
+			     struct rate_control_extra *extra)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	int i;
+
+	for (i = 0; i < local->num_curr_rates; i++) {
+		struct ieee80211_rate *rate = &local->curr_rates[i];
+
+		if (rate->flags & IEEE80211_RATE_SUPPORTED)
+			return rate;
+	}
+	return &local->curr_rates[0];
+}
+
+static void rate_control_lowest_rate_init(void *priv, void *priv_sta,
+					  struct ieee80211_local *local,
+					  struct sta_info *sta)
+{
+	sta->txrate = 0;
+}
+
+static void *rate_control_lowest_alloc(struct ieee80211_local *local)
+{
+	return kzalloc(sizeof(int), GFP_KERNEL);
+}
+
+static void rate_control_lowest_free(void *priv)
+{
+	kfree(priv);
+}
+
+static void rate_control_lowest_clear(void *priv)
+{
+}
+
+static void * rate_control_lowest_alloc_sta(void *priv, gfp_t gfp)
+{
+	return kzalloc(sizeof(int), gfp);
+}
+
+
+static void rate_control_lowest_free_sta(void *priv, void *priv_sta)
+{
+	kfree(priv_sta);
+}
+
+static struct rate_control_ops rate_control_lowest = {
+	.module = THIS_MODULE,
+	.name = "lowest",
+	.tx_status = rate_control_lowest_tx_status,
+	.get_rate = rate_control_lowest_get_rate,
+	.rate_init = rate_control_lowest_rate_init,
+	.clear = rate_control_lowest_clear,
+	.alloc = rate_control_lowest_alloc,
+	.free = rate_control_lowest_free,
+	.alloc_sta = rate_control_lowest_alloc_sta,
+	.free_sta = rate_control_lowest_free_sta,
+};
+
+static int __init rate_control_lowest_init(void)
+{
+	return ieee80211_rate_control_register(&rate_control_lowest);
+}
+
+
+static void __exit rate_control_lowest_exit(void)
+{
+	ieee80211_rate_control_unregister(&rate_control_lowest);
+}
+
+
+module_init(rate_control_lowest_init);
+module_exit(rate_control_lowest_exit);
+
+MODULE_DESCRIPTION("Testing rate control algorithm for ieee80211");
+MODULE_LICENSE("GPL");
-- 
1.3.0

