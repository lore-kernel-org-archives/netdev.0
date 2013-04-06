From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 45/51] netfilter: enable per netns support for nf_loggers
Date: Sat,  6 Apr 2013 14:17:44 +0200
Message-ID: <1365250670-14993-46-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39095 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163474Ab3DFMSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 08:18:54 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

After this patch, all nf_loggers support net namespace. Still
xt_LOG and ebt_log require syslog netns support.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c |   21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 8d331dc..388656d 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -35,9 +35,6 @@ void nf_log_set(struct net *net, u_int8_t pf, const struct nf_logger *logger)
 {
 	const struct nf_logger *log;
 
-	if (!net_eq(net, &init_net))
-		return;
-
 	if (pf == NFPROTO_UNSPEC)
 		return;
 
@@ -56,9 +53,6 @@ void nf_log_unset(struct net *net, const struct nf_logger *logger)
 	int i;
 	const struct nf_logger *log;
 
-	if (!net_eq(net, &init_net))
-		return;
-
 	mutex_lock(&nf_log_mutex);
 	for (i = 0; i < NFPROTO_NUMPROTO; i++) {
 		log = rcu_dereference_protected(net->nf.nf_loggers[i],
@@ -94,7 +88,6 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 
 	mutex_unlock(&nf_log_mutex);
 
-	nf_log_set(&init_net, pf, logger);
 	return 0;
 }
 EXPORT_SYMBOL(nf_log_register);
@@ -107,17 +100,12 @@ void nf_log_unregister(struct nf_logger *logger)
 	for (i = 0; i < NFPROTO_NUMPROTO; i++)
 		list_del(&logger->list[i]);
 	mutex_unlock(&nf_log_mutex);
-
-	nf_log_unset(&init_net, logger);
 }
 EXPORT_SYMBOL(nf_log_unregister);
 
 int nf_log_bind_pf(struct net *net, u_int8_t pf,
 		   const struct nf_logger *logger)
 {
-	if (!net_eq(net, &init_net))
-		return 0;
-
 	if (pf >= ARRAY_SIZE(net->nf.nf_loggers))
 		return -EINVAL;
 	mutex_lock(&nf_log_mutex);
@@ -133,9 +121,6 @@ EXPORT_SYMBOL(nf_log_bind_pf);
 
 void nf_log_unbind_pf(struct net *net, u_int8_t pf)
 {
-	if (!net_eq(net, &init_net))
-		return;
-
 	if (pf >= ARRAY_SIZE(net->nf.nf_loggers))
 		return;
 	mutex_lock(&nf_log_mutex);
@@ -157,9 +142,6 @@ void nf_log_packet(struct net *net,
 	char prefix[NF_LOG_PREFIXLEN];
 	const struct nf_logger *logger;
 
-	if (!net_eq(net, &init_net))
-		return;
-
 	rcu_read_lock();
 	logger = rcu_dereference(net->nf.nf_loggers[pf]);
 	if (logger) {
@@ -274,9 +256,6 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 	struct net *net = current->nsproxy->net_ns;
 
 	if (write) {
-		if (!net_eq(net, &init_net))
-			return -EPERM;
-
 		if (size > sizeof(buf))
 			size = sizeof(buf);
 		if (copy_from_user(buf, buffer, size))
-- 
1.7.10.4
