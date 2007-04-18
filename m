From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take4 6/6] add ioctls for adding/removing target
Date: Wed, 18 Apr 2007 21:14:55 +0900
Message-ID: <46260BBF.2070202@bx.jp.nec.com>
References: <462605DC.2080804@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:45895 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422957AbXDRMPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 08:15:06 -0400
In-Reply-To: <462605DC.2080804@bx.jp.nec.com>
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
 * Keiichi KII <k-keiichi@bx.jp.nec.com>
 * Copyright (C) 2007 by Keiichi KII
 * This software is under GPL version 2 of the license.
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
@@ -116,6 +116,8 @@
 #include <linux/dvb/video.h>
 #include <linux/lp.h>
 
+#include <linux/netconsole.h>
+
 static int do_ioctl32_pointer(unsigned int fd, unsigned int cmd,
 			      unsigned long arg, struct file *f)
 {
Index: mm/include/linux/compat_ioctl.h
===================================================================
--- mm.orig/include/linux/compat_ioctl.h
+++ mm/include/linux/compat_ioctl.h
@@ -828,3 +828,6 @@ COMPATIBLE_IOCTL(VIDEO_GET_NAVI)
 COMPATIBLE_IOCTL(VIDEO_SET_ATTRIBUTES)
 COMPATIBLE_IOCTL(VIDEO_GET_SIZE)
 COMPATIBLE_IOCTL(VIDEO_GET_FRAME_RATE)
+/* netconsole */
+COMPATIBLE_IOCTL(NETCON_ADD_TARGET)
+ULONG_IOCTL(NETCON_REMOVE_TARGET)
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
@@ -313,6 +314,64 @@ static void release_target(struct kobjec
 	remove_target(nt);
 }
 
+static int netconsole_ioctl(struct inode *inode, struct file *file,
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
+		list_for_each_entry_safe(nt, tmp, &target_list, list) {
+			if (nt->id == id) {
+				kobject_unregister(&nt->obj);
+				break;
+			}
+		}
+		break;
+	default:
+		return -ENOTTY;
+	}
+
+	return 0;
+}
+
 static struct sysfs_ops target_sysfs_ops = {
 	.show = show_target_attr,
 	.store = store_target_attr
@@ -324,9 +383,14 @@ static struct kobj_type target_ktype = {
 	.default_attrs = target_attrs,
 };
 
+static struct file_operations miscdev_fops = {
+	.ioctl = netconsole_ioctl,
+};
+
 static struct miscdevice netconsole_miscdev = {
 	.minor = MISC_DYNAMIC_MINOR,
 	.name = "netconsole",
+	.fops = &miscdev_fops,
 };
 
 static struct notifier_block netconsole_notifier = {

-- 


