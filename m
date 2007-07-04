From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 4/9] netconsole: Introduce netconsole_netdev_notifier
Date: Wed, 04 Jul 2007 16:37:59 +0530
Message-ID: <20070704110759.28520.37301.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57159 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761447AbXGDLIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:01 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[4/9] netconsole: Introduce netconsole_netdev_notifier

To update fields of underlying netpoll structure at runtime on
corresponding NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 drivers/net/netconsole.c |   36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-03 21:51:40.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-03 22:02:11.000000000 +0530
@@ -81,6 +81,37 @@ static struct netconsole_target default_
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
+	if (!(event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
+		goto done;
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
+done:
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
@@ -123,6 +154,10 @@ static int __init init_netconsole(void)
 	if (err)
 		goto out;
 
+	err = register_netdevice_notifier(&netconsole_netdev_notifier);
+	if (err)
+		return err;
+
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
 
@@ -135,6 +170,7 @@ static void __exit cleanup_netconsole(vo
 	struct netconsole_target *nt = &default_target;
 
 	unregister_console(&netconsole);
+	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 	netpoll_cleanup(&nt->np);
 }
 
