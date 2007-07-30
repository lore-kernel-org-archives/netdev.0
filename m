From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH v3 -mm 3/9] netconsole: Simplify boot/module option setup logic
Date: Mon, 30 Jul 2007 08:18:11 +0530
Message-ID: <20070730024811.10828.30537.sendpatchset@enigma.security.iitk.ac.in>
References: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43478 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966047AbXG3Cfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 22:35:51 -0400
In-Reply-To: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

[3/9] netconsole: Simplify boot/module option setup logic

Presently, boot/module parameters are set up quite differently for the
case of built-in netconsole (__setup() -> obsolete_checksetup() ->
netpoll_parse_options() -> strlen(config) == 0 in init_netconsole())
vs modular netconsole (module_param_string() -> string copied to the
config variable -> strlen(config) != 0 init_netconsole() ->
netpoll_parse_options()).

This patch makes both of them similar by doing exactly the equivalent
of a module_param_string() in option_setup() also -- just copying the
param string passed from the kernel command line into "config" variable.
So, strlen(config) != 0 in both cases, and netpoll_parse_options() is
always called from init_netconsole(), thus making the setup logic for
both cases similar.

Now, option_setup() is only ever called / used for the built-in case,
so we put it inside a #ifndef MODULE, otherwise gcc will complain about
option_setup() being "defined but not used". Also, the "configured"
variable is redundant with this patch and hence removed.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Acked-by: Matt Mackall <mpm@selenic.com>

---

 drivers/net/netconsole.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 2c2aef1..e56aa6c 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
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
