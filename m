From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take4 2/6] support multiple logging
Date: Wed, 18 Apr 2007 21:06:41 +0900
Message-ID: <462609D1.50300@bx.jp.nec.com>
References: <462605DC.2080804@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:42454 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422916AbXDRMGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 08:06:55 -0400
In-Reply-To: <462605DC.2080804@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch contains the following changes for supporting multiple logging
 agents.

1. extend netconsole to multiple netpolls
   To send kernel messages to multiple logging agents, extend netcosnole
    to be able to use multiple netpolls. Each netpoll sends kernel messages
    to its own logging agent.

2. change config parameter format
   We change config parameter format from single configuration to multiple 
   configurations separated by ';'.

   ex) sending kernel messages to destination1 and destination2 using eth0.
    modprobe netconsole \
            netconsole="@/eth0,@[destination1]/;@/eth0,@[destination2]/"

3. introduce CONFIG_NETCONSOLE_DYNCON config to change between 
   existing netconsole and netconsole applying the above function.

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
Index: mm/drivers/net/netconsole.c
===================================================================
--- mm.orig/drivers/net/netconsole.c
+++ mm/drivers/net/netconsole.c
@@ -61,15 +61,102 @@ static struct netpoll np = {
 	.remote_port = 6666,
 	.remote_mac = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
 };
-static int configured = 0;
 
 #define MAX_PRINT_CHUNK 1000
 
+#ifdef CONFIG_NETCONSOLE_DYNCON
+struct netconsole_target {
+	struct list_head list;
+	int id;
+	struct netpoll np;
+};
+
+static LIST_HEAD(target_list);
+static DEFINE_SPINLOCK(target_list_lock);
+
+static int add_target(char* target_config);
+static void remove_target(struct netconsole_target *nt);
+static void cleanup_netconsole(void);
+
+static int add_target(char* target_config)
+{
+	int retval = 0;
+	static atomic_t target_count = ATOMIC_INIT(0);
+	struct netconsole_target *new_target;
+
+	new_target = kzalloc(sizeof(*new_target), GFP_KERNEL);
+	if (!new_target) {
+		printk(KERN_ERR "netconsole: kmalloc() failed!\n");
+		retval = -ENOMEM;
+		goto out;
+	}
+
+	new_target->np = np;
+	if (netpoll_parse_options(&new_target->np, target_config)) {
+		printk(KERN_ERR "netconsole: can't parse config:%s\n",
+		       target_config);
+		kfree(new_target);
+		retval = -EINVAL;
+		goto out;
+	}
+	if (netpoll_setup(&new_target->np)) {
+		printk(KERN_ERR "netconsole: can't setup netpoll:%s\n",
+		       target_config);
+		kfree(new_target);
+		retval = -EINVAL;
+		goto out;
+	}
+
+	new_target->id = atomic_inc_return(&target_count);
+
+	printk(KERN_INFO "netconsole: add target: "
+	       "remote ip_addr=%d.%d.%d.%d remote port=%d\n",
+	       HIPQUAD(new_target->np.remote_ip), new_target->np.remote_port);
+
+	spin_lock(&target_list_lock);
+	list_add(&new_target->list, &target_list);
+	spin_unlock(&target_list_lock);
+
+ out:
+	return retval;
+}
+
+static void remove_target(struct netconsole_target *nt)
+{
+	spin_lock(&target_list_lock);
+	list_del(&nt->list);
+	if (list_empty(&target_list))
+		netpoll_cleanup(&nt->np);
+	spin_unlock(&target_list_lock);
+	kfree(nt);
+}
+#endif /* CONFIG_NETCONSOLE_DYNCON */
+
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
 	unsigned long flags;
+#ifdef CONFIG_NETCONSOLE_DYNCON
+	struct netconsole_target *target;
+
+	if (list_empty(&target_list))
+		return;
 
+	local_irq_save(flags);
+	spin_lock(&target_list_lock);
+
+	for(left = len; left; ) {
+		frag = min(left, MAX_PRINT_CHUNK);
+		list_for_each_entry(target, &target_list, list) {
+			netpoll_send_udp(&target->np, msg, frag);
+		}
+		msg += frag;
+		left -= frag;
+	}
+
+	spin_unlock(&target_list_lock);
+	local_irq_restore(flags);
+#else
 	if (!np.dev)
 		return;
 
@@ -83,6 +170,7 @@ static void write_msg(struct console *co
 	}
 
 	local_irq_restore(flags);
+#endif /* CONFIG_NETCONSOLE_DYNCON */
 }
 
 static struct console netconsole = {
@@ -91,39 +179,60 @@ static struct console netconsole = {
 	.write = write_msg
 };
 
+#ifndef MODULE
 static int __init option_setup(char *opt)
 {
-	configured = !netpoll_parse_options(&np, opt);
+	strncpy(config, opt, 256);
 	return 1;
 }
 
 __setup("netconsole=", option_setup);
+#endif
 
 static int __init init_netconsole(void)
 {
-	int err;
+	char *tmp = config;
+#ifdef CONFIG_NETCONSOLE_DYNCON
+	char *p;
 
-	if(strlen(config))
-		option_setup(config);
-
-	if(!configured) {
-		printk("netconsole: not configured, aborting\n");
+	register_console(&netconsole);
+	if(!strlen(config)) {
+		printk(KERN_ERR "netconsole: not configured\n");
 		return 0;
 	}
-
-	err = netpoll_setup(&np);
-	if (err)
-		return err;
-
+	while ((p = strsep(&tmp, ";")) != NULL) {
+		if (add_target(p)) {
+			printk(KERN_ERR
+			       "netconsole: can't add target to netconsole\n");
+			cleanup_netconsole();
+			return -EINVAL;
+		}
+	}
+#else
+	if (!strlen(config) ||
+	    netpoll_parse_options(&np, tmp) || netpoll_setup(&np)) {
+		printk(KERN_ERR "netconsole: can't parse config:%s\n", tmp);
+		return -EINVAL;
+	}
 	register_console(&netconsole);
+#endif /* CONFIG_NETCONSOLE_DYNCON */
 	printk(KERN_INFO "netconsole: network logging started\n");
 	return 0;
 }
 
 static void cleanup_netconsole(void)
 {
+#ifdef CONFIG_NETCONSOLE_DYNCON
+	struct netconsole_target *nt, *tmp;
+
+	unregister_console(&netconsole);
+	list_for_each_entry_safe(nt, tmp, &target_list, list) {
+		remove_target(nt);
+	}
+#else
 	unregister_console(&netconsole);
 	netpoll_cleanup(&np);
+#endif /* CONFIG_NETCONSOLE_DYNCON */
 }
 
 module_init(init_netconsole);
Index: mm/drivers/net/Kconfig
===================================================================
--- mm.orig/drivers/net/Kconfig
+++ mm/drivers/net/Kconfig
@@ -2986,6 +2986,14 @@ config NETCONSOLE
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
 
+config NETCONSOLE_DYNCON
+	default y
+	bool "Support for multiple logging and UI for netconsole"
+	depends on NETCONSOLE
+	---help---
+	This option enables multiple logging and changing dynamically
+	 configurations (e.g. IP adderss, port number and so on)
+	 by using sysfs and ioctl.
 endif #NETDEVICES
 
 config NETPOLL

-- 


