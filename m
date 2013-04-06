From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 41/51] netfilter: xt_LOG: add net namespace support for xt_LOG
Date: Sat,  6 Apr 2013 14:17:40 +0200
Message-ID: <1365250670-14993-42-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39079 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163467Ab3DFMSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 08:18:52 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Add pernet support to xt_LOG by means of the new nf_log_set
function added in (30e0c6a netfilter: nf_log: prepare net
namespace support for loggers).

Since syslog ns has yet not been implemented, we don't want
the containers to DDOS host's syslogd. So only enable ebt_log
only from init_net and wait for syslog ns support

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LOG.c |   52 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 49 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index fa40096..fe573f6 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -474,7 +474,14 @@ ipt_log_packet(u_int8_t pf,
 	       const struct nf_loginfo *loginfo,
 	       const char *prefix)
 {
-	struct sbuff *m = sb_open();
+	struct sbuff *m;
+	struct net *net = dev_net(in ? in : out);
+
+	/* FIXME: Disabled from containers until syslog ns is supported */
+	if (!net_eq(net, &init_net))
+		return;
+
+	m = sb_open();
 
 	if (!loginfo)
 		loginfo = &default_loginfo;
@@ -798,7 +805,14 @@ ip6t_log_packet(u_int8_t pf,
 		const struct nf_loginfo *loginfo,
 		const char *prefix)
 {
-	struct sbuff *m = sb_open();
+	struct sbuff *m;
+	struct net *net = dev_net(in ? in : out);
+
+	/* FIXME: Disabled from containers until syslog ns is supported */
+	if (!net_eq(net, &init_net))
+		return;
+
+	m = sb_open();
 
 	if (!loginfo)
 		loginfo = &default_loginfo;
@@ -893,23 +907,55 @@ static struct nf_logger ip6t_log_logger __read_mostly = {
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
 
+	ret = register_pernet_subsys(&log_net_ops);
+	if (ret < 0)
+		goto err_pernet;
+
 	ret = xt_register_targets(log_tg_regs, ARRAY_SIZE(log_tg_regs));
 	if (ret < 0)
-		return ret;
+		goto err_target;
 
 	nf_log_register(NFPROTO_IPV4, &ipt_log_logger);
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	nf_log_register(NFPROTO_IPV6, &ip6t_log_logger);
 #endif
 	return 0;
+
+err_target:
+	unregister_pernet_subsys(&log_net_ops);
+err_pernet:
+	return ret;
 }
 
 static void __exit log_tg_exit(void)
 {
+	unregister_pernet_subsys(&log_net_ops);
 	nf_log_unregister(&ipt_log_logger);
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	nf_log_unregister(&ip6t_log_logger);
-- 
1.7.10.4
