From: "Huascar Tejeda" <htejeda@gmail.com>
Subject: Re: [PATCH] net: reset network device counters on the fly
Date: Tue, 6 Jan 2009 23:17:57 -0400
Message-ID: <3375b4020901061917h2d61e9bbpdcc608e1cd9cfd9a@mail.gmail.com>
References: <3375b4020901061808g527cb872ia64b47147783b91c@mail.gmail.com>
	 <49641399.80305@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:55901 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbZAGDR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 22:17:59 -0500
Received: by ewy10 with SMTP id 10so8799000ewy.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2009 19:17:57 -0800 (PST)
In-Reply-To: <49641399.80305@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot for your reply and sorry for sending the patch as an
attachment; Anyway, here is the patch in case someone finds it useful.

--- net/core/dev.c.orig	2009-01-05 17:38:51.000000000 -0400
+++ net/core/dev.c	2009-01-06 16:36:35.000000000 -0400
@@ -161,6 +161,11 @@
 #define PTYPE_HASH_SIZE	(16)
 #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)

+/*
+ * 	Maximum length of the command sent by the user
+ */
+#define RSTDEV_COMMAND_MAX_SIZE (15)
+
 static DEFINE_SPINLOCK(ptype_lock);
 static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 static struct list_head ptype_all __read_mostly;	/* Taps */
@@ -2671,10 +2676,78 @@
 			    sizeof(struct seq_net_private));
 }

+
+/*	
+ *	Called when /proc/net/dev is written
+ */
+static ssize_t reset_device_counters(struct file *file, const char
*buffer, size_t len, loff_t * off)
+{
+	struct net_device *dev;
+	struct net_device_stats *stats;
+	char cmd[RSTDEV_COMMAND_MAX_SIZE];
+	unsigned long cmd_size = 0;
+	char *cmd_ptr = cmd;
+	char **argv = (char **) kmalloc(sizeof(char *), GFP_KERNEL);
+	char *tmp_token, *action, *ifname;
+	int argc = 0;
+
+	cmd_size = ( len > RSTDEV_COMMAND_MAX_SIZE ) ? RSTDEV_COMMAND_MAX_SIZE : len;
+	if ( copy_from_user(cmd, buffer, cmd_size) ) {
+		return -EFAULT;
+	}
+
+	//Parse user input
+	while ( (tmp_token = strsep(&cmd_ptr, " \n")) ) {
+		if ( *tmp_token ) {
+			argv[argc] = (char *) kmalloc((strlen(tmp_token) + 1) *
sizeof(char), GFP_KERNEL);
+			strcpy(argv[argc++], tmp_token);
+		}
+	}
+
+	if ( !argv[0] || !argv[1] ) {
+		printk(KERN_INFO "Please usage: reset \"[network interface]\" or
\"reset all\"\n");
+		return -EINVAL;
+	}
+
+	//TODO: create a struct for this.
+	action = argv[0];
+	ifname = argv[1];
+	
+	kfree(argv);
+
+	if ( strstr(action, "reset") ) {
+		if ( !strcmp(ifname, "all") ) {
+			for_each_netdev(&init_net, dev) {
+				stats = dev->get_stats(dev);
+				if ( stats ) {
+					memset(stats, 0, sizeof(struct net_device_stats));
+				}
+			}
+		} else {
+			dev = dev_get_by_name(&init_net, ifname);
+			if ( dev ) {
+				stats = dev->get_stats(dev);
+				if ( stats ) {
+					memset(stats, 0, sizeof(struct net_device_stats));
+				}
+			} else {
+				printk(KERN_INFO "Device %s not found!\n", ifname);
+				return -ENODEV;
+			}
+		}
+	} else {
+		printk(KERN_INFO "\"reset\" is the only supported command!\n");
+		return -EINVAL;
+	}
+
+	return cmd_size;
+}
+
 static const struct file_operations dev_seq_fops = {
 	.owner	 = THIS_MODULE,
 	.open    = dev_seq_open,
 	.read    = seq_read,
+        .write   = reset_device_counters,
 	.llseek  = seq_lseek,
 	.release = seq_release_net,
 };

Huascar Tejeda

On Tue, Jan 6, 2009 at 10:29 PM, Rick Jones <rick.jones2@hp.com> wrote:
> Huascar Tejeda wrote:
>>
>> Hello everyone,
>>
>> This is my first post to the mailing list and also my first kernel patch.
>>
>> There was an scenario where I needed to clear network device counters
>> without shutting down the interface.
>> With this patch I add this functionality to /proc/net/dev.
>>
>> Usage example:
>> echo clear eth0 > /proc/net/dev
>> echo clear all > /proc/net/dev
>>
>> Thanks for your comments and please feel free to reply with any
>> suggestions you may have.
>
> Having been at least once bitten as a patch submittor, I'll point-out that
> patches are generally requested to be inline, not attachments. Also, in any
> kernel tree there should be a file describing how a patch should be put
> together and what addtional bits of information need to be included.  That
> file is ./Documentation/SubmittingPatches.
>
> Finally, my recollection is this same sort of thing (zeroing counters) has
> been proposed before, and shot-down.  Doesn't a priori mean it will be
> shot-down this time, but it suggests the chances are slim.  You can probably
> find the discussion in one or more of the various archives for the netdev
> list.  For those situations where you want to know the statistics for a
> given interval, you can snap the stats to files at either end of the
> interval and run them through "beforeafter" or something similar:
>
> http://ftp.cup.hp.com/dist/networking/tools/
>
> rick jones
> wondering what has become of his ethtool patch to recognize speeds other
> than 10/100/1000/10000... perhaps it too tripped over some of the above :(
>
