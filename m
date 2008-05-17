From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH updated] net: add ability to clear per-interface network
 statistics via procfs
Date: Sat, 17 May 2008 17:49:49 -0500
Message-ID: <482F610D.2080108@sngx.net>
References: <482DA5B6.1020606@sngx.net> <482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net> <482F5113.5090703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl093-193-175.stl1.dsl.speakeasy.net ([66.93.193.175]:58344
	"EHLO hades.sngx.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751067AbYEQWtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 18:49:08 -0400
In-Reply-To: <482F5113.5090703@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This version has a bug, please check again.

Gah, you're right, fixed below.

---

--- linux-2.6.25.4/net/core/dev.c       2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/net/core/dev.c      2008-05-17 17:45:57.000000000 -0500
@@ -2455,2 +2455,80 @@

+/**
+ * proc_net_dev_write - handle writes to /proc/net/dev
+ * @file: not used
+ * @buf: buffer to write
+ * @length: length of buf, at most PAGE_SIZE
+ * @ppos: not used
+ *
+ * Description: this provides a mechanism to clear statistics on a
+ * per-interface basis
+ * "echo 'net clear-stats ifdev' >/proc/net/dev"
+ * with  "ifdev" replaced by the device name you wish to clear.
+ *
+ */
+static ssize_t proc_net_dev_write(struct file *file, const char __user *buf,
+                                  size_t length, loff_t *ppos)
+{
+        char *buffer, *p;
+        char devname[IFNAMSIZ];
+        struct net *net;
+        struct net_device *dev;
+        int err;
+
+        if (!buf || length > PAGE_SIZE)
+                return -EINVAL;
+
+        buffer = (char *)__get_free_page(GFP_KERNEL);
+        if (!buffer)
+                return -ENOMEM;
+
+        err = -EFAULT;
+        if (copy_from_user(buffer, buf, length))
+                goto out;
+
+        err = -EINVAL;
+        if (length < PAGE_SIZE)
+                buffer[length] = '\0';
+        else if (buffer[PAGE_SIZE-1])
+                goto out;
+
+        err = -ENXIO;
+        net = get_proc_net(file->f_dentry->d_inode);
+        if (!net)
+                goto out;
+
+        /*
+         * Usage: echo "net clear-stats ifdev" >/proc/net/dev
+         * with  "ifdev" replaced by the device name you wish to clear.
+         */
+        if (!strncmp("net clear-stats",buffer,15)) {
+                p = buffer + 16;
+                if(sscanf(p,"%16s",devname)>0) {
+                        dev = dev_get_by_name(net,devname);
+                        if (dev) {
+                                if (dev->get_stats) {
+                                        struct net_device_stats *stats =
+                                               dev->get_stats(dev);
+                                        memset(stats,0,
+                                               sizeof(struct net_device_stats));
+                                }
+                                dev_put(dev);
+                        }
+                }
+        }
+
+        /*
+         * convert success returns so that we return the
+         * number of bytes consumed.
+         */
+        if (!err)
+                err = length;
+
+        put_net(net);
+
+ out:
+        free_page((unsigned long)buffer);
+        return err;
+}
+
 static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
@@ -2498,2 +2576,3 @@
        .read    = seq_read,
+        .write   = proc_net_dev_write,
        .llseek  = seq_lseek,
