From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next 4/9] ipv6: separate seq_ops for global & per/device
	ipv6 statistics
Date: Thu,  2 Oct 2008 14:14:07 +0400
Message-ID: <1222942452-9820-4-git-send-email-den@openvz.org>
References: <1222942394.6327.5.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1222942394.6327.5.camel-aPCOdVxUTlgvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

idev has been stored on seq->private. NULL has been stored for global
statistics.

The situation is changed with net namespace. We need to store pointer to
struct net and the only place is seq->private. So, we'll have for
/proc/net/dev_snmp6/* and for /proc/net/snmp6 pointers of two different
types stored in the same field.

This effectively requires to separate seq_ops of these files.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv6/proc.c |   48 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 25eda8b..7601f56 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -175,26 +175,17 @@ snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp_mib *itemlist)
 
 static int snmp6_seq_show(struct seq_file *seq, void *v)
 {
-	struct inet6_dev *idev = (struct inet6_dev *)seq->private;
-
-	if (idev) {
-		seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
-		snmp6_seq_show_item(seq, (void **)idev->stats.ipv6, snmp6_ipstats_list);
-		snmp6_seq_show_item(seq, (void **)idev->stats.icmpv6, snmp6_icmp6_list);
-		snmp6_seq_show_icmpv6msg(seq, (void **)idev->stats.icmpv6msg);
-	} else {
-		snmp6_seq_show_item(seq, (void **)ipv6_statistics, snmp6_ipstats_list);
-		snmp6_seq_show_item(seq, (void **)icmpv6_statistics, snmp6_icmp6_list);
-		snmp6_seq_show_icmpv6msg(seq, (void **)icmpv6msg_statistics);
-		snmp6_seq_show_item(seq, (void **)udp_stats_in6, snmp6_udp6_list);
-		snmp6_seq_show_item(seq, (void **)udplite_stats_in6, snmp6_udplite6_list);
-	}
+	snmp6_seq_show_item(seq, (void **)ipv6_statistics, snmp6_ipstats_list);
+	snmp6_seq_show_item(seq, (void **)icmpv6_statistics, snmp6_icmp6_list);
+	snmp6_seq_show_icmpv6msg(seq, (void **)icmpv6msg_statistics);
+	snmp6_seq_show_item(seq, (void **)udp_stats_in6, snmp6_udp6_list);
+	snmp6_seq_show_item(seq, (void **)udplite_stats_in6, snmp6_udplite6_list);
 	return 0;
 }
 
 static int snmp6_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, snmp6_seq_show, PDE(inode)->data);
+	return single_open(file, snmp6_seq_show, NULL);
 }
 
 static const struct file_operations snmp6_seq_fops = {
@@ -205,6 +196,30 @@ static const struct file_operations snmp6_seq_fops = {
 	.release = single_release,
 };
 
+static int snmp6_dev_seq_show(struct seq_file *seq, void *v)
+{
+	struct inet6_dev *idev = (struct inet6_dev *)seq->private;
+
+	seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
+	snmp6_seq_show_item(seq, (void **)idev->stats.ipv6, snmp6_ipstats_list);
+	snmp6_seq_show_item(seq, (void **)idev->stats.icmpv6, snmp6_icmp6_list);
+	snmp6_seq_show_icmpv6msg(seq, (void **)idev->stats.icmpv6msg);
+	return 0;
+}
+
+static int snmp6_dev_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, snmp6_dev_seq_show, PDE(inode)->data);
+}
+
+static const struct file_operations snmp6_dev_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = snmp6_dev_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release,
+};
+
 int snmp6_register_dev(struct inet6_dev *idev)
 {
 	struct proc_dir_entry *p;
@@ -221,7 +236,8 @@ int snmp6_register_dev(struct inet6_dev *idev)
 		return -ENOENT;
 
 	p = proc_create_data(idev->dev->name, S_IRUGO,
-			     net->mib.proc_net_devsnmp6, &snmp6_seq_fops, idev);
+			     net->mib.proc_net_devsnmp6,
+			     &snmp6_dev_seq_fops, idev);
 	if (!p)
 		return -ENOMEM;
 
-- 
1.5.3.rc5
