From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 -mm 3/9] netconsole: Simplify boot/module option setup logic
Date: Tue, 10 Jul 2007 14:49:36 +0530
Message-ID: <20070710091936.23907.68970.sendpatchset@cselinux1.cse.iitk.ac.in>
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
Received: from mail4.iitk.ac.in ([203.197.196.4]:42599 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758348AbXGJI5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:22 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[3/9] netconsole: Simplify boot/module option setup logic

Presently, for built-in netconsole:

__setup(..., option_setup) ensures that the option_setup() function is
called at boot-time from obsolete_checksetup() with the string matching
"netconsole=" passed to it from the kernel's command line. We call the
netpoll_parse_options() from in there, and populate the netpoll struct
with the passed values. Then, when init_netconsole() is called during the
initcall phase, strlen(config) fails, thus skipping option_setup().

For modular netconsole:

module_param_string() ensures that the string corresponding to the
"netconsole" module parameter passed from the modprobe command line is
copied into the "config" static variable. This time, when the module is
being initialized, strlen(config) is true and so option_setup() is called
on "config" from init_netconsole() and the input string is parsed and the
netpoll struct populated.

Hence, quite different things happen in the copying and parsing of the
passed netpoll parameters for the modular / built-in cases. This patch
makes both of them similar by doing exactly the equivalent of a
module_param_string() in option_setup() also -- just copying the param
string passed from the kernel command line into the "config" static
variable. So, init_netconsole() parses (using netpoll_parse_options())
it in both the cases, and makes the logic somewhat simpler.

Now, option_setup() is only ever called / used for the built-in case,
so we put it inside a #ifndef MODULE, otherwise gcc will complain about
option_setup() being "defined but not used".

Also, the "configured" variable is redundant with this patch and so removed.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 drivers/net/netconsole.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-10 06:00:15.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-10 06:28:19.000000000 +0530
@@ -53,6 +53,15 @@ static char config[MAX_PARAM_LENGTH];
 module_param_string(netconsole, config, MAX_PARAM_LENGTH, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]\n");
 
+#ifndef	MODULE
+static int __init option_setup(char *opt)
+{
+	strlcpy(config, opt, MAX_PARAM_LENGTH);
+	return 1;
+}
+__setup("netconsole=", option_setup);
+#endif	/* MODULE */
+
 static struct netpoll np = {
 	.name		= "netconsole",
 	.dev_name	= "eth0",
@@ -60,7 +69,6 @@ static struct netpoll np = {
 	.remote_port	= 6666,
 	.remote_mac	= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
 };
-static int configured;
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
@@ -85,26 +93,19 @@ static struct console netconsole = {
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
