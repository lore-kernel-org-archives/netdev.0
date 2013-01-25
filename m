From: pablo@netfilter.org
Subject: [PATCH 21/21] netfilter: nf_conntrack: fix compilation if sysctl are disabled
Date: Fri, 25 Jan 2013 14:54:53 +0100
Message-ID: <1359122093-3404-22-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60353 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757372Ab3AYNzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 08:55:23 -0500
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

In (f94161c netfilter: nf_conntrack: move initialization out of pernet
operations), some ifdefs were missing for sysctl dependent code.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_standalone.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 725bf04..7936bf7 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -563,10 +563,14 @@ static int __init nf_conntrack_standalone_init(void)
 	if (ret < 0)
 		goto out_start;
 
+#ifdef CONFIG_SYSCTL
 	nf_ct_netfilter_header =
 		register_net_sysctl(&init_net, "net", nf_ct_netfilter_table);
-	if (!nf_ct_netfilter_header)
+	if (!nf_ct_netfilter_header) {
+		pr_err("nf_conntrack: can't register to sysctl.\n");
 		goto out_sysctl;
+	}
+#endif
 
 	ret = register_pernet_subsys(&nf_conntrack_net_ops);
 	if (ret < 0)
@@ -576,9 +580,10 @@ static int __init nf_conntrack_standalone_init(void)
 	return 0;
 
 out_pernet:
+#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(nf_ct_netfilter_header);
 out_sysctl:
-	pr_err("nf_conntrack: can't register to sysctl.\n");
+#endif
 	nf_conntrack_cleanup_end();
 out_start:
 	return ret;
@@ -588,7 +593,9 @@ static void __exit nf_conntrack_standalone_fini(void)
 {
 	nf_conntrack_cleanup_start();
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
+#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(nf_ct_netfilter_header);
+#endif
 	nf_conntrack_cleanup_end();
 }
 
-- 
1.7.10.4
