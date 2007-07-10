From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 -mm 6/9] netconsole: Introduce netconsole_netdev_notifier
Date: Tue, 10 Jul 2007 14:49:51 +0530
Message-ID: <20070710091951.23907.36072.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:56120 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758010AbXGJI5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:37 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[6/9] netconsole: Introduce netconsole_netdev_notifier

To update fields of underlying netpoll structure at runtime on
corresponding NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.

ioctl(SIOCSIFHWADDR) {or ioctl(SIOCSIFNAME)} could be used to change the
hardware/MAC address {or name} of the local interface that our netpoll is
attached to. Whenever this happens, netdev notifier chain is called out
with the NETDEV_CHANGEADDR {or NETDEV_CHANGENAME} event message. We respond
to that and update the local_mac {or dev_name} field of the struct netpoll.
This makes sense anyway, but is especially required for dynamic netconsole
because the netpoll structure's internal members become user visible files
when either sysfs or configfs are used. So this helps us to keep up with the
MAC address / name changes and keep the values in struct netpoll uptodate.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 drivers/net/netconsole.c |   32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-10 06:57:44.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-10 07:24:27.000000000 +0530
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
 
