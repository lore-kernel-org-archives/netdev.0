From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert packet scheduler API to single_open
Date: Fri, 5 Sep 2003 14:01:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905140104.6a9ed33a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert /proc/net/psched to use seq_file; almost trivial.

Patch against 2.6.0-test4 bk latest.

diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	Fri Sep  5 13:58:01 2003
+++ b/net/sched/sch_api.c	Fri Sep  5 13:58:01 2003
@@ -32,6 +32,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/kmod.h>
 
 #include <net/sock.h>
@@ -1059,27 +1060,27 @@
 int psched_tick_per_us = 1;
 
 #ifdef CONFIG_PROC_FS
-static int psched_read_proc(char *buffer, char **start, off_t offset,
-			     int length, int *eof, void *data)
+static int psched_show(struct seq_file *seq, void *v)
 {
-	int len;
-
-	len = sprintf(buffer, "%08x %08x %08x %08x\n",
+	seq_printf(seq, "%08x %08x %08x %08x\n",
 		      psched_tick_per_us, psched_us_per_tick,
 		      1000000, HZ);
 
-	len -= offset;
-
-	if (len > length)
-		len = length;
-	if(len < 0)
-		len = 0;
-
-	*start = buffer + offset;
-	*eof = 1;
+	return 0;
+}
 
-	return len;
+static int psched_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, psched_show, PDE(inode)->data);
 }
+
+static struct file_operations psched_fops = {
+	.owner = THIS_MODULE,
+	.open = psched_open,
+	.read  = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};	
 #endif
 
 #if PSCHED_CLOCK_SOURCE == PSCHED_GETTIMEOFDAY
@@ -1250,9 +1251,7 @@
 	tc_filter_init();
 #endif
 
-#ifdef CONFIG_PROC_FS
-	create_proc_read_entry("net/psched", 0, 0, psched_read_proc, NULL);
-#endif
+	proc_net_fops_create("psched", 0, &psched_fops);
 
 	return 0;
 }
