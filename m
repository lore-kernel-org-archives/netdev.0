From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/5) replay netdev notifier events on registration
Date: Tue, 13 Jan 2004 10:58:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113105843.0d1351cb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several protocols register for network device notification to detect new new network devices;
but then have to walk the device list to capture the devices that are already up.
This leaves a exposed window between when the notifier is registered and when the list walk
occurs. Also, in several cases, there is a different code path for the pre-existing and
new devices which leads to bug exposure.

The solution is to replay the registration and up events for existing devices into the
new notifier.

All notifiers in 2.6.1 have been audited and the other patches fix places
where protocols were doing there own registered device discovery loop.

Thanks to Al Viro for the suggestion.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Thu Dec 18 15:32:11 2003
+++ b/net/core/dev.c	Thu Dec 18 15:32:11 2003
@@ -946,11 +946,29 @@
  *	The notifier passed is linked into the kernel structures and must
  *	not be reused until it has been unregistered. A negative errno code
  *	is returned on a failure.
+ *
+ * 	When registered all registration and up events are replayed
+ *	to the new notifier to allow device to have a race free 
+ *	view of the network device list.
  */
 
 int register_netdevice_notifier(struct notifier_block *nb)
 {
-	return notifier_chain_register(&netdev_chain, nb);
+	struct net_device *dev;
+	int err;
+
+	rtnl_lock();
+	err = notifier_chain_register(&netdev_chain, nb);
+	if (!err) {
+		for (dev = dev_base; dev; dev = dev->next) {
+			nb->notifier_call(nb, NETDEV_REGISTER, dev);
+
+			if (dev->flags & IFF_UP) 
+				nb->notifier_call(nb, NETDEV_UP, dev);
+		}
+	}
+	rtnl_unlock();
+	return err;
 }
 
 /**
