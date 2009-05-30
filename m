From: John Mehaffey <mehaf@gedanken.com>
Subject: [PATCH] networking: Add write/clear capability to /proc/net/dev
Date: Fri, 29 May 2009 17:26:58 -0700
Message-ID: <4A207D52.9000407@gedanken.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:13072 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbZE3A04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 20:26:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently no way to reset networking statistics other than to
rmmod the interface and reinstall it.

This patch adds the capability to clear and/or set network statistics
counters using the /proc/net/dev file.

Please see the Documentation/networking/proc_net_dev file for full
details of the API.

Signed-off-by: John Mehaffey <mehaf_lkml@gedanken.com>
---

diff -purN orig new
--- orig/Documentation/networking/proc_net_dev.txt    Wed Dec 31 
16:00:00 1969
+++ new/Documentation/networking/proc_net_dev.txt    Fri May 29 15:59:32 
2009
@@ -0,0 +1,32 @@
+This document describes the interface provided by /proc/net/dev
+
+The proc/net/dev interface provides statistics about currently
+active network devices, both actual hardware and virtual devices.
+
+Reading /proc/net/dev provides both raw statistics and summaries
+from the struct net_dev_stats structure. If a device does not
+support statistics, an error message will print for that device.
+
+Writing /proc/net/dev can clear or set statistics for devices.
+
+There are 4 modes available for writing to /proc/net/dev.
+
+1.  echo "clearall" > /proc/net/dev
+    This will clear (0 out) all statistics for all devices.
+2.  echo "eth1 clear" > /proc/net/dev
+    Clears all stats for a single network device (eth1 in this case).
+3.  echo "eth1 0 0 0 0" > /proc/net/dev
+    Clears rx and tx bytes and packets counters. The order of counters
+    cleared is that in struct net_device_stats. Counters not included
+    in the parameter list are not altered.
+4.  echo "eth1 ,,,,0xFFFF 0xFFFF" > /proc/net/dev : sets rx and tx errors,
+    leaving byte and packet counters unchanged.  Perhaps useful for testing
+    network health monitoring software. Each comma skips an element, so if
+    you want to set consecutive elements, DO NOT use a comma separated 
list!
+
+    Whitespace is ignored, except as a separator. There is a limit of 256
+    bytes for the command.  You can use mode 4 to break setting of stats
+    into smaller chunks, if necessary.
+
+NOTE: the order of parameters is that of struct net_device_stats,
+    NOT that of the statistics returned by reading /proc/net/dev!!!
--- orig/net/core/dev.c    Fri May 29 15:13:15 2009
+++ new/net/core/dev.c    Fri May 29 14:44:18 2009
@@ -2929,6 +2929,142 @@ static void dev_seq_printf_stats(struct
            stats->tx_compressed);
 }
 
