From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next 1/9] netns: move /proc/net/dev_snmp6 to struct net
Date: Thu,  2 Oct 2008 14:14:04 +0400
Message-ID: <1222942452-9820-1-git-send-email-den@openvz.org>
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

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 include/net/netns/mib.h |    4 ++++
 net/ipv6/proc.c         |   20 +++++++++++---------
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 4491476..ffcef5d 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -11,6 +11,10 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics);
 	DEFINE_SNMP_STAT(struct icmp_mib, icmp_statistics);
 	DEFINE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct proc_dir_entry *proc_net_devsnmp6;
+#endif
 };
 
 #endif
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 0179b66..16ebf85 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -29,8 +29,6 @@
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
 
-static struct proc_dir_entry *proc_net_devsnmp6;
-
 static int sockstat6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
@@ -210,18 +208,20 @@ static const struct file_operations snmp6_seq_fops = {
 int snmp6_register_dev(struct inet6_dev *idev)
 {
 	struct proc_dir_entry *p;
+	struct net *net;
 
 	if (!idev || !idev->dev)
 		return -EINVAL;
 
-	if (!net_eq(dev_net(idev->dev), &init_net))
+	net = dev_net(idev->dev);
+	if (!net_eq(net, &init_net))
 		return 0;
 
-	if (!proc_net_devsnmp6)
+	if (!net->mib.proc_net_devsnmp6)
 		return -ENOENT;
 
 	p = proc_create_data(idev->dev->name, S_IRUGO,
-			     proc_net_devsnmp6, &snmp6_seq_fops, idev);
+			     net->mib.proc_net_devsnmp6, &snmp6_seq_fops, idev);
 	if (!p)
 		return -ENOMEM;
 
@@ -231,12 +231,13 @@ int snmp6_register_dev(struct inet6_dev *idev)
 
 int snmp6_unregister_dev(struct inet6_dev *idev)
 {
-	if (!proc_net_devsnmp6)
+	struct net *net = dev_net(idev->dev);
+	if (!net->mib.proc_net_devsnmp6)
 		return -ENOENT;
 	if (!idev || !idev->stats.proc_dir_entry)
 		return -EINVAL;
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
-			  proc_net_devsnmp6);
+			  net->mib.proc_net_devsnmp6);
 	idev->stats.proc_dir_entry = NULL;
 	return 0;
 }
@@ -269,8 +270,9 @@ int __init ipv6_misc_proc_init(void)
 	if (!proc_net_fops_create(&init_net, "snmp6", S_IRUGO, &snmp6_seq_fops))
 		goto proc_snmp6_fail;
 
-	proc_net_devsnmp6 = proc_mkdir("dev_snmp6", init_net.proc_net);
-	if (!proc_net_devsnmp6)
+	init_net.mib.proc_net_devsnmp6 =
+		proc_mkdir("dev_snmp6", init_net.proc_net);
+	if (!init_net.mib.proc_net_devsnmp6)
 		goto proc_dev_snmp6_fail;
 out:
 	return rc;
-- 
1.5.3.rc5
