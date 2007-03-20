From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take3 6/6][resend] add ioctls for adding/removing
 target
Date: Tue, 20 Mar 2007 21:34:09 +0900
Message-ID: <45FFD4C1.7000103@bx.jp.nec.com>
References: <45FFCF31.3040000@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:42507 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933112AbXCTMeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 08:34:23 -0400
In-Reply-To: <45FFCF31.3040000@bx.jp.nec.com>
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
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stropts.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <linux/if_ether.h>

#define NETCONSOLE_DEV_NAME "/dev/netconsole"

struct command {
        char *name;
        char *options;
        int (*handle_command)(struct command* command,
                              int argc, char* argv[]);
        void (*usage)(char *msg);

extern char *optarg;

static void generic_usage(char *msg) {
        fprintf(stderr, "Usage  : netconfig command [option] [args]\n");
        fprintf(stderr, "command: add remove help\n");
        exit(-1);
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
                if (i != ETH_ALEN)
                        (*command->usage)("Invalid MAC address!\n");
                memcpy(req.remote_mac, mac, ETH_ALEN);

        fd = open(NETCONSOLE_DEV_NAME, O_RDWR);
        if (fd < 0) {
                fprintf(stderr, "cannot open device" NETCONSOLE_DEV_NAME "\n");
                return -1;
        exit(-1);

static int handle_command_remove(struct command *command,
                                 int argc, char** argv)
{

        while ((ch = getopt(argc, argv, command->options)) != -1) {
                switch (ch) {
                case 'h':
                default:
                        (*command->usage)(NULL);
                }
        }
        argc -= optind;

        if (argc != 1)

        id = atoi(argv[0]);
        fd = open(NETCONSOLE_DEV_NAME, O_RDWR);
        if (fd < 0) {
                fprintf(stderr, "can't open device " NETCONSOLE_DEV_NAME "\n");
                return -1;
        }
        if(ioctl(fd, NETCON_REMOVE_TARGET, &id) != 0)
                perror("remove");

        return 0;

static void usage_remove(char *msg) {
        fprintf(stderr, "Usage  : netconfig remove id\n");
        exit(-1);

static int handle_command_help(struct command *command,
                               int argc, char** argv) {

        return 0;

static void usage_help(char *msg) {
        generic_usage(NULL);
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

Index: linux-mm/fs/compat_ioctl.c
===================================================================
--- linux-mm.orig/fs/compat_ioctl.c
+++ linux-mm/fs/compat_ioctl.c
@@ -117,6 +117,8 @@
 #include <linux/dvb/video.h>
 #include <linux/lp.h>
 
+#include <linux/netconsole.h>
+
 static int do_ioctl32_pointer(unsigned int fd, unsigned int cmd,
 			      unsigned long arg, struct file *f)
 {
Index: linux-mm/include/linux/compat_ioctl.h
===================================================================
--- linux-mm.orig/include/linux/compat_ioctl.h
+++ linux-mm/include/linux/compat_ioctl.h
@@ -828,3 +828,6 @@ COMPATIBLE_IOCTL(VIDEO_GET_NAVI)
 COMPATIBLE_IOCTL(VIDEO_SET_ATTRIBUTES)
 COMPATIBLE_IOCTL(VIDEO_GET_SIZE)
 COMPATIBLE_IOCTL(VIDEO_GET_FRAME_RATE)
+/* netconsole */
+COMPATIBLE_IOCTL(NETCON_ADD_TARGET)
+ULONG_IOCTL(NETCON_REMOVE_TARGET)
Index: linux-mm/include/linux/netconsole.h
===================================================================
--- /dev/null
+++ linux-mm/include/linux/netconsole.h
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
Index: linux-mm/drivers/net/netconsole.c
===================================================================
--- linux-mm.orig/drivers/net/netconsole.c
+++ linux-mm/drivers/net/netconsole.c
@@ -47,6 +47,7 @@
 #include <linux/netpoll.h>
 #include <linux/miscdevice.h>
 #include <linux/inet.h>
+#include <linux/netconsole.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -306,6 +307,64 @@ static void release_target(struct kobjec
 	delete_target(nt);
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
@@ -317,9 +376,14 @@ static struct kobj_type target_ktype = {
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
 
 static struct netpoll np = {

-- 


