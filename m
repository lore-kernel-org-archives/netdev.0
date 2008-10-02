From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next 2/9] netns: register /proc/net/dev_snmp6/* in each ns
Date: Thu,  2 Oct 2008 14:14:05 +0400
Message-ID: <1222942452-9820-2-git-send-email-den@openvz.org>
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

Do the same for /proc/net/snmp6.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv6/proc.c |   40 ++++++++++++++++------------------------
 1 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 16ebf85..5764062 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -247,12 +247,27 @@ static int ipv6_proc_init_net(struct net *net)
 	if (!proc_net_fops_create(net, "sockstat6", S_IRUGO,
 			&sockstat6_seq_fops))
 		return -ENOMEM;
+
+	if (!proc_net_fops_create(net, "snmp6", S_IRUGO, &snmp6_seq_fops))
+		goto proc_snmp6_fail;
+
+	net->mib.proc_net_devsnmp6 = proc_mkdir("dev_snmp6", net->proc_net);
+	if (!net->mib.proc_net_devsnmp6)
+		goto proc_dev_snmp6_fail;
 	return 0;
+
+proc_snmp6_fail:
+	proc_net_remove(net, "sockstat6");
+proc_dev_snmp6_fail:
+	proc_net_remove(net, "dev_snmp6");
+	return -ENOMEM;
 }
 
 static void ipv6_proc_exit_net(struct net *net)
 {
 	proc_net_remove(net, "sockstat6");
+	proc_net_remove(net, "dev_snmp6");
+	proc_net_remove(net, "snmp6");
 }
 
 static struct pernet_operations ipv6_proc_ops = {
@@ -262,34 +277,11 @@ static struct pernet_operations ipv6_proc_ops = {
 
 int __init ipv6_misc_proc_init(void)
 {
-	int rc = 0;
-
-	if (register_pernet_subsys(&ipv6_proc_ops))
-		goto proc_net_fail;
-
-	if (!proc_net_fops_create(&init_net, "snmp6", S_IRUGO, &snmp6_seq_fops))
-		goto proc_snmp6_fail;
-
-	init_net.mib.proc_net_devsnmp6 =
-		proc_mkdir("dev_snmp6", init_net.proc_net);
-	if (!init_net.mib.proc_net_devsnmp6)
-		goto proc_dev_snmp6_fail;
-out:
-	return rc;
-
-proc_dev_snmp6_fail:
-	proc_net_remove(&init_net, "snmp6");
-proc_snmp6_fail:
-	unregister_pernet_subsys(&ipv6_proc_ops);
-proc_net_fail:
-	rc = -ENOMEM;
-	goto out;
+	return register_pernet_subsys(&ipv6_proc_ops);
 }
 
 void ipv6_misc_proc_exit(void)
 {
-	proc_net_remove(&init_net, "dev_snmp6");
-	proc_net_remove(&init_net, "snmp6");
 	unregister_pernet_subsys(&ipv6_proc_ops);
 }
 
-- 
1.5.3.rc5
