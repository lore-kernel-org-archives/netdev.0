From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] /proc/net/ipconfig seq_file.
Date: Thu, 11 Sep 2003 15:52:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911155220.67265917.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert /proc/net/ipconfig to seq_file.

diff -Nru a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
--- a/net/ipv4/ipconfig.c	Thu Sep 11 15:50:41 2003
+++ b/net/ipv4/ipconfig.c	Thu Sep 11 15:50:41 2003
@@ -50,6 +50,7 @@
 #include <linux/route.h>
 #include <linux/udp.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/major.h>
 #include <linux/root_dev.h>
 #include <net/arp.h>
@@ -1091,44 +1092,45 @@
 #endif /* IPCONFIG_DYNAMIC */
 
 #ifdef CONFIG_PROC_FS
-
-static int pnp_get_info(char *buffer, char **start,
-			off_t offset, int length)
+static int pnp_seq_show(struct seq_file *seq, void *v)
 {
-	int len;
-       int i;
+	int i;
 
 	if (ic_proto_used & IC_PROTO)
-	    sprintf(buffer, "#PROTO: %s\n",
-		    (ic_proto_used & IC_RARP) ? "RARP"
-		    : (ic_proto_used & IC_USE_DHCP) ? "DHCP" : "BOOTP");
+		seq_printf(seq, "#PROTO: %s\n",
+			   (ic_proto_used & IC_RARP) ? "RARP"
+			   : (ic_proto_used & IC_USE_DHCP) ? "DHCP" : "BOOTP");
 	else
-	    strcpy(buffer, "#MANUAL\n");
-	len = strlen(buffer);
+		seq_puts(seq, "#MANUAL\n");
 
 	if (ic_domain[0])
-		len += sprintf(buffer + len,
+		seq_printf(seq, 
 			       "domain %s\n", ic_domain);
 	for (i = 0; i < CONF_NAMESERVERS_MAX; i++) {
 		if (ic_nameservers[i] != INADDR_NONE)
-			len += sprintf(buffer + len,
-				       "nameserver %u.%u.%u.%u\n",
-				       NIPQUAD(ic_nameservers[i]));
+			seq_printf(seq, "nameserver %u.%u.%u.%u\n",
+				   NIPQUAD(ic_nameservers[i]));
 	}
 	if (ic_servaddr != INADDR_NONE)
-		len += sprintf(buffer + len,
-			       "bootserver %u.%u.%u.%u\n",
-			       NIPQUAD(ic_servaddr));
-
-	if (offset > len)
-		offset = len;
-	*start = buffer + offset;
-
-	if (offset + length > len)
-		length = len - offset;
-	return length;
+		seq_printf(seq, "bootserver %u.%u.%u.%u\n",
+			   NIPQUAD(ic_servaddr));
+
+	return 0;
 }
 
+static int pnp_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, pnp_seq_show, NULL);
+}
+
+static struct file_operations pnp_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = pnp_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release,
+};
+
 #endif /* CONFIG_PROC_FS */
 
 /*
@@ -1140,7 +1142,7 @@
 	unsigned long jiff;
 
 #ifdef CONFIG_PROC_FS
-	proc_net_create("pnp", 0, pnp_get_info);
+	proc_net_fops_create("pnp", S_IRUGO, &pnp_seq_fops);
 #endif /* CONFIG_PROC_FS */
 
 	if (!ic_enable)
