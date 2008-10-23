From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: Coexist with the sysfs limitations v2
Date: Thu, 23 Oct 2008 08:56:08 -0700
Message-ID: <m1fxmni9uv.fsf_-_@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m17i80nzff.fsf@frodo.ebiederm.org> <20081022212124.GA9910@us.ibm.com>
	<49003019.40904@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36653 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756554AbYJWQEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 12:04:33 -0400
In-Reply-To: <49003019.40904@bull.net> (Benjamin Thery's message of "Thu, 23
	Oct 2008 10:04:41 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To make testing of the network namespace simpler allow
the network namespace code and the sysfs code to be
compiled and run at the same time.  To do this only
virtual devices are allowed in the additional network
namespaces and those virtual devices are not placed
in the kobject tree.

Since virtual devices don't actually do anything interesting
hardware wise that needs device management there should
be no loss in keeping them out of the kobject tree and
by implication sysfs.  The gain in ease of testing
and code coverage should be significant.

Changelog:

v2: As pointed out by Benjamin Thery it only makes sense to call
    device_rename in the initial network namespace for now.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
Tested-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/Kconfig          |    2 +-
 net/core/dev.c       |   25 ++++++++++++++++++++-----
 net/core/net-sysfs.c |    7 +++++++
 3 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index d789d79..8c3d97c 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -27,7 +27,7 @@ menu "Networking options"
 config NET_NS
 	bool "Network namespace support"
 	default n
-	depends on EXPERIMENTAL && !SYSFS && NAMESPACES
+	depends on EXPERIMENTAL && NAMESPACES
 	help
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
diff --git a/net/core/dev.c b/net/core/dev.c
index b8a4fd0..0e38594 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -924,10 +924,15 @@ int dev_change_name(struct net_device *dev, const char *newname)
 		strlcpy(dev->name, newname, IFNAMSIZ);
 
 rollback:
-	ret = device_rename(&dev->dev, dev->name);
-	if (ret) {
-		memcpy(dev->name, oldname, IFNAMSIZ);
-		return ret;
+	/* For now only devices in the initial network namespace
+	 * are in sysfs.
+	 */
+	if (net == &init_net) {
+		ret = device_rename(&dev->dev, dev->name);
+		if (ret) {
+			memcpy(dev->name, oldname, IFNAMSIZ);
+			return ret;
+		}
 	}
 
 	write_lock_bh(&dev_base_lock);
@@ -4449,6 +4454,15 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	if (dev->features & NETIF_F_NETNS_LOCAL)
 		goto out;
 
+#ifdef CONFIG_SYSFS
+	/* Don't allow real devices to be moved when sysfs
+	 * is enabled.
+	 */
+	err = -EINVAL;
+	if (dev->dev.parent)
+		goto out;
+#endif
+
 	/* Ensure the device has been registrered */
 	err = -EINVAL;
 	if (dev->reg_state != NETREG_REGISTERED)
@@ -4506,6 +4520,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	 */
 	dev_addr_discard(dev);
 
+	netdev_unregister_kobject(dev);
+
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
@@ -4522,7 +4538,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	}
 
 	/* Fixup kobjects */
-	netdev_unregister_kobject(dev);
 	err = netdev_register_kobject(dev);
 	WARN_ON(err);
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 92d6b94..85cb8bd 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -476,6 +476,10 @@ void netdev_unregister_kobject(struct net_device * net)
 	struct device *dev = &(net->dev);
 
 	kobject_get(&dev->kobj);
+
+	if (dev_net(net) != &init_net)
+		return;
+
 	device_del(dev);
 }
 
@@ -501,6 +505,9 @@ int netdev_register_kobject(struct net_device *net)
 #endif
 #endif /* CONFIG_SYSFS */
 
+	if (dev_net(net) != &init_net)
+		return 0;
+
 	return device_add(dev);
 }
 
-- 
1.5.3.rc6.17.g1911

