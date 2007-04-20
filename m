From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH -mm take4 2/6] support multiple logging
Date: Thu, 19 Apr 2007 21:08:13 -0700
Message-ID: <20070419210813.a599c54f.akpm@linux-foundation.org>
References: <462605DC.2080804@bx.jp.nec.com>
	<462609D1.50300@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:53233 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754363AbXDTEI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 00:08:29 -0400
In-Reply-To: <462609D1.50300@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Apr 2007 21:06:41 +0900 Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:

> From: Keiichi KII <k-keiichi@bx.jp.nec.com>
> 
> This patch contains the following changes for supporting multiple logging
>  agents.
> 
> 1. extend netconsole to multiple netpolls
>    To send kernel messages to multiple logging agents, extend netcosnole
>     to be able to use multiple netpolls. Each netpoll sends kernel messages
>     to its own logging agent.
> 
> 2. change config parameter format
>    We change config parameter format from single configuration to multiple 
>    configurations separated by ';'.
> 
>    ex) sending kernel messages to destination1 and destination2 using eth0.
>     modprobe netconsole \
>             netconsole="@/eth0,@[destination1]/;@/eth0,@[destination2]/"
> 
> 3. introduce CONFIG_NETCONSOLE_DYNCON config to change between 
>    existing netconsole and netconsole applying the above function.
> 
> Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
> Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
> ---
> Index: mm/drivers/net/netconsole.c
> ===================================================================
> --- mm.orig/drivers/net/netconsole.c
> +++ mm/drivers/net/netconsole.c
> @@ -61,15 +61,102 @@ static struct netpoll np = {
>  	.remote_port = 6666,
>  	.remote_mac = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
>  };
> -static int configured = 0;
>  
>  #define MAX_PRINT_CHUNK 1000
>  
> +#ifdef CONFIG_NETCONSOLE_DYNCON
> +struct netconsole_target {
> +	struct list_head list;
> +	int id;
> +	struct netpoll np;
> +};
> +
> +static LIST_HEAD(target_list);
> +static DEFINE_SPINLOCK(target_list_lock);
> +
> +static int add_target(char* target_config);
> +static void remove_target(struct netconsole_target *nt);
> +static void cleanup_netconsole(void);

I started to do some cleanups and fixups here, but abandoned it when it was
all getting a bit large.

Here are some fixes against this patch:


- Fix Kconfig

- Avoid need for forward-declared statics

- Coding style:

	fix `if' layout
	unneeded braces

- use spin_lock_irqsave() and _restore()



diff -puN drivers/net/Kconfig~netconsole-support-multiple-logging-fix drivers/net/Kconfig
--- a/drivers/net/Kconfig~netconsole-support-multiple-logging-fix
+++ a/drivers/net/Kconfig
@@ -2965,9 +2965,11 @@ config NETCONSOLE_DYNCON
 	bool "Support for multiple logging and UI for netconsole"
 	depends on NETCONSOLE
 	---help---
-	This option enables multiple logging and changing dynamically
-	 configurations (e.g. IP adderss, port number and so on)
-	 by using sysfs and ioctl.
+	  This option enables multiple logging and changing dynamically
+	  configurations (e.g. IP address, port number and so on)
+	  by using sysfs and ioctl.
+	  See <file:Documentation/networking/netconsole.txt> for details.
+
 endif #NETDEVICES
 
 config NETPOLL
diff -puN drivers/net/netconsole.c~netconsole-support-multiple-logging-fix drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~netconsole-support-multiple-logging-fix
+++ a/drivers/net/netconsole.c
@@ -74,10 +74,6 @@ struct netconsole_target {
 static LIST_HEAD(target_list);
 static DEFINE_SPINLOCK(target_list_lock);
 
-static int add_target(char* target_config);
-static void remove_target(struct netconsole_target *nt);
-static void cleanup_netconsole(void);
-
 static int add_target(char* target_config)
 {
 	int retval = 0;
@@ -142,27 +138,24 @@ static void write_msg(struct console *co
 	if (list_empty(&target_list))
 		return;
 
-	local_irq_save(flags);
-	spin_lock(&target_list_lock);
+	spin_lock_irqsave(&target_list_lock, flags);
 
-	for(left = len; left; ) {
+	for (left = len; left; ) {
 		frag = min(left, MAX_PRINT_CHUNK);
-		list_for_each_entry(target, &target_list, list) {
+		list_for_each_entry(target, &target_list, list)
 			netpoll_send_udp(&target->np, msg, frag);
-		}
 		msg += frag;
 		left -= frag;
 	}
 
-	spin_unlock(&target_list_lock);
-	local_irq_restore(flags);
+	spin_unlock_irqrestore(&target_list_lock, flags);
 #else
 	if (!np.dev)
 		return;
 
 	local_irq_save(flags);
 
-	for(left = len; left; ) {
+	for (left = len; left; ) {
 		frag = min(left, MAX_PRINT_CHUNK);
 		netpoll_send_udp(&np, msg, frag);
 		msg += frag;
@@ -189,6 +182,20 @@ static int __init option_setup(char *opt
 __setup("netconsole=", option_setup);
 #endif
 
+static void cleanup_netconsole(void)
+{
+#ifdef CONFIG_NETCONSOLE_DYNCON
+	struct netconsole_target *nt, *tmp;
+
+	unregister_console(&netconsole);
+	list_for_each_entry_safe(nt, tmp, &target_list, list)
+		remove_target(nt);
+#else
+	unregister_console(&netconsole);
+	netpoll_cleanup(&np);
+#endif /* CONFIG_NETCONSOLE_DYNCON */
+}
+
 static int __init init_netconsole(void)
 {
 	char *tmp = config;
@@ -196,7 +203,7 @@ static int __init init_netconsole(void)
 	char *p;
 
 	register_console(&netconsole);
-	if(!strlen(config)) {
+	if (!strlen(config)) {
 		printk(KERN_ERR "netconsole: not configured\n");
 		return 0;
 	}
@@ -220,20 +227,5 @@ static int __init init_netconsole(void)
 	return 0;
 }
 
-static void cleanup_netconsole(void)
-{
-#ifdef CONFIG_NETCONSOLE_DYNCON
-	struct netconsole_target *nt, *tmp;
-
-	unregister_console(&netconsole);
-	list_for_each_entry_safe(nt, tmp, &target_list, list) {
-		remove_target(nt);
-	}
-#else
-	unregister_console(&netconsole);
-	netpoll_cleanup(&np);
-#endif /* CONFIG_NETCONSOLE_DYNCON */
-}
-
 module_init(init_netconsole);
 module_exit(cleanup_netconsole);
_

