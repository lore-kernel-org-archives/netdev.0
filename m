From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [IPV4] convert proc/net/pnp to seq_file.
Date: Sat, 13 Sep 2003 14:20:07 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913.142007.113839771.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert /proc/net/pnp to seq_file.

===== net/ipv4/ipconfig.c 1.29 vs edited =====
--- 1.29/net/ipv4/ipconfig.c	Fri Aug 15 16:41:43 2003
+++ edited/net/ipv4/ipconfig.c	Sat Sep 13 13:47:03 2003
@@ -50,6 +50,7 @@
 #include <linux/route.h>
 #include <linux/udp.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/major.h>
 #include <linux/root_dev.h>
 #include <net/arp.h>
@@ -1092,43 +1093,45 @@
 
 #ifdef CONFIG_PROC_FS
 
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
-			       "domain %s\n", ic_domain);
+		seq_printf(seq,
+			   "domain %s\n", ic_domain);
 	for (i = 0; i < CONF_NAMESERVERS_MAX; i++) {
 		if (ic_nameservers[i] != INADDR_NONE)
-			len += sprintf(buffer + len,
-				       "nameserver %u.%u.%u.%u\n",
-				       NIPQUAD(ic_nameservers[i]));
+			seq_printf(seq,
+				   "nameserver %u.%u.%u.%u\n",
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
+		seq_printf(seq,
+			   "bootserver %u.%u.%u.%u\n",
+			   NIPQUAD(ic_servaddr));
+	return 0;
 }
 
+static int pnp_seq_open(struct inode *indoe, struct file *file)
+{
+	return single_open(file, pnp_seq_show, NULL);
+}
+
+static struct file_operations pnp_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= pnp_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
 #endif /* CONFIG_PROC_FS */
 
 /*
@@ -1140,7 +1143,7 @@
 	unsigned long jiff;
 
 #ifdef CONFIG_PROC_FS
-	proc_net_create("pnp", 0, pnp_get_info);
+	proc_net_fops_create("pnp", S_IRUGO, &pnp_seq_fops);
 #endif /* CONFIG_PROC_FS */
 
 	if (!ic_enable)


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
