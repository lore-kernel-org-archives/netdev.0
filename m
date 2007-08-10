From: akpm@linux-foundation.org
Subject: [patch 24/28] netconsole: Introduce netconsole_netdev_notifier
Date: Fri, 10 Aug 2007 14:12:06 -0700
Message-ID: <200708102112.l7ALC7Vf009451@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org, k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45167 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755899AbXHJVQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.

To update fields of underlying netpoll structure at runtime on corresponding
NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.

ioctl(SIOCSIFHWADDR or SIOCSIFNAME) could be used to change the hardware/MAC
address or name of the local interface that our netpoll is attached to. 
Whenever this happens, netdev notifier chain is called out with the
NETDEV_CHANGEADDR or NETDEV_CHANGENAME event message.  We respond to that and
update the local_mac or dev_name field of the struct netpoll.  This makes
sense anyway, but is especially required for dynamic netconsole because the
netpoll structure's internal members become user visible files when either
sysfs or configfs are used.  So this helps us to keep up with the MAC
address/name changes and keep values in struct netpoll uptodate.

[ Note that ioctl(SIOCSIFADDR) to change IP address of interface at
  runtime is not handled (to update local_ip of netpoll) on purpose --
  some setups may set the local_ip to a private address, not necessary
  the actual IP address of the sender host, as presently allowed. ]

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netconsole.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+)

diff -puN drivers/net/netconsole.c~netconsole-introduce-netconsole_netdev_notifier drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~netconsole-introduce-netconsole_netdev_notifier
+++ a/drivers/net/netconsole.c
@@ -80,6 +80,33 @@ static struct netconsole_target default_
 	},
 };
 
+/* Handle network interface device notifications */
+static int netconsole_netdev_event(struct notifier_block *this,
+				   unsigned long event,
+				   void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct netconsole_target *nt = &default_target;
+
+	if (nt->np.dev == dev) {
+		switch (event) {
+		case NETDEV_CHANGEADDR:
+			memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);
+			break;
+
+		case NETDEV_CHANGENAME:
+			strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
+			break;
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block netconsole_netdev_notifier = {
+	.notifier_call  = netconsole_netdev_event,
+};
+
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
@@ -122,6 +149,10 @@ static int __init init_netconsole(void)
 	if (err)
 		goto out;
 
+	err = register_netdevice_notifier(&netconsole_netdev_notifier);
+	if (err)
+		goto out;
+
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
 
@@ -134,6 +165,7 @@ static void __exit cleanup_netconsole(vo
 	struct netconsole_target *nt = &default_target;
 
 	unregister_console(&netconsole);
+	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 	netpoll_cleanup(&nt->np);
 }
 
_