+#define USR_BUF_SIZE 256
+
+static void get_usr_buf(char *buffer, const char __user *input, size_t 
size)
+{
+    if (size < USR_BUF_SIZE) {
+        copy_from_user(buffer, input, size - 1);
+        buffer[size - 1]='\0';
+    } else {
+        printk(KERN_WARNING "Dev: Ignoring characters past size %d\n",
+                            USR_BUF_SIZE - 1);
+        copy_from_user(buffer, input, USR_BUF_SIZE - 1);
+        buffer[USR_BUF_SIZE - 1] = '\0';
+    }
+}
+
+static inline void clear_stats(struct net_device_stats *stats)
+{
+    if (stats)
+        memset(stats, 0, sizeof(struct net_device_stats));
+}
+
+static inline char *skip_whitespace(char *start)
+{
+    while (isspace(*start))
+        ++start;
+    return start;
+}
+
+static int get_net_dev(char **scan_start, struct net_device **net_dev)
+{
+    char tmp;
+    char *scan_end = *scan_start;
+
+    while ((*scan_end) && !(*scan_end == ',') && !isspace(*scan_end))
+        ++scan_end;
+
+    tmp = *scan_end;
+    if (!tmp) {
+        printk(KERN_ERR "Dev: Invalid parameter(s)\n");
+        return -EINVAL;
+    }
+
+    *scan_end = '\0';
+    *net_dev = dev_get_by_name(*scan_start);
+    if (!*net_dev) {
+        printk(KERN_ERR "Dev: network device not found: \"%s\"\n",
+                                *scan_start);
+        return -ENOENT;
+    }
+
+    *scan_end = tmp;
+    *scan_start = skip_whitespace(scan_end);
+
+    return 0;
+}
+
+static int set_stats(struct net_device *net_dev, char *scan_start)
+{
+    char * scan_end;
+    unsigned long *stat_ptr = (unsigned long *)net_dev->get_stats(net_dev);
+
+    while (*scan_start) {
+        if (isdigit(*scan_start))
+            *stat_ptr = simple_strtoul(scan_start, &scan_end, 0);
+        else if (*scan_start == ',')
+            scan_end = scan_start + 1;
+        else {
+            printk(KERN_ERR "Dev: Invalid scan character:\"%c\"\n",
+                                *scan_start);
+            return -EINVAL;
+        }
+
+        scan_start = skip_whitespace(scan_end);
+        ++stat_ptr;
+    }
+
+    return 0;
+}
+
+/*
+ * dev_stats_write - clear or set stats for network devices
+ * syntax:
+ * echo "clearall" > /proc/net/dev : clears all stats for all (current)
+ *    network devices.
+ * echo "eth1 clear" > /proc/net/dev : clears all stats for a single 
network
+ *      device (eth1 in this case).
+ * echo "eth1 0 0 0 0" > /proc/net/dev : clears rx and tx bytes and packets
+ *      counters.
+ * echo "eth1 ,,,,0xFFFF 0xFFFF" > /proc/net/dev : sets rx and tx errors,
+ *      leaving byte and packet counters unchanged.  Perhaps useful for 
testing
+ *      network health monitoring software. Each comma skips an 
element, so if
+ *      you want to set consecutive elements, DO NOT use a comma 
separated list!
+ *      Whitespace is ignored, except as a separator.
+ * NOTE: the order of parameters is that of struct net_device_stats,
+ *      NOT that of the statistics returned by reading /proc/net/dev!!!
+ */
+
+static ssize_t dev_stats_write(struct file *file, const char __user *input,
+                size_t size, loff_t *ofs)
+{
+    char usr_buf[USR_BUF_SIZE];
+    char *scan_start;
+    int retval;
+    struct net_device *net_dev = dev_base;
+
+    if (!capable(CAP_NET_ADMIN))
+                return -EPERM;
+    if (size < 2)
+        return -EINVAL;
+
+    get_usr_buf(usr_buf, input, size);
+
+    scan_start = strstrip(usr_buf);
+
+    if (!strcmp(scan_start, "clearall")) {
+        while (net_dev) {
+            clear_stats(net_dev->get_stats(net_dev));
+            net_dev = net_dev->next;
+        }
+        return size;
+    }
+
+    if ((retval = get_net_dev(&scan_start, &net_dev)))
+        return retval;
+
+    if (!strcmp(scan_start, "clear")) {
+        clear_stats(net_dev->get_stats(net_dev));
+        return size;
+    }
+
+    if ((retval = set_stats(net_dev, scan_start)))
+        return retval;
+    else
+        return size;
+}
+
 /*
  *    Called from the PROCfs module. This now uses the new arbitrary sized
  *    /proc/net interface to create /proc/net/dev
@@ -3002,6 +3138,7 @@ static const struct file_operations dev_
     .owner     = THIS_MODULE,
     .open    = dev_seq_open,
     .read    = seq_read,
+    .write   = dev_stats_write,
     .llseek  = seq_lseek,
     .release = seq_release_net,
 };
@@ -3135,7 +3272,7 @@ static int __net_init dev_proc_net_init(
 {
     int rc = -ENOMEM;
 
-    if (!proc_net_fops_create(net, "dev", S_IRUGO, &dev_seq_fops))
+    if (!proc_net_fops_create(net, "dev", S_IRUGO | S_IWUSR, 
&dev_seq_fops))
         goto out;
     if (!proc_net_fops_create(net, "softnet_stat", S_IRUGO, 
&softnet_seq_fops))
         goto out_dev;

