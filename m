From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 02/22] netconsole: Introduce locking over the netpoll fields
Date: Tue, 14 Dec 2010 13:29:04 -0800
Message-ID: <20101214212904.17022.16604.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netconsole driver currently doesn't do any locking over its
configuration fields.  This can cause problems if we were to ever have
concurrent writing to fields while somebody is enabling the service.

For simplicity, this patch extends targets_list_lock to cover all
configuration fields within the targets.  Macros are also added here to
wrap accessors so that we check whether the target has been enabled with
locking handled.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
 drivers/net/netconsole.c |  114 ++++++++++++++++++++++++++--------------------
 1 files changed, 64 insertions(+), 50 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index c87a49e..6e16888 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -327,6 +327,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			     const char *buf,
 			     size_t count)
 {
+	unsigned long flags;
 	int err;
 	long enabled;
 
@@ -335,6 +336,10 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		return enabled;
 
 	if (enabled) {	/* 1 */
+		spin_lock_irqsave(&target_list_lock, flags);
+		if (nt->enabled)
+			goto busy;
+		spin_unlock_irqrestore(&target_list_lock, flags);
 
 		/*
 		 * Skip netpoll_parse_options() -- all the attributes are
@@ -343,18 +348,28 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		netpoll_print_options(&nt->np);
 
 		err = netpoll_setup(&nt->np);
+		spin_lock_irqsave(&target_list_lock, flags);
+		if (err)
+			nt->enabled = 0;
+		else
+			nt->enabled = 1;
+		spin_unlock_irqrestore(&target_list_lock, flags);
 		if (err)
 			return err;
 
 		printk(KERN_INFO "netconsole: network logging started\n");
-
 	} else {	/* 0 */
+		spin_lock_irqsave(&target_list_lock, flags);
+		nt->enabled = 0;
+		spin_unlock_irqrestore(&target_list_lock, flags);
+
 		netpoll_cleanup(&nt->np);
 	}
 
-	nt->enabled = enabled;
-
 	return strnlen(buf, count);
+busy:
+	spin_unlock_irqrestore(&target_list_lock, flags);
+	return -EBUSY;
 }
 
 static ssize_t store_dev_name(struct netconsole_target *nt,
@@ -363,13 +378,6 @@ static ssize_t store_dev_name(struct netconsole_target *nt,
 {
 	size_t len;
 
-	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
-		return -EINVAL;
-	}
-
 	strlcpy(nt->np.dev_name, buf, IFNAMSIZ);
 
 	/* Get rid of possible trailing newline from echo(1) */
@@ -387,13 +395,6 @@ static ssize_t store_local_port(struct netconsole_target *nt,
 	long local_port;
 #define __U16_MAX	((__u16) ~0U)
 
-	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
-		return -EINVAL;
-	}
-
 	local_port = strtol10_check_range(buf, 0, __U16_MAX);
 	if (local_port < 0)
 		return local_port;
@@ -410,13 +411,6 @@ static ssize_t store_remote_port(struct netconsole_target *nt,
 	long remote_port;
 #define __U16_MAX	((__u16) ~0U)
 
-	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
-		return -EINVAL;
-	}
-
 	remote_port = strtol10_check_range(buf, 0, __U16_MAX);
 	if (remote_port < 0)
 		return remote_port;
@@ -430,13 +424,6 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 			      const char *buf,
 			      size_t count)
 {
-	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
-		return -EINVAL;
-	}
-
 	nt->np.local_ip = in_aton(buf);
 
 	return strnlen(buf, count);
@@ -446,13 +433,6 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 			       const char *buf,
 			       size_t count)
 {
-	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
-		return -EINVAL;
-	}
-
 	nt->np.remote_ip = in_aton(buf);
 
 	return strnlen(buf, count);
@@ -466,13 +446,6 @@ static ssize_t store_remote_mac(struct netconsole_target *nt,
 	char *p = (char *) buf;
 	int i;
 
-	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
-		return -EINVAL;
-	}
-
 	for (i = 0; i < ETH_ALEN - 1; i++) {
 		remote_mac[i] = simple_strtoul(p, &p, 16);
 		if (*p != ':')
@@ -496,15 +469,56 @@ invalid:
  * Attribute definitions for netconsole_target.
  */
 
-#define NETCONSOLE_TARGET_ATTR_RO(_name)				\
+#define __NETCONSOLE_TARGET_ATTR_RO(_name, _prefix_...)			\
 static struct netconsole_target_attr netconsole_target_##_name =	\
-	__CONFIGFS_ATTR(_name, S_IRUGO, show_##_name, NULL)
+	__CONFIGFS_ATTR(_name, S_IRUGO, show_##_prefix_##_name, NULL)
 
-#define NETCONSOLE_TARGET_ATTR_RW(_name)				\
+#define __NETCONSOLE_TARGET_ATTR_RW(_name, _prefix_...)			\
 static struct netconsole_target_attr netconsole_target_##_name =	\
-	__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR, show_##_name, store_##_name)
+	__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR,			\
+			show_##_prefix_##_name, store_##_prefix_##_name)
+
+#define NETCONSOLE_WRAP_ATTR_STORE(_name)				\
+static ssize_t store_locked_##_name(struct netconsole_target *nt,	\
+				    const char *buf,			\
+				    size_t count)			\
+{									\
+	unsigned long flags;						\
+	ssize_t ret;							\
+	spin_lock_irqsave(&target_list_lock, flags);			\
+	if (nt->enabled) {						\
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "	\
+				"disable to update parameters\n",	\
+				config_item_name(&nt->item));		\
+		spin_unlock_irqrestore(&target_list_lock, flags);	\
+		return -EBUSY;						\
+	}								\
+	ret = store_##_name(nt, buf, count);				\
+	spin_unlock_irqrestore(&target_list_lock, flags);		\
+	return ret;							\
+}
+
+#define NETCONSOLE_WRAP_ATTR_SHOW(_name)				\
+static ssize_t show_locked_##_name(struct netconsole_target *nt, char *buf) \
+{									\
+	unsigned long flags;						\
+	ssize_t ret;							\
+	spin_lock_irqsave(&target_list_lock, flags);			\
+	ret = show_##_name(nt, buf);					\
+	spin_unlock_irqrestore(&target_list_lock, flags);		\
+	return ret;							\
+}
+
+#define NETCONSOLE_TARGET_ATTR_RW(_name)				\
+		NETCONSOLE_WRAP_ATTR_STORE(_name)			\
+		NETCONSOLE_WRAP_ATTR_SHOW(_name)			\
+		__NETCONSOLE_TARGET_ATTR_RW(_name, locked_)
+
+#define NETCONSOLE_TARGET_ATTR_RO(_name)				\
+		NETCONSOLE_WRAP_ATTR_SHOW(_name)			\
+		__NETCONSOLE_TARGET_ATTR_RO(_name, locked_)
 
-NETCONSOLE_TARGET_ATTR_RW(enabled);
+__NETCONSOLE_TARGET_ATTR_RW(enabled);
 NETCONSOLE_TARGET_ATTR_RW(dev_name);
 NETCONSOLE_TARGET_ATTR_RW(local_port);
 NETCONSOLE_TARGET_ATTR_RW(remote_port);
