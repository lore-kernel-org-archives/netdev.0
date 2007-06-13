From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take5 6/7] add ioctls for adding/removing target
Date: Wed, 13 Jun 2007 19:31:06 +0900
Message-ID: <466FC76A.6050006@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:57564 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756454AbXFMKbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 06:31:31 -0400
In-Reply-To: <466FC455.5060001@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

We add ioctls for adding/removing target.
If we use NETCONSOLE_ADD_TARGET ioctl, 
we can dynamically add netconsole target.
If we use NETCONSOLE_REMOVE_TARGET ioctl,
we can dynamically remoe netconsole target.

We attach a sample program for ioctl.

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
/*
 * This software is a sample program for ioctl of netconsole.
 * You can add/remove netconsole port by using this software.
 *
 * Copyright (C) 2007 NEC Corporation

 * Created by Keiichi KII <k-keiichi@bx.jp.nec.com>

 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 or
 *  (at your option) any later version.
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stropts.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <linux/if_ether.h>
#include <linux/netconsole.h>

#define NETCONSOLE_DEV_NAME "/dev/netconsole"
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

struct command {
	char *name;
	char *options;
	int (*handle_command)(struct command* command, int argc, char* argv[]);
	void (*usage)(char *msg);
};

extern char *optarg;
extern int opterr, optind, errno;

static void generic_usage(char *msg) {
	fprintf(stderr, "Usage  : netconfig command [option] [args]\n");
	fprintf(stderr, "command: add remove help\n");
	exit(-1);
}

static int handle_command_add(struct command* command, int argc, char** argv)
{
	int i, fd, ch;
	unsigned int address;
	unsigned char mac[ETH_ALEN];
	struct netconsole_request req = {
		.netdev_name = "eth0",
		.local_port = 6665,
		.remote_port = 6666,
		.remote_mac = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF},
	};

	while ((ch = getopt(argc, argv, command->options)) != -1) {
		switch (ch) {
		case 'p':
			req.local_port = atoi(optarg);
			break;
		case 's':
			address = inet_addr(optarg);
			if (address == -1)
				(*command->usage)("invlid IP address!\n");
			req.local_ip = address;
			break;
		case 'h':
		default:
			(*command->usage)(NULL);
		}
	}
	argc -= optind;
	argv += optind;

	if (argc < 3 || argc > 4)
		(*command->usage)(NULL);

	memcpy(req.netdev_name, argv[0], IFNAMSIZ);
	address = inet_addr(argv[1]);
	if (address == -1)
		(*command->usage)("invlid IP address!\n");
	req.remote_ip = address;
	req.remote_port = atoi(argv[2]);
	if (argc == 4) {
		i = 0;
		mac[i++] = strtol(argv[3], NULL, 16);
		while ((argv[3] = strchr(argv[3], ':')) != NULL) {
			argv[3]++;
			mac[i++] = strtol(argv[3], NULL, 16);
		}
		if (i != ETH_ALEN)
			(*command->usage)("Invalid MAC address!\n");
		memcpy(req.remote_mac, mac, ETH_ALEN);
	}

	fd = open(NETCONSOLE_DEV_NAME, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "cannot open device" NETCONSOLE_DEV_NAME "\n");
		return -1;
	}

	if(ioctl(fd, NETCON_ADD_TARGET, &req) != 0)
		perror("add");
	close(fd);

	return 0;
}

static void usage_add(char *msg)
{
	if (msg != NULL)
		fprintf(stderr, "%s", msg);
	fprintf(stderr, "Usage  : netconfig add [-options] dev_name remote_ip "
		"remote_port [remote_mac]\n");
	fprintf(stderr, "options:\n");
	fprintf(stderr, "        -p local_port     :local port number\n");
	fprintf(stderr, "        -s local_up       :local IP address\n");
	exit(-1);
}

static int handle_command_remove(struct command *command,
				 int argc, char** argv)
{
	int fd, id, ch;

	while ((ch = getopt(argc, argv, command->options)) != -1) {
		switch (ch) {
		case 'h':
		default:
			(*command->usage)(NULL);
		}
	}
	argc -= optind;
	argv += optind;

	if (argc != 1)
		(*command->usage)(NULL);

	id = atoi(argv[0]);
	fd = open(NETCONSOLE_DEV_NAME, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "can't open device " NETCONSOLE_DEV_NAME "\n");
		return -1;
	}
	if(ioctl(fd, NETCON_REMOVE_TARGET, &id) != 0)
		perror("remove");
	close(fd);

	return 0;
}

static void usage_remove(char *msg)
{
	fprintf(stderr, "Usage  : netconfig remove id\n");
	exit(-1);
}

static int handle_command_help(struct command *command, int argc, char** argv)
{
	(*command->usage)(NULL);

	return 0;
}

static void usage_help(char *msg)
{
	generic_usage(NULL);
}

static struct command s_commands[] = {
	{"add", "hp:s:", handle_command_add, usage_add},
	{"remove", "hp:", handle_command_remove, usage_remove},
	{"help", NULL, handle_command_help, usage_help},
};

int main(int argc, char* argv[])
{
	int i;
	struct command *command = NULL;

	for(i = 0; i < ARRAY_SIZE(s_commands); i++) {
		if (argc <= 1)
			break;
		if (strcmp(s_commands[i].name, argv[1]) == 0) {
			command = &s_commands[i];
			break;
		}
	}

	if (command == NULL)
		generic_usage(NULL);
	argc--;
	argv++;

	if (command->handle_command)
		(*command->handle_command)(command, argc, argv);
	else {
		fprintf(stderr, "function handle_command() isn't set.");
		exit(-1);
	}
	return 0;
}
Index: mm/fs/compat_ioctl.c
===================================================================
--- mm.orig/fs/compat_ioctl.c
+++ mm/fs/compat_ioctl.c
@@ -114,6 +114,8 @@
 #include <linux/dvb/video.h>
 #include <linux/lp.h>
 
+#include <linux/netconsole.h>
+
 static int do_ioctl32_pointer(unsigned int fd, unsigned int cmd,
 			      unsigned long arg, struct file *f)
 {
@@ -3489,6 +3491,12 @@ HANDLE_IOCTL(LPSETTIMEOUT, lp_timeout_tr
 
 IGNORE_IOCTL(VFAT_IOCTL_READDIR_BOTH32)
 IGNORE_IOCTL(VFAT_IOCTL_READDIR_SHORT32)
+
+#ifdef CONFIG_NETCONSOLE_DYNCON
+/* netconsole */
+COMPATIBLE_IOCTL(NETCON_ADD_TARGET)
+ULONG_IOCTL(NETCON_REMOVE_TARGET)
+#endif
 };
 
 #define IOCTL_HASHSIZE 256
