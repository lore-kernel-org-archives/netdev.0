From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 04/10] netfilter: xt_LOG: add net namespace support for xt_LOG
Date: Thu, 7 Feb 2013 15:49:44 +0800
Message-ID: <1360223390-15589-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lve-ke3WRBg/xIg@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add pernet_operations for xt_LOG, in pernet_ops,
we call nf_log_set/unset to set/unset nf_loggers
of per net.

Because the syslog ns has not been implemented,
we don't want the container DOS the host's syslog.
so only enable ebt_log in init_net and wait for
syslog ns.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/netfilter/xt_LOG.c | 41 ++++++++++++++++++++++++++++++++++++++---
 1 file changed, 38 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index fa40096..f49cac4 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -474,7 +474,13 @@ ipt_log_packet(u_int8_t pf,
 	       const struct nf_loginfo *loginfo,
 	       const char *prefix)
 {
-	struct sbuff *m = sb_open();
+	struct sbuff *m;
+	struct net *net = dev_net((in != NULL) ? in : out);
+
+	if (!net_eq(net, &init_net))
+		return;
+
+	m = sb_open();
 
 	if (!loginfo)
 		loginfo = &default_loginfo;
@@ -798,7 +804,13 @@ ip6t_log_packet(u_int8_t pf,
 		const struct nf_loginfo *loginfo,
 		const char *prefix)
 {
-	struct sbuff *m = sb_open();
+	struct sbuff *m;
+	struct net *net = dev_net((in != NULL) ? in : out);
+
+	if (!net_eq(net, &init_net))
+		return;
+
+	m = sb_open();
 
 	if (!loginfo)
 		loginfo = &default_loginfo;
@@ -893,6 +905,28 @@ static struct nf_logger ip6t_log_logger __read_mostly = {
 };
 #endif
 
+static int __net_init log_net_init(struct net *net)
+{
+	nf_log_set(net, NFPROTO_IPV4, &ipt_log_logger);
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+	nf_log_set(net, NFPROTO_IPV6, &ip6t_log_logger);
+#endif
+	return 0;
+}
+
+static void __net_exit log_net_exit(struct net *net)
+{
+	nf_log_unset(net, &ipt_log_logger);
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+	nf_log_unset(net, &ip6t_log_logger);
+#endif
+}
+
+static struct pernet_operations log_net_ops = {
+	.init = log_net_init,
+	.exit = log_net_exit,
+};
+
 static int __init log_tg_init(void)
 {
 	int ret;
@@ -905,11 +939,12 @@ static int __init log_tg_init(void)
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	nf_log_register(NFPROTO_IPV6, &ip6t_log_logger);
 #endif
-	return 0;
+	return register_pernet_subsys(&log_net_ops);
 }
 
 static void __exit log_tg_exit(void)
 {
+	unregister_pernet_subsys(&log_net_ops);
 	nf_log_unregister(&ipt_log_logger);
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	nf_log_unregister(&ip6t_log_logger);
-- 
1.7.11.7
