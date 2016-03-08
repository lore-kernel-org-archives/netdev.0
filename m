From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/10] netfilter: ipvs: avoid unused variable warnings
Date: Tue,  8 Mar 2016 11:00:42 +0100
Message-ID: <1457431250-3086-3-git-send-email-pablo@netfilter.org>
References: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40447 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932153AbcCHKBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 05:01:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id CED1C8424
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B2F49CA108
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 83A4928D25B
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:01 +0100 (CET)
In-Reply-To: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

The proc_create() and remove_proc_entry() functions do not reference
their arguments when CONFIG_PROC_FS is disabled, so we get a couple
of warnings about unused variables in IPVS:

ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]
ipvs/ip_vs_ctl.c:3950:14: warning: unused variable 'net' [-Wunused-variable]
ipvs/ip_vs_ctl.c:3994:14: warning: unused variable 'net' [-Wunused-variable]

This removes the local variables and instead looks them up separately
for each use, which obviously avoids the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 4c50a8ce2b63 ("netfilter: ipvs: avoid unused variable warning")
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_app.c |  8 ++------
 net/netfilter/ipvs/ip_vs_ctl.c | 15 ++++++---------
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 0328f72..299edc6 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -605,17 +605,13 @@ static const struct file_operations ip_vs_app_fops = {
 
 int __net_init ip_vs_app_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	INIT_LIST_HEAD(&ipvs->app_list);
-	proc_create("ip_vs_app", 0, net->proc_net, &ip_vs_app_fops);
+	proc_create("ip_vs_app", 0, ipvs->net->proc_net, &ip_vs_app_fops);
 	return 0;
 }
 
 void __net_exit ip_vs_app_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	unregister_ip_vs_app(ipvs, NULL /* all */);
-	remove_proc_entry("ip_vs_app", net->proc_net);
+	remove_proc_entry("ip_vs_app", ipvs->net->proc_net);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index daf4cb7..404b2a4 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3945,7 +3945,6 @@ static struct notifier_block ip_vs_dst_notifier = {
 
 int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
 	int i, idx;
 
 	/* Initialize rs_table */
@@ -3972,9 +3971,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 	spin_lock_init(&ipvs->tot_stats.lock);
 
-	proc_create("ip_vs", 0, net->proc_net, &ip_vs_info_fops);
-	proc_create("ip_vs_stats", 0, net->proc_net, &ip_vs_stats_fops);
-	proc_create("ip_vs_stats_percpu", 0, net->proc_net,
+	proc_create("ip_vs", 0, ipvs->net->proc_net, &ip_vs_info_fops);
+	proc_create("ip_vs_stats", 0, ipvs->net->proc_net, &ip_vs_stats_fops);
+	proc_create("ip_vs_stats_percpu", 0, ipvs->net->proc_net,
 		    &ip_vs_stats_percpu_fops);
 
 	if (ip_vs_control_net_init_sysctl(ipvs))
@@ -3989,13 +3988,11 @@ err:
 
 void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	ip_vs_trash_cleanup(ipvs);
 	ip_vs_control_net_cleanup_sysctl(ipvs);
-	remove_proc_entry("ip_vs_stats_percpu", net->proc_net);
-	remove_proc_entry("ip_vs_stats", net->proc_net);
-	remove_proc_entry("ip_vs", net->proc_net);
+	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
+	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
+	remove_proc_entry("ip_vs", ipvs->net->proc_net);
 	free_percpu(ipvs->tot_stats.cpustats);
 }
 
-- 
2.1.4