Index: mm/include/linux/netconsole.h
===================================================================
--- /dev/null
+++ mm/include/linux/netconsole.h
@@ -0,0 +1,18 @@
+#ifndef __NETCONSOLE_H
+#define __NETCONSOLE_H
+
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+struct netconsole_request {
+	__u32 id;
+	__u8 netdev_name[IFNAMSIZ];
+	__u8 remote_mac[ETH_ALEN];
+	__u32 local_ip, remote_ip;
+	__u16 local_port, remote_port;
+};
+
+#define NETCON_ADD_TARGET _IOW(0xAE, 4, struct netconsole_request)
+#define NETCON_REMOVE_TARGET _IOW(0xAE, 5, int)
+
+#endif /* __NETCONSOLE_H */
Index: mm/drivers/net/netconsole.c
===================================================================
--- mm.orig/drivers/net/netconsole.c
+++ mm/drivers/net/netconsole.c
@@ -47,6 +47,7 @@
 #include <linux/netpoll.h>
 #include <linux/miscdevice.h>
 #include <linux/inet.h>
+#include <linux/netconsole.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -75,6 +76,8 @@ struct netconsole_target {
 	struct netpoll np;
 };
 
+static struct tty_driver *netconsole_tty_driver;
+
 static LIST_HEAD(target_list);
 static DEFINE_SPINLOCK(target_list_lock);
 static DECLARE_MUTEX(netdev_change_sem);
