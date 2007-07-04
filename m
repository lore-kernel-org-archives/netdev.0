From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 2/9] netconsole: Code simplification
Date: Wed, 04 Jul 2007 16:37:49 +0530
Message-ID: <20070704110749.28520.92997.sendpatchset@cselinux1.cse.iitk.ac.in>
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
Received: from mail4.iitk.ac.in ([203.197.196.4]:57166 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761454AbXGDLIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:02 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[2/9] netconsole: Code simplification

(1) Extract netpoll_parse_options() out of option_setup(), and into
init_netconsole() itself. So "configured" variable is redundant and
can be removed.

(2) With this change, option_setup() is not required for modular netconsole.

(3) The (!np.dev) check in write_msg() is bogus (always false), because:
np.dev is set by netpoll_setup(), which is called by the target init
code in init_netconsole() _before_ register_console() => write_msg() cannot
be triggered unless netpoll_setup() returns with success. And that will not
happen if netpoll_setup() failed to set np.dev. Also np.dev cannot go from
under us while netconsole is loaded. This is because netpoll_setup() grabs
a reference for us on that dev. So let's remove the pointless check.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 drivers/net/netconsole.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-03 21:45:16.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-03 21:45:37.000000000 +0530
@@ -53,6 +53,16 @@ static char config[MAX_PARAM_LENGTH];
 module_param_string(netconsole, config, MAX_PARAM_LENGTH, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]\n");
 
+#ifndef	MODULE
+static int __init option_setup(char *opt)
+{
+	strlcpy(config, opt, MAX_PARAM_LENGTH);
+	return 1;
+}
+
+__setup("netconsole=", option_setup);
+#endif
+
 static struct netpoll np = {
 	.name		= "netconsole",
 	.dev_name	= "eth0",
@@ -60,16 +70,12 @@ static struct netpoll np = {
 	.remote_port	= 6666,
 	.remote_mac	= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
 };
-static int configured;
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
 	unsigned long flags;
 
-	if (!np.dev)
-		return;
-
 	local_irq_save(flags);
 
 	for (left = len; left;) {
@@ -88,26 +94,19 @@ static struct console netconsole = {
 	.write	= write_msg,
 };
 
-static int __init option_setup(char *opt)
-{
-	configured = !netpoll_parse_options(&np, opt);
-	return 1;
-}
-
-__setup("netconsole=", option_setup);
-
 static int __init init_netconsole(void)
 {
 	int err = 0;
 
-	if (strnlen(config, MAX_PARAM_LENGTH))
-		option_setup(config);
-
-	if (!configured) {
+	if (!strnlen(config, MAX_PARAM_LENGTH)) {
 		printk(KERN_INFO "netconsole: not configured, aborting\n");
 		goto out;
 	}
 
+	err = netpoll_parse_options(&np, config);
+	if (err)
+		goto out;
+
 	err = netpoll_setup(&np);
 	if (err)
 		goto out;
