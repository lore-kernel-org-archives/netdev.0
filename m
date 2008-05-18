From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH updated] net: add ability to clear per-interface network
 statistics via procfs
Date: Sun, 18 May 2008 00:09:29 -0500
Message-ID: <482FBA09.80201@sngx.net>
References: <482DA5B6.1020606@sngx.net> <482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net> <482F5113.5090703@cosmosbay.com> <482F610D.2080108@sngx.net> <20080518003104.GK28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl093-193-175.stl1.dsl.speakeasy.net ([66.93.193.175]:58561
	"EHLO hades.sngx.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751863AbYERFIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 01:08:45 -0400
In-Reply-To: <20080518003104.GK28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You need to stop your mail client word-wrapping patches.  It looks like
> something has converted tabs to spaces, too.

Hmm, I don't know what might be causing that.  I'm using Thunderbird and disabled 
wrapping, and things look ok on lkml when I view the archives there. The tab/spaces 
issue was a result of me copying it out of a terminal window, and the patch now 
clears checkpatch.pl.

As for the rest, I've done as you suggested, my only comment about it is that 
like I said, my code is based heavily on that found in drivers/scsi/scsi_proc.c, so
it may be worth it to do the same changes there.

---

--- linux-2.6.25.4/net/core/dev.c	2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/net/core/dev.c	2008-05-17 20:53:13.000000000 -0500
@@ -2453,6 +2453,75 @@ static struct netif_rx_stats *softnet_ge
 	return rc;
 }
 
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
+				  size_t length, loff_t *ppos)
+{
+	char *buffer, *p;
+	char devname[IFNAMSIZ];
+	static const char command[] = "net clear-stats ";
+	struct net *net;
+	struct net_device *dev;
+	int err;
+
+	if (!buf || length > PAGE_SIZE)
+		return -EINVAL;
+
+	buffer = (char *)__get_free_page(GFP_KERNEL);
+	if (!buffer)
+		return -ENOMEM;
+
+	err = -EFAULT;
+	if (copy_from_user(buffer, buf, length))
+		goto out;
+
+	err = -EINVAL;
+	if (length < PAGE_SIZE)
+		buffer[length] = '\0';
+	else if (buffer[PAGE_SIZE-1])
+		goto out;
+
+	err = -ENXIO;
+	net = get_proc_net(file->f_dentry->d_inode);
+	if (!net)
+		goto out;
+
+	if (!strncmp(command, buffer, sizeof(command) - 1)) {
+		p = buffer + strlen(command);
+		if (sscanf(p, "%16s", devname) > 0) {
+			dev = dev_get_by_name(net, devname);
+			if (dev) {
+				if (dev->get_stats) {
+					struct net_device_stats *stats =
+					       dev->get_stats(dev);
+					memset(stats, 0,
+					       sizeof(struct net_device_stats));
+				}
+				dev_put(dev);
+				err = length;
+			}
+		}
+	}
+
+	put_net(net);
+
+ out:
+	free_page((unsigned long)buffer);
+	return err;
+}
+
 static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	return softnet_get_online(pos);
@@ -2496,6 +2565,7 @@ static const struct file_operations dev_
 	.owner	 = THIS_MODULE,
 	.open    = dev_seq_open,
 	.read    = seq_read,
+	.write   = proc_net_dev_write,
 	.llseek  = seq_lseek,
 	.release = seq_release_net,
 };
