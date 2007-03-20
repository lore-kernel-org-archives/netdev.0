From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take3 2/6][resend] support multiple logging
Date: Tue, 20 Mar 2007 21:26:13 +0900
Message-ID: <45FFD2E5.9070208@bx.jp.nec.com>
References: <45FFCF31.3040000@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:37509 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255AbXCTM0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 08:26:22 -0400
In-Reply-To: <45FFCF31.3040000@bx.jp.nec.com>
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

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
Index: linux-2.6.19.5/drivers/net/netconsole.c
===================================================================
--- linux-2.6.19.5.orig/drivers/net/netconsole.c
+++ linux-2.6.19.5/drivers/net/netconsole.c
@@ -54,6 +54,20 @@ static char config[256];
 module_param_string(netconsole, config, 256, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]\n");
 
+struct netconsole_target {
+	struct list_head list;
+	int id;
+	struct netpoll np;
+};
+
+static int add_target(char* target_config);
+static void cleanup_netconsole(void);
+static void delete_target(struct netconsole_target *nt);
+
+static LIST_HEAD(target_list);
+
+static DEFINE_SPINLOCK(target_list_lock);
+
 static struct netpoll np = {
 	.name = "netconsole",
 	.dev_name = "eth0",
@@ -61,27 +75,85 @@ static struct netpoll np = {
 	.remote_port = 6666,
 	.remote_mac = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
 };
-static int configured = 0;
 
 #define MAX_PRINT_CHUNK 1000
+#define CONFIG_SEPARATOR ";"
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
+	atomic_inc(&target_count);
+	new_target->id = atomic_read(&target_count);
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
+static void delete_target(struct netconsole_target *nt)
+{
+	spin_lock(&target_list_lock);
+	list_del(&nt->list);
+	spin_unlock(&target_list_lock);
+	netpoll_cleanup(&nt->np);
+	kfree(nt);
+}
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
 	unsigned long flags;
+	struct netconsole_target *target;
 
-	if (!np.dev)
+	if (list_empty(&target_list))
 		return;
 
 	local_irq_save(flags);
+	spin_lock(&target_list_lock);
 
 	for(left = len; left; ) {
 		frag = min(left, MAX_PRINT_CHUNK);
-		netpoll_send_udp(&np, msg, frag);
+		list_for_each_entry(target, &target_list, list) {
+			netpoll_send_udp(&target->np, msg, frag);
+		}
 		msg += frag;
 		left -= frag;
 	}
 
+	spin_unlock(&target_list_lock);
 	local_irq_restore(flags);
 }
 
@@ -91,39 +163,48 @@ static struct console netconsole = {
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
+	char *p;
+	char *tmp = config;
 
-	if(strlen(config))
-		option_setup(config);
+	register_console(&netconsole);
 
-	if(!configured) {
-		printk("netconsole: not configured, aborting\n");
+	if(!strlen(config)) {
+		printk(KERN_ERR "netconsole: not configured\n");
 		return 0;
 	}
+	while ((p = strsep(&tmp, CONFIG_SEPARATOR)) != NULL) {
+		if (add_target(p)) {
+			printk(KERN_ERR
+			       "netconsole: can't add target to netconsole\n");
+			cleanup_netconsole();
+			return -EINVAL;
+		}
+	}
 
-	err = netpoll_setup(&np);
-	if (err)
-		return err;
-
-	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
 	return 0;
 }
 
 static void cleanup_netconsole(void)
 {
+	struct netconsole_target *nt, *tmp;
+
 	unregister_console(&netconsole);
-	netpoll_cleanup(&np);
+	list_for_each_entry_safe(nt, tmp, &target_list, list) {
+		delete_target(nt);
+	}
 }
 
 module_init(init_netconsole);

-- 


