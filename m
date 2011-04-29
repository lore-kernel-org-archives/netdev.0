From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] bridge: Module use count must be updated as bridges
	 are created/destroyed
Date: Fri, 29 Apr 2011 08:21:14 +0100
Message-ID: <4DBA830A020000780003ED5D@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <bridge@lists.linux-foundation.org>,
	"Jeff Mahoney" <jeffm@suse.com>, <netdev@vger.kernel.org>
To: <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise 'modprobe -r' on a module having a dependency on bridge will
implicitly unload bridge, bringing down all connectivity that was using
bridges.

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Cc: Jeff Mahoney <jeffm@suse.com>

---
 net/bridge/br_if.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- 2.6.39-rc5/net/bridge/br_if.c
+++ 2.6.39-rc5-bridge-module-get-put/net/bridge/br_if.c
@@ -290,6 +290,11 @@ int br_add_bridge(struct net *net, const
 	if (!dev)
 		return -ENOMEM;
 
+	if (!try_module_get(THIS_MODULE)) {
+		free_netdev(dev);
+		return -ENOENT;
+	}
+
 	rtnl_lock();
 	if (strchr(dev->name, '%')) {
 		ret = dev_alloc_name(dev, dev->name);
@@ -308,6 +313,8 @@ int br_add_bridge(struct net *net, const
 		unregister_netdevice(dev);
  out:
 	rtnl_unlock();
+	if (ret)
+		module_put(THIS_MODULE);
 	return ret;
 
 out_free:
@@ -339,6 +346,8 @@ int br_del_bridge(struct net *net, const
 		del_br(netdev_priv(dev), NULL);
 
 	rtnl_unlock();
+	if (ret == 0)
+		module_put(THIS_MODULE);
 	return ret;
 }
 



