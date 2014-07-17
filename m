From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v2 net-next 2/2] net: print net_device reg_state in netdev_* unless it's registered
Date: Thu, 17 Jul 2014 16:09:46 +0200
Message-ID: <1405606186-13703-3-git-send-email-vfalico@gmail.com>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933853AbaGQOOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 10:14:24 -0400
In-Reply-To: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This way we'll always know in what status the device is, unless it's
running normally (i.e. NETDEV_REGISTERED).

CC: "David S. Miller" <davem@davemloft.net>
CC: Jason Baron <jbaron@akamai.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Vlad Yasevich <vyasevic@redhat.com>
CC: stephen hemminger <stephen@networkplumber.org>
CC: Jerry Chu <hkchu@google.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 include/linux/netdevice.h | 17 ++++++++++++++++-
 lib/dynamic_debug.c       |  8 +++++---
 net/core/dev.c            |  8 +++++---
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 70256aa..d868858 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3388,6 +3388,20 @@ static inline const char *netdev_name(const struct net_device *dev)
 	return dev->name;
 }
 
+static inline const char *netdev_reg_state(const struct net_device *dev)
+{
+	switch (dev->reg_state) {
+	case NETREG_UNINITIALIZED: return " (unregistered)";
+	case NETREG_REGISTERED: return "";
+	case NETREG_UNREGISTERING: return " (unregistering)";
+	case NETREG_UNREGISTERED: return " (unregistered)";
+	case NETREG_RELEASED: return " (released)";
+	case NETREG_DUMMY: return " (dummy)";
+	}
+
+	return " (unknown)";
+}
+
 __printf(3, 4)
 int netdev_printk(const char *level, const struct net_device *dev,
 		  const char *format, ...);
@@ -3444,7 +3458,8 @@ do {								\
  * file/line information and a backtrace.
  */
 #define netdev_WARN(dev, format, args...)			\
-	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##args)
+	WARN(1, "netdevice: %s%s\n" format, netdev_name(dev),	\
+	     netdev_reg_state(dev), ##args)
 
 /* netif printk helpers, similar to netdev_printk */
 
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 7288e38..c9afbe2 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -614,13 +614,15 @@ int __dynamic_netdev_dbg(struct _ddebug *descriptor,
 		char buf[PREFIX_SIZE];
 
 		res = dev_printk_emit(7, dev->dev.parent,
-				      "%s%s %s %s: %pV",
+				      "%s%s %s %s%s: %pV",
 				      dynamic_emit_prefix(descriptor, buf),
 				      dev_driver_string(dev->dev.parent),
 				      dev_name(dev->dev.parent),
-				      netdev_name(dev), &vaf);
+				      netdev_name(dev), netdev_reg_state(dev),
+				      &vaf);
 	} else if (dev) {
-		res = printk(KERN_DEBUG "%s: %pV", netdev_name(dev), &vaf);
+		res = printk(KERN_DEBUG "%s%s: %pV", netdev_name(dev),
+			     netdev_reg_state(dev), &vaf);
 	} else {
 		res = printk(KERN_DEBUG "(NULL net_device): %pV", &vaf);
 	}
diff --git a/net/core/dev.c b/net/core/dev.c
index 239722a..81d6101 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6950,12 +6950,14 @@ static int __netdev_printk(const char *level, const struct net_device *dev,
 	if (dev && dev->dev.parent) {
 		r = dev_printk_emit(level[1] - '0',
 				    dev->dev.parent,
-				    "%s %s %s: %pV",
+				    "%s %s %s%s: %pV",
 				    dev_driver_string(dev->dev.parent),
 				    dev_name(dev->dev.parent),
-				    netdev_name(dev), vaf);
+				    netdev_name(dev), netdev_reg_state(dev),
+				    vaf);
 	} else if (dev) {
-		r = printk("%s%s: %pV", level, netdev_name(dev), vaf);
+		r = printk("%s%s%s: %pV", level, netdev_name(dev),
+			   netdev_reg_state(dev), vaf);
 	} else {
 		r = printk("%s(NULL net_device): %pV", level, vaf);
 	}
-- 
1.8.4
