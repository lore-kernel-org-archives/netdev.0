From: Jason Baron <jbaron@redhat.com>
Subject: [PATCH 08/10] dynamic_debug: make netif_dbg() call __netdev_printk()
Date: Wed, 6 Jul 2011 13:25:07 -0400
Message-ID: <889f3300a96f381aee1239ea775014fff26d93c9.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
References: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Cc: joe@perches.com, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Baron <jbaron@redhat.com>

Previously, netif_dbg() was using dynamic_dev_dbg() to perform
the underlying printk. Fix it to use __netdev_printk(), instead.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Jason Baron <jbaron@redhat.com>
---
 include/linux/dynamic_debug.h |   12 ++++++++++++
 include/linux/netdevice.h     |    6 ++----
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
index feaac1e..7048e64 100644
--- a/include/linux/dynamic_debug.h
+++ b/include/linux/dynamic_debug.h
@@ -84,6 +84,18 @@ extern int __dynamic_netdev_dbg(struct _ddebug *descriptor,
 		__dynamic_netdev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);\
 	} while (0)
 
+#define dynamic_netif_dbg(dev, cond, fmt, ...) do {			\
+	static struct _ddebug descriptor				\
+	__used								\
+	__attribute__((section("__verbose"), aligned(8))) =		\
+	{ KBUILD_MODNAME, __func__, __FILE__, fmt, __LINE__,		\
+		_DPRINTK_FLAGS_DEFAULT };				\
+	if (unlikely(descriptor.enabled)) {				\
+		if (cond)						\
+			__dynamic_netdev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);\
+	}								\
+	} while (0)
+
 #else
 
 static inline int ddebug_remove_module(const char *mod)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9b132ef..99c358f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2731,10 +2731,8 @@ do {								\
 #elif defined(CONFIG_DYNAMIC_DEBUG)
 #define netif_dbg(priv, type, netdev, format, args...)		\
 do {								\
-	if (netif_msg_##type(priv))				\
-		dynamic_dev_dbg((netdev)->dev.parent,		\
-				"%s: " format,			\
-				netdev_name(netdev), ##args);	\
+	dynamic_netif_dbg(netdev, (netif_msg_##type(priv)),	\
+				  format, ##args);		\
 } while (0)
 #else
 #define netif_dbg(priv, type, dev, format, args...)			\
-- 
1.7.5.4
