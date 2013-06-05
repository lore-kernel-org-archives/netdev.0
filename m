From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: don't panic on error while walking through the init path
Date: Wed,  5 Jun 2013 22:40:25 +0200
Message-ID: <1370464832-4216-5-git-send-email-pablo@netfilter.org>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57451 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120Ab3FEUkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 16:40:52 -0400
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't panic if we hit an error while adding the nf_log or pernet
netfilter support, just bail out.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/netfilter.h |    2 +-
 net/netfilter/core.c      |   21 +++++++++++++++------
 net/netfilter/nf_log.c    |    5 +----
 net/socket.c              |    4 +++-
 4 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 0060fde..de70f7b 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -35,7 +35,7 @@ static inline void nf_inet_addr_mask(const union nf_inet_addr *a1,
 	result->all[3] = a1->all[3] & mask->all[3];
 }
 
-extern void netfilter_init(void);
+extern int netfilter_init(void);
 
 /* Largest hook number + 1 */
 #define NF_MAX_HOOKS 8
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 07c865a..300539d 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -302,17 +302,26 @@ static struct pernet_operations netfilter_net_ops = {
 	.exit = netfilter_net_exit,
 };
 
-void __init netfilter_init(void)
+int __init netfilter_init(void)
 {
-	int i, h;
+	int i, h, ret;
+
 	for (i = 0; i < ARRAY_SIZE(nf_hooks); i++) {
 		for (h = 0; h < NF_MAX_HOOKS; h++)
 			INIT_LIST_HEAD(&nf_hooks[i][h]);
 	}
 
-	if (register_pernet_subsys(&netfilter_net_ops) < 0)
-		panic("cannot create netfilter proc entry");
+	ret = register_pernet_subsys(&netfilter_net_ops);
+	if (ret < 0)
+		goto err;
+
+	ret = netfilter_log_init();
+	if (ret < 0)
+		goto err_pernet;
 
-	if (netfilter_log_init() < 0)
-		panic("cannot initialize nf_log");
+	return 0;
+err_pernet:
+	unregister_pernet_subsys(&netfilter_net_ops);
+err:
+	return ret;
 }
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 388656d..bd5474a 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -368,10 +368,7 @@ static int __net_init nf_log_net_init(struct net *net)
 	return 0;
 
 out_sysctl:
-	/* For init_net: errors will trigger panic, don't unroll on error. */
-	if (!net_eq(net, &init_net))
-		remove_proc_entry("nf_log", net->nf.proc_netfilter);
-
+	remove_proc_entry("nf_log", net->nf.proc_netfilter);
 	return ret;
 }
 
diff --git a/net/socket.c b/net/socket.c
index 6b94633..734194d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2612,7 +2612,9 @@ static int __init sock_init(void)
 	 */
 
 #ifdef CONFIG_NETFILTER
-	netfilter_init();
+	err = netfilter_init();
+	if (err)
+		goto out;
 #endif
 
 #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
-- 
1.7.10.4
