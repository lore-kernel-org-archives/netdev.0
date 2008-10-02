From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next 7/9] netns: add stab functions for per/namespace mibs
	allocation
Date: Thu,  2 Oct 2008 14:14:10 +0400
Message-ID: <1222942452-9820-7-git-send-email-den@openvz.org>
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

The content of init_ipv6_mibs/cleanup_ipv6_mibs will be moved to new
calls one by one next.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv6/af_inet6.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 95055f8..46d4e62 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -834,6 +834,15 @@ static void cleanup_ipv6_mibs(void)
 	snmp_mib_free((void **)udplite_stats_in6);
 }
 
+static int __net_init ipv6_init_mibs(struct net *net)
+{
+	return 0;
+}
+
+static void __net_exit ipv6_cleanup_mibs(struct net *net)
+{
+}
+
 static int inet6_net_init(struct net *net)
 {
 	int err = 0;
@@ -849,6 +858,9 @@ static int inet6_net_init(struct net *net)
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 
+	err = ipv6_init_mibs(net);
+	if (err)
+		return err;
 #ifdef CONFIG_PROC_FS
 	err = udp6_proc_init(net);
 	if (err)
@@ -859,7 +871,6 @@ static int inet6_net_init(struct net *net)
 	err = ac6_proc_init(net);
 	if (err)
 		goto proc_ac6_fail;
-out:
 #endif
 	return err;
 
@@ -868,7 +879,9 @@ proc_ac6_fail:
 	tcp6_proc_exit(net);
 proc_tcp6_fail:
 	udp6_proc_exit(net);
-	goto out;
+out:
+	ipv6_cleanup_mibs(net);
+	return err;
 #endif
 }
 
@@ -879,6 +892,7 @@ static void inet6_net_exit(struct net *net)
 	tcp6_proc_exit(net);
 	ac6_proc_exit(net);
 #endif
+	ipv6_cleanup_mibs(net);
 }
 
 static struct pernet_operations inet6_net_ops = {
-- 
1.5.3.rc5
