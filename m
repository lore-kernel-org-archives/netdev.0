From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: Coexist with the sysfs limitations
Date: Wed, 22 Oct 2008 13:32:36 -0700
Message-ID: <m17i80nzff.fsf@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36150 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbYJVUea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 16:34:30 -0400
In-Reply-To: <20081022152144.351965414@theryb.frec.bull.fr> (Benjamin Thery's
	message of "Wed, 22 Oct 2008 17:21:44 +0200")
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

I.e. people running distributions that make it next to
impossible to boot without sysfs should at be able to
boot a test kernel now.

Plus no ABIs are harmed with this patch.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/Kconfig          |    2 +-
 net/core/dev.c       |   12 +++++++++++-
 net/core/net-sysfs.c |    7 +++++++
 3 files changed, 19 insertions(+), 2 deletions(-)

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
index b8a4fd0..a7f0461 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4449,6 +4449,15 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
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
@@ -4506,6 +4515,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	 */
 	dev_addr_discard(dev);
 
+	netdev_unregister_kobject(dev);
+
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
@@ -4522,7 +4533,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
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

