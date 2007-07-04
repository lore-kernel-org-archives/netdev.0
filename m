From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 3/9] netconsole: Introduce netconsole_target
Date: Wed, 04 Jul 2007 16:37:54 +0530
Message-ID: <20070704110754.28520.73112.sendpatchset@cselinux1.cse.iitk.ac.in>
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
Received: from mail4.iitk.ac.in ([203.197.196.4]:57178 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758968AbXGDLIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:10 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[3/9] netconsole: Introduce netconsole_target

Introduce a wrapper structure over netpoll to represent targets
configured in netconsole. This will get extended with other members in
further patches.

Ok, so the original patchset did this along with (and inside the #ifdef)
of CONFIG_NETCONSOLE_DYNAMIC itself. I decided otherwise, and was able
to drastically cut down on the #ifdef-complexity of final netconsole.c.
Also, struct netconsole_target would be required for multiple targets
support also, and not just dynamic reconfigurability. Previously these
two things were coupled, but I want to de-link that. (more on this later)

Note that this patch in itself looks quite redundant / stupid, but it is
purposefully made this way, so further patches are much more readable.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 drivers/net/netconsole.c |   34 ++++++++++++++++++++++++----------
 1 file changed, 24 insertions(+), 10 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-03 21:16:41.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-03 21:35:32.000000000 +0530
@@ -63,24 +63,35 @@ static int __init option_setup(char *opt
 __setup("netconsole=", option_setup);
 #endif
 
-static struct netpoll np = {
-	.name		= "netconsole",
-	.dev_name	= "eth0",
-	.local_port	= 6665,
-	.remote_port	= 6666,
-	.remote_mac	= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
+/**
+ * struct netconsole_target - Represents a configured netconsole target.
+ * @np:		The netpoll structure for this target.
+ */
+struct netconsole_target {
+	struct netpoll		np;
+};
+
+static struct netconsole_target default_target = {
+	.np		= {
+		.name		= "netconsole",
+		.dev_name	= "eth0",
+		.local_port	= 6665,
+		.remote_port	= 6666,
+		.remote_mac	= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
+	},
 };
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
 	unsigned long flags;
+	struct netconsole_target *nt = &default_target;
 
 	local_irq_save(flags);
 
 	for (left = len; left;) {
 		frag = min(left, MAX_PRINT_CHUNK);
-		netpoll_send_udp(&np, msg, frag);
+		netpoll_send_udp(&nt->np, msg, frag);
 		msg += frag;
 		left -= frag;
 	}
@@ -97,17 +108,18 @@ static struct console netconsole = {
 static int __init init_netconsole(void)
 {
 	int err = 0;
+	struct netconsole_target *nt = &default_target;
 
 	if (!strnlen(config, MAX_PARAM_LENGTH)) {
 		printk(KERN_INFO "netconsole: not configured, aborting\n");
 		goto out;
 	}
 
-	err = netpoll_parse_options(&np, config);
+	err = netpoll_parse_options(&nt->np, config);
 	if (err)
 		goto out;
 
-	err = netpoll_setup(&np);
+	err = netpoll_setup(&nt->np);
 	if (err)
 		goto out;
 
@@ -120,8 +132,10 @@ out:
 
 static void __exit cleanup_netconsole(void)
 {
+	struct netconsole_target *nt = &default_target;
+
 	unregister_console(&netconsole);
-	netpoll_cleanup(&np);
+	netpoll_cleanup(&nt->np);
 }
 
 module_init(init_netconsole);
