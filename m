From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/29] netfilter: ipt_CLUSTERIP: switch to nf_register_net_hook
Date: Fri, 30 Jun 2017 00:53:00 +0200
Message-ID: <1498776807-11124-3-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57572 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751893AbdF2Wxj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0A830BDF51
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:28 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EFCEFD1CA7
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 08784DA57F
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:25 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

one of the last remaining users of the old api, hopefully followup commit
can remove it soon.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 038f293c2376..f30bee8e407b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -743,14 +743,20 @@ static const struct file_operations clusterip_proc_fops = {
 static int clusterip_net_init(struct net *net)
 {
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
+	int ret;
 
 	INIT_LIST_HEAD(&cn->configs);
 
 	spin_lock_init(&cn->lock);
 
+	ret = nf_register_net_hook(net, &cip_arp_ops);
+	if (ret < 0)
+		return ret;
+
 #ifdef CONFIG_PROC_FS
 	cn->procdir = proc_mkdir("ipt_CLUSTERIP", net->proc_net);
 	if (!cn->procdir) {
+		nf_unregister_net_hook(net, &cip_arp_ops);
 		pr_err("Unable to proc dir entry\n");
 		return -ENOMEM;
 	}
@@ -765,6 +771,7 @@ static void clusterip_net_exit(struct net *net)
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 	proc_remove(cn->procdir);
 #endif
+	nf_unregister_net_hook(net, &cip_arp_ops);
 }
 
 static struct pernet_operations clusterip_net_ops = {
@@ -786,17 +793,11 @@ static int __init clusterip_tg_init(void)
 	if (ret < 0)
 		goto cleanup_subsys;
 
-	ret = nf_register_hook(&cip_arp_ops);
-	if (ret < 0)
-		goto cleanup_target;
-
 	pr_info("ClusterIP Version %s loaded successfully\n",
 		CLUSTERIP_VERSION);
 
 	return 0;
 
-cleanup_target:
-	xt_unregister_target(&clusterip_tg_reg);
 cleanup_subsys:
 	unregister_pernet_subsys(&clusterip_net_ops);
 	return ret;
@@ -806,7 +807,6 @@ static void __exit clusterip_tg_exit(void)
 {
 	pr_info("ClusterIP Version %s unloading\n", CLUSTERIP_VERSION);
 
-	nf_unregister_hook(&cip_arp_ops);
 	xt_unregister_target(&clusterip_tg_reg);
 	unregister_pernet_subsys(&clusterip_net_ops);
 
-- 
2.1.4
