From: akpm@linux-foundation.org
Subject: [patch 20/28] netconsole: Simplify boot/module option setup logic
Date: Fri, 10 Aug 2007 14:12:03 -0700
Message-ID: <200708102112.l7ALC4HF009439@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org, k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33128 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761950AbXHJVQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.

Presently, boot/module parameters are set up quite differently for the case of
built-in netconsole (__setup() -> obsolete_checksetup() ->
netpoll_parse_options() -> strlen(config) == 0 in init_netconsole()) vs
modular netconsole (module_param_string() -> string copied to the config
variable -> strlen(config) != 0 init_netconsole() -> netpoll_parse_options()).

This patch makes both of them similar by doing exactly the equivalent of a
module_param_string() in option_setup() also -- just copying the param string
passed from the kernel command line into "config" variable.  So,
strlen(config) != 0 in both cases, and netpoll_parse_options() is always
called from init_netconsole(), thus making the setup logic for both cases
similar.

Now, option_setup() is only ever called / used for the built-in case, so we
put it inside a #ifndef MODULE, otherwise gcc will complain about
option_setup() being "defined but not used".  Also, the "configured" variable
is redundant with this patch and hence removed.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Acked-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netconsole.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff -puN drivers/net/netconsole.c~netconsole-simplify-boot-module-option-setup-logic drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~netconsole-simplify-boot-module-option-setup-logic
+++ a/drivers/net/netconsole.c
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
_
