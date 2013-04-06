From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 40/51] netfilter: ebt_log: add net namespace support for ebt_log
Date: Sat,  6 Apr 2013 14:17:39 +0200
Message-ID: <1365250670-14993-41-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Add pernet support to ebt_log by means of the new nf_log_set
function added in (30e0c6a netfilter: nf_log: prepare net
namespace support for loggers).

Since syslog ns has yet not been implemented, we don't want
the containers to DDOS host's syslogd. So only enable ebt_log
only from init_net and wait for syslog ns support.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_log.c |   37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 08e5ea5..9878eb8 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -78,6 +78,11 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
    const char *prefix)
 {
 	unsigned int bitmask;
+	struct net *net = dev_net(in ? in : out);
+
+	/* FIXME: Disabled from containers until syslog ns is supported */
+	if (!net_eq(net, &init_net))
+		return;
 
 	spin_lock_bh(&ebt_log_lock);
 	printk(KERN_SOH "%c%s IN=%s OUT=%s MAC source = %pM MAC dest = %pM proto = 0x%04x",
@@ -207,19 +212,47 @@ static struct nf_logger ebt_log_logger __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
+static int __net_init ebt_log_net_init(struct net *net)
+{
+	nf_log_set(net, NFPROTO_BRIDGE, &ebt_log_logger);
+	return 0;
+}
+
+static void __net_exit ebt_log_net_fini(struct net *net)
+{
+	nf_log_unset(net, &ebt_log_logger);
+}
+
+static struct pernet_operations ebt_log_net_ops = {
+	.init = ebt_log_net_init,
+	.exit = ebt_log_net_fini,
+};
+
 static int __init ebt_log_init(void)
 {
 	int ret;
 
+	ret = register_pernet_subsys(&ebt_log_net_ops);
+	if (ret < 0)
+		goto err_pernet;
+
 	ret = xt_register_target(&ebt_log_tg_reg);
 	if (ret < 0)
-		return ret;
+		goto err_target;
+
 	nf_log_register(NFPROTO_BRIDGE, &ebt_log_logger);
-	return 0;
+
+	return ret;
+
+err_target:
+	unregister_pernet_subsys(&ebt_log_net_ops);
+err_pernet:
+	return ret;
 }
 
 static void __exit ebt_log_fini(void)
 {
+	unregister_pernet_subsys(&ebt_log_net_ops);
 	nf_log_unregister(&ebt_log_logger);
 	xt_unregister_target(&ebt_log_tg_reg);
 }
-- 
1.7.10.4