@@ -442,6 +445,73 @@ static int netconsole_event(struct notif
 static struct notifier_block netconsole_notifier = {
 	.notifier_call = netconsole_event,
 };
+
+static int netconsole_open(struct tty_struct *tty, struct file *file)
+{
+	return 0;
+}
+
+static int netconsole_ioctl(struct tty_struct *tty, struct file *file,
+			    unsigned int cmd, unsigned long arg)
+{
+	int id, count;
+	char config[256];
+	char *cur;
+	struct netconsole_request req;
+	struct netconsole_target *nt, *tmp;
+	void __user *argp = (void __user *)arg;
+
+	switch (cmd) {
+	case NETCON_ADD_TARGET:
+		printk(KERN_INFO "netconsole: cmd=NETCON_ADD_TARGET\n");
+		if (copy_from_user(&req, argp, sizeof(req)))
+			return -EFAULT;
+		cur = config;
+		count = sprintf(cur, "%d@", req.local_port);
+		cur += count;
+		if (req.local_ip)
+			count = sprintf(cur, "%d.%d.%d.%d/",
+					NIPQUAD(req.local_ip));
+		else
+			count = sprintf(cur, "/");
+		cur += count;
+		count = sprintf(cur, "%s,", req.netdev_name);
+		cur += count;
+		count = sprintf(cur, "%d@", req.remote_port);
+		cur += count;
+		count = sprintf(cur, "%d.%d.%d.%d/",
+				NIPQUAD(req.remote_ip));
+		cur += count;
+		count = sprintf(cur, "%02x:%02x:%02x:%02x:%02x:%02x",
+				req.remote_mac[0], req.remote_mac[1],
+				req.remote_mac[2], req.remote_mac[3],
+				req.remote_mac[4], req.remote_mac[5]);
+		printk(KERN_INFO "count = %d config=[%s]\n", count, config);
+		if (add_target(config))
+			return -EINVAL;
+		break;
+	case NETCON_REMOVE_TARGET:
+		printk(KERN_INFO "netconsole: cmd=NETCON_REMOVE_TARGET\n");
+		if (copy_from_user(&id, argp, sizeof(int)))
+			return -EFAULT;
+		printk(KERN_INFO "netconsole: id=%d\n", id);
+		list_for_each_entry_safe(nt, tmp, &target_list, list)
+			if (nt->id == id) {
+				kobject_unregister(&nt->obj);
+				break;
+			}
+		break;
+	default:
+		return -ENOTTY;
+	}
+
+	return 0;
+}
+
+static struct tty_operations netconsole_ops = {
+	.open = netconsole_open,
+	.ioctl = netconsole_ioctl,
+};
 #endif /* CONFIG_NETCONSOLE_DYNCON */
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
@@ -510,6 +580,8 @@ static void cleanup_netconsole(void)
 	unregister_netdevice_notifier(&netconsole_notifier);
 	if (miscdev_configured)
 		misc_deregister(&netconsole_miscdev);
+	tty_unregister_driver(netconsole_tty_driver);
+	put_tty_driver(netconsole_tty_driver);
 #else
 	unregister_console(&netconsole);
 	netpoll_cleanup(&np);
@@ -521,6 +593,7 @@ static int __init init_netconsole(void)
 	char *tmp = config;
 #ifdef CONFIG_NETCONSOLE_DYNCON
 	char *p;
+	int result;
 
 	if (misc_register(&netconsole_miscdev)) {
 		printk(KERN_ERR
@@ -531,6 +604,27 @@ static int __init init_netconsole(void)
 	} else
 		miscdev_configured = 1;
 
+	netconsole_tty_driver = alloc_tty_driver(1);
+	if (!netconsole_tty_driver)
+		return -ENOMEM;
+	netconsole_tty_driver->owner = THIS_MODULE;
+	netconsole_tty_driver->name = "netcon";
+	netconsole_tty_driver->driver_name = "netconsole";
+	netconsole_tty_driver->major = 0;
+	netconsole_tty_driver->minor_start = 0;
+	netconsole_tty_driver->num = 1;
+	netconsole_tty_driver->type = TTY_DRIVER_TYPE_CONSOLE;
+	tty_set_operations(netconsole_tty_driver, &netconsole_ops);
+
+	if ((result = tty_register_driver(netconsole_tty_driver))) {
+		printk(KERN_ERR "failed to register netconsole tty driver"
+		       " errno=%d\n", result);
+		put_tty_driver(netconsole_tty_driver);
+		if (miscdev_configured)
+			misc_deregister(&netconsole_miscdev);
+		return result;
+	}
+
 	register_netdevice_notifier(&netconsole_notifier);
 	register_console(&netconsole);
 	if (!strlen(config)) {

-- 
