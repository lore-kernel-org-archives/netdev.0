From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 5/9] netconsole: Introduce dev_status member
Date: Wed, 04 Jul 2007 16:38:04 +0530
Message-ID: <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
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
Received: from mail4.iitk.ac.in ([203.197.196.4]:57177 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761446AbXGDLII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:08 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[5/9] netconsole: Introduce dev_status member

Introduce a new member in netconsole_target that tracks the status (up or
down) of the underlying interface network device that the specific logging
target netpoll is attached to.

We then join this up with the just-introduced net_device notifier, and
introduce NETDEV_UP and NETDEV_DOWN notifications. By disabling the target
when the corresponding local interface is down, we save the overhead of
unnecessarily disabling interrupts and calling into the netpoll stack in
console->write().

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 drivers/net/netconsole.c |   42 +++++++++++++++++++++++++++++++-----------
 1 file changed, 31 insertions(+), 11 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-03 22:05:51.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-04 03:04:45.000000000 +0530
@@ -63,11 +63,23 @@ static int __init option_setup(char *opt
 __setup("netconsole=", option_setup);
 #endif
 
+/*
+ * Why no net_dev_is_up() in netdevice.h? The kernel could lose a lot of
+ * weight if only netdevice.h had the good sense to export such a function.
+ * Oh well ...
+ */
+static inline int net_dev_is_up(struct net_device *net_dev)
+{
+	return ((net_dev->flags & IFF_UP) == IFF_UP);
+}
+
 /**
  * struct netconsole_target - Represents a configured netconsole target.
+ * @dev_status:	Tracks whether the underlying interface is up or down.
  * @np:		The netpoll structure for this target.
  */
 struct netconsole_target {
+	int			dev_status;
 	struct netpoll		np;
 };
 
@@ -89,11 +101,17 @@ static int netconsole_netdev_event(struc
 	struct net_device *dev = ptr;
 	struct netconsole_target *nt = &default_target;
 
-	if (!(event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
-		goto done;
+	if (!(event == NETDEV_UP || event == NETDEV_DOWN ||
+	      event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
+	      	goto done;
 
 	if (nt->np.dev == dev) {
 		switch (event) {
+		case NETDEV_UP:
+		case NETDEV_DOWN:
+			nt->dev_status = net_dev_is_up(nt->np.dev);
+			break;
+
 		case NETDEV_CHANGEADDR:
 			memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);
 			break;
@@ -118,16 +136,16 @@ static void write_msg(struct console *co
 	unsigned long flags;
 	struct netconsole_target *nt = &default_target;
 
-	local_irq_save(flags);
-
-	for (left = len; left;) {
-		frag = min(left, MAX_PRINT_CHUNK);
-		netpoll_send_udp(&nt->np, msg, frag);
-		msg += frag;
-		left -= frag;
+	if (nt->dev_status) {
+		local_irq_save(flags);
+		for (left = len; left;) {
+			frag = min(left, MAX_PRINT_CHUNK);
+			netpoll_send_udp(&nt->np, msg, frag);
+			msg += frag;
+			left -= frag;
+		}
+		local_irq_restore(flags);
 	}
-
-	local_irq_restore(flags);
 }
 
 static struct console netconsole = {
@@ -154,6 +172,8 @@ static int __init init_netconsole(void)
 	if (err)
 		goto out;
 
+	nt->dev_status = net_dev_is_up(nt->np.dev);
+
 	err = register_netdevice_notifier(&netconsole_netdev_notifier);
 	if (err)
 		return err;
