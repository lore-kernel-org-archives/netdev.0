From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH v3 -mm 6/9] netconsole: Introduce netconsole_target
Date: Mon, 30 Jul 2007 08:18:40 +0530
Message-ID: <20070730024840.10828.48069.sendpatchset@enigma.security.iitk.ac.in>
References: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43500 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965900AbXG3CgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 22:36:20 -0400
In-Reply-To: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

[6/9] netconsole: Introduce netconsole_target

Introduce a wrapper structure over netpoll to represent logging targets
configured in netconsole. This will get extended with other members in
further patches.

This is done independent of the (to-be-introduced) NETCONSOLE_DYNAMIC
config option so that we're able to drastically cut down on the #ifdef
complexity of final netconsole.c. Also, struct netconsole_target would be
required for multiple targets support also, and not just dynamic
reconfigurability.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 drivers/net/netconsole.c |   36 +++++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 75cb761..be15ca6 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -62,24 +62,35 @@ static int __init option_setup(char *opt)
 __setup("netconsole=", option_setup);
 #endif	/* MODULE */
 
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
 
-	if (netif_running(np.dev)) {
+	if (netif_running(nt->np.dev)) {
 		local_irq_save(flags);
 		for (left = len; left;) {
 			frag = min(left, MAX_PRINT_CHUNK);
-			netpoll_send_udp(&np, msg, frag);
+			netpoll_send_udp(&nt->np, msg, frag);
 			msg += frag;
 			left -= frag;
 		}
@@ -96,17 +107,18 @@ static struct console netconsole = {
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
 
@@ -119,8 +131,10 @@ out:
 
 static void __exit cleanup_netconsole(void)
 {
+	struct netconsole_target *nt = &default_target;
+
 	unregister_console(&netconsole);
-	netpoll_cleanup(&np);
+	netpoll_cleanup(&nt->np);
 }
 
 module_init(init_netconsole);
